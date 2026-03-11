# Sub-plan 10: Tight Cropping for Screenshots

Parent: [00-index.md](00-index.md)

## Problem

About-page screenshots have ~200px of blank space below content. The clip faithfully captures the element's bounding box, but the element is inflated by:

1. **`min-height: 100vh`** on `.quarto-container.page-columns` — stretches the grid container to fill viewport
2. **Internal padding** on `.quarto-about-*` elements (14px top, 17px bottom)
3. The about-page flex children stretch to fill their grid cell

Content (social links) ends at ~617px but the element extends to ~842px at 900px viewport height.

## Root Cause Confirmed

Investigated via Chrome DevTools MCP on broadside template:
- `.quarto-container.page-columns` has `min-height: 100vh` (computed ~820px at 900px viewport)
- `.quarto-about-broadside` content ends at 617px (social links bottom)
- Element height: 760px (stretched by parent) → 634px (with `min-height: auto` on parent)
- Clip result: 1030×842 (before fix) → 1030×654 (after fix)

## Approaches Investigated

### Approach A: Reduce viewport height

**Result: Does not work.** This is a catch-22:
- Viewport >= content height: `min-height: 100vh` stretches element → blank space
- Viewport < content height: clip clamps to viewport bounds → loses content (Bluesky/Github buttons cut off)

Tested with viewport height 650: viewport=592px (after chrome), element=634px, buttons clipped.

### Approach B: CSS zoom

**Result: Does not fix blank space for clip-based captures.** CSS zoom (`document.body.style.zoom`) scales content AND padding equally — the content-to-blank ratio is invariant under uniform scaling. Zoom only helps for viewport-mode captures (makes content fill more of the fixed viewport).

### Approach C: Cleanup eval (DOM manipulation before clip)

**Result: Works.** Add cleanup step to remove `min-height`:
```js
document.querySelector('.quarto-container').style.minHeight = 'auto'
```
Element collapses from 760→634px. Clip captures tight bounding box.

**Pros:**
- Zero dependencies, uses existing cleanup mechanism
- Applied before `computeClip()` so bounding box reflects the change
- Can target specific CSS properties causing the problem

**Cons:**
- Requires knowing which CSS properties cause blank space per layout
- Fragile if Quarto CSS changes class names or layout strategy
- Doesn't handle blank space from element internal padding

### Approach D: Playwright `style` option (v1.41+)

**Result: Partially applicable.** `page.screenshot({ style: '...' })` injects CSS during capture only, auto-reverts.

```js
await page.screenshot({
  clip: computedClip,
  style: '.quarto-container { min-height: auto !important }'
});
```

**Critical limitation:** `style` is applied during `screenshot()`, but `boundingBox()` (used by `computeClip()`) runs BEFORE `screenshot()`. The injected CSS does NOT affect clip measurements.

**Workaround:** Use `page.addStyleTag()` before `computeClip()` instead. Functionally equivalent to cleanup eval but uses CSS injection instead of inline style manipulation.

**Where `style` IS useful:** For visual-only changes that don't affect clip (hiding cursors, animations, banners during capture). Could complement cleanup evals.

### Approach E: Post-processing trim (sharp or jimp)

**Result: Most robust general solution.** Trim whitespace from the PNG after capture.

**sharp** (recommended over jimp):
```js
await sharp(outputPath)
  .trim({ threshold: 10, lineArt: true })
  .extend({ top: 20, bottom: 20, left: 20, right: 20, background: '#ffffff' })
  .toFile(trimmedPath);
```

**jimp** alternative:
```js
image.autocrop({ tolerance: 0.001, cropOnlyFrames: false, leaveBorder: 20 })
```

**sharp advantages:**
- Better trim API (threshold + lineArt mode + explicit background)
- Chainable `.trim().extend()` for trim-then-pad
- Fast (C++ libvips underneath)
- Pre-built binaries for Windows/Mac/Linux
- `lineArt: true` correct for PNG screenshots (no noise smoothing)

**jimp advantages:**
- Pure JavaScript — zero native dependencies
- Simpler install, no platform-specific binaries

**jimp risks:**
- `cropOnlyFrames: true` default — won't crop if content is flush to one edge
- Very tight tolerance default (0.0002) — may not trim anti-aliased edges
- Open bug: 1-pixel-height result in edge cases (#651)

**Both handle dark mode:** Detect background from top-left pixel (or specify explicitly).

**sharp risks:**
- Native dependency (pre-built binaries cover all common platforms)
- Windows DLL conflict if `canvas` module also loaded (not applicable to us)
- v0.35.0 drops Node 18 support

## Recommendation

**Use Approach E (sharp trim) as the primary solution for blank space. Cleanup eval (Approach C) remains a general-purpose tool for DOM/style manipulation before clip computation.**

Rationale:
1. Sharp trim is content-aware — handles any source of blank space without knowing the CSS cause
2. Combined with zoom (1.15), produces readable fonts + tight layout in one pass
3. Cleanup eval is a general mechanism for modifying DOM or styles before clipping — useful when you need to change what the page looks like before capture (removing elements, adjusting layout, etc.), independent of trim

### Implementation plan

**Phase 1 — Cleanup eval (done):**
- Added `capture.cleanup` to all 5 about-page manifest entries
- Verified tight cropping visually
- Later removed from about-pages when sharp trim made it unnecessary for this specific case

**Phase 2 — sharp trim (done):**
- Added `sharp` to `tools/screenshots/package.json`
- Added `capture.trim` manifest option (`true` or `{ threshold, padding }`)
- In capture.js: `trimPng()` runs after screenshot, before compress
- Background auto-detected from top-left pixel (handles light + dark)
- Combined with zoom (1.15) for readable fonts + tight layout

**Phase 3 — myblog rework (done):**
- Updated myblog example to match `quarto create project blog` output: post thumbnail images, `page-layout: full`, `background: primary` on navbar, `posts/_metadata.yml`
- Dark mode works without trim — navbar is muted blue, body is dark gray, no blue band issue
- Used `maxHeight: 640` to crop blank space below content (content ends ~593px in 900px viewport)
- Trim not used for myblog — multi-colored background (navbar vs body) prevents content-aware edge detection

**Phase 4 — Playwright `style` support (future):**
- Add `capture.style` manifest field (CSS string)
- Pass to `page.screenshot({ style })` for visual-only overrides
- Document in manifest spec

## Decision Log

| Approach | Verdict | Why |
|----------|---------|-----|
| Reduce viewport height | Rejected | Catch-22 with clip clamping |
| CSS zoom | Rejected for clip mode | Scales content + padding equally |
| Cleanup eval | **Available** | General-purpose DOM/style manipulation before clip; complements trim |
| Playwright `style` | Deferred | Doesn't affect clip computation |
| sharp post-processing | **Accepted (primary)** | Content-aware, handles any blank space source, works with dark mode |
| jimp post-processing | Rejected | Less reliable API, open bugs |
