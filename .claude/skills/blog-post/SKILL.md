---
name: quarto-blog-post
description: Use when writing, drafting, or editing blog posts for quarto.org, creating Quarto feature or release announcements, or reviewing blog post drafts for the Quarto website.
---

# Quarto Blog Post

Write blog posts for `quarto.org/blog` matching the voice, structure, and conventions
from 40+ existing posts.

## Setup

1. `ls docs/blog/posts/` — browse existing posts for reference
2. Read `docs/blog/posts/_metadata.yml` — inherited by all posts (Giscus comments,
   title-block-banner, left TOC, signup widget, `search: false`)
3. If the post covers a Quarto feature, read the relevant docs page for accurate
   terminology and linking.

## File Structure

```
docs/blog/posts/YYYY-MM-DD-slug/
  index.qmd        # The post (required)
  thumbnail.png    # Listing card image (required)
  *.png, *.jpg     # Additional images
  _contribs.md     # Contributor list (release posts only)
```

Directory name: `YYYY-MM-DD-slug` — date matches frontmatter, slug is short kebab-case.

## Frontmatter

```yaml
---
title: "Post Title"
description: |
  One to three sentences for listing cards and social sharing.
author: Author Name
date: "YYYY-MM-DD"
categories:
  - Category1
  - Category2
image: thumbnail.png
image-alt: "Descriptive alt text for the thumbnail."
---
```

**title**: Short. Release posts: `"Quarto X.Y"`. Backtick code spans OK.

**description**: Self-contained summary (makes sense without the title). Always `|` block scalar.

**author**: Plain string for staff (`Charlotte Wickham`). Two authors: `Name and Name`.
Guest authors use structured form with `name:` and optional `url:`.

**date**: ISO 8601 `"YYYY-MM-DD"`. Must match directory name.

**categories**: 2-3 per post. Use existing values — scan recent posts to check. Common:
`Releases`, `Quarto X.Y`, `Features`, `Authoring`, `Learn`, `Workshop`, `Conference`,
`Tip`, `Extensions`, `Tables`, `Teaching`, `Jupyter`.

**image / image-alt**: `thumbnail.png` preferred. `image-alt` is mandatory.
See `references/thumbnail-guide.md` for dimensions, visual style, and design patterns.

**Optional**: `lightbox: true` (many screenshots), `draft: true` (while developing).
Do not use `subtitle:` (phased out after 2023).

## Post Types

Identify the type before writing — it determines structure, opening, and closing.
Read `references/post-types.md` for detailed structure guidance per type.

| Type | When | Key trait |
|------|------|-----------|
| **Release** | New Quarto version ships | Most structured: features → Other Highlights → Acknowledgements |
| **Feature** | Spotlight a specific capability | Concept-driven sections, docs links |
| **How-to** | Tutorial or walkthrough | Problem → solution, sequential steps |
| **News** | Short announcement, roundup | Very short, layout-heavy, minimal prose |

## Writing Voice

**First-person plural**: "We" for team work, "you" for the reader.

**Warm, not marketing**: "We're excited about this feature" — good.
"This groundbreaking capability" — bad. Collegial tone, sharing with practitioners.

**Direct openers**: Get to the point immediately. No "In this blog post, we will..."
preambles. State what happened or what the feature does, then elaborate.

**Technical accuracy**: Use exact terminology from the docs. Link to docs rather than
trying to replicate them — the post introduces, the docs page is the reference.

**Thank contributors**: Call out external contributors warmly inline.

## Technical Conventions

### Images

Every image must have `fig-alt=` text — non-negotiable accessibility standard.

```markdown
![](screenshot.png){fig-alt="Description of what the screenshot shows."}
```

Multi-image layouts use Quarto's layout system (`{layout-ncol="2"}`).
For many images, add `{.lightbox group="name"}`.

### Code Blocks

Always specify language. Use `filename=` labels for file content or terminal commands:

````markdown
```{.yaml filename="_quarto.yml"}
project:
  type: website
```
````

### Links

Every feature mentioned links to its docs page. Pattern: explain briefly, show example,
then link. Use site-root-relative paths: `[Feature](/docs/path.qmd)`.

### Callouts

Use sparingly: `.callout-tip` for post origin context, `.callout-warning` for caveats,
`.callout-note` for prerequisites. Release posts typically skip callouts.

### Shortcodes

- `{{< prerelease-callout X.Y type="blog" >}}` — pre-release banner (auto-disappears)
- `{{< video URL >}}` — video embed
- `{{< include file.md >}}` — include generated content

## Workflow

1. **Identify post type** → read `references/post-types.md` for that type
2. **Create directory**: `docs/blog/posts/YYYY-MM-DD-slug/`
3. **Write frontmatter** per schema above
4. **Draft body** following type-specific structure
5. **Add images** with `fig-alt=` on every one
6. **Link to docs** for every feature mentioned
7. **Create thumbnail** (or note one is needed)
8. **Review**: direct opener? code blocks fenced with language? all images alt-texted?
   docs links present? closing matches type convention? categories correct?

## Publishing

When ready to publish, set the post date to today and rename the directory:

```bash
quarto run _tools/publish-date.ts docs/blog/posts/YYYY-MM-DD-slug
```

This updates `date:` in frontmatter and renames the directory to match. Run it
on the day you intend to merge — avoids manual date edits if the publish date slips.

## PR Workflow

PR to `main` first. On merge, auto-backport creates cherry-pick PR to `prerelease`.
Push branches to `upstream` remote (quarto-dev/quarto-web), not `origin`.
