```{=html}
<% for (const cat of items) { %>
<% if (cat.capabilities && cat.capabilities.length) { %>
<p class="gal-caps"><b>Learn the Quarto features used:</b>
  <% for (const c of cat.capabilities) { %><a href="<%- c.href %>"><%= c.text %></a><% } %>
</p>
<% } %>
<% } %>
```
