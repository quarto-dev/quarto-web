---
description: Capture or update documentation screenshots
allowed-tools: Bash(node *), Bash(playwright-cli *), Bash(oxipng *), Agent
---

## Current Screenshots

!`node "${CLAUDE_SKILL_DIR}/../../../tools/screenshots/scripts/list.js"`

## Visual Rules

!`cat "${CLAUDE_SKILL_DIR}/../../../tools/screenshots/CLAUDE.md"`

## Capture Agent Reference

!`cat "${CLAUDE_SKILL_DIR}/capture-agent.md"`

## Instructions

You are the screenshot orchestrator. The manifest data above shows all registered screenshots, and the capture agent reference describes how browser operations work.

### If the user wants to UPDATE existing screenshots:

1. Ask which screenshots to update (or "all")
2. For each screenshot group (by source project):
   a. Render: `node tools/screenshots/scripts/render.js <project-path>`
   b. Serve: `node tools/screenshots/scripts/serve.js <dir>` (background, prints URL)
   c. Launch capture agent for this group (pass URL + manifest entries)
   d. Compress: `node tools/screenshots/scripts/compress.js <output-file>`
   e. Show the user the output file path and ask them to verify visually
   f. Wait for confirmation before continuing to the next group
   g. Stop the background server process started in step 2b
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
5. **What viewport size?** (suggest based on category: navbar=1440x400, sidebar=992x600, about=1200x900, full page=1440x900)
6. **Zoom?** (suggest 1.15 for about pages or content with excess internal padding; default 1.0)
7. **Trim whitespace?** (suggest `trim: true` when there's blank space around content. Won't work if layout elements like vertical rules extend to the edge — use cropBottom/maxHeight instead.)
8. **Crop bottom or max height?** (suggest `cropBottom` when a fixed amount of blank space at bottom, `maxHeight` when the image should be capped. Use when trim can't detect blank edges.)
9. **Element or full page?** If element, what CSS selector?
10. **Any interactions needed?** (click dropdown, hover, etc.)
11. **Output path?** (suggest based on doc location)
12. **Which .qmd file references this image?** (for doc.file in manifest)

Then work through two phases:

#### Phase A: Visual design (what to capture)

Use playwright-cli to explore the page interactively and nail down the visual:

1. Create example project if needed
2. Render: `node tools/screenshots/scripts/render.js <project-path>`
3. Serve: `node tools/screenshots/scripts/serve.js <dir>` (prints URL)
4. Open in playwright-cli: `playwright-cli -s=screenshot open <url>`
5. Iterate with the user: adjust viewport, element selector, cleanup evals, interactions, zoom
6. Use `playwright-cli --help` to discover available commands for interactive exploration

#### Phase B: Image processing (how to post-process)

Once the visual is right, configure post-capture processing:

1. Add the manifest entry to `tools/screenshots/manifest.json`
2. Run `npm run capture -- --name <name>` to produce the screenshot
3. Show the user the output — ask them to verify visually
4. If blank space remains, decide with the user:
   - **Uniform background edges?** → add `"trim": true`
   - **Vertical rules or multi-color edges?** → add `"cropBottom": N` or `"maxHeight": N`
   - **Both?** → trim runs first, then crop
5. Re-capture and verify until the user is satisfied

### Launching the capture agent:

Use the Agent tool with `subagent_type="general-purpose"` and `model="sonnet"`. Pass:
- The base URL where the site is being served
- The capture agent reference (already in your context above)
- Specific screenshot details: viewport, cleanup, interactions, element, output path
- Note: zoom and post-processing (trim, crop) are handled by capture.js, not the agent. If the agent captures manually, it should apply zoom via `page.evaluate(z => document.body.style.zoom = z, String(zoom))`
- Instruct it to follow the capture workflow and use `-s=screenshot` session flag
