# i18n Audit Spec (shared contract for all auditors)

You are auditing WHMCS Smarty `.tpl` templates for the **Hadrian** theme to find every
**hardcoded user-facing English string** and classify how it should be tokenized.
This is an AUDIT ONLY — **do NOT edit any `.tpl` file.** You only WRITE one report file.

## Goal
For each hardcoded string, decide one of:
- **WHMCS** — a native WHMCS `$_LANG` key already covers this string → propose `{$LANG.key}`.
- **CUSTOM** — no WHMCS key fits → propose a new Hadrian key `{$hadrianLang.<group>.<key>}`.
- **SKIP** — not translatable (see SKIP rules).

Policy (decided by the user):
- **Prefer real WHMCS keys.** If our wording is *close* to a WHMCS string, switch to the
  WHMCS key even if wording shifts slightly. Only use CUSTOM when nothing fits.
- **Tokenize everything user-facing**, including attributes: `placeholder`, `title`,
  `aria-label`, `alt`, and button/input `value`.

## What counts as a hardcoded string (TOKENIZE)
- Visible text nodes between tags: `<h1>Manage Service</h1>`, `>Choose plan<`.
- `<option>` labels, `<button>`/`<a>` text, table headers `<th>...</th>`.
- Attributes that render to the user: `placeholder="..."`, `title="..."`,
  `aria-label="..."`, `alt="..."`, `value="..."` on submit/button inputs.
- **JS string literals that build user-facing UI** (alerts, `textContent=`, template
  strings injected into the DOM) inside `<script>` blocks. Mark type `js-string`. Some cart
  files already seed a global JS lang object from Smarty at the top (e.g. `_localLang`) —
  that is the wiring mechanism; just propose the key, don't redesign it. Use `%s` for any
  interpolated value (e.g. `"Save %s%"`).

## CRITICAL: `{$LANG.key|default:'English text'}` IS IN SCOPE (primary target)
This theme is full of `{$LANG.someKey|default:'Some English'}`. A `|default:'literal'` on a
`$LANG` lookup is a red flag: the author wasn't sure the key exists — and many of these keys
are **invented** (not real WHMCS keys). On the server they silently fall back to the English
literal, which *hides* any genuine WHMCS translation. These are a PRIMARY target. For each:
- If evidence shows the key IS real (it appears in a reference theme or our own templates for
  the same string, used WITHOUT a `|default`) → class **WHMCS**, proposed `{$LANG.key}`, note
  "real key — strip default".
- If the key is found ONLY ever with a `|default` (never as a bare real key) → it is
  **invented**; the English literal is our custom copy → class **CUSTOM**, proposed
  `{$hadrianLang.<group>.<key>}` with the literal as the value, note "invented LANG key →
  rebadge". (Prefer reusing the SAME WHMCS key name as the hadrianLang key suffix when it
  reads well, e.g. `cartselectedplan` → `hadrianLang.cart.selectedPlan`.)
Report the `|default` English as the "Current text". Type is usually `text`.

## What to SKIP (do NOT report, unless noted)
- Verified-real WHMCS keys: `{$LANG.key}` with NO `|default:'...'` literal — genuine WHMCS
  strings, already correct. Skip. (But `{$LANG.key|default:'…'}` is IN SCOPE — see above.)
- `{$rslang.*}` (legacy Hadrian custom — already tokenized, NOT hardcoded; will be renamed to
  `$hadrianLang` in Phase B. Just note it exists; don't report as hardcoded.)
- `{$var}` output, `{if}`/`{foreach}`/`{assign}` and other Smarty logic.
- Smarty comments `{* ... *}` and HTML comments `<!-- -->`.
- Markup/code: class names, ids, `data-*` keys, CSS, SVG path data, URLs/hrefs, JS
  identifiers, inline styles.
- Pure numbers, punctuation, symbols, single non-word chars.
- **Brand / proper nouns that must NOT translate**: `Hostnodes`, `WHMCS`, `cPanel`,
  `PayPal`, `Stripe`, registrar/product names, currency codes, email addresses, etc.
  (If a brand word is mixed into a sentence, the *sentence* is still tokenizable — only the
  standalone brand token is skipped.)

## How to find the WHMCS key (evidence required)
You CANNOT see WHMCS's master `lang/english.php` (it lives on the server). So prove a WHMCS
key two ways, in priority order, and **cite file:line**:
1. **Our own already-tokenized usage** — grep `hadrian/templates/hadrian` and `hadrian_cart`
   for the same English text appearing inside `{$LANG.key}`. Most reliable (same install).
2. **Reference themes** — the same UI element/string wrapped in `{$LANG.key}`:
   - Client-area pages: `nexus/<page>.tpl` and `lagom2.3/lagom2-theme/<page>.tpl`
   - Order form (cart): `standard_cart/standard_cart/<file>.tpl` (exact same filenames!) and
     `lagom2.3/orderforms/lagom2/<file>.tpl`
If you find a key, set classification **WHMCS**, confidence high/med, cite the evidence file.
If no key is found, set classification **CUSTOM** and propose a Hadrian key.

## Custom (Hadrian) key naming
- Namespace variable: **`$hadrianLang`** (proposed; do not use `$rslang`).
- Reference form in tpl: `{$hadrianLang.<group>.<key>}`.
- `<group>` = the page-area, one of:
  `common, nav, footer, dashboard, auth, services, domains, billing, support, account,
  ssl, network, cart, errors`.
- `<key>` = short camelCase describing the string, e.g. `choosePlan`, `emptyCartTitle`.
- Reuse one key for the same string repeated across files (note the dedupe).

## Output — write ONE markdown file
Write to the path given in your task prompt (e.g. `hadrian/docs/i18n-audit/B03-cart-configure.md`).
Start with a one-line header `# <batch id> — <area>` then a `## Summary` (counts: total
strings, #WHMCS, #CUSTOM, #SKIP-worth-noting, #js-string) then a table **per file**:

```
### <relative/path/to/file.tpl>
| Line | Type | Current text | Class | Proposed reference | Evidence / Notes | Conf |
|------|------|--------------|-------|--------------------|------------------|------|
| 919 | text | Choose plan | CUSTOM | {$hadrianLang.cart.choosePlan} | no WHMCS key; stepper label | high |
| 42 | placeholder | Search… | WHMCS | {$LANG.search} | nexus/header.tpl:88 uses {$LANG.search} | high |
```

Type ∈ `text | placeholder | title | aria-label | alt | value | option | js-string`.
Class ∈ `WHMCS | CUSTOM`. Keep "Current text" short (trim long sentences to ~80 chars + …).
List rows in file/line order. If a file has NO hardcoded strings, still add its heading with
"_None found._". Be exhaustive — do not sample; read the whole file.

End the report with `## Proposed custom keys` — a deduped list of every `$hadrianLang.*` key
you proposed with its English value, ready to paste into the lang file:
```
hadrianLang.cart.choosePlan = "Choose plan"
```
