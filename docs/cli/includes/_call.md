Access functions of Quarto subsystems such as its rendering engines.

``` {.bash}
quarto call 
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
  <tr>
   <td style="text-align:left;"> <code>engine</code> </td>
   <td style="text-align:left;"> Access functionality specific to quarto's different rendering engines. </td>
  </tr>
  <tr>
   <td style="text-align:left;"> <code>build-ts-extension</code> </td>
   <td style="text-align:left;"> Build TypeScript execution engine extensions.

This command type-checks and bundles TypeScript extensions into single JavaScript files using Quarto's bundled deno bundle.

The entry point is determined by:
  1. [entry-point] command-line argument (if specified)
  2. bundle.entryPoint in deno.json (if specified)
  3. Single .ts file in src/ directory
  4. src/mod.ts (if multiple .ts files exist) </td>
  </tr>
  <tr>
   <td style="text-align:left;"> <code>typst-gather</code> </td>
   <td style="text-align:left;"> Gather Typst packages for a format extension.

This command scans Typst files for @preview imports and downloads the packages to a local directory for offline use.

Configuration is determined by:
  1. typst-gather.toml in current directory (if present)
  2. Auto-detection from _extension.yml (template and template-partials) </td>
  </tr>
</tbody>
</table>
```




