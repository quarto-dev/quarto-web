---
title: "Quarto Accessibility Conformance Report"
subtitle: "International Edition"
toc: true
repo-actions: false
search: false
other-links:
  - text: PDF
    href: quarto-1.11.6-ACR.pdf
    icon: file-pdf
resources:
  - quarto-1.11.6-ACR.pdf
---
<!-- Generated from quarto-dev/quarto-acr (a private repository in
the quarto-dev organization) at 550860d168d2162cc5f6b59669e730a45ac63c4a on 2026-11-02. Do not edit this
file. Edits here are lost at the next export. Make changes in
quarto-dev/quarto-acr. -->

::: {#acr-based-on}
(Based on VPAT® Version 2.5Rev)^["Voluntary Product Accessibility Template" and "VPAT" are registered service marks of the Information Technology Industry Council (ITI).]

:::

**Name of Product/Version:** Quarto 1.11.6

**Report Date:** November 2026

**Product Description:** Quarto is an open-source scientific and technical publishing system.
Authors write in markdown or notebooks; Quarto renders to HTML, PDF, and
other formats.

**Contact Information:** accessibility@posit.co

## Notes

This is a single report covering many aspects of Quarto. 
We map the aspects covered in the WCAG tables as follows:

- **Software** — the Quarto command-line interface's own user interface.
- **Web** — the documentation for Quarto hosted at [quarto.org](https://quarto.org). 
- **Authoring Tool** — the rendered output from Quarto's default templates. 

The Section 508 and EN 301 549 tables may cover any or all of these aspects.
We make clear which aspects are covered in the table notes, or remarks for each row.

The following aspects are **Not applicable** and omitted:

- **Electronic Docs**: Quarto's primary documentation is [quarto.org](https://quarto.org), covered under **Web** above. Some non-web files, notably `.qmd` files, but also `.css`, `.scss`, and `.yml` files, are shipped with the Quarto CLI as templates, and/or are downloadable from [quarto.org](https://quarto.org). These are plain text files we treat as source code and do not assess in this report. We evaluate their rendered form under **Authoring Tool**.
- **Closed**: the command-line interface is open-functionality software operated in the user's own terminal with their own assistive technology.

## Evaluation Methods Used

### Software

We evaluated the Quarto command-line interface (CLI) at version
1.11.6 on 2026-10-19 and 2026-10-20.

#### Scope

The assessment covers what the CLI itself writes to the terminal
and asks of the user: its messages, prompts, progress reporting,
and help. How that text looks is set by the user's terminal
application: font, size, zoom, wrapping, colour theme, contrast,
cursor, and window title. The same terminal exposes the text to
assistive technology. For criteria about presentation, we report
the CLI as Supports, since all it emits is text and palette
indices. The CLI creates no user interface components of its own.

We evaluated the CLI in two passes. First, we inspected the CLI's
source and output to find out what it writes and when. Second, we
used the CLI with a screen reader and the keyboard only, to find
out what a user can do and what they hear.

#### Inspection

We read the CLI's source at the `v1.11.6` tag to establish most criteria:
how warnings and errors are marked, how
colour is applied and switched off (`NO_COLOR`), which interactive
prompts exist, how the progress spinner works, which URLs are
printed, and whether any time limits or window-title changes
exist. Separately, we captured the output of help, render, render
with errors, check, and preview with and without `NO_COLOR`, and
compared the two sets after stripping terminal escape codes, to
confirm that the text is the same whether or not colour is on.

#### Manual testing

We ran a keyboard-only session with VoiceOver, in Terminal.app
(Terminal 2.15, One Light profile, 80 by 24 characters, zsh) on
macOS 27.0, with VoiceOver verbosity set to High and Reduce Motion
off. The session had five tests on a small fixture project,
covering the main ways the CLI asks something of the user or
reports back:

* Interactive prompts: `quarto create project` (list, text, and
  confirmation prompts), `quarto add` (confirmation and spinner),
  and `quarto remove` (checkbox), including leaving a prompt.
* Errors: a mistyped command, a missing input file, and a YAML
  validation error, then the same three without colour.
* Progress: `quarto render` of a two-page site, `quarto check`,
  and `quarto check --quiet`.
* Preview: `quarto preview`, a file edit that triggers a
  re-render, and stopping the server.
* Help: `quarto --help` and `quarto render --help`, and the same
  in a 60-column window.

### Web

We evaluated the documentation website, [quarto.org](https://quarto.org),
with automated and manual tests between 2026-10-13 and
2026-10-16. The site was built with Quarto 1.11.6.

#### Scope

The assessment covers the pages of quarto.org, the documentation
site for Quarto. We excluded four kinds of content:

* **Revealjs presentations.** The site hosts example slide decks
  in Quarto's revealjs format. They are example output of a
  different format, which this report does not assess.
* **Third-party components.** Some documentation pages embed
  components from other projects to show how Quarto works with
  them: Observable Inputs and Observable Plot, Leaflet maps,
  dygraphs charts, Vega-Lite charts (vega-embed), and the Arquero table
  viewer. Quarto includes the Observable
  libraries in its OJS support, but other projects develop and
  maintain them all. We assessed the page around each component,
  but not the component itself.
* **The YouTube player's controls.** The site's tutorial videos
  play in an embedded YouTube player. Clause 7 covers its caption
  functions. We did not assess its own controls, beyond confirming
  that keyboard focus can leave it.
* **Example videos.** Videos shown only as examples of embedding
  a video.

We used three sources: an automated scan that covers every page;
manual tests on a sample of pages; and
[issues from quarto-cli](https://github.com/quarto-dev/quarto-cli)
that apply to the site.

#### Automated testing

The site runs a weekly axe-core scan of every page, at desktop
(1440px) and mobile (320px) widths and in the light and dark
colour schemes. The results in this report come from the scan of
2026-10-16 (axe-core 4.10.3, 372 pages, run 38970016556 of the
quarto-web "Axe Report" workflow). The results of the latest scan
are published at
<https://quarto.org/accessibility/site-report.html>.

The scan skips the tool-chooser redirect pages under
`docs/get-started/` and `docs/manuscripts/authoring/`; the pages
they redirect to are scanned.

#### Manual testing

We ran the manual tests in Safari 27.0 on macOS 27.0, with
VoiceOver for the screen reader pass and
[TPGi's Colour Contrast Analyser](https://www.tpgi.com/color-contrast-checker/)
3.5.5 for contrast. We chose five sample pages to cover the site's
page types:

* the home page, `index.html`
* a long documentation page, `docs/authoring/markdown-basics.html`
* a reference page, `docs/reference/formats/html.html`
* the gallery listing, `docs/gallery/index.html`
* a tutorial page with an embedded video,
  `docs/get-started/hello/rstudio.html`

On each sample page, we:

* navigated with the keyboard only, at 1280px and 320px wide
* read the page with VoiceOver
* viewed the page at 320px wide, at 200% page zoom and 200%
  text-only zoom, with text spacing overrides applied, and in
  both orientations
* measured the contrast of controls, focus indicators, icons,
  and state cues in the light and dark colour schemes

We also tested the whole site, or the pages that have a specific
component. We:

* used the site search from the keyboard and with VoiceOver, at
  1280px and 320px wide
* used the footnote, citation, cross-reference and
  code-annotation popups and tooltips, on the pages that have
  them
* opened tabsets and collapsed callouts from the keyboard, on
  the pages that have them
* checked the markup of all pages for video, animation, and
  animated images; for consistent navigation and help; for the
  ways to find a page; and for target size and spacing

### Authoring Tool

We evaluated Quarto's HTML output at version 1.11.6 between
2026-10-16 and 2026-10-20, on a small corpus of rendered examples.

#### Scope

The assessment covers one of Quarto's output formats, `format:
html`, as standalone documents and as websites.
This report does not assess other output formats.

Quarto is responsible for what it adds to the page and how it
carries the author's content into the output. The author is
responsible for the accessibility of the content itself: the text, links,
and images they write, any raw HTML or JavaScript they add, and
the figures, tables, and widgets their code cells produce.

The corpus is four configurations rendered from one source
document. The document uses the core features of a Quarto HTML
document with their default options: headings, images with
alternative text, a code block, inline and display math, a
tabset, callouts, a footnote, a citation, cross-references, a
table, and a margin note. The four configurations are:

* a standalone document (`format: html`) with a table of
  contents and code tools
* the website scaffold from `quarto create project website`,
  with that page added
* the blog scaffold from `quarto create project blog`, with
  alternative text and link names added where the scaffold
  has none
* the website scaffold with a sidebar that has a collapsible
  section, and the search in the sidebar

The standalone document and the sidebar website use Bootstrap's
default theme; the two scaffolds keep their cosmo theme.

We used five sources: an automated scan of the corpus;
an inspection of the rendered corpus pages;
manual tests on two corpus pages;
the quarto.org findings; and the
quarto-cli issue tracker.

#### Automated testing

We scanned every corpus page with axe-core 4.10.3 on 2026-10-16,
at desktop (1440px) and mobile (320px) widths. The corpus has 11
pages.

#### Inspection

We inspected the rendered corpus pages in a headless browser on
2026-10-20, and recorded:

* the markup of landmarks, headings, tables, tabsets, callouts,
  footnotes, and search
* the computed colours and contrast ratios of current-item cues
  and focus indicators
* reflow at 320px wide and at the layout width of 200% zoom
* text-spacing overrides and doubled font sizes
* a short landscape viewport with the sidebar open
* the keyboard stops of each page

#### Manual testing

We ran the manual tests on 2026-10-20 in Safari 27.0.1 on macOS
27.0, with VoiceOver for the screen reader pass and
[TPGi's Colour Contrast Analyser](https://www.tpgi.com/color-contrast-checker/)
3.5.5 for contrast. We tested two corpus pages: the standalone
document, and the same page inside the sidebar website. On each
page, we:

* navigated with the keyboard only, at 1280px and 320px wide
* read the page with VoiceOver
* measured the contrast of the current-item cues, focus
  indicators, and text, to check the values computed in the
  inspection

#### quarto.org findings

The documentation site, quarto.org, is a Quarto website built with
1.11.6, and we assessed it on its own under [Web](#web). We include
a result from that assessment, pass or fail, in this aspect when it
comes from Quarto's own markup, styles, or scripts, and leave out
results that come from the site's content. For results that depend
on a theme (contrast, focus indicators, colour cues), we use the
corpus only.

## Applicable Standards/Guidelines

This report covers the degree of conformance for the following accessibility standard/guidelines:

```{=html}
<table class="table acr-table">
<colgroup>
<col style="width: 65%">
<col style="width: 35%">
</colgroup>
<thead>
<tr>
<th scope="col">Standard/Guideline</th>
<th scope="col">Included In Report</th>
</tr>
</thead>
<tbody>
<tr>
<th scope="row"><a href="https://www.w3.org/TR/WCAG22/">Web Content Accessibility Guidelines 2.2</a></th>
<td>Level A (Yes)<br>Level AA (Yes)<br>Level AAA (No)</td>
</tr>
<tr>
<th scope="row"><a href="https://www.access-board.gov/ict/">Revised Section 508 standards published January 18, 2017 and corrected January 22, 2018</a></th>
<td>(Yes)</td>
</tr>
<tr>
<th scope="row"><a href="https://www.etsi.org/deliver/etsi_en/301500_301599/301549/03.01.01_60/en_301549v030101p.pdf">EN 301 549 Accessibility requirements for ICT products and services - V3.1.1 (2019-11)</a> <em>AND</em> <a href="https://www.etsi.org/deliver/etsi_en/301500_301599/301549/03.02.01_60/en_301549v030201p.pdf">EN 301 549 Accessibility requirements for ICT products and services - V3.2.1 (2021-03)</a></th>
<td>(Yes)</td>
</tr>
</tbody>
</table>
```

## Terms

The terms used in the Conformance Level information are defined as follows:

- **Supports**: The functionality of the product has at least one method that meets the criterion without known defects or meets with equivalent facilitation.
- **Partially Supports**: Some functionality of the product does not meet the criterion.
- **Does Not Support**: The majority of product functionality does not meet the criterion.
- **Not Applicable**: The criterion is not relevant to the product.
- **Not Evaluated**: The product has not been evaluated against the criterion. This can be used only in WCAG Level AAA criteria.

## WCAG 2.2 Report {#wcag-report}

Tables 1 and 2 also document conformance with:

- EN 301 549:
  - Clause 9 - Web
  - Clauses 10.1-10.4 of Clause 10 - Non-Web documents
  - Clauses 11.1-11.4 and 11.8.2 of Clause 11 - Software
  - Clauses 12.1.2 and 12.2.4 of Clause 12 - Documentation and support
    services
- Revised Section 508:
  - Chapter 5 - 501.1 Scope and 504.2 Content Creation or Editing
  - Chapter 6 - 602.3 Electronic Support Documentation

Note: When reporting on conformance with the WCAG 2.2 Success
Criteria, they are scoped for full pages, complete processes, and
accessibility-supported ways of using technology as documented in the
[WCAG 2.2 Conformance Requirements](https://www.w3.org/TR/WCAG22/#conformance-reqs).

### Table 1: Success Criteria, Level A {#acr-tbl-wcag-a}

::: {.column-page}

```{=html}
<table class="table acr-table acr-criteria" aria-labelledby="acr-tbl-wcag-a">
<colgroup>
<col style="width: 25%">
<col style="width: 15%">
<col style="width: 60%">
</colgroup>
<thead>
<tr>
<th scope="col">Criteria</th>
<th scope="col">Conformance Level</th>
<th scope="col">Remarks and Explanations</th>
</tr>
</thead>
<tbody>
<tr>
<th scope="row"><div id="acr-1.1.1" class="acr-criterion"><a href="https://www.w3.org/TR/WCAG22/#non-text-content">1.1.1 Non-text Content</a> (Level A)</div>
<div class="acr-also-applies">Also applies to:</div>
<p>EN 301 549 Criteria</p>
<ul>
<li>9.1.1.1 (Web)</li>
<li>10.1.1.1 (Non-web document)</li>
<li>11.1.1.1.1 (Open Functionality Software)</li>
<li>11.1.1.1.2 (Closed Functionality Software)</li>
<li>11.8.2 (Authoring Tool)</li>
<li>12.1.2 (Product Docs)</li>
<li>12.2.4 (Support Docs)</li>
</ul>
<p>Revised Section 508</p>
<ul>
<li>501 (Web)(Software)</li>
<li>504.2 (Authoring Tool)</li>
<li>602.3 (Support Docs)</li>
</ul></th>
<td><p><strong>Software:</strong> Partially Supports</p>
<p><strong>Web:</strong> Partially Supports</p>
<p><strong>Authoring Tool:</strong> Partially Supports</p></td>
<td><div data-qmd="**Software:** The CLI's markers are text characters, followed by text
that explains the meaning: `[✓]` before a completed step's message,
`✖` and `ℹ` before the sentences of a validation error, the
spinner frames before the step in progress.

Known defects:

- In the checkbox prompt of `quarto remove`, an item's state is
  shown by a `✔` or `✘` glyph alone, and a screen reader speaks
  the first but not the second, so an unchecked item is heard with
  no state.

**Web:** Images on the sample pages have accurate text alternatives, and
decorative icons are hidden from assistive technology.

Known defects:

- The home page hero animation is decorative but is not hidden,
  so screen readers announce a series of unnamed images.
- Images made by the `placeholder` shortcode have no `alt`
  attribute ([quarto-dev/quarto-cli#14769](https://github.com/quarto-dev/quarto-cli/issues/14769)).

The Markdown Basics page shows two images without alt text on
purpose, as examples of that output; the automated scan reports
them.

**Authoring Tool:** Author-supplied alternative text (`fig-alt`, `alt`) appears in the
output for images and figures, equations are spoken by screen
readers, and decorative icons are hidden from assistive
technology.

Known defects:

- Images made by the `placeholder` shortcode have no `alt`
  attribute ([quarto-dev/quarto-cli#14769](https://github.com/quarto-dev/quarto-cli/issues/14769)).
- A listing shows a placeholder image with no alternative text
  when a post has none ([quarto-dev/quarto-cli#7028](https://github.com/quarto-dev/quarto-cli/issues/7028)).
- The blog project template ships an image without alternative
  text on its about page and in a post
  ([quarto-dev/quarto-cli#15038](https://github.com/quarto-dev/quarto-cli/issues/15038))."></div></td>
</tr>
<tr>
<th scope="row"><div id="acr-1.2.1" class="acr-criterion"><a href="https://www.w3.org/TR/WCAG22/#audio-only-and-video-only-prerecorded">1.2.1 Audio-only and Video-only (Prerecorded)</a> (Level A)</div>
<div class="acr-also-applies">Also applies to:</div>
<p>EN 301 549 Criteria</p>
<ul>
<li>9.1.2.1 (Web)</li>
<li>10.1.2.1 (Non-web document)</li>
<li>11.1.2.1.1 (Open Functionality Software)</li>
<li>11.1.2.1.2.1 and 11.1.2.1.2.2 (Closed Software)</li>
<li>11.8.2 (Authoring Tool)</li>
<li>12.1.2 (Product Docs)</li>
<li>12.2.4 (Support Docs)</li>
</ul>
<p>Revised Section 508</p>
<ul>
<li>501 (Web)(Software)</li>
<li>504.2 (Authoring Tool)</li>
<li>602.3 (Support Docs)</li>
</ul></th>
<td><p><strong>Software:</strong> Supports</p>
<p><strong>Web:</strong> Supports</p>
<p><strong>Authoring Tool:</strong> Supports</p></td>
<td><div data-qmd="**Software:** The CLI presents no audio or video.

**Web:** The only prerecorded video-only media are animated GIFs of editor
demos. Each has alt text, and the surrounding text describes the
feature it shows.

**Authoring Tool:** Default output has no audio-only or video-only content. The `video` shortcode embeds a video; the text alternative is prose the author writes beside it."></div></td>
</tr>
<tr>
<th scope="row"><div id="acr-1.2.2" class="acr-criterion"><a href="https://www.w3.org/TR/WCAG22/#captions-prerecorded">1.2.2 Captions (Prerecorded)</a> (Level A)</div>
<div class="acr-also-applies">Also applies to:</div>
<p>EN 301 549 Criteria</p>
<ul>
<li>9.1.2.2 (Web)</li>
<li>10.1.2.2 (Non-web document)</li>
<li>11.1.2.2 (Open Functionality Software)</li>
<li>11.1.2.2 (Closed Software)</li>
<li>11.8.2 (Authoring Tool)</li>
<li>12.1.2 (Product Docs)</li>
<li>12.2.4 (Support Docs)</li>
</ul>
<p>Revised Section 508</p>
<ul>
<li>501 (Web)(Software)</li>
<li>504.2 (Authoring Tool)</li>
<li>602.3 (Support Docs)</li>
</ul></th>
<td><p><strong>Software:</strong> Supports</p>
<p><strong>Web:</strong> Partially Supports</p>
<p><strong>Authoring Tool:</strong> Partially Supports</p></td>
<td><div data-qmd="**Software:** The CLI presents no audio or video.

**Web:** The site offers two tutorial videos. Posit's &quot;Get Started with
Quarto&quot; video on the RStudio tutorial page has uploaded English
captions that match the speech.

Known defects:

- The video on the Neovim tutorial page, from a third-party
  channel, has only automatically generated captions, which
  mistranscribe &quot;Quarto&quot; in several ways.

**Authoring Tool:** The `video` shortcode embeds hosted videos (YouTube, Vimeo,
Brightcove) in the host's own player, which shows the captions the
host provides.

Known defects:

- For a local video file it emits a player with no way to attach a
  caption track, so captions cannot be added without leaving the
  shortcode."></div></td>
</tr>
<tr>
<th scope="row"><div id="acr-1.2.3" class="acr-criterion"><a href="https://www.w3.org/TR/WCAG22/#audio-description-or-media-alternative-prerecorded">1.2.3 Audio Description or Media Alternative (Prerecorded)</a> (Level A)</div>
<div class="acr-also-applies">Also applies to:</div>
<p>EN 301 549 Criteria</p>
<ul>
<li>9.1.2.3 (Web)</li>
<li>10.1.2.3 (Non-web document)</li>
<li>11.1.2.3.1 (Open Functionality Software)</li>
<li>11.1.2.3.2 (Closed Software)</li>
<li>11.8.2 (Authoring Tool)</li>
<li>12.1.2 (Product Docs)</li>
<li>12.2.4 (Support Docs)</li>
</ul>
<p>Revised Section 508</p>
<ul>
<li>501 (Web)(Software)</li>
<li>504.2 (Authoring Tool)</li>
<li>602.3 (Support Docs)</li>
</ul></th>
<td><p><strong>Software:</strong> Supports</p>
<p><strong>Web:</strong> Does Not Support</p>
<p><strong>Authoring Tool:</strong> Partially Supports</p></td>
<td><div data-qmd="**Software:** The CLI presents no audio or video.

**Web:** The site offers two tutorial videos.

Known defects:

- Neither has an audio description, and neither page presents its
  text as an alternative for the video. Both videos show actions
  on screen that the narration does not name.

**Authoring Tool:** Hosted players play an audio description track if the host
provides one.

Known defects:

- For a local video file the `video` shortcode offers no
  audio-description track and no link to a media alternative; an
  author can only describe the video in the surrounding text."></div></td>
</tr>
<tr>
<th scope="row"><div id="acr-1.3.1" class="acr-criterion"><a href="https://www.w3.org/TR/WCAG22/#info-and-relationships">1.3.1 Info and Relationships</a> (Level A)</div>
<div class="acr-also-applies">Also applies to:</div>
<p>EN 301 549 Criteria</p>
<ul>
<li>9.1.3.1 (Web)</li>
<li>10.1.3.1 (Non-web document)</li>
<li>11.1.3.1.1 (Open Functionality Software)</li>
<li>11.1.3.1.2 (Closed Software)</li>
<li>11.8.2 (Authoring Tool)</li>
<li>12.1.2 (Product Docs)</li>
<li>12.2.4 (Support Docs)</li>
</ul>
<p>Revised Section 508</p>
<ul>
<li>501 (Web)(Software)</li>
<li>504.2 (Authoring Tool)</li>
<li>602.3 (Support Docs)</li>
</ul></th>
<td><p><strong>Software:</strong> Supports</p>
<p><strong>Web:</strong> Partially Supports</p>
<p><strong>Authoring Tool:</strong> Partially Supports</p></td>
<td><div data-qmd="**Software:** A text stream has no heading or table markup. Help output marks sections (`Usage`, `Options`, `Commands`) with a colon, a blank line, and indentation, and each entry reads in order as name, arguments, description.

**Web:** Landmarks, headings, lists, and tables are exposed to assistive
technology on the sample pages.

Known defects:

- The `kbd` shortcode with only operating-system keyword arguments
  gives screen readers no text for the shortcut
  ([quarto-dev/quarto-cli#15065](https://github.com/quarto-dev/quarto-cli/issues/15065)).
- Margin citations keep `role=&quot;listitem&quot;` after their list parent
  is removed ([quarto-dev/quarto-cli#14755](https://github.com/quarto-dev/quarto-cli/issues/14755)).
- The previous and next page links at the foot of each page are
  named by the target page title alone, so a screen reader does
  not say which link goes back and which goes forward
  ([quarto-dev/quarto-cli#14804](https://github.com/quarto-dev/quarto-cli/issues/14804)).

**Authoring Tool:** Landmarks, headings, lists, tables, footnotes, and citations are
exposed with their roles, and alternative text, table captions,
and header cells appear in the output.

Known defects, each in an optional feature:

- The `kbd` shortcode with only operating-system keyword arguments
  gives screen readers no text for the shortcut
  ([quarto-dev/quarto-cli#15065](https://github.com/quarto-dev/quarto-cli/issues/15065)).
- Margin citations keep `role=&quot;listitem&quot;` after their list parent
  is removed ([quarto-dev/quarto-cli#14755](https://github.com/quarto-dev/quarto-cli/issues/14755)).
- Page navigation links are named by the target page title alone,
  so a screen reader does not say which link goes back and which
  forward ([quarto-dev/quarto-cli#14804](https://github.com/quarto-dev/quarto-cli/issues/14804))."></div></td>
</tr>
<tr>
<th scope="row"><div id="acr-1.3.2" class="acr-criterion"><a href="https://www.w3.org/TR/WCAG22/#meaningful-sequence">1.3.2 Meaningful Sequence</a> (Level A)</div>
<div class="acr-also-applies">Also applies to:</div>
<p>EN 301 549 Criteria</p>
<ul>
<li>9.1.3.2 (Web)</li>
<li>10.1.3.2 (Non-web document)</li>
<li>11.1.3.2.1 (Open Functionality Software)</li>
<li>11.1.3.2.2 (Closed Software)</li>
<li>11.8.2 (Authoring Tool)</li>
<li>12.1.2 (Product Docs)</li>
<li>12.2.4 (Support Docs)</li>
</ul>
<p>Revised Section 508</p>
<ul>
<li>501 (Web)(Software)</li>
<li>504.2 (Authoring Tool)</li>
<li>602.3 (Support Docs)</li>
</ul></th>
<td><p><strong>Software:</strong> Supports</p>
<p><strong>Web:</strong> Partially Supports</p>
<p><strong>Authoring Tool:</strong> Partially Supports</p></td>
<td><div data-qmd="**Software:** Output is a single sequence of lines in the order they are written.

**Web:** Page content reads in a meaningful order on the sample pages.

Known defects:

- The screen-reader text of the `kbd` shortcode comes after the
  sentence that contains the shortcut, not where the shortcut is
  ([quarto-dev/quarto-cli#15065](https://github.com/quarto-dev/quarto-cli/issues/15065)).

**Authoring Tool:** Content reads in source order, and a margin note is read after
the paragraph it belongs to.

Known defects:

- The screen-reader text of the `kbd` shortcode comes after the
  sentence that contains the shortcut, not where the shortcut is
  ([quarto-dev/quarto-cli#15065](https://github.com/quarto-dev/quarto-cli/issues/15065))."></div></td>
</tr>
<tr>
<th scope="row"><div id="acr-1.3.3" class="acr-criterion"><a href="https://www.w3.org/TR/WCAG22/#sensory-characteristics">1.3.3 Sensory Characteristics</a> (Level A)</div>
<div class="acr-also-applies">Also applies to:</div>
<p>EN 301 549 Criteria</p>
<ul>
<li>9.1.3.3 (Web)</li>
<li>10.1.3.3 (Non-web document)</li>
<li>11.1.3.3 (Open Functionality Software)</li>
<li>11.1.3.3 (Closed Software)</li>
<li>11.8.2 (Authoring Tool)</li>
<li>12.1.2 (Product Docs)</li>
<li>12.2.4 (Support Docs)</li>
</ul>
<p>Revised Section 508</p>
<ul>
<li>501 (Web)(Software)</li>
<li>504.2 (Authoring Tool)</li>
<li>602.3 (Support Docs)</li>
</ul></th>
<td><p><strong>Software:</strong> Supports</p>
<p><strong>Web:</strong> Supports</p>
<p><strong>Authoring Tool:</strong> Supports</p></td>
<td><div data-qmd="**Software:** Instructions in the CLI name commands, options, and keys. The current item in an interactive prompt is marked with a pointer character (`❯`) as well as colour.

**Authoring Tool:** The author writes the instructions in the content. Quarto's
own interface gives no instructions that rely on shape, position,
or colour alone."></div></td>
</tr>
<tr>
<th scope="row"><div id="acr-1.4.1" class="acr-criterion"><a href="https://www.w3.org/TR/WCAG22/#use-of-color">1.4.1 Use of Color</a> (Level A)</div>
<div class="acr-also-applies">Also applies to:</div>
<p>EN 301 549 Criteria</p>
<ul>
<li>9.1.4.1 (Web)</li>
<li>10.1.4.1 (Non-web document)</li>
<li>11.1.4.1 (Open Functionality Software)</li>
<li>11.1.4.1 (Closed Software)</li>
<li>11.8.2 (Authoring Tool)</li>
<li>12.1.2 (Product Docs)</li>
<li>12.2.4 (Support Docs)</li>
</ul>
<p>Revised Section 508</p>
<ul>
<li>501 (Web)(Software)</li>
<li>504.2 (Authoring Tool)</li>
<li>602.3 (Support Docs)</li>
</ul></th>
<td><p><strong>Software:</strong> Supports</p>
<p><strong>Web:</strong> Partially Supports</p>
<p><strong>Authoring Tool:</strong> Partially Supports</p></td>
<td><div data-qmd="**Software:** Warnings and errors start with a text prefix (`WARN:`, `ERROR:`), not just a colour, and the selected item in an interactive prompt is marked with a pointer character as well as colour. With `NO_COLOR` set, the output text is identical.

**Web:** Links in running text are underlined, and the active table of
contents entry, tab, and tool chooser item have a border or weight
cue as well as a colour change.

Known defects, in the site navigation:

- The sidebar marks the current page by a change of colour alone,
  with no other visual cue.
- The navbar marks the current section by a change of colour
  alone, with no other visual cue.

**Authoring Tool:** The author chooses the colours in the content. Quarto's default
style underlines links in running text, gives the active tab and
the active table-of-contents entry a cue beyond colour, and gives
callout types an icon and a title.

Known defects, in website navigation:

- The sidebar marks the current page by a change of colour alone
  (1.08:1 against the other entries), and the page is not marked
  for assistive technology either.
- The navbar marks the current section by colour alone; in the
  default theme the two colours are both near white (1.00:1), so
  there is no visible cue."></div></td>
</tr>
<tr>
<th scope="row"><div id="acr-1.4.2" class="acr-criterion"><a href="https://www.w3.org/TR/WCAG22/#audio-control">1.4.2 Audio Control</a> (Level A)</div>
<div class="acr-also-applies">Also applies to:</div>
<p>EN 301 549 Criteria</p>
<ul>
<li>9.1.4.2 (Web)</li>
<li>10.1.4.2 (Non-web document)</li>
<li>11.1.4.2 (Open Functionality Software)</li>
<li>11.1.4.2 (Closed Software)</li>
<li>11.8.2 (Authoring Tool)</li>
<li>12.1.2 (Product Docs)</li>
<li>12.2.4 (Support Docs)</li>
</ul>
<p>Revised Section 508</p>
<ul>
<li>501 (Web)(Software)</li>
<li>504.2 (Authoring Tool)</li>
<li>602.3 (Support Docs)</li>
</ul></th>
<td><p><strong>Software:</strong> Supports</p>
<p><strong>Web:</strong> Supports</p>
<p><strong>Authoring Tool:</strong> Supports</p></td>
<td><div data-qmd="**Software:** The CLI plays no audio.

**Web:** No audio on the site plays automatically. The two embedded videos start only when the user presses play.

**Authoring Tool:** Default output plays no audio automatically. The players the `video` shortcode embeds start only when the user presses play."></div></td>
</tr>
<tr>
<th scope="row"><div id="acr-2.1.1" class="acr-criterion"><a href="https://www.w3.org/TR/WCAG22/#keyboard">2.1.1 Keyboard</a> (Level A)</div>
<div class="acr-also-applies">Also applies to:</div>
<p>EN 301 549 Criteria</p>
<ul>
<li>9.2.1.1 (Web)</li>
<li>10.2.1.1 (Non-web document)</li>
<li>11.2.1.1.1 (Open Functionality Software)</li>
<li>11.2.1.1.2 (Closed Software)</li>
<li>11.8.2 (Authoring Tool)</li>
<li>12.1.2 (Product Docs)</li>
<li>12.2.4 (Support Docs)</li>
</ul>
<p>Revised Section 508</p>
<ul>
<li>501 (Web)(Software)</li>
<li>504.2 (Authoring Tool)</li>
<li>602.3 (Support Docs)</li>
</ul></th>
<td><p><strong>Software:</strong> Supports</p>
<p><strong>Web:</strong> Partially Supports</p>
<p><strong>Authoring Tool:</strong> Partially Supports</p></td>
<td><div data-qmd="**Software:** Everything is operated from the keyboard: commands and options are typed, and interactive prompts use the arrow keys, Space, Enter, and typed text.

**Web:** Navigation, search, menus, tabsets, copy buttons, the gallery
carousel, and the embedded video player all work from the
keyboard.

Known defects:

- Collapsed callouts cannot be opened from the keyboard, because
  the header takes no focus ([quarto-dev/quarto-cli#4934](https://github.com/quarto-dev/quarto-cli/issues/4934)).
- Code annotation markers take no keyboard focus, so their popups
  are mouse-only; the annotation text is also in the numbered list
  under the code block.
- When content extends into the right margin, the table of
  contents collapses into an &quot;On this page&quot; toggle, which is not
  keyboard operable ([quarto-dev/quarto-cli#14969](https://github.com/quarto-dev/quarto-cli/issues/14969)).

**Authoring Tool:** Navigation, search, sidebar sections, tabsets, copy buttons, and
scrollable code blocks work from the keyboard.

Known defects, each only in content the author adds:

- Collapsed callouts cannot be opened from the keyboard, because
  the header takes no focus ([quarto-dev/quarto-cli#4934](https://github.com/quarto-dev/quarto-cli/issues/4934)).
- Code annotation markers take no keyboard focus, so their popups
  are mouse-only; the annotation text is also listed under the
  code block.
- When content extends into the right margin, the table of
  contents collapses into an &quot;On this page&quot; toggle, which is not
  keyboard operable ([quarto-dev/quarto-cli#14969](https://github.com/quarto-dev/quarto-cli/issues/14969))."></div></td>
</tr>
<tr>
<th scope="row"><div id="acr-2.1.2" class="acr-criterion"><a href="https://www.w3.org/TR/WCAG22/#no-keyboard-trap">2.1.2 No Keyboard Trap</a> (Level A)</div>
<div class="acr-also-applies">Also applies to:</div>
<p>EN 301 549 Criteria</p>
<ul>
<li>9.2.1.2 (Web)</li>
<li>10.2.1.2 (Non-web document)</li>
<li>11.2.1.2 (Open Functionality Software)</li>
<li>11.2.1.2 (Closed Software)</li>
<li>11.8.2 (Authoring Tool)</li>
<li>12.1.2 (Product Docs)</li>
<li>12.2.4 (Support Docs)</li>
</ul>
<p>Revised Section 508</p>
<ul>
<li>501 (Web)(Software)</li>
<li>504.2 (Authoring Tool)</li>
<li>602.3 (Support Docs)</li>
</ul></th>
<td><p><strong>Software:</strong> Supports</p>
<p><strong>Web:</strong> Supports</p>
<p><strong>Authoring Tool:</strong> Supports</p></td>
<td><div data-qmd="**Software:** Ctrl+C, the terminal convention, leaves any prompt and stops any running command, including `preview`."></div></td>
</tr>
<tr>
<th scope="row"><div id="acr-2.1.4" class="acr-criterion"><a href="https://www.w3.org/TR/WCAG22/#character-key-shortcuts">2.1.4 Character Key Shortcuts</a> (Level A 2.1 and 2.2)</div>
<div class="acr-also-applies">Also applies to:</div>
<p>EN 301 549 Criteria</p>
<ul>
<li>9.2.1.4 (Web)</li>
<li>10.2.1.4 (Non-web document)</li>
<li>11.2.1.4.1 (Open Functionality Software)</li>
<li>11.2.1.4.2 (Closed Software)</li>
<li>11.8.2 (Authoring Tool)</li>
<li>12.1.2 (Product Docs)</li>
<li>12.2.4 (Support Docs)</li>
</ul>
<p>Revised Section 508 – Does not apply</p></th>
<td><p><strong>Software:</strong> Supports</p>
<p><strong>Web:</strong> Does Not Support</p>
<p><strong>Authoring Tool:</strong> Partially Supports</p></td>
<td><div data-qmd="**Software:** Single-character keys exist only inside interactive prompts (for example `n` and `p` move through a list) and are active only while that prompt has focus.

**Web:** The single-character keys `f`, `s`, and `/` open the site search
when focus is on the page body.

Known defects:

- There is no way to turn them off or remap them.

**Authoring Tool:** Websites with search bind the single keys `f`, `s`, and `/` to
open the search whenever focus is outside a form field. An author
can remap them, or turn them off for every reader, with the
`keyboard-shortcut` search option, or turn off the search feature.

Known defects:

- Readers have no way to turn them off or remap them."></div></td>
</tr>
<tr>
<th scope="row"><div id="acr-2.2.1" class="acr-criterion"><a href="https://www.w3.org/TR/WCAG22/#timing-adjustable">2.2.1 Timing Adjustable</a> (Level A)</div>
<div class="acr-also-applies">Also applies to:</div>
<p>EN 301 549 Criteria</p>
<ul>
<li>9.2.2.1 (Web)</li>
<li>10.2.2.1 (Non-web document)</li>
<li>11.2.2.1 (Open Functionality Software)</li>
<li>11.2.2.1 (Closed Software)</li>
<li>11.8.2 (Authoring Tool)</li>
<li>12.1.2 (Product Docs)</li>
<li>12.2.4 (Support Docs)</li>
</ul>
<p>Revised Section 508</p>
<ul>
<li>501 (Web)(Software)</li>
<li>504.2 (Authoring Tool)</li>
<li>602.3 (Support Docs)</li>
</ul></th>
<td><p><strong>Software:</strong> Supports</p>
<p><strong>Web:</strong> Supports</p>
<p><strong>Authoring Tool:</strong> Supports</p></td>
<td><div data-qmd="**Software:** The CLI sets no time limits on input; interactive prompts wait indefinitely. The one timed step is the device-code login for Posit Connect Cloud, whose code expiry is set by the service.

**Web:** The site sets no time limits: there is no session, no timed content, and search has no timeout.

**Authoring Tool:** Default output sets no time limits."></div></td>
</tr>
<tr>
<th scope="row"><div id="acr-2.2.2" class="acr-criterion"><a href="https://www.w3.org/TR/WCAG22/#pause-stop-hide">2.2.2 Pause, Stop, Hide</a> (Level A)</div>
<div class="acr-also-applies">Also applies to:</div>
<p>EN 301 549 Criteria</p>
<ul>
<li>9.2.2.2 (Web)</li>
<li>10.2.2.2 (Non-web document)</li>
<li>11.2.2.2 (Open Functionality Software)</li>
<li>11.2.2.2 (Closed Software)</li>
<li>11.8.2 (Authoring Tool)</li>
<li>12.1.2 (Product Docs)</li>
<li>12.2.4 (Support Docs)</li>
</ul>
<p>Revised Section 508</p>
<ul>
<li>501 (Web)(Software)</li>
<li>504.2 (Authoring Tool)</li>
<li>602.3 (Support Docs)</li>
</ul></th>
<td><p><strong>Software:</strong> Supports</p>
<p><strong>Web:</strong> Does Not Support</p>
<p><strong>Authoring Tool:</strong> Supports</p></td>
<td><div data-qmd="**Software:** The only moving content is a one-character spinner shown while `check`, `add`, `use`, `publish`, and tool installs wait on a step, during which no interaction is possible; animation during this phase is &quot;essential animation&quot;; `--quiet` removes it, with all other output.

**Web:** Three kinds of moving content start on their own and have no
pause, stop, or hide control.

Known defects:

- The home page hero animation, which is hidden when the operating
  system's reduce-motion setting is on.
- The gallery carousel, which advances every five seconds.
- The animated GIFs of editor demos, which loop without end.

**Authoring Tool:** Default output has no moving, blinking, or auto-updating content."></div></td>
</tr>
<tr>
<th scope="row"><div id="acr-2.3.1" class="acr-criterion"><a href="https://www.w3.org/TR/WCAG22/#three-flashes-or-below-threshold">2.3.1 Three Flashes or Below Threshold</a> (Level A)</div>
<div class="acr-also-applies">Also applies to:</div>
<p>EN 301 549 Criteria</p>
<ul>
<li>9.2.3.1 (Web)</li>
<li>10.2.3.1 (Non-web document)</li>
<li>11.2.3.1 (Open Functionality Software)</li>
<li>11.2.3.1 (Closed Software)</li>
<li>11.8.2 (Authoring Tool)</li>
<li>12.1.2 (Product Docs)</li>
<li>12.2.4 (Support Docs)</li>
</ul>
<p>Revised Section 508</p>
<ul>
<li>501 (Web)(Software)</li>
<li>504.2 (Authoring Tool)</li>
<li>602.3 (Support Docs)</li>
</ul></th>
<td><p><strong>Software:</strong> Supports</p>
<p><strong>Web:</strong> Supports</p>
<p><strong>Authoring Tool:</strong> Supports</p></td>
<td><div data-qmd="**Software:** Nothing in the CLI flashes.

**Web:** Nothing on the site flashes.

**Authoring Tool:** Nothing in default output flashes."></div></td>
</tr>
<tr>
<th scope="row"><div id="acr-2.4.1" class="acr-criterion"><a href="https://www.w3.org/TR/WCAG22/#bypass-blocks">2.4.1 Bypass Blocks</a> (Level A)</div>
<div class="acr-also-applies">Also applies to:</div>
<p>EN 301 549 Criteria</p>
<ul>
<li>9.2.4.1 (Web)</li>
<li>10.2.4.1 (Non-web document) – Does not apply</li>
<li>11.2.4.1 (Open Functionality Software) – Does not apply</li>
<li>11.2.4.1 (Closed Software) – Does not apply</li>
<li>11.8.2 (Authoring Tool)</li>
<li>12.1.2 (Product Docs)</li>
<li>12.2.4 (Support Docs)</li>
</ul>
<p>Revised Section 508</p>
<ul>
<li>501 (Web)(Software) – Does not apply to non-web software</li>
<li>504.2 (Authoring Tool)</li>
<li>602.3 (Support Docs) – Does not apply to non-web docs</li>
</ul></th>
<td><p><strong>Web:</strong> Supports</p>
<p><strong>Authoring Tool:</strong> Supports</p></td>
<td><div data-qmd="**Authoring Tool:** Every page begins with a skip link to the main content."></div></td>
</tr>
<tr>
<th scope="row"><div id="acr-2.4.2" class="acr-criterion"><a href="https://www.w3.org/TR/WCAG22/#page-titled">2.4.2 Page Titled</a> (Level A)</div>
<div class="acr-also-applies">Also applies to:</div>
<p>EN 301 549 Criteria</p>
<ul>
<li>9.2.4.2 (Web)</li>
<li>10.2.4.2 (Non-web document)</li>
<li>11.2.4.2 (Open Functionality Software) – Does not apply</li>
<li>11.2.4.2 (Closed Software) – Does not apply</li>
<li>11.8.2 (Authoring Tool)</li>
<li>12.1.2 (Product Docs)</li>
<li>12.2.4 (Support Docs)</li>
</ul>
<p>Revised Section 508</p>
<ul>
<li>501 (Web)(Software)</li>
<li>504.2 (Authoring Tool)</li>
<li>602.3 (Support Docs)</li>
</ul></th>
<td><p><strong>Software:</strong> Supports</p>
<p><strong>Web:</strong> Supports</p>
<p><strong>Authoring Tool:</strong> Supports</p></td>
<td><div data-qmd="**Software:** The CLI creates no windows of its own; the terminal and shell set the window title. `quarto preview` opens a URL in the user's browser, where the page title is the rendered document's, as assessed in the Authoring Tool row.

**Authoring Tool:** The author writes the document title and, on websites, the site
title. Quarto combines them into the page title."></div></td>
</tr>
<tr>
<th scope="row"><div id="acr-2.4.3" class="acr-criterion"><a href="https://www.w3.org/TR/WCAG22/#focus-order">2.4.3 Focus Order</a> (Level A)</div>
<div class="acr-also-applies">Also applies to:</div>
<p>EN 301 549 Criteria</p>
<ul>
<li>9.2.4.3 (Web)</li>
<li>10.2.4.3 (Non-web document)</li>
<li>11.2.4.3 (Open Functionality Software)</li>
<li>11.2.4.3 (Closed Software)</li>
<li>11.8.2 (Authoring Tool)</li>
<li>12.1.2 (Product Docs)</li>
<li>12.2.4 (Support Docs)</li>
</ul>
<p>Revised Section 508</p>
<ul>
<li>501 (Web)(Software)</li>
<li>504.2 (Authoring Tool)</li>
<li>602.3 (Support Docs)</li>
</ul></th>
<td><p><strong>Software:</strong> Supports</p>
<p><strong>Web:</strong> Partially Supports</p>
<p><strong>Authoring Tool:</strong> Partially Supports</p></td>
<td><div data-qmd="**Software:** Each prompt has a single point of input, and list prompts move the pointer through the options in the order shown.

**Web:** Focus moves in reading order through the navbar, sidebar, footnotes,
tabsets, and popups, and hidden items of closed menus and sidebar
sections are skipped.

Known defects, in the site search:

- The search button is out of place in the Tab order
  ([quarto-dev/quarto-cli#7058](https://github.com/quarto-dev/quarto-cli/issues/7058)).
- The search overlay does not trap focus.
- Closing the search overlay returns focus to the top of the page.

**Authoring Tool:** Focus moves in reading order through the navbar, sidebar, table
of contents, body, tabsets, and footnotes, and hidden items of
closed menus and sidebar sections are skipped.

Known defects:

- The search button is out of place in the Tab order
  ([quarto-dev/quarto-cli#7058](https://github.com/quarto-dev/quarto-cli/issues/7058); fixed after 1.11.6).
- The search overlay does not trap focus.
- Closing the search overlay returns focus to the top of the page.
- Closing the source code window of the `code-tools` returns focus
  to the top of the page."></div></td>
</tr>
<tr>
<th scope="row"><div id="acr-2.4.4" class="acr-criterion"><a href="https://www.w3.org/TR/WCAG22/#link-purpose-in-context">2.4.4 Link Purpose (In Context)</a> (Level A)</div>
<div class="acr-also-applies">Also applies to:</div>
<p>EN 301 549 Criteria</p>
<ul>
<li>9.2.4.4 (Web)</li>
<li>10.2.4.4 (Non-web document)</li>
<li>11.2.4.4 (Open Functionality Software)</li>
<li>11.2.4.4 (Closed Software)</li>
<li>11.8.2 (Authoring Tool)</li>
<li>12.1.2 (Product Docs)</li>
<li>12.2.4 (Support Docs)</li>
</ul>
<p>Revised Section 508</p>
<ul>
<li>501 (Web)(Software)</li>
<li>504.2 (Authoring Tool)</li>
<li>602.3 (Support Docs)</li>
</ul></th>
<td><p><strong>Software:</strong> Supports</p>
<p><strong>Web:</strong> Partially Supports</p>
<p><strong>Authoring Tool:</strong> Partially Supports</p></td>
<td><div data-qmd="**Software:** Every URL the CLI prints is in a descriptive sentence, for example `Browse at http://localhost:4873/`.

**Web:** Link purpose is clear from the link text or its context, including
the &quot;Learn more&quot;, &quot;View source code&quot;, and heading anchor links that
repeat on a page.

Known defects:

- Footnote back-links have only the return arrow character as
  their name, so a screen reader does not say where the link goes
  ([quarto-dev/quarto-cli#15064](https://github.com/quarto-dev/quarto-cli/issues/15064), from [jgm/pandoc#11965](https://github.com/jgm/pandoc/issues/11965)).

The Markdown Basics page shows a linked image with no alt text on
purpose, as an example of the syntax; that link has no accessible
name.

**Authoring Tool:** Links in the content keep the text the author writes.
The links Quarto adds have a purpose that is clear from their text or
context.

Known defects:

- Footnote back-links have only the return arrow character as
  their name, so a screen reader does not say where the link goes
  ([quarto-dev/quarto-cli#15064](https://github.com/quarto-dev/quarto-cli/issues/15064), from [jgm/pandoc#11965](https://github.com/jgm/pandoc/issues/11965)).
- Navbar and sidebar items declared with an icon only have no
  accessible name, and the blog project template ships two such
  links ([quarto-dev/quarto-cli#14828](https://github.com/quarto-dev/quarto-cli/issues/14828), [quarto-dev/quarto-cli#15038](https://github.com/quarto-dev/quarto-cli/issues/15038))."></div></td>
</tr>
<tr>
<th scope="row"><div id="acr-2.5.1" class="acr-criterion"><a href="https://www.w3.org/TR/WCAG22/#pointer-gestures">2.5.1 Pointer Gestures</a> (Level A 2.1 and 2.2)</div>
<div class="acr-also-applies">Also applies to:</div>
<p>EN 301 549 Criteria</p>
<ul>
<li>9.2.5.1 (Web)</li>
<li>10.2.5.1 (Non-web document)</li>
<li>11.2.5.1 (Open Functionality Software)</li>
<li>11.2.5.1 (Closed Software)</li>
<li>11.8.2 (Authoring Tool)</li>
<li>12.1.2 (Product Docs)</li>
<li>12.2.4 (Support Docs)</li>
</ul>
<p>Revised Section 508 – Does not apply</p></th>
<td><p><strong>Software:</strong> Supports</p>
<p><strong>Web:</strong> Supports</p>
<p><strong>Authoring Tool:</strong> Supports</p></td>
<td><div data-qmd="**Software:** The CLI takes no pointer input.

**Authoring Tool:** Default output needs no path-based or multipoint gestures."></div></td>
</tr>
<tr>
<th scope="row"><div id="acr-2.5.2" class="acr-criterion"><a href="https://www.w3.org/TR/WCAG22/#pointer-cancellation">2.5.2 Pointer Cancellation</a> (Level A 2.1 and 2.2)</div>
<div class="acr-also-applies">Also applies to:</div>
<p>EN 301 549 Criteria</p>
<ul>
<li>9.2.5.2 (Web)</li>
<li>10.2.5.2 (Non-web document)</li>
<li>11.2.5.2 (Open Functionality Software)</li>
<li>11.2.5.2 (Closed Software)</li>
<li>11.8.2 (Authoring Tool)</li>
<li>12.1.2 (Product Docs)</li>
<li>12.2.4 (Support Docs)</li>
</ul>
<p>Revised Section 508 – Does not apply</p></th>
<td><p><strong>Software:</strong> Supports</p>
<p><strong>Web:</strong> Supports</p>
<p><strong>Authoring Tool:</strong> Supports</p></td>
<td><div data-qmd="**Software:** The CLI takes no pointer input."></div></td>
</tr>
<tr>
<th scope="row"><div id="acr-2.5.3" class="acr-criterion"><a href="https://www.w3.org/TR/WCAG22/#label-in-name">2.5.3 Label in Name</a> (Level A 2.1 and 2.2)</div>
<div class="acr-also-applies">Also applies to:</div>
<p>EN 301 549 Criteria</p>
<ul>
<li>9.2.5.3 (Web)</li>
<li>10.2.5.3 (Non-web document)</li>
<li>11.2.5.3.1 (Open Functionality Software)</li>
<li>11.2.5.3.2 (Closed Software)</li>
<li>11.8.2 (Authoring Tool)</li>
<li>12.1.2 (Product Docs)</li>
<li>12.2.4 (Support Docs)</li>
</ul>
<p>Revised Section 508 – Does not apply</p></th>
<td><p><strong>Software:</strong> Supports</p>
<p><strong>Web:</strong> Supports</p>
<p><strong>Authoring Tool:</strong> Supports</p></td>
<td><div data-qmd="**Software:** Every label in the CLI is text, so the label is the name."></div></td>
</tr>
<tr>
<th scope="row"><div id="acr-2.5.4" class="acr-criterion"><a href="https://www.w3.org/TR/WCAG22/#motion-actuation">2.5.4 Motion Actuation</a> (Level A 2.1 and 2.2)</div>
<div class="acr-also-applies">Also applies to:</div>
<p>EN 301 549 Criteria</p>
<ul>
<li>9.2.5.4 (Web)</li>
<li>10.2.5.4 (Non-web document)</li>
<li>11.2.5.4 (Open Functionality Software)</li>
<li>11.2.5.4 (Closed Software)</li>
<li>11.8.2 (Authoring Tool)</li>
<li>12.1.2 (Product Docs)</li>
<li>12.2.4 (Support Docs)</li>
</ul>
<p>Revised Section 508 – Does not apply</p></th>
<td><p><strong>Software:</strong> Supports</p>
<p><strong>Web:</strong> Supports</p>
<p><strong>Authoring Tool:</strong> Supports</p></td>
<td><div data-qmd="**Software:** The CLI takes no motion input.

**Web:** The site takes no motion input.

**Authoring Tool:** Default output takes no motion input."></div></td>
</tr>
<tr>
<th scope="row"><div id="acr-3.1.1" class="acr-criterion"><a href="https://www.w3.org/TR/WCAG22/#language-of-page">3.1.1 Language of Page</a> (Level A)</div>
<div class="acr-also-applies">Also applies to:</div>
<p>EN 301 549 Criteria</p>
<ul>
<li>9.3.1.1 (Web)</li>
<li>10.3.1.1 (Non-web document)</li>
<li>11.3.1.1.1 (Open Functionality Software)</li>
<li>11.3.1.1.2 (Closed Software)</li>
<li>11.8.2 (Authoring Tool)</li>
<li>12.1.2 (Product Docs)</li>
<li>12.2.4 (Support Docs)</li>
</ul>
<p>Revised Section 508</p>
<ul>
<li>501 (Web)(Software)</li>
<li>504.2 (Authoring Tool)</li>
<li>602.3 (Support Docs)</li>
</ul></th>
<td><p><strong>Software:</strong> Supports</p>
<p><strong>Web:</strong> Supports</p>
<p><strong>Authoring Tool:</strong> Supports</p></td>
<td><div data-qmd="**Software:** The CLI emits plain text, which has no language metadata. All CLI text is in English.

**Authoring Tool:** The author sets the document language with the `lang` option
(English if not set). Quarto sets it on every page."></div></td>
</tr>
<tr>
<th scope="row"><div id="acr-3.2.1" class="acr-criterion"><a href="https://www.w3.org/TR/WCAG22/#on-focus">3.2.1 On Focus</a> (Level A)</div>
<div class="acr-also-applies">Also applies to:</div>
<p>EN 301 549 Criteria</p>
<ul>
<li>9.3.2.1 (Web)</li>
<li>10.3.2.1 (Non-web document)</li>
<li>11.3.2.1 (Open Functionality Software)</li>
<li>11.3.2.1 (Closed Software)</li>
<li>11.8.2 (Authoring Tool)</li>
<li>12.1.2 (Product Docs)</li>
<li>12.2.4 (Support Docs)</li>
</ul>
<p>Revised Section 508</p>
<ul>
<li>501 (Web)(Software)</li>
<li>504.2 (Authoring Tool)</li>
<li>602.3 (Support Docs)</li>
</ul></th>
<td><p><strong>Software:</strong> Supports</p>
<p><strong>Web:</strong> Supports</p>
<p><strong>Authoring Tool:</strong> Supports</p></td>
<td><div data-qmd="**Software:** Moving the pointer in a list prompt changes nothing until Enter."></div></td>
</tr>
<tr>
<th scope="row"><div id="acr-3.2.2" class="acr-criterion"><a href="https://www.w3.org/TR/WCAG22/#on-input">3.2.2 On Input</a> (Level A)</div>
<div class="acr-also-applies">Also applies to:</div>
<p>EN 301 549 Criteria</p>
<ul>
<li>9.3.2.2 (Web)</li>
<li>10.3.2.2 (Non-web document)</li>
<li>11.3.2.2 (Open Functionality Software)</li>
<li>11.3.2.2 (Closed Software)</li>
<li>11.8.2 (Authoring Tool)</li>
<li>12.1.2 (Product Docs)</li>
<li>12.2.4 (Support Docs)</li>
</ul>
<p>Revised Section 508</p>
<ul>
<li>501 (Web)(Software)</li>
<li>504.2 (Authoring Tool)</li>
<li>602.3 (Support Docs)</li>
</ul></th>
<td><p><strong>Software:</strong> Supports</p>
<p><strong>Web:</strong> Supports</p>
<p><strong>Authoring Tool:</strong> Supports</p></td>
<td><div data-qmd="**Software:** Changing a selection or typing at a prompt changes nothing else until Enter."></div></td>
</tr>
<tr>
<th scope="row"><div id="acr-3.2.6" class="acr-criterion"><a href="https://www.w3.org/TR/WCAG22/#consistent-help">3.2.6 Consistent Help</a> (Level A 2.2 only)</div>
<div class="acr-also-applies">Also applies to:</div>
<p>EN 301 549 Criteria – Does not apply</p>
<p>Revised Section 508 – Does not apply</p></th>
<td><p><strong>Web:</strong> Supports</p></td>
<td></td>
</tr>
<tr>
<th scope="row"><div id="acr-3.3.1" class="acr-criterion"><a href="https://www.w3.org/TR/WCAG22/#error-identification">3.3.1 Error Identification</a> (Level A)</div>
<div class="acr-also-applies">Also applies to:</div>
<p>EN 301 549 Criteria</p>
<ul>
<li>9.3.3.1 (Web)</li>
<li>10.3.3.1 (Non-web document)</li>
<li>11.3.3.1.1 (Open Functionality Software)</li>
<li>11.3.3.1.2 (Closed Software)</li>
<li>11.8.2 (Authoring Tool)</li>
<li>12.1.2 (Product Docs)</li>
<li>12.2.4 (Support Docs)</li>
</ul>
<p>Revised Section 508</p>
<ul>
<li>501 (Web)(Software)</li>
<li>504.2 (Authoring Tool)</li>
<li>602.3 (Support Docs)</li>
</ul></th>
<td><p><strong>Software:</strong> Supports</p>
<p><strong>Web:</strong> Supports</p>
<p><strong>Authoring Tool:</strong> Supports</p></td>
<td><div data-qmd="**Software:** Errors are identified by an `ERROR:` prefix and described in text. YAML validation errors name the file, line, and columns, quote the line, and say what the value must be.

**Web:** Search is the site's only form. It takes any text, with no required field or format, so no input error can occur.

**Authoring Tool:** Search is the only form in default output. It takes any text, with no required field or format, so no input error can occur."></div></td>
</tr>
<tr>
<th scope="row"><div id="acr-3.3.2" class="acr-criterion"><a href="https://www.w3.org/TR/WCAG22/#labels-or-instructions">3.3.2 Labels or Instructions</a> (Level A)</div>
<div class="acr-also-applies">Also applies to:</div>
<p>EN 301 549 Criteria</p>
<ul>
<li>9.3.3.2 (Web)</li>
<li>10.3.3.2 (Non-web document)</li>
<li>11.3.3.2 (Open Functionality Software)</li>
<li>11.3.3.2 (Closed Software)</li>
<li>11.8.2 (Authoring Tool)</li>
<li>12.1.2 (Product Docs)</li>
<li>12.2.4 (Support Docs)</li>
</ul>
<p>Revised Section 508</p>
<ul>
<li>501 (Web)(Software)</li>
<li>504.2 (Authoring Tool)</li>
<li>602.3 (Support Docs)</li>
</ul></th>
<td><p><strong>Software:</strong> Partially Supports</p>
<p><strong>Web:</strong> Supports</p>
<p><strong>Authoring Tool:</strong> Partially Supports</p></td>
<td><div data-qmd="**Software:** Every prompt is labelled with what it asks for, and the hints name
the keys to use.

Known gaps under a screen reader:

- In `quarto create`, the `Directory` label is not announced.
- In `quarto create`, the `Open With` prompt is not announced at
  all, so the command seems to hang.
- In `quarto remove`, the hint that explains how to check items
  and submit is not announced.

**Authoring Tool:** Search is the only form in default output. Its text field has a
search icon, and in the navbar search the name &quot;Search&quot;.

Known defects:

- With the search in the sidebar, the text field's label is
  &quot;Submit&quot;, taken from the button beside it, so VoiceOver reads it
  as &quot;Submit, search text field&quot;."></div></td>
</tr>
<tr>
<th scope="row"><div id="acr-3.3.7" class="acr-criterion"><a href="https://www.w3.org/TR/WCAG22/#redundant-entry">3.3.7 Redundant Entry</a> (Level A 2.2 only)</div>
<div class="acr-also-applies">Also applies to:</div>
<p>EN 301 549 Criteria – Does not apply</p>
<p>Revised Section 508 – Does not apply</p></th>
<td><p><strong>Web:</strong> Supports</p></td>
<td><div data-qmd="**Web:** The site has no multi-step process that could ask for the same information twice."></div></td>
</tr>
<tr>
<th scope="row"><div id="acr-4.1.1" class="acr-criterion"><a href="https://www.w3.org/TR/WCAG22/#parsing">4.1.1 Parsing</a> (Level A)</div>
<div class="acr-also-applies">Also applies to:</div>
<p>WCAG 2.0 and 2.1 – Always answer ‘Supports’</p>
<p>WCAG 2.2 (obsolete and removed) – Does not apply</p>
<p>EN 301 549 Criteria</p>
<ul>
<li>9.4.1.1 (Web)</li>
<li>10.4.1.1 (Non-web document)</li>
<li>11.4.1.1.1 (Open Functionality Software)</li>
<li>11.4.1.1.2 (Closed Software) – Does not apply</li>
<li>11.8.2 (Authoring Tool)</li>
<li>12.1.2 (Product Docs)</li>
<li>12.2.4 (Support Docs)</li>
</ul>
<p>Revised Section 508</p>
<ul>
<li>501 (Web)(Software)</li>
<li>504.2 (Authoring Tool)</li>
<li>602.3 (Support Docs)</li>
</ul></th>
<td>Supports</td>
<td><div data-qmd="For WCAG 2.0, 2.1, EN 301 549, and Revised 508 Standards, the September 2023 errata update indicates this criterion is always supported. See the [WCAG 2.0 Editorial Errata](https://www.w3.org/WAI/WCAG20/errata/#editorial) and the [WCAG 2.1 Editorial Errata](https://www.w3.org/WAI/WCAG21/errata/#editorial)."></div></td>
</tr>
<tr>
<th scope="row"><div id="acr-4.1.2" class="acr-criterion"><a href="https://www.w3.org/TR/WCAG22/#name-role-value">4.1.2 Name, Role, Value</a> (Level A)</div>
<div class="acr-also-applies">Also applies to:</div>
<p>EN 301 549 Criteria</p>
<ul>
<li>9.4.1.2 (Web)</li>
<li>10.4.1.2 (Non-web document)</li>
<li>11.4.1.2.1 (Open Functionality Software)</li>
<li>11.4.1.2.2 (Closed Software) – Does not apply</li>
<li>11.8.2 (Authoring Tool)</li>
<li>12.1.2 (Product Docs)</li>
<li>12.2.4 (Support Docs)</li>
</ul>
<p>Revised Section 508</p>
<ul>
<li>501 (Web)(Software)</li>
<li>504.2 (Authoring Tool)</li>
<li>602.3 (Support Docs)</li>
</ul></th>
<td><p><strong>Software:</strong> Supports</p>
<p><strong>Web:</strong> Partially Supports</p>
<p><strong>Authoring Tool:</strong> Partially Supports</p></td>
<td><div data-qmd="**Software:** The CLI creates no user interface components of its own. Its prompts and messages are text in the terminal, which assistive technology reads through the terminal's own accessibility support.

**Web:** The site's navigation controls expose their name, role, and state:
the navbar, sidebar section toggles, colour-scheme toggle, search
button, tabsets, code copy buttons, and the gallery carousel.

Known defects:

- Collapsed callout headers act as buttons but have no role and no
  expanded state ([quarto-dev/quarto-cli#4934](https://github.com/quarto-dev/quarto-cli/issues/4934)).
- When content extends into the right margin, the table of
  contents collapses into an &quot;On this page&quot; toggle, which is a
  plain element with a click handler, with no role or state
  ([quarto-dev/quarto-cli#14969](https://github.com/quarto-dev/quarto-cli/issues/14969)).
- Moving through search results with the arrow keys is silent in
  VoiceOver ([algolia/autocomplete#589](https://github.com/algolia/autocomplete/issues/589)).

**Authoring Tool:** Navigation controls expose their name, role, and state: the
navbar, sidebar section toggles, the sidebar and search buttons,
tabsets, scrollable code blocks, and copy buttons.

Known defects:

- Collapsed callout headers act as buttons but have no role and
  expose no expanded state ([quarto-dev/quarto-cli#4934](https://github.com/quarto-dev/quarto-cli/issues/4934)).
- When content extends into the right margin, the table of
  contents collapses into an &quot;On this page&quot; toggle, which is a
  plain element with a click handler, with no role or state
  ([quarto-dev/quarto-cli#14969](https://github.com/quarto-dev/quarto-cli/issues/14969)).
- Moving through navbar search results with the arrow keys is
  silent in VoiceOver ([algolia/autocomplete#589](https://github.com/algolia/autocomplete/issues/589))."></div></td>
</tr>
</tbody>
</table>
```

:::

### Table 2: Success Criteria, Level AA {#acr-tbl-wcag-aa}

::: {.column-page}

```{=html}
<table class="table acr-table acr-criteria" aria-labelledby="acr-tbl-wcag-aa">
<colgroup>
<col style="width: 25%">
<col style="width: 15%">
<col style="width: 60%">
</colgroup>
<thead>
<tr>
<th scope="col">Criteria</th>
<th scope="col">Conformance Level</th>
<th scope="col">Remarks and Explanations</th>
</tr>
</thead>
<tbody>
<tr>
<th scope="row"><div id="acr-1.2.4" class="acr-criterion"><a href="https://www.w3.org/TR/WCAG22/#captions-live">1.2.4 Captions (Live)</a> (Level AA)</div>
<div class="acr-also-applies">Also applies to:</div>
<p>EN 301 549 Criteria</p>
<ul>
<li>9.1.2.4 (Web)</li>
<li>10.1.2.4 (Non-web document)</li>
<li>11.1.2.4 (Open Functionality Software)</li>
<li>11.1.2.4 (Closed Software)</li>
<li>11.8.2 (Authoring Tool)</li>
<li>12.1.2 (Product Docs)</li>
<li>12.2.4 (Support Docs)</li>
</ul>
<p>Revised Section 508</p>
<ul>
<li>501 (Web)(Software)</li>
<li>504.2 (Authoring Tool)</li>
<li>602.3 (Support Docs)</li>
</ul></th>
<td><p><strong>Software:</strong> Supports</p>
<p><strong>Web:</strong> Supports</p>
<p><strong>Authoring Tool:</strong> Supports</p></td>
<td><div data-qmd="**Software:** The CLI presents no audio or video.

**Web:** The site has no live audio or video.

**Authoring Tool:** Default output has no live audio or video, and the `video` shortcode embeds prerecorded media only."></div></td>
</tr>
<tr>
<th scope="row"><div id="acr-1.2.5" class="acr-criterion"><a href="https://www.w3.org/TR/WCAG22/#audio-description-prerecorded">1.2.5 Audio Description (Prerecorded)</a> (Level AA)</div>
<div class="acr-also-applies">Also applies to:</div>
<p>EN 301 549 Criteria</p>
<ul>
<li>9.1.2.5 (Web)</li>
<li>10.1.2.5 (Non-web document)</li>
<li>11.1.2.5 (Open Functionality Software)</li>
<li>11.1.2.5 (Closed Software)</li>
<li>11.8.2 (Authoring Tool)</li>
<li>12.1.2 (Product Docs)</li>
<li>12.2.4 (Support Docs)</li>
</ul>
<p>Revised Section 508</p>
<ul>
<li>501 (Web)(Software)</li>
<li>504.2 (Authoring Tool)</li>
<li>602.3 (Support Docs)</li>
</ul></th>
<td><p><strong>Software:</strong> Supports</p>
<p><strong>Web:</strong> Does Not Support</p>
<p><strong>Authoring Tool:</strong> Partially Supports</p></td>
<td><div data-qmd="**Software:** The CLI presents no audio or video.

**Web:** The site offers two tutorial videos.

Known defects:

- Neither has an audio description. In both, the narration depends
  on what is on screen, for example which button is pressed or
  which line of code to copy. The page text next to each video is
  a separate write-up, not a text alternative for it.

**Authoring Tool:** Hosted players can carry an audio description track from the host.

Known defects:

- The player the `video` shortcode makes for a local file has no
  such track and no option to add one."></div></td>
</tr>
<tr>
<th scope="row"><div id="acr-1.3.4" class="acr-criterion"><a href="https://www.w3.org/TR/WCAG22/#orientation">1.3.4 Orientation</a> (Level AA 2.1 and 2.2)</div>
<div class="acr-also-applies">Also applies to:</div>
<p>EN 301 549 Criteria</p>
<ul>
<li>9.1.3.4 (Web)</li>
<li>10.1.3.4 (Non-web document)</li>
<li>11.1.3.4 (Open Functionality Software)</li>
<li>11.1.3.4 (Closed Software)</li>
<li>11.8.2 (Authoring Tool)</li>
<li>12.1.2 (Product Docs)</li>
<li>12.2.4 (Support Docs)</li>
</ul>
<p>Revised Section 508 – Does not apply</p></th>
<td><p><strong>Software:</strong> Supports</p>
<p><strong>Web:</strong> Supports</p>
<p><strong>Authoring Tool:</strong> Supports</p></td>
<td><div data-qmd="**Software:** The CLI does not set or lock display orientation. The terminal application controls orientation."></div></td>
</tr>
<tr>
<th scope="row"><div id="acr-1.3.5" class="acr-criterion"><a href="https://www.w3.org/TR/WCAG22/#identify-input-purpose">1.3.5 Identify Input Purpose</a> (Level AA 2.1 and 2.2)</div>
<div class="acr-also-applies">Also applies to:</div>
<p>EN 301 549 Criteria</p>
<ul>
<li>9.1.3.5 (Web)</li>
<li>10.1.3.5 (Non-web document)</li>
<li>11.1.3.5.1 (Open Functionality Software)</li>
<li>11.1.3.5.2 (Closed Software)</li>
<li>11.8.2 (Authoring Tool)</li>
<li>12.1.2 (Product Docs)</li>
<li>12.2.4 (Support Docs)</li>
</ul>
<p>Revised Section 508 – Does not apply</p></th>
<td><p><strong>Software:</strong> Supports</p>
<p><strong>Web:</strong> Supports</p>
<p><strong>Authoring Tool:</strong> Supports</p></td>
<td><div data-qmd="**Software:** Interactive prompts run in a text stream, which has no mechanism for declaring an input's purpose.

**Web:** Search is the site's only form, and it collects no information about the user.

**Authoring Tool:** Search is the only form in default output, and it collects nothing about the user."></div></td>
</tr>
<tr>
<th scope="row"><div id="acr-1.4.3" class="acr-criterion"><a href="https://www.w3.org/TR/WCAG22/#contrast-minimum">1.4.3 Contrast (Minimum)</a> (Level AA)</div>
<div class="acr-also-applies">Also applies to:</div>
<p>EN 301 549 Criteria</p>
<ul>
<li>9.1.4.3 (Web)</li>
<li>10.1.4.3 (Non-web document)</li>
<li>11.1.4.3 (Open Functionality Software)</li>
<li>11.1.4.3 (Closed Software)</li>
<li>11.8.2 (Authoring Tool)</li>
<li>12.1.2 (Product Docs)</li>
<li>12.2.4 (Support Docs)</li>
</ul>
<p>Revised Section 508</p>
<ul>
<li>501 (Web)(Software)</li>
<li>504.2 (Authoring Tool)</li>
<li>602.3 (Support Docs)</li>
</ul></th>
<td><p><strong>Software:</strong> Supports</p>
<p><strong>Web:</strong> Supports</p>
<p><strong>Authoring Tool:</strong> Partially Supports</p></td>
<td><div data-qmd="**Software:** The CLI selects colours by terminal palette index (yellow for warnings, bright red for errors); the terminal's theme sets the actual colours and the background, so contrast depends on the user's terminal theme. Colour is never the only cue (see [1.4.1](#acr-1.4.1)).

**Authoring Tool:** Body text, navigation, and the table of contents meet 4.5:1 in
the default and cosmo themes.

Known defects:

- Footnote back-links in the appendix
  ([quarto-dev/quarto-cli#14679](https://github.com/quarto-dev/quarto-cli/issues/14679)).
- Margin notes, captions, and other secondary text in the cosmo
  theme ([quarto-dev/quarto-cli#14678](https://github.com/quarto-dev/quarto-cli/issues/14678)).
- The category filter links in blog listings
  ([quarto-dev/quarto-cli#14381](https://github.com/quarto-dev/quarto-cli/issues/14381))."></div></td>
</tr>
<tr>
<th scope="row"><div id="acr-1.4.4" class="acr-criterion"><a href="https://www.w3.org/TR/WCAG22/#resize-text">1.4.4 Resize text</a> (Level AA)</div>
<div class="acr-also-applies">Also applies to:</div>
<p>EN 301 549 Criteria</p>
<ul>
<li>9.1.4.4 (Web)</li>
<li>10.1.4.4 (Non-web document)</li>
<li>11.1.4.4.1 (Open Functionality Software)</li>
<li>11.1.4.4.2 (Closed Software)</li>
<li>11.8.2 (Authoring Tool)</li>
<li>12.1.2 (Product Docs)</li>
<li>12.2.4 (Support Docs)</li>
</ul>
<p>Revised Section 508</p>
<ul>
<li>501 (Web)(Software)</li>
<li>504.2 (Authoring Tool)</li>
<li>602.3 (Support Docs)</li>
</ul></th>
<td><p><strong>Software:</strong> Supports</p>
<p><strong>Web:</strong> Partially Supports</p>
<p><strong>Authoring Tool:</strong> Partially Supports</p></td>
<td><div data-qmd="**Software:** The terminal sets text size and zoom.

**Web:** Body text, menus, tabsets, cards and buttons resize to 200% without
loss.

Known defects:

- At 200% page zoom in a 1280px window the layout drops below the
  768px breakpoint, so the &quot;On this page&quot; table of contents and
  the &quot;Edit this page&quot; and &quot;Report an issue&quot; links are hidden
  ([quarto-dev/quarto-cli#5961](https://github.com/quarto-dev/quarto-cli/issues/5961)).
- At 200% text-only zoom in Safari the navbar stays on one row:
  the logo is clipped and the search button, colour-scheme toggle
  and &quot;Supported by Posit&quot; badge are pushed past the right edge,
  where the page cannot scroll to them.
- On the gallery page, the carousel captions grow upwards over the
  slide image at 200% text-only zoom.

**Authoring Tool:** Text resizes to 200% without loss in body content, menus, and
tabsets.

Known defects:

- At 200% page zoom in a 1280px window the layout drops below the
  768px breakpoint, so the table of contents is hidden
  ([quarto-dev/quarto-cli#5961](https://github.com/quarto-dev/quarto-cli/issues/5961))."></div></td>
</tr>
<tr>
<th scope="row"><div id="acr-1.4.5" class="acr-criterion"><a href="https://www.w3.org/TR/WCAG22/#images-of-text">1.4.5 Images of Text</a> (Level AA)</div>
<div class="acr-also-applies">Also applies to:</div>
<p>EN 301 549 Criteria</p>
<ul>
<li>9.1.4.5 (Web)</li>
<li>10.1.4.5 (Non-web document)</li>
<li>11.1.4.5.1 (Open Functionality Software)</li>
<li>11.1.4.5.2 (Closed Software) – Does not apply</li>
<li>11.8.2 (Authoring Tool)</li>
<li>12.1.2 (Product Docs)</li>
<li>12.2.4 (Support Docs)</li>
</ul>
<p>Revised Section 508</p>
<ul>
<li>501 (Web)(Software)</li>
<li>504.2 (Authoring Tool)</li>
<li>602.3 (Support Docs)</li>
</ul></th>
<td><p><strong>Software:</strong> Supports</p>
<p><strong>Web:</strong> Supports</p>
<p><strong>Authoring Tool:</strong> Supports</p></td>
<td><div data-qmd="**Software:** The CLI emits no images.

**Authoring Tool:** The author supplies the images in the content. Quarto renders its own
text as text and makes no images of text."></div></td>
</tr>
<tr>
<th scope="row"><div id="acr-1.4.10" class="acr-criterion"><a href="https://www.w3.org/TR/WCAG22/#reflow">1.4.10 Reflow</a> (Level AA 2.1 and 2.2)</div>
<div class="acr-also-applies">Also applies to:</div>
<p>EN 301 549 Criteria</p>
<ul>
<li>9.1.4.10 (Web)</li>
<li>10.1.4.10 (Non-web document)</li>
<li>11.1.4.10 (Open Functionality Software)</li>
<li>11.1.4.10 (Closed Software)</li>
<li>11.8.2 (Authoring Tool)</li>
<li>12.1.2 (Product Docs)</li>
<li>12.2.4 (Support Docs)</li>
</ul>
<p>Revised Section 508 – Does not apply</p></th>
<td><p><strong>Software:</strong> Supports</p>
<p><strong>Web:</strong> Partially Supports</p>
<p><strong>Authoring Tool:</strong> Partially Supports</p></td>
<td><div data-qmd="**Software:** The terminal wraps lines. Help output re-wraps to the terminal width.

**Web:** Pages reflow to 320px: the navbar collapses, tabsets wrap, and
code blocks scroll in their own box.

Known defects:

- Below 768px the &quot;On this page&quot; table of contents and the &quot;Edit
  this page&quot; and &quot;Report an issue&quot; links are hidden rather than
  collapsed ([quarto-dev/quarto-cli#5961](https://github.com/quarto-dev/quarto-cli/issues/5961)).
- Tables that contain long inline code cannot shrink to the
  column, so the reference page scrolls sideways at 320px.
- Inline code inside a tight list item cannot wrap, so the
  Markdown Basics page scrolls sideways at 320px.
- On a short viewport below 992px, the open sidebar extends below
  the screen and its last entries cannot be scrolled into view.

**Authoring Tool:** Pages reflow to 320px: the navbar and sidebar collapse behind
toggles, tabsets wrap, and code blocks scroll in their own box.

Known defects:

- A display equation wider than the viewport makes the whole page
  scroll sideways, because the math container neither scrolls nor
  breaks lines.
- Below 768px the table of contents is hidden rather than
  collapsed ([quarto-dev/quarto-cli#5961](https://github.com/quarto-dev/quarto-cli/issues/5961)).
- Inline code in a table cell or a tight list item cannot wrap, so
  a long code span makes the page scroll sideways.
- On a short viewport below 992px, the open sidebar may extend
  below the screen and its last entries cannot be scrolled into
  view."></div></td>
</tr>
<tr>
<th scope="row"><div id="acr-1.4.11" class="acr-criterion"><a href="https://www.w3.org/TR/WCAG22/#non-text-contrast">1.4.11 Non-text Contrast</a> (Level AA 2.1 and 2.2)</div>
<div class="acr-also-applies">Also applies to:</div>
<p>EN 301 549 Criteria</p>
<ul>
<li>9.1.4.11 (Web)</li>
<li>10.1.4.11 (Non-web document)</li>
<li>11.1.4.11 (Open Functionality Software)</li>
<li>11.1.4.11 (Closed Software)</li>
<li>11.8.2 (Authoring Tool)</li>
<li>12.1.2 (Product Docs)</li>
<li>12.2.4 (Support Docs)</li>
</ul>
<p>Revised Section 508 – Does not apply</p></th>
<td><p><strong>Software:</strong> Supports</p>
<p><strong>Web:</strong> Partially Supports</p>
<p><strong>Authoring Tool:</strong> Partially Supports</p></td>
<td><div data-qmd="**Software:** The CLI draws no non-text components. Its markers (the prompt pointer, check marks, the spinner) are text characters in the terminal's text colours.

**Web:** Sidebar toggles, the colour-scheme toggle, the code copy button,
and the gallery carousel controls meet 3:1, and controls that keep
the browser's default focus ring fall under the user-agent
exception. Tabs and the search field are identified by their text
and icons, so their faint borders are not needed. Screenshots of
Quarto output and editors fall under the exception for graphics
whose presentation is essential.

Known defects:

- The focus indicator on the navbar items and the &quot;On this page&quot;
  links is a faint halo, well below 3:1 in both colour schemes.
- Many callouts on the site have a custom title, so only the icon
  shows the callout type, and several icons are below 3:1: tip,
  warning, and caution in the light scheme, and note and important
  in the dark scheme.

**Authoring Tool:** Quarto's own icons meet 3:1 in both themes: the sidebar section
toggles, the navbar menu button, and the code copy button. The
current table-of-contents entry has a coloured left border that
meets 3:1, and tabs are identified by their text, so their faint
borders are not needed. Sidebar section toggles have a 2px outline
on focus, and the sidebar, search, code-tools, and copy buttons
keep the browser's own focus ring.

Known defects:

- In the default theme, the focus indicators on navbar items,
  table-of-contents links, and tabs do not meet contrast minimums.
- A callout's default title names its type, but when the author
  gives it a custom title, only the icon shows the type, and some
  icons are below 3:1: warning and caution in the default theme,
  and tip, warning, and caution in cosmo."></div></td>
</tr>
<tr>
<th scope="row"><div id="acr-1.4.12" class="acr-criterion"><a href="https://www.w3.org/TR/WCAG22/#text-spacing">1.4.12 Text Spacing</a> (Level AA 2.1 and 2.2)</div>
<div class="acr-also-applies">Also applies to:</div>
<p>EN 301 549 Criteria</p>
<ul>
<li>9.1.4.12 (Web)</li>
<li>10.1.4.12 (Non-web document)</li>
<li>11.1.4.12 (Open Functionality Software)</li>
<li>11.1.4.12 (Closed Software)</li>
<li>11.8.2 (Authoring Tool)</li>
<li>12.1.2 (Product Docs)</li>
<li>12.2.4 (Support Docs)</li>
</ul>
<p>Revised Section 508 – Does not apply</p></th>
<td><p><strong>Software:</strong> Supports</p>
<p><strong>Web:</strong> Partially Supports</p>
<p><strong>Authoring Tool:</strong> Supports</p></td>
<td><div data-qmd="**Software:** The terminal sets text spacing.

**Web:** With the text spacing overrides applied, no text is clipped or
overlapping on the home, documentation, reference, and tutorial
pages, at 1280px and at 320px.

Known defects:

- On the gallery page, the carousel captions overlap the bottom of
  the slide image."></div></td>
</tr>
<tr>
<th scope="row"><div id="acr-1.4.13" class="acr-criterion"><a href="https://www.w3.org/TR/WCAG22/#content-on-hover-or-focus">1.4.13 Content on Hover or Focus</a> (Level AA 2.1 and 2.2)</div>
<div class="acr-also-applies">Also applies to:</div>
<p>EN 301 549 Criteria</p>
<ul>
<li>9.1.4.13 (Web)</li>
<li>10.1.4.13 (Non-web document)</li>
<li>11.1.4.13 (Open Functionality Software)</li>
<li>11.1.4.13 (Closed Software)</li>
<li>11.8.2 (Authoring Tool)</li>
<li>12.1.2 (Product Docs)</li>
<li>12.2.4 (Support Docs)</li>
</ul>
<p>Revised Section 508 – Does not apply</p></th>
<td><p><strong>Software:</strong> Supports</p>
<p><strong>Web:</strong> Partially Supports</p>
<p><strong>Authoring Tool:</strong> Partially Supports</p></td>
<td><div data-qmd="**Software:** Nothing in the CLI appears on hover or focus.

**Web:** The footnote, citation, and cross-reference popups can be hovered
and stay open while the pointer is on them.

Known defects:

- The popups cannot be dismissed ([quarto-dev/quarto-cli#15080](https://github.com/quarto-dev/quarto-cli/issues/15080)).

**Authoring Tool:** Footnote, citation, and cross-reference popups can be hovered and
stay open while the pointer is on them.

Known defects:

- The popups cannot be dismissed ([quarto-dev/quarto-cli#15080](https://github.com/quarto-dev/quarto-cli/issues/15080))."></div></td>
</tr>
<tr>
<th scope="row"><div id="acr-2.4.5" class="acr-criterion"><a href="https://www.w3.org/TR/WCAG22/#multiple-ways">2.4.5 Multiple Ways</a> (Level AA)</div>
<div class="acr-also-applies">Also applies to:</div>
<p>EN 301 549 Criteria</p>
<ul>
<li>9.2.4.5 (Web)</li>
<li>10.2.4.5 (Non-web document) – Does not apply</li>
<li>11.2.4.5 (Open Functionality Software) – Does not apply</li>
<li>11.2.4.5 (Closed Software) – Does not apply</li>
<li>11.8.2 (Authoring Tool)</li>
<li>12.1.2 (Product Docs)</li>
<li>12.2.4 (Support Docs)</li>
</ul>
<p>Revised Section 508</p>
<ul>
<li>501 (Web)(Software) – Does not apply to non-web software</li>
<li>504.2 (Authoring Tool)</li>
<li>602.3 (Support Docs) – Does not apply to non-web docs</li>
</ul></th>
<td><p><strong>Web:</strong> Supports</p>
<p><strong>Authoring Tool:</strong> Supports</p></td>
<td><div data-qmd="**Authoring Tool:** A standalone document is a single page. On websites, the author can add a navbar or a sidebar in the site configuration. A site with either one also gets search, and a sidebar with nested sections also gives breadcrumbs. Authors can also link between pages in their text."></div></td>
</tr>
<tr>
<th scope="row"><div id="acr-2.4.6" class="acr-criterion"><a href="https://www.w3.org/TR/WCAG22/#headings-and-labels">2.4.6 Headings and Labels</a> (Level AA)</div>
<div class="acr-also-applies">Also applies to:</div>
<p>EN 301 549 Criteria</p>
<ul>
<li>9.2.4.6 (Web)</li>
<li>10.2.4.6 (Non-web document)</li>
<li>11.2.4.6 (Open Functionality Software)</li>
<li>11.2.4.6 (Closed Software)</li>
<li>11.8.2 (Authoring Tool)</li>
<li>12.1.2 (Product Docs)</li>
<li>12.2.4 (Support Docs)</li>
</ul>
<p>Revised Section 508</p>
<ul>
<li>501 (Web)(Software)</li>
<li>504.2 (Authoring Tool)</li>
<li>602.3 (Support Docs)</li>
</ul></th>
<td><p><strong>Software:</strong> Supports</p>
<p><strong>Web:</strong> Supports</p>
<p><strong>Authoring Tool:</strong> Supports</p></td>
<td><div data-qmd="**Software:** Help output is organised under `Usage`, `Options`, and `Commands` headings, and each interactive prompt is labelled with what it asks for.

**Authoring Tool:** Headings in the content keep the text the author writes. Quarto's
own headings and labels, such as &quot;On this page&quot;, describe their
topic or purpose."></div></td>
</tr>
<tr>
<th scope="row"><div id="acr-2.4.7" class="acr-criterion"><a href="https://www.w3.org/TR/WCAG22/#focus-visible">2.4.7 Focus Visible</a> (Level AA)</div>
<div class="acr-also-applies">Also applies to:</div>
<p>EN 301 549 Criteria</p>
<ul>
<li>9.2.4.7 (Web)</li>
<li>10.2.4.7 (Non-web document)</li>
<li>11.2.4.7 (Open Functionality Software)</li>
<li>11.2.4.7 (Closed Software)</li>
<li>11.8.2 (Authoring Tool)</li>
<li>12.1.2 (Product Docs)</li>
<li>12.2.4 (Support Docs)</li>
</ul>
<p>Revised Section 508</p>
<ul>
<li>501 (Web)(Software)</li>
<li>504.2 (Authoring Tool)</li>
<li>602.3 (Support Docs)</li>
</ul></th>
<td><p><strong>Software:</strong> Supports</p>
<p><strong>Web:</strong> Partially Supports</p>
<p><strong>Authoring Tool:</strong> Partially Supports</p></td>
<td><div data-qmd="**Software:** In list prompts the current option is marked with a `❯` pointer; at text prompts the terminal's cursor marks the insertion point.

**Web:** Focus is visible on links in the text, the sidebar links and
toggles, heading anchors, carousel controls, code tools, and the
search input. Navbar items and the &quot;On this page&quot; links show a
faint halo on focus; its low contrast is reported under
[1.4.11](#acr-1.4.11).

Known defects:

- The &quot;Supported by Posit&quot; badge link in the navbar has no visible
  focus indicator ([posit-dev/supported-by-posit#1](https://github.com/posit-dev/supported-by-posit/issues/1)).
- When content in the right margin collapses the &quot;On this page&quot;
  table of contents into a toggle, its links still take focus
  while they are hidden, so focus disappears for several Tab
  presses ([quarto-dev/quarto-cli#14969](https://github.com/quarto-dev/quarto-cli/issues/14969)).

**Authoring Tool:** Focus is visible on links in the text, sidebar links and toggles,
heading anchors, and the code-tools, copy, sidebar, and search
buttons. Navbar items, table-of-contents links, and tabs show a
faint halo on focus; its low contrast is reported under
[1.4.11](#acr-1.4.11).

Known defects, only in content the author adds:

- When content in the right margin collapses the &quot;On this page&quot;
  table of contents into a toggle, its links still take focus
  while they are hidden, so focus disappears for several Tab
  presses ([quarto-dev/quarto-cli#14969](https://github.com/quarto-dev/quarto-cli/issues/14969))."></div></td>
</tr>
<tr>
<th scope="row"><div id="acr-2.4.11" class="acr-criterion"><a href="https://www.w3.org/TR/WCAG22/#focus-not-obscured-minimum">2.4.11 Focus Not Obscured (Minimum)</a> (Level AA 2.2 only)</div>
<div class="acr-also-applies">Also applies to:</div>
<p>EN 301 549 Criteria – Does not apply</p>
<p>Revised Section 508 – Does not apply</p></th>
<td><p><strong>Web:</strong> Partially Supports</p></td>
<td><div data-qmd="**Web:** Moving down a page with Tab, nothing covers the focused item.

Known defects:

- Moving back up with Shift+Tab, the focused item is sometimes
  hidden completely behind the sticky navbar: heading anchors,
  code copy buttons, and listing links, at both 1280px and 320px.
- The search overlay does not keep focus inside it, and once focus
  leaves, the overlay hides the focused items in the page behind
  it.
- A footnote, citation, or cross-reference popup that stays open
  after focus moves on can cover the newly focused link at narrow
  widths ([quarto-dev/quarto-cli#15080](https://github.com/quarto-dev/quarto-cli/issues/15080))."></div></td>
</tr>
<tr>
<th scope="row"><div id="acr-2.5.7" class="acr-criterion"><a href="https://www.w3.org/TR/WCAG22/#dragging-movements">2.5.7 Dragging Movements</a> (Level AA 2.2 only)</div>
<div class="acr-also-applies">Also applies to:</div>
<p>EN 301 549 Criteria – Does not apply</p>
<p>Revised Section 508 – Does not apply</p></th>
<td><p><strong>Web:</strong> Supports</p></td>
<td><div data-qmd="**Web:** No function on the site needs a dragging movement."></div></td>
</tr>
<tr>
<th scope="row"><div id="acr-2.5.8" class="acr-criterion"><a href="https://www.w3.org/TR/WCAG22/#target-size-minimum">2.5.8 Target Size (Minimum)</a> (Level AA 2.2 only)</div>
<div class="acr-also-applies">Also applies to:</div>
<p>EN 301 549 Criteria – Does not apply</p>
<p>Revised Section 508 – Does not apply</p></th>
<td><p><strong>Web:</strong> Partially Supports</p></td>
<td><div data-qmd="**Web:** Navbar and footer icons, code copy buttons, breadcrumbs, menu
items, and footer links meet the minimum size or the spacing
exception.

Known defects:

- The sidebar's section toggles and page links are under 24 px and
  too close together for the spacing exception
  ([quarto-dev/quarto-cli#15096](https://github.com/quarto-dev/quarto-cli/issues/15096))."></div></td>
</tr>
<tr>
<th scope="row"><div id="acr-3.1.2" class="acr-criterion"><a href="https://www.w3.org/TR/WCAG22/#language-of-parts">3.1.2 Language of Parts</a> (Level AA)</div>
<div class="acr-also-applies">Also applies to:</div>
<p>EN 301 549 Criteria</p>
<ul>
<li>9.3.1.2 (Web)</li>
<li>10.3.1.2 (Non-web document)</li>
<li>11.3.1.2 (Open Functionality Software) – Does not apply</li>
<li>11.3.1.2 (Closed Software) – Does not apply</li>
<li>11.8.2 (Authoring Tool)</li>
<li>12.1.2 (Product Docs)</li>
<li>12.2.4 (Support Docs)</li>
</ul>
<p>Revised Section 508</p>
<ul>
<li>501 (Web)(Software)</li>
<li>504.2 (Authoring Tool)</li>
<li>602.3 (Support Docs)</li>
</ul></th>
<td><p><strong>Software:</strong> Supports</p>
<p><strong>Web:</strong> Supports</p>
<p><strong>Authoring Tool:</strong> Supports</p></td>
<td><div data-qmd="**Software:** The CLI emits plain text, which has no language metadata. All CLI text is in English.

**Web:** The site has no passage in a language other than English.

**Authoring Tool:** Quarto's own interface text follows the document language; the author marks passages in another language with `lang`."></div></td>
</tr>
<tr>
<th scope="row"><div id="acr-3.2.3" class="acr-criterion"><a href="https://www.w3.org/TR/WCAG22/#consistent-navigation">3.2.3 Consistent Navigation</a> (Level AA)</div>
<div class="acr-also-applies">Also applies to:</div>
<p>EN 301 549 Criteria</p>
<ul>
<li>9.3.2.3 (Web)</li>
<li>10.3.2.3 (Non-web document) – Does not apply</li>
<li>11.3.2.3 (Open Functionality Software) – Does not apply</li>
<li>11.3.2.3 (Closed Software) – Does not apply</li>
<li>11.8.2 (Authoring Tool)</li>
<li>12.1.2 (Product Docs)</li>
<li>12.2.4 (Support Docs)</li>
</ul>
<p>Revised Section 508</p>
<ul>
<li>501 (Web)(Software) – Does not apply to non-web software</li>
<li>504.2 (Authoring Tool)</li>
<li>602.3 (Support Docs) – Does not apply to non-web docs</li>
</ul></th>
<td><p><strong>Web:</strong> Supports</p>
<p><strong>Authoring Tool:</strong> Supports</p></td>
<td></td>
</tr>
<tr>
<th scope="row"><div id="acr-3.2.4" class="acr-criterion"><a href="https://www.w3.org/TR/WCAG22/#consistent-identification">3.2.4 Consistent Identification</a> (Level AA)</div>
<div class="acr-also-applies">Also applies to:</div>
<p>EN 301 549 Criteria</p>
<ul>
<li>9.3.2.4 (Web)</li>
<li>10.3.2.4 (Non-web document) – Does not apply</li>
<li>11.3.2.4 (Open Functionality Software) – Does not apply</li>
<li>11.3.2.4 (Closed Software) – Does not apply</li>
<li>11.8.2 (Authoring Tool)</li>
<li>12.1.2 (Product Docs)</li>
<li>12.2.4 (Support Docs)</li>
</ul>
<p>Revised Section 508</p>
<ul>
<li>501 (Web)(Software) – Does not apply to non-web software</li>
<li>504.2 (Authoring Tool)</li>
<li>602.3 (Support Docs) – Does not apply to non-web docs</li>
</ul></th>
<td><p><strong>Web:</strong> Supports</p>
<p><strong>Authoring Tool:</strong> Supports</p></td>
<td></td>
</tr>
<tr>
<th scope="row"><div id="acr-3.3.3" class="acr-criterion"><a href="https://www.w3.org/TR/WCAG22/#error-suggestion">3.3.3 Error Suggestion</a> (Level AA)</div>
<div class="acr-also-applies">Also applies to:</div>
<p>EN 301 549 Criteria</p>
<ul>
<li>9.3.3.3 (Web)</li>
<li>10.3.3.3 (Non-web document)</li>
<li>11.3.3.3 (Open Functionality Software)</li>
<li>11.3.3.3 (Closed Software)</li>
<li>11.8.2 (Authoring Tool)</li>
<li>12.1.2 (Product Docs)</li>
<li>12.2.4 (Support Docs)</li>
</ul>
<p>Revised Section 508</p>
<ul>
<li>501 (Web)(Software)</li>
<li>504.2 (Authoring Tool)</li>
<li>602.3 (Support Docs)</li>
</ul></th>
<td><p><strong>Software:</strong> Supports</p>
<p><strong>Web:</strong> Supports</p>
<p><strong>Authoring Tool:</strong> Supports</p></td>
<td><div data-qmd="**Software:** A mistyped command gets a suggestion (`Did you mean command &quot;render&quot;?`), and YAML validation errors say what the value must be.

**Web:** Search is the site's only form and takes any text, so there is no input error to suggest a correction for.

**Authoring Tool:** Search is the only form in default output and takes any text, so there is no input error to suggest a correction for."></div></td>
</tr>
<tr>
<th scope="row"><div id="acr-3.3.4" class="acr-criterion"><a href="https://www.w3.org/TR/WCAG22/#error-prevention-legal-financial-data">3.3.4 Error Prevention (Legal, Financial, Data)</a> (Level AA)</div>
<div class="acr-also-applies">Also applies to:</div>
<p>EN 301 549 Criteria</p>
<ul>
<li>9.3.3.4 (Web)</li>
<li>10.3.3.4 (Non-web document)</li>
<li>11.3.3.4 (Open Functionality Software)</li>
<li>11.3.3.4 (Closed Software)</li>
<li>11.8.2 (Authoring Tool)</li>
<li>12.1.2 (Product Docs)</li>
<li>12.2.4 (Support Docs)</li>
</ul>
<p>Revised Section 508</p>
<ul>
<li>501 (Web)(Software)</li>
<li>504.2 (Authoring Tool)</li>
<li>602.3 (Support Docs)</li>
</ul></th>
<td><p><strong>Software:</strong> Supports</p>
<p><strong>Web:</strong> Supports</p>
<p><strong>Authoring Tool:</strong> Supports</p></td>
<td><div data-qmd="**Software:** Publishing or updating a site, installing or removing extensions, and overwriting files ask for confirmation first; `--no-prompt` is an explicit opt-out.

**Web:** The site has no legal, financial, or data-changing submissions and no test responses.

**Authoring Tool:** Default output has no legal, financial, or data-changing submissions."></div></td>
</tr>
<tr>
<th scope="row"><div id="acr-3.3.8" class="acr-criterion"><a href="https://www.w3.org/TR/WCAG22/#accessible-authentication-minimum">3.3.8 Accessible Authentication (Minimum)</a> (Level AA 2.2 only)</div>
<div class="acr-also-applies">Also applies to:</div>
<p>EN 301 549 Criteria – Does not apply</p>
<p>Revised Section 508 – Does not apply</p></th>
<td><p><strong>Web:</strong> Supports</p></td>
<td><div data-qmd="**Web:** The site has no login or other authentication."></div></td>
</tr>
<tr>
<th scope="row"><div id="acr-4.1.3" class="acr-criterion"><a href="https://www.w3.org/TR/WCAG22/#status-messages">4.1.3 Status Messages</a> (Level AA 2.1 and 2.2)</div>
<div class="acr-also-applies">Also applies to:</div>
<p>EN 301 549 Criteria</p>
<ul>
<li>9.4.1.3 (Web)</li>
<li>10.4.1.3 (Non-web document)</li>
<li>11.4.1.3 (Open Functionality Software)</li>
<li>11.4.1.3 (Closed Software) – Does not apply</li>
<li>11.8.2 (Authoring Tool)</li>
<li>12.1.2 (Product Docs)</li>
<li>12.2.4 (Support Docs)</li>
</ul>
<p>Revised Section 508 – Does not apply</p></th>
<td><p><strong>Software:</strong> Partially Supports</p>
<p><strong>Web:</strong> Partially Supports</p>
<p><strong>Authoring Tool:</strong> Partially Supports</p></td>
<td><div data-qmd="**Software:** Status messages (`Output created`, `Watching files for changes`,
the `[✓]` lines of `check`, the preview re-render block) are text
that the terminal exposes to assistive technology.

Known defects:

- In list prompts, moving the pointer and toggling an item are not
  announced.
- The `Open With` prompt of `quarto create` is not announced.
- In `quarto check` and a multi-file `render`, each new line
  interrupts the one being read, so `check` cannot be followed by
  ear.

**Web:** The &quot;Copied!&quot; confirmation on code copy buttons is announced by
screen readers.

Known defects:

- Neither the search results nor a &quot;no results&quot; message is
  announced as you type in the search box.

**Authoring Tool:** The &quot;Copied!&quot; confirmation on code copy buttons is announced by
screen readers.

Known defects:

- Neither the search results nor a &quot;no results&quot; message is
  announced as the reader types in the search box."></div></td>
</tr>
</tbody>
</table>
```

:::

### Table 3: Success Criteria, Level AAA {#acr-tbl-wcag-aaa}

Notes:

Not Applicable. We did not assess Quarto for WCAG 2.2 Level AAA
conformance.

## Revised Section 508 Report

### Chapter 3: [Functional Performance Criteria](https://www.access-board.gov/ict/#chapter-3-functional-performance-criteria) (FPC) {#acr-tbl-sec508-fpc}

Notes:

Each row is answered for three aspects of Quarto. **Software** is the Quarto CLI, used in a terminal. **Web** is the documentation at [quarto.org](https://quarto.org). **Authoring Tool** is the HTML that Quarto produces by default, for the people who read it. Each part summarises the WCAG rows it links to.

A row is Supports only if every aspect that the criterion applies to supports it, and Does Not Support only if none does. A mix is Partially Supports. An aspect that the criterion does not apply to is not counted in the level.

::: {.column-page}

```{=html}
<table class="table acr-table acr-criteria acr-fpc" aria-labelledby="acr-tbl-sec508-fpc">
<colgroup>
<col style="width: 25%">
<col style="width: 15%">
<col style="width: 60%">
</colgroup>
<thead>
<tr>
<th scope="col">Criteria</th>
<th scope="col">Conformance Level</th>
<th scope="col">Remarks and Explanations</th>
</tr>
</thead>
<tbody>
<tr>
<th scope="row"><div id="acr-302.1">302.1 Without Vision</div></th>
<td>Partially Supports</td>
<td><div data-qmd="**Software:** A screen reader user can run commands and hear their output,
error messages, and help, and commands that prompt accept
`--no-prompt`.

Known defects:

- In interactive prompts, moving through a list or checking an
  item is not announced, and two prompts of `quarto create` are
  not announced in full ([1.1.1](#acr-1.1.1),
  [3.3.2](#acr-3.3.2), [4.1.3](#acr-4.1.3)).
- `quarto check` cannot be followed by ear, because each new
  line cuts off the one being read ([4.1.3](#acr-4.1.3),
  [502.3.14](#acr-502.3.14)).

**Web:** A screen reader user can read and move through the documentation
by its landmarks, headings, and links.

Known defects:

- Images in the home page animation have no name
  ([1.1.1](#acr-1.1.1)).
- Collapsed callouts, and the &quot;On this page&quot; toggle that
  replaces the table of contents when content extends into the
  right margin, have no role or state ([4.1.2](#acr-4.1.2)).
- Search results are not announced ([4.1.3](#acr-4.1.3)).
- The tutorial videos have no audio description
  ([1.2.3](#acr-1.2.3), [1.2.5](#acr-1.2.5)).
- The `kbd` shortcode with only operating-system keyword
  arguments gives screen readers no text for the shortcut, and
  its text is read after the sentence that contains it
  ([1.3.1](#acr-1.3.1), [1.3.2](#acr-1.3.2)).
- Margin citations keep `role=&quot;listitem&quot;` after their list
  parent is removed ([1.3.1](#acr-1.3.1)).
- The previous and next page links are named by the target page
  title alone, so a screen reader does not say which goes back
  and which forward ([1.3.1](#acr-1.3.1)).
- The search button is out of place in the Tab order, the search
  overlay does not trap focus, and closing it returns focus to
  the top of the page ([2.4.3](#acr-2.4.3)).
- Footnote back-links are named only by an arrow
  ([2.4.4](#acr-2.4.4)).

**Authoring Tool:** Default output gives screen readers landmarks, headings, the
author's alternative text, and spoken equations.

Known defects, in website search, which is on by default with a
navbar or sidebar:

- Search results are not announced ([4.1.3](#acr-4.1.3)).
- The search button is out of place in the Tab order, the search
  overlay does not trap focus, and closing it returns focus to
  the top of the page ([2.4.3](#acr-2.4.3)).

Known defects, each only in content the author chooses to add:

- Images from the `placeholder` shortcode have no alternative
  text ([1.1.1](#acr-1.1.1)).
- Callouts set to collapse have no role or state
  ([4.1.2](#acr-4.1.2)).
- Footnote back-links are named only by an arrow
  ([2.4.4](#acr-2.4.4)).
- A local video file added with the `video` shortcode cannot be
  given an audio description ([1.2.3](#acr-1.2.3),
  [1.2.5](#acr-1.2.5)).
- The `kbd` shortcode with only operating-system keyword
  arguments gives screen readers no text for the shortcut, and
  its text is read after the sentence that contains it
  ([1.3.1](#acr-1.3.1), [1.3.2](#acr-1.3.2)).
- Margin citations keep `role=&quot;listitem&quot;` after their list
  parent is removed ([1.3.1](#acr-1.3.1)).
- Page navigation links are named by the target page title
  alone, so a screen reader does not say which goes back and
  which forward ([1.3.1](#acr-1.3.1)).
- Closing the `code-tools` source window returns focus to the
  top of the page ([2.4.3](#acr-2.4.3))."></div></td>
</tr>
<tr>
<th scope="row"><div id="acr-302.2">302.2 With Limited Vision</div></th>
<td>Partially Supports</td>
<td><div data-qmd="**Software:** The terminal draws the CLI's text, so its size, font, colour, and contrast follow the terminal's settings and the platform's zoom (see [503.2](#acr-503.2)). Help text re-wraps to the width of the window.

**Web:** Text resizes and pages reflow.

Known defects:

- At 200% zoom and at narrow widths the &quot;On this page&quot; table of
  contents is hidden ([1.4.4](#acr-1.4.4),
  [1.4.10](#acr-1.4.10)).
- Some pages scroll sideways at 320px ([1.4.10](#acr-1.4.10)).
- The focus indicator on navbar items is faint
  ([1.4.11](#acr-1.4.11), [2.4.7](#acr-2.4.7)).
- Footnote popups cannot be dismissed ([1.4.13](#acr-1.4.13)).
- With text spacing overrides applied, the gallery carousel
  captions overlap the slide image ([1.4.12](#acr-1.4.12)).
- Moving back up a page with Shift+Tab, the focused item can be
  hidden behind the sticky navbar, and the search overlay and
  open popups can cover the focused item
  ([2.4.11](#acr-2.4.11)).

**Authoring Tool:** Text resizes and pages reflow.

Known defects:

- Some secondary text is below 4.5:1 ([1.4.3](#acr-1.4.3)).
- The focus indicator on navbar items and tabs is faint
  ([1.4.11](#acr-1.4.11), [2.4.7](#acr-2.4.7)).
- At 200% zoom and at narrow widths the table of contents is
  hidden ([1.4.4](#acr-1.4.4), [1.4.10](#acr-1.4.10)).
- Only in content the author adds: wide equations make the page
  scroll sideways at 320px ([1.4.10](#acr-1.4.10)).
- Only in content the author adds: footnote, citation, and
  cross-reference popups cannot be dismissed, but the author can
  turn them off ([1.4.13](#acr-1.4.13))."></div></td>
</tr>
<tr>
<th scope="row"><div id="acr-302.3">302.3 Without Perception of Color</div></th>
<td>Partially Supports</td>
<td><div data-qmd="**Software:** No information is shown by colour alone: errors and warnings have a text prefix, and the current option in a prompt has a pointer. With `NO_COLOR` set, the output text is the same. See [1.4.1](#acr-1.4.1).

**Web:** Links in running text are underlined, so they can be found
without telling colours apart, and elsewhere colour has a second
cue.

Known defects, in the site navigation:

- The sidebar marks the current page by colour alone
  ([1.4.1](#acr-1.4.1)).
- The navbar marks the current section by colour alone
  ([1.4.1](#acr-1.4.1)).

**Authoring Tool:** Quarto's default style underlines links in running text, so they
can be found without telling colours apart, and gives colour a
second cue elsewhere.

Known defects, in website navigation:

- The sidebar marks the current page by colour alone
  ([1.4.1](#acr-1.4.1)).
- The navbar marks the current section by colour alone
  ([1.4.1](#acr-1.4.1))."></div></td>
</tr>
<tr>
<th scope="row"><div id="acr-302.4">302.4 Without Hearing</div></th>
<td>Partially Supports</td>
<td><div data-qmd="**Software:** The CLI makes no sound.

**Web:** Both tutorial videos have captions.

Known defects:

- On one of them the captions are generated automatically and
  mistranscribe &quot;Quarto&quot; ([1.2.2](#acr-1.2.2)).

**Authoring Tool:** Hosted videos show the host's captions.

Known defects:

- For a local video file, the `video` shortcode gives no way to
  attach captions ([1.2.2](#acr-1.2.2), [7.1.1](#acr-7.1.1))."></div></td>
</tr>
<tr>
<th scope="row"><div id="acr-302.5">302.5 With Limited Hearing</div></th>
<td>Partially Supports</td>
<td><div data-qmd="**Software:** The CLI makes no sound.

**Web:** Captions are available for both tutorial videos.

Known defects:

- On one of them the captions are generated automatically and
  mistranscribe &quot;Quarto&quot; ([1.2.2](#acr-1.2.2)).

**Authoring Tool:** Hosted videos show the host's captions.

Known defects:

- For a local video file, the `video` shortcode gives no way to
  attach captions ([1.2.2](#acr-1.2.2), [7.1.1](#acr-7.1.1))."></div></td>
</tr>
<tr>
<th scope="row"><div id="acr-302.6">302.6 Without Speech</div></th>
<td>Not Applicable</td>
<td><div data-qmd="Quarto does not use speech for input, control, or operation."></div></td>
</tr>
<tr>
<th scope="row"><div id="acr-302.7">302.7 With Limited Manipulation</div></th>
<td>Partially Supports</td>
<td><div data-qmd="**Software:** All input is typed text and single keys. The only key combination is Ctrl+C, and closing the terminal tab does the same (see [5.9](#acr-5.9)).

**Web:** Navigation, search, menus, and tabsets work from the keyboard.

Known defects:

- Collapsed callouts, code annotation markers, and the &quot;On this
  page&quot; toggle that replaces the table of contents when content
  extends into the right margin do not work from the keyboard
  ([2.1.1](#acr-2.1.1)).
- The single-key search shortcuts cannot be turned off
  ([2.1.4](#acr-2.1.4)).
- The sidebar's links and toggles are small and close together
  ([2.5.8](#acr-2.5.8)).

**Authoring Tool:** Navigation, search, sidebar sections, and tabsets work from the
keyboard.

Known defects:

- Readers cannot turn off the single-key search shortcuts,
  though an author can, with the `keyboard-shortcut` search
  option ([2.1.4](#acr-2.1.4)).
- Only in content the author adds: collapsed callouts, code
  annotation markers, and the &quot;On this page&quot; toggle that
  replaces the table of contents when content extends into the
  right margin do not work from the keyboard
  ([2.1.1](#acr-2.1.1))."></div></td>
</tr>
<tr>
<th scope="row"><div id="acr-302.8">302.8 With Limited Reach and Strength</div></th>
<td>Supports</td>
<td><div data-qmd="**Software:** No action needs force or a held key: input is typed text, single keys, and Ctrl+C (see [5.9](#acr-5.9)).

**Web:** No action needs force, a held key, or a long reach. Every control works with a single click or keystroke, and the controls that do not work from the keyboard work with a mouse or other pointing device (see [302.7](#acr-302.7)).

**Authoring Tool:** No action in Quarto's output needs force, a held key, or a long reach. Every control works with a single click or keystroke, and the controls that do not work from the keyboard work with a mouse or other pointing device (see [302.7](#acr-302.7))."></div></td>
</tr>
<tr>
<th scope="row"><div id="acr-302.9">302.9 With Limited Language, Cognitive, and Learning Abilities</div></th>
<td>Partially Supports</td>
<td><div data-qmd="**Software:** Help output is organised under `Usage`, `Options`, and `Commands` headings, and every prompt is labelled, with a hint that names the keys to use. Prompts wait with no time limit, and publishing, installing, or overwriting files asks for confirmation first. Errors start with `ERROR:` and say what the value must be, and a mistyped command gets a suggestion. We did not assess reading level or plain language. See [2.2.1](#acr-2.2.1), [2.4.6](#acr-2.4.6), [3.3.1](#acr-3.3.1), [3.3.3](#acr-3.3.3), and [3.3.4](#acr-3.3.4).

**Web:** Navigation, labels, and help links are in the same place and
order on every page, and pages have descriptive titles and
headings. The site sets no time limits and has no login or
multi-step process. We did not assess reading level or plain
language. See [2.2.1](#acr-2.2.1), [2.4.2](#acr-2.4.2),
[2.4.6](#acr-2.4.6), [3.2.3](#acr-3.2.3), [3.2.4](#acr-3.2.4),
[3.2.6](#acr-3.2.6), [3.3.7](#acr-3.3.7), and
[3.3.8](#acr-3.3.8).

Known defects:

- The home page animation, the gallery carousel, and the looping
  demo GIFs start on their own and cannot be paused
  ([2.2.2](#acr-2.2.2)).
- The search button is out of place in the Tab order, and
  closing the search returns focus to the top of the page
  ([2.4.3](#acr-2.4.3)).

**Authoring Tool:** Navigation and labels are consistent from page to page, and the
page title combines the document and site titles. Default output
sets no time limits and has no moving content. We did not assess
reading level or plain language. See
[2.2.1](#acr-2.2.1), [2.2.2](#acr-2.2.2), [2.4.2](#acr-2.4.2),
[3.2.3](#acr-3.2.3), and [3.2.4](#acr-3.2.4).

Known defects:

- The search button is out of place in the Tab order, and
  closing the search or the `code-tools` source window returns
  focus to the top of the page ([2.4.3](#acr-2.4.3))."></div></td>
</tr>
</tbody>
</table>
```

:::

### Chapter 4: [Hardware](https://www.access-board.gov/ict/#chapter-4-hardware) {#acr-tbl-sec508-hardware}

Notes:

Not Applicable. Quarto is software — a command-line tool and its
documentation website — and includes no hardware component.

### Chapter 5: [Software](https://www.access-board.gov/ict/#chapter-5-software) {#acr-tbl-sec508-software}

Notes:

Chapter 5 addresses two aspects of Quarto: 501–503 concern the Quarto CLI (**Software**), and 504 concerns Quarto as an **Authoring Tool**.

::: {.column-page}

```{=html}
<table class="table acr-table acr-criteria" aria-labelledby="acr-tbl-sec508-software">
<colgroup>
<col style="width: 25%">
<col style="width: 15%">
<col style="width: 60%">
</colgroup>
<thead>
<tr>
<th scope="col">Criteria</th>
<th scope="col">Conformance Level</th>
<th scope="col">Remarks and Explanations</th>
</tr>
</thead>
<tbody>
<tr>
<th scope="row"><div id="acr-501.1">501.1 Scope – Incorporation of WCAG 2.0 AA</div></th>
<td>See <a href="#wcag-report">WCAG 2.2 section</a></td>
<td><div data-qmd="See information in WCAG 2.2 section"></div></td>
</tr>
<tr>
<th scope="row" class="acr-heading"><div id="acr-502"><a href="https://www.access-board.gov/ict/#502-interoperability-assistive-technology">502 Interoperability with Assistive Technology</a></div></th>
<td>Heading cell – no response required</td>
<td><div data-qmd="Heading cell – no response required"></div></td>
</tr>
<tr>
<th scope="row"><div id="acr-502.2.1">502.2.1 User Control of Accessibility Features</div></th>
<td>Not Applicable</td>
<td><div data-qmd="Quarto is not a platform."></div></td>
</tr>
<tr>
<th scope="row"><div id="acr-502.2.2">502.2.2 No Disruption of Accessibility Features</div></th>
<td>Supports</td>
<td><div data-qmd="The CLI writes text to the terminal and asks for keystrokes only while a prompt is open. It changes no platform or terminal setting and honors `NO_COLOR`."></div></td>
</tr>
<tr>
<th scope="row" class="acr-heading"><div id="acr-502.3">502.3 Accessibility Services</div></th>
<td>Heading cell – no response required</td>
<td><div data-qmd="Heading cell – no response required"></div></td>
</tr>
<tr>
<th scope="row"><div id="acr-502.3.1">502.3.1 Object Information</div></th>
<td>Supports</td>
<td><div data-qmd="The CLI's prompts and messages are text in the terminal, and the terminal exposes that text, its extent, and the cursor to assistive technology through the platform's accessibility services. The CLI creates no user interface objects of its own."></div></td>
</tr>
<tr>
<th scope="row"><div id="acr-502.3.2">502.3.2 Modification of Object Information</div></th>
<td>Supports</td>
<td><div data-qmd="The only state the CLI keeps, the current option and the checked items in a prompt, is shown as text and changed by keystrokes, which the terminal passes through from any input method."></div></td>
</tr>
<tr>
<th scope="row"><div id="acr-502.3.3">502.3.3 Row, Column, and Headers</div></th>
<td>Not Applicable</td>
<td><div data-qmd="The CLI displays no data tables. Help output aligns names and descriptions in columns of text."></div></td>
</tr>
<tr>
<th scope="row"><div id="acr-502.3.4">502.3.4 Values</div></th>
<td>Supports</td>
<td><div data-qmd="The only values the CLI holds are prompt answers, shown as text: the current option, the checked items, and the typed text."></div></td>
</tr>
<tr>
<th scope="row"><div id="acr-502.3.5">502.3.5 Modification of Values</div></th>
<td>Supports</td>
<td><div data-qmd="Prompt answers are set by keystrokes, which assistive technology can send through the terminal."></div></td>
</tr>
<tr>
<th scope="row"><div id="acr-502.3.6">502.3.6 Label Relationships</div></th>
<td>Supports</td>
<td><div data-qmd="Each prompt's label is text on the same line as its input."></div></td>
</tr>
<tr>
<th scope="row"><div id="acr-502.3.7">502.3.7 Hierarchical Relationships</div></th>
<td>Not Applicable</td>
<td><div data-qmd="The CLI has no component hierarchy; its output is a sequence of lines."></div></td>
</tr>
<tr>
<th scope="row"><div id="acr-502.3.8">502.3.8 Text</div></th>
<td>Supports</td>
<td><div data-qmd="All of the CLI's output is text in the terminal, which exposes its content and extent to assistive technology."></div></td>
</tr>
<tr>
<th scope="row"><div id="acr-502.3.9">502.3.9 Modification of Text</div></th>
<td>Supports</td>
<td><div data-qmd="Text typed at a prompt can be entered by any input method the terminal accepts, including assistive technology."></div></td>
</tr>
<tr>
<th scope="row"><div id="acr-502.3.10">502.3.10 List of Actions</div></th>
<td>Supports</td>
<td><div data-qmd="The CLI's actions are its commands and options, listed by `--help`, and the keys each prompt accepts, named in the prompt's hint."></div></td>
</tr>
<tr>
<th scope="row"><div id="acr-502.3.11">502.3.11 Actions on Objects</div></th>
<td>Supports</td>
<td><div data-qmd="Every action is a typed command or a keystroke, which assistive technology can send through the terminal."></div></td>
</tr>
<tr>
<th scope="row"><div id="acr-502.3.12">502.3.12 Focus Cursor</div></th>
<td>Supports</td>
<td><div data-qmd="The terminal's cursor marks the insertion point, and in list prompts the `❯` pointer marks the current option as text."></div></td>
</tr>
<tr>
<th scope="row"><div id="acr-502.3.13">502.3.13 Modification of Focus Cursor</div></th>
<td>Supports</td>
<td><div data-qmd="The pointer in a list prompt moves with the arrow keys, which assistive technology can send through the terminal."></div></td>
</tr>
<tr>
<th scope="row"><div id="acr-502.3.14">502.3.14 Event Notification</div></th>
<td>Partially Supports</td>
<td><div data-qmd="The CLI's state changes are written to the terminal as text, which
the terminal exposes to assistive technology.

Known defects:

- In its list prompts, moving the pointer and checking or
  unchecking an item redraw the line in place and are not
  announced by a screen reader ([4.1.3](#acr-4.1.3)).
- The `Open With` prompt of `quarto create` is not announced at
  all ([4.1.3](#acr-4.1.3))."></div></td>
</tr>
<tr>
<th scope="row"><div id="acr-502.4">502.4 Platform Accessibility Features</div></th>
<td>Not Applicable</td>
<td><div data-qmd="Quarto is not a platform."></div></td>
</tr>
<tr>
<th scope="row" class="acr-heading"><div id="acr-503"><a href="https://www.access-board.gov/ict/#503-applications">503 Applications</a></div></th>
<td>Heading cell – no response required</td>
<td><div data-qmd="Heading cell – no response required"></div></td>
</tr>
<tr>
<th scope="row"><div id="acr-503.2">503.2 User Preferences</div></th>
<td>Supports</td>
<td><div data-qmd="The terminal draws the CLI's text, so colour, contrast, font, size, and the cursor follow the terminal's settings. The CLI selects colours by palette index only and honors `NO_COLOR`."></div></td>
</tr>
<tr>
<th scope="row"><div id="acr-503.3">503.3 Alternative User Interfaces</div></th>
<td>Not Applicable</td>
<td><div data-qmd="Quarto provides no alternative user interface functioning as assistive technology."></div></td>
</tr>
<tr>
<th scope="row" class="acr-heading"><div id="acr-503.4">503.4 User Controls for Captions and Audio Description</div></th>
<td>Heading cell – no response required</td>
<td><div data-qmd="Heading cell – no response required"></div></td>
</tr>
<tr>
<th scope="row"><div id="acr-503.4.1">503.4.1 Caption Controls</div></th>
<td>Not Applicable</td>
<td><div data-qmd="The Quarto CLI does not display video."></div></td>
</tr>
<tr>
<th scope="row"><div id="acr-503.4.2">503.4.2 Audio Description Controls</div></th>
<td>Not Applicable</td>
<td><div data-qmd="The Quarto CLI does not display video."></div></td>
</tr>
<tr>
<th scope="row" class="acr-heading"><div id="acr-504"><a href="https://www.access-board.gov/ict/#504-authoring-tools">504 Authoring Tools</a></div></th>
<td>Heading cell – no response required</td>
<td><div data-qmd="Heading cell – no response required"></div></td>
</tr>
<tr>
<th scope="row"><div id="acr-504.2">504.2 Content Creation or Editing (if not authoring tool, enter “not applicable”)</div></th>
<td>See <a href="#wcag-report">WCAG 2.2 section</a></td>
<td><div data-qmd="See information in WCAG 2.2 section"></div></td>
</tr>
<tr>
<th scope="row"><div id="acr-504.2.1">504.2.1 Preservation of Information Provided for Accessibility in Format Conversion</div></th>
<td>Supports</td>
<td><div data-qmd="Converting a Quarto document to HTML keeps the accessibility information in the source: alternative text, document language, title, heading levels, table captions and header cells, and footnote and citation roles reach the output. PDF output is outside this report."></div></td>
</tr>
<tr>
<th scope="row"><div id="acr-504.2.2">504.2.2 PDF Export</div></th>
<td>Supports</td>
<td><div data-qmd="Quarto can export PDF/UA: the `pdf-standard` option accepts `ua-1` with Typst and `ua-2` with LaTeX, and the result is validated with veraPDF when it is installed. We did not assess whether the PDF files conform, or PDF output otherwise."></div></td>
</tr>
<tr>
<th scope="row"><div id="acr-504.3">504.3 Prompts</div></th>
<td>Partially Supports</td>
<td><div data-qmd="The opt-in `axe` document option reports WCAG
failures axe-core can detect in the rendered page.

Known gaps:

- Quarto does not prompt authors for accessibility information:
  `quarto create` asks only for the project type, directory, and
  title.
- Rendering to HTML gives no warning when, for example, an image
  has no alternative text."></div></td>
</tr>
<tr>
<th scope="row"><div id="acr-504.4">504.4 Templates</div></th>
<td>Partially Supports</td>
<td><div data-qmd="The project templates of `quarto create` (default, website, blog,
book, manuscript) let authors create accessible content.

Known defects:

- None of them gives fully conforming output. The website template
  adds no defects of its own, but its pages have the same defects
  as Quarto's default output reported in the WCAG table for the
  Authoring Tool.
- The blog template also ships an image without alternative text
  and two links without names ([quarto-dev/quarto-cli#15038](https://github.com/quarto-dev/quarto-cli/issues/15038),
  [quarto-dev/quarto-cli#14828](https://github.com/quarto-dev/quarto-cli/issues/14828))."></div></td>
</tr>
</tbody>
</table>
```

:::

### Chapter 6: [Support Documentation and Services](https://www.access-board.gov/ict/#chapter-6-support-documentation-and-services) {#acr-tbl-sec508-support}

Notes:

Section 602 applies to both Quarto's **Web** documentation at [quarto.org](https://quarto.org) as well as the CLI's built-in help (**Software**).
Section 603 does not apply. Quarto offers no support services: no help desk, call centre, technical support, or training. Questions and bug reports go to GitHub Issues and Discussions, which are public community channels with no service commitment.

::: {.column-page}

```{=html}
<table class="table acr-table acr-criteria" aria-labelledby="acr-tbl-sec508-support">
<colgroup>
<col style="width: 25%">
<col style="width: 15%">
<col style="width: 60%">
</colgroup>
<thead>
<tr>
<th scope="col">Criteria</th>
<th scope="col">Conformance Level</th>
<th scope="col">Remarks and Explanations</th>
</tr>
</thead>
<tbody>
<tr>
<th scope="row" class="acr-heading"><div id="acr-601.1">601.1 Scope</div></th>
<td>Heading cell – no response required</td>
<td><div data-qmd="Heading cell – no response required"></div></td>
</tr>
<tr>
<th scope="row" class="acr-heading"><div id="acr-602"><a href="https://www.access-board.gov/ict/#602-support-documentation">602 Support Documentation</a></div></th>
<td>Heading cell – no response required</td>
<td><div data-qmd="Heading cell – no response required"></div></td>
</tr>
<tr>
<th scope="row"><div id="acr-602.2">602.2 Accessibility and Compatibility Features</div></th>
<td>Partially Supports</td>
<td><div data-qmd="**Web:** quarto.org explains how to use the accessibility features of
Quarto's output: alternative text with `fig-alt`, the `axe`
accessibility check, PDF/UA export with `pdf-standard`, and the
search keyboard shortcuts on Quarto websites and how to change
them. Its accessibility page gives the site's latest automated
scan results and asks users to report problems as GitHub issues.

Known gaps:

- No page lists the site's own features, such as the skip link,
  the search shortcuts `f`, `s`, and `/`, the colour-scheme
  toggle, and its use of the reduce-motion setting.
- No page explains how to use quarto.org with assistive
  technology.

**Software:** The CLI reference on quarto.org and `--help` list `--no-prompt`
and `--quiet`.

Known gaps:

- Neither is presented as an accessibility feature.
- Nothing documents that the CLI honors `NO_COLOR` (see
  [503.2](#acr-503.2)).
- Nothing explains how to use the CLI with a screen reader."></div></td>
</tr>
<tr>
<th scope="row"><div id="acr-602.3">602.3 Electronic Support Documentation</div></th>
<td>See <a href="#wcag-report">WCAG 2.2 section</a></td>
<td><div data-qmd="See information in WCAG 2.2 section"></div></td>
</tr>
<tr>
<th scope="row"><div id="acr-602.4">602.4 Alternate Formats for Non-Electronic Support Documentation</div></th>
<td>Not Applicable</td>
<td><div data-qmd="Support documentation is provided in electronic formats only."></div></td>
</tr>
<tr>
<th scope="row" class="acr-heading"><div id="acr-603"><a href="https://www.access-board.gov/ict/#603-support-services">603 Support Services</a></div></th>
<td>Heading cell – no response required</td>
<td><div data-qmd="Heading cell – no response required"></div></td>
</tr>
<tr>
<th scope="row"><div id="acr-603.2">603.2 Information on Accessibility and Compatibility Features</div></th>
<td>Not Applicable</td>
<td><div data-qmd="See the table note."></div></td>
</tr>
<tr>
<th scope="row"><div id="acr-603.3">603.3 Accommodation of Communication Needs</div></th>
<td>Not Applicable</td>
<td><div data-qmd="See the table note."></div></td>
</tr>
</tbody>
</table>
```

:::

## EN 301 549 Report

### Clause [4: Functional Performance Statements](https://www.etsi.org/deliver/etsi_en/301500_301599/301549/03.02.01_60/en_301549v030201p.pdf#page=20) (FPS) {#acr-tbl-en301549-4}

Notes:

Each row is answered for three aspects of Quarto. **Software** is the Quarto CLI, used in a terminal. **Web** is the documentation at [quarto.org](https://quarto.org). **Authoring Tool** is the HTML that Quarto produces by default, for the people who read it. Each part summarises the WCAG rows it links to.

A row is Supports only if every aspect that the statement applies to supports it, and Does Not Support only if none does. A mix is Partially Supports. An aspect that the statement does not apply to is not counted in the level.

::: {.column-page}

```{=html}
<table class="table acr-table acr-criteria acr-fpc" aria-labelledby="acr-tbl-en301549-4">
<colgroup>
<col style="width: 25%">
<col style="width: 15%">
<col style="width: 60%">
</colgroup>
<thead>
<tr>
<th scope="col">Criteria</th>
<th scope="col">Conformance Level</th>
<th scope="col">Remarks and Explanations</th>
</tr>
</thead>
<tbody>
<tr>
<th scope="row"><div id="acr-4.2.1">4.2.1 Usage without vision</div></th>
<td>Partially Supports</td>
<td><div data-qmd="**Software:** A screen reader user can run commands and hear their output,
error messages, and help, and commands that prompt accept
`--no-prompt`.

Known defects:

- In interactive prompts, moving through a list or checking an
  item is not announced, and two prompts of `quarto create` are
  not announced in full ([1.1.1](#acr-1.1.1),
  [3.3.2](#acr-3.3.2), [4.1.3](#acr-4.1.3)).
- `quarto check` cannot be followed by ear, because each new
  line cuts off the one being read ([4.1.3](#acr-4.1.3)).

**Web:** A screen reader user can read and move through the documentation
by its landmarks, headings, and links.

Known defects:

- Images in the home page animation have no name
  ([1.1.1](#acr-1.1.1)).
- Collapsed callouts, and the &quot;On this page&quot; toggle that
  replaces the table of contents when content extends into the
  right margin, have no role or state ([4.1.2](#acr-4.1.2)).
- Search results are not announced ([4.1.3](#acr-4.1.3)).
- The tutorial videos have no audio description
  ([1.2.3](#acr-1.2.3), [1.2.5](#acr-1.2.5)).
- The `kbd` shortcode with only operating-system keyword
  arguments gives screen readers no text for the shortcut, and
  its text is read after the sentence that contains it
  ([1.3.1](#acr-1.3.1), [1.3.2](#acr-1.3.2)).
- Margin citations keep `role=&quot;listitem&quot;` after their list
  parent is removed ([1.3.1](#acr-1.3.1)).
- The previous and next page links are named by the target page
  title alone, so a screen reader does not say which goes back
  and which forward ([1.3.1](#acr-1.3.1)).
- The search button is out of place in the Tab order, the search
  overlay does not trap focus, and closing it returns focus to
  the top of the page ([2.4.3](#acr-2.4.3)).
- Footnote back-links are named only by an arrow
  ([2.4.4](#acr-2.4.4)).

**Authoring Tool:** Default output gives screen readers landmarks, headings, the
author's alternative text, and spoken equations.

Known defects, in website search, which is on by default with a
navbar or sidebar:

- Search results are not announced ([4.1.3](#acr-4.1.3)).
- The search button is out of place in the Tab order, the search
  overlay does not trap focus, and closing it returns focus to
  the top of the page ([2.4.3](#acr-2.4.3)).

Known defects, each only in content the author chooses to add:

- Images from the `placeholder` shortcode have no alternative
  text ([1.1.1](#acr-1.1.1)).
- Callouts set to collapse have no role or state
  ([4.1.2](#acr-4.1.2)).
- Footnote back-links are named only by an arrow
  ([2.4.4](#acr-2.4.4)).
- A local video file added with the `video` shortcode cannot be
  given an audio description ([1.2.3](#acr-1.2.3),
  [1.2.5](#acr-1.2.5)).
- The `kbd` shortcode with only operating-system keyword
  arguments gives screen readers no text for the shortcut, and
  its text is read after the sentence that contains it
  ([1.3.1](#acr-1.3.1), [1.3.2](#acr-1.3.2)).
- Margin citations keep `role=&quot;listitem&quot;` after their list
  parent is removed ([1.3.1](#acr-1.3.1)).
- Page navigation links are named by the target page title
  alone, so a screen reader does not say which goes back and
  which forward ([1.3.1](#acr-1.3.1)).
- Closing the `code-tools` source window returns focus to the
  top of the page ([2.4.3](#acr-2.4.3))."></div></td>
</tr>
<tr>
<th scope="row"><div id="acr-4.2.2">4.2.2 Usage with limited vision</div></th>
<td>Partially Supports</td>
<td><div data-qmd="**Software:** The terminal draws the CLI's text, so the terminal and the platform set magnification, font, colour, and contrast (see [503.2](#acr-503.2)). Help text re-wraps to the width of the window.

**Web:** Pages can be zoomed and reflow.

Known defects:

- At 200% zoom and at narrow widths the &quot;On this page&quot; table of
  contents is hidden ([1.4.4](#acr-1.4.4),
  [1.4.10](#acr-1.4.10)).
- Some pages scroll sideways at 320px ([1.4.10](#acr-1.4.10)).
- The focus indicator on navbar items is faint
  ([1.4.11](#acr-1.4.11), [2.4.7](#acr-2.4.7)).
- Footnote popups cannot be dismissed ([1.4.13](#acr-1.4.13)).
- With text spacing overrides applied, the gallery carousel
  captions overlap the slide image ([1.4.12](#acr-1.4.12)).
- Moving back up a page with Shift+Tab, the focused item can be
  hidden behind the sticky navbar, and the search overlay and
  open popups can cover the focused item
  ([2.4.11](#acr-2.4.11)).

**Authoring Tool:** Pages can be zoomed and reflow.

Known defects:

- Some secondary text is below 4.5:1 ([1.4.3](#acr-1.4.3)).
- The focus indicator on navbar items and tabs is faint
  ([1.4.11](#acr-1.4.11), [2.4.7](#acr-2.4.7)).
- At 200% zoom and at narrow widths the table of contents is
  hidden ([1.4.4](#acr-1.4.4), [1.4.10](#acr-1.4.10)).
- Only in content the author adds: wide equations make the page
  scroll sideways at 320px ([1.4.10](#acr-1.4.10)).
- Only in content the author adds: footnote, citation, and
  cross-reference popups cannot be dismissed, but the author can
  turn them off ([1.4.13](#acr-1.4.13))."></div></td>
</tr>
<tr>
<th scope="row"><div id="acr-4.2.3">4.2.3 Usage without perception of colour</div></th>
<td>Partially Supports</td>
<td><div data-qmd="**Software:** No output depends on colour alone: errors and warnings have a text prefix, and the current option in a prompt has a pointer. With `NO_COLOR` set, the output text is the same. See [1.4.1](#acr-1.4.1).

**Web:** Links in running text are underlined, so they can be found
without telling colours apart, and elsewhere colour has a second
cue.

Known defects, in the site navigation:

- The sidebar marks the current page by colour alone
  ([1.4.1](#acr-1.4.1)).
- The navbar marks the current section by colour alone
  ([1.4.1](#acr-1.4.1)).

**Authoring Tool:** Quarto's default style underlines links in running text, so they
can be found without telling colours apart, and gives colour a
second cue elsewhere.

Known defects, in website navigation:

- The sidebar marks the current page by colour alone
  ([1.4.1](#acr-1.4.1)).
- The navbar marks the current section by colour alone
  ([1.4.1](#acr-1.4.1))."></div></td>
</tr>
<tr>
<th scope="row"><div id="acr-4.2.4">4.2.4 Usage without hearing</div></th>
<td>Partially Supports</td>
<td><div data-qmd="**Software:** The CLI makes no sound.

**Web:** Both tutorial videos have captions.

Known defects:

- On one of them the captions are generated automatically and
  mistranscribe &quot;Quarto&quot; ([1.2.2](#acr-1.2.2)).

**Authoring Tool:** Hosted videos show the host's captions.

Known defects:

- For a local video file, the `video` shortcode gives no way to
  attach captions ([1.2.2](#acr-1.2.2), [7.1.1](#acr-7.1.1))."></div></td>
</tr>
<tr>
<th scope="row"><div id="acr-4.2.5">4.2.5 Usage with limited hearing</div></th>
<td>Partially Supports</td>
<td><div data-qmd="**Software:** The CLI makes no sound.

**Web:** Captions are available for both tutorial videos.

Known defects:

- On one of them the captions are generated automatically and
  mistranscribe &quot;Quarto&quot; ([1.2.2](#acr-1.2.2)).

**Authoring Tool:** Hosted videos show the host's captions.

Known defects:

- For a local video file, the `video` shortcode gives no way to
  attach captions ([1.2.2](#acr-1.2.2), [7.1.1](#acr-7.1.1))."></div></td>
</tr>
<tr>
<th scope="row"><div id="acr-4.2.6">4.2.6 Usage with no or limited vocal capability</div></th>
<td>Not Applicable</td>
<td><div data-qmd="Quarto does not require vocal input."></div></td>
</tr>
<tr>
<th scope="row"><div id="acr-4.2.7">4.2.7 Usage with limited manipulation or strength</div></th>
<td>Partially Supports</td>
<td><div data-qmd="**Software:** All input is typed text and single keys, with no simultaneous action except Ctrl+C, which closing the terminal tab replaces (see [5.9](#acr-5.9)).

**Web:** Navigation, search, menus, and tabsets work from the keyboard.

Known defects:

- Collapsed callouts, code annotation markers, and the &quot;On this
  page&quot; toggle that replaces the table of contents when content
  extends into the right margin do not work from the keyboard
  ([2.1.1](#acr-2.1.1)).
- The single-key search shortcuts cannot be turned off
  ([2.1.4](#acr-2.1.4)).
- The sidebar's links and toggles are small and close together
  ([2.5.8](#acr-2.5.8)).

**Authoring Tool:** Navigation, search, sidebar sections, and tabsets work from the
keyboard.

Known defects:

- Readers cannot turn off the single-key search shortcuts,
  though an author can, with the `keyboard-shortcut` search
  option ([2.1.4](#acr-2.1.4)).
- Only in content the author adds: collapsed callouts, code
  annotation markers, and the &quot;On this page&quot; toggle that
  replaces the table of contents when content extends into the
  right margin do not work from the keyboard
  ([2.1.1](#acr-2.1.1))."></div></td>
</tr>
<tr>
<th scope="row"><div id="acr-4.2.8">4.2.8 Usage with limited reach</div></th>
<td>Not Applicable</td>
<td><div data-qmd="Quarto is software, not a free-standing or installed product."></div></td>
</tr>
<tr>
<th scope="row"><div id="acr-4.2.9">4.2.9 Minimize photosensitive seizure triggers</div></th>
<td>Supports</td>
<td><div data-qmd="**Software:** Nothing in the CLI flashes. See [2.3.1](#acr-2.3.1).

**Web:** Nothing on quarto.org flashes. See [2.3.1](#acr-2.3.1).

**Authoring Tool:** Nothing in default output flashes. See [2.3.1](#acr-2.3.1)."></div></td>
</tr>
<tr>
<th scope="row"><div id="acr-4.2.10">4.2.10 Usage with limited cognition, language or learning</div></th>
<td>Partially Supports</td>
<td><div data-qmd="**Software:** Help output is organised under `Usage`, `Options`, and `Commands` headings, and every prompt is labelled, with a hint that names the keys to use. Prompts wait with no time limit, and publishing, installing, or overwriting files asks for confirmation first. Errors start with `ERROR:` and say what the value must be, and a mistyped command gets a suggestion. We did not assess reading level or plain language. See [2.2.1](#acr-2.2.1), [2.4.6](#acr-2.4.6), [3.3.1](#acr-3.3.1), [3.3.3](#acr-3.3.3), and [3.3.4](#acr-3.3.4).

**Web:** Navigation, labels, and help links are in the same place and
order on every page, and pages have descriptive titles and
headings. The site sets no time limits and has no login or
multi-step process. We did not assess reading level or plain
language. See [2.2.1](#acr-2.2.1), [2.4.2](#acr-2.4.2),
[2.4.6](#acr-2.4.6), [3.2.3](#acr-3.2.3), [3.2.4](#acr-3.2.4),
[3.2.6](#acr-3.2.6), [3.3.7](#acr-3.3.7), and
[3.3.8](#acr-3.3.8).

Known defects:

- The home page animation, the gallery carousel, and the looping
  demo GIFs start on their own and cannot be paused
  ([2.2.2](#acr-2.2.2)).
- The search button is out of place in the Tab order, and
  closing the search returns focus to the top of the page
  ([2.4.3](#acr-2.4.3)).

**Authoring Tool:** Navigation and labels are consistent from page to page, and the
page title combines the document and site titles. Default output
sets no time limits and has no moving content. We did not assess
reading level or plain language. See
[2.2.1](#acr-2.2.1), [2.2.2](#acr-2.2.2), [2.4.2](#acr-2.4.2),
[3.2.3](#acr-3.2.3), and [3.2.4](#acr-3.2.4).

Known defects:

- The search button is out of place in the Tab order, and
  closing the search or the `code-tools` source window returns
  focus to the top of the page ([2.4.3](#acr-2.4.3))."></div></td>
</tr>
<tr>
<th scope="row"><div id="acr-4.2.11">4.2.11 Privacy</div></th>
<td>Not Applicable</td>
<td><div data-qmd="Quarto has no accessibility features of its own (see [5.2](#acr-5.2))."></div></td>
</tr>
</tbody>
</table>
```

:::

### Clause [5: Generic Requirements](https://www.etsi.org/deliver/etsi_en/301500_301599/301549/03.02.01_60/en_301549v030201p.pdf#page=23) {#acr-tbl-en301549-5}

Notes:

Quarto provides no closed functionality, requires no biometrics, has no operable parts, has no locking or toggle controls, has no key repeat function, and provides no keyboard or keypad, therefore clauses 5.1, 5.3, 5.5, 5.6, 5.7 and 5.8 are not applicable.

::: {.column-page}

```{=html}
<table class="table acr-table acr-criteria" aria-labelledby="acr-tbl-en301549-5">
<colgroup>
<col style="width: 25%">
<col style="width: 15%">
<col style="width: 60%">
</colgroup>
<thead>
<tr>
<th scope="col">Criteria</th>
<th scope="col">Conformance Level</th>
<th scope="col">Remarks and Explanations</th>
</tr>
</thead>
<tbody>
<tr>
<th scope="row" class="acr-heading"><div id="acr-5.1">5.1 Closed functionality</div></th>
<td>Heading cell – no response required</td>
<td><div data-qmd="Heading cell – no response required"></div></td>
</tr>
<tr>
<th scope="row" class="acr-heading"><div id="acr-5.1.2">5.1.2 General</div></th>
<td>Heading cell – no response required</td>
<td><div data-qmd="Heading cell – no response required"></div></td>
</tr>
<tr>
<th scope="row"><div id="acr-5.1.2.1">5.1.2.1 Closed functionality</div></th>
<td>See 5.2 through 13</td>
<td><div data-qmd="See information in 5.2 through 13"></div></td>
</tr>
<tr>
<th scope="row"><div id="acr-5.1.2.2">5.1.2.2 Assistive technology</div></th>
<td>See 5.1.3 through 5.1.6</td>
<td><div data-qmd="See information in 5.1.3 through 5.1.6"></div></td>
</tr>
<tr>
<th scope="row" class="acr-heading"><div id="acr-5.1.3">5.1.3 Non-visual access</div></th>
<td>Heading cell – no response required</td>
<td><div data-qmd="Heading cell – no response required"></div></td>
</tr>
<tr>
<th scope="row"><div id="acr-5.1.3.1">5.1.3.1 Audio output of visual information</div></th>
<td>Not Applicable</td>
<td><div data-qmd="See the table note."></div></td>
</tr>
<tr>
<th scope="row"><div id="acr-5.1.3.2">5.1.3.2 Auditory output delivery including speech</div></th>
<td>Not Applicable</td>
<td><div data-qmd="See the table note."></div></td>
</tr>
<tr>
<th scope="row"><div id="acr-5.1.3.3">5.1.3.3 Auditory output correlation</div></th>
<td>Not Applicable</td>
<td><div data-qmd="See the table note."></div></td>
</tr>
<tr>
<th scope="row"><div id="acr-5.1.3.4">5.1.3.4 Speech output user control</div></th>
<td>Not Applicable</td>
<td><div data-qmd="See the table note."></div></td>
</tr>
<tr>
<th scope="row"><div id="acr-5.1.3.5">5.1.3.5 Speech output automatic interruption</div></th>
<td>Not Applicable</td>
<td><div data-qmd="See the table note."></div></td>
</tr>
<tr>
<th scope="row"><div id="acr-5.1.3.6">5.1.3.6 Speech output for non-text content</div></th>
<td>Not Applicable</td>
<td><div data-qmd="See the table note."></div></td>
</tr>
<tr>
<th scope="row"><div id="acr-5.1.3.7">5.1.3.7 Speech output for video information</div></th>
<td>Not Applicable</td>
<td><div data-qmd="See the table note."></div></td>
</tr>
<tr>
<th scope="row"><div id="acr-5.1.3.8">5.1.3.8 Masked entry</div></th>
<td>Not Applicable</td>
<td><div data-qmd="See the table note."></div></td>
</tr>
<tr>
<th scope="row"><div id="acr-5.1.3.9">5.1.3.9 Private access to personal data</div></th>
<td>Not Applicable</td>
<td><div data-qmd="See the table note."></div></td>
</tr>
<tr>
<th scope="row"><div id="acr-5.1.3.10">5.1.3.10 Non-interfering audio output</div></th>
<td>Not Applicable</td>
<td><div data-qmd="See the table note."></div></td>
</tr>
<tr>
<th scope="row"><div id="acr-5.1.3.11">5.1.3.11 Private listening volume</div></th>
<td>Not Applicable</td>
<td><div data-qmd="See the table note."></div></td>
</tr>
<tr>
<th scope="row"><div id="acr-5.1.3.12">5.1.3.12 Speaker volume</div></th>
<td>Not Applicable</td>
<td><div data-qmd="See the table note."></div></td>
</tr>
<tr>
<th scope="row"><div id="acr-5.1.3.13">5.1.3.13 Volume reset</div></th>
<td>Not Applicable</td>
<td><div data-qmd="See the table note."></div></td>
</tr>
<tr>
<th scope="row"><div id="acr-5.1.3.14">5.1.3.14 Spoken languages</div></th>
<td>Not Applicable</td>
<td><div data-qmd="See the table note."></div></td>
</tr>
<tr>
<th scope="row"><div id="acr-5.1.3.15">5.1.3.15 Non-visual error identification</div></th>
<td>Not Applicable</td>
<td><div data-qmd="See the table note."></div></td>
</tr>
<tr>
<th scope="row"><div id="acr-5.1.3.16">5.1.3.16 Receipts, tickets, and transactional outputs</div></th>
<td>Not Applicable</td>
<td><div data-qmd="See the table note."></div></td>
</tr>
<tr>
<th scope="row"><div id="acr-5.1.4">5.1.4 Functionality closed to text enlargement</div></th>
<td>Not Applicable</td>
<td><div data-qmd="See the table note."></div></td>
</tr>
<tr>
<th scope="row"><div id="acr-5.1.5">5.1.5 Visual output for auditory information</div></th>
<td>Not Applicable</td>
<td><div data-qmd="See the table note."></div></td>
</tr>
<tr>
<th scope="row" class="acr-heading"><div id="acr-5.1.6">5.1.6 Operation without keyboard interface</div></th>
<td>Heading cell – no response required</td>
<td><div data-qmd="Heading cell – no response required"></div></td>
</tr>
<tr>
<th scope="row"><div id="acr-5.1.6.1">5.1.6.1 Closed functionality</div></th>
<td>See 5.1.3.1 through 5.1.3.16</td>
<td><div data-qmd="See information in 5.1.3.1 through 5.1.3.16"></div></td>
</tr>
<tr>
<th scope="row"><div id="acr-5.1.6.2">5.1.6.2 Input focus</div></th>
<td>Not Applicable</td>
<td><div data-qmd="See the table note."></div></td>
</tr>
<tr>
<th scope="row"><div id="acr-5.1.7">5.1.7 Access without speech</div></th>
<td>Not Applicable</td>
<td><div data-qmd="See the table note."></div></td>
</tr>
<tr>
<th scope="row"><div id="acr-5.2">5.2 Activation of accessibility features</div></th>
<td>Not Applicable</td>
<td><div data-qmd="Quarto has no accessibility features of its own to activate. The features its documentation describes as accessibility features, such as `fig-alt` and `lang`, are properties of the rendered output and are reported under [504.2](#acr-504.2) and [11.8.2](#acr-11.8.2)."></div></td>
</tr>
<tr>
<th scope="row"><div id="acr-5.3">5.3 Biometrics</div></th>
<td>Not Applicable</td>
<td><div data-qmd="See the table note."></div></td>
</tr>
<tr>
<th scope="row"><div id="acr-5.4">5.4 Preservation of accessibility information during conversion</div></th>
<td>Supports</td>
<td><div data-qmd="Rendering a Quarto document to HTML keeps the accessibility information the author provides: alternative text, document language, title, heading levels, table captions and header cells, and the roles of footnotes and citations all appear in the output. PDF output is outside this report."></div></td>
</tr>
<tr>
<th scope="row" class="acr-heading"><div id="acr-5.5">5.5 Operable parts</div></th>
<td>Heading cell – no response required</td>
<td><div data-qmd="Heading cell – no response required"></div></td>
</tr>
<tr>
<th scope="row"><div id="acr-5.5.1">5.5.1 Means of operation</div></th>
<td>Not Applicable</td>
<td><div data-qmd="See the table note."></div></td>
</tr>
<tr>
<th scope="row"><div id="acr-5.5.2">5.5.2 Operable parts discernibility</div></th>
<td>Not Applicable</td>
<td><div data-qmd="See the table note."></div></td>
</tr>
<tr>
<th scope="row" class="acr-heading"><div id="acr-5.6">5.6 Locking or toggle controls</div></th>
<td>Heading cell – no response required</td>
<td><div data-qmd="Heading cell – no response required"></div></td>
</tr>
<tr>
<th scope="row"><div id="acr-5.6.1">5.6.1 Tactile or auditory status</div></th>
<td>Not Applicable</td>
<td><div data-qmd="See the table note."></div></td>
</tr>
<tr>
<th scope="row"><div id="acr-5.6.2">5.6.2 Visual status</div></th>
<td>Not Applicable</td>
<td><div data-qmd="See the table note."></div></td>
</tr>
<tr>
<th scope="row"><div id="acr-5.7">5.7 Key repeat</div></th>
<td>Not Applicable</td>
<td><div data-qmd="See the table note."></div></td>
</tr>
<tr>
<th scope="row"><div id="acr-5.8">5.8 Double-strike key acceptance</div></th>
<td>Not Applicable</td>
<td><div data-qmd="See the table note."></div></td>
</tr>
<tr>
<th scope="row"><div id="acr-5.9">5.9 Simultaneous user actions</div></th>
<td>Supports</td>
<td><div data-qmd="The CLI's only chorded action is Ctrl+C, the terminal convention for stopping a running command such as `quarto preview` or for leaving a prompt. The same can be done without a chord by closing the terminal window or tab, or by ending the process from another shell. All other input is single keys and typed text."></div></td>
</tr>
</tbody>
</table>
```

:::

### Clause [6: ICT with Two-Way Voice Communication](https://www.etsi.org/deliver/etsi_en/301500_301599/301549/03.02.01_60/en_301549v030201p.pdf#page=30) {#acr-tbl-en301549-6}

Notes:

Not Applicable. Quarto provides no two-way voice communication.

### Clause [7: ICT with Video Capabilities](https://www.etsi.org/deliver/etsi_en/301500_301599/301549/03.02.01_60/en_301549v030201p.pdf#page=35) {#acr-tbl-en301549-7}

Notes:

The Quarto CLI neither provides nor displays any video. Video can be included in authored documents via the `{{{< video >}}}` shortcode and we label this aspect **Authoring Tool** in the table below. The documentation at [quarto.org](https://quarto.org) includes video and we label this aspect **Web** in the table below. In both cases, playback and controls are handled by embedded third-party video players.

::: {.column-page}

```{=html}
<table class="table acr-table acr-criteria" aria-labelledby="acr-tbl-en301549-7">
<colgroup>
<col style="width: 25%">
<col style="width: 15%">
<col style="width: 60%">
</colgroup>
<thead>
<tr>
<th scope="col">Criteria</th>
<th scope="col">Conformance Level</th>
<th scope="col">Remarks and Explanations</th>
</tr>
</thead>
<tbody>
<tr>
<th scope="row" class="acr-heading"><div id="acr-7.1">7.1 Caption processing technology</div></th>
<td>Heading cell – no response required</td>
<td><div data-qmd="Heading cell – no response required"></div></td>
</tr>
<tr>
<th scope="row"><div id="acr-7.1.1">7.1.1 Captioning playback</div></th>
<td>Partially Supports</td>
<td><div data-qmd="**Web:** The YouTube player on quarto.org shows captions for both tutorial videos when the user turns them on.

**Authoring Tool:** The `video` shortcode embeds hosted videos (YouTube, Vimeo,
Brightcove) in the host's player, which shows the captions the
host provides.

Known defects:

- For a local video file, the shortcode gives no way to attach a
  caption track, so its player has no captions to show."></div></td>
</tr>
<tr>
<th scope="row"><div id="acr-7.1.2">7.1.2 Captioning synchronization</div></th>
<td>Supports</td>
<td><div data-qmd="**Web:** The YouTube player on quarto.org keeps captions in sync with the speech.

**Authoring Tool:** The `video` shortcode embeds YouTube videos in the same player. Its player for local files shows no captions (see [7.1.1](#acr-7.1.1))."></div></td>
</tr>
<tr>
<th scope="row"><div id="acr-7.1.3">7.1.3 Preservation of captioning</div></th>
<td>Not Applicable</td>
<td><div data-qmd="**Web:** quarto.org embeds YouTube videos and does not process them.

**Authoring Tool:** Quarto does not transmit, convert, or record video. Rendering copies a local video file into the output unchanged, so caption data in the file is kept, and hosted videos play in the host's player."></div></td>
</tr>
<tr>
<th scope="row"><div id="acr-7.1.4">7.1.4 Captions characteristics</div></th>
<td>Does Not Support</td>
<td><div data-qmd="**Web:** The YouTube player embedded on quarto.org shows captions when
the user turns them on.

Known defects:

- The player gives no way to change the size, colour, or font of
  captions; these options are available only when the video is
  played on youtube.com.

**Authoring Tool:** The `video` shortcode embeds YouTube videos in the same player.

Known defects:

- Its player for YouTube videos gives no way to change the size,
  colour, or font of captions.
- Its player for local files shows no captions (see
  [7.1.1](#acr-7.1.1))."></div></td>
</tr>
<tr>
<th scope="row"><div id="acr-7.1.5">7.1.5 Spoken subtitles</div></th>
<td>Does Not Support</td>
<td><div data-qmd="**Web:** The YouTube player on quarto.org shows captions as text.

Known defects:

- The player has no mode that speaks the captions.

**Authoring Tool:** The `video` shortcode embeds hosted videos in the host's player.

Known defects:

- Neither the YouTube player nor the player the shortcode emits
  for local files has a mode that speaks the captions."></div></td>
</tr>
<tr>
<th scope="row"><div id="acr-7.2.1">7.2.1 Audio description playback</div></th>
<td>Partially Supports</td>
<td><div data-qmd="**Web:** No video on quarto.org has an audio description (see [1.2.3](#acr-1.2.3) and [1.2.5](#acr-1.2.5)), so there was nothing to test.

**Authoring Tool:** The `video` shortcode embeds hosted videos in the host's player,
which plays an audio description if the host provides one.

Known defects:

- For a local video file, the shortcode gives no way to attach
  an audio description."></div></td>
</tr>
<tr>
<th scope="row"><div id="acr-7.2.2">7.2.2 Audio description synchronization</div></th>
<td>Not Applicable</td>
<td><div data-qmd="**Web:** No video on quarto.org has an audio description, so there is none to play.

**Authoring Tool:** The `video` shortcode's player for local files has no way to play an audio description (see [7.2.1](#acr-7.2.1))."></div></td>
</tr>
<tr>
<th scope="row"><div id="acr-7.2.3">7.2.3 Preservation of audio description</div></th>
<td>Not Applicable</td>
<td><div data-qmd="**Web:** quarto.org embeds YouTube videos and does not process them.

**Authoring Tool:** Quarto does not transmit, convert, or record video. Rendering copies a local video file into the output unchanged, so an audio description track in the file is kept, and hosted videos stay with the host."></div></td>
</tr>
<tr>
<th scope="row"><div id="acr-7.3">7.3 User controls for captions and audio description</div></th>
<td>Partially Supports</td>
<td><div data-qmd="**Web:** The YouTube player on quarto.org has its captions button on the control bar, with the primary playback controls. No video there has an audio description, so the player shows no description control.

**Authoring Tool:** Hosted videos keep the host player's own caption and description
controls.

Known defects:

- For a local video file, the `video` shortcode's player has no
  captions or description to control, because the shortcode
  gives no way to attach them."></div></td>
</tr>
</tbody>
</table>
```

:::

### Clause [8: Hardware](https://www.etsi.org/deliver/etsi_en/301500_301599/301549/03.02.01_60/en_301549v030201p.pdf#page=37) {#acr-tbl-en301549-8}

Notes:

Not Applicable. Quarto is software — a command-line tool and its
documentation website — and includes no hardware component.

### Clause [9: Web](https://www.etsi.org/deliver/etsi_en/301500_301599/301549/03.02.01_60/en_301549v030201p.pdf#page=45) *(see [WCAG 2.2 section](#wcag-report))* {#acr-en301549-9}

### Clause [10: Non-Web Documents](https://www.etsi.org/deliver/etsi_en/301500_301599/301549/03.02.01_60/en_301549v030201p.pdf#page=52) {#acr-tbl-en301549-10}

Notes:

Quarto ships no non-web documents beyond those described in [the report Notes](#notes) under **Electronic Docs**. We treat these files as source code, so the requirements in this clause are not applicable.

### Clause [11: Software](https://www.etsi.org/deliver/etsi_en/301500_301599/301549/03.02.01_60/en_301549v030201p.pdf#page=64) {#acr-tbl-en301549-11}

Notes:

Clause 11 addresses two aspects of Quarto: 11.5--11.7 concern the Quarto CLI (**Software**), and 11.8 concerns Quarto as an **Authoring Tool**. 

 EN 301 549 does not address command-line interfaces (see [clause 11.0 NOTE 4](https://www.etsi.org/deliver/etsi_en/301500_301599/301549/03.02.01_60/en_301549v030201p.pdf#page=64)).
 The Quarto CLI's interface is the text stream presented by the user's terminal, so the 11.5–11.7 rows are marked Not Applicable. We assess the accessibility of the CLI under the [Revised Section 508 Functional Performance Criteria](#acr-tbl-sec508-fpc) and [Revised Section 508 Chapter 5](#acr-tbl-sec508-software).

::: {.column-page}

```{=html}
<table class="table acr-table acr-criteria" aria-labelledby="acr-tbl-en301549-11">
<colgroup>
<col style="width: 25%">
<col style="width: 15%">
<col style="width: 60%">
</colgroup>
<thead>
<tr>
<th scope="col">Criteria</th>
<th scope="col">Conformance Level</th>
<th scope="col">Remarks and Explanations</th>
</tr>
</thead>
<tbody>
<tr>
<th scope="row" class="acr-heading"><div id="acr-11.0">11.0 General (informative)</div></th>
<td>Heading cell – no response required</td>
<td><div data-qmd="Heading cell – no response required"></div></td>
</tr>
<tr>
<th scope="row"><div id="acr-11.1.1.1-through-11.4.1.3">11.1.1.1 through 11.4.1.3</div></th>
<td>See <a href="#wcag-report">WCAG 2.2 section</a></td>
<td><div data-qmd="See information in WCAG 2.2 section"></div></td>
</tr>
<tr>
<th scope="row" class="acr-heading"><div id="acr-11.5">11.5 Interoperability with assistive technology</div></th>
<td>Heading cell – no response required</td>
<td><div data-qmd="Heading cell – no response required"></div></td>
</tr>
<tr>
<th scope="row" class="acr-heading"><div id="acr-11.5.1">11.5.1 Closed functionality</div></th>
<td>Heading cell – no response required</td>
<td><div data-qmd="Heading cell – no response required"></div></td>
</tr>
<tr>
<th scope="row" class="acr-heading"><div id="acr-11.5.2">11.5.2 Accessibility services</div></th>
<td>Heading cell – no response required</td>
<td><div data-qmd="Heading cell – no response required"></div></td>
</tr>
<tr>
<th scope="row"><div id="acr-11.5.2.1">11.5.2.1 Platform accessibility service support for software that provides a user interface</div></th>
<td>See 11.5.2.5 through 11.5.2.17</td>
<td><div data-qmd="See information in 11.5.2.5 through 11.5.2.17"></div></td>
</tr>
<tr>
<th scope="row"><div id="acr-11.5.2.2">11.5.2.2 Platform accessibility service support for assistive technologies</div></th>
<td>See 11.5.2.5 through 11.5.2.17</td>
<td><div data-qmd="See information in 11.5.2.5 through 11.5.2.17"></div></td>
</tr>
<tr>
<th scope="row"><div id="acr-11.5.2.3">11.5.2.3 Use of accessibility services</div></th>
<td>See 11.5.2.5 through 11.5.2.17</td>
<td><div data-qmd="See information in 11.5.2.5 through 11.5.2.17"></div></td>
</tr>
<tr>
<th scope="row"><div id="acr-11.5.2.4">11.5.2.4 Assistive technology</div></th>
<td>Not Applicable</td>
<td><div data-qmd="Quarto is not assistive technology."></div></td>
</tr>
<tr>
<th scope="row"><div id="acr-11.5.2.5">11.5.2.5 Object information</div></th>
<td>Not Applicable</td>
<td><div data-qmd="See the table note."></div></td>
</tr>
<tr>
<th scope="row"><div id="acr-11.5.2.6">11.5.2.6 Row, column, and headers</div></th>
<td>Not Applicable</td>
<td><div data-qmd="See the table note."></div></td>
</tr>
<tr>
<th scope="row"><div id="acr-11.5.2.7">11.5.2.7 Values</div></th>
<td>Not Applicable</td>
<td><div data-qmd="See the table note."></div></td>
</tr>
<tr>
<th scope="row"><div id="acr-11.5.2.8">11.5.2.8 Label relationships</div></th>
<td>Not Applicable</td>
<td><div data-qmd="See the table note."></div></td>
</tr>
<tr>
<th scope="row"><div id="acr-11.5.2.9">11.5.2.9 Parent-child relationships</div></th>
<td>Not Applicable</td>
<td><div data-qmd="See the table note."></div></td>
</tr>
<tr>
<th scope="row"><div id="acr-11.5.2.10">11.5.2.10 Text</div></th>
<td>Not Applicable</td>
<td><div data-qmd="See the table note."></div></td>
</tr>
<tr>
<th scope="row"><div id="acr-11.5.2.11">11.5.2.11 List of available actions</div></th>
<td>Not Applicable</td>
<td><div data-qmd="See the table note."></div></td>
</tr>
<tr>
<th scope="row"><div id="acr-11.5.2.12">11.5.2.12 Execution of available actions</div></th>
<td>Not Applicable</td>
<td><div data-qmd="See the table note."></div></td>
</tr>
<tr>
<th scope="row"><div id="acr-11.5.2.13">11.5.2.13 Tracking of focus and selection attributes</div></th>
<td>Not Applicable</td>
<td><div data-qmd="See the table note."></div></td>
</tr>
<tr>
<th scope="row"><div id="acr-11.5.2.14">11.5.2.14 Modification of focus and selection attributes</div></th>
<td>Not Applicable</td>
<td><div data-qmd="See the table note."></div></td>
</tr>
<tr>
<th scope="row"><div id="acr-11.5.2.15">11.5.2.15 Change notification</div></th>
<td>Not Applicable</td>
<td><div data-qmd="See the table note."></div></td>
</tr>
<tr>
<th scope="row"><div id="acr-11.5.2.16">11.5.2.16 Modifications of states and properties</div></th>
<td>Not Applicable</td>
<td><div data-qmd="See the table note."></div></td>
</tr>
<tr>
<th scope="row"><div id="acr-11.5.2.17">11.5.2.17 Modifications of values and text</div></th>
<td>Not Applicable</td>
<td><div data-qmd="See the table note."></div></td>
</tr>
<tr>
<th scope="row" class="acr-heading"><div id="acr-11.6">11.6 Documented accessibility usage</div></th>
<td>Heading cell – no response required</td>
<td><div data-qmd="Heading cell – no response required"></div></td>
</tr>
<tr>
<th scope="row"><div id="acr-11.6.1">11.6.1 User control of accessibility features</div></th>
<td>Not Applicable</td>
<td><div data-qmd="Quarto is not a platform."></div></td>
</tr>
<tr>
<th scope="row"><div id="acr-11.6.2">11.6.2 No disruption of accessibility features</div></th>
<td>Not Applicable</td>
<td><div data-qmd="See the table note."></div></td>
</tr>
<tr>
<th scope="row"><div id="acr-11.7">11.7 User preferences</div></th>
<td>Not Applicable</td>
<td><div data-qmd="See the table note."></div></td>
</tr>
<tr>
<th scope="row" class="acr-heading"><div id="acr-11.8">11.8 Authoring tools</div></th>
<td>Heading cell – no response required</td>
<td><div data-qmd="Heading cell – no response required"></div></td>
</tr>
<tr>
<th scope="row" class="acr-heading"><div id="acr-11.8.1">11.8.1 Content technology</div></th>
<td>Heading cell – no response required</td>
<td><div data-qmd="Heading cell – no response required"></div></td>
</tr>
<tr>
<th scope="row"><div id="acr-11.8.2">11.8.2 Accessible content creation</div></th>
<td>See <a href="#wcag-report">WCAG 2.2 section</a></td>
<td><div data-qmd="See information in WCAG 2.2 section"></div></td>
</tr>
<tr>
<th scope="row"><div id="acr-11.8.3">11.8.3 Preservation of accessibility information in transformations</div></th>
<td>Supports</td>
<td><div data-qmd="When Quarto transforms a document to HTML, the accessibility information the author provides is kept: alternative text, document language, title, heading levels, table captions and header cells, and footnote and citation roles. PDF output is outside this report."></div></td>
</tr>
<tr>
<th scope="row"><div id="acr-11.8.4">11.8.4 Repair assistance</div></th>
<td>Partially Supports</td>
<td><div data-qmd="The `axe` document option checks rendered HTML pages with axe-core
and reports each failure with axe's description of the rule and a
link to its guidance on how to fix it.

Known gaps:

- The suggestions are axe's and describe the HTML, not the Quarto
  source; Quarto adds no repair suggestion of its own."></div></td>
</tr>
<tr>
<th scope="row"><div id="acr-11.8.5">11.8.5 Templates</div></th>
<td>Partially Supports</td>
<td><div data-qmd="The project templates of `quarto create` (default, website, blog,
book, manuscript) let authors create accessible content.

Known defects:

- None of them gives fully conforming output. The website template
  adds no defects of its own, but its pages have the same defects
  as Quarto's default output reported in the WCAG table for the
  Authoring Tool.
- The blog template also ships an image without alternative text
  and two links without names ([quarto-dev/quarto-cli#15038](https://github.com/quarto-dev/quarto-cli/issues/15038),
  [quarto-dev/quarto-cli#14828](https://github.com/quarto-dev/quarto-cli/issues/14828))."></div></td>
</tr>
</tbody>
</table>
```

:::

### Clause [12: Documentation and Support Services](https://www.etsi.org/deliver/etsi_en/301500_301599/301549/03.02.01_60/en_301549v030201p.pdf#page=84) {#acr-tbl-en301549-12}

Notes:

Clause 12.1 applies to both Quarto's **Web** documentation at [quarto.org](https://quarto.org) as well as the CLI's built-in help (**Software**).
Clause 12.2 does not apply. Quarto offers no support services: no help desk, call centre, technical support, or training. Questions and bug reports go to GitHub Issues and Discussions, which are public community channels with no service commitment.

::: {.column-page}

```{=html}
<table class="table acr-table acr-criteria" aria-labelledby="acr-tbl-en301549-12">
<colgroup>
<col style="width: 25%">
<col style="width: 15%">
<col style="width: 60%">
</colgroup>
<thead>
<tr>
<th scope="col">Criteria</th>
<th scope="col">Conformance Level</th>
<th scope="col">Remarks and Explanations</th>
</tr>
</thead>
<tbody>
<tr>
<th scope="row" class="acr-heading"><div id="acr-12.1">12.1 Product documentation</div></th>
<td>Heading cell – no response required</td>
<td><div data-qmd="Heading cell – no response required"></div></td>
</tr>
<tr>
<th scope="row"><div id="acr-12.1.1">12.1.1 Accessibility and compatibility features</div></th>
<td>Partially Supports</td>
<td><div data-qmd="**Web:** quarto.org explains how to use the accessibility features of
Quarto's output, including `fig-alt`, the `axe` check, PDF/UA
export with `pdf-standard`, and the search keyboard shortcuts on
Quarto websites. The site's accessibility page reports its
automated scan results and how to report a problem.

Known gaps:

- No page lists the site's own features, such as the skip link,
  the search shortcuts `f`, `s`, and `/`, the colour-scheme
  toggle, and its use of the reduce-motion setting.
- No page explains how to use the site with assistive
  technology.

**Software:** The CLI reference on quarto.org and `--help` list `--no-prompt`
and `--quiet`.

Known gaps:

- Neither is presented as an accessibility feature.
- Nothing documents that the CLI honors `NO_COLOR`.
- Nothing explains how to use the CLI with a screen reader."></div></td>
</tr>
<tr>
<th scope="row"><div id="acr-12.1.2">12.1.2 Accessible documentation</div></th>
<td>See <a href="#wcag-report">WCAG 2.2 section</a></td>
<td><div data-qmd="See information in WCAG 2.2 section"></div></td>
</tr>
<tr>
<th scope="row" class="acr-heading"><div id="acr-12.2">12.2 Support Services</div></th>
<td>Heading cell – no response required</td>
<td><div data-qmd="Heading cell – no response required"></div></td>
</tr>
<tr>
<th scope="row"><div id="acr-12.2.2">12.2.2 Information on accessibility and compatibility features</div></th>
<td>Not Applicable</td>
<td><div data-qmd="See the table note."></div></td>
</tr>
<tr>
<th scope="row"><div id="acr-12.2.3">12.2.3 Effective communication</div></th>
<td>Not Applicable</td>
<td><div data-qmd="See the table note."></div></td>
</tr>
<tr>
<th scope="row"><div id="acr-12.2.4">12.2.4 Accessible documentation</div></th>
<td>Not Applicable</td>
<td><div data-qmd="See the table note."></div></td>
</tr>
</tbody>
</table>
```

:::

### Clause [13: ICT Providing Relay or Emergency Service Access](https://www.etsi.org/deliver/etsi_en/301500_301599/301549/03.02.01_60/en_301549v030201p.pdf#page=86) {#acr-tbl-en301549-13}

Notes:

Not Applicable. Quarto does not provide or give access to relay or
emergency services.
