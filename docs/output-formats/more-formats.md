---
title: More Formats
description: "Pandoc support a huge array of output formats, all of which can be used with Quarto. To use any Pandoc format just use the `format` option or the `--to` command line option."
format: html
---

## Overview

Pandoc support a huge array of output formats, all of which can be used with Quarto. To use any Pandoc format just use the `format` option or the `--to` command line option.

For example, here's some YAML that specifies the use of the `odt` format as well as a couple of format options:

``` {.yaml}
---
title: "My Document"
format: 
  odt:
    toc: true
    reference-doc: reference.odt
---
```

Alternatively you can specify the use of a format on the command line:

``` {.bash}
quarto render document.md --to odt
```

## Formats

All Pandoc output formats currently available are listed below (the format "name" on the left is what you specify in the `format` YAML key).

To learn more about the specific options available for all of Pandoc's formats, see the [Pandoc User Guide](https://pandoc.org/MANUAL.html).

+------------------------+-------------------------------------------------------------------------------------------------------+
| Name                   | Details                                                                                               |
+========================+=======================================================================================================+
| asciidoc               | <https://asciidoc.org/>                                                                               |
+------------------------+-------------------------------------------------------------------------------------------------------+
| asciidoctor            | <https://asciidoctor.org/>                                                                            |
+------------------------+-------------------------------------------------------------------------------------------------------+
| beamer                 | <https://ctan.org/pkg/beamer>                                                                         |
+------------------------+-------------------------------------------------------------------------------------------------------+
| commonmark\            | <http://commonmark.org/>                                                                              |
| commonmark_x           |                                                                                                       |
+------------------------+-------------------------------------------------------------------------------------------------------+
| context                | <http://www.pragma-ade.nl/>                                                                           |
+------------------------+-------------------------------------------------------------------------------------------------------+
| csljson                | <https://citationstyles.org/>                                                                         |
+------------------------+-------------------------------------------------------------------------------------------------------+
| docbook\               | <http://www.docbook.org/>                                                                             |
| docbook4\              |                                                                                                       |
| docbook5               |                                                                                                       |
+------------------------+-------------------------------------------------------------------------------------------------------+
| docx                   | <https://en.wikipedia.org/wiki/Office_Open_XML>                                                       |
+------------------------+-------------------------------------------------------------------------------------------------------+
| dokuwiki               | <https://www.dokuwiki.org/wiki:syntax>                                                                |
+------------------------+-------------------------------------------------------------------------------------------------------+
| dzslides               | <http://paulrouget.com/dzslides/>                                                                     |
+------------------------+-------------------------------------------------------------------------------------------------------+
| epub\                  | <http://en.wikipedia.org/wiki/EPUB>                                                                   |
| epub2\                 |                                                                                                       |
| epub3                  |                                                                                                       |
+------------------------+-------------------------------------------------------------------------------------------------------+
| fb2                    | <https://en.wikipedia.org/wiki/FictionBook>                                                           |
+------------------------+-------------------------------------------------------------------------------------------------------+
| gfm                    | <https://github.github.com/gfm/>                                                                      |
+------------------------+-------------------------------------------------------------------------------------------------------+
| haddock                | <http://www.haskell.org/haddock/doc/html/ch03s08.html>                                                |
+------------------------+-------------------------------------------------------------------------------------------------------+
| html\                  | <https://en.wikipedia.org/wiki/HTML5>                                                                 |
| html4\                 |                                                                                                       |
| html5                  |                                                                                                       |
+------------------------+-------------------------------------------------------------------------------------------------------+
| icml                   | <https://wwwimages.adobe.com/content/dam/acom/en/devnet/indesign/sdk/cs6/idml/idml-specification.pdf> |
+------------------------+-------------------------------------------------------------------------------------------------------+
| ipynb                  | <https://nbformat.readthedocs.io/en/latest/>                                                          |
+------------------------+-------------------------------------------------------------------------------------------------------+
| jats\                  | <https://jats.nlm.nih.gov/publishing/>                                                                |
| jats_archiving\        |                                                                                                       |
| jats_articleauthoring\ |                                                                                                       |
| jats_publishing        |                                                                                                       |
+------------------------+-------------------------------------------------------------------------------------------------------+
| jira                   | <https://jira.atlassian.com/secure/WikiRendererHelpAction.jspa?section=all>                           |
+------------------------+-------------------------------------------------------------------------------------------------------+
| json                   | <https://pandoc.org/filters.html>                                                                     |
+------------------------+-------------------------------------------------------------------------------------------------------+
| latex                  |                                                                                                       |
+------------------------+-------------------------------------------------------------------------------------------------------+
| man                    | <http://www.gnu.org/software/groff/groff.html>                                                        |
+------------------------+-------------------------------------------------------------------------------------------------------+
| markdown\              | <https://pandoc.org/MANUAL.html#markdown-variants>                                                    |
| markdown_github\       |                                                                                                       |
| markdown_mmd\          |                                                                                                       |
| markdown_phpextra\     |                                                                                                       |
| markdown_strict        |                                                                                                       |
+------------------------+-------------------------------------------------------------------------------------------------------+
| mediawiki              | <http://www.mediawiki.org/wiki/Help:Formatting>                                                       |
+------------------------+-------------------------------------------------------------------------------------------------------+
| ms                     | <http://www.gnu.org/software/groff/groff.html>                                                        |
+------------------------+-------------------------------------------------------------------------------------------------------+
| muse                   | <https://www.gnu.org/software/emacs-muse/manual/>                                                     |
+------------------------+-------------------------------------------------------------------------------------------------------+
| native                 | <https://pandoc.org/using-the-pandoc-api.html>                                                        |
+------------------------+-------------------------------------------------------------------------------------------------------+
| odt                    | <http://en.wikipedia.org/wiki/OpenDocument>                                                           |
+------------------------+-------------------------------------------------------------------------------------------------------+
| opendocument           | <http://opendocument.xml.org/>                                                                        |
+------------------------+-------------------------------------------------------------------------------------------------------+
| opml                   | <http://dev.opml.org/spec2.html>                                                                      |
+------------------------+-------------------------------------------------------------------------------------------------------+
| org                    | <http://orgmode.org/>                                                                                 |
+------------------------+-------------------------------------------------------------------------------------------------------+
| pdf                    | <https://en.wikipedia.org/wiki/PDF>                                                                   |
+------------------------+-------------------------------------------------------------------------------------------------------+
| plain                  | Plain text                                                                                            |
+------------------------+-------------------------------------------------------------------------------------------------------+
| pptx                   | <https://en.wikipedia.org/wiki/Microsoft_PowerPoint>                                                  |
+------------------------+-------------------------------------------------------------------------------------------------------+
| revealjs               | <http://lab.hakim.se/reveal-js/>                                                                      |
+------------------------+-------------------------------------------------------------------------------------------------------+
| rst                    | <http://docutils.sourceforge.net/docs/ref/rst/introduction.html>                                      |
+------------------------+-------------------------------------------------------------------------------------------------------+
| rtf                    | <https://en.wikipedia.org/wiki/Rich_Text_Format>                                                      |
+------------------------+-------------------------------------------------------------------------------------------------------+
| s5                     | <http://meyerweb.com/eric/tools/s5/>                                                                  |
+------------------------+-------------------------------------------------------------------------------------------------------+
| slideous               | <http://goessner.net/articles/slideous/>                                                              |
+------------------------+-------------------------------------------------------------------------------------------------------+
| slidy                  | <http://www.w3.org/Talks/Tools/Slidy>                                                                 |
+------------------------+-------------------------------------------------------------------------------------------------------+
| tei                    | <https://github.com/TEIC/TEI-Simple>                                                                  |
+------------------------+-------------------------------------------------------------------------------------------------------+
| texinfo                | <http://www.gnu.org/software/texinfo/>                                                                |
+------------------------+-------------------------------------------------------------------------------------------------------+
| textile                | <http://redcloth.org/textile>                                                                         |
+------------------------+-------------------------------------------------------------------------------------------------------+
| xwiki                  | <https://www.xwiki.org/xwiki/bin/view/Documentation/UserGuide/Features/XWikiSyntax/>                  |
+------------------------+-------------------------------------------------------------------------------------------------------+
| zimwik                 | <http://zim-wiki.org/manual/Help/Wiki_Syntax.html>                                                    |
+------------------------+-------------------------------------------------------------------------------------------------------+

