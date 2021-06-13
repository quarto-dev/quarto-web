---
title: "Site Variables"
---

## Overview

If you have commonly repeating values or content in your website, you can create a `_variables.yml` file alongside your `_quarto.yml` project file, and then include references to those variables within any page on your site.

Variables can be either simple values or can include arbitrary markdown content.

## Defining Variables

To define variables, create a `_variables.yml` file in the root directory of your project. For example:

```yaml
version: 1.2

email:
  info: info@example.com
  support: support@example.com

engine:
  jupyter: "[Jupyter](https://jupyter.org)"
  knitr: "[Knitr](<https://yihui.name/knitr>)"
```

Note that the `engine` variable values include markdown for hyperlinks.

## Using Variables

To include the value of a variable, use the `{{< var >}}` shortcode, for example:

```markdown
Version {{< var version >}} is a minor upgrade.

Please contact us at {{< var email.info >}}.

Quarto includes {{< var engine.jupyter >}} and 
{{< var engine.knitr >}} computation engines.
```



