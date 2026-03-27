# Decisions and Learnings

Architectural decisions and non-obvious gotchas discovered while building this tool.
The reference docs (CLAUDE.md, SETUP.md) cover *what* and *how*. This document
covers *why* and *why not*.

## Why Playwright API, not subprocess calls

The original design used `playwright-cli` subprocess calls via `execSync`. On Windows,
`execSync` goes through `cmd.exe`, which corrupts complex JS strings containing quotes,
template literals, and newlines. Even `execFileSync` with `shell: true` has the same
issue. The fix was switching to the direct Playwright Node.js API — `page.evaluate()`,
`page.screenshot()`, etc. — which eliminates shell quoting entirely.

`playwright-cli` is still used for *interactive* design sessions (the `/screenshot` skill),
where a human iterates on selectors and viewports in a headed browser. `capture.js` replays
the result mechanically via the API.

## Why sharp, not jimp

Both libraries can trim blank edges from PNGs. sharp was chosen because:

- Better trim API: explicit `threshold`, `lineArt: true` mode (correct for PNG screenshots),
  and configurable background color
- Chainable `.trim().extend()` for trim-then-pad in one pipeline
- Fast (C++ libvips with pre-built binaries for Windows/Mac/Linux)

jimp was rejected due to: `cropOnlyFrames: true` default won't crop if content is flush to
one edge; very tight tolerance default (0.0002); open bug #651 for 1-pixel-height results
in edge cases.

## Why clip over element screenshots

`capture.element` screenshots the element's bounding box. Dropdown menus overflow their
parent element bounds, so element screenshots clip the dropdown content. `capture.clip`
computes the union bounding box of multiple CSS selectors (e.g., toolbar + open dropdown),
adding 20px padding. This handles overflow correctly.

## Why `execSync` is kept for quarto render

`capture.js` still uses `execSync` for `node render.js` and `node compress.js`. This is
intentional — these are internal tool scripts with controlled inputs from the manifest and
environment variables, not user-supplied strings. The shell quoting problem only affects
complex JS passed to Playwright.

## Viewport height catch-22

About pages have `min-height: 100vh` on `.quarto-container.page-columns`. This creates a
dilemma:

- Viewport >= content height: the element stretches to fill the viewport → blank space below
- Viewport < content height: Playwright's clip clamps to viewport bounds → content is cut off

Neither reducing viewport height nor CSS zoom solves this (zoom scales content and padding
equally). The solution is content-aware trim via sharp — capture at a comfortable viewport
size, then trim blank edges in post-processing.

## Playwright `style` option doesn't affect clip

Playwright's `screenshot({ style })` injects CSS during the screenshot call, but
`boundingBox()` (used by `computeClip()`) runs *before* `screenshot()`. Injected CSS does
not affect clip measurements. Use cleanup evals to modify the DOM before capture instead.

## JSON Schema: draft-07, not 2020-12

VS Code's JSON language service uses draft-07 for `$schema`-driven autocompletion.
Draft-2020-12 support is partial. Since IDE hover descriptions are a primary benefit of
the schema, draft-07 was chosen.

AJV does not auto-skip `$schema` in instance documents. Under `additionalProperties: false`,
the `$schema` key must be explicitly listed in the root schema's properties or validation
rejects the manifest.

`anyOf` (not `oneOf`) is used for `trimConfig` (boolean | object) because it produces
cleaner error messages for unions.

## Windows CLI detection

`import.meta.url` has a `file:///` prefix with forward slashes; `process.argv[1]` has
OS-native paths. Direct string comparison breaks on Windows. Use:

```js
if (fileURLToPath(import.meta.url) === resolve(process.argv[1])) { ... }
```

## Quarto profile array merging

When a profile YAML defines the same array as the base `_quarto.yml` (e.g.,
`website.navbar.left`), Quarto *concatenates* them instead of replacing. This means
a profile intended to show a different navbar gets the base items plus the profile items.

Fix: move conflicting arrays into dedicated profile files (e.g., `_quarto-reader-mode.yml`),
keeping only shared scalar settings in `_quarto.yml`.

