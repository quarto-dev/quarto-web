# Post Type Reference

Detailed structure guidance for each blog post type. Read the section that matches
your post — you rarely need all four.

All docs links in examples are absolute (`https://quarto.org/docs/...`) — the
blog no longer lives on quarto.org, so site-relative paths break.

## Release Announcements

The most structured type. Readers expect consistency across releases.

**Opening**: One direct sentence announcing the release, immediately followed by
download and changelog links. No preamble.

```markdown
Quarto 1.9 is out! You can get the current release from the
[download page](https://quarto.org/docs/download/index.html). You can find all
the changes in this version in the
[Release Notes](https://quarto.org/docs/download/changelog/1.9/).
```

The summary paragraph between the download link and the feature sections names
each major feature as a short noun phrase ("more refined HTML accessibility
checks") — one clause per feature, no capability details. The detail belongs in
the feature sections.

**Feature sections**: Each major feature gets a `##` heading named after the feature
(not "What's New"). Order by importance. Each section:
- Explain in 2-3 sentences
- Code example or screenshot (or both)
- Link to docs: "Learn more at [Feature Name](https://quarto.org/docs/path.html)."

Keep feature prose lean — state what changed plainly:
- Cut "why this matters" clauses and parenthetical examples (`e.g.`,
  `such as`); the docs link carries that detail.
- Scope claims precisely: if a behavior applies only under a particular
  option, say so ("When using `output: document`, violations are…").
- Cover the headline change only. Adjacent minor wins (a platform port, a
  related small fix) can be dropped — the changelog has them.

**Other Highlights**: `## Other Highlights` bundles smaller improvements. Format:

```markdown
- [Feature Name](https://quarto.org/docs/path.html)---Short description of what it does.
```

Note the em-dash (`---`) between link and description.

**Dependency updates**: List bundled tool updates (Pandoc, Typst, Deno) after Other
Highlights if applicable.

**Closing**: Always `## Acknowledgements`. Thank contributors. Recent releases use
`{{< include _contribs.md >}}`, with `_contribs.md` committed in the post
folder. Release posts with emoji thumbnails include OpenMoji attribution at
the very end.

**Callouts**: release posts typically skip them.

**Frontmatter**: `title` is `"Quarto X.Y"`; `source: quarto` always; `topics`
from the fixed set (release posts have used `Publishing`); `tags` are
`Quarto X.Y` and `Releases` — the old categories convention, carried by every
ported release post.

---

## Feature Announcements

Spotlight a specific feature, often published before the corresponding release. More
varied structure than release posts.

**Opening**: If the feature is unreleased, add a static callout at the very top
(the quarto.org `{{< prerelease-callout >}}` shortcode doesn't exist in
open-source-website), and remove it once the version ships:

```markdown
::: {.callout-note}
This feature is available in the
[pre-release version of Quarto](https://quarto.org/docs/download/prerelease.html)
and will be part of the upcoming X.Y release.
:::
```

Then a direct statement of what the feature does. Get to the point — readers clicked
because the title caught their interest.

**Body**: Organize around the feature's concepts, not a "what's new" list. `##`
headings name the concept being explained.

Problem/Solution framing works well for features that address a pain point: explain
the problem first, then show how the feature solves it.

**Closing**: Link to the documentation. "Learn more on the
[Feature Name](https://quarto.org/docs/path.html) page." No acknowledgements section.

---

## Technical How-to Posts

Tutorial-style walkthroughs.

**Opening**: If based on a talk or repost, start with a `.callout-tip` providing context
and linking the original source. Then frame the use case — what problem does the reader
have?

**Body**: Walk through steps sequentially. Heading names can be conversational — verbs
and questions are fine ("Create the content", "Why are we doing this?"). Use numbered
sub-steps when sequence matters.

Show before/after comparisons with `{layout-ncol="2"}` divs.

**Closing**: Brief summary of what was covered, or a "Learn more" section with resource
links. No acknowledgements.

---

## News/Community Posts

Short announcements, conference roundups, workshop materials. The lightest type.

**Opening**: One direct summary sentence.

**Body**: Often visual grids rather than prose. Conference roundups use
`{layout="[70,30]"}` divs pairing descriptions with thumbnails. Video posts embed
with `{{< video >}}`.

**Closing**: May have no explicit closing — the content structure speaks for itself.
