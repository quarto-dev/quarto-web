```{=html}
<%
  // Collect every distinct `categories` value across the browse listings and
  // render one chip per category, so the set stays in sync with the data and
  // nothing is hand-maintained. Each chip deep-links to the browse listing
  // pre-filtered on that category.
  const seen = [];
  for (const item of items) {
    for (const c of (item.categories || [])) {
      const v = String(c).trim();
      if (v && seen.indexOf(v) === -1) seen.push(v);
    }
  }
  seen.sort();
%>
<div class="gal-caps gal-browse-chips">
<% for (const c of seen) { %><a href="browse.html#category=<%= c %>"><%= c %></a> <% } %>
</div>
```
