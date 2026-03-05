# Sub-plan 07: screenshot-capture Agent

Parent: [00-index.md](00-index.md)

## Overview

A Claude Code sub-agent (Sonnet) that handles all browser operations for screenshot capture. Uses playwright-cli skill for browser control. The only part of the workflow that needs AI — for visual validation and ref-based interaction.

## Agent Definition

**Location:** `.claude/agents/screenshot-capture.md`

```markdown
---
model: sonnet
description: Captures documentation screenshots using playwright-cli
skills:
  - playwright-cli
allowed-tools: Bash(playwright-cli:*), Bash(node:*), Read
---

# Screenshot Capture Agent

You capture documentation screenshots using playwright-cli. You receive:
- A base URL where the page is already being served
- One or more screenshot specifications from the manifest

## Capture Workflow

For each screenshot:

### 1. Navigate and resize

```bash
playwright-cli open <url>/<page>
playwright-cli resize <width> <height>
```

### 2. Wait for full load

```bash
playwright-cli snapshot
```

Check the snapshot for:
- Bootstrap Icons rendered (not blank boxes or missing glyphs)
- Fonts loaded (text not in fallback font)
- Content fully rendered (not loading spinners)

If not ready, wait and re-snapshot:
```bash
playwright-cli eval "new Promise(r => setTimeout(r, 2000))"
playwright-cli snapshot
```

### 3. Run cleanup steps

Remove prerelease callouts and banners:
```bash
playwright-cli eval "document.querySelectorAll('.callout-note').forEach(el => { if (el.textContent.includes('Pre-release')) el.remove() })"
playwright-cli eval "document.querySelectorAll('[class*=prerelease],[class*=preview]').forEach(el => el.remove())"
```

Run any additional cleanup from the manifest entry.

### 4. Run interaction steps

For clicks (e.g., opening a dropdown):
1. Take a snapshot to get refs
2. Find the ref matching the target (e.g., the GitHub icon)
3. Click it: `playwright-cli click <ref>`
4. If a wait selector is specified, snapshot again and verify the element appeared

For hovers:
1. Snapshot to find ref
2. `playwright-cli hover <ref>`

### 5. Take screenshot

**Element screenshot** (when capture.element is specified):
1. Snapshot to find the ref for the element
2. `playwright-cli screenshot <ref> --filename=<output-path>`

**Full page/viewport screenshot:**
```bash
playwright-cli screenshot --filename=<output-path>
```

### 6. Visual validation

After capturing, take a final snapshot and verify:
- The screenshot file was created and is non-empty
- Report what you see (so the orchestrator can review)

### 7. Close when done with all screenshots for this session

```bash
playwright-cli close
```

## Rules

- ALWAYS use light color scheme (default)
- ALWAYS wait for fonts and icons to load before capturing
- ALWAYS remove prerelease/preview banners
- Use consistent viewport sizes from the manifest
- If something looks wrong (missing icons, broken layout), report it — don't save a bad screenshot
- If an interaction fails (ref not found, dropdown didn't open), report the error with the snapshot content
```

## How the Orchestrator Invokes This Agent

From the `/screenshot` command or capture.js:

```
Agent(
  subagent_type="general-purpose",
  model="sonnet",
  prompt="""
  You are the screenshot capture agent. Use playwright-cli for all browser operations.

  Base URL: http://localhost:3456

  Capture these screenshots:

  1. navbar-tools
     - Page: index.html
     - Viewport: 1440x400
     - Cleanup: [standard prerelease removal]
     - Interaction: click .bi-github, wait .dropdown-menu.show
     - Element: .navbar
     - Output: docs/websites/images/navbar-tools.png

  2. about-jolla
     - Page: jolla.html
     - Viewport: 1200x900
     - Cleanup: [standard prerelease removal]
     - No interaction
     - Full viewport
     - Output: docs/websites/images/about-jolla.png

  Follow the capture workflow: open, resize, wait for load, cleanup, interact, screenshot, validate.
  Report results for each screenshot.
  """
)
```

## Why Sonnet (not Opus or Haiku)

- **Visual judgment required:** Is the page fully loaded? Are icons rendered? Does the layout look right?
- **Sonnet is sufficient:** These are straightforward visual checks, not complex reasoning
- **Token efficiency:** Sonnet is ~5x cheaper than Opus, adequate for this task
- **Not Haiku:** Haiku can't reliably interpret visual correctness from snapshots

## Interaction with playwright-cli Skill

The agent has `skills: playwright-cli` in frontmatter, which means:
- The SKILL.md content is loaded into its context automatically
- It knows all available playwright-cli commands
- It can use refs from snapshots naturally (e.g., `playwright-cli click e15`)
- It has `Bash(playwright-cli:*)` permission to run any playwright-cli command

## Finding Refs from CSS Selectors

The manifest stores CSS selectors (`.bi-github`, `.navbar`), but playwright-cli uses refs (e3, e15). The agent handles this naturally:

1. Takes a snapshot
2. Reads the snapshot (YAML with refs for each element)
3. Identifies which ref corresponds to the CSS selector (using AI judgment)
4. Uses that ref for click/screenshot

This is where AI adds value — mapping semantic descriptions to refs requires understanding the page structure. The replay script (capture.js) bypasses this with `run-code` using Playwright API directly.

## Error Scenarios

| Problem | Agent behavior |
|---------|---------------|
| Page won't load | Report error, skip this screenshot |
| Icons not rendering | Wait up to 10s, re-snapshot, report if still broken |
| Ref not found for selector | Report snapshot contents, skip interaction |
| Dropdown didn't open | Retry once, report if still closed |
| Screenshot file empty/missing | Report error |
| Layout looks wrong | Report concern, save screenshot anyway (orchestrator decides) |
