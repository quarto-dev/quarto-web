# Sub-plan 09: PR #1815 Screenshot Updates

Parent: [00-index.md](00-index.md)
PR: https://github.com/quarto-dev/quarto-web/pull/1815

## Context

PR #1815 moves examples from Twitter to Bluesky across quarto-web docs. Several doc pages reference screenshots that need updating with the new icons and examples. This plan describes what to do in that PR using the screenshot tooling built in this branch.

## Screenshots to Update

The tooling branch produces these images via `capture.js`:

| Image | Light | Dark | Dimensions |
|-------|-------|------|------------|
| about-jolla | `about-jolla.png` | `about-jolla-dark.png` | 819x579 |
| navbar-tools | `navbar-tools.png` | `navbar-tools-dark.png` | 181x136 |

## .qmd Changes Needed in PR #1815

Add `.include-dark` class to image references so the `filters/include-dark.lua` filter generates both light and dark `<img>` tags. The filter expects a `-dark` variant at the same path (e.g., `about-jolla.png` + `about-jolla-dark.png`).

### `docs/websites/website-about.qmd` (line 69)

```markdown
# Before
![](images/about-jolla.png){.border fig-alt="..."}

# After
![](images/about-jolla.png){.border .include-dark fig-alt="..."}
```

### `docs/websites/website-blog.qmd` (line 168)

```markdown
# Before
![](images/about-jolla.png){.border fig-alt="..."}

# After
![](images/about-jolla.png){.border .include-dark fig-alt="..."}
```

### `docs/websites/website-navigation.qmd` (line 112)

```markdown
# Before
![](images/navbar-tools.png){.border alt="...Twitter..."}

# After
![](images/navbar-tools.png){.border .include-dark alt="...Bluesky..."}
```

Note: the navbar-tools alt text should also be updated from "Twitter" to "Bluesky" since the icon changed.

## Alt Text Updates

The example projects now use Bluesky instead of Twitter. Update alt text in the .qmd files:
- "Twitter and Github logo" → "Bluesky and Github logo"
- "buttons for twitter and github" → "buttons for Bluesky and GitHub" (or similar)

## Workflow

1. Merge the screenshot tooling branch first (or cherry-pick the images)
2. In PR #1815, add `.include-dark` to the three image references above
3. Copy the four screenshot files (light + dark for both) into the PR
4. Update alt text to reference Bluesky
5. Verify with `quarto preview` that both light and dark images render correctly

## Future Screenshots

When more screenshots are added to the manifest (sidebar, blog, etc.), follow the same pattern:
- Set `"dark": true` in manifest.json
- Add `.include-dark` to the .qmd image reference
- Both variants are captured automatically by `capture.js`
