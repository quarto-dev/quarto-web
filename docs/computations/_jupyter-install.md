If you don't yet have Python 3 on your system, we recommend you install a version using the standard installer from <https://www.python.org/downloads/>.

If you are in a fresh Python 3 environment, installing the `jupyter` package will provide everything required to execute Jupyter kernels with Quarto:

+---------------------+--------------------------------------------+
| Pkg. Manager        | Command                                    |
+=====================+============================================+
| Pip\                | ``` bash                                   |
| (Windows)           | py -m pip install jupyter                  |
|                     | ```                                        |
+---------------------+--------------------------------------------+
| Pip\                | ``` bash                                   |
| (Mac/Linux)         | python3 -m pip install jupyter             |
|                     | ```                                        |
+---------------------+--------------------------------------------+
| Conda               | ``` bash                                   |
|                     | conda install jupyter                      |
|                     | ```                                        |
+---------------------+--------------------------------------------+

You can verify that Quarto is configured correctly for Jupyter with:

``` bash
quarto check jupyter
```

