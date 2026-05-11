# Page creation & verification checklist

Working reference for converting every WHMCS client-area page from the
`apple-client-area/` mockups into the live theme at `templates/mytheme/`.
Built from the bugs found shipping `clientareahome`, `clientareaproducts`,
`clientareadomains`, `clientareainvoices`, `supporttickets`, `viewinvoice`.

---

## 1. Anatomy of a page

Every page needs exactly these five things on disk:

```
templates/mytheme/
├── <page>.tpl                                  ← top-level dispatcher (1)
├── core/pages/<page>/
│   ├── page.php                                ← page metadata        (2)
│   └── default/
│       ├── default.tpl                         ← the actual markup    (3)
│       └── pageoption.php                      ← variant settings     (4)
└── assets/css/pages/<page>.css                 ← page-specific CSS    (5)
```

Plus optionally:

```
modules/addons/MyTheme/src/Service/Hooks.php    ← localAPI fallback hook (6)
modules/addons/MyTheme/hooks.php                ← register the hook    (7)
```

`<page>` matches WHMCS's `$templatefile` value (e.g. `clientareaproducts`,
`supporttickets`, `viewinvoice`).

---

## 2. What each file must contain

### (1) `templates/mytheme/<page>.tpl` — dispatcher

```smarty
{if isset($myTheme.pages.<page>.fullPath) && $myTheme.pages.<page>.fullPath && file_exists("templates/`$myTheme.pages.<page>.fullPath`")}
    {include file="`$myTheme.pages.<page>.fullPath`"}
{else}
    {include file="`$template`/core/pages/<page>/default/default.tpl"}
{/if}
```

The `isset && truthy && file_exists` triple is **required** — the first two
fail-safe `$myTheme.pages` not being populated; `file_exists` covers a
mis-named variant.

### (2) `core/pages/<page>/page.php` — page metadata

```php
<?php
return [
    'display_name' => 'My Services',
    'group'        => 'Client Area',          // or 'Authentication' / 'Public' / 'Billing' / 'Support'
    'type'         => 'client-portal',        // or 'public'
    'listDisplay'  => true,
    'description'  => 'Logged-in services list — filter by status, manage products.',
];
```

### (3) `core/pages/<page>/default/default.tpl` — markup

Top-of-file structure (the contract every variant tpl must follow):

```smarty
{* Brief description of what this page renders and what vars it expects *}

{* (A) Resolve WHMCS-native vs fallback variable list *}
{if isset($products) && $products|@count > 0}
    {assign var=svcList value=$products}
{elseif isset($mtProducts) && $mtProducts|@count > 0}
    {assign var=svcList value=$mtProducts}
{else}
    {assign var=svcList value=[]}
{/if}
{assign var=count_all value=$svcList|@count}

{* (B) Empty/full flag for body[data-data] *)
{if $count_all > 0}{assign var=dashIsEmpty value='full'}{else}{assign var=dashIsEmpty value='empty'}{/if}

{* (C) Load page-specific CSS *)
<link rel="stylesheet" href="{$WEB_ROOT}/templates/{$template}/assets/css/pages/<page>.css?v={$myTheme.version|default:'1.0'}">

{* (D) Hand layout signals to body so CSS toggles fire *)
<script>
(function () {
    var b = document.body;
    if (!b) return;
    b.setAttribute('data-data',   '{$dashIsEmpty}');
    b.setAttribute('data-subnav', 'on');
})();
</script>

{* (E) Page header *}
<header class="page-header">…</header>

{* (F) Main content — split into when-full / when-empty if both states exist *}
…
```

### (4) `core/pages/<page>/default/pageoption.php` — variant settings

```php
<?php
return [
    'display_name' => 'Default',
    'description'  => 'One-line description of this variant.',
    'preview'      => 'thumb.png',
    'settings'     => [
        'showFilters' => [
            'type' => 'checkbox', 'name' => 'showFilters',
            'label' => 'Show status filters', 'default' => true,
            'tooltip' => 'Renders the left aside with status filters.',
        ],
        // … more variant settings …
    ],
];
```

