# Sub-plan 12: Navigation Page Screenshots

Parent: [00-index.md](00-index.md)
Doc page: `docs/websites/website-navigation.qmd`

## Context

The website-navigation.qmd page has 11 image references (12 counting navbar-tools dark variant). Only 2 are in the manifest (navbar-tools, sidebar-tools). This plan adds all navigation screenshots to the tooling for full reproducibility and dark mode support.

## Screenshot Inventory

| # | Image | Section | In manifest | Dark? | Needs update? | Source strategy |
|---|-------|---------|-------------|-------|---------------|-----------------|
| 1 | `nav-bar.png` | Top Navigation | No | No → Yes | New capture | `examples/navbar-basic` |
| 2-3 | `navbar-tools.png` + dark | Navbar Tools | **Yes** | **Yes** | Done (PR #1815) | `examples/navbar-tools` |
| 4 | `nav-side-anchored.png` | Side Navigation | No | No → Yes | New capture | `examples/sidebar-demo` profile=docked |
| 5 | `nav-side-floating.png` | Side Navigation | No | No → Yes | New capture | `examples/sidebar-demo` profile=floating |
| 6 | `tools.png` + dark | Sidebar Tools | **Yes** | Needs wiring | .include-dark + alt text | `examples/sidebar-tools` |
| 7 | `nav-bar-hybrid.png` | Hybrid Navigation | No | No → Yes | New capture | `examples/hybrid-nav` |
| 8 | `nav-bar-hybrid-sidebar.png` | Hybrid Navigation | No | No → Yes | New capture | `examples/hybrid-nav` page=tutorials.html |
| 9 | `nav-bar-hybrid-dropdown.png` | Hybrid Navigation | No | No → Yes | New capture | `examples/hybrid-nav` profile=dropdown |
| 10 | `nav-breadcrumbs.png` | Breadcrumbs | No | No → Yes | New capture | `examples/sidebar-demo` profile=breadcrumbs |
| 11 | `reader-mode.png` | Reader Mode | No | No → Yes | New capture | `examples/navbar-basic` profile=reader-mode |
| 12 | `repo-actions.png` | GitHub Links | No | No → Yes | New capture + highlight | `examples/sidebar-demo` profile=repo-actions |

### quarto-demo consideration

The quarto-demo repo (https://github.com/quarto-dev/quarto-demo, live at https://quarto-dev.github.io/quarto-demo/) has docked sidebar + `repo-actions: [edit]` + cosmo theme. capture.js already supports `source.type: "url"`.

**Decided against URL source** for reproducibility:
- quarto-demo only has `repo-actions: [edit]`, but screenshot needs `[edit, source, issue]`
- Can't change sidebar style for floating variant
- No breadcrumbs, no reader-mode, no navbar
- External dependency — content could change

quarto-demo serves as a reference for what the screenshots should look like, not a capture source.

## Example Projects

### 1. `examples/navbar-basic/` (NEW)

Simple top navbar site. 3 pages, 2 profiles.

**Pages:**
- `index.qmd` — Home (minimal content)
- `talks.qmd` — Talks
- `about.qmd` — About

**`_quarto.yml` (base):**
```yaml
project:
  type: website
website:
  title: "My Site"
  navbar:
    background: primary
    search: true
    left:
      - text: "Home"
        href: index.qmd
      - talks.qmd
      - about.qmd
format:
  html:
    theme: cosmo
```

**`_quarto-reader-mode.yml` (profile):**
```yaml
website:
  reader-mode: true
```

**Screenshots served by this project:**
- `nav-bar.png` — default profile, captures navbar
- `reader-mode.png` — reader-mode profile, captures navbar with toggle icon

### 2. `examples/sidebar-demo/` (NEW)

Sidebar navigation site with sections. Enough depth for breadcrumbs. 4 profiles.

**Pages:**
- `index.qmd` — Getting Started
- `getting-started.qmd` — additional getting started content
- `tutorials.qmd` — Tutorials landing
- `tutorial-landing.qmd` — nested page (for breadcrumbs)
- `advanced.qmd` — Advanced section
- `raw-code.qmd` — Advanced sub-page

Content modeled on quarto-demo structure. Fictional content — focus is on navigation chrome.

**`_quarto.yml` (base, no sidebar — profiles add it):**
```yaml
project:
  type: website
website:
  title: "Quarto Demo"
format:
  html:
    theme: cosmo
    toc: true
```

**`_quarto-docked.yml`:**
```yaml
website:
  sidebar:
    style: "docked"
    search: true
    contents:
      - section: "Basics"
        contents:
          - index.qmd
          - getting-started.qmd
      - section: "Tutorials"
        contents:
          - tutorials.qmd
          - tutorial-landing.qmd
      - section: "Advanced"
        contents:
          - advanced.qmd
          - raw-code.qmd
```

**`_quarto-floating.yml`:** Same sidebar structure, `style: "floating"`.

**`_quarto-breadcrumbs.yml`:** Same as docked + breadcrumbs are on by default for nested pages. The capture navigates to `tutorial-landing.html` where breadcrumbs appear naturally (nested under Tutorials section).

**`_quarto-repo-actions.yml`:**
```yaml
website:
  sidebar: [same as docked]
  repo-url: https://github.com/quarto-dev/quarto-demo
  repo-actions: [edit, source, issue]
```

**Screenshots served by this project:**
- `nav-side-anchored.png` — profile=docked, full page view
- `nav-side-floating.png` — profile=floating, full page view
- `nav-breadcrumbs.png` — profile=breadcrumbs, page=tutorial-landing.html, clip to breadcrumb area
- `repo-actions.png` — profile=repo-actions, clip to TOC area + highlight

### 3. `examples/hybrid-nav/` (NEW)

"ProjectX" site with hybrid navbar + sidebar. Multiple pages. 2 profiles.

**Pages:**
- `index.qmd` — Home
- `tutorials.qmd` — Tutorials landing
- `tutorial1.qmd` — Tutorial 1
- `tutorial2.qmd` — Tutorial 2
- `howto.qmd` — How-To landing
- `fundamentals.qmd` — Fundamentals landing
- `reference.qmd` — Reference landing

**`_quarto.yml` (flat hybrid — navbar links to sections, clicking shows sidebar):**
```yaml
project:
  type: website
website:
  title: "ProjectX"
  navbar:
    background: primary
    search: true
    left:
      - text: "Home"
        href: index.qmd
      - text: "Tutorials"
        href: tutorials.qmd
      - text: "How-To"
        href: howto.qmd
      - text: "Fundamentals"
        href: fundamentals.qmd
      - text: "Reference"
        href: reference.qmd
  sidebar:
    - title: "Tutorials"
      style: "docked"
      background: light
      contents:
        - tutorials.qmd
        - tutorial1.qmd
        - tutorial2.qmd
    - title: "How-To"
      contents:
        - howto.qmd
    - title: "Fundamentals"
      contents:
        - fundamentals.qmd
    - title: "Reference"
      contents:
        - reference.qmd
format:
  html:
    theme: cosmo
```

**`_quarto-dropdown.yml` (dropdown hybrid — navbar items reference sidebars by id):**
```yaml
website:
  navbar:
    left:
      - text: "Home"
        href: index.qmd
      - sidebar:tutorials
      - sidebar:howto
      - sidebar:fundamentals
      - sidebar:reference
  sidebar:
    - id: tutorials
      title: "Tutorials"
      style: "docked"
      background: light
      contents:
        - tutorials.qmd
        - tutorial1.qmd
        - tutorial2.qmd
    - id: howto
      title: "How-To"
      contents:
        - howto.qmd
    - id: fundamentals
      title: "Fundamentals"
      contents:
        - fundamentals.qmd
    - id: reference
      title: "Reference"
      contents:
        - reference.qmd
```

**Screenshots served by this project:**
- `nav-bar-hybrid.png` — default profile, page=index.html, clip navbar
- `nav-bar-hybrid-sidebar.png` — default profile, page=tutorials.html, full page view
- `nav-bar-hybrid-dropdown.png` — dropdown profile, page=index.html, clip navbar

## New Tooling Feature: Highlight

For `repo-actions.png`, Chris's idea: add a colored border around the repo-actions element to draw viewer attention while showing broader page context.

**Implementation: cleanup eval** (no new feature needed — use existing mechanism):
```json
"cleanup": [
  { "action": "eval", "script": "const el = document.querySelector('.quarto-other-links-target-group'); if (el) { el.style.outline = '3px solid #0d6efd'; el.style.outlineOffset = '6px'; el.style.borderRadius = '4px'; }" }
]
```

Alternative: softer box-shadow approach:
```json
{ "action": "eval", "script": "const el = document.querySelector('.quarto-other-links-target-group'); if (el) { el.style.boxShadow = '0 0 0 3px rgba(13, 110, 253, 0.4)'; el.style.borderRadius = '4px'; }" }
```

The right selector and style will be determined during interactive `/screenshot` exploration. If this pattern proves useful, we could formalize it as a `capture.highlight` manifest option in the future.

**Note:** Need to verify the correct CSS selector for the repo-actions container via playwright-cli/Chrome DevTools when example is built.

## Proposed Manifest Entries

9 new entries (2 existing already cover navbar-tools and sidebar-tools):

### nav-bar (NEW)
```json
{
  "name": "nav-bar",
  "output": "docs/websites/images/nav-bar.png",
  "dark": true,
  "source": { "type": "example", "project": "examples/navbar-basic", "page": "index.html" },
  "capture": {
    "viewport": { "width": 1440, "height": 400 },
    "clip": [".navbar"]
  },
  "doc": {
    "file": "docs/websites/website-navigation.qmd",
    "alt": "A navigation bar. The title 'My Site' is on the left. To the right of the title are the words 'Home', 'Talks', and 'About'. 'Home' is slightly lighter than the other two words. On the far right side of the navigation bar is a search box."
  }
}
```

### nav-side-anchored (NEW)
```json
{
  "name": "nav-side-anchored",
  "output": "docs/websites/images/nav-side-anchored.png",
  "dark": true,
  "source": { "type": "example", "project": "examples/sidebar-demo", "page": "index.html", "profile": "docked" },
  "capture": {
    "viewport": { "width": 1200, "height": 800 }
  },
  "doc": {
    "file": "docs/websites/website-navigation.qmd",
    "alt": "A screenshot of a Quarto document where the sidebar is colored gray."
  }
}
```

### nav-side-floating (NEW)
```json
{
  "name": "nav-side-floating",
  "output": "docs/websites/images/nav-side-floating.png",
  "dark": true,
  "source": { "type": "example", "project": "examples/sidebar-demo", "page": "index.html", "profile": "floating" },
  "capture": {
    "viewport": { "width": 1200, "height": 800 }
  },
  "doc": {
    "file": "docs/websites/website-navigation.qmd",
    "alt": "A screenshot of a Quarto document where the sidebar has a white background and is closer to the body text."
  }
}
```

### nav-bar-hybrid (NEW)
```json
{
  "name": "nav-bar-hybrid",
  "output": "docs/websites/images/nav-bar-hybrid.png",
  "dark": true,
  "source": { "type": "example", "project": "examples/hybrid-nav", "page": "index.html" },
  "capture": {
    "viewport": { "width": 1440, "height": 400 },
    "clip": [".navbar"]
  },
  "doc": {
    "file": "docs/websites/website-navigation.qmd",
    "alt": "A navigation bar titled 'ProjectX' on the left. To the right of the title are the menu items 'Home', 'Tutorials', 'How-To', 'Fundamentals', and 'Reference'. There is a search bar on the far right side of the navigation bar."
  }
}
```

### nav-bar-hybrid-sidebar (NEW)
```json
{
  "name": "nav-bar-hybrid-sidebar",
  "output": "docs/websites/images/nav-bar-hybrid-sidebar.png",
  "dark": true,
  "source": { "type": "example", "project": "examples/hybrid-nav", "page": "tutorials.html" },
  "capture": {
    "viewport": { "width": 1200, "height": 800 }
  },
  "doc": {
    "file": "docs/websites/website-navigation.qmd",
    "alt": "A navigation bar titled 'ProjectX' on the left. To the right of the title are the menu items 'Home', 'Tutorials', 'How-To', 'Fundamentals', and 'Reference'. There is a search bar on the far right side of the navigation bar. The contents of the 'Tutorials' page is shown, with the sidebar showing the items 'Tutorials', 'Tutorial 1', and 'Tutorial 2'."
  }
}
```

### nav-bar-hybrid-dropdown (NEW)
```json
{
  "name": "nav-bar-hybrid-dropdown",
  "output": "docs/websites/images/nav-bar-hybrid-dropdown.png",
  "dark": true,
  "source": { "type": "example", "project": "examples/hybrid-nav", "page": "index.html", "profile": "dropdown" },
  "capture": {
    "viewport": { "width": 1440, "height": 400 },
    "clip": [".navbar"]
  },
  "doc": {
    "file": "docs/websites/website-navigation.qmd",
    "alt": "A navigation bar titled 'ProjectX' on the left. To the right of the title are the menu items 'Home', 'Tutorials', 'How-To', 'Fundamentals', and 'Reference'. 'Home' is in a lighter color than the other menu options. The other menu options have a triangle pointing down next to each one, indicating the existence of a drop-down menu. There is a search bar on the far right side of the navigation bar."
  }
}
```

### nav-breadcrumbs (NEW)
```json
{
  "name": "nav-breadcrumbs",
  "output": "docs/websites/images/nav-breadcrumbs.png",
  "dark": true,
  "source": { "type": "example", "project": "examples/sidebar-demo", "page": "tutorial-landing.html", "profile": "breadcrumbs" },
  "capture": {
    "viewport": { "width": 1200, "height": 400 },
    "clip": [".breadcrumb", "#title-block-header"]
  },
  "doc": {
    "file": "docs/websites/website-navigation.qmd",
    "alt": "Screenshot of a webpage. Above the header 'Tutorials' is the linked text 'Tutorials > Tutorial Landing'."
  }
}
```

### reader-mode (NEW)
```json
{
  "name": "reader-mode",
  "output": "docs/websites/images/reader-mode.png",
  "dark": true,
  "source": { "type": "example", "project": "examples/navbar-basic", "page": "index.html", "profile": "reader-mode" },
  "capture": {
    "viewport": { "width": 1440, "height": 400 },
    "clip": [".navbar"]
  },
  "doc": {
    "file": "docs/websites/website-navigation.qmd",
    "alt": "Reader mode toggle appearing the top navigation."
  }
}
```

### repo-actions (NEW)
```json
{
  "name": "repo-actions",
  "output": "docs/websites/images/repo-actions.png",
  "dark": true,
  "source": { "type": "example", "project": "examples/sidebar-demo", "page": "index.html", "profile": "repo-actions" },
  "capture": {
    "viewport": { "width": 1200, "height": 800 },
    "clip": [".sidebar-toc-item", ".quarto-other-links-target-group"],
    "cleanup": [
      { "action": "eval", "script": "const el = document.querySelector('.quarto-other-links-target-group'); if (el) { el.style.outline = '3px solid #0d6efd'; el.style.outlineOffset = '6px'; el.style.borderRadius = '4px'; }" }
    ]
  },
  "doc": {
    "file": "docs/websites/website-navigation.qmd",
    "alt": "A screenshot of a Quarto document. Underneath the page table of contents on the right side are three options: 'Edit this page', 'View source' and 'Report an issue'. There is a GitHub icon to the left of 'Edit this Page.'"
  }
}
```

**Notes on all manifest entries above:**
- Viewport sizes, clip selectors, and cleanup evals are initial proposals — will be refined during interactive `/screenshot` exploration with playwright-cli
- `dark: true` on all entries to generate `-dark` variants
- Alt text preserved from existing QMD where available

## .qmd Changes Needed

### `docs/websites/website-navigation.qmd`

Add `.include-dark` class to all 9 image references that get dark variants. Update alt text where needed.

| Line | Image | Change |
|------|-------|--------|
| ~37 | `nav-bar.png` | Add `.include-dark` |
| ~112 | `navbar-tools.png` | Already has `.include-dark` |
| ~158 | `nav-side-anchored.png` | Add `.include-dark` |
| ~158 | `nav-side-floating.png` | Add `.include-dark`, fix `fit-alt` → `fig-alt` |
| ~276 | `tools.png` | Add `.include-dark`, update alt text (Twitter → Bluesky), fix `fit-alt` → `fig-alt` |
| ~285 | `nav-bar-hybrid.png` | Add `.include-dark` |
| ~289 | `nav-bar-hybrid-sidebar.png` | Add `.include-dark` |
| ~345 | `nav-bar-hybrid-dropdown.png` | Add `.include-dark` |
| ~404 | `nav-breadcrumbs.png` | Add `.include-dark` |
| ~476 | `reader-mode.png` | Add `.include-dark` |
| ~514 | `repo-actions.png` | Add `.include-dark` |

**Note:** Two images use `fit-alt` instead of `fig-alt` — this appears to be an accessibility bug. The `fit-alt` attribute doesn't generate a proper `alt` attribute in the rendered HTML (it becomes `data-fit-alt`). Should be `fig-alt`.

## Implementation Phases

### Phase 1: PR #1815 completion (sidebar-tools)

What: Wire `.include-dark` + fix alt text for `tools.png` in `website-navigation.qmd`. Commit and cherry-pick navbar-tools/sidebar-tools dark images to twitter-to-bluesky branch.

Also needed on twitter-to-bluesky: `.include-dark` + alt text for myblog in `website-blog.qmd` and 4 remaining about templates in `website-about.qmd`.

### Phase 2: Build example projects

Create 3 new example projects:
1. `examples/navbar-basic/` — 3 pages, 2 profiles (default, reader-mode)
2. `examples/sidebar-demo/` — 6 pages, 4 profiles (docked, floating, breadcrumbs, repo-actions)
3. `examples/hybrid-nav/` — 7 pages, 2 profiles (default, dropdown)

Each project gets rendered and visually validated before moving to Phase 3.

### Phase 3: Interactive capture design

Use `/screenshot` with `playwright-cli --headed` to refine each manifest entry:
- Determine exact clip selectors (element selectors above are proposals)
- Test viewport sizes
- Design highlight approach for repo-actions
- Test zoom/trim/crop needs
- Validate dark mode captures

Work through screenshots in groups by example project.

### Phase 4: Add manifest entries

Add all 9 new entries to `manifest.json`. Run `npm run capture` to generate all images.

### Phase 5: .qmd changes

Add `.include-dark` to all 9 non-dark images. Fix `fit-alt` → `fig-alt` where found. Update tools.png alt text (Twitter → Bluesky). These changes go on the twitter-to-bluesky branch.

### Phase 6: Commit and verify

Commit tooling changes on worktree-screenshot-tool. Cherry-pick images + .qmd changes to twitter-to-bluesky. Verify deploy preview.

## Open Questions

1. **Breadcrumbs capture approach**: Current image has `.border` class and `width=50%` in QMD. Should the captured image be narrow (just breadcrumb + title area) or full-width? The clip selectors for breadcrumbs need exploration — may need to use `computeClip` union of breadcrumb element + title block.

2. **Side navigation screenshots**: These are shown side-by-side in a table in the QMD (`::: column-screen-inset-shaded`). The current images appear to be full-page screenshots. Should we keep them full-page or clip to the sidebar area? Full-page is more useful for comparing styles.

3. **Dark mode for table layout**: The side navigation images appear in a side-by-side table. With `.include-dark`, both images swap to dark variants independently. Does the table layout work with dark mode? May need testing.

4. **Highlight color**: Blue outline (#0d6efd, Bootstrap primary) matches the cosmo theme. But should it be more subtle (dashed? lighter?) or more prominent? To be determined during interactive design.

5. **Profile rendering cost**: 8 profiles across 3 projects = 8 `quarto render` calls + potentially 8 more for dark variants. Each render is fast for small projects but adds up. Consider grouping captures by project to minimize renders.

## Estimated Effort

- Phase 1: Small — .qmd edits only, images already exist
- Phase 2: Medium — create 3 example projects (~16 pages total, 8 profile configs)
- Phase 3: Medium-large — interactive exploration for 9 screenshots
- Phase 4: Small — add manifest entries (mostly from Phase 3 findings)
- Phase 5: Small — .qmd edits
- Phase 6: Small — commit/cherry-pick

Total: ~3-4 sessions of work across Phases 2-4.
