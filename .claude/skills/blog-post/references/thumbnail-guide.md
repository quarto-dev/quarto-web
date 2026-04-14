# Thumbnail Guide

Design conventions for blog post listing card images, derived from 40 existing posts.

## Dimensions and Format

- **Size**: 1200x630 px (Open Graph / social card standard)
- **Format**: PNG preferred (34 of 40 posts use PNG)
- **HiDPI**: Some posts use 2400x1260 (2x) — same aspect ratio, sharper on retina

The 1200x630 ratio (~1.9:1) is the current standard for all post types from 2024 onward.
Earlier posts used inconsistent sizes — don't follow those as examples.

## Quarto Brand Colors

Sourced from the website CSS (`index.css`):

| Color | Hex | Usage |
|-------|-----|-------|
| Hero light blue | `#F0F5F9` | Light background for thumbnails and hero sections |
| Quarto blue | `#5286AB` | Primary brand blue — icons, elements, accents |
| Hero heading blue | `#39729E` | Darker blue for headings in light mode |
| Steel blue | `#4D6E8E` | Release post backgrounds (legacy convention) |

**Contrast guideline**: Light backgrounds (`#F0F5F9`) with Quarto blue (`#5286AB`)
elements provide better contrast than colored backgrounds with white elements,
especially for icon compositions where the icon has its own color palette.

## Visual Style by Post Type

### Release posts

All use the same template:

- Steel blue solid background (~#4d6e8e)
- Centered Quarto logo (circle-crosshair) + wordmark in white
- Large bold version number in white (e.g., "1.9")
- One small thematic emoji-style illustration (unique per release)

The only creative variable is the illustration — background, typography, logo placement,
and layout are identical across 1.4 through 1.9. Release thumbnails that use emoji
illustrations include an OpenMoji attribution at the end of the post.

### Feature and how-to posts

Two palettes available:

- **Light background** (preferred for icon compositions): `#F0F5F9` background with
  Quarto blue (`#5286AB`) icons and elements. Use when the design includes third-party
  logos/icons with their own colors — avoids contrast problems.
- **Steel blue background** (legacy): `#4D6E8E` background with white icons. Works
  for simple compositions but can have contrast issues with blue-toned icons.

Content patterns:

- **Icon compositions**: Outline icons arranged with arrows or connectors showing
  a concept (e.g., Chromium → terminal + Quarto for chrome-headless-shell post)
- **Diagrams/explainers**: Simple visual showing the concept (e.g., notebook → reports
  with arrow for parameterized reports post)
- **Screenshots**: Cropped screenshot of the feature output (older convention, less common now)

### Conference and workshop posts

Use Posit conference brand templates rather than the Quarto steel blue:

- Dark navy or teal backgrounds with 3D isometric block illustrations
- Conference logo placement (posit::conf branding)
- Speaker/instructor names in white text

### Partner/integration posts

Use the partner's own logo on a white or neutral background (e.g., Hugging Face logo,
Confluence logo). No Quarto branding needed — the partner identity is the visual.

## Creating Thumbnails

### Prerequisites

The screenshot step needs a headless browser. If `agent-browser` is installed
(`npm i -g agent-browser`), use the examples below. If not, any tool that can
screenshot an HTML page at a fixed viewport works — Playwright, Puppeteer, or
even opening the HTML in Chrome DevTools at a locked viewport and saving manually.

If no headless tool is available, create the SVG and ask someone with the tooling
to generate the PNG, or open the HTML in a browser and use the OS screenshot tool
at the right dimensions.

### HTML/CSS + screenshot approach (recommended)

Create an HTML file sized to 1200x630 with the design, then screenshot it:

1. **Source SVG icons** — good free sources:
   - [svgrepo.com](https://www.svgrepo.com) — many Public Domain (PD) icons, no attribution needed
   - [icon-icons.com](https://icon-icons.com) — CC BY 4.0 icons, attribution required
2. **Build an HTML file** — set `body` to 1200x630, embed SVG icons inline, use
   flexbox for layout. Choose background color based on post type (see above).
3. **Serve and screenshot** — serve the HTML locally and screenshot at 1200x630.
   Use any local HTTP server + headless browser screenshot tool. Examples:

   With `agent-browser` + a local server:
   ```bash
   # Serve with any static server (python, npx serve, simple-http-server, etc.)
   python -m http.server 8181 -d path/to/post/dir &
   agent-browser batch "set viewport 1200 630" \
     "open http://127.0.0.1:8181/thumbnail.html" \
     "screenshot path/to/thumbnail.png"
   agent-browser close
   ```

   With `file://` protocol (no server needed, requires `--allow-file-access`):
   ```bash
   agent-browser close  # Ensure clean daemon start
   agent-browser --allow-file-access batch "set viewport 1200 630" \
     "open file:///absolute/path/to/thumbnail.html" \
     "screenshot path/to/thumbnail.png"
   agent-browser close
   ```
4. **Save SVG source** — save a standalone `thumbnail.svg` in the post directory
   alongside the PNG. This makes future edits easy (color changes, element swaps)
   without recreating from scratch.
5. **Clean up** — delete the HTML source after confirming the PNG looks correct.
   Keep the SVG for future reference.

**Always use PNG as the thumbnail (`image: thumbnail.png`), never SVG.** Standalone
SVGs don't center properly in Quarto listing cards or social card previews — the
HTML uses flexbox for centering which SVG can't replicate without duplicating all
the layout logic. The SVG is only a source file for regenerating the PNG.

The Quarto logo SVG is at the repo root: `quarto-icon.svg` (fill color `#74AADB`
— recolor to `#5286AB` for thumbnails or `white` for dark backgrounds).

### Attribution

When using third-party icons, add an attribution line at the very end of the post
(after the last content section). Match the format used in existing posts:

```markdown
The [icon description] in the [listing and social card image](thumbnail.png) for this
post is by [Author](url){.external} via [source](url){.external}.
License: [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/){.external}
```

Public Domain icons (e.g., from svgrepo.com PD collection) need no attribution.
