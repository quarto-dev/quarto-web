```{=html}
<ul class="gal-chooser" aria-label="Gallery categories">
<% for (const item of items) { %>
  <li>
    <a class="gal-choice cat-<%- item.slug %>" href="<%- item.page %>">
      <span class="gal-choice-title"><%= item.category %></span>
      <p><%= item.tagline %></p>
    </a>
  </li>
<% } %>
</ul>
```
