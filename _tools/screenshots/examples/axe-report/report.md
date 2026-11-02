# axe site audit

2 pages · 8/8 cells ok · axe-core 4.10.3 · Quarto 1.11.4 · generated 2026-09-09T18:08:47.930Z

**2 new findings**. A finding on many pages usually repeats from a shared source — fixing it once fixes them all. To accept a finding, see `README.md` in this directory.

## New findings

| id | standard | impact | pages | instances | detail |
|---|---|---|---:|---:|---|
| [`image-alt-4468cc`](#image-alt-4468cc) | WCAG 2.0 A | critical | 1 | 1 | Element does not have an alt attribute |
| [`color-contrast-78b899`](#color-contrast-78b899) | WCAG 2.0 AA | serious | 1 | 1 | #bbbbbb on #ffffff = 1.91 (needs 4.5:1) |

### Occurrences

#### image-alt-4468cc

<details>
<summary>Images must have alternative text (1 instance on 1 page)</summary>

**Standard:** WCAG 2.0 A (1.1.1) · **Impact:** critical · **Signature:** `image-alt :: img`

**Problem:** Element does not have an alt attribute

Reference: <https://dequeuniversity.com/rules/axe/4.10/image-alt?application=axeAPI>

| page | cells (width·mode) | selector | element |
|---|---|---|---|
| index.html | 1440x900·dark, 1440x900·light, 320x568·dark, 320x568·light | `img` | `<img src="map.png" class="img-fluid">` |

</details>

#### color-contrast-78b899

<details>
<summary>Elements must meet minimum color contrast ratio thresholds (1 instance on 1 page)</summary>

**Standard:** WCAG 2.0 AA (1.4.3) · **Impact:** serious · **Signature:** `color-contrast :: #bbbbbb on #ffffff`

**Problem:** #bbbbbb on #ffffff = 1.91 (needs 4.5:1)

Reference: <https://dequeuniversity.com/rules/axe/4.10/color-contrast?application=axeAPI>

| page | cells (width·mode) | selector | element |
|---|---|---|---|
| index.html | 1440x900·light, 320x568·light | `p:nth-child(4) > span` | `<span style="color: #bbb">tide table</span>` |

</details>

---

Full machine-readable results: `findings.json` (schema documented in `README.md` alongside this report).
