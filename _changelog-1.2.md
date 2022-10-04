


## Revealjs Format

- Introduce template partials for RevealJS. You may provide partials for `title-slide.html` or `toc-slide.html`.

## Markdown Formats

- Support code folding for markdown output when `raw_html` is supported.
- `docusaurus-md` format for Docusaurus compatible markdown
- `docusaurus` and `hugo` project types for render/preview within external static site generators


## Authors and Affiliations

- Improve handling of empty authors
- Parse `author` and `institute` (often used for RevealJs and Beamer) into normalized author schema

## Websites

- Properly allow `twitter-card` and `open-graph` to override the page description.
- Don't discover resources within a site or book output directory
- Enable use of custom HTML formats for websites
- Automatically populate sidebar menu using `auto` option for contents
- Properly handle `margin-header` and `margin-footer` files
- Ensure that the `code-copy` button is functional even when margin content is present.
- Add support for open graph image sizes
- Fix issue preventing `twitter-card` `site` metadata from being emitted.
- Prevent website content from shifting when page first loads
- Improve animation smoothness when expanding navbar in mobile mode (#1873)
- Permit icons in top level navbar, if specified

## Books

- Fix issue that caused incomplete search indexes for books
- Don't display the book description in each chapter's title block
- book YAML now accepts fields from csl-item schema (#2148, #2398)
- book YAML now accepts date-format explicitly (#2148, #2398)
- Books no longer require an `index.qmd` file in the chapter list. If not present, the first chapter will serve as the website home page.



## Listing and Feeds

- Properly support `max-desc-length` to trim descriptions within listings

## Bibliographies and Citations

- Support formats `bibtex`, `biblatex`, and `csljson`. When rendered to one of these formats any citations within the document will be rendered as the specified bibliography format.
- Always add citeproc filter if `citeproc: true` is specified, even if there isn't a bibliography or references in the document (#2294)
- Don't process citations twice when `citeproc` is specified (#2393)
- Fix `citation-hover` for footnote style reference formats

## TinyTex

- `quarto install tool tinytex` will now install TinyTex even if a system installation of TeX is detected.
- `quarto install tool tinytex` will no longer add TinyTex to the system path by default.
- When rendering PDFs, Quarto will prefer an existing installation of TinyTex over a system Tex installation
- To prevent Quarto from using an installation of TinyTex (if you'd prefer the system installation be used), set `latex-tinytex: false` in your project or document front matter.
- To install TinyTex system wide, using the `--update-path` flag when installing (this will add TinyTex to the system path)

## Video Shortcode

- The video shortcode extension is now native to the Quarto CLI
- Reveal-JS Video Snippet backgrounds are now better supported. For common video snippets, like YouTube, you can specify them as `video` backgrounds and quarto will ensure the correct embed URL and swap to be an `iframe` background if needed.

## Miscellaneous

- Render: ability to compose `--to all` with other formats (e.g. `--to all,json`)
- Don't call Deno.realPathSync on Windows (avoid problems w/ UNC paths)
- Don't include Unicode literals on Windows directly (#2184), thanks @yihui
- Improve YAML validation error messages on values of type object (#2191)
- Upgrade esbuild to 0.15.6
- Implement --help option for quarto preview and quarto run
- Increase contrast for a11y-light theme to work with default code-block background (#2067, #2528)
- Upgrade to deno 1.25.1, which should lead to a 2-3x speedup in quarto startup time
- Use deno arm64 native binaries on macOS
- Set working dir to `QUARTO_WORKING_DIR` variable if provided.
- Resolve absolute paths in include shortcodes (#2320)
- New metadata field `quarto-required` to specify required versions of quarto in a document
- Provide project configuration for calls to `quarto inspect` for files
- Improve YAML validation error messages on closed schemas (#2349)
- Don't use default width/height on mermaid diagrams when better information is available (#2383)
- Improve YAML validation error messages on invalid YAML objects that include `x = y` (#2434)
- Forward `--log-level` to Pandoc via `--trace`, `--verbose`, and `--quiet`
- Disallow names with paths in command line option `--output` and YAML option `output-file` (#2440)
- Add possible chrome process running error to the error message thrown when quarto fails to connect to chrome headless (#2499)
- Only pass `pagetitle` metadata for HTML file output
- Provide non-HTML treatment for code block `filename`


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

