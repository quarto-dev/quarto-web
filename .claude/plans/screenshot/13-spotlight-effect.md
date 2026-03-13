# Plan 13: Spotlight Effect for Screenshots

## Goal

Add a reusable `capture.spotlight` feature that dims the page background while
highlighting a specific element. Useful for documentation screenshots that need
to draw attention to a particular UI feature (e.g., repo-actions links, color
scheme toggle, sidebar tools).

## Approach

**CSS injection via cleanup eval** — inject a `<style>` tag with overlay + target
styles, plus a div overlay element. Runs inside `runCleanup`, so it automatically
re-runs after dark mode switch (no dedicated dark-mode code needed).

### Why This Approach

- Piggybacks on existing cleanup re-run mechanism (light + dark for free)
- CSS approach handles stacking contexts cleanly with `!important`
- Idempotent re-inject pattern (remove + re-create on each call)
- `getComputedStyle(document.body).backgroundColor` auto-detects dark bg

### Rejected Alternatives

- Raw `page.evaluate` DOM manipulation: verbose, no relationship to cleanup re-run
- Pure cleanup eval in manifest: can't auto-detect light/dark background
- Dedicated pipeline phase: over-engineered for what cleanup already provides

## Manifest Schema

```json
"spotlight": {
  "selector": ".toc-actions",
  "overlay": 0.5,
  "radius": "6px"
}
```

| Field | Type | Default | Description |
|---|---|---|---|
| `selector` | string | required | CSS selector for element to highlight |
| `overlay` | number | `0.5` | Overlay opacity (0.0–1.0) |
| `radius` | string | `"6px"` | Border-radius on spotlit element |

### Deferred (YAGNI)

- `boxShadow` option
- Per-shot overlay color (hardcoded black)
- Global `defaults.spotlight`
- Coordinate-based targeting (selector covers all current needs)

## Implementation

### Phase 0: Validate with playwright-cli (REQUIRED)

Before writing any capture.js code, the CSS injection approach MUST be tested
interactively using playwright-cli on a real page:

1. Serve the repo-actions example site
2. Open in playwright-cli (headed mode)
3. Apply zoom and cleanup evals (hide navbar/sidebar) as the manifest specifies
4. Manually inject the spotlight CSS + overlay via `eval` command:
   - Test overlay renders correctly (page dims, target element pops)
   - Test with different selectors (`.toc-actions`, etc.)
   - Test light mode appearance
   - Toggle to dark mode and re-inject — verify dark background detection works
   - Test that the target element's background matches the page background
   - Test border-radius appearance
   - Try different overlay opacity values (0.3, 0.5, 0.7)
5. Take preview screenshots and show Chris for visual approval
6. Only proceed to Phase 1 after the visual effect is confirmed working

This step validates the CSS approach before committing to implementation. If
stacking context issues or visual problems arise, adjust the approach here —
not after coding capture.js.

### Phase 1: Core Feature

**capture.js changes (~40 lines):**

1. Add `applySpotlight(page, config)` function after `runCleanup`:
   - Remove any previous `#__spotlight-overlay` and `#__spotlight-style` (idempotent)
   - Detect `body.quarto-dark` for background color
   - Inject `<style>` with overlay (fixed, inset 0, rgba overlay, z-index 9998)
     and target styles (relative, z-index 9999, background, border-radius)
   - Append overlay div to body

2. Extend `runCleanup` to synthesize spotlight step from `shot.capture?.spotlight`
   at end of cleanup sequence, dispatching to `applySpotlight`

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
  position: relative !important;
  z-index: 9999 !important;
  background: {auto-detected-bg} !important;
  border-radius: {radius} !important;
}
```

### Phase 2: Use for repo-actions screenshot

Update manifest entry for `repo-actions`:
```json
"spotlight": {
  "selector": "#quarto-margin-sidebar .toc-actions",
  "overlay": 0.5,
  "radius": "6px"
}
```

### Constraints

- **Incompatible with `trim: true`** — overlay changes the background color that
  trim uses for edge detection. Document this.
- **Only useful with viewport or clip capture** — element capture (`capture.element`)
  clips out the overlay entirely.

### Docs

Add "Spotlight" section to `tools/screenshots/CLAUDE.md` with schema reference
and the trim incompatibility constraint.

## Status

- [ ] Phase 0: Validate CSS approach with playwright-cli
- [ ] Phase 1: Implement spotlight in capture.js
- [ ] Phase 2: Use for repo-actions screenshot
- [ ] Update CLAUDE.md docs
