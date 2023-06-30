## Caching

[Jupyter Cache](https://jupyter-cache.readthedocs.io/en/latest/) enables you to cache all of the cell outputs for a notebook. If any of the cells in the notebook change then all of the cells will be re-executed.

To use Jupyter Cache you'll want to first install the `jupyter-cache` package:

+------------------+-----------------------------------------------+
| Platform         | Command                                       |
+==================+===============================================+
| Mac/Linux        | ``` {.bash filename="Terminal"}               |
|                  | python3 -m pip install jupyter-cache          |
|                  | ```                                           |
+------------------+-----------------------------------------------+
| Windows          | ``` {.powershell filename="Terminal"}         |
|                  | py -m pip install jupyter-cache               |
|                  | ```                                           |
+------------------+-----------------------------------------------+

To enable the cache for a document, add the `cache` option. For example:

``` yaml
---
title: "My Document"
format: html
execute: 
  cache: true
---
```

You can also specify caching at the project level. For example, within a project file:

``` yaml
project:
  type: website
  
format:
  html:
    theme: united
    
execute:
  cache: true
```

Note that changes within a document that aren't within code cells (e.g. markdown narrative) do not invalidate the document cache. This makes caching a very convenient option when you are working exclusively on the prose part of a document.

Jupyter Cache include a `jcache` command line utility that you can use to analyze and manage the notebook cache. See the [Jupyter Cache](https://jupyter-cache.readthedocs.io/en/latest/) documentation for additional details.
