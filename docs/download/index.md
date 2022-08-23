---
title: "Download Quarto"
subtitle: "Install a release or pre-release build of Quarto."
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

## Release Candidate ([]{.download-pre-version})

{{< include _download-pre.md >}}

## Stable Release ([]{.download-version})

{{< include _download.md >}}

:::