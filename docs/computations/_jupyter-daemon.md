## Kernel Daemon

To mitigate the start-up time for the Jupyter kernel Quarto keeps a daemon with a running Jupyter kernel alive for each document. This enables subsequent renders to proceed immediately without having to wait for kernel start-up.

The purpose of the daemon is to make render more responsive during interactive sessions. Accordingly, no daemon is created when documents are rendered without an active tty or when they are part of a batch rendering (e.g. in a [Quarto Project](../projects/quarto-projects.qmd)).

Note that Quarto does not use a daemon by default on Windows (as some Windows systems will not allow the socket connection required by the daemon).

You can customize this behavior using the `daemon` execution option. Set it to `false` to prevent the use of a daemon, or set it to a value (in seconds) to determine the period after which the daemon will timeout (the default is 300 seconds). For example:

``` yaml
execute:
  daemon: false
```

``` yaml
execute:
  daemon: 60
```

Note that if you want to use a daemon on Windows you need to enable it explicitly:

``` yaml
execute:
  daemon: true
```

### Command Line

You can also control use of the Jupyter daemon using the following command line options:

```{.bash filename="Terminal"}
# use a daemon w/ default timeout (300 sec)
quarto render document.qmd --execute-daemon

# use a daemon w/ an explicit timeout
quarto render document.qmd --execute-daemon 60

# prevent use of a daemon
quarto render document.qmd --no-execute-daemon
```

You can also force an existing daemon to restart using the `--execute-daemon-restart` command line flag:

```{.bash filename="Terminal"}
quarto render document.qmd --execute-daemon-restart 
```

This might be useful if you suspect that the re-use of notebook sessions is causing an error.

Finally, you can print extended debugging information about daemon usage (startup, shutdown, connections, etc.) using the `--execute-debug` flag:

```{.bash filename="Terminal"}
quarto render document.qmd --execute-debug
```
