If you don't yet have Python 3 on your system, we recommend you install a version using the standard installer from <https://www.python.org/downloads/>.

If you are in a fresh Python 3 environment, installing the `jupyter` package will provide everything required to execute Jupyter kernels with Quarto:

+--------------+--------------------------------------+
| Pkg. Manager | Command                              |
+==============+======================================+
| Pip\         | ```{.bash filename="Terminal"}       |
| (Mac/Linux)  | python3 -m pip install jupyter       |
|              | ```                                  |
+--------------+--------------------------------------+
| Pip\         | ```{.powershell filename="Terminal"} |
| (Windows)    | py -m pip install jupyter            |
|              | ```                                  |
+--------------+--------------------------------------+
| Conda        | ```{.bash filename="Terminal"}       |
|              | conda install jupyter                |
|              | ```                                  |
+--------------+--------------------------------------+

You can verify that Quarto is configured correctly for Jupyter with:

```{.bash filename="Terminal"}
quarto check jupyter
```

Quarto will select a version of Python using the [Python Launcher](https://docs.python.org/3/using/windows.html#python-launcher-for-windows) on Windows or system `PATH` on MacOS and Linux. You can override the version of Python used by Quarto by setting the `QUARTO_PYTHON` environment variable.
