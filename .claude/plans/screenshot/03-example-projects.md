# Sub-plan: Example Quarto Projects

Parent: `glistening-beaming-thunder.md` | Task #3

## Overview

Minimal Quarto projects in `tools/screenshots/examples/` that produce the pages being screenshotted. Each project is the absolute minimum to render its screenshot — no extra content, but should look good and realistic.

All example projects use `theme: { light: cosmo, dark: darkly }` to support both light and dark screenshot variants.

## Projects

### examples/navbar-tools/

Purpose: Screenshot of navbar with Bluesky + GitHub tools (including dropdown)

```
navbar-tools/
├── _quarto.yml
├── .gitignore
└── index.qmd
```

**`_quarto.yml`:**
```yaml
project:
  type: website
  render:
    - index.qmd

format:
  html:
    theme:
      light: cosmo
      dark: darkly

website:
  title: "ProjectX"
  navbar:
    left:
      - text: Blog
        href: "#"
      - text: Help
        href: "#"
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

### examples/sidebar-tools/ (superseded by URL source)

The sidebar-tools screenshot now uses `source.type: "url"` pointing at https://quarto-dev.github.io/quarto-demo/ instead of this local example project. The quarto-demo site provides richer sidebar content (title, search, multiple sections with children) and supports dark mode (cosmo light / darkly dark).

The example project still exists on disk but is no longer the capture source. It may be removed in a future cleanup.

### examples/about-pages/

Purpose: Screenshots of all 5 about page templates using Quarto profiles.

```
about-pages/
├── _quarto.yml              ← base config (no template)
├── _quarto-jolla.yml        ← profile: sets template to jolla
├── _quarto-trestles.yml     ← profile: sets template to trestles
├── _quarto-solana.yml       ← profile: sets template to solana
├── _quarto-marquee.yml      ← profile: sets template to marquee
├── _quarto-broadside.yml    ← profile: sets template to broadside
├── about.qmd                ← shared content (no template in frontmatter)
├── profile.jpg              ← avatar image
└── .gitignore
```

**`_quarto.yml`:**
```yaml
project:
  type: website
  render:
    - about.qmd

website:
  title: "About Pages"

format:
  html:
    theme:
      light: cosmo
      dark: darkly
```

**Profile configs** (e.g., `_quarto-trestles.yml`):
```yaml
about:
  template: trestles
```

Each profile overrides only the template. The base `_quarto.yml` has no template default — projects are always rendered with an explicit `--profile`.

**`about.qmd`:**
```yaml
---
title: "Finley Malloc"
image: profile.jpg
about:
  links:
    - icon: bluesky
      text: Bluesky
      href: https://bsky.app
    - icon: github
      text: Github
      href: https://github.com
---

Finley Malloc is the Chief Data Scientist at Wengo Analytics...

## Education
University of California, San Diego | San Diego, CA
PhD in Mathematics | Sept 2011 - June 2015

Macalester College | St. Paul, MN
B.A in Economics | Sept 2007 - June 2011

## Experience
Wengo Analytics | Head Data Scientist | April 2018 - present

GeoScynce | Chief Analyst | Sept 2012 - April 2018
```

The `about` block in frontmatter has `links` but no `template` — the template comes exclusively from the profile config. This prevents page-level YAML from overriding the project-level profile setting.

**`profile.jpg`:** Reused from the existing about-pages example (originally sourced from the quarto-web docs).

### examples/myblog/

Purpose: Screenshot of blog homepage with Bluesky icon in navbar

```
myblog/
├── _quarto.yml
├── index.qmd
├── about.qmd
├── .gitignore
└── posts/
    ├── welcome/
    │   └── index.qmd
    └── first-post/
        └── index.qmd
```

**`_quarto.yml`:**
```yaml
project:
  type: website
  render:
    - index.qmd
    - about.qmd
    - posts/first-post/index.qmd
    - posts/welcome/index.qmd

format:
  html:
    theme:
      light: cosmo
      dark: darkly

website:
  title: "myblog"
  navbar:
    right:
      - about.qmd
      - icon: github
        href: https://github.com
      - icon: bluesky
        href: https://bsky.app
```

**`index.qmd`:** Blog listing page with `listing: { contents: posts, sort: "date desc", type: default, categories: true }`.

**Posts:** 2 minimal example posts ("Welcome To My Blog" and "Post With Code") with different categories and dates so the listing and category sidebar look populated.

## Visual Consistency Rules

- All projects use `theme: { light: cosmo, dark: darkly }` for light/dark screenshot support
- Use "Finley Malloc" for about pages (matches existing screenshots)
- Use "myblog" as blog title (matches existing)
- Use "ProjectX" as generic site title for navbar/sidebar examples
- Keep content minimal but realistic — not lorem ipsum
- Include enough navigation items for the UI to look populated

## .gitignore

Each example project has its own `.gitignore`:
```
/.quarto/
**/*.quarto_ipynb
```

## profile.jpg

Reused from the original about-pages example. The image was already present in the repo from earlier work.
