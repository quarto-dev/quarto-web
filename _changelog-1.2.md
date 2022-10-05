


## Markdown Formats

- Article in advanced on quarto and static site generators

## Extensions

- Preview live reload for changes to extension source files
- HTML dependencies may be provided by paths to files outside the extension directory
- HTML dependencies may now include `serviceworkers`, which are copied into the output directory.
- New `quarto.doc.attachToDependency` function to attach files to html dependencies (copies files into the lib dir for a named HTML dependency).
- Ensure that `quarto.utils.dump` works with pandoc's builtin global variables (#2254)
- Provide a better error message for non-existent format resources (#2291)
- Ability to specify a minimum quarto version via the `quarto-required` option.
- Extension may now contribute project types (project metadata which will be merged with a project when project of that type are rendered)
- Include Pandoc `logging` Lua module from @wlupton
- Improve path resolution of extensions
- Add support for extensions that contribute revealjs-plugins
- Fix issue loading extensions when the organization name is the same as the extension identifier
- Fix issue preventing installation of archived extensions from an arbitrary url (#2419)
- Support installation of extensions using Github archive urls
- Support installation of extensions from with subdirectories of a github repo
- Lua `require` can now find modules adjacent to the current script
- Use snake case for Quarto Lua API functions (match Pandoc API)

