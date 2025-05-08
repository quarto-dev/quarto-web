Updates an extension or global dependency.

``` {.bash}
quarto update [target...]
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
   <td style="text-align:left;"> <code>--no-prompt</code> </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> Do not prompt to confirm actions </td>
  </tr>
  <tr>
   <td style="text-align:left;"> <code>--embed</code> </td>
   <td style="text-align:left;"> <code><extensionId></code> </td>
   <td style="text-align:left;"> Embed this extension within another extension (used when authoring extensions). </td>
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
### Update extension (Github)

``` {.bash filename='Terminal'}
quarto update extension <gh-org>/<gh-repo>
```

### Update extension (file)

``` {.bash filename='Terminal'}
quarto update extension <path-to-zip>
```

### Update extension (url)

``` {.bash filename='Terminal'}
quarto update extension <url>
```

### Update TinyTeX

``` {.bash filename='Terminal'}
quarto update tool tinytex
```

### Update Chromium

``` {.bash filename='Terminal'}
quarto update tool chromium
```

### Choose tool to update

``` {.bash filename='Terminal'}
quarto update tool
```

