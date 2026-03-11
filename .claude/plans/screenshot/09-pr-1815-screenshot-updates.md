# Sub-plan 09: PR #1815 Screenshot Updates

Parent: [00-index.md](00-index.md)
PR: https://github.com/quarto-dev/quarto-web/pull/1815

## Context

PR #1815 moves examples from Twitter to Bluesky across quarto-web docs. Several doc pages reference screenshots that need updating with the new icons and examples. This plan describes what to do in that PR using the screenshot tooling built in this branch.

## Screenshots Produced

The tooling branch produces 8 screenshots (16 images with dark variants) via `capture.js`:

| Image | Light | Dark | Viewport | Source |
|-------|-------|------|----------|--------|
| about-jolla | `about-jolla.png` | `about-jolla-dark.png` | 1200x900 | about-pages profile=jolla |
| about-trestles | `about-trestles.png` | `about-trestles-dark.png` | 1200x900 | about-pages profile=trestles |
| about-solana | `about-solana.png` | `about-solana-dark.png` | 1200x900 | about-pages profile=solana |
| about-marquee | `about-marquee.png` | `about-marquee-dark.png` | 1200x900 | about-pages profile=marquee |
| about-broadside | `about-broadside.png` | `about-broadside-dark.png` | 1200x900 | about-pages profile=broadside |
| navbar-tools | `navbar-tools.png` | `navbar-tools-dark.png` | 1440x400 | navbar-tools |
| sidebar-tools | `tools.png` | `tools-dark.png` | 400x300 | sidebar-tools |
| myblog | `myblog.png` | `myblog-dark.png` | 1440x900 | myblog |

## .qmd Changes Needed in PR #1815

Add `.include-dark` class to image references so the `filters/include-dark.lua` filter generates both light and dark `<img>` tags. The filter expects a `-dark` variant at the same path.

Also update alt text to reference Bluesky instead of Twitter.

### `docs/websites/website-about.qmd`

5 image references for about templates. Each needs `.include-dark` added and alt text updated:

| Approx line | Template | Change |
|-------------|----------|--------|
| ~69 | jolla | Add `.include-dark`, update alt text |
| ~73 | trestles | Add `.include-dark`, update alt text |
| ~77 | solana | Add `.include-dark`, update alt text |
| ~81 | marquee | Add `.include-dark`, update alt text |
| ~85 | broadside | Add `.include-dark`, update alt text |

Note: about-jolla `.include-dark` was already added in commit `104974f` on the twitter-to-bluesky branch. The remaining 4 templates need it.

### `docs/websites/website-navigation.qmd`

| Approx line | Image | Change |
|-------------|-------|--------|
| ~112 | navbar-tools | Already done in `104974f` |
| ~276 | sidebar-tools (tools.png) | Add `.include-dark`, update alt text (Twitter → Bluesky) |

### `docs/websites/website-blog.qmd`

| Approx line | Image | Change |
|-------------|-------|--------|
| ~111 | myblog | Add `.include-dark`, update alt text (Twitter → Bluesky) |

## Alt Text Updates

All example projects now use Bluesky instead of Twitter. Update alt text:
- "Twitter and Github logo" → "Bluesky and Github logo"
- "buttons for twitter and github" → "buttons for Bluesky and GitHub"
- Blog screenshot alt text should mention Bluesky icon in navbar

## Workflow

All 8 screenshots already exist in the manifest with examples ready. This happens
on the **twitter-to-bluesky** branch, not the screenshot-tool branch:

1. Run capture to generate all 16 images (8 light + 8 dark):
   ```bash
   npm run capture
   ```
2. Visually verify each screenshot (compare with existing originals)
3. If any look wrong, use `/screenshot` to iterate on manifest entry or example project, then re-run `npm run capture`
4. Copy final images to the twitter-to-bluesky branch
5. Add `.include-dark` and update alt text in the 3 .qmd files
6. Commit images and .qmd changes together
7. Compression: CI handles it after merge, or run `npm run compress` locally

## Progress

### Done (images cherry-picked to twitter-to-bluesky)
- **About pages** (5): all screenshots captured with trim + zoom, dark variants included
- **myblog**: reworked example (post images, blue navbar, page-layout: full), maxHeight: 640 cropping, dark variant works
- `.include-dark` + alt text for about-jolla and navbar-tools (commit `104974f`)

### Remaining
- **navbar-tools**: images regenerated in worktree but not yet committed/cherry-picked to twitter-to-bluesky
- **sidebar-tools** (tools.png): images regenerated in worktree but not yet committed/cherry-picked; `.include-dark` + alt text still needed in `website-navigation.qmd`
- **myblog**: `.include-dark` + alt text still needed in `website-blog.qmd`
- Remaining `.include-dark` + alt text changes in `website-about.qmd` (4 templates) and `website-navigation.qmd` (sidebar-tools)