## Profile override precedence

Page-level YAML frontmatter overrides project-level profile settings. If `about.qmd`
includes `template: jolla` in its frontmatter, a profile that sets a different template
is ignored. The `template:` must live exclusively in profile config files.

## Dark mode: JS toggle, not click

At viewports narrower than 992px, Quarto's navbar collapses and the color scheme toggle
button is hidden. Clicking it fails. The JS function `window.quartoToggleColorScheme()` is
identical to the click handler — it toggles classes, stylesheets, persists to localStorage,
and dispatches resize. Using `page.evaluate()` to call it directly bypasses visibility issues.

The dark variant reloads the page fresh (not just toggling in-place) because cleanup evals
(hiding elements, spotlight CSS) get clobbered by the theme switch. Reload → dark toggle →
cleanup → capture ensures correct state.

## Stateful toggles and dark mode

Reader mode persists state in `localStorage`. The light pass activates it, then the dark
reload inherits the active state from localStorage. A plain `click` interaction would
*deactivate* it on the dark pass. Fix: use `eval` with a guard condition:

```json
{ "action": "eval", "script": "const el = document.querySelector('.nav-link.reader-toggle'); if (!el.classList.contains('active')) el.click();" }
```

## Spotlight stacking contexts

CSS `z-index` on the target element alone doesn't lift it above the overlay when an
ancestor creates a stacking context (e.g., `#quarto-margin-sidebar` with `position: sticky;
z-index: 1`). The `elevate` field lifts the ancestor above the overlay, and `dim` fades
siblings within the elevated container.

## CI compression: oxipng with cargo cache

The GitHub Actions workflow installs oxipng via `cargo install`. Without caching,
compilation takes ~1 minute. `actions/cache` on `~/.cargo/` with key
`${{ runner.os }}-cargo-oxipng` avoids recompilation on subsequent runs.

Key flags: `-o 4` (highest recommended optimization), `-i 0` (remove interlacing, saves
25-50%), `--strip safe` (remove non-rendering metadata).

## Multi-colored backgrounds defeat trim

Content-aware trim detects background from the top-left pixel. Pages with different-colored
regions (e.g., dark navbar above white body) have no single background color. Trim either
removes too much or nothing. Use `maxHeight` or `cropBottom` instead for these layouts.

## quarto-demo as git subtree

Navigation screenshots need realistic site content (sidebars, breadcrumbs, ToC). Rather
than maintaining large example projects or screenshotting live URLs (which change
unpredictably), `examples/quarto-demo/` is a squash subtree of
[quarto-dev/quarto-demo](https://github.com/quarto-dev/quarto-demo).

This enables local profile overrides (floating sidebar, repo-actions) while reusing real
content. The upstream project uses `freeze: true`, so no Python or R is needed for
rendering — `_freeze/` contains pre-computed results.

## Miscellaneous learnings

- Example projects with no navigation need an explicit `render:` list in `_quarto.yml` —
  Quarto's auto-discovery finds 0 files without navigation links
- Always use named playwright-cli sessions (`-s=screenshot`) to avoid collisions with
  the `default` session
- `serve.js` takes a directory path, not a `--profile` flag. For profiled renders, serve
  the output directory directly (e.g., `examples/navbar-basic/docs-reader-mode/`)
- Console errors for `favicon.ico` are harmless and expected
- PR deploy previews show the full quarto.org site, not example projects — all screenshots
  need self-contained example projects
- Use specific selectors when pages have multiple instances of an icon (e.g.,
  `#quarto-navigation-tool-dropdown-0` instead of `.bi-github` on quarto-demo pages)
- `npm` in Git Bash (with nvm/scoop) resolves to an extensionless shell script that breaks
  on `npm run`. Use `npm.cmd` instead
- `$()` command substitution is blocked by Claude Code's permission check system. Use
  `${CLAUDE_SKILL_DIR}` (expanded by Claude Code, not the shell) for CWD-independent paths
