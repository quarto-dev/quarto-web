# Screenshot Tooling — Sub-plan Index

**Main plan:** [`glistening-beaming-thunder.md`](../glistening-beaming-thunder.md)
**PR:** https://github.com/quarto-dev/quarto-web/pull/1815 (Twitter→Bluesky, 8 screenshots)

## Architecture Summary

Claude Code is the primary operator. Scripts handle deterministic work (zero AI tokens). AI only for visual judgment.

```
/screenshot skill (orchestrator, Opus)
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
| 06 | [06-skill-scripts.md](06-skill-scripts.md) | `/screenshot` skill, `!` preprocessing, helper scripts | Updated (skill dir, preprocessing fix) |
| 07 | [07-capture-agent.md](07-capture-agent.md) | `screenshot-capture` agent definition | Updated (bundled in skill dir) |
| 08 | [08-walkthrough-learnings.md](08-walkthrough-learnings.md) | Learnings from Phase 0.5 walkthrough | Updated (L16-L17 added) |
| 09 | [09-pr-1815-screenshot-updates.md](09-pr-1815-screenshot-updates.md) | .qmd changes for PR #1815 (`.include-dark`, alt text) | Done (all cherry-picked) |
| 10 | [10-tight-cropping.md](10-tight-cropping.md) | Tight cropping: cleanup eval vs sharp vs Playwright style | Done (about-pages + myblog) |
| 11 | [11-manifest-schema.md](11-manifest-schema.md) | JSON Schema for manifest validation + help reference | Planned |
| 12 | [12-navigation-screenshots.md](12-navigation-screenshots.md) | All 11 website-navigation.qmd screenshots: 3 new example projects, 9 new manifest entries | New |

## Key Decisions

- **playwright-cli** for interactive design (agent/skill explores selectors, viewports)
- **Playwright API** (Node.js library) for automated replay in capture.js — avoids shell quoting issues across platforms
- **npm deps**: `playwright` + `open` + `sharp` in tools/screenshots/package.json
- **sharp trim** — content-aware trim after capture removes blank space from CSS layout padding; `capture.trim` manifest option
- **Sonnet** for capture agent, **Opus** for orchestrator
- **Manifest-driven** — every screenshot fully described and reproducible
- **Two sessions**: Session 1 = build + validate (2 screenshots), Session 2 = all 8
- **Quarto profiles** for multi-template examples — one shared .qmd, profile configs override template
- **Dark mode** — `"dark": true` auto-captures `-dark` variant; clip union ensures identical dimensions
- **Clip over element** — `capture.clip` (union bounding box) handles dropdown overflow; `capture.element` clips to element bounds
- **cropBottom/maxHeight** — post-capture image cropping for layouts where trim can't detect blank edges (vertical rules, multi-colored backgrounds)
- **URL source** — `source.type: "url"` captures from live sites (e.g., quarto-demo). Use specific selectors when pages have multiple instances of an icon (e.g., `#quarto-navigation-tool-dropdown-0` instead of `.bi-github`)
- **`${CLAUDE_SKILL_DIR}`** — skill directory variable for CWD-independent paths in `!` preprocessing. `$()` command substitution is blocked by Claude Code permission checks; use `${CLAUDE_SKILL_DIR}/../../..` to reach repo root

## File Layout (Session 1 deliverables)

```
.claude/
├── skills/
│   ├── screenshot/                    # /screenshot skill (orchestrator + agent)
│   │   ├── SKILL.md                   # orchestrator, uses ${CLAUDE_SKILL_DIR}
│   │   └── capture-agent.md           # Sonnet capture agent reference
│   └── playwright-cli/                # installed via playwright-cli install --skills

tools/screenshots/
├── manifest.json                   # screenshot definitions
├── capture.js                      # replay script (no AI)
├── CLAUDE.md                       # visual rules for Claude
├── SETUP.md                        # colleague setup guide
├── .gitignore
├── package.json                    # deps: playwright, open, sharp
├── scripts/
│   ├── list.js                     # read manifest, format output
│   ├── render.js                   # quarto render wrapper
│   ├── serve.js                    # detect + start file server
│   └── compress.js                 # oxipng wrapper
└── examples/
    ├── navbar-tools/               # navbar with dropdown
    ├── sidebar-tools/              # sidebar with dropdown
    ├── about-pages/                # 5 about templates
    ├── myblog/                     # blog homepage
    ├── navbar-basic/               # basic navbar (plan 12)
    ├── sidebar-demo/               # sidebar styles + features (plan 12)
    └── hybrid-nav/                 # hybrid navbar+sidebar (plan 12)

.github/workflows/
└── optimize-images.yml             # CI oxipng
```
