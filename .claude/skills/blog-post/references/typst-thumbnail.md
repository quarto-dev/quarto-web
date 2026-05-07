# Typst Thumbnail Path

How to create a blog post thumbnail with [Typst](https://typst.app), using the
templates and assets bundled in this skill.

The Typst path is good for **text-only** thumbnails (release-style title cards
without emoji) and for **programmatic diagrams** (trees, flows, simple graphs).
For thumbnails that compose third-party logos or icons, use the HTML+SVG path
(see `thumbnail-guide.md`).

## When to use Typst vs HTML+SVG

See the `Choosing your path` table at the top of `thumbnail-guide.md`. In short:

- Diagram explains the concept of the post → Typst with cetz
- Plain title + version card → Typst (text-only template)
- Composition of third-party logos/icons → HTML+SVG
- Release post that matches the established template (logo + version + emoji) → HTML+SVG

## Prerequisites

Quarto bundles a Typst CLI. No separate install is needed.

```powershell
quarto typst --version
```

Before rendering, check what fonts are available so you understand any
substitution that may happen:

```powershell
quarto typst fonts | Select-String -Pattern "Helvetica|Arial"
```

The most common silent failure is font substitution — the render succeeds but
the visual differs from what you expected because the system fell back to a
different font.

## Setup

Copy the template and the logo SVG from the skill's `assets/` directory into
your post directory. Both files must live alongside `thumbnail.typ` because the
template uses a co-located filename for the logo.

```powershell
$skill = ".claude/skills/blog-post/assets"
$post  = "docs/blog/posts/YYYY-MM-DD-slug"
Copy-Item "$skill/thumbnail-diagram.typ" "$post/thumbnail.typ"   # or thumbnail-text.typ
Copy-Item "$skill/quarto-logo-trademark-light.svg" $post         # white-fill, for #447099 / dark backgrounds
```

Two wordmark variants are bundled:

| File | Use on |
|------|--------|
| `quarto-logo-trademark-light.svg` | Dark backgrounds (`#447099` blue, `#4D6E8E` steel) — default for the bundled templates |
| `quarto-logo-trademark.svg` | Light backgrounds (`#F0F5F9`) — swap in if you adapt a template to the light palette |

Both derive from the same brand-kit source; the only difference is `fill`.

When the post is ready, commit all three artifacts together:

- `thumbnail.typ` — the source
- `thumbnail.png` — the rendered output (referenced by frontmatter `image:`)
- `quarto-logo-trademark-light.svg` — the bundled wordmark

This keeps the post self-contained: anyone with `quarto typst` can re-render
the thumbnail on a fresh checkout.

## Page setup

Both bundled templates use:

- Page size: `1200pt` × `630pt` (Open Graph / social card standard)
- Margin: `50pt`
- Background fill: `rgb("#447099")` — Quarto release-thumbnail blue

Quarto brand palette (mirror of `thumbnail-guide.md`):

| Hex | Use |
|-----|-----|
| `#447099` | Page background (release thumbnails) |
| `#5286AB` | Quarto blue — accents on light backgrounds |
| `#39729E` | Hero heading blue |
| `#4D6E8E` | Steel blue — alternate background |
| `#F0F5F9` | Hero light blue — alternate background |
| `#1f3a52` | Dark text on white-filled cetz nodes |

## Font fallback chain

Both templates use:

```typst
font: ("Helvetica Neue", "Helvetica", "Arial", "Liberation Sans", "DejaVu Sans")
```

Helvetica Neue is preferred (matches existing release thumbnails) but is not
present on Linux contributors' machines by default. The chain ensures a clean
sans-serif substitution rather than a warning.

## Cetz pin

The diagram template pins cetz to `0.3.4`:

```typst
#import "@preview/cetz:0.3.4"
```

Cetz is pre-1.0 and its API is still evolving. Pinning a specific version means
the template renders the same on every contributor's machine and survives
upstream cetz releases unchanged. Bump the pin only when you intentionally
adopt a new cetz feature and re-test all bundled templates.

## Title injection

Templates contain literal placeholder strings. Edit them directly:

```diff
- #text(size: 56pt, weight: "bold")[Replace this title]
+ #text(size: 56pt, weight: "bold")[Parsing & Source Maps]
```

No `--input` / `sys.inputs` indirection — literal edit keeps the template
readable and the source file is the canonical record of what the rendered PNG
shows.

## Diagram scaffold pattern (cetz)

The diagram template ships with two helpers preloaded inside `cetz.canvas`:

```typst
let node(pos, label, name) = { ... }   // ellipse, white fill
let edge(a, b) = { ... }               // straight white line between named nodes
```

### Snippet 1 — three-node tree

```typst
node((4, 2), "Doc",    "doc")
node((1, 0), "Header", "header")
node((7, 0), "Str",    "str")
edge("doc", "header")
edge("doc", "str")
```

Position uses cetz coordinate units; `length: 45pt` on `cetz.canvas` scales
units to layout points. Adjust coordinates to spread nodes out.

### Snippet 2 — rectangle nodes with custom colors

When ellipses are wrong (e.g., long labels, technical diagrams), define a
second helper that draws rectangles:

```typst
let box(pos, label, name) = {
  let (x, y) = pos
  rect(
    (x - 1.6, y - 0.5),
    (x + 1.6, y + 0.5),
    fill: rgb("#F0F5F9"),
    stroke: white,
    name: name,
  )
  content((x, y), text(fill: rgb("#1f3a52"), weight: "bold", size: 20pt)[#label])
}

box((0, 0), "input.qmd",   "src")
box((6, 0), "rendered.html", "out")
```

### Snippet 3 — directed edge with arrowhead

Replace `edge` with a variant that draws an arrowhead:

```typst
let arrow(a, b) = {
  line(a, b, mark: (end: ">"), stroke: (paint: white, thickness: 1.5pt))
}

arrow("src", "out")
```

For a label on the edge, place a `content()` at the midpoint:

```typst
content(((src.x + out.x) / 2, (src.y + out.y) / 2 + 0.4),
        text(fill: white, size: 16pt)[render])
```

For richer cetz patterns (anchors, transformations, plot integration) consult
the cetz manual at <https://typst.app/universe/package/cetz/>.

## Render command

Run from the post directory:

```powershell
cd docs/blog/posts/YYYY-MM-DD-slug
quarto typst compile thumbnail.typ thumbnail.png -f png --ppi 144
```

`--ppi 144` produces a 2400×1260 PNG (twice the 1200×630 base) — the HiDPI/2x
retina convention noted in `thumbnail-guide.md`.

## Anti-patterns

- **Don't use `--input` / `sys.inputs`** for the title. Literal-edit is simpler
  and keeps the template grep-able.
- **Don't unpin cetz.** A floating import will eventually break templates and
  re-renders won't be reproducible.
- **Don't omit the font fallback chain.** A bare `Helvetica Neue` produces a
  warning and falls back to Typst's default, which may not be what you want.
- **Don't ship a `.typ` without rendering.** The PNG is the artifact Quarto
  serves; the source is for revision. Both must exist and stay in sync.
- **Don't omit the logo SVG copy.** The template references
  `quarto-logo-trademark-light.svg` as a co-located file. Without it, render
  fails on a fresh checkout (this is exactly what happened to the original
  `2026-05-05-quarto-2-parsing/thumbnail.typ`).

## Optional global helpers

Two third-party Claude skills cover Typst and cetz in depth and may help when
you want general Typst guidance beyond the thumbnail templates:

- [`lucifer1004/claude-skill-typst`](https://github.com/lucifer1004/claude-skill-typst)
  — general Typst authoring, debug verification, package search
- [`edoardob90/typst-cetz-skills`](https://github.com/edoardob90/typst-cetz-skills)
  — cetz API reference (canvas, primitives, anchors, transforms)

These are optional. The bundled templates and this guide are sufficient to ship
a thumbnail without them.