Here is a list of the currently supported formats:

**Lightweight markup formats**

-   [Markdown](http://daringfireball.net/projects/markdown/) (including [CommonMark](http://commonmark.org/) and [GitHub-flavored Markdown](https://github.github.com/gfm/))

-   [reStructuredText](http://docutils.sourceforge.net/docs/ref/rst/introduction.html)

-   [AsciiDoc](https://asciidoc.org/)

-   Emacs [Org-Mode](http://orgmode.org/)

-   Emacs [Muse](https://www.gnu.org/software/emacs-muse/manual/)

-   [Textile](http://redcloth.org/textile)

**HTML formats**

-   (X)HTML 4

-   HTML5

**Ebooks**

-   [EPUB](http://en.wikipedia.org/wiki/EPUB) version 2 or 3

-   [FictionBook2](http://www.fictionbook.org/index.php/Eng:XML_Schema_Fictionbook_2.1)

**Documentation formats**

-   [GNU TexInfo](http://www.gnu.org/software/texinfo/)

-   [Haddock markup](http://www.haskell.org/haddock/doc/html/ch03s08.html)

**Roff formats**

-   [roff man](http://www.gnu.org/software/groff/groff.html)

-   [roff ms](http://www.gnu.org/software/groff/groff.html)

**TeX formats**

-   [LaTeX](http://www.latex-project.org/)

-   [ConTeXt](http://www.pragma-ade.nl/)

**XML formats**

-   [DocBook](http://www.docbook.org/) version 4 or 5

-   [JATS](https://jats.nlm.nih.gov/publishing/)

-   [TEI Simple](https://github.com/TEIC/TEI-Simple)

**Outline formats**

-   [OPML](http://dev.opml.org/spec2.html)

**Bibliography formats**

-   [BibTeX](http://tug.org/bibtex/)

-   [BibLaTeX](https://github.com/plk/biblatex)

-   [CSL JSON](https://citeproc-js.readthedocs.io/en/latest/csl-json/markup.html)

-   CSL YAML

**Word processor formats**

-   Microsoft Word [docx](https://en.wikipedia.org/wiki/Office_Open_XML)

-   OpenOffice/LibreOffice [ODT](http://en.wikipedia.org/wiki/OpenDocument)

-   [OpenDocument XML](http://opendocument.xml.org/)

-   Microsoft [PowerPoint](https://en.wikipedia.org/wiki/Microsoft_PowerPoint)

**Interactive notebook formats**

-   Jupyter notebook ([ipynb](https://nbformat.readthedocs.io/en/latest/))

**Page layout formats**

-   [InDesign ICML](http://wwwimages.adobe.com/content/dam/acom/en/devnet/indesign/sdk/cs6/idml/idml-specification.pdf)

**Wiki markup formats**

-   [MediaWiki markup](http://www.mediawiki.org/wiki/Help:Formatting)

-   [DokuWiki markup](https://www.dokuwiki.org/wiki:syntax)

-   [XWiki markup](https://www.xwiki.org/xwiki/bin/view/Documentation/UserGuide/Features/XWikiSyntax/)

-   [ZimWiki markup](http://zim-wiki.org/manual/Help/Wiki_Syntax.html)

-   [Jira wiki markup](https://jira.atlassian.com/secure/WikiRendererHelpAction.jspa?section=all)

**Slide show formats**

-   [LaTeX Beamer](https://ctan.org/pkg/beamer)

-   [Slidy](http://www.w3.org/Talks/Tools/Slidy)

-   [reveal.js](http://lab.hakim.se/reveal-js/)

-   [Slideous](http://goessner.net/articles/slideous/)

-   [S5](http://meyerweb.com/eric/tools/s5/)

-   [DZSlides](http://paulrouget.com/dzslides/)

**Custom formats**

-   Custom writers can be written in [lua](http://www.lua.org/).

**PDF**

-   via `pdflatex`, `lualatex`, `xelatex`, `latexmk`, `tectonic`, `wkhtmltopdf`, `weasyprint`, `prince`, `context`, or `pdfroff`.
