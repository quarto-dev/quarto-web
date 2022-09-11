## Spell Checking

You can enable spell checking for Quarto documents by using the [Spell Right](https://marketplace.visualstudio.com/items?itemName=ban.spellright) VS Code Extension. To configure spell checking, do the following:

1.  Install the [Spell Right](https://marketplace.visualstudio.com/items?itemName=ban.spellright) extension (search for "spell right" in the VS Code Extensions panel)

2.  Open up the VS Code settings UI and search for "spellright" (make sure you are editing **User** level settings if you want to enable Quarto spell checking globally). Then, find the **Spellright: Document Types** setting and click the link to edit it in `settings.json`:

    ![](/docs/tools/images/vscode-spell-right.png){.border}

3.  There will be an entry for `spellright.documentTypes` automatically added to the `settings.json`. Replace it with the following:

    ``` json
    "spellright.documentTypes": [
      "quarto", 
      "markdown", 
      "latex", 
      "plaintext"
    ],
    "spellright.parserByClass": {
      "quarto": {
        "parser": "markdown"
      }
    },
    "spellright.ignoreRegExpsByClass": {
      "quarto": [
        "/\\{.+\\}/", 
        "/@[^ ]+/", 
        "/\\n\\s*[^\\s\\:]+\\:/"
      ]
    }
    ```

    The `spellright.ignoreRegExpsByClass` setting configures Spell Right to ignore Pandoc attributes, citation keys, crossrefs, and YAML option names.
    