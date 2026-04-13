# Thumbnail Guide

Design conventions for blog post listing card images, derived from 40 existing posts.

## Dimensions and Format

- **Size**: 1200x630 px (Open Graph / social card standard)
- **Format**: PNG preferred (34 of 40 posts use PNG)
- **HiDPI**: Some posts use 2400x1260 (2x) — same aspect ratio, sharper on retina

The 1200x630 ratio (~1.9:1) is the current standard for all post types from 2024 onward.
Earlier posts used inconsistent sizes — don't follow those as examples.

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

Same steel blue palette as release posts. Content varies:

- **Icon compositions**: White outline icons arranged on the blue background
  (e.g., PDF accessibility post uses Quarto icon + PDF + accessibility + shield icons)
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

### HTML/CSS + screenshot approach (recommended)

Create an HTML file sized to 1200x630 with the design, then screenshot it:

1. **Source SVG icons** — good free sources:
   - [svgrepo.com](https://www.svgrepo.com) — many Public Domain (PD) icons, no attribution needed
   - [icon-icons.com](https://icon-icons.com) — CC BY 4.0 icons, attribution required
2. **Build an HTML file** — set `body` to 1200x630 with the steel blue background,
   embed SVG icons inline (recolor fills to white as needed), use flexbox for layout
3. **Screenshot at 1200x630** — use `agent-browser` with viewport set to 1200x630:
   ```bash
   agent-browser set viewport 1200 630
   agent-browser open file:///path/to/thumbnail.html
   agent-browser screenshot /path/to/thumbnail.png
   ```
4. **Clean up** — delete the HTML source, keep only the PNG

The Quarto logo SVG is at the repo root: `quarto-icon.svg`.

### Attribution

When using third-party icons, add an attribution line at the very end of the post
(after the last content section). Match the format used in existing posts:

```markdown
The [icon description] in the [listing and social card image](thumbnail.png) for this
post is by [Author](url){.external} via [source](url){.external}.
License: [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/){.external}
```

Public Domain icons (e.g., from svgrepo.com PD collection) need no attribution.
