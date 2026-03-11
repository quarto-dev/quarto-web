# Sub-plan 11: Manifest JSON Schema

Parent: [00-index.md](00-index.md)

## Problem

Manifest fields (viewport, zoom, trim, cropBottom, maxHeight, clip, cleanup, etc.) are
only documented in prose across CLAUDE.md, SETUP.md, and plan files. No validation
catches typos or invalid values before capture runs. The help script lists commands
but not manifest field reference.

## Goals

- JSON Schema for `manifest.json` — validates entries, documents every field with descriptions
- `help.js` prints field reference from the schema (single source of truth)
- IDE autocompletion when editing manifest.json (via `$schema` reference)
- `capture.js` validates manifest entries on load (fail fast with clear errors)

## Design Decisions

TBD — will fill in when working on this.

## Implementation Plan

TBD.
