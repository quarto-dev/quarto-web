const j = JSON.parse(Deno.readTextFileSync("_site/search.json"));
j.forEach((entry) => {
    const crumb = entry.crumbs || [];
    entry.weight = crumb[0] === "Guide" ? 1 : 0;
})
Deno.writeTextFileSync("_site/search.json", JSON.stringify(j, null, 2));
    