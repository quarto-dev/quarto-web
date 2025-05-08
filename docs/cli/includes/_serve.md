Serve a Shiny interactive document.

By default, the document will be rendered first and then served. If you have previously rendered the document, pass --no-render to skip the rendering step.

``` {.bash}
quarto serve [input:string]
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
   <td style="text-align:left;"> <code>--no-render</code> </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> Do not render the document before serving. </td>
  </tr>
  <tr>
   <td style="text-align:left;"> <code>-p</code>, <code>--port</code> </td>
   <td style="text-align:left;"> <code>[port:number]</code> </td>
   <td style="text-align:left;"> The TCP port that the application should listen on. </td>
  </tr>
  <tr>
   <td style="text-align:left;"> <code>--host</code> </td>
   <td style="text-align:left;"> <code>[host:string]</code> </td>
   <td style="text-align:left;"> Hostname to bind to (defaults to 127.0.0.1) </td>
  </tr>
  <tr>
   <td style="text-align:left;"> <code>--browser</code> </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> Open a browser to preview the site. </td>
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
### Serve an interactive Shiny document

``` {.bash filename='Terminal'}
quarto serve dashboard.qmd
```

### Serve a document without rendering

``` {.bash filename='Terminal'}
quarto serve dashboard.qmd --no-render
```

