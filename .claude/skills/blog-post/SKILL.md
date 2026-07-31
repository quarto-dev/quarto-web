---
name: quarto-blog-post
description: Use when writing, drafting, or editing Quarto blog posts, creating Quarto feature or release announcements, or reviewing Quarto blog post drafts. Quarto posts publish on the Posit Open Source blog (posit-dev/open-source-website), not on quarto.org.
---

# Quarto Blog Post

Write Quarto blog posts matching the voice, structure, and conventions of 40+
prior posts. Since May 2026 the Quarto blog lives on the
[Posit Open Source website](https://opensource.posit.co/blog/q/quarto/):
posts are authored and published in the
[`posit-dev/open-source-website`](https://github.com/posit-dev/open-source-website)
repo, not in quarto-web. This skill carries the Quarto-specific knowledge
(post types, voice, thumbnails); defer to that repo's own guides for its
mechanics.

## Setup

1. Locate a local clone of `posit-dev/open-source-website` — conventionally a
   sibling of this repo (`../open-source-website`). Clone it if missing.
   Check `git status` before branching.
2. Read, in its `content/blog/` directory:
   - `CLAUDE.md` — frontmatter schema and taxonomies
   - `_authoring-guide.md` — format choice, rendering, preview, and PR flow
3. Browse `content/blog/ported/quarto/` for prior Quarto posts. Recent ones
   (e.g. `2026-03-24-1.9-release/`) show the current frontmatter and structure
   conventions.
4. If the post covers a Quarto feature, read its docs from this repo — not
   from quarto.org — so drafting works even when the docs aren't live yet.
   Docs for an unreleased version live on the `prerelease` branch: check the
   working tree first, then `git fetch origin prerelease` and
   `git show origin/prerelease:docs/<path>`. quarto.org serves `main`, so
   anything prerelease-only won't be live until the release-time merge — see
   § Links for how to link to it anyway.

## File Structure

In the open-source-website clone, on a branch named `blog/<slug>`:

```
content/blog/<slug>/
  index.qmd        # Source (required)
  index.md         # Rendered output — always commit alongside the source
  thumbnail.png    # Hero + listing card image, 1920×1080 (required)
  *.png, *.jpg     # Additional images
```

The folder name is the URL slug: short kebab-case, no date prefix
(e.g. `quarto-1-10`). The published URL becomes `/blog/YYYY-MM-DD_<slug>/`
from the frontmatter `date`. Never scaffold under `content/blog/ported/` —
that tree is for migrated legacy posts.

## Frontmatter

Don't write the frontmatter from memory — scaffold it from the repo's Hugo
archetype (`archetypes/blog.md`, the source of truth for the schema; see
Workflow step 2) and fill it in. Field meanings and taxonomies are documented
in open-source-website's `content/blog/CLAUDE.md`.

Quarto-post specifics when filling in the scaffold:

**source: quarto** — required, and not in the archetype. Places the post on
the [Quarto project listing](https://opensource.posit.co/blog/q/quarto/),
where old quarto.org blog URLs redirect. Set `software: quarto` too.

**date**: a future date schedules the post — Hugo hides it until a daily
build (8 AM UTC) on the publish date, so set the date the PR is expected to
merge (or later). No date-fixing script needed.

**image / image-alt**: set `image: thumbnail.png`, 1920×1080 (16:9) — used as
both the hero and the listing card. `image-alt` is mandatory.
See `references/thumbnail-guide.md` for the decision between the two
production paths (Typst, or HTML+SVG) and the HTML+SVG flow. For the Typst
path, see `references/typst-thumbnail.md`.

**people**: full names, individuals only — never a team name.

**tags**: freeform — this is where the old quarto.org `categories` vocabulary
lives on (`Releases`, `Quarto X.Y`, `Features`, `Authoring`, `Learn`,
`Workshop`, `Tip`, ...; the port moved each post's categories into its tags).
Reuse tags already present in `content/blog/ported/quarto/` sources rather
than coining synonyms, and skip a bare `Quarto` tag — `source` and `software`
already cover it.

Never add `ported_from` or `port_status` (migration metadata), and don't carry
over the old quarto.org schema: no `categories`, no `subtitle`, no
`_metadata.yml` inheritance.

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

Multi-image layouts use Quarto's layout system (`{layout-ncol="2"}`) — a Lua
filter in open-source-website converts these for Hugo. Don't use `.lightbox`;
that's a quarto.org HTML feature with no equivalent in the Hugo pipeline.

### Code Blocks

Always specify language. Use `filename=` labels for file content or terminal commands:

````markdown
```{.yaml filename="_quarto.yml"}
project:
  type: website
```
````

### Links

**Docs links must be absolute**: `https://quarto.org/docs/...`, never a
`.qmd` source path or a site-root-relative path — the post no longer lives on
quarto.org. Derive the URL from the repo path:
`docs/<path>/<page>.qmd` → `https://quarto.org/docs/<path>/<page>.html`.
Every feature mentioned links to its docs page. Pattern: explain briefly,
show example, then link.

**Verify every quarto.org link resolves** (e.g.
`curl -s -o /dev/null -w '%{http_code}' <url>`). A page whose docs exist only
on the `prerelease` branch will 404 until the release-time
`prerelease` → `main` merge. Keep the quarto.org URL anyway — never
substitute the prerelease site's domain — and **flag every such
pending-merge link when handing off the draft** so it's re-checked before the
post publishes.

**Other blog posts**: link with the permalink pattern `/blog/YYYY-MM-DD_slug/`
(see the authoring guide), never content-directory paths.

### Callouts

Use sparingly: `.callout-tip` for post origin context, `.callout-warning` for caveats,
`.callout-note` for prerequisites. Quarto callouts render correctly through
the Hugo pipeline.

### Shortcodes

- `{{< video URL >}}` — video embed
- `{{< include file.md >}}` — include generated content

Both are processed by Quarto at render time and work in open-source-website.

**Displaying literal shortcode syntax** (showing readers what to type) takes
three ingredients — this is how every such example in the ported Quarto posts
works (verified empirically):

1. **Put the syntax in code** — a fenced block or inline code, never prose.
   An escape in prose reaches Hugo as a live shortcode: a name Hugo knows
   silently renders its output in place of your example; an unknown name
   fails the entire site build.
2. **Escape it so Quarto doesn't execute it**: triple braces
   (`{{{< meta state >}}}`), or the `shortcodes="false"` attribute on a
   fenced block (`{.markdown shortcodes="false"}`). Unescaped syntax in code
   is swallowed at the Quarto stage, leaving empty code.
3. **Opt into the site's escape filter** in the post frontmatter:

   ```yaml
   filters:
     - escape-shortcodes
   ```

   The filter (`content/_extensions/escape-shortcodes`) rewrites `{{<` to
   Hugo's comment escape in code contexts, so Hugo displays the syntax
   instead of executing it. Ported Quarto posts get it automatically via
   `content/blog/ported/quarto/_metadata.yml`; new posts must opt in.

In prose, refer to shortcodes by name instead ("the `video` shortcode").

**`{{< prerelease-callout >}}` does NOT exist there** — it's a quarto-web
extension. For a post about an unreleased feature, write a static callout
instead, and remove it once the version ships:

```markdown
::: {.callout-note}
This feature is available in the
[pre-release version of Quarto](https://quarto.org/docs/download/prerelease.html)
and will be part of the upcoming X.Y release.
:::
```

## Workflow

1. **Identify post type** → read `references/post-types.md` for that type
2. **Branch and scaffold** in the open-source-website clone, off up-to-date
   `main`, mirroring its `/new-post` command:

   ```bash
   git checkout -b blog/<slug>
   hugo new blog/<slug>/index.md
   mv content/blog/<slug>/index.md content/blog/<slug>/index.qmd
   ```

   `hugo new` fills the frontmatter from `archetypes/blog.md`, so the schema
   stays in sync with the site. If `hugo` isn't installed, copy the
   frontmatter from `archetypes/blog.md` by hand instead — same source of
   truth. (In a Claude session started in that repo, the `/new-post` command
   runs this flow interactively.)
3. **Fill in the frontmatter**: replace the placeholder `title`, `people`,
   and `description`; trim `topics`, `languages`, and `tags` to what applies;
   delete unused optional fields; and set the Quarto specifics above
   (`source: quarto`, `image`/`image-alt`, `date`)
4. **Draft body** following type-specific structure. Body headings start at
   `##` — the H1 comes from `title`.
5. **Add images** with `fig-alt=` on every one
6. **Link to docs** with absolute quarto.org URLs for every feature mentioned
7. **Create thumbnail** (1920×1080):
   1. Read `references/thumbnail-guide.md` § Choosing your path
   2. **Always present both options as a question to the user**, even if one
      path is the obvious recommendation. State the recommendation with
      reasoning (logos? programmatic diagram? text-only? release post?), then
      explicitly ask the user to confirm or override before proceeding. Never
      silently pick.
   3. Read the chosen path's reference and execute
      (`references/typst-thumbnail.md` for Typst, rest of `thumbnail-guide.md`
      for HTML+SVG)
8. **Render**: from the post directory, `quarto render index.qmd` — this
   produces the `index.md` Hugo builds from. Commit `index.qmd`, `index.md`,
   and any generated outputs together.
9. **Validate**: from the open-source-website root:

   ```bash
   uv run scripts/validate-blog-posts.py content/blog/<slug>/index.md
   ```

   In a Claude session started in that repo, the `/check-post` and
   `/review-post` commands run validation and a content review interactively.
10. **Review**: direct opener? code blocks fenced with language? all images
    alt-texted? absolute docs links, each verified live or flagged as
    pending-merge? closing matches type convention? frontmatter complete
    (`people`, `topics`, `source: quarto`)?

## Publishing

Open a PR against `main` in `posit-dev/open-source-website` — never push
directly to `main`. Posit org members push branches to the repo itself (no
fork needed); a Netlify preview is posted on the PR automatically, and merging
requires one approving review from someone with Write access. To schedule a
post, set a future `date` and merge — it goes live on that date's morning
build. Details: `content/blog/_authoring-guide.md` § Publishing your post.
