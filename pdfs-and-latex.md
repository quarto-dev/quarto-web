---
title: "PDFs and LaTeX"
format: html
---

Pandoc supports the use of a wide range of TeX distributions and PDF compilation engines including pdflatex, xelatex, lualatex, tectonic, and latexmk.

While you can employ whatever toolchain you like for LaTeX compilation, we strongly recommend the use of [TinyTeX](https://yihui.org/tinytex/), which is a distribution of [TeX Live](https://tug.org/texlive/) that provides a reasonably sized initial download (\~100 MB) that includes the 200 or so most commonly used TeX packages for Pandoc documents.

We also recommend the use of Quarto's built in PDF compilation engine, which among other things performs automatic installation of any missing TeX packages.

## Installing TeX

To install TinyTeX, use the following command:

``` {.bash}
$ quarto install tinytex
```

If you prefer TeX Live, you can find instructions for installing it here: <https://tug.org/texlive/>.

Note that Quarto's automatic installation of missing TeX packages will work for TinyTeX and TeX Live, but not for other TeX distributions (as it relies on TeX Live's [tlmgr](https://www.tug.org/texlive/tlmgr.html) command).

## LaTeX Packages

When creating a PDF document, Pandoc allows the use of [raw LaTeX](https://pandoc.org/MANUAL.html#extension-raw_tex) directives intermixed with markdown. In some cases this LaTeX will require additional LaTeX packages. To add these packages to your document, use the `header-includes` YAML option. For example:

``` {.yaml}
title: "My Document"
format:
  pdf:
    header-includes: |
      \usepackage{fontawesome}
      \usepackage{sansmath}
```

Note the use of the `|` character on the line with `header-includes` to indicate that the value is a multi-line string.

If you don't already have these packages installed locally, then Quarto will automatically install them during rendering of the document.

## Quarto PDF Engine

Quarto's built-in PDF compilation engine handles running LaTeX multiple times to resolve index and bibliography entries, and also performs automatic LaTeX package installation. This section describes customizing the built-in engine (see the [Alternate PDF Engines](#alternate-pdf-engines) section below for docs on using other engines).

### PDF Compilation

The following options are available for customizing PDF compilation:

| Option                 | Description                                                         |
|------------------------|---------------------------------------------------------------------|
| `latex-min-runs`       | Number (minimum number of compilation passes)                       |
| `latex-max-runs`       | Number (maximum number of compilation passes)                       |
| `latex-clean`          | Boolean (clean intermediates after compilation, defaults to `true`) |
| `latex-output-dir`     | String (output directory for intermediates and PDF)                 |
| `latex-makeindex`      | String (program to use for `makeindex`)                             |
| `latex-makeindex-opts` | Array (options for `makeindex`program)                              |

### Package Installation

The following options are available for customizing automatic package installation:

| Option               | Description                                                         |
|----------------------|---------------------------------------------------------------------|
| `latex-auto-install` | Boolean (enable/disable automatic package installation)             |
| `latex-tlmgr-opts`   | Array (options for [tlmgr](https://www.tug.org/texlive/tlmgr.html)) |

## Alternate PDF Engines {#alternate-pdf-engines}

To disable Quarto's built in PDF engine, set the `latex-auto-mk` option to `false`:

``` {.yaml}
title: "My Document"
latex-auto-mk: false
```

The above configuration will result in Pandoc's default behavior for PDF compilation (`pdf-engine: pdflatex` ). You can then use the `pdf-engine` and `pdf-engine-opts` to further customize Pandoc compilation. For example:

``` {.yaml}
title: "My Document"
latex-auto-mk: false
pdf-engine: xelatex
pdf-engine-opt: -outdir=out
```
