```{=html}
<ul class="gal-cards list">
<% for (const item of items) { %>
  <% const cardHref = item.live || item.path || '#'; %>
  <li class="gal-card<%= item.slug ? ' cat-' + item.slug : '' %>" <%= metadataAttrs(item) %>>
    <% if (item.image) { %>
      <a href="<%- cardHref %>" target="_blank" rel="noopener noreferrer" tabindex="-1" aria-hidden="true">
        <img class="thumb-img" src="<%- item.image %>" alt=""/>
      </a>
    <% } else { %>
      <div class="thumb" aria-hidden="true"><%= item.name || item.title %></div>
    <% } %>
    <div class="body">
      <p class="job"><a class="listing-title" href="<%- cardHref %>" target="_blank" rel="noopener noreferrer" aria-label="<%= item.title %>, opens in new window"><%= item.title %></a></p>
      <% if (item.alt) { %><span class="visually-hidden">Screenshot: <%= item.alt %></span><% } %>
      <p class="who"><span class="listing-name"><%= item.name %></span><% if (item.author) { %> by <span class="listing-author"><%= item.author %></span><% } %></p>
      <% if (item.categories && item.categories.length) { %>
      <div class="gal-cats listing-categories">
        <% for (const c of item.categories) { %><div class="listing-category" role="button" tabindex="0" aria-label="Filter by <%= c %>" data-category="<%- btoa(unescape(encodeURIComponent(c))) %>" onclick="window.quartoListingCategory(this.dataset.category); return false;" onkeydown="if (event.key === 'Enter' || event.key === ' ') { event.preventDefault(); window.quartoListingCategory(this.dataset.category); }"><%= c %></div><% } %>
      </div>
      <% } %>
      <% if (item.features && item.features.length) { %>
      <div class="feats">
        <% for (const f of item.features) { %><span class="f<%= /interactive/i.test(f) ? ' i' : '' %>"><%= f %></span><% } %>
      </div>
      <% } %>
      <% if (item.description) { %><p class="why listing-description"><%= item.description %></p><% } %>
      <div class="foot">
        <% if (item.live) { %><a href="<%- item.live %>" target="_blank" rel="noopener noreferrer" aria-label="Live demo of <%= item.name || item.title %>, opens in new window">Live &#8599;</a><% } %>
        <% if (item.code) { %><a href="<%- item.code %>" target="_blank" rel="noopener noreferrer" aria-label="Source for <%= item.name || item.title %>, opens in new window">&lt;/&gt; Source</a><% } %>
      </div>
    </div>
  </li>
<% } %>
</ul>
```
