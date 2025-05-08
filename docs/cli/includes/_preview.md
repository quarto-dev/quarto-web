Render and preview a document or website project.

Automatically reloads the browser when input files or document resources (e.g. CSS) change.

For website preview, the most recent execution results of computational documents are used to render
the site (this is to optimize startup time). If you want to perform a full render prior to
previewing pass the --render option with "all" or a comma-separated list of formats to render.

For document preview, input file changes will result in a re-render (pass --no-watch to prevent).

You can also include arbitrary command line arguments to be forwarded to [1mquarto render[22m.

``` {.bash}
quarto preview [file:string] [...args:string]
```


## Options


```{=html}
<table>
 <thead>
  <tr>
   <th style="text-align:left;"> Flags </th>
   <th style="text-align:left;"> Arguments </th>
   <th style="text-align:left;"> Description </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> <code>-h</code>, <code>--help</code> </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> Show this help. </td>
  </tr>
  <tr>
   <td style="text-align:left;"> <code>--port</code> </td>
   <td style="text-align:left;"> <code>[port:number]</code> </td>
   <td style="text-align:left;"> Suggested port to listen on (defaults to random value between 3000 and 8000).
If the port is not available then a random port between 3000 and 8000 will be selected. </td>
  </tr>
  <tr>
   <td style="text-align:left;"> <code>--host</code> </td>
   <td style="text-align:left;"> <code>[host:string]</code> </td>
   <td style="text-align:left;"> Hostname to bind to (defaults to 127.0.0.1) </td>
  </tr>
  <tr>
   <td style="text-align:left;"> <code>--render</code> </td>
   <td style="text-align:left;"> <code>[format:string]</code> </td>
   <td style="text-align:left;"> Render to the specified format(s) before previewing </td>
  </tr>
  <tr>
   <td style="text-align:left;"> <code>--no-serve</code> </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> Don't run a local preview web server (just monitor and re-render input files) </td>
  </tr>
  <tr>
   <td style="text-align:left;"> <code>--no-navigate</code> </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> Don't navigate the browser automatically when outputs are updated. </td>
  </tr>
  <tr>
   <td style="text-align:left;"> <code>--no-browser</code> </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> Don't open a browser to preview the site. </td>
  </tr>
  <tr>
   <td style="text-align:left;"> <code>--no-watch-inputs</code> </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> Do not re-render input files when they change. </td>
  </tr>
  <tr>
   <td style="text-align:left;"> <code>--timeout</code> </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> Time (in seconds) after which to exit if there are no active clients. </td>
  </tr>
  <tr>
   <td style="text-align:left;"> <code>--log</code> </td>
   <td style="text-align:left;"> <code><file></code> </td>
   <td style="text-align:left;"> Path to log file </td>
  </tr>
  <tr>
   <td style="text-align:left;"> <code>--log-level</code> </td>
   <td style="text-align:left;"> <code><level></code> </td>
   <td style="text-align:left;"> Log level (info, warning, error, critical) </td>
  </tr>
  <tr>
   <td style="text-align:left;"> <code>--log-format</code> </td>
   <td style="text-align:left;"> <code><format></code> </td>
   <td style="text-align:left;"> Log format (plain, json-stream) </td>
  </tr>
  <tr>
   <td style="text-align:left;"> <code>--quiet</code> </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> Suppress console output. </td>
  </tr>
  <tr>
   <td style="text-align:left;"> <code>--profile</code> </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> Active project profile(s) </td>
  </tr>
</tbody>
</table>
```



## Commands


```{=html}
<table>
 <thead>
  <tr>
   <th style="text-align:left;"> Command </th>
   <th style="text-align:left;"> Description </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> <code>help</code> </td>
   <td style="text-align:left;"> Show this help or the help of a sub-command. </td>
  </tr>
</tbody>
</table>
```



## Examples
### Preview document

``` {.bash filename='Terminal'}
quarto preview doc.qmd
```

### Preview document with render command line args

``` {.bash filename='Terminal'}
quarto preview doc.qmd --toc
```

### Preview document (don't watch for input changes)

``` {.bash filename='Terminal'}
quarto preview doc.qmd --no-watch-inputs
```

### Preview website with most recent execution results

``` {.bash filename='Terminal'}
quarto preview
```

### Previewing website using a specific port

``` {.bash filename='Terminal'}
quarto preview --port 4444
```

### Preview website (don't open a browser)

``` {.bash filename='Terminal'}
quarto preview --no-browser
```

### Fully render all website/book formats then preview

``` {.bash filename='Terminal'}
quarto preview --render all
```

### Fully render the html format then preview

``` {.bash filename='Terminal'}
quarto preview --render html
```

