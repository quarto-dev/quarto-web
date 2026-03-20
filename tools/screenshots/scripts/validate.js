#!/usr/bin/env node
// Validate manifest.json against manifest-schema.json using AJV.
// Can be used as a module (import { validateManifest }) or CLI (npm run validate).

import { readFileSync } from 'node:fs';
import { join, dirname, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';
import Ajv from 'ajv/dist/2019.js';

const __dirname = dirname(fileURLToPath(import.meta.url));
const TOOLS_DIR = resolve(__dirname, '..');

const schema = JSON.parse(readFileSync(join(TOOLS_DIR, 'manifest-schema.json'), 'utf8'));
const ajv = new Ajv({ allErrors: true, strict: false });
const validate = ajv.compile(schema);

function formatErrors(errors) {
  return errors.map(err => {
    // Source type discrimination: make "missing required property" errors readable
    if (err.keyword === 'required' && err.instancePath.match(/\/screenshots\/\d+\/source$/)) {
      const missingProp = err.params.missingProperty;
      return `${err.instancePath}: source requires "${missingProp}" field`;
    }
    // if/then failures on source type — suppress the generic message, the required error above covers it
    if (err.keyword === 'if' && err.instancePath.match(/\/screenshots\/\d+\/source$/)) {
      return null;
    }
    return `${err.instancePath || '/'}: ${err.message}`;
  }).filter(Boolean);
}

export function validateManifest(manifest) {
  const valid = validate(manifest);
  if (valid) return { valid: true, errors: [] };
  return { valid: false, errors: formatErrors(validate.errors) };
}

// CLI mode
const scriptPath = fileURLToPath(import.meta.url).toLowerCase();
const cliPath = process.argv[1] ? resolve(process.argv[1]).toLowerCase() : '';
if (scriptPath === cliPath) {
  const manifest = JSON.parse(readFileSync(join(TOOLS_DIR, 'manifest.json'), 'utf8'));
  const result = validateManifest(manifest);
  if (result.valid) {
    console.log('manifest.json is valid');
    process.exit(0);
  } else {
    console.error('manifest.json validation failed:');
    result.errors.forEach(e => console.error(`  ${e}`));
    process.exit(1);
  }
}
