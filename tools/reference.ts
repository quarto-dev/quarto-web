
import { basename, dirname, join, relative } from "https://deno.land/std/path/mod.ts";
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

// helper to read a group schema
const readGroupOptions = (context: string, name: string) : Array<Option> => {
  const groupOptions = readSchema(`new/${context}-${name}.yml`) as Array<OptionSchema>;
  return  groupOptions
    .filter(optionsSchema => !optionsSchema.hidden)
    .map(optionSchema => ({
      name: optionSchema.name,
      description: typeof(optionSchema.description) === "string" 
        ? optionSchema.description 
        : optionSchema.description?.long || optionSchema.description?.short || "",
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
    options: options.filter(option => option.engine !== "knitr")
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
  cells: ["attributes", "codeoutput", "textoutput", "figure", "table","layout", "pagelayout"],
} as Record<string,string[]>;

for (const page of Object.keys(cellPages)) {
  const groups = cellPages[page];
  writeCellGroups(groups, `docs/reference/${page}.json`);
}

function writeCellGroups(groups: string[], path: string) {
  const writeGroups = cellOptions.filter(group => groups.includes(group.name));
  Deno.writeTextFileSync(path, JSON.stringify(writeGroups, undefined, 2));
}
