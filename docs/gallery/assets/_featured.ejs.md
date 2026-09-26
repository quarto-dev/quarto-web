<% /* The chooser and the section rail render from the same featured.yml items, so pull them in as partials before the featured sections below. */ %>
<% partial("_chooser.ejs.md", { items }); %>

<% partial("_jumpnav.ejs.md", { items }); %>

```{=html}
<div class="gal-featured-intro">
  <h2 class="no-anchor">Need inspiration?</h2>
  <p>Browse a few examples we curated below.</p>
</div>
```

```{=html}
<% for (const cat of items) { %>
<section class="gal-section cat-<%- cat.slug %>" id="<%- cat.anchor %>">
  <div class="shead">
    <div class="l">
      <h2><a href="<%- cat.page %>"><span class="ic" aria-hidden="true"><% if (cat.icon) { %><i class="bi bi-<%- cat.icon %>"></i><% } %></span><%= cat.category %></a></h2>
      <span class="tag"><%= cat.tagline %></span>
    </div>
    <a class="gal-seeall" href="<%- cat.page %>">See all &rarr;</a>
  </div>

  <% if (cat.capabilities && cat.capabilities.length) { %>
  <p class="gal-caps"><b>Learn the Quarto features used:</b>
    <% for (const c of cat.capabilities) { %><a href="<%- c.href %>"><%= c.text %></a><% } %>
  </p>
  <% } %>

  <ul class="gal-cards">
    <% const featured = (cat.cards || []).slice(0, 3); %>
    <% for (const item of featured) { %>
      <li class="gal-card">
        <% if (item.preview) { %>
          <a href="<%- item.live || '#' %>" target="_blank" rel="noopener noreferrer" tabindex="-1" aria-hidden="true" class="thumb-stack"><img class="thumb-img" src="<%- item.image %>" alt=""/><video class="thumb-img gal-preview" muted loop playsinline preload="none" tabindex="-1" aria-hidden="true"><source src="<%- item.preview %>.webm" type="video/webm"><source src="<%- item.preview %>.mp4" type="video/mp4"></video></a>
        <% } else if (item.image) { %>
          <a href="<%- item.live || '#' %>" target="_blank" rel="noopener noreferrer" tabindex="-1" aria-hidden="true"><img class="thumb-img" src="<%- item.image %>" alt=""/></a>
        <% } else { %>
          <div class="thumb" aria-hidden="true"><%= item.name || item.title %></div>
        <% } %>
        <div class="body">
          <p class="job"><a href="<%- item.live || '#' %>" target="_blank" rel="noopener noreferrer" aria-label="<%= item.title %>, opens in new window"><%= item.title %></a></p>
          <% if (item.alt) { %><span class="visually-hidden">Screenshot: <%= item.alt %></span><% } %>
          <% if (item.author) { %><p class="who">by <%= item.author %></p><% } %>
          <% if ((item.categories && item.categories.length) || (item.features && item.features.length)) { %>
          <div class="feats">
            <% for (const c of (item.categories || [])) { %><span class="f cat"><%= c %></span><% } %>
            <% for (const f of (item.features || [])) { %><span class="f<%= /interactive/i.test(f) ? ' i' : '' %>"><%= f %></span><% } %>
          </div>
          <% } %>
          <% if (item.description) { %><p class="why"><%= item.description %></p><% } %>
          <div class="foot">
            <% if (item.live) { %><a href="<%- item.live %>" target="_blank" rel="noopener noreferrer" aria-label="Live demo of <%= item.name || item.title %>, opens in new window">Live &#8599;</a><% } %>
            <% if (item.code) { %><a href="<%- item.code %>" target="_blank" rel="noopener noreferrer" aria-label="Source for <%= item.name || item.title %>, opens in new window">&lt;/&gt; Source</a><% } %>
          </div>
        </div>
      </li>
    <% } %>
    <% if (featured.length < 3) { %>
      <li class="gal-card ghost">
        <div class="body">
          <div style="font-size:1.3rem" aria-hidden="true">&#65291;</div>
          <div style="font-weight:600"><a href="https://github.com/quarto-dev/quarto-web/issues" target="_blank" rel="noopener noreferrer">Suggest an example</a></div>
          <div style="font-size:0.72rem"><%= cat.gap || 'help fill this category' %></div>
        </div>
      </li>
    <% } %>
  </ul>
</section>
<% } %>
<script id="gal-preview-play">
  document.addEventListener("DOMContentLoaded", () => {
    const videos = Array.from(document.querySelectorAll("video.gal-preview"));
    if (videos.length === 0) return;

    const reduce = window.matchMedia("(prefers-reduced-motion: reduce)");

    const cardOf = (video) => video.closest(".gal-card");

    // The static poster is a sibling <img> underneath; hiding the video (opacity 0)
    // reveals it, so leaving a card always returns to the still image, not a frozen
    // video frame.
    const stop = (video) => {
      video.style.opacity = "0";
      video.pause();
      video.currentTime = 0;
    };

    const start = (video) => {
      if (reduce.matches) return;
      video.style.opacity = "1";
      const playing = video.play();
      if (playing && typeof playing.catch === "function") playing.catch(() => {});
    };

    videos.forEach((video) => {
      const card = cardOf(video);
      if (!card) return;
      card.addEventListener("pointerenter", () => start(video));
      card.addEventListener("pointerleave", () => stop(video));
      card.addEventListener("focusin", () => start(video));
      card.addEventListener("focusout", () => stop(video));
    });

    // If the user switches to reduced-motion while a preview is playing, halt it.
    reduce.addEventListener("change", () => {
      if (reduce.matches) videos.forEach(stop);
    });
  });
</script>
```
