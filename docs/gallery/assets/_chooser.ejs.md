```{=html}
<ul class="gal-chooser">
<% for (const item of items) { %>
  <li>
    <a class="gal-choice cat-<%- item.slug %>" href="<%- item.page %>">
      <span class="row">
        <span class="ic" aria-hidden="true"><% if (item.icon) { %><i class="bi bi-<%- item.icon %>"></i><% } %></span>
      </span>
      <span class="gal-choice-title"><%= item.category %></span>
      <p><%= item.tagline %></p>
    </a>
  </li>
<% } %>
</ul>
```
