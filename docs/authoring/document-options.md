---
title: Document Options
format: html
---

Quarto supports a number of global document options that allow you to customize how documents are rendered (e.g. section numbering, table of contents, etc.). This article summarizes those options.

## Format

The most important option is the format to render to (e.g. HTML, PDF, etc.). This is specified using the `format` key. For example:

``` {.yaml}
format: pdf
```

You can also specify more than one format, as well as options that apply to only a given format. For example, here we specify global `toc` options alongside some format-specific options:

``` {.yaml}
toc: true
toc-depth: 2
format:
  html:
    html-math-method: katex
  pdf:
    documentclass: report
```

## Table of Contents

toc

toc-depth

## Section Numbering

number-sections

## Syntax Highlighting

## Includes
