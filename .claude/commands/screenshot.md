---
description: Capture or update documentation screenshots
allowed-tools: Bash(node *), Bash(playwright-cli *), Bash(oxipng *), Agent
---

## Current Screenshots

!`node tools/screenshots/scripts/list.js`

## Visual Rules

!`cat tools/screenshots/CLAUDE.md`

## Capture Agent Reference

!`cat .claude/agents/screenshot-capture.md`

## Instructions

You are the screenshot orchestrator. The manifest data above shows all registered screenshots, and the capture agent reference describes how browser operations work.

### If the user wants to UPDATE existing screenshots:

1. Ask which screenshots to update (or "all")
2. For each screenshot group (by source project):
   a. Render: `node tools/screenshots/scripts/render.js <project-path>`
   b. Serve: `node tools/screenshots/scripts/serve.js <dir>` (background, prints URL)
   c. Launch capture agent for this group (pass URL + manifest entries)
   d. Compress: `node tools/screenshots/scripts/compress.js <output-file>`
3. Show results summary

### If the user wants to CREATE a new screenshot:

Ask these questions:

1. **What are you screenshotting?**
   - A page on an external live site → source type `url`
   - A page from a PR preview deploy → source type `preview`
   - A local Quarto example project → source type `example`
   - A page from the quarto-web site itself → source type `local`

2. **For `url` source:** What's the URL?
3. **For `preview` source:** What's the path on the preview site?
4. **For `example` source:**
   - Does an example project already exist in `tools/screenshots/examples/`?
   - If not, create one (minimal Quarto project, just enough to render the screenshot)
5. **What viewport size?** (suggest based on category: navbar=1440x400, sidebar=400x300, about=1200x900, full page=1440x900)
6. **Element or full page?** If element, what CSS selector?
7. **Any interactions needed?** (click dropdown, hover, etc.)
8. **Output path?** (suggest based on doc location)
9. **Which .qmd file references this image?** (for doc.file in manifest)

Then:
1. Add entry to `tools/screenshots/manifest.json`
2. Create example project if needed
3. Render + serve + capture + compress
4. Verify the screenshot looks correct

### Launching the capture agent:

Use the Agent tool with `subagent_type="general-purpose"` and `model="sonnet"`. Pass:
- The base URL where the site is being served
- The capture agent reference (already in your context above)
- Specific screenshot details: viewport, cleanup, interactions, element, output path
- Instruct it to follow the capture workflow and use `-s=screenshot` session flag
