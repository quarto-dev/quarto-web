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

## 1.1 Release Candidate

{{< include _download-pre.md >}}

## 1.0 Stable Release

{{< include _download.md >}}

:::