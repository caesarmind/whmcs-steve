# i18n Implementation Spec (shared contract for all implementation agents)

You apply the tokenization for ONE batch. Working dir: `C:\Users\iblac\Desktop\Hostnodes Theme`.
This is a DEPLOY-SENSITIVE Smarty theme — a malformed tag blanks the page. Be surgical:
change ONLY the text/token, never the surrounding HTML or Smarty logic.

## Inputs (read first, every time)
1. Your batch audit report `hadrian/docs/i18n-audit/<ID>.md` — per-string mapping table
   (`Line | Type | Current text | Class | Proposed reference | Evidence | Conf`).
2. SOURCE OF TRUTH for custom keys: `hadrian/templates/hadrian/core/lang/english.php` — read
   the group(s) named in your prompt.
3. `hadrian/docs/i18n-audit/_CONSOLIDATION-NOTES.md` — the "Dropped from custom -> real WHMCS
   key" list (use it to switch invented keys to the right real key) and the collisions list.

## Apply each row
- **Class WHMCS**: apply the report's "Proposed reference". Usually = strip the dead `|default`
  so the bare real key remains: `{$LANG.key|default:'X'}` -> `{$LANG.key}`. Sometimes = switch
  an invented key to its real twin (see the "Dropped -> real" list). Policy: **ACCEPT the WHMCS
  wording even if the visible label shifts** (the user approved this).
- **Class CUSTOM**: replace with `{$hadrianLang.<group>.<key>}`. The report proposes a key, but
  consolidation may have RENAMED/merged it — VERIFY the exact key path exists in english.php by
  matching the ENGLISH VALUE, and use that key. If NO matching value exists, do NOT invent —
  leave the source as-is and list it under **MISSING KEYS** in your report-back.
- **Bare hardcoded text** and **attributes** (placeholder/title/aria-label/alt/value): tokenize
  the same way, keeping attribute/markup syntax intact: `aria-label="{$hadrianLang.nav.x}"`.
- **JS strings** inside `<script>`: render the value via Smarty. Three safe patterns:
  - If the file already seeds a JS lang object (e.g. `var _localLang = {...}`), ADD entries to
    it (`'key': '{$hadrianLang.group.key|escape:"javascript"}'`) and reference `_localLang.key`.
  - Else if the JS is NOT inside a `{literal}` block, inline directly:
    `var msg = '{$hadrianLang.group.key|escape:"javascript"}';`
  - If the JS IS inside a `{literal}` block (Smarty won't parse inside it), add a small
    `<script>var _localLang = {...};</script>` seed BEFORE the `{literal}` and reference it
    inside. NEVER put `{$...}` inside a `{literal}` block (it renders literally).
  Never leave a user-facing JS literal hardcoded.
- **Do NOT touch**: dev-only `state-chip` strings or "Variant A-H"/"Variant A-F" labels (they
  render only under `?preview=1`); Smarty logic ({if}/{foreach}/{assign}); class names; ids;
  SVG path data; URLs/hrefs; brand nouns (Hostnodes, WHMCS, cPanel, PayPal...).
- ASCII only in any literal you might add. Preserve exact indentation.

## Bug fixes
Apply any bug noted in your prompt's "Batch notes" (wrong-key renders, `$LANG.billing`/
`$LANG.name` "Array" traps -> keep the English literal hardcoded, missing CSRF `{$token}`).

## Validate (deploy-safety) — REQUIRED before returning
For EACH edited file, confirm these block-tag counts are UNCHANGED vs before your edits
(tokenization must not move them): `{if`/`{/if}`, `{foreach`/`{/foreach}`, `{literal}`/
`{/literal}`, `{*`/`*}`. Verify every `{$...}` you wrote is well-formed (balanced braces, no
stray quote). Use Bash/Grep (e.g. `grep -oF '{if' file | wc -l`).

## Return (concise)
Per-file edit count; WHMCS-strip vs CUSTOM split; **MISSING KEYS** (anything you could not
tokenize); notable wording shifts; js-strings handled; balance result per file. Do NOT run git.
Do NOT edit files outside your list.
