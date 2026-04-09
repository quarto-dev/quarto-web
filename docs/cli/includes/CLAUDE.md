# CLI Reference Includes

Files in this directory are **auto-generated**. Do not edit manually.

## Regeneration workflow

1. Update JSON from quarto CLI source:
   ```bash
   quarto dev-call cli-info > docs/cli/cli-info.json
   ```
2. Regenerate markdown includes:
   ```bash
   quarto run _tools/reference-cli-generate-md.R
   ```

The descriptions (e.g., tool lists in install/update/uninstall) come from quarto-cli's command definitions. To change them permanently, update the CLI source in quarto-cli.
