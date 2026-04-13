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

When you can't create the thumbnail yourself (e.g., no image generation tool available),
note clearly what's needed and describe the intended design. The design should match the
post type conventions above.

For feature posts, a good default is: steel blue background + 2-3 white outline icons
that represent the feature's concepts, at 1200x630 px.
