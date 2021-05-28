---
title: More Formats
format: html
---

## Overview

Pandoc support a huge array of output formats, all of which can be used with Quarto. Here is a list of the currently supported formats:

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

## Using Formats

Any of the formats can be used with Quarto via the `format` YAML option or the `--to` command-line option. For example, here's some YAML that specifies the use of the `odt` format:

``` {.yaml}
---
title: "My Document"
format: odt
---
```

Alternatively you can specify the use of a format on the command line:

``` {.bash}
$ quarto render document.md --to odt
```

To learn more about using all of Pandoc's formats, see the [Pandoc User Guide](https://pandoc.org/MANUAL.html).

## Format Names

Here's a list of all the currently supported format names:

-   asciidoc

-   asciidoctor

-   beamer

-   commonmark

-   commonmark_x

-   context

-   csljson

-   docbook

-   docbook4

-   docbook5

-   docx

-   dokuwiki

-   dzslides

-   epub

-   epub2

-   epub3

-   fb2

-   gfm

-   haddock

-   html

-   html4

-   html5

-   icml

-   ipynb

-   jats

-   jats_archiving

-   jats_articleauthoring

-   jats_publishing

-   jira

-   json

-   latex

-   man

-   markdown

-   markdown_github

-   markdown_mmd

-   markdown_phpextra

-   markdown_strict

-   mediawiki

-   ms

-   muse

-   native

-   odt

-   opendocument

-   opml

-   org

-   pdf

-   plain

-   pptx

-   revealjs

-   rst

-   rtf

-   s5

-   slideous

-   slidy

-   tei

-   texinfo

-   textile

-   xwiki

-   zimwik
