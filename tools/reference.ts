
import { join } from "https://deno.land/std/path/mod.ts";
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
  }
  description: string | { short: string, long?: string };
  hidden?: boolean;
}
const formatsFromOptionSchema = (option: OptionSchema) => {
  if (option.disabled) {
    const disabledFormats = resolveFormats(option.disabled);
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
}
interface OptionGroup {
  name: string;
  title: string;
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
    }))
    .filter(group => group.name !== "hidden");
};


// read baseline config
const groups = readSchema("new/groups.yml") as Array< { [key: string]: Array<Record<string, { title: string, description?: string }>>}>;

// cell options
const cellGroups = groups[0]["cell"];
const cellOptions = cellGroups.map(group => {
  const name = Object.keys(group)[0];
  const title = Object.values(group)[0]["title"];
  const options = readGroupOptions("cell", name);
  return {
    name,
    title,
    options
  }
})

// document options
const documentGroups = groups[1]["document"];
const documentOptions = documentGroups.map(group => {
  const name = Object.keys(group)[0];
  const title = Object.values(group)[0]["title"];

  // options are a combination of document group options and cell
  // options that are also available at the document level
  const options = readGroupOptions("document", name);

  const docCellOptions = cellOptions.flatMap(
    group => group.options.filter(option => option.contexts?.includes("document-" + name))
  );
  options.push(...docCellOptions);

  return {
    name, 
    title,
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
          .map(option => ( { name: option.name, desciption: option.description }))
      }
    })
    .filter(group => group.options.length > 0)
}

const writeOptions = (format: string, path: string) => {
  const options = JSON.stringify(optionsForFormat(format), undefined, 2);
  Deno.writeTextFileSync(join("docs", "reference", "formats", path), options);
}

writeOptions("html", "html.json");
writeOptions("pdf", "pdf.json");
writeOptions("docx", "docx.json");