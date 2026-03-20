# Plan 11: Manifest JSON Schema

## Context

Manifest fields (viewport, zoom, trim, spotlight, etc.) are only documented in prose
across CLAUDE.md, SETUP.md, and plan files. No validation catches typos or wrong types
before capture runs — bad field names silently do nothing (via optional chaining `?.`),
wrong types cause confusing runtime errors mid-capture.

Additionally, during investigation we found:
- `defaults.dark.toggle` is dead config from the old click-based approach (replaced by
  `quartoToggleColorScheme()` JS call). Several files still reference it incorrectly.
- `defaults.compress` exists in manifest but is never read by capture.js.
- `source.type: "local"` is scaffolded in groupBySource but never implemented.

This plan addresses all of these alongside the schema work.

## Goals

1. JSON Schema for `manifest.json` — documents every field with descriptions
2. IDE autocompletion when editing manifest.json (VS Code `$schema` reference)
3. `npm run validate` — standalone fast check for the /screenshot workflow
4. `capture.js` validates on startup too — safety net for direct invocation
5. `help.js` prints field reference from the schema (single source of truth)
6. Clean up dead toggle references
7. Wire up `defaults.compress`
8. Implement `source.type: "local"` routing

## Files

| File | Action | ~Lines |
|---|---|---|
| `tools/screenshots/manifest-schema.json` | **Create** — JSON Schema draft-07 | ~250 |
| `tools/screenshots/scripts/validate.js` | **Create** — standalone validate command, exports `validateManifest()` + `formatErrors()` | ~55 |
| `tools/screenshots/manifest.json` | Add `$schema`, remove `dark.toggle` | +1, -1 |
| `tools/screenshots/package.json` | Add `ajv` dependency, add `validate` script | +2 |
| `tools/screenshots/capture.js` | Import validate, compress wiring, local routing, toggle comment | ~20 |
| `tools/screenshots/scripts/help.js` | Rewrite: schema-driven field reference + validate command | ~130 |
| `tools/screenshots/CLAUDE.md` | Add validate to workflow + tools, source.path, dark mode phrasing, compress note | ~8 |
| `tools/screenshots/SETUP.md` | Fix dark mode (line 109), add validate command | ~4 |
| `.claude/skills/screenshot/SKILL.md` | Add validate step to Phase B workflow (line 126) | ~2 |
| `.claude/skills/screenshot/capture-agent.md` | Fix wrong dark mode instructions (lines 150, 154) | ~10 |
| `.claude/skills/screenshot/manifest-schema.md` | Remove toggle row, fix local source docs, add validate | ~8 |

## Design Decisions

**JSON Schema draft-07** — VS Code's JSON language service uses draft-07 for
`$schema`-driven autocompletion. Draft-2020-12 support is partial.

**ajv v8 for runtime validation** — Standard JSON Schema validator. ESM-compatible:
`import Ajv from 'ajv'` works directly in `"type": "module"` packages (confirmed in
AJV docs). `allErrors: true` reports all problems at once.

**`$schema` in root properties** — AJV does NOT auto-skip `$schema` in instance
documents. With `additionalProperties: false`, `$schema` must be explicitly listed
in the root schema's `properties` as `{ "type": "string" }`, or validation rejects it.

**Strict source type discrimination with `if/then/else`** — Schema requires
type-specific fields: `type: "example"` requires `project`, `type: "url"` requires
`url`, `type: "local"` requires `path`. Catches the common mistake of wrong type/field
combos. Worth the schema complexity since the manifest is hand-edited.

**`additionalProperties: false` everywhere** — Catches typos (e.g., `viewprot` instead
of `viewport`). Worth the strictness for a manifest that's hand-edited.

**`trimConfig` uses `anyOf` not `oneOf`** — For boolean/object unions, `anyOf` produces
cleaner error messages. Only one branch can match a given value type anyway.

**`interactionStep` is a flat object** — All fields optional except `action`. Fields
like `wait` (only valid with `click`), `script` (only with `eval`) documented via
descriptions. Only 3 interaction entries in the manifest — per-action discriminated
unions aren't worth the complexity.

**Two-layer validation** — `scripts/validate.js` is the primary validation tool for
the /screenshot workflow (Claude calls it after editing manifest.json). `capture.js`
also validates on startup as a safety net. Shared logic: validate.js exports a
`validateManifest()` function, capture.js imports and calls it.

**Custom error messages for `if/then/else`** — AJV's default messages for
`if/then/else` schemas are opaque ("should match 'then' schema"). Post-process
source type discrimination errors into readable messages like `source type "example"
requires "project" field`. Detect `if/then` keyword errors, look at sibling errors
for the failing `then` branch, combine into human-readable output.

## Step 1: Clean up dark toggle leftovers

Remove dead `defaults.dark.toggle` field and fix all references to the old
click-based dark mode approach.