### (5) `assets/css/pages/<page>.css` — styling

Extract from the matching mockup (`apple-client-area/<page>.html` or
`-v2.html`'s `<style>` block). MUST be `git add`ed — otherwise the deploy
action skips it and the live page renders as unstyled markup (we hit
this with domains/invoices/supporttickets).

### (6) `Hooks.php` — localAPI fallback

Use when WHMCS doesn't propagate its native page variable into the
included tpl scope. Pattern (see existing `clientAreaPageProductsServices`):

```php
private function clientAreaPage<X>(array $vars, Template $template): array
{
    $clientId = (int)($_SESSION['uid'] ?? 0);
    if ($clientId === 0) return [];
    return ['mt<X>' => $this->fetchAll<X>($clientId)];
}

private function fetchAll<X>(int $clientId): array
{
    try {
        $response = localAPI('Get<Whatever>', ['clientid' => $clientId, …]);
        if (($response['result'] ?? '') !== 'success') return [];
        $out = [];
        foreach (($response['<key>'] ?? []) as $row) {
            $out[] = [/* shape it to match the legacy tpl key expectations */];
        }
        return $out;
    } catch (\Throwable) {
        return [];
    }
}
```

Always **strip HTML** from WHMCS-returned status fields (`<span
class="textred">Unpaid</span>` is a real shape):

```php
$status = strip_tags((string)($row['status'] ?? 'Unknown'));
```

### (7) `hooks.php` — register the hook

```php
add_hook('ClientAreaPage<X>', 1, function ($vars) {
    return HookService::instance()->dispatch('ClientAreaPage<X>', $vars);
});
```

---

## 3. Smarty syntax rules (WHMCS-compatible)

| Do | Don't |
|---|---|
| `{assign var=foo value='bar'}` | `{$foo = 'bar'}` (inline assignment, can silently fail on WHMCS Smarty) |
| `$list\|@count` | `$list\|count` for Collection objects |
| `{if isset($x) && $x\|@count > 0}` | `{if $x}` (errors when $x is undefined) |
| `$myTheme.layouts['main-menu']` | `$myTheme.layouts.main-menu` (hyphen parsed as subtraction) |
| Strip-tags before using a value as a CSS class | Pipe a value through `\|lower\|escape` straight into an HTML attribute when WHMCS may wrap it in `<span>` |
| Wrap nested `$myTheme.x.y` access in `isset()` chain | Rely on `\|default:''` to catch failures — it doesn't fire if the chain blows up first |

---

## 4. WHMCS variable cheatsheet

| Page | WHMCS-native | Fallback ($mt*) | Hook needed |
|---|---|---|---|
| `clientareahome` | `$panels` (homepage menu items) + `$clientsstats` | `$dashboard.activeServices`, `$dashboard.openTickets`, `$dashboard.recentInvoices` | `ClientAreaPageHome` ✅ |
| `clientareaproducts` | `$products` (often missing in our scope) | `$mtProducts` | `ClientAreaPageProductsServices` ✅ |
| `clientareadomains` | `$domains` | `$mtDomains` | `ClientAreaPageDomains` ✅ |
| `clientareainvoices` | `$invoices` | `$mtInvoices` | `ClientAreaPageInvoices` ✅ |
| `viewinvoice` | `$invoicedata`, `$clientsdetails`, `$lineitems`, `$transactions` | — | none yet |
| `supporttickets` | `$tickets` | `$mtTickets` | `ClientAreaPageSupportTickets` ✅ |
| `viewticket` | `$replies`, `$ticket`, `$attachments` | — | — |
| `clientareadetails` | `$clientsdetails`, `$countries`, `$states`, `$languages` | — | — |
| `login` | `$incorrect`, `$rememberMe`, `$logout`, `$ssoProviders` | — | — |

Universal globals always available:
- `$WEB_ROOT`, `$template`, `$companyname`, `$loggedin`
- `$LANG.*` (translated strings)
- `$clientsstats.{productsnumactive, numactivedomains, numunpaidinvoices, numactivetickets, unpaidinvoicesamount, numexpiringdomains, numoverdueinvoices}`
- `$pagetitle`, `$templatefile`
- `$activeLocale.languageCode`, `$language`
- `$myTheme.{version, manifest, layouts, pages, styles}` (populated by `Hooks::clientAreaPage`)

---

## 5. Preview-chip option compatibility

The state-chip (top-floating panel from `partials/state-chip.tpl`) drives
these body data-attrs. Every page must respond to all of them via CSS in
its page-specific stylesheet or via `apple-layout.css`:

| Chip control | Body/html attr | CSS rule must do… |
|---|---|---|
| **Auth: Logged in / out** | `body[data-auth="in\|out"]` | toggle `.only-in` / `.only-out` blocks |
| **Layout: Top / Side / Rail** | `body[data-layout="top\|side\|rail"]` | show only matching `.only-top` / `.only-side` / `.only-rail` chrome |
| **Data: Full / Empty** | `body[data-data="full\|empty"]` | toggle `.when-full` / `.when-empty` |
| **Align: Center / Content / Left** | `body[data-align="center\|content\|left"]` | shift `.content-area` horizontally |
| **Sub-nav: Show / Hide** | `body[data-subnav="on\|off"]` | collapse the right-aside `<aside>` |
| **Sub-nav side: L / R / Outside-L / Outside** | `body[data-subnav-side="…"]` | flip grid column or float into gutter |
| **Services: Inside / Outside** | `body[data-svc-layout="inside\|outside"]` | strip card header onto the page bg |
| **Tiles: A / B / C / D / E / F** | `body[data-tiles="…"]` | show only the matching `[data-variant]` block |
| **Palette: Blue / Emerald / Violet / Rose / Amber / Slate** | `html[data-palette="…"]` | swap accent colour CSS vars |

**Test routine for a new page:**
1. Open `?layout=top&data=empty&palette=violet` → should render top-nav with the violet accent and empty-state markup
2. Click each chip on the live preview → page should re-render the right state without a reload (apple-layout.js handles it)

---

## 6. CSS conventions

Every page CSS must:

1. Live at `assets/css/pages/<page>.css` and be **tracked in git**
2. Define unique class prefixes per page so styles don't collide:
   - Dashboard: `.dash-*`
   - Services: `.svc-*`
   - Domains: `.dom-*`
   - Invoices: `.inv-*`
   - Tickets: `.tk-*`
3. Honor the universal toggles via `body[data-data]`, `body[data-svc-layout]`, etc. — don't comment them out as "Smarty handles it"
4. Use design tokens from `apple-theme.css` (`--color-surface`, `--color-accent`, `--radius-lg`, `--transition-fast`, etc.) — not raw hex values
5. **NEVER include `body { display: block; }`** — that's mockup leftover. The real theme's `apple-theme.css` sets `body { display: flex; min-height: 100vh; }` to hold sidebar + main-wrap as flex children; overriding it to `block` collapses the entire layout (especially visible when switching to **top nav** because the sticky `.homepage-nav` needs the flex chain intact)
6. **Scope `body[data-subnav-side="outside"]` / `[outside-left"]` content-area transforms to non-top layouts** — they shift the content column horizontally to make room for a floated sub-nav, but in top layout there's no sidebar to offset against, so the shift pushes content off-center. Required pattern:
   ```css
   body[data-subnav-side="outside"]:not([data-layout="top"]):not([data-align="left"]):not([data-align="content"]) .ph-main-wrap .content-area { transform: translateX(-132px); }
   ```

## 6b. Layout-switching verification — the THREE layouts must all work

For every page, **test all three values of `body[data-layout]`**:

| URL | Expected |
|---|---|
| `?layout=side` (default) | Fixed 260px sidebar visible on left, content shifted right with `margin-left: 260px` |
| `?layout=top` | `.homepage-nav` sticky at top, sidebar + rail hidden, content full-width centered |
| `?layout=rail` | 80px icon rail visible on left, content shifted right with `margin-left: 80px` |

When you switch via the preview chip OR via URL param:

- [ ] Sidebar (only-side), rail (only-rail), topnav (only-top), inner-topbar (only-inner) all toggle to the correct visibility
- [ ] `.ph-main-wrap` margin-left adapts (260px / 80px / 0)
- [ ] `.content-area` doesn't shift via `translateX` unless `data-subnav-side="outside"` is set AND we're not in top layout
- [ ] Page-specific layout (`.dash-split`, `.svc-split`, `.inv-split`, `.tk-split`, `.dom-split`) keeps its grid columns intact in all three layouts
- [ ] Sticky elements (`.homepage-nav`, `.ph-side-topbar`) stay at the top without overlapping content
- [ ] Page-specific CSS doesn't set `body { display: block }` (would break flex container)

## 6c. Align + sub-nav-side toggles must be no-ops in top layout

The `Align: center/content/left` chip option and `Sub-nav side: outside/outside-L` options were designed to position content **relative to a sidebar**. In top-nav layout there is no sidebar — those toggles have nothing to anchor against, and any effect they have on content positioning is a bug.

**All CSS rules that read `data-align` or `data-subnav-side` must include `:not([data-layout="top"])` in their selector.**

Verification — switch to top layout, then click every Align and Sub-nav-side button. Content position should never change. Quick programmatic test:

```javascript
['center','content','left'].forEach(a => {
  document.body.dataset.layout = 'top';
  a==='center' ? document.body.removeAttribute('data-align') : document.body.setAttribute('data-align', a);
  console.log(a, document.querySelector('.content-area').getBoundingClientRect().left);
});
// All three numbers must be identical
```

Required scoping patterns:

```css
/* core in apple-layout.css */
body[data-align="left"]:not([data-layout="top"]) .ph-main-wrap .content-area { margin-left: 0; margin-right: auto; }

/* in every page CSS that uses subnav-side */
body[data-subnav-side="outside"]:not([data-layout="top"]):not([data-align="left"]):not([data-align="content"]) .ph-main-wrap .content-area { transform: translateX(-132px); }
body[data-subnav-side="outside-left"]:not([data-layout="top"]):not([data-align="left"]):not([data-align="content"]) .ph-main-wrap .content-area { transform: translateX(132px); }
body[data-subnav-side="outside-left"][data-align="left"]:not([data-layout="top"]) .ph-main-wrap .content-area { margin-left: 240px; }
```

The same scoping must be applied to **mockup HTML inline `<style>` blocks** in `apple-client-area/<page>.html` (they have their own copies of these rules — that's why the localhost preview can break differently from the live theme).

## 6d. `.ph-main-wrap` must fill body width — content-area centering depends on it

**Symptom of the bug:** in top-nav layout, content gets pinned to the left edge of the viewport instead of being centered. Reported as "alignment doesn't work" or "content not on full length."

**Root cause:** when sidebar / rail are `position: fixed`, they're removed from `body`'s flex flow. `.ph-main-wrap` becomes `body`'s only flex child. Without `flex: 1`, it shrinks to its content's natural width — which is `.content-area`'s `max-width: 1120px`. With `.ph-main-wrap` only 1120px wide, `.content-area`'s `margin: auto` has no remaining space to absorb, so margins collapse to 0 and content sticks to column 0.

**Required rule** in `apple-layout.css` and the mockup `apple-client-area/css/apple-layout.css`:

```css
.ph-main-wrap {
    display: flex;
    flex-direction: column;
    min-height: 100vh;
    flex: 1;        /* fill body's flex row remaining space */
    min-width: 0;   /* allow shrinking past content if needed */
}
```

**Verification** — paste into DevTools console on any page in top-nav layout. All three should hold:

```javascript
(() => {
  const w = document.querySelector('.ph-main-wrap').getBoundingClientRect();
  const c = document.querySelector('.content-area').getBoundingClientRect();
  const bw = document.body.clientWidth;
  return {
    wrap_fills_body:     Math.abs(w.width - bw) < 20,   // ≈ true
    content_inside_wrap: c.left >= w.left && c.right <= w.right,
    content_centered:    Math.abs(c.left - (bw - c.right)) < 5  // auto-margin centers
  };
})()
// All three must be true. If `wrap_fills_body: false` → .ph-main-wrap shrunk to content.
//                          If `content_centered: false` → margin auto isn't centering.
```

**Curl-based remote check** (no browser needed):

```bash
curl -s https://bill.hostnodes.com/templates/mytheme/assets/css/apple-layout.css \
  | grep -A 8 '^\.ph-main-wrap {' \
  | grep -E 'flex: 1|min-width: 0'
# Both lines must appear. If either is missing, the bug is back.
```

When adding a new page CSS file, **never** override `body { display: flex }` or `.ph-main-wrap`'s flex sizing. Refer to PAGE-CHECKLIST §6 rule 5 (no `body { display: block }`) for the related trap.

---

## 7. Pre-deploy verification (local)

Before pushing, run through:

- [ ] All five files exist on disk (dispatcher, page.php, default.tpl, pageoption.php, page CSS)
- [ ] `git status` shows all five files staged or already tracked (gitignore traps caught domains/invoices CSS — verify with `git ls-files | grep <page>`)
- [ ] Smarty assignments use `{assign}`, not `{$x = y}`
- [ ] No bare `$myTheme.layouts['…']` chain — always `isset()`-guarded
- [ ] No `$x|lower|escape` straight into a class attr when `$x` may contain HTML (e.g. WHMCS invoice statuses)
- [ ] If both `when-empty` and `when-full` markup coexist, the universal CSS toggle in `apple-layout.css` is **uncommented**
- [ ] `data-data` set by the inline `<script>` in the page tpl

---

## 8. Post-deploy verification (live)

After GitHub Action finishes (~60s) + manual `templates_c/` wipe + browser hard-refresh:

```bash
# Asset reachability — every CSS file must return 200, not 404
curl -sI "https://bill.hostnodes.com/templates/mytheme/assets/css/pages/<page>.css" -w "%{http_code}\n" -o /dev/null

# Page renders with the right structural hooks (login + check class hits)
curl -s -b cookies.txt "https://bill.hostnodes.com/<page-url>" \
  | grep -cE 'class="<prefix>-stack\|class="<prefix>-table\|class="<prefix>-empty'

# state-chip is on every page
curl -s -b cookies.txt "https://bill.hostnodes.com/<page-url>" | grep -c 'class="state-chip"'
```

Visual checks (real browser):

- [ ] Page renders (not blank, not 404)
- [ ] Header + sidebar/rail/topnav matches the chosen layout
- [ ] Preview chip top-right with all chip-groups visible
- [ ] Page content matches the corresponding mockup at `http://localhost:3002/<page>.html`
- [ ] Only ONE of `when-empty` or `when-full` is visible (DevTools → Elements → check `display: none` on the other)
- [ ] Status pills have correct background colour (not raw HTML in the class attr)
- [ ] Chip toggles flip layouts/palette/sub-nav without a reload
- [ ] `?layout=top` / `?layout=rail` URL params work (set the body attr on load)

---

## 9. Pages status (live as of `231ba2f`)

| Page | Dispatcher | page.php | default.tpl | pageoption | CSS | Hook | Status |
|---|---|---|---|---|---|---|---|
| `clientareahome` | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | **Live** |
| `clientareaproducts` | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | **Live** |
| `clientareadomains` | ✅ | ? | ✅ | ? | ✅ (just added) | ✅ | **Live** |
| `clientareainvoices` | ✅ | ? | ✅ | ? | ✅ (just added) | ✅ | **Live** |
| `supporttickets` | ✅ | ? | ✅ | ? | ✅ (just added) | ✅ | Awaiting `templates_c/` clear |
| `supportticketslist` | ✅ | ? | ✅ (forwarder) | ? | uses supporttickets | — | Same as above |
| `viewinvoice` | ✅ | ? | ✅ | ? | ❌ **missing** | ❌ | Renders without per-page CSS |
| `viewticket` | ✅ | ? | ✅ | ? | ❌ missing | ❌ | Not yet checked |
| `clientareadetails` | ✅ | ? | ✅ | ? | ❌ missing | ❌ | Not yet checked |
| `login` | ✅ | ✅ | ✅ | ✅ | ✅ | — | **Live** |
| `homepage` | ✅ | ✅ | ✅ | ✅ | ✅ | — | **Live** |
| `announcements` | ✅ | ? | ✅ | ? | ❌ missing | — | Not yet checked |
| `clientareaproductdetails` | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | TODO |
| `clientareadomaindetails` | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | TODO |
| `clientareaquotes` | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | TODO |
| `clientareasecurity` | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | TODO |
| `clientareacancelrequest` | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | TODO |
| `submitticket` | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | TODO |
| `register` (clientregister) | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | TODO |
| `pwreset` (password-reset) | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | TODO |
| `cart.php` (order form) | — | — | — | — | — | — | Out of scope (different system) |

---

## 10. Common gotchas that have bitten us

- **CSS file untracked in git** → 404 on server → unstyled markup. Solution: `git ls-files` to verify, always.
- **WHMCS Smarty doesn't propagate `$products`/`$tickets`/etc. into our included tpl scope** → use the localAPI fallback hook.
- **WHMCS sends invoice (and sometimes product) status as `<span class="textred">Unpaid</span>`** → always `strip_tags()` (PHP-side) or `|strip_tags` (Smarty-side) before piping into a class. Same trap appeared on `clientareaproducts/default/default.tpl` line 150 — fixed by assigning a stripped value first.
- **`{$var = value}` inline assignment fails silently in WHMCS Smarty 4** → use `{assign var=var value=value}`.
- **Chained property access on potentially-missing `$myTheme.x.y.z`** → wrap in `isset()` chain before access, or short-circuit assigns won't fire.
- **Both `when-empty` and `when-full` markup coexisting** → relies on `apple-layout.css` toggle rules; keep them active, never comment out.
- **`body { display: block; }` leak in page CSS** → kills the body's `display: flex` chain that holds sidebar + main-wrap, most visibly breaking **top-nav layout** since the sticky `.homepage-nav` needs intact flex. Strip this from every page CSS (was in 5 files: clientareahome, clientareaproducts, clientareadomains, clientareainvoices, supporttickets).
- **`[data-subnav-side="outside"]` content-area transforms unscoped** → in top layout there's no sidebar to offset against, so `translateX(-132px)` shoves content off-center. Always include `:not([data-layout="top"])` in the selector.
- **`.ph-main-wrap` missing `flex: 1`** → in top layout (sidebar/rail are fixed-positioned, removed from flex flow) the wrap shrinks to its content's max-width (1120px), leaving `.content-area`'s `margin: auto` no space to absorb, so content sticks to column 0 of the viewport. Required rules: `flex: 1; min-width: 0;` on `.ph-main-wrap`. See §6d.
- **GitHub Action deploys files but doesn't clear `templates_c/`** → manual cPanel wipe needed after every push that changes `.tpl` files.
- **Browser caches CSS aggressively** → bump the `?v=` query string in page tpls when changing CSS, or hard-refresh / use incognito to verify.
- **Top-level dispatcher checks `file_exists` against `"templates/$path"`** → that path is **relative to WHMCS root**, not the tpl's location. Don't refactor it to absolute.

---

## 11. Comparison against localhost demos

Each live page must match its localhost counterpart at `http://localhost:3002/<page>.html`. The localhost demos are the **design source of truth** — when a live page renders differently, the live page is wrong, not the demo.

To compare:

1. Open both side-by-side in two browser windows
2. Sync the preview chip state on both (same layout/data/palette settings)
3. Spot-check:
   - Heading typography
   - Card border radius (should match — both use `var(--radius-lg)`)
   - Status pill background colour for each status
   - Sidebar item alignment + hover state
   - Empty-state icon size + spacing

If a live page diverges, it's almost always because:
- A CSS file is missing → check 404s
- An inline `body { display: block; }` from the mockup leaked into a `<style>` block in the live tpl
- A class hook is named differently between mockup and live tpl
- Smarty's HTML escape is changing a value somewhere subtle
