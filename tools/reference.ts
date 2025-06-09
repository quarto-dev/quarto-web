
import { basename, dirname, join } from "stdlib/path";
import { expandGlobSync } from "stdlib/fs";
import { parse } from "stdlib/yaml";
import { distinct } from "stdlib/collections";


export function asArray<T>(x?: T | Array<T>): Array<T> {
  return x ? Array.isArray(x) ? x : [x] : [];
}

// location of schema yaml and function to read from it
const schemasDir = Deno.realPathSync(Deno.args[0] || "../quarto-cli/src/resources/schema");
const readSchema = (file: string) => {
  const schema = parse(Deno.readTextFileSync(join(schemasDir, file)));
  return schema;
}

// format aliases and function to resolve a format list
// deno-lint-ignore no-explicit-any
const formatAliases = (readSchema("format-aliases.yml") as any)["aliases"] as Record<string, string[]>;
const allFormats = formatAliases["pandoc-all"];
const resolveFormats = (formats: string[]): string[] => {
  return distinct(formats
    .reduce((formats, format) => {
      if (format.startsWith("$")) {
        const aliasedFormats = formatAliases[format.slice(1)];
        return formats.concat(...resolveFormats(aliasedFormats));
      } else {
        return formats.concat(format);
      }
    }, formats)
    .filter(format => !format.startsWith("$")));
}

// option schema
interface OptionSchema {
  name: string;
  disabled?: string[];
  tags?: {
    formats?: string[];
    contexts?: string[];
    engine?: string;
    ["execute-only"]?: boolean;
  }
  description: string | { short: string, long?: string };
  hidden?: boolean;
}
const formatsFromOptionSchema = (option: OptionSchema) => {
  // if the formats start with ! they are disabled
  const disabled = option.disabled || option.tags?.formats?.filter(format => format.startsWith("!")).map(format => format.slice(1));
  if (disabled && disabled.length > 0) {
    const disabledFormats = resolveFormats(disabled);
    return allFormats.filter(format => !disabledFormats.includes(format));
  } else if (option.tags?.formats) {
    return resolveFormats(option.tags.formats);
  } else {
    return allFormats;
  }
}

// option that we'll process
interface Option {
  name: string;
  description: string;
  contexts?: string[];
  formats?: string[];
  engine?: string | string[];
}
interface OptionGroup {
  name: string;
  title: string;
  description?: string;
  options: Option[];
}

function asDescriptionString(description?: string | { short: string, long?: string }) {
  return typeof (description) === "string"
    ? description
    : description?.long || description?.short || "";
}

// helper to read a group schema
const readGroupOptions = (context: string, name: string): Array<Option> => {
  const groupOptions = readSchema(`${context}-${name}.yml`) as Array<OptionSchema>;
  if (groupOptions) {
    return groupOptions
      .filter(optionsSchema => !optionsSchema.hidden && (name !== "execute" || optionsSchema.tags?.["execute-only"]))
      .map(optionSchema => ({
        name: optionSchema.name,
        description: asDescriptionString(optionSchema.description),
        formats: formatsFromOptionSchema(optionSchema),
        contexts: optionSchema.tags?.contexts,
        engine: optionSchema.tags?.engine,
      }))
      .filter(group => group.name !== "hidden" && group.name !== "editor");
  } else {
    return [];
  }
};


// read baseline config
const groups = readSchema("groups.yml") as { [key: string]: { [key: string]: { title: string, description?: string } } };

// cell options
const cellGroups = groups["cell"];
const cellOptions = Object.keys(cellGroups).map(group => {
  const title = cellGroups[group]["title"];
  const description = cellGroups[group]["description"];
  const options = readGroupOptions("cell", group);
  return {
    name: group,
    title,
    description,
    options
  }
})

// document options
const documentGroups = groups["document"];
const documentOptions = Object.keys(documentGroups)
  .filter(group => !["comments"].includes(group))
  .map(group => {

    const title = documentGroups[group]["title"];
    const description = documentGroups[group]["description"];

    const options: Option[] = [];

    // look for cell options
    for (const cellGroup of cellOptions) {
      for (const cellOption of cellGroup.options) {
        if (cellOption.contexts?.includes("document-" + group)) {
          options.push(cellOption);
        }
      }
    }

    // document options
    // options are a combination of document group options and cell
    // options that are also available at the document level
    readGroupOptions("document", group).forEach(option => options.push(option));
    return {
      name: group,
      title,
      description,
      options
    } as OptionGroup;
  });

