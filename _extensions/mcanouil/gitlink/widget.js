/**
 * Gitlink - Repository Navigation Widget
 * Replaces every `#gitlink-widget` placeholder (navbar item, sidebar tool, or
 * sidebar contents item) with a button showing live star and fork counts and a
 * dropdown menu of repository links. Configuration is injected by the gitlink
 * Lua filter as a JSON script element; counts come from the platform REST API,
 * cached in localStorage for four hours so the rate limit is not hit on every
 * page view, and shared by every widget on the page. A stale cache or `?`
 * covers a failed request. Octicon path data for the icons the menu uses
 * arrives in the configuration (`icons`); other icon names render as Bootstrap
 * Icons, which Quarto bundles with every HTML page.
 *
 * @license MIT
 * @copyright 2026 Mickaël Canouil
 * @author Mickaël Canouil
 */
// Widget inspired by and derived from the GitHub button in
// https://github.com/posit-dev/great-docs by Rich Iannone
// (https://github.com/rich-iannone).
(function () {
  "use strict";

  const CACHE_DURATION = 4 * 60 * 60 * 1000;

  const SVG_NS = "http://www.w3.org/2000/svg";

  const ARROW_PATHS = [
    { d: "M4.427 7.427l3.396 3.396a.25.25 0 00.354 0l3.396-3.396A.25.25 0 0011.396 7H4.604a.25.25 0 00-.177.427z" },
  ];

  const readConfig = () => {
    const node = document.getElementById("gitlink-widget-config");
    if (!node) return null;
    try {
      return JSON.parse(node.textContent);
    } catch (error) {
      return null;
    }
  };

  // Large numbers read better abbreviated: 1500 -> 1.5k, 2000000 -> 2M.
  const formatCount = (value) => {
    if (value === undefined || value === null || value === "?") return "?";
    if (value >= 1e6) return (value / 1e6).toFixed(1).replace(/\.0$/, "") + "M";
    if (value >= 1e3) return (value / 1e3).toFixed(1).replace(/\.0$/, "") + "k";
    return String(value);
  };

  // Read and parse the cached stats, or null. Freshness is judged by the
  // caller so expired data can still serve as a fallback on a failed refresh.
  const readCache = (cacheKey) => {
    try {
      const raw = localStorage.getItem(cacheKey);
      return raw ? JSON.parse(raw) : null;
    } catch (error) {
      return null;
    }
  };

  const writeCache = (cacheKey, data) => {
    try {
      localStorage.setItem(cacheKey, JSON.stringify(data));
    } catch (error) {
      // localStorage may be unavailable (private mode, quota); counts still
      // render from the live response, only the cache is skipped.
    }
  };

  // Only http(s) links belong in the menu; anything else (e.g. javascript:)
  // is dropped.
  const safeHref = (href) => {
    try {
      const url = new URL(href, window.location.href);
      return url.protocol === "http:" || url.protocol === "https:" ? url.href : null;
    } catch (error) {
      return null;
    }
  };

  // Labels arrive either as plain strings or as structured parts emitted by
  // the Lua filter: {text} or {tag, attrs} with tags and attributes already
  // allowlisted at render time. The same allowlist is enforced again here,
  // and everything is built with createElement/createTextNode, so no HTML
  // string is ever parsed in the browser.
  const ALLOWED_LABEL_TAGS = ["span", "em", "strong", "code", "sub", "sup", "i", "iconify-icon"];
  const ALLOWED_LABEL_ATTRIBUTES = [
    "class", "icon", "width", "height", "inline", "title", "role",
    "aria-label", "aria-hidden",
  ];

  const buildLabelInto = (target, label) => {
    if (typeof label === "string") {
      target.appendChild(document.createTextNode(label));
      return;
    }
    (label || []).forEach((part) => {
      if (typeof part.text === "string") {
        target.appendChild(document.createTextNode(part.text));
        return;
      }
      if (!part.tag || ALLOWED_LABEL_TAGS.indexOf(part.tag) === -1) return;
      const element = document.createElement(part.tag);
      const attrs = part.attrs || {};
      ALLOWED_LABEL_ATTRIBUTES.forEach((name) => {
        if (typeof attrs[name] === "string") {
          element.setAttribute(name, attrs[name]);
        }
      });
      target.appendChild(element);
    });
  };

  // Build an SVG element from path attribute objects ({d, fill-rule}) so no
  // HTML string is ever parsed.
  const buildSvg = (paths, size) => {
    const svg = document.createElementNS(SVG_NS, "svg");
    svg.setAttribute("viewBox", "0 0 16 16");
    svg.setAttribute("width", String(size));
    svg.setAttribute("height", String(size));
    svg.setAttribute("fill", "currentColor");
    svg.setAttribute("aria-hidden", "true");
    paths.forEach((attrs) => {
      const path = document.createElementNS(SVG_NS, "path");
      path.setAttribute("d", attrs.d);
      if (attrs["fill-rule"]) path.setAttribute("fill-rule", attrs["fill-rule"]);
      svg.appendChild(path);
    });
    return svg;
  };

  // An icon spec is a name whose octicon paths were embedded in the config,
  // or a Bootstrap icon name (Quarto bundles Bootstrap Icons and uses the
  // same names for its navbar tools and callouts). Returns an element or null.
  const buildIcon = (spec, size, icons) => {
    if (!spec) return null;
    const paths = icons && icons[spec];
    if (paths) {
      return buildSvg(paths, size);
    }
    if (typeof spec === "string" && /^[a-z0-9-]+$/.test(spec)) {
      const icon = document.createElement("i");
      icon.className = "bi bi-" + spec;
      icon.setAttribute("aria-hidden", "true");
      icon.style.fontSize = size + "px";
      icon.style.lineHeight = "1";
      return icon;
    }
    return null;
  };

  const buildStat = (name, title, iconKey, icons) => {
    const stat = document.createElement("span");
    stat.className = "gitlink-widget-stat gitlink-widget-" + name;
    stat.title = title;
    const icon = buildIcon(iconKey, 14, icons);
    if (icon) stat.appendChild(icon);
    const count = document.createElement("span");
    count.className = "gitlink-widget-count";
    count.dataset.stat = name;
    count.textContent = "-";
    stat.appendChild(count);
    return stat;
  };

  // Disclosure pattern: a native button toggling a plain list of links, per
  // the ARIA Authoring Practices for navigation link collections. No menu
  // roles, so Tab moves through the links naturally.
  const buildTrigger = (config, menuId) => {
    const trigger = document.createElement("button");
    trigger.type = "button";
    trigger.className = "gitlink-widget-trigger";
    trigger.setAttribute("aria-expanded", "false");
    trigger.setAttribute("aria-controls", menuId);
    trigger.setAttribute("aria-label", config.menuLabel);

    const platformIcon = buildIcon(config.icon, 20, config.icons);
    if (platformIcon) {
      platformIcon.classList.add("gitlink-widget-platform-icon");
      trigger.appendChild(platformIcon);
    }

    if (config.api) {
      const stats = document.createElement("span");
      stats.className = "gitlink-widget-stats";
      stats.appendChild(buildStat("stars", "Stars", "star", config.icons));
      stats.appendChild(buildStat("forks", "Forks", "fork", config.icons));
      trigger.appendChild(stats);
    }

    const arrow = buildSvg(ARROW_PATHS, 16);
    arrow.classList.add("gitlink-widget-arrow");
    trigger.appendChild(arrow);
    return trigger;
  };

  const buildDropdown = (config, menuId) => {
    const dropdown = document.createElement("div");
    dropdown.id = menuId;
    dropdown.className = "gitlink-widget-dropdown";
    dropdown.setAttribute("aria-hidden", "true");

    config.links.forEach((link) => {
      if (link.divider) {
        const divider = document.createElement("div");
        divider.className = "gitlink-widget-divider";
        dropdown.appendChild(divider);
        return;
      }
      const href = safeHref(link.href);
      if (!href) return;
      const item = document.createElement("a");
      item.className = "gitlink-widget-item";
      item.href = href;
      item.target = "_blank";
      item.rel = "noopener";
      const icon = buildIcon(link.icon, 16, config.icons);
      if (icon) item.appendChild(icon);
      const label = document.createElement("span");
      label.className = "gitlink-widget-item-label";
      buildLabelInto(label, link.label);
      item.appendChild(label);
      const newTabHint = document.createElement("span");
      newTabHint.className = "gitlink-widget-sr-only";
      newTabHint.textContent = " (opens in new tab)";
      item.appendChild(newTabHint);
      dropdown.appendChild(item);
    });
    return dropdown;
  };

  // The first widget on a page keeps the historical `gitlink-widget` id; any
  // further placeholder gets a suffixed one so ids stay unique.
  const buildWidget = (config, index) => {
    const rootId = index === 0 ? "gitlink-widget" : "gitlink-widget-" + index;
    const menuId = rootId + "-menu";
    const root = document.createElement("div");
    root.id = rootId;
    root.className = "gitlink-widget";
    root.appendChild(buildTrigger(config, menuId));
    root.appendChild(buildDropdown(config, menuId));
    return root;
  };

  const showStats = (widget, stats, config) => {
    const setCount = (selector, value) => {
      const node = widget.querySelector(selector);
      if (node) node.textContent = formatCount(value);
    };
    setCount('.gitlink-widget-count[data-stat="stars"]', stats.stars);
    setCount('.gitlink-widget-count[data-stat="forks"]', stats.forks);

    // Surface the counts to assistive technology; the visual counters are
    // bare numbers with mouse-only tooltips.
    const spoken = [];
    if (typeof stats.stars === "number") spoken.push(formatCount(stats.stars) + " stars");
    if (typeof stats.forks === "number") spoken.push(formatCount(stats.forks) + " forks");
    if (spoken.length > 0) {
      const trigger = widget.querySelector(".gitlink-widget-trigger");
      if (trigger) {
        trigger.setAttribute("aria-label", config.menuLabel + ", " + spoken.join(", "));
      }
    }
  };

  // The in-flight request, shared by every widget on the page (they all read
  // the same configuration) so several placeholders make one API call instead
  // of racing each other before the cache is written.
  let pendingStats = null;

  const fetchStats = (config) => {
    // Read + parse the cache once; branch on freshness so the stale-fallback
    // path does not re-read and re-parse the same entry.
    const cached = readCache(config.cacheKey);
    if (cached && Date.now() - cached.timestamp <= CACHE_DURATION) {
      return Promise.resolve(cached);
    }
    if (pendingStats) return pendingStats;

    const options = { headers: config.api.headers || {} };
    // Bound the request so a slow API falls back to the stale cache instead
    // of leaving the counts pending; older browsers just skip the timeout.
    if (typeof AbortSignal !== "undefined" && AbortSignal.timeout) {
      options.signal = AbortSignal.timeout(8000);
    }

    const request = fetch(config.api.endpoint, options)
      .then((response) => (response.ok ? response.json() : Promise.reject(response.status)))
      .then((data) => {
        const stats = {
          stars: data[config.api.starsField],
          forks: data[config.api.forksField],
          timestamp: Date.now(),
        };
        writeCache(config.cacheKey, stats);
        return stats;
      })
      .catch(() => cached || { stars: "?", forks: "?" });
    pendingStats = request;
    return request;
  };

  const loadStats = (widget, config) => {
    if (!config.api) return;
    fetchStats(config).then((stats) => showStats(widget, stats, config));
  };

  const setupDropdown = (widget) => {
    const trigger = widget.querySelector(".gitlink-widget-trigger");
    const dropdown = widget.querySelector(".gitlink-widget-dropdown");
    if (!trigger || !dropdown) return;

    const setOpen = (open) => {
      trigger.setAttribute("aria-expanded", String(open));
      dropdown.setAttribute("aria-hidden", String(!open));
      widget.classList.toggle("gitlink-widget-open", open);
    };

    // The trigger is a native button, so Enter/Space activation is built in.
    trigger.addEventListener("click", (event) => {
      event.stopPropagation();
      setOpen(trigger.getAttribute("aria-expanded") !== "true");
    });

    document.addEventListener("click", (event) => {
      if (!widget.contains(event.target)) setOpen(false);
    });

    document.addEventListener("keydown", (event) => {
      if (event.key !== "Escape") return;
      // Closing while focus is on a link inside the menu would drop focus
      // into a hidden subtree; hand it back to the trigger.
      if (widget.contains(document.activeElement) && document.activeElement !== trigger) {
        trigger.focus();
      }
      setOpen(false);
    });
  };

  // Replace one placeholder anchor with a widget. Only the anchor goes, so
  // whatever Quarto wrapped it in (`li.nav-item`, `li.sidebar-item >
  // div.sidebar-item-container`, `div.sidebar-tools-main`) is preserved, and
  // the widget inherits the spacing and colours of its neighbours.
  const mountWidget = (anchor, index, config) => {
    const root = buildWidget(config, index);

    // The tools row is a horizontal strip of icon-sized controls; flag it so
    // the CSS can stack the widget above the search and colour-scheme
    // controls instead of squeezing the counts in beside them.
    const tools = anchor.closest(".sidebar-tools-main, .sidebar-tools-collapse");
    if (tools) {
      tools.classList.add("gitlink-widget-tools");
    } else if (anchor.closest("#quarto-sidebar")) {
      // A sidebar navigation item is as wide as the sidebar and sits in its
      // scroll container, so its menu expands inline rather than overlaying.
      root.classList.add("gitlink-widget-sidebar");
    }

    anchor.replaceWith(root);

    loadStats(root, config);
    setupDropdown(root);
  };

  document.addEventListener("DOMContentLoaded", function () {
    const config = readConfig();
    if (!config) return;

    // Quarto rewrites the placeholder href to a relative path
    // (`./#gitlink-widget` at the root, `../#gitlink-widget` deeper), so
    // match the fragment suffix rather than an exact href.
    const anchors = document.querySelectorAll('a[href$="#gitlink-widget"]');
    anchors.forEach((anchor, index) => mountWidget(anchor, index, config));
  });
})();
