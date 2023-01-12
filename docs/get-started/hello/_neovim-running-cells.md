You don't need to fully render documents in order to iterate on code cells.
With the provided configuration we can open a terminal of our choosing using the leader key (`<space>`) followed by`c` (for code) and then `p` (for python) or `i` (for ipython).

If you wait a little in between the key presses a small window pops up at the bottom of your screen to tell you about existing keybindings:

![](/docs/get-started/hello/images/neovim-open-terminal.png)

We can navigate between the code and the terminal using `ctrl` plus vim direction keys and enter commands into the python REPL by going into insert mode in this terminal buffer.

To send code to the python REPL from quarto we navigate to one of our code blocks and press `<space><cr>` (space bar followed by Enter).
The plugin responsible for sending code to various places, [vim-slime](https://github.com/jpalardy/vim-slime) will prompt us with the question which terminal to send the code to, pre filled with the latest terminal we created.

![](/docs/get-started/hello/images/neovim-send-code.png)

If you want to use <kbd>ctrl+Enter</kbd> to send code just like in RStudio, you are going to have to tell your terminal emulator to send the correct key codes.
For example, in the [kitty](https://github.com/kovidgoyal/kitty) terminal the configuration looks as follows:

```
map ctrl+shift+enter no_op
map shift+enter send_text all \x1b[13;2u
map ctrl+enter send_text all \x1b[13;5u
```

This is what the kickstarter configuration has been tested with.
