Access functionality specific to the julia rendering engine.

``` {.bash}
quarto call engine julia 
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
   <td style="text-align:left;"> <code>status</code> </td>
   <td style="text-align:left;"> Get status information on the currently running Julia server process. </td>
  </tr>
  <tr>
   <td style="text-align:left;"> <code>kill</code> </td>
   <td style="text-align:left;"> Kill the control server if it is currently running. This will also kill all notebook worker processes. </td>
  </tr>
  <tr>
   <td style="text-align:left;"> <code>log</code> </td>
   <td style="text-align:left;"> Print the content of the julia server log file if it exists which can be used to diagnose problems. </td>
  </tr>
  <tr>
   <td style="text-align:left;"> <code>close</code> </td>
   <td style="text-align:left;"> Close the worker for a given notebook. If it is currently running, it will not be interrupted. </td>
  </tr>
  <tr>
   <td style="text-align:left;"> <code>stop</code> </td>
   <td style="text-align:left;"> Send a message to the server that it should close all notebooks and exit. This will fail if any notebooks are not idle. </td>
  </tr>
</tbody>
</table>
```




