Render files or projects to various document types.

``` {.bash}
quarto render [input:string] [...args]
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
   <td style="text-align:left;"> <code>-t</code>, <code>--to</code> </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> Specify output format(s). </td>
  </tr>
  <tr>
   <td style="text-align:left;"> <code>-o</code>, <code>--output</code> </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> Write output to FILE (use '--output -' for stdout). </td>
  </tr>
  <tr>
   <td style="text-align:left;"> <code>--output-dir</code> </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> Write output to DIR (path is input/project relative) </td>
  </tr>
  <tr>
   <td style="text-align:left;"> <code>-M</code>, <code>--metadata</code> </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> Metadata value (KEY:VALUE). </td>
  </tr>
  <tr>
   <td style="text-align:left;"> <code>--site-url</code> </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> Override site-url for website or book output </td>
  </tr>
  <tr>
   <td style="text-align:left;"> <code>--execute</code> </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> Execute code (--no-execute to skip execution). </td>
  </tr>
  <tr>
   <td style="text-align:left;"> <code>-P</code>, <code>--execute-param</code> </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> Execution parameter (KEY:VALUE). </td>
  </tr>
  <tr>
   <td style="text-align:left;"> <code>--execute-params</code> </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> YAML file with execution parameters. </td>
  </tr>
  <tr>
   <td style="text-align:left;"> <code>--execute-dir</code> </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> Working directory for code execution. </td>
  </tr>
  <tr>
   <td style="text-align:left;"> <code>--execute-daemon</code> </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> Keep Jupyter kernel alive (defaults to 300 seconds). </td>
  </tr>
  <tr>
   <td style="text-align:left;"> <code>--execute-daemon-restart</code> </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> Restart keepalive Jupyter kernel before render. </td>
  </tr>
  <tr>
   <td style="text-align:left;"> <code>--execute-debug</code> </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> Show debug output when executing computations. </td>
  </tr>
  <tr>
   <td style="text-align:left;"> <code>--use-freezer</code> </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> Force use of frozen computations for an incremental file render. </td>
  </tr>
  <tr>
   <td style="text-align:left;"> <code>--cache</code> </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> Cache execution output (--no-cache to prevent cache). </td>
  </tr>
  <tr>
   <td style="text-align:left;"> <code>--cache-refresh</code> </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> Force refresh of execution cache. </td>
  </tr>
  <tr>
   <td style="text-align:left;"> <code>--no-clean</code> </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> Do not clean project output-dir prior to render </td>
  </tr>
  <tr>
   <td style="text-align:left;"> <code>--debug</code> </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> Leave intermediate files in place after render. </td>
  </tr>
  <tr>
   <td style="text-align:left;"> <code>pandoc-args...</code> </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> Additional pandoc command line arguments. </td>
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
### Render Markdown

``` {.bash filename='Terminal'}
quarto render document.qmd
quarto render document.qmd --to html
quarto render document.qmd --to pdf --toc
```

### Render Notebook

``` {.bash filename='Terminal'}
quarto render notebook.ipynb
quarto render notebook.ipynb --to docx
quarto render notebook.ipynb --to pdf --toc
```

### Render Project

``` {.bash filename='Terminal'}
quarto render
quarto render projdir
```

### Render w/ Metadata

``` {.bash filename='Terminal'}
quarto render document.qmd -M echo:false
quarto render document.qmd -M code-fold:true
```

### Render to Stdout

``` {.bash filename='Terminal'}
quarto render document.qmd --output -
```

