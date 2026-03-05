# Sub-plan: Example Quarto Projects

Parent: `glistening-beaming-thunder.md` | Task #3

## Overview

Minimal Quarto projects in `tools/screenshots/examples/` that produce the pages being screenshotted. Each project is the absolute minimum to render its screenshot — no extra content, but should look good and realistic.

## Projects

### examples/navbar-tools/

Purpose: Screenshot of navbar with Bluesky + GitHub tools (including dropdown)

```
navbar-tools/
├── _quarto.yml
└── index.qmd
```

**`_quarto.yml`:**
```yaml
project:
  type: website

website:
  title: "ProjectX"
  navbar:
    tools:
      - icon: bluesky
        href: https://bsky.app
      - icon: github
        menu:
          - text: Source Code
            href: https://code.com
          - text: Report a Bug
            href: https://bugs.com
```

**`index.qmd`:** Minimal content (heading + paragraph) so the page looks realistic.

### examples/sidebar-tools/

Purpose: Screenshot of sidebar with Bluesky + GitHub tools (including dropdown)

```
sidebar-tools/
├── _quarto.yml
├── index.qmd
└── page2.qmd
```

**`_quarto.yml`:**
```yaml
project:
  type: website

website:
  sidebar:
    title: "ProjectX"
    tools:
      - icon: bluesky
        href: https://bsky.app
      - icon: github
        menu:
          - text: Source Code
            href: https://code.com
          - text: Report a Bug
            href: https://bugs.com
    contents:
      - index.qmd
      - page2.qmd
```

Need at least 2 pages for sidebar navigation to render properly.

### examples/about-pages/

Purpose: Screenshots of all 5 about page templates

```
about-pages/
├── _quarto.yml
├── profile.jpg      ← realistic avatar image
├── jolla.qmd
├── trestles.qmd
├── solana.qmd
├── marquee.qmd
└── broadside.qmd
```

**`_quarto.yml`:** Minimal website project config.

**Each template .qmd** (e.g., `jolla.qmd`):
```yaml
---
title: "Finley Malloc"
image: profile.jpg
about:
  template: jolla
  links:
    - icon: bluesky
      text: Bluesky
      href: https://bsky.app
    - icon: github
      text: Github
      href: https://github.com
---

Finley Malloc is the Chief Data Scientist at Wengo Analytics...
(same content as current docs examples)

## Education
University of California, San Diego | San Diego, CA
PhD in Mathematics | Sept 2011 - June 2015

## Experience
Wengo Analytics | Head Data Scientist | April 2018 - present
```

**`profile.jpg`:** Need a realistic-looking avatar. Options:
- Use a placeholder image service
- Use a simple generated avatar
- Reuse the image from the existing screenshots (extract from current about-jolla.png or find the original)

### examples/myblog/

Purpose: Screenshot of blog homepage with Bluesky icon in navbar

```
myblog/
├── _quarto.yml
├── index.qmd
├── about.qmd
├── styles.css
└── posts/
    ├── _metadata.yml
    ├── welcome/
    │   └── index.qmd
    └── post-with-code/
        └── index.qmd
```

**`_quarto.yml`:**
```yaml
project:
  type: website

website:
  title: "myblog"
  navbar:
    right:
      - about.qmd
      - icon: github
        href: https://github.com
      - icon: bluesky
        href: https://bsky.app
  search: true

format:
  html:
    theme: cosmo
```

**`index.qmd`:** Blog listing page:
```yaml
---
title: "myblog"
listing:
  contents: posts
  sort: "date desc"
  type: default
  categories: true
---
```

**Posts:** 2 minimal example posts with different categories, dates, descriptions, and preview images so the listing looks realistic.

## Visual Consistency Rules

- All projects use default Quarto theme (cosmo) unless the screenshot needs a specific theme
- Light color scheme always
- Use "Finley Malloc" for about pages (matches existing screenshots)
- Use "myblog" as blog title (matches existing)
- Use "ProjectX" as generic site title for navbar/sidebar examples
- Keep content minimal but realistic — not lorem ipsum
- Include enough navigation items for the UI to look populated

## .gitignore

At `tools/screenshots/.gitignore`:
```
_site/
_freeze/
.quarto/
```

## profile.jpg

Need to source or create a profile image for the about pages. Check if the original image used in the existing screenshots can be found, otherwise use a simple placeholder.
