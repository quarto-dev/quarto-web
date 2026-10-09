// Mark the link to the current page and remember it, for every .page-chooser.
(function () {
  const filename = window.location.pathname.split("/").slice(-1)[0];
  for (const chooser of document.querySelectorAll(".page-chooser")) {
    const isIndex = filename === "" || filename === "index.html";
    const target = isIndex && chooser.dataset.default ? chooser.dataset.default : filename;
    for (const link of chooser.querySelectorAll("a")) {
      if (target && link.pathname.split("/").slice(-1)[0] === target) {
        link.setAttribute("aria-current", "page");
        break;
      }
    }
    if (chooser.dataset.storageKey && filename) {
      window.localStorage.setItem(chooser.dataset.storageKey, filename);
    }
  }
})();
