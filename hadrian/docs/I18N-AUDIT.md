# Hadrian theme — i18n audit (Phase A deliverable)

Audit of every **front-side** template in `hadrian` (client area) and `hadrian_cart`
(order form) for hardcoded user-facing English. The admin addon (`hadrian/modules/**`)
is out of scope. **No `.tpl` has been edited yet** — this is the review-before-implement
deliverable.

## What was scanned
- **148 content-bearing templates** (the 88 root `*.tpl` are thin dispatchers and the
  `store-*` marketing stubs were excluded; real content lives in
  `core/pages/<page>/default/default.tpl`, the layouts, partials, and the cart `.tpl`s).
- Cross-referenced against the stock WHMCS themes in-repo to find the genuine `$LANG`
  keys: `standard_cart/standard_cart/*` (identical cart filenames), `nexus/*`, and
  `lagom2.3/{lagom2-theme,orderforms/lagom2}/*`.

## Headline numbers
| | rows | meaning |
|---|---:|---|
| **WHMCS key** | **1,241** | string already maps to a real WHMCS `$_LANG` key — should use `{$LANG.key}` |
| **Custom (Hadrian)** | **655** (→ **627** distinct keys) | no WHMCS key exists — goes in our lang file |
| **js-string** | ~41 (~25 truly custom) | user-facing text built in `<script>` — needs a Smarty→JS lang seed |
| **Total findings** | **1,936** | across the 148 files |

Per-batch totals, the full deduped key list, collisions resolved, and the
"needs server verification" list are in
[_CONSOLIDATION-NOTES.md](i18n-audit/_CONSOLIDATION-NOTES.md). The 17 detailed per-file
reports are in [`hadrian/docs/i18n-audit/`](i18n-audit/) (B01…B14b). The proposed lang
file is [_HADRIAN-LANG-DRAFT.php](i18n-audit/_HADRIAN-LANG-DRAFT.php) (lints clean).

## The dominant pattern: `{$LANG.invented|default:'English'}`
The theme is **not** simply missing translations — it's full of
`{$LANG.someKey|default:'Some English'}` where the key is **invented** (not a real WHMCS
key). On the server these silently fall back to the English literal, so the page *looks*
translated but actually **hides any genuine WHMCS translation** and won't follow a
language switch. The audit splits every one of these into:
1. **Real key, strip the default** — the key IS real (proven in a stock theme): drop the
   `|default` so WHMCS translations apply. (~majority of the 1,241.)
2. **Wrong key, switch it** — an invented key has a real WHMCS twin under a different name
   (e.g. `loginforgotten`→`forgotpw`, the whole billing `invoice*`→`invoices*`/`billing.ledger.*`
   set, `ssl*`→`ssl.*` dotted family). Switch to the real key.
3. **Truly custom** — no WHMCS key fits → our `$hadrianLang` lang file (627 keys).

## Custom keys by group (627)
`cart 127 · support 86 · services 77 · domains 64 · account 64 · billing 63 · auth 36 ·
dashboard 29 · common 24 · ssl 23 · network 15 · nav 4 · footer 1 · devchip 14 (dev-only)`

The custom file will be loaded the same way the existing one already is
([Hooks.php::loadLanguage](../modules/addons/Hadrian/src/Service/Hooks.php)) — it already
reaches both the client area and the cart. The only change is the access namespace:
legacy **`$rslang`** → **`$hadrianLang`** (rebrands away from the RSStudio heritage name;
6 existing refs + the Hooks assignment get renamed).

## Latent bugs found along the way (independent of translation)
1. **Real key piped the *wrong* `|default`** → the page renders an unexpected WHMCS string,
   not the literal the author intended. Confirmed examples: clientregister "New"/"Cancel"
   actually render "Generate new"/"Close"; account-user-permissions "Save permissions"
   renders "Save changes"; sidebar `announcementstitle|default:'Notifications'` renders
   "Announcements"; a KB row keyed `viewcart` would render "View Cart"; viewcart H1
   "Your cart" uses the wrong key.
2. **`$LANG.billing` / `$LANG.name` are arrays on this install** (render literal "Array") —
   several headers must stay hardcoded English, never switch to those keys.
3. **Missing CSRF `{$token}`** on the `masspay` and `invoice-payment` POST forms (stock
   nexus includes it). Out of i18n scope but worth a fix.

## Open decisions (see the questions in chat)
1. **Wording shifts** — switching invented keys to real WHMCS keys changes some visible
   text ("From"→"Pay To", "Active"→"Open", "Incidents & maintenance"→"Network Status"…).
   Accept the WHMCS wording (prefer-real-keys policy), or preserve our bespoke English as
   custom keys where it diverges?
2. **Latent bugs** — fix them as part of this work, or just report?
3. **Server key verification** — a set of keys (core-resolved nav keys, status pills,
   `paymentMethods.*` suffixes) can't be proven from in-repo themes; verify against the
   live server `lang/english.php` before stripping defaults, or proceed best-effort?
4. **Rollout** — Phase B is ~1,900 edits across 148 files. Sequence it in deployable
   chunks (recommend cart first — the main project) with template validation + the
   `check-smarty-balance.mjs` gate before each push, given the cache-poisoning risk.
5. **devchip** (14 variant labels) + ~40 `state-chip` dev strings are `?preview=1`-only —
   recommend dropping/skipping rather than translating.

## Phase B plan (on approval)
1. Promote `_HADRIAN-LANG-DRAFT.php` → `core/lang/english.php` (superset; keep legacy groups).
2. Rename `$rslang` → `$hadrianLang` (Hooks.php + 6 template refs + file header).
3. Add a tiny Smarty→JS lang seed for the ~25 custom js-strings (extend the cart's existing
   `_localLang` pattern to the few pages that lack it).
4. Apply the per-file replacements in deployable chunks, each validated with
   `scripts/check-smarty-balance.mjs` + `check-html-balance.mjs` before commit.
5. Deploy chunk-by-chunk (push to main → Action), verifying live render after each.
