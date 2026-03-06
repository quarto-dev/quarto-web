# Screenshot Tooling — Sub-plan Index

**Main plan:** [`glistening-beaming-thunder.md`](../glistening-beaming-thunder.md)
**PR:** https://github.com/quarto-dev/quarto-web/pull/1815 (Twitter→Bluesky, 8 screenshots)

## Architecture Summary

Claude Code is the primary operator. Scripts handle deterministic work (zero AI tokens). AI only for visual judgment.

```
/screenshot command (orchestrator, Opus)
    ├── !`node scripts/list.js`  → manifest data injected before prompt
    ├── scripts/render.js        → quarto render (deterministic)
    ├── scripts/serve.js         → file server (deterministic)
    ├── screenshot-capture agent → playwright-cli (Sonnet, visual judgment)
    ├── scripts/compress.js      → oxipng (deterministic)
    └── capture.js               → replay script (no AI needed)
```

## Sub-plans

| # | File | Covers | Status |
|---|------|--------|--------|
| 01 | [01-capture-script.md](01-capture-script.md) | `capture.js` replay script (playwright-cli) | Rewritten |
| 02 | [02-manifest.md](02-manifest.md) | `manifest.json` format + all 8 PR #1815 entries | Updated (profiles, dark, clip) |
| 03 | [03-example-projects.md](03-example-projects.md) | Example Quarto projects (navbar, sidebar, about, blog) | Updated (profiles) |
| 04 | [04-ci-workflow.md](04-ci-workflow.md) | GitHub Action: oxipng on PR PNGs | OK |
| 05 | [05-documentation.md](05-documentation.md) | CLAUDE.md, SETUP.md, visual rules | Revised |
| 06 | [06-skill-scripts.md](06-skill-scripts.md) | `/screenshot` skill, `!` preprocessing, helper scripts | New |
| 07 | [07-capture-agent.md](07-capture-agent.md) | `screenshot-capture` agent definition | New |
| 08 | [08-walkthrough-learnings.md](08-walkthrough-learnings.md) | Learnings from Phase 0.5 walkthrough | Updated (all validated, L15 profiles) |
| 09 | [09-pr-1815-screenshot-updates.md](09-pr-1815-screenshot-updates.md) | .qmd changes for PR #1815 (`.include-dark`, alt text) | Updated (all 8 screenshots) |

## Key Decisions

- **playwright-cli** for interactive design (agent/skill explores selectors, viewports)
- **Playwright API** (Node.js library) for automated replay in capture.js — avoids shell quoting issues across platforms
- **npm deps**: `playwright` + `open` in tools/screenshots/package.json
- **Sonnet** for capture agent, **Opus** for orchestrator
- **Manifest-driven** — every screenshot fully described and reproducible
- **Two sessions**: Session 1 = build + validate (2 screenshots), Session 2 = all 8
- **Quarto profiles** for multi-template examples — one shared .qmd, profile configs override template
- **Dark mode** — `"dark": true` auto-captures `-dark` variant; clip union ensures identical dimensions
- **Clip over element** — `capture.clip` (union bounding box) handles dropdown overflow; `capture.element` clips to element bounds

## File Layout (Session 1 deliverables)

```
.claude/
├── commands/screenshot.md          # /screenshot orchestrator
├── agents/screenshot-capture.md    # Sonnet capture agent
└── skills/playwright-cli/          # installed via playwright-cli install --skills

tools/screenshots/
├── manifest.json                   # screenshot definitions
├── capture.js                      # replay script (no AI)
├── CLAUDE.md                       # visual rules for Claude
├── SETUP.md                        # colleague setup guide
├── .gitignore
├── package.json                    # deps: playwright, open
├── scripts/
│   ├── list.js                     # read manifest, format output
│   ├── render.js                   # quarto render wrapper
│   ├── serve.js                    # detect + start file server
│   └── compress.js                 # oxipng wrapper
└── examples/
    ├── navbar-tools/               # navbar with dropdown
    ├── sidebar-tools/              # sidebar with dropdown (Session 2)
    ├── about-pages/                # 5 about templates
    └── myblog/                     # blog homepage (Session 2)

.github/workflows/
└── optimize-images.yml             # CI oxipng
```
