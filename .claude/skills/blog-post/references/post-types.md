# Post Type Reference

Detailed structure guidance for each blog post type. Read the section that matches
your post — you rarely need all four.

## Release Announcements

The most structured type. Readers expect consistency across releases.

**Opening**: One direct sentence announcing the release, immediately followed by
download and changelog links. No preamble.

```markdown
Quarto 1.9 is out! You can get the current release from the
[download page](/docs/download/index.qmd). Read the full
[changelog](https://github.com/quarto-dev/quarto-cli/releases/tag/v1.9)
for a complete list of changes.
```

**Feature sections**: Each major feature gets a `##` heading named after the feature
(not "What's New"). Order by importance. Each section:
- Explain in 2-3 sentences
- Code example or screenshot (or both)
- Link to docs: "Learn more at [Feature Name](/docs/path)."

**Other Highlights**: `## Other Highlights` bundles smaller improvements. Format:

```markdown
- [Feature Name](/docs/path)---Short description of what it does.
```

Note the em-dash (`---`) between link and description.

**Dependency updates**: List bundled tool updates (Pandoc, Typst, Deno) after Other
Highlights if applicable.

**Closing**: Always `## Acknowledgements`. Thank contributors. Recent releases use
`{{< include _contribs.md >}}`. Release posts with emoji thumbnails include OpenMoji
attribution at the very end.

**Categories**: Always `Quarto X.Y` + `Releases`.

---

## Feature Announcements

Spotlight a specific feature, often published before the corresponding release. More
varied structure than release posts.

**Opening**: If unreleased, add prerelease callout at the very top:

```markdown
{{< prerelease-callout 1.10 type="blog" >}}
```

Then a direct statement of what the feature does. Get to the point — readers clicked
because the title caught their interest.

**Body**: Organize around the feature's concepts, not a "what's new" list. `##`
headings name the concept being explained.

Problem/Solution framing works well for features that address a pain point: explain
the problem first, then show how the feature solves it.

**Closing**: Link to the documentation. "Learn more on the [Feature Name](/docs/path)
page." No acknowledgements section.

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
