```{=html}
<nav id="gal-rail" class="gal-rail" aria-label="Gallery categories">
  <ul>
    <% for (const item of items) { %>
      <li>
        <a class="gal-rail__link cat-<%- item.slug %>" href="#<%- item.anchor %>">
          <span class="gal-rail__mark" aria-hidden="true"><% if (item.icon) { %><i class="bi bi-<%- item.icon %>"></i><% } %></span>
          <span class="gal-rail__label"><%= item.category %></span>
        </a>
      </li>
    <% } %>
    <li>
      <a class="gal-rail__link cat-browse" href="#browse-by-format">
        <span class="gal-rail__mark" aria-hidden="true"><i class="bi bi-collection"></i></span>
        <span class="gal-rail__label">Browse all</span>
      </a>
    </li>
  </ul>
</nav>
<script id="gal-rail-spy">
  document.addEventListener("DOMContentLoaded", () => {
    const nav = document.getElementById("gal-rail");
    if (!nav) return;

    const anchors = new Map();
    const targets = [];
    nav.querySelectorAll(".gal-rail__link").forEach((link) => {
      const id = (link.getAttribute("href") || "").slice(1);
      const el = id && document.getElementById(id);
      if (el) {
        anchors.set(id, link);
        targets.push(el);
      }
    });
    if (targets.length === 0) return;

    const list = nav.querySelector("ul");
    const revealActive = (link) => {
      if (list.scrollHeight > list.clientHeight + 1) {
        list.scrollTop = link.offsetTop - list.offsetTop + link.offsetHeight / 2 - list.clientHeight / 2;
      }
      if (list.scrollWidth > list.clientWidth + 1) {
        list.scrollLeft = link.offsetLeft - list.offsetLeft + link.offsetWidth / 2 - list.clientWidth / 2;
      }
    };

    let activeId = null;
    const setActive = (id) => {
      if (activeId === id) return;
      const previous = anchors.get(activeId);
      if (previous) {
        previous.classList.remove("active");
        previous.removeAttribute("aria-current");
      }
      const current = anchors.get(id);
      if (current) {
        current.classList.add("active");
        current.setAttribute("aria-current", "true");
        revealActive(current);
      }
      activeId = id;
    };

    // Keyboard focus in the horizontal bottom dock: bring the focused chip into
    // view so a sighted keyboard user is never scrolled off the edge.
    nav.addEventListener("focusin", (event) => {
      const link = event.target.closest(".gal-rail__link");
      if (link) revealActive(link);
    });

    if ("IntersectionObserver" in window) {
      const observer = new IntersectionObserver(
        (entries) => {
          const visible = entries
            .filter((e) => e.isIntersecting)
            .sort((a, b) => a.boundingClientRect.top - b.boundingClientRect.top);
          if (visible.length > 0) setActive(visible[0].target.id);
        },
        { rootMargin: "-20% 0px -70% 0px", threshold: 0 },
      );
      targets.forEach((t) => observer.observe(t));

      const footer = document.querySelector(".nav-footer, footer.footer");
      if (footer) {
        let footerVisible = false;
        const syncTuck = () => {
          if (footerVisible && nav.contains(document.activeElement)) return;
          nav.classList.toggle("gal-rail--tucked", footerVisible);
          nav.inert = footerVisible;
        };
        const footerObserver = new IntersectionObserver(
          (entries) => {
            footerVisible = entries[entries.length - 1].isIntersecting;
            syncTuck();
          },
          { threshold: 0 },
        );
        footerObserver.observe(footer);
        nav.addEventListener("focusout", (event) => {
          if (!nav.contains(event.relatedTarget)) syncTuck();
        });
      }
    }

    const landed = window.location.hash.slice(1);
    setActive(anchors.has(landed) ? landed : targets[0].id);
  });
</script>
```
