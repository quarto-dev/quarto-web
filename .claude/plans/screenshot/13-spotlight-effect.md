# Plan 13: Spotlight Effect for Screenshots

## Goal

Add a reusable `capture.spotlight` feature that dims the page background while
highlighting a specific element. Useful for documentation screenshots that need
to draw attention to a particular UI feature (e.g., repo-actions links, color
scheme toggle, sidebar tools).

## Approach

**CSS injection via `page.evaluate`** — inject a `<style>` tag with overlay +
target styles, plus a div overlay element. Called from `runCleanup`, so it
automatically re-runs after dark mode switch (no dedicated dark-mode code needed).

### Why This Approach

- Piggybacks on existing cleanup re-run mechanism (light + dark for free)
- Idempotent re-inject pattern (remove + re-create on each call)
- `getComputedStyle(document.body).backgroundColor` auto-detects dark bg
- Self-contained manifest block — all spotlight config in one place

### Rejected Alternatives

- Pure cleanup eval in manifest: can't auto-detect light/dark background
- Dedicated pipeline phase: over-engineered for what cleanup already provides
- Minimal spotlight + separate cleanup evals for z-index: splits related config
  across two manifest keys, harder to understand

## Manifest Schema

```json
"spotlight": {
  "selector": ".toc-actions",
  "elevate": "#quarto-margin-sidebar",
  "dim": "#TOC.toc-active > ul:first-of-type",
  "overlay": 0.5,
  "radius": "6px",
  "padding": "8px"
}
```

| Field | Type | Default | Description |
|---|---|---|---|
| `selector` | string | required | CSS selector for element to highlight |
| `elevate` | string | `null` | CSS selector for ancestor to lift above overlay (stacking context fix) |
| `dim` | string or string[] | `null` | CSS selector(s) for siblings/elements to fade within the elevated container |
| `overlay` | number | `0.5` | Overlay opacity (0.0–1.0) |
| `radius` | string | `"6px"` | Border-radius on spotlit element |
| `padding` | string | `"8px"` | Padding around spotlit element |

### Stacking Context Problem (why `elevate` exists)

CSS stacking contexts trap child z-indexes. If the target element has an ancestor
with `position: sticky/fixed/relative` + `z-index` (common in Quarto layouts —
e.g., `#quarto-margin-sidebar` is `position: sticky; z-index: 1`), then setting
z-index: 9999 on the target has NO effect outside that context.

**Solution:** `elevate` lifts the entire ancestor container above the overlay
(z-index 9999). Then `dim` fades other elements inside that container so only
the target stands out.

**How to diagnose:** Walk up the DOM from the target checking `getComputedStyle`
for `position` (not static) + `z-index` (not auto). Any match creates a stacking
context. The `elevate` selector should point to that ancestor.

**When `elevate` is NOT needed:** If the target element has no stacking context
ancestors (e.g., it's a direct child of `body` or all ancestors are `static`),
the basic spotlight (overlay + target z-index) works without `elevate`.

### Deferred (YAGNI)

- `boxShadow` option
- Per-shot overlay color (hardcoded black)
- Global `defaults.spotlight`
- Coordinate-based targeting (selector covers all current needs)

## Implementation

### Phase 0: Validate with Chrome DevTools / playwright-cli (REQUIRED) — DONE

Validated interactively using Chrome DevTools MCP on repo-actions page:

1. Served repo-actions example site at localhost
2. Applied zoom (1.25) and cleanup evals (hide navbar/sidebar)
3. Injected spotlight CSS — discovered stacking context issue:
   - `#quarto-margin-sidebar` has `position: sticky; z-index: 1` → traps child z-indexes
   - Setting z-index 9999 on `.toc-actions` alone had NO visible effect
   - **Fix:** elevate entire margin sidebar to z-index 9999, then fade TOC siblings
4. Visual result approved by Chris at overlay opacity 0.5

**Key finding:** Simple spotlight (overlay + target z-index) doesn't work for most
Quarto layouts because sticky sidebars create stacking contexts. The `elevate` +
`dim` fields are essential for real-world use.

**Debugging tip:** When spotlight doesn't visually highlight, use Chrome DevTools MCP
(`evaluate_script`) to walk up the DOM checking for stacking context creators.
Faster feedback loop than playwright-cli for this kind of CSS debugging.

### Phase 1: Core Feature

**capture.js changes (~50 lines):**

1. Add `applySpotlight(page, spotlightConfig)` function:
   - Remove any previous `#__spotlight-overlay` and `#__spotlight-style` (idempotent)
   - Detect background color via `getComputedStyle(document.body).backgroundColor`
   - Inject `<style>` with:
     - Overlay: fixed, inset 0, rgba(0,0,0, {overlay}), z-index 9998
     - Target: background {bg}, border-radius {radius}, padding {padding}
     - Elevate (if set): z-index 9999 on ancestor
     - Dim (if set): opacity 0.3 on sibling elements
   - Append overlay div to body

2. Call `applySpotlight` at end of `runCleanup` when `shot.capture?.spotlight` exists

3. Fix clip+dark path: add `runCleanup` after `switchToLight` (line ~445) before
   `runInteractions`. Pre-existing correctness gap — dark cleanup overwrites
   spotlight background, then light screenshot uses wrong color without re-run.

**Key CSS rules:**
```css
#__spotlight-overlay {
  position: fixed;
  inset: 0;
  background: rgba(0, 0, 0, {overlay});
  z-index: 9998;
  pointer-events: none;
}
{selector} {
  background: {auto-detected-bg} !important;
  border-radius: {radius} !important;
  padding: {padding} !important;
}
/* Only when elevate is set */
{elevate} {
  z-index: 9999 !important;
}
/* Only when dim is set */
{dim} {
  opacity: 0.3 !important;
}
/* Only when elevate is NOT set (simple case) */
{selector} {
  position: relative !important;
  z-index: 9999 !important;
}
```

### Phase 2: Use for repo-actions screenshot

Update manifest entry for `repo-actions`:
```json
"spotlight": {
  "selector": ".toc-actions",
  "elevate": "#quarto-margin-sidebar",
  "dim": "#TOC.toc-active > ul:first-of-type",
  "overlay": 0.5,
  "radius": "6px",
  "padding": "8px"
}
```

### Constraints

- **Incompatible with `trim: true`** — overlay changes the background color that
  trim uses for edge detection. Document this.
- **Only useful with viewport or clip capture** — element capture (`capture.element`)
  clips out the overlay entirely.

### Docs

Add "Spotlight" section to `tools/screenshots/CLAUDE.md` covering:
- Schema reference (all 6 fields)
- Stacking context explanation and how to diagnose
- When `elevate`/`dim` are needed vs simple spotlight
- Constraints (trim incompatibility, viewport/clip only)
- Debugging tip: use Chrome DevTools MCP when stuck

## Status

- [x] Phase 0: Validate CSS approach (Chrome DevTools MCP) — approved
- [x] Phase 1: Implement spotlight in capture.js — commit `08f55bff9`
- [x] Phase 2: Use for repo-actions screenshot — captured `dfefda1a4`
- [ ] Update CLAUDE.md docs
