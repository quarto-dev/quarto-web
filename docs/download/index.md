---
title: "Download Quarto"
subtitle: "Install a release or prerelease build of Quarto."
format:
  html:
    include-in-header: 
      - '_download.html'
    include-after-body: 
      text: |
        <script type="text/javascript">
        window['quarto-download-prerelease'] = true;
        window['quarto-download-release'] = true;
        window['quarto-download-archives'] = true;
        </script>
page-layout: full
toc: false
anchor-sections: false
editor: source
image: /images/hero_right.png
---

::: {.panel-tabset}

## Current: []{.download-pre-version}

{{< include _download-pre.md >}}

## []{.download-version}

{{< include _download.md >}}

:::