# Lua API docs

We semi-automatically generate the Lua API docs (`docs/lua/*`).

This happens through the following steps:

- run the Lua LSP JSON generator
  - This is `https://github.com/LuaLS/lua-language-server`
  - You'll need to clone the repo and build it (it will end up in `bin/lua-language-server`)
  - From there, run something like
    
    ```
    $ ./lua-language-server --doc=../../../quarto-dev/quarto-cli/src/resources/lua-types
    ```

    there will be two files produced: doc.json and doc.md. Delete `doc.md` and move `doc.json` to `docs/lua` in this repository.

- run `quarto run tools/build-lua-types-autogen.ts`
