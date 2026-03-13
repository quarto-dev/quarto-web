---
name: capturing-screenshots
description: Capture or update documentation screenshots for the Quarto website using Playwright. Use when screenshots need refreshing, new screenshots are needed for docs pages, or the user mentions screenshots, screen captures, or visual documentation.
allowed-tools: Bash(node tools/screenshots/*), Bash(cat *), Bash(playwright-cli *), Bash(oxipng *), Agent
---

## Setup

When this skill loads, run these commands to gather context:

1. **List registered screenshots:** `bash "${CLAUDE_SKILL_DIR}/scripts/list-screenshots.sh"`
2. **Read visual rules:** `cat tools/screenshots/CLAUDE.md`
3. **Read capture agent reference:** `cat "${CLAUDE_SKILL_DIR}/capture-agent.md"`

## Instructions

You are the screenshot orchestrator. The list output shows all registered screenshots, the visual rules define quality standards, and the capture agent reference describes how browser operations work.

### If the user wants to UPDATE existing screenshots:

1. Ask which screenshots to update (or "all")
2. Process screenshots **one at a time** — never batch-capture without confirmation:
   a. Render: `node tools/screenshots/scripts/render.js <project-path>` (can batch-render all profiles upfront)
   b. Capture: `npm run capture -- --name <name>` (handles serve, capture, dark variant, compress)
   c. Show the user the output image(s) using the Read tool
   d. **STOP and wait for explicit confirmation** before proceeding to the next screenshot
   e. If the user requests adjustments, update manifest and re-capture
   f. Only after confirmation, move to the next screenshot
3. Show results summary

**Critical:** Each screenshot requires user visual review and explicit approval. Do not proceed to the next screenshot until the user confirms the current one is acceptable. This applies to both new captures and re-captures of existing screenshots.

### If the user wants to CREATE a new screenshot:

Gather these parameters (ask about unknowns, infer from context when obvious):

| Parameter | Values / Notes |
|-----------|---------------|
| Source type | `url` (live site), `preview` (PR deploy), `example` (local Quarto project), `local` (quarto-web) |
| Source detail | URL, preview path, or example project path (create minimal project if needed) |
| Viewport | navbar=1440x400, sidebar=992x600, about=1200x900, full page=1440x900 |
| Zoom | Default 1.0; use 1.15 for about pages or excess internal padding |
| Element | CSS selector if capturing a specific element; omit for full viewport |
| Interactions | Clicks, hovers, etc. needed before capture |
| Trim / Crop | `trim: true` for uniform background edges; `cropBottom`/`maxHeight` when vertical rules prevent trim |
| Output path | Suggest based on doc location |
| Doc file | Which .qmd references this image (for manifest `doc.file`) |

Then work through two phases:

#### Phase A: Visual design (what to capture)

Use playwright-cli to explore the page interactively and nail down the visual:

1. Create example project if needed
2. Render: `node tools/screenshots/scripts/render.js <project-path>`
3. Serve: `node tools/screenshots/scripts/serve.js <dir>` (prints URL)
4. Open in playwright-cli: `playwright-cli -s=screenshot open <url>`
5. Iterate with the user: adjust viewport, element selector, cleanup evals, interactions, zoom
6. Use `playwright-cli --help` to discover available commands for interactive exploration
7. See capture-agent.md for `eval` vs `run-code` guidance — use `run-code` for complex JS

#### When stuck: Chrome DevTools MCP (only if available)

If playwright-cli's shell escaping fights you on complex JS (template literals,
nested quotes, `getComputedStyle`), Chrome DevTools MCP can help — but ONLY if
it's available in the current session, and ALWAYS ask the user before switching.

- `evaluate_script` — proper JS function, no shell escaping layer
- `take_screenshot` — inline visual feedback in conversation
- Best for: iterative CSS/DOM debugging (e.g., spotlight stacking contexts)
- Trade-off: more verbose output per call = higher token usage

Never switch to Chrome DevTools MCP proactively. Suggest it as an option and
let the user decide.

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
- The capture agent reference (from `${CLAUDE_SKILL_DIR}/capture-agent.md`)
- Specific screenshot details: viewport, cleanup, interactions, element, output path
- Note: zoom and post-processing (trim, crop) are handled by capture.js, not the agent. If the agent captures manually, it should apply zoom via `page.evaluate(z => document.body.style.zoom = z, String(zoom))`
- Instruct it to follow the capture workflow and use `-s=screenshot` session flag
