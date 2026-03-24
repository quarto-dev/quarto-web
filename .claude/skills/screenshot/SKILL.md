---
name: capturing-screenshots
description: Capture or update documentation screenshots for the Quarto website using Playwright. Use when screenshots need refreshing, new screenshots are needed for docs pages, or the user mentions screenshots, screen captures, or visual documentation.
allowed-tools: Bash(node tools/screenshots/*), Bash(npm.cmd *), Bash(cat *), Bash(playwright-cli *), Bash(oxipng *), Agent
---

## Setup

When this skill loads, run these commands to gather context:

1. **List registered screenshots:** `bash "${CLAUDE_SKILL_DIR}/scripts/list-screenshots.sh"`
2. **Read visual rules:** `cat tools/screenshots/CLAUDE.md`
3. **Read capture agent reference:** `cat "${CLAUDE_SKILL_DIR}/capture-agent.md"`
4. **Read manifest schema:** `cat "${CLAUDE_SKILL_DIR}/manifest-schema.md"`

**Working directory:** `npm run` commands (`render`, `capture`, `compress`) work from
any directory — they resolve paths from `tools/screenshots/package.json`. Direct
`node scripts/...` calls and `playwright-cli` must run from `tools/screenshots/` or
use absolute paths. Be careful not to double up path segments if you've already `cd`'d
into `tools/screenshots/`.

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
| Source type | `url` (live site), `example` (Quarto project — render then serve) |
| Source detail | URL or example project path (create minimal project if needed) |
| Viewport | navbar=1440x400, sidebar=992x600, about=1200x900, full page=1440x900 |
| Zoom | Default 1.0; use 1.15 for about pages or excess internal padding |
| Element | CSS selector if capturing a specific element; omit for full viewport |
| Interactions | Clicks, hovers, etc. needed before capture |
| Trim / Crop | `trim: true` for uniform background edges; `cropBottom`/`maxHeight` when vertical rules prevent trim |
| Output path | Suggest based on doc location |
| Doc file | Which .qmd references this image (for manifest `doc.file`) |

Then work through two phases:

#### Phase A: Visual design (what to capture)

Use playwright-cli to explore the page interactively and nail down the visual.
Phase A ends when the user approves the screenshot visual.

1. Create example project if needed
2. Render: `node tools/screenshots/scripts/render.js <project-path>` (add `--profile <name>` if needed)
3. Serve the **rendered output directory**: `node tools/screenshots/scripts/serve.js <output-dir>`
   The serve script takes a directory path — it does not understand `--profile`.
   For default renders, the output is `_site/` inside the project. For profiled renders,
   it's `docs-<profile>/` (e.g., `examples/navbar-basic/docs-reader-mode`). Check the
   render output to confirm the actual path.
4. Open in headed mode: `playwright-cli -s=screenshot open --headed <url>`
   (headed mode shows the browser window so you can see the page)
5. Discover what to capture:
   a. Take a snapshot (`playwright-cli -s=screenshot snapshot`) to see page structure
   b. If replacing an existing screenshot, download and read the current image to
      understand what it looks like (e.g., `curl -sL -o "$TMPDIR/existing.png" <url>`
      then Read tool). Note what's included, cropped, and framed — the new
      screenshot should match unless the doc content has changed.
   c. Read the .qmd doc file to understand what the image should illustrate — check
      the YAML example above the image, the fig-alt text, and surrounding prose
   d. Determine initial viewport from the category table (navbar=1440x400,
      sidebar=992x600, about=1200x900, full page=1440x900)
6. Test and iterate in headed mode:
   a. Resize: `playwright-cli -s=screenshot resize <w> <h>`
   b. Test cleanup evals if needed (hiding elements, removing banners)
   c. Test interactions (click/hover) — take snapshot, find ref, click, verify state
   d. Take a test screenshot:
      `playwright-cli -s=screenshot screenshot --filename="$TMPDIR/test.png"`
   e. Show the screenshot to the user: `npm run open -- "$TMPDIR/test.png"`
      (cross-platform; do NOT use `open` or `start` directly)
   f. Provide review context so the user can judge the screenshot:
      - Which .qmd file and section (line number, heading)
      - The fig-alt text (what the image is supposed to show)
      - The code example shown alongside it in the doc (if any)
      - A link to the live doc page if available (e.g., quarto.org URL)
      - What to specifically check (does navbar match the YAML? Are the
        right items visible? etc.)
   g. Ask: "Does this capture what the doc needs? Anything to adjust?"
   h. Repeat until the user approves the visual
7. Encode findings into manifest:
   a. Read manifest-schema.md for the complete field reference
   b. Create the manifest entry based on what was validated interactively
   c. Every field value should come from tested exploration, not guesswork

Use `playwright-cli --help` to discover available commands.
See capture-agent.md for `eval` vs `run-code` guidance — use `run-code` for complex JS.

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

Phase B starts after the user approves the visual in Phase A and a manifest entry
exists. Now run the automated capture pipeline and tune post-processing.

1. Add the manifest entry to `tools/screenshots/manifest.json`
2. Run `npm run validate` to check the manifest entry
3. Run `npm run capture -- --name <name>` to produce the screenshot
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
