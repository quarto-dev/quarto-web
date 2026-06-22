#!/usr/bin/env node
// Prints available commands for the screenshot tooling.

console.log(`
Screenshot tooling for quarto-web
==================================

Commands (run from _tools/screenshots/):

  npm run capture                        Capture all screenshots from manifest
  npm run capture -- --name <pattern>    Capture specific entry (supports globs)
  npm run capture -- --list              List manifest entries
  npm run capture -- --dry-run           Preview what would be captured
  npm run capture -- --no-compress       Skip oxipng compression
  npm run capture -- --verify            Open each image for visual review

  npm run list                           List manifest entries (formatted)
  npm run render -- <project-path>       Render a Quarto example project
  npm run serve -- <site-path>           Serve a rendered site locally
  npm run compress                       Compress all manifest outputs (oxipng)
  npm run compress -- <file.png>         Compress specific files
  npm run open -- <file>                 Open file with OS default app

  npm run validate                       Validate manifest.json against schema
  npm run help                           Show this help

Source of truth: manifest.json
Docs: CLAUDE.md (workflow), SETUP.md (setup guide)
`.trim());