const optionsForFormat = (format: string) => {
  return documentOptions
    .map(group => {
      return {
        ...group,
        options: group.options
          .filter(option => option.formats?.includes(format))
          .map(option => ({ name: option.name, description: option.description }))
      }
    })
    .filter(group => group.name !== "hidden" && group.name !== "editor" && group.options.length > 0)
}

const writeDocumentOptions = (format: string, path: string) => {
  const options = JSON.stringify(optionsForFormat(format), undefined, 2);
  Deno.writeTextFileSync(path, options);
}

// document formats
for (const file of expandGlobSync("docs/reference/formats/**/*.qmd")) {
  if (file.isFile) {
    const format = basename(file.name, ".qmd");
    writeDocumentOptions(format, join(dirname(file.path), format + ".json"));
  }
}


// cell pages
const cellPages = {
  cells: ["attributes", "codeoutput", "textoutput", "figure", "table", "layout", "pagelayout", "cache", "include"],
} as Record<string, string[]>;

function writeCellGroups(engine: string, groups: string[], path: string) {

  let writeGroups = (structuredClone(cellOptions) as Array<OptionGroup>).filter(group => groups.includes(group.name));

  // filter options on engine

  writeGroups.forEach(writeGroup => {
    writeGroup.options = writeGroup.options.filter(option => {
      return !option.engine || (asArray(option.engine).includes(engine));
    });
  });

  // filter out groups with no options
  writeGroups = writeGroups.filter(writeGroup => writeGroup.options.length > 0);

  Deno.writeTextFileSync(path, JSON.stringify(writeGroups, undefined, 2));
}

function writeCellPages(engine: string) {
  for (const page of Object.keys(cellPages)) {
    const groups = cellPages[page];
    writeCellGroups(engine, groups, `docs/reference/cells/${page}-${engine}.json`);
  }
}
writeCellPages("jupyter");
writeCellPages("knitr");
writeCellPages("ojs");


// project tables
const definitions = readSchema("definitions.yml") as Array<{
  id: string,
  object?: { properties: Record<string, unknown> },
  oneOf?: { schemas: Record<string, unknown> }
}>;

const project = readSchema("project.yml") as Array<{ name: string }>;

// read a project object
function readProjectProperties(props: { [name: string]: Record<string, unknown> }, descriptions?: Record<string, string>) {
  return Object.keys(props)
    .filter(key => props[key].hidden !== true)
    .map(key => ({
      name: key,
      description: descriptions?.[key] || asDescriptionString(findVal(props[key], "description"))
    }))
}

function readProjectObject(name: string, descriptions?: Record<string, string>) {
  // deno-lint-ignore no-explicit-any
  const obj = project.find(value => value.name == name) as any;

  const results = [];
  const props = obj["schema"]["object"]["properties"];
  if (props) {
    results.push(...readProjectProperties(props, descriptions));
  }

  const supers = obj["schema"]["object"]["super"];
  if (supers) {
    (supers as { resolveRef: string }[]).forEach((sup) => {
      results.push(...readDefinitionsId(sup.resolveRef, descriptions));
    })
  }

  return results;
}

function readDefinitionsId(id: string, descriptions?: Record<string, string>) {
  const obj = definitions.find(value => value.id === id) as any;

  const baseObject = (obj["object"] || obj["schema"]["object"]);
  const props = baseObject["properties"];

  const results = [];
  results.push(...readProjectProperties(props, descriptions));

  const supers = obj["super"];
  if (supers) {
    (supers as { resolveRef: string }[]).forEach((sup) => {
      console.log('super!');
      results.push(...readDefinitionsId(sup.resolveRef));
    })
  }
  return results;
}

function readDefinitionsIdSuper(id: string, descriptions?: Record<string, string>) {
  const obj = definitions.find(value => value.id === id) as any;

  const baseObject = (obj["object"] || obj["schema"]["object"]);
  const props = baseObject["properties"];

  const results = [];
  results.push(...readProjectProperties(props, descriptions));

  const _super = baseObject["super"];
  if (_super) {
    results.push(...readDefinitionsIdSuper(_super.resolveRef));
  }
  return results;
}