| File | Change |
|---|---|
| `manifest.json:10` | Remove `"toggle": ".quarto-color-scheme-toggle"` |
| `capture-agent.md:150` | Replace `playwright-cli ... locator('.quarto-color-scheme-toggle').click()` with `eval "window.quartoToggleColorScheme()"` |
| `capture-agent.md:154` | Replace "Click toggle again to return to light mode" with same JS eval |
| `manifest-schema.md:34` | Remove `toggle` row from defaults.dark table |
| `SETUP.md:109` | Rewrite: "Dark mode uses `quartoToggleColorScheme()` via JS" |
| `capture.js:264` | Simplify comment to remove old-approach framing (optional) |

## Step 2: Create `manifest-schema.json`

JSON Schema draft-07 with `$defs` for reused shapes.

**Root schema properties:** `$schema` (string), `defaults`, `screenshots` (array).
All three listed explicitly — `$schema` is required because AJV treats it as a
regular property under `additionalProperties: false`.

**`$defs`:**

- `viewport` — `{width: integer, height: integer}`, `additionalProperties: false`
- `cleanupStep` — `{action: "eval", script: string}`
- `interactionStep` — `{action: enum["click","hover","wait","eval","scroll"], selector?, wait?, timeout?, script?}`. Descriptions note per-action validity (e.g., `wait` field: "CSS selector to wait for after click action")
- `spotlightConfig` — `{selector(req), elevate?, dim?(string|string[]), overlay?(0-1, default 0.5), radius?(default "6px"), padding?(default "8px")}`. Descriptions include default values.
- `trimConfig` — `anyOf [boolean, {threshold?(default 10), padding?(default 20), background?}]`
- `darkConfig` — `{ready?, readyLight?, settle?}` (NO toggle — removed in step 1)
- `sourceConfig` — base: `{type: enum["example","url","local"]}`, discriminated by `type`:
  - `if type: "example"` → `then required: ["project"]`, optional `page`, `profile`
  - `if type: "url"` → `then required: ["url"]`
  - `if type: "local"` → `then required: ["path"]`, optional `page`
  - All source fields listed in `properties` with descriptions noting which type they belong to
- `captureConfig` — viewport?, zoom?, clip?(string[]), element?(string), trim?, cropBottom?(integer), maxHeight?(integer), cleanup?, interaction?, spotlight?
- `docConfig` — `{file(req), alt(req)}`
- `defaultsConfig` — viewport?, compress?(boolean), zoom?, trim?, cleanup?, dark?
- `screenshotEntry` — `{name(req), output(req), dark(req), source(req), capture(req), doc(req)}`

### Defaults field membership

Only fields with fallback logic in capture.js:

| Field | capture.js line | In defaults |
|---|---|---|
| `viewport` | 468 | Yes |
| `compress` | (wired in step 3) | Yes |
| `zoom` | 478 | Yes |
| `trim` | 385 | Yes |
| `cleanup` | 165 | Yes |
| `dark` | 266+ | Yes |
| `cropBottom` | 390 (no fallback) | No |
| `maxHeight` | 391 (no fallback) | No |
| `spotlight` | 171 (no fallback) | No |
| `interaction` | 231 (no fallback) | No |

## Step 3: Wire up `defaults.compress` in capture.js

Currently `defaults.compress: true` is in manifest but never read. Fix:

```js
// At MODULE SCOPE, after manifest validation (after ~line 60), before line 63
const shouldCompress = (manifest.defaults.compress ?? true) && !noCompress;
```

**Must be at module scope** — `compressPng()` is defined at module scope (line 334)
and currently closes over module-level `noCompress`. If `shouldCompress` were inside
`main()`, `compressPng` wouldn't see it.

Then in `compressPng()`, replace `if (noCompress) return;` with `if (!shouldCompress) return;`.

## Step 4: Implement `source.type: "local"` routing

Three changes in capture.js, one in manifest-schema.md:

**Fix `groupBySource` key (line ~99):**
```js
// BEFORE: local:${s.source.page || 'site'}
// AFTER:
: `local:${s.source.path}`;
```

**Add routing branch in main loop (after the `url` branch, ~line 426):**
```js
} else if (shots[0].source.type === 'local') {
  const siteDir = resolve(REPO_ROOT, shots[0].source.path);
  if (!dryRun) {
    server = await startServer(siteDir);
    baseUrl = server.url;
    console.log(`  Serving ${siteDir} at ${baseUrl}`);
  }
}
```

No changes needed to `startServer`, `shotUrl`, or the `finally` cleanup block — they
all work as-is for local sources. list.js also handles local sources already (line 35:
`s.source.path || s.source.page`).

**Update `manifest-schema.md` (lines 87-89):** Change local source example from
`"page": "docs/..."` to `"path": "some/built/site"`, remove "not yet used, reserved"
label. Document that `path` is relative to repo root.

## Step 5: Add `$schema` to manifest.json

First key: `"$schema": "./manifest-schema.json"`. VS Code resolves relative to file.

## Step 6: Install ajv, create validate command, wire into capture.js

```bash
cd tools/screenshots && npm.cmd install ajv
```

### `scripts/validate.js` (~40 lines)

Standalone validation script. Exports a reusable function and runs as CLI:

