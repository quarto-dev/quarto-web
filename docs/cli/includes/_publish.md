Publish a document or project to a provider.

Available providers include:

 - Quarto Pub (quarto-pub)
 - GitHub Pages (gh-pages)
 - Posit Connect (connect)
 - Netlify (netlify)
 - Confluence (confluence)
 - Hugging Face Spaces (huggingface)

Accounts are configured interactively during publishing.
Manage/remove accounts with: quarto publish accounts

``` {.bash}
quarto publish [provider] [path]
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
   <td style="text-align:left;"> <code>--id</code> </td>
   <td style="text-align:left;"> <code><id:string></code> </td>
   <td style="text-align:left;"> Identifier of content to publish </td>
  </tr>
  <tr>
   <td style="text-align:left;"> <code>--server</code> </td>
   <td style="text-align:left;"> <code><server:string></code> </td>
   <td style="text-align:left;"> Server to publish to </td>
  </tr>
  <tr>
   <td style="text-align:left;"> <code>--token</code> </td>
   <td style="text-align:left;"> <code><token:string></code> </td>
   <td style="text-align:left;"> Access token for publising provider </td>
  </tr>
  <tr>
   <td style="text-align:left;"> <code>--no-render</code> </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> Do not render before publishing. </td>
  </tr>
  <tr>
   <td style="text-align:left;"> <code>--no-prompt</code> </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> Do not prompt to confirm publishing destination </td>
  </tr>
  <tr>
   <td style="text-align:left;"> <code>--no-browser</code> </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> Do not open a browser to the site after publishing </td>
  </tr>
  <tr>
   <td style="text-align:left;"> <code>--log</code> </td>
   <td style="text-align:left;"> <code><file></code> </td>
   <td style="text-align:left;"> Path to log file </td>
  </tr>
  <tr>
   <td style="text-align:left;"> <code>--log-level</code> </td>
   <td style="text-align:left;"> <code><level></code> </td>
   <td style="text-align:left;"> Log level (debug, info, warning, error, critical) </td>
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
### Publish project (prompt for provider)

``` {.bash filename='Terminal'}
quarto publish
```

### Publish document (prompt for provider)

``` {.bash filename='Terminal'}
quarto publish document.qmd
```

### Publish project to Hugging Face Spaces

``` {.bash filename='Terminal'}
quarto publish huggingface
```

### Publish project to Netlify

``` {.bash filename='Terminal'}
quarto publish netlify
```

### Publish with explicit target

``` {.bash filename='Terminal'}
quarto publish netlify --id DA36416-F950-4647-815C-01A24233E294
```

### Publish project to GitHub Pages

``` {.bash filename='Terminal'}
quarto publish gh-pages
```

### Publish project to Posit Connect

``` {.bash filename='Terminal'}
quarto publish connect
```

### Publish with explicit credentials

``` {.bash filename='Terminal'}
quarto publish connect --server example.com --token 01A24233E294
```

### Publish without confirmation prompt

``` {.bash filename='Terminal'}
quarto publish --no-prompt
```

### Publish without rendering

``` {.bash filename='Terminal'}
quarto publish --no-render
```

### Publish without opening browser

``` {.bash filename='Terminal'}
quarto publish --no-browser
```

### Manage/remove publishing accounts

``` {.bash filename='Terminal'}
quarto publish accounts
```

