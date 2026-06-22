| Alias        | Formats                                                                        |
|--------------|--------------------------------------------------------------------------------|
| `latex`      | `latex`, `pdf`, `beamer`                                                       |
| `pdf`        | `latex`, `pdf`, `beamer`                                                       |
| `epub`       | `epub*`                                                                        |
| `html`       | `html*`, `epub*`, `revealjs`, `dashboard`, `email`                             |
| `html:js`    | `html*`, `revealjs`, `dashboard`, `email`                                      |
| `markdown`   | `markdown*`, `commonmark*`, `gfm`, `markua`, `hugo-md`, `docusaurus-md`        |
| `odt`        | `odt`, `opendocument`                                                          |
| `hugo`       | `hugo-md`                                                                      |
| `docusaurus` | `docusaurus-md`                                                                |
| `asciidoc`   | `asciidoc`, `asciidoctor`                                                      |

Note that the `html:js` alias indicates that the target format is capable of executing JavaScript (this maps to all HTML formats save for ePub).

Other values supported are directly the name of the format, including Quarto's specific formats like `dashboard`, `email`, or `confluence`.