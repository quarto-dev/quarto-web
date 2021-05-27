---
title: Markdown Basics
format: html
---

## Overview

Quarto is based on Pandoc and uses it's variation of markdown as it's underlying document syntax. Pandoc markdown is an extended and slightly revised version of John Gruber's [Markdown](https://daringfireball.net/projects/markdown/) syntax.

Markdown is a plain text format that is designed to be easy to write, and, even more importantly, easy to read:

> A Markdown-formatted document should be publishable as-is, as plain text, without looking like it's been marked up with tags or formatting instructions. -- [John Gruber](https://daringfireball.net/projects/markdown/syntax#philosophy)

This document provides a high-level summary of the most commonly used markdown syntax. See the full documentation of [Pandoc's Markdown](https://pandoc.org/MANUAL.html#pandocs-markdown) for more in-depth documentation.

## Text Formatting

+-----------------------------------+-------------------------------+
| Markdown Syntax                   | Output                        |
+===================================+===============================+
|     *italics* and **bold**        | *italics* and **bold**        |
+-----------------------------------+-------------------------------+
|     superscript^2^ / subscript~2~ | superscript^2^ / subscript~2~ |
+-----------------------------------+-------------------------------+
|     ~~strikethrough~~             | ~~strikethrough~~             |
+-----------------------------------+-------------------------------+
|     `verbatim code`               | `verbatim code`               |
+-----------------------------------+-------------------------------+

## Headings

+-----------------------------------+------------------------------+
| Markdown Syntax                   | Output                       |
+===================================+==============================+
|     # Header 1                    | # Header 1                   |
+-----------------------------------+------------------------------+
|     ## Header 2                   | ## Header 2                  |
+-----------------------------------+------------------------------+
|     ### Header 3                  | ### Header 3                 |
+-----------------------------------+------------------------------+
|     #### Header 4                 | Header 4                     |
+-----------------------------------+------------------------------+
|     ##### Header 5                | ##### Header 5               |
+-----------------------------------+------------------------------+
|     ###### Header 6               | ###### Header 6              |
+-----------------------------------+------------------------------+

## Links & Images

+---------------------------------------------------------------+-----------------------------------------------------------+
| Markdown Syntax                                               | Output                                                    |
+===============================================================+===========================================================+
|     [link](https://www.quarto.org)                            | [link](https://www.quarto.org)                            |
+---------------------------------------------------------------+-----------------------------------------------------------+
|     ![Caption](images/elephant.png)                           | ![Caption](images/elephant.png)                           |
+---------------------------------------------------------------+-----------------------------------------------------------+
|     [![Caption](images/elephant.png)](https://www.quarto.org) | [![Caption](images/elephant.png)](https://www.quarto.org) |
+---------------------------------------------------------------+-----------------------------------------------------------+

## Lists

+-------------------------------------+---------------------------------+
| Markdown Syntax                     | Output                          |
+=====================================+=================================+
|     * unordered list                | -   unordered list              |
|         + sub-item 1                |                                 |
|         + sub-item 2                |     -   sub-item 1              |
|             - sub-sub-item 1        |                                 |
|                                     |     -   sub-item 2              |
|                                     |                                 |
|                                     |         -   sub-sub-item 1      |
+-------------------------------------+---------------------------------+
|     * item 2                        | -   item 2                      |
|                                     |                                 |
|         Continued (indent 4 spaces) |     Continued (indent 4 spaces) |
+-------------------------------------+---------------------------------+
|     1. ordered list                 | 1.  ordered list                |
|     2. item 2                       |                                 |
|         i) sub-item 1               | 2.  item 2                      |
|              A.  sub-sub-item 1     |                                 |
|                                     |     i)  sub-item 1              |
|                                     |                                 |
|                                     |         A.  sub-sub-item 1      |
+-------------------------------------+---------------------------------+
|     (@)  A list whose numbering     | (1) A list whose numbering      |
|                                     |                                 |
|     continues after                 | continues after                 |
|                                     |                                 |
|     (@)  an interruption            | (2) an interruption             |
+-------------------------------------+---------------------------------+
|     term                            | term                            |
|     : definition                    |                                 |
|                                     | :   definition                  |
+-------------------------------------+---------------------------------+

## Tables

#### Markdown Syntax

    | Right | Left | Default | Center |
    |------:|:-----|---------|:------:|
    |   12  |  12  |    12   |    12  |
    |  123  |  123 |   123   |   123  |
    |    1  |    1 |     1   |     1  |

#### Output

+----------+----------+---------+------------+
| Right    | Left     | Default | Center     |
+=========:+:=========+=========+:==========:+
| 12       | 12       | 12      | 12         |
+----------+----------+---------+------------+
| 123      | 123      | 123     | 123        |
+----------+----------+---------+------------+
| 1        | 1        | 1       | 1          |
+----------+----------+---------+------------+

## Equations

+----------------------------------+--------------------------------+
| Markdown Syntax                  | Output                         |
+==================================+================================+
|     inline math: $E = mc^{2}$    | inline math: $E=mc^{2}$        |
+----------------------------------+--------------------------------+
|     display math: $$E = mc^{2}$$ | display math: $$E = mc^{2}$$   |
+----------------------------------+--------------------------------+

## Special Blocks

+---------------------------------+--------------------------------+
| Markdown Syntax                 | Output                         |
+=================================+================================+
|     > Blockquote                | > Blockquote                   |
+---------------------------------+--------------------------------+
|     :::{.classname}             | ::: {.classname}               |
|     Div                         | Div                            |
|     :::                         | :::                            |
+---------------------------------+--------------------------------+
|     |    Line Block             | |    Line Block                |
|     | Line Block                | | Line Block                   |
+---------------------------------+--------------------------------+

### Special Characters

+---------------------------------+---------------------------------+
| Markdown Syntax                 | Output                          |
+=================================+=================================+
|     endash: --                  | endash: --                      |
+---------------------------------+---------------------------------+
|     emdash: ---                 | emdash: ---                     |
+---------------------------------+---------------------------------+