function readTypographyOptions(id: string, toFollow: Array<string>) {
  const obj = definitions.find(value => value.id === id) as any;

  const baseObject = (obj["object"] || obj["schema"]["object"]);
  const props = baseObject["properties"];
  const descriptions = {
    "fonts": asDescriptionString(findVal(props.fonts, "description")) +" See [Font resource definitions](#font-resource-definitions) for more information."
  };

  for (const [key, prop] of Object.entries(props).filter(([_, {ref}]) => ref)) {
    if (prop.hidden) {
      continue;
    }
    const shortref = prop.ref.replace(/^brand-typography-options-/, '');
    descriptions[key] = asDescriptionString(findVal(prop, "description")) +" See [" + shortref + "](#" + shortref + ") for more information.";
    toFollow.push(prop.ref)
  }

  const results = [];
  results.push(...readProjectProperties(props, descriptions));

  return results;
}

function readNavigationItem(descriptions?: Record<string, string>) {
  const obj = definitions.find(value => value.id === "navigation-item") as any;
  const refId = obj["anyOf"][1]["ref"];
  return readDefinitionsId(refId, descriptions);
}

function readDefinitionsObject(name: string, descriptions?: Record<string, string>) {

  const root = findVal(definitions, name)?.["anyOf"][1];
  if (root) {
    const rootRef = root as Record<string, string>;
    if (rootRef.ref !== undefined) {
      return readDefinitionsId(rootRef.ref);
    } else {
      const obj = root["object"]["properties"]!;
      return readProjectProperties(obj, descriptions);
    }
  } else {
    throw new Error("Unexpected data structure for " + name);
  }
}

function readSidebarObject(descriptions?: Record<string, string>) {
  const obj = findVal(definitions, "sidebar")?.["anyOf"][1]["maybeArrayOf"]["object"]["properties"]!;
  return readProjectProperties(obj, descriptions);
}

// deno-lint-ignore no-explicit-any
function findVal(object: any, key: string) {

  const keys = Object.keys(object);
  for (const k of keys) {
    if (k === key) {
      return object[k];
    }
  }

  for (const k of keys) {
    if (object[k] && typeof object[k] === 'object') {
      const value = findVal(object[k], key) as any;
      if (value !== undefined) {
        return value;
      }
    }
  }

  return undefined;
}

// Metadata pages
function writeMetadataTable(name: string, title: string, options: Array<Option>) {
  const path = `docs/reference/metadata/${name}.json`;
  const metadata = [{
    "name": name,
    "title": title,
    "options": options
  }];
  Deno.writeTextFileSync(path, JSON.stringify(metadata, undefined, 2));
}

const citationOptions = readDefinitionsId("csl-item");
writeMetadataTable("citation", "Citation", citationOptions);

// Brand Page

// Filter `definitions` to items with an id field starting with `brand-`
const brandDefinitions = definitions.filter(item => item.id.startsWith("brand-"));

const brandOptions = readDefinitionsId("brand",{
  "meta": "Metadata for a brand, including the brand name and important links. See [Meta](#meta) for more information.",
  "logo": "Provide definitions and defaults for brand's logo in various formats and sizes. See [Logo](#logo) for more information.",
  "color": "The brand's custom color palette and theme. See [Color](#color) for more information.",
  "typography": "Typography definitions for the brand. See [Typography](#typography) for more information.",
  "defaults": "Default settings"
});

const toFollow : Array<string> = []

const typographyOptionDescriptions = {
  "family": "The font family.",
  "size": "The font size.",
  "weight": "The font weight.",
  "style": "The font style.",
  "color": "The text color.",
  "background-color": "The text background color.",
  "decoration": "The text decoration, i.e. underline",
  "line-height": "The distance between lines of text.",
};

const fontResourceDefinitions = definitions.find(value => value.id === "brand-font").anyOf;

const brandMetadata = [
  {
    "name": "brand",
    "title": "Brand",
    "options": brandOptions 
  },
  {
    "name": "brand-meta",
    "title": "Meta",
    "options": readDefinitionsId("brand-meta")
  },
  {
    "name": "brand-logo",
    "title": "Logo",
    "options": readDefinitionsId("brand-logo")
  },
  {
    "name": "brand-color",
    "title": "Color",
    "options": readDefinitionsId("brand-color")
  }, 
  {
    "name": "brand-typography",
    "title": "Typography",
    "options": readTypographyOptions("brand-typography", toFollow)
  },
  {
    "name": "font-resource-definitions",
    "title": "Font resource definitions",
    "level": 3,
    "options": []
  },
  ...fontResourceDefinitions.map(({ref}) => {
    if (!ref) return null;
    const source = ref.replace(/^brand-font-/, "");
    const descriptions = {"source": '\`"' + source + '"\`'}
    return {
      "name": ref,
      "title": source,
      "level": 4,
      "options": readDefinitionsIdSuper(ref, descriptions)
    }
  }).filter(x => x),
  ...toFollow.map(id => {
    const typography = definitions.find(value => value.id === id);
    const root = typography?.["anyOf"][1]?.object;
    if (!root?.properties) return null;
    return {
      "name": id,
      "title": id.replace(/^brand-typography-options-/, ""),
      "level": 3,
      "options": readProjectProperties(root.properties, typographyOptionDescriptions)
    }
  }).filter(x => x),
]
Deno.writeTextFileSync(`docs/reference/metadata/brand.json`, JSON.stringify(brandMetadata, undefined, 2));

// Crossref Page
const crossrefs = readSchema("document-crossref.yml");
const crossrefOptions = (crossrefs as any[]).find(value => value.name ==  "crossref")["schema"]["anyOf"][1]["object"]["properties"];
const customCrossrefOptions = findVal(crossrefs, "custom")["arrayOf"]["object"]["properties"];

const crossrefMetadata = [
{
  "name": "crossref",
  "title": "Crossref",
  "options": readProjectProperties(crossrefOptions)
},
{
  "name": "crossref-custom",
  "title": "Custom",
  "description": "Use the `custom` option to `crossref` to define new types of cross reference. For example: \n\n```yaml\n---\ncrossref:\n  custom:\n    - key: vid\n      kind: float\n      reference-prefix: Video\n---\n```\n",
  "options": readProjectProperties(customCrossrefOptions),
}];
Deno.writeTextFileSync(`docs/reference/metadata/crossref.json`, JSON.stringify(crossrefMetadata, undefined, 2));

function writeProjectTable(name: string, options: Array<Option>) {
  const path = `docs/reference/projects/${name}.json`;
  Deno.writeTextFileSync(path, JSON.stringify(options, undefined, 2));
}

const projectOptions = readProjectObject("project", {
  "preview": "Options for `quarto preview` (see [Preview](#preview))"
});
writeProjectTable("project", projectOptions);

const projectPreviewOptions = readDefinitionsId("project-preview", {
  "serve": "Options for external preview server (see [Serve](#serve))"
});
writeProjectTable("preview", projectPreviewOptions);

const projectPreviewServeOptions = readDefinitionsId("project-serve");
writeProjectTable("serve", projectPreviewServeOptions);

const socialMetadataOptions = readDefinitionsId("social-metadata");
const twitterOptions = socialMetadataOptions.concat(readDefinitionsObject("twitter-card"));
writeProjectTable("twitter", twitterOptions);

const openGraphOptions = socialMetadataOptions.concat(readDefinitionsObject("open-graph"));
writeProjectTable("open-graph", openGraphOptions);

const websiteOptions = readDefinitionsId("base-website", {
  "drafts": "A list of input documents that should be treated as drafts. Read more at [Website Drafts](/docs/websites/website-drafts.qmd).",
  "navbar": "Navbar options (see [Navbar](#navbar))",
  "sidebar": "Sidebar options (see [Sidebar](#sidebar))",
  "announcement": "An announcement displayed at the top of the page. (see [Announcement](#announcement))",
  "page-footer": "Page footer. Text content or [page footer](#footer) definition.",
  "open-graph": "Generate Open Graph metadata (see [Open Graph](#open-graph) options)",
  "twitter-card": "Generate Twitter Card metadata (see [Twitter Card](#twitter-card) options)",
  "search": "Site search (`true` or `false` to enable/disable, or provide custom [Search Options](#search)"
})
writeProjectTable("website", websiteOptions);


const excludeFromBooks = ['announcement', 'description', 'drafts', 'draft-mode', 'title'];

const bookOptions: Option[] = readProjectObject("book").concat(
  websiteOptions.filter(option => !excludeFromBooks.includes(option.name))
);

writeProjectTable("book", bookOptions);

const manuscriptOptions = readDefinitionsId("manuscript-schema", {
  "notebooks": "Options for notebooks included under the heading \"Notebooks\". See [Including Notebooks](/docs/manuscripts/components.html#including-notebooks) for more details."
});
writeProjectTable("manuscript", manuscriptOptions);