```js
import Ajv from 'ajv';
import { readFileSync } from 'node:fs';
import { join, dirname, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

const __dirname = dirname(fileURLToPath(import.meta.url));
const TOOLS_DIR = join(__dirname, '..');

export function validateManifest(manifest) {
  const schema = JSON.parse(readFileSync(join(TOOLS_DIR, 'manifest-schema.json'), 'utf8'));
  const ajv = new Ajv({ allErrors: true });
  const validate = ajv.compile(schema);
  if (validate(manifest)) return { valid: true, errors: [] };
  return {
    valid: false,
    errors: formatErrors(validate.errors)
  };
}

// Post-process AJV errors for readability. if/then/else errors get combined
// into messages like: source type "example" requires "project" field.
function formatErrors(errors) { /* ~15 lines — see design decision above */ }

// CLI mode: run directly with `node scripts/validate.js`
// Use resolve() comparison — import.meta.url has file:/// prefix with forward slashes
// while process.argv[1] has OS-native paths. Direct string comparison breaks on Windows.
if (fileURLToPath(import.meta.url) === resolve(process.argv[1])) {
  const manifest = JSON.parse(readFileSync(join(TOOLS_DIR, 'manifest.json'), 'utf8'));
  const result = validateManifest(manifest);
  if (result.valid) {
    console.log('manifest.json is valid');
    process.exit(0);
  } else {
    console.error('manifest.json validation failed:');
    result.errors.forEach(e => console.error(`  ${e}`));
    process.exit(1);
  }
}
```

Add to `package.json` scripts: `"validate": "node scripts/validate.js"`

### capture.js validation (safety net)

At top of capture.js:
```js
import { validateManifest } from './scripts/validate.js';
```

After line 60 (`const manifest = JSON.parse(...)`), at module scope:
```js
const validation = validateManifest(manifest);
if (!validation.valid) {
  console.error('manifest.json validation failed:');
  validation.errors.forEach(e => console.error(`  ${e}`));
  process.exit(1);
}
```

## Step 7: Rewrite help.js

Replace static console.log with schema-reading field reference. Reads
`manifest-schema.json`, walks `$defs`, prints formatted output grouped by section:
entry fields, source, capture, interaction, spotlight, doc, defaults.

Format per field: `name  type  (required|optional)  description`

Keep the existing commands section at the top (add `npm run validate`), append field
reference below.

Handle missing schema file gracefully (fall back to commands-only output with a note).

## Step 8: Documentation updates

### `tools/screenshots/CLAUDE.md`

| Section | Change |
|---|---|
| "Creating New Screenshots" (line 27) | Add step 3.5: "Run `npm run validate` to check the entry" between encoding and capturing |
| "Tools" table (line 36) | Add row: `npm run validate` — Validate manifest.json against schema |
| "Manifest" (line 49) | Add note: "Schema: `manifest-schema.json` — provides IDE autocompletion via `$schema`" |
| "Manifest" path conventions (line 53) | Add: `source.path` — relative to repo root (for `type: "local"`) |
| "Dark Mode" (line 62-63) | Minor: remove "the same function the toggle button calls" phrasing |
| "Compression" (line 209) | Add note about `defaults.compress` controlling default behavior |

### `.claude/skills/screenshot/SKILL.md`

| Section | Change |
|---|---|
| Setup commands (line 11) | No change needed — already reads manifest-schema.md |
| Phase B step 1-2 (lines 126-127) | Add: "Run `npm run validate` after adding the manifest entry, before capturing" |
| Source type table (line 46) | Remove `preview` (not implemented anywhere). Update `local` description: serves a pre-built site directory, `path` field required |

### `.claude/skills/screenshot/capture-agent.md`

Already in Step 1 (dark toggle fix at lines 150, 154).

### `.claude/skills/screenshot/manifest-schema.md`

Already in Step 1 (remove toggle row) and Step 4 (fix local source docs).
Additionally: add `npm run validate` to the commands section if one exists.

### `tools/screenshots/SETUP.md`

Already in Step 1 (fix dark mode line 109).
Additionally: mention `npm run validate` in the commands overview section.

## Verification

1. **Validate command works**: `npm run validate` → "manifest.json is valid"
2. **Validate catches typos**: Add `"viewprot"` to an entry → `npm run validate` → error
3. **Validate catches missing required fields**: `{"type": "example"}` without
   `project` → `npm run validate` → error about required field
4. **Capture validates too**: `npm run capture -- --list` → validation passes, list prints
5. **IDE autocompletion**: Open `manifest.json` in VS Code → fields autocomplete,
   descriptions show on hover
6. **Help output**: `npm run help` prints field reference from schema + validate command
7. **Compress wiring**: Set `defaults.compress: false`, run capture without
   `--no-compress` → compression skipped
8. **Local routing**: Add a temporary manifest entry with `type: "local"` pointing to
   an existing `_site/` directory → server starts, page loads, screenshot captured
9. **Capture still works**: `npm run capture -- --name navbar-tools` produces image
10. **Source discrimination errors are readable**: `{"type": "example"}` without
    `project` → message says `source type "example" requires "project"`, not
    `should match "then" schema`
11. **Windows path test**: Run `npm run validate` from Git Bash (confirms
    `fileURLToPath`/`resolve` CLI detection works on Windows)
