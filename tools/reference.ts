
import { basename, dirname, join } from "https://deno.land/std/path/mod.ts";
import { expandGlobSync } from "https://deno.land/std/fs/expand_glob.ts";
import { parse } from "https://deno.land/std/encoding/yaml.ts";
import { distinct } from "https://deno.land/std/collections/distinct.ts"


// location of schema yaml and function to read from it
const schemasDir = Deno.realPathSync(Deno.args[0] || "../quarto-cli/src/resources/schema");
const readSchema = (file: string) => {
  const schema = parse(Deno.readTextFileSync(join(schemasDir, file)));
  return schema;
}

// format aliases and function to resolve a format list
// deno-lint-ignore no-explicit-any
const formatAliases = (readSchema("format-aliases.yml") as any)["aliases"] as Record<string,string[]>;
const allFormats = formatAliases["pandoc-all"];
const resolveFormats = (formats: string[]) : string[] => {
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
  engine?: string;
}
interface OptionGroup {
  name: string;
  title: string;
  description?: string;
  options: Option[];
}

function asDescriptionString(description?: string | { short: string, long?: string }) {
  return typeof(description) === "string" 
  ? description 
  : description?.long || description?.short || "";
}

// helper to read a group schema
const readGroupOptions = (context: string, name: string) : Array<Option> => {
  const groupOptions = readSchema(`new/${context}-${name}.yml`) as Array<OptionSchema>;
  return  groupOptions
    .filter(optionsSchema => !optionsSchema.hidden)
    .map(optionSchema => ({
      name: optionSchema.name,
      description: asDescriptionString(optionSchema.description),
      formats: formatsFromOptionSchema(optionSchema),
      contexts: optionSchema.tags?.contexts,
      engine: optionSchema.tags?.engine,
    }))
    .filter(group =>  group.name !== "hidden");
};


// read baseline config
const groups = readSchema("new/groups.yml") as { [key: string]: { [key: string] : { title: string, description?: string }} };

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
  .filter(group => !["comments", "crossref"].includes(group))
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
          .map(option => ( { name: option.name, description: option.description }))
      }
    })
    .filter(group => group.name !== "hidden" && group.options.length > 0)
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
  cells: ["attributes", "codeoutput", "textoutput", "figure", "table","layout", "pagelayout", "cache", "include"],
} as Record<string,string[]>;

function writeCellGroups(engine: string, groups: string[], path: string) {

  let writeGroups = (structuredClone(cellOptions) as Array<OptionGroup>).filter(group => groups.includes(group.name));

  // filter options on engine

  writeGroups.forEach(writeGroup => {
    writeGroup.options = writeGroup.options.filter(option => !option.engine || option.engine === engine);
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
const definitions = readSchema("new/definitions.yml") as Array<{ object?: { id: string, properties: Record<string,unknown> } }>;
const project = readSchema("new/project.yml") as Array<{ name: string}>;

// read a project object
function readProjectProperties(props: { [name: string]: Record<string,unknown> }, descriptions?: Record<string, string>) {
  return Object.keys(props).map(key => ({
    name: key,
    description: descriptions?.[key] ||  asDescriptionString(findVal(props[key], "description"))
  })) 
}

function readProjectObject(name: string) {
  // deno-lint-ignore no-explicit-any
  const obj = project.find(value => value.name == name) as any;
  const props = obj["schema"]["object"]["properties"];
  return readProjectProperties(props); 
}

function readDefinitionsObject(id: string, descriptions?: Record<string, string>) {
  const obj = definitions.find(value => value.object?.id === id) as any;
  const props = obj["object"]["properties"];
  return readProjectProperties(props, descriptions);

}

// deno-lint-ignore no-explicit-any
function findVal(object: any, key: string) {
  let value;
  Object.keys(object).some(function(k) {
      if (k === key) {
          value = object[k];
          return true;
      }
      if (object[k] && typeof object[k] === 'object') {
          value = findVal(object[k], key);
          return value !== undefined;
      }
  });
  return value;
}


function writeProjectTable(name: string, options: Array<Option>) {
  const path = `docs/reference/projects/${name}.json`;
  Deno.writeTextFileSync(path, JSON.stringify(options, undefined, 2));
}

const projectOptions = readProjectObject("project");
writeProjectTable("project", projectOptions);

const websiteOptions = readDefinitionsObject("base-website", {
  "navbar": "Navbar options (see [Navbar](#navbar))",
  "sidebar": "Sidebar options (see [Sidebar](#sidebar))"
})
writeProjectTable("website", websiteOptions);

const bookOptions = readProjectObject("book").concat(
  websiteOptions.filter(option => option.name !== "title"));
writeProjectTable("book", bookOptions);



const navbarOptions = readProjectProperties(findVal(definitions, "navbar")?.["oneOf"][1]["object"]["properties"]!, {
  "left": "List of items for the left side of the navbar (see [Navbar Items])",
  "right": "List of items for the left side of the navbar (see [Navbar Items])"
});
writeProjectTable("navbar", navbarOptions);

const sidebarOptions = readProjectProperties(findVal(definitions, "sidebar")?.["oneOf"][1]["object"]["properties"]!, {
  "tools": "List of sidebar tools (see [Sidebar Tools])"
});
writeProjectTable("sidebar", sidebarOptions);