const navitemOptions = readNavigationItem({
  "menu": "Submenu of [navigation items](#nav-items)"
});
writeProjectTable("navitem", navitemOptions);


/*
const sidebarToolOptions = readDefinitionsId("tool-item", {
  "menu": "Submenu of [navigation items](#nav-items)"
});
writeProjectTable("sidebartool", sidebarToolOptions);
*/

const navbarOptions = readDefinitionsObject("navbar", {
  "left": "List of items for the left side of the navbar (see [Nav Items](#nav-items))",
  "right": "List of items for the right side of the navbar (see [Nav Items](#nav-items))"
});
writeProjectTable("navbar", navbarOptions);

const sidebarOptions = readSidebarObject({
  "tools": "List of sidebar tools (see [Sidebar Tools](#sidebar-tools))",
  "contents": "List of [navigation items](#nav-items) to appear in the sidebar. Can also include `section` entries which in turn contain sub-lists of navigation items."
});
writeProjectTable("sidebar", sidebarOptions);

const pageFooterOptions = readDefinitionsObject("page-footer", {
  "left": "String, or list of [navigation items](#nav-items) to appear in the left region of the footer",
  "center": "String, or list of [navigation items](#nav-items) to appear in the center region of the footer",
  "right": "String, or list of [navigation items](#nav-items) to appear in the right region of the footer"
});
writeProjectTable("pagefooter", pageFooterOptions);

const announcementOptions = readDefinitionsObject("announcement", {
});
writeProjectTable("announcement", announcementOptions);

const searchOptions = readDefinitionsObject("search", {
  "algolia": "Use an Algolia index for site search (see [Algolia Options](#algolia-options))"
});
writeProjectTable("search", searchOptions)

const algoliaOptions = readProjectProperties(findVal(definitions, "algolia")!["object"]["properties"], {
  "index-fields": "Fields to target for searches (see below for details)"
})
writeProjectTable("algolia", algoliaOptions);

const algoliaIndexFieldsOptions = readProjectProperties(findVal(definitions, "index-fields")!["object"]["properties"]);
writeProjectTable("algolia-index-fields", algoliaIndexFieldsOptions);

const utterancesOptions = readProjectProperties(findVal(definitions, "utterances")!["object"]["properties"]);
writeProjectTable("utterances", utterancesOptions);

const giscussOptions = readProjectProperties(findVal(definitions, "giscus")!["object"]["properties"]);
writeProjectTable("giscus", giscussOptions);

const hypothesisSchema = findVal(definitions, "hypothesis")!["anyOf"][1]["object"]["properties"];
const hypothesisOptions = readProjectProperties(hypothesisSchema, {
  "services": "Array of service definitions",
  "branding": "Custom branding/colors to apply to UI",
  "focus": "User focused filter set for the available annotations on a page",
  "requestConfigFromFrame": "Specify a host iframe to request configuration from"

});
writeProjectTable("hypothesis", hypothesisOptions);

const hypothesisServiceOptions = readProjectProperties(findVal(hypothesisSchema, "services")!["arrayOf"]["object"]["properties"]);
writeProjectTable("hypothesis-service", hypothesisServiceOptions);

const hypothesisBrandingOptions = readProjectProperties(findVal(hypothesisSchema, "branding")!["object"]["properties"]);
writeProjectTable("hypothesis-branding", hypothesisBrandingOptions);

const hypothesisFocusUserOptions = readProjectProperties(findVal(hypothesisSchema, "focus")!["object"]["properties"]["user"]["object"]["properties"]);
writeProjectTable("hypothesis-focus-user", hypothesisFocusUserOptions);

const hypothesisIFrameconfig = readProjectProperties(findVal(hypothesisSchema, "requestConfigFromFrame")!["object"]["properties"]);
writeProjectTable("hypothesis-iframe", hypothesisIFrameconfig);

const listingOptions = readDefinitionsId("website-listing", {
  "feed": "Create an RSS feed for this page using the items in this listing (see [Feed](#feed)). "
});
writeProjectTable("listing", listingOptions);

const feedOptions = readDefinitionsObject("feed");
writeProjectTable("feed", feedOptions);

const aboutOptions = readDefinitionsId("website-about", {
  "links": "Links (as [navigation items](#nav-items)) to display on the about page."
});
writeProjectTable("about", aboutOptions);