// don't run the post-render on incremental render or preview
console.log("Running post-render script for Algolia search index.");
if (!Deno.env.get("QUARTO_PROJECT_RENDER_ALL")) {
    console.log("   Skipping custom attribute addition for Algolia search as this is not a full render.");
    Deno.exit(0);
}
console.log("   Adding custom attribute for Algolia search.");
// This script adds a custom attribute to the Algolia search index for guides
const j = JSON.parse(Deno.readTextFileSync("_site/search.json"));
j.forEach((entry) => {
    const crumb = entry.crumbs || [];
    entry.guide = crumb[0] === "Guide" ? 1 : 0;
})
Deno.writeTextFileSync("_site/search.json", JSON.stringify(j, null, 2));
    