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
| `{foreach $list as $row}{if $row@iteration <= 5}` | `{foreach $list as $row@idx}{if $idx < 5}` — Smarty doesn't accept custom iterator names; this is a silent compile failure that empties the content-area. Use `@iteration` (1-based) or `@index` (0-based) on the loop var itself |
| Wrap inline `<script>` and `<style>` bodies in `{literal}…{/literal}` | Leave `{` from JS object literals or CSS selectors exposed — Smarty parses them as directives and bails mid-template |

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

## 6e. Page CSS must implement the "Controls inside / outside" chip toggle

The preview chip's `Services: Controls inside | Controls outside` option sets `body[data-svc-layout="inside|outside"]`. Every list page (invoices, services, domains, tickets, dashboard) must define a CSS rule set for `body[data-svc-layout="outside"]` so the chip toggle visibly does something:

- **Default ("inside")**: the `.<prefix>-stack` is a single white card — column titles, table/rows, and pager all share the same surface.
- **Outside**: `.<prefix>-stack` becomes transparent (no border, no background, no shadow). Only the inner `.<prefix>-table-card` keeps its surface; the head row + footer float on the page background above/below it.

Required selectors per page CSS (substitute `inv` for invoices, `svc` for services, `dom` for domains, `tk` for tickets):

```css
/* Default — stack is one unified card */
.inv-stack {
    background: var(--color-surface);
    border: 0.5px solid var(--color-border);
    border-radius: var(--radius-md);
    overflow: visible;
}
.inv-stack > .inv-table-card { background: transparent; border: 0; border-radius: 0; box-shadow: none; margin: 0; }

/* Outside — stack strips down, only the rows card keeps the surface */
body[data-svc-layout="outside"] .inv-stack {
    background: transparent; border: 0; border-radius: 0;
    display: flex; flex-direction: column; gap: 8px;
}
body[data-svc-layout="outside"] .inv-stack > .inv-table-card {
    background: var(--color-surface);
    border: 0.5px solid var(--color-border);
    border-radius: var(--radius-md);
}
```

**Verification — paste in DevTools console:**

```javascript
(() => {
  document.body.setAttribute('data-svc-layout', 'inside');
  const insideCard = getComputedStyle(document.querySelector('.inv-stack')).background;
  document.body.setAttribute('data-svc-layout', 'outside');
  const outsideCard = getComputedStyle(document.querySelector('.inv-stack')).background;
  return { inside: insideCard, outside: outsideCard, changed: insideCard !== outsideCard };
})()
// changed must be true. If it returns false, the page CSS doesn't honor data-svc-layout.
```

**Pages that already have it**: clientareahome, clientareaproducts, clientareadomains, clientareainvoices, supporttickets. Any new list page must include the same rules.

## 6f. Sortable column headers — Lagom-style DataTables.js instant sort

Matches the Lagom theme exactly: jQuery + DataTables 1.x for instant client-side reorder on header click (no page reload). Server-side sort in `Hooks.php` honors the same `?orderby=…&sort=…` URL params so first render + no-JS fallback work, and DataTables's initial `order()` call mirrors the URL state so the active-column arrow points the right way on load.

**Four required pieces:**

### 1. Load jQuery + DataTables on the page

Near the top of the page tpl (after the page-specific CSS link):

```smarty
<script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
<script src="https://cdn.datatables.net/1.13.11/js/jquery.dataTables.min.js"></script>
```

CDN is fine for now; switch to local copies in `assets/js/vendor/` for a fully self-hosted build. Skip the DataTables CSS bundle — our own page CSS supplies the sort indicators (see piece 4).

### 2. Table structure: `<thead>` inside `<table>`, `data-order` on each `<td>`

DataTables requires a real `<thead>`. The previous external `<div class="inv-table-head-row">` is gone — `<th>` cells live in the table now. Each sortable `<td>` carries `data-order` with the raw sort value (DataTables uses this instead of the formatted display string).

```smarty
<table class="inv-table when-full" id="invTable">
    <colgroup>
        <col class="inv-col-invoice">
        <col class="inv-col-date">
        ...
    </colgroup>
    <thead>
        <tr>
            <th class="hl-invoice">{$LANG.invoicenum|default:'Invoice'} <span class="inv-sort-ico"></span></th>
            <th class="hl-date">{$LANG.invoicedatecreated|default:'Date'} <span class="inv-sort-ico"></span></th>
            <th class="hl-due">{$LANG.invoicedatedue|default:'Due date'} <span class="inv-sort-ico"></span></th>
            <th class="hl-amount">{$LANG.amount|default:'Amount'} <span class="inv-sort-ico"></span></th>
            <th class="hl-status">{$LANG.invoicesstatus|default:'Status'} <span class="inv-sort-ico"></span></th>
            <th class="hl-actions" data-orderable="false" aria-hidden="true"></th>
        </tr>
    </thead>
    <tbody>
        {foreach $invList as $inv}
        {assign var=sortDateRaw value=$inv._sort_date_raw|default:$inv.datecreated|default:''}
        {assign var=sortDueRaw  value=$inv._sort_due_raw|default:$inv.duedate|default:''}
        {assign var=sortAmount  value=$inv._sort_amount|default:0}
        <tr data-href="{$WEB_ROOT}/viewinvoice.php?id={$inv.id}">
            <td data-order="{$inv.id}">...invoice number display...</td>
            <td class="date" data-order="{$sortDateRaw|escape:'html'}">{$inv.datecreated|escape}</td>
            <td class="date" data-order="{$sortDueRaw|escape:'html'}">{$inv.duedate|escape}</td>
            <td class="amount" data-order="{$sortAmount}">{$inv.total|escape}</td>
            <td data-order="{$invStatusLower|escape:'html'}"><span class="status-pill {$invStatusLower}">{$invStatus|escape}</span></td>
            <td class="actions">...kebab menu...</td>
        </tr>
        {/foreach}
    </tbody>
</table>
```

`data-orderable="false"` on the actions `<th>` tells DataTables not to attach a sort handler there.

### 3. DataTables init — map URL → column index for initial order, sync URL on every reorder

The script block sits at the bottom of the tpl. Smarty must interpolate the column index + direction OUTSIDE `{literal}` blocks; everything else (object literals, function bodies) lives INSIDE `{literal}` so curly braces don't fight Smarty:

```smarty
{assign var=sortKey value=$smarty.get.orderby|default:'id'}
{assign var=sortDir value=$smarty.get.sort|default:'DESC'}
{if $sortDir != 'ASC' && $sortDir != 'DESC'}{assign var=sortDir value='DESC'}{/if}
{if $sortKey == 'date'}{assign var=sortColIdx value=1}
{elseif $sortKey == 'due'}{assign var=sortColIdx value=2}
{elseif $sortKey == 'amount'}{assign var=sortColIdx value=3}
{elseif $sortKey == 'status'}{assign var=sortColIdx value=4}
{else}{assign var=sortColIdx value=0}
{/if}

<script>
{literal}
if (typeof jQuery !== 'undefined' && jQuery.fn.DataTable) {
    jQuery(function ($) {
        var $tbl = $('#invTable');
        if (!$tbl.length) return;
        var table = $tbl.DataTable({
            paging:    false,
            searching: false,
            info:      false,
            autoWidth: false,
            ordering:  true,
{/literal}
            order:     [[{$sortColIdx}, '{$sortDir|lower}']],
{literal}
            columnDefs: [
                { orderable: false, targets: -1 },
                // Force types per column — DataTables auto-detection samples the
                // first row's data-order value and can pick wrong types, silently
                // breaking sort. See "Column type rules" below.
                { type: 'num',    targets: [0, 3] },          // id, amount
                { type: 'string', targets: [1, 2, 4] }        // date, due, status
            ]
        });
        var keyByCol = { 0: 'id', 1: 'date', 2: 'due', 3: 'amount', 4: 'status' };
        table.on('order.dt', function () {
            var ord = table.order();
            if (!ord || !ord.length) return;
            var key = keyByCol[ord[0][0]];
            var dir = (ord[0][1] || 'asc').toUpperCase();
            if (!key) return;
            try {
                var url = new URL(window.location.href);
                url.searchParams.set('orderby', key);
                url.searchParams.set('sort', dir);
                window.history.replaceState({}, '', url.toString());
            } catch (err) {}
        });
    });
}
{/literal}
</script>
```

Critical: `paging:false, searching:false, info:false` keeps our custom pager/filter visible — DataTables ONLY handles sort. `autoWidth:false` prevents it from overriding our `<colgroup>` widths with inline styles.

### Column type rules (the bug that bit us)

**Always set `columnDefs` types explicitly — never rely on auto-detection.** DataTables samples the first row's `data-order` value to pick a sort type. With ambiguous data ("2024" could be a number or a year, "5.99" could be a float or a version) it picks the wrong type and the column either sorts in an unexpected order or doesn't sort at all. We hit this on supporttickets: the Subject column wouldn't sort alphabetically because DataTables guessed the wrong type from the first row.

Pick types from this matrix:

| Column content | `data-order` value | `type` |
|---|---|---|
| Plain text (subject, name, department) | the raw text | `'string'` |
| Status / category (lowercased class name) | `unpaid`, `delivered`, `on-hold` | `'string'` |
| ID (integer primary key) | `42`, `1083` | `'num'` |
| Money / amount | `19.99`, `1234.50` (raw float, no `$`) | `'num'` |
| Date — formatted | `Apr 11, 2026` — DON'T sort on this | always pair with raw date |
| Date — raw (ISO or `YYYY-MM-DD HH:MM:SS`) | `2026-04-11` or `2026-04-11 14:23:55` | `'string'` (lex order = chron order) |
| Date — UNIX timestamp | `1744387200` | `'num'` |
| Boolean (on/off, true/false) | `1` / `0` or `yes` / `no` | `'string'` (consistent across rows) |

**Verification — open DevTools console and inspect the detected type:**
```javascript
var t = jQuery('#invTable').DataTable();
t.columns().every(function () {
    console.log('Col', this.index(), 'type:', t.column(this.index()).type());
});
// Each line must show the type you configured. If "num" shows up for a
// text column or "html" shows anywhere, the auto-detect picked wrong.
```

**The actual sort behavior test** — paste in console after the page loads:
```javascript
var t = jQuery('#invTable').DataTable();
t.order([0, 'asc']).draw();  // sort by first column ascending
var first = jQuery('#invTable tbody tr').first().find('td').first().text().trim();
t.order([0, 'desc']).draw();
var first2 = jQuery('#invTable tbody tr').first().find('td').first().text().trim();
console.log({ asc: first, desc: first2, changed: first !== first2 });
// "changed: true" means sort worked. "changed: false" means the column
// is sorting incorrectly OR isn't sortable (orderable: false).
```

### 4. CSS — own the sort indicator, hide DataTables defaults

We skip the DataTables CSS bundle, so DataTables only adds the state classes (`.sorting`, `.sorting_asc`, `.sorting_desc`) to `<th>` — we paint the arrows ourselves on the `<span class="inv-sort-ico">` that lives inside each `<th>`:

```css
.inv-table thead th {
    padding: 10px 20px 6px;
    font-size: 11px; font-weight: 600;
    color: var(--color-text-tertiary);
    text-transform: uppercase; letter-spacing: 0.05em;
    text-align: left; background: transparent; border: 0;
    cursor: pointer; user-select: none; white-space: nowrap;
}
.inv-table thead th.hl-actions { cursor: default; }
.inv-table thead th .inv-sort-ico {
    display: inline-block; position: relative;
    width: 10px; height: 12px; vertical-align: middle; margin-left: 4px;
}
.inv-table thead th .inv-sort-ico::before,
.inv-table thead th .inv-sort-ico::after {
    content: ""; position: absolute; left: 2px;
    border-left: 3px solid transparent; border-right: 3px solid transparent;
    opacity: 0.3;
}
.inv-table thead th .inv-sort-ico::before { top: 1px; border-bottom: 4px solid currentColor; }
.inv-table thead th .inv-sort-ico::after  { bottom: 1px; border-top: 4px solid currentColor; }
/* DataTables sort-state — active column lights up its arrow */
.inv-table thead th.sorting_asc, .inv-table thead th.sorting_desc { color: var(--color-text-primary); }
.inv-table thead th.sorting_asc  .inv-sort-ico::before { opacity: 1; }
.inv-table thead th.sorting_desc .inv-sort-ico::after  { opacity: 1; }
```

Mobile reset must hide `.inv-table thead` (not the old `.inv-table-head-row`):

```css
@media (max-width: 720px) {
    .inv-table thead,
    .inv-table colgroup { display: none; }
}
```

### Hook-side sort (initial render + no-JS fallback)

`Hooks.php::fetchAll<X>()` honors `?orderby=…&sort=…` so the first paint is already correctly ordered before DataTables runs. Keep raw `_sort_*` fields on each row — `<td data-order>` reads them.

```php
$orderby = (string)($_GET['orderby'] ?? 'id');
$sort    = strtoupper((string)($_GET['sort'] ?? 'DESC'));
if (!in_array($sort, ['ASC', 'DESC'], true)) { $sort = 'DESC'; }

$cmp = match ($orderby) {
    'date'   => fn($a, $b) => strcmp($a['_sort_date_raw'], $b['_sort_date_raw']),
    'amount' => fn($a, $b) => $a['_sort_amount'] <=> $b['_sort_amount'],
    'status' => fn($a, $b) => strcasecmp($a['status'], $b['status']),
    default  => fn($a, $b) => $a['id'] <=> $b['id'],
};
usort($out, $cmp);
if ($sort === 'DESC') { $out = array_reverse($out); }
```

### Verification

**Console test** — paste after clicking the Date header twice:

```javascript
(() => {
  var table = jQuery('#invTable').DataTable();
  // Sort by amount ascending
  table.order([3, 'asc']).draw();
  var ord1 = table.order();
  // Then desc
  table.order([3, 'desc']).draw();
  var ord2 = table.order();
  var firstAmount = jQuery('#invTable tbody tr').first().find('td.amount').attr('data-order');
  return {
    asc:  ord1[0][0] === 3 && ord1[0][1] === 'asc',
    desc: ord2[0][0] === 3 && ord2[0][1] === 'desc',
    urlOrderby: new URL(location.href).searchParams.get('orderby'),
    firstRowSortValue: firstAmount,
  };
})()
// asc + desc must be true. urlOrderby must equal "amount".
```

**Initial-render fallback test** (server-side sort, no JS):
```bash
curl -s -b cookies.txt "https://bill.hostnodes.com/clientarea.php?action=invoices&orderby=amount&sort=ASC" \
  | grep -oE 'data-order="[0-9.]+"' | head -3
# First row's data-order must be the smallest amount in the result set.
```

### Gotchas seen along the way

- **Vanilla JS sort engine looked correct but didn't match Lagom UX** — first attempt was a custom ~30 line vanilla JS engine, replaced when the user wanted exact Lagom parity (DataTables).
- **URL-based sort (page reload) feels broken** — single-row tables show no visible change on click; the user reported "only Invoice column works." Don't do this for list pages.
- **DataTables `autoWidth: true` (default)** overrides `<colgroup>` widths with inline styles — `autoWidth: false` is required to keep our column proportions.
- **`{literal}` mishandling** — Smarty eats DataTables's object-literal config (`{ paging: false, ... }`) unless it's inside `{literal}`. Split the script: literal for JS, plain Smarty only for the `{$sortColIdx}` and `{$sortDir|lower}` interpolations. See §10 gotcha about JS object literals.
- **DataTables CSS bundle conflicts** — pulling `jquery.dataTables.min.css` adds its own sort indicators on top of our `.inv-sort-ico` spans. Skip the CSS bundle; let DataTables only manage the state classes (`.sorting_asc`/`.sorting_desc`) and paint indicators ourselves.

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
- [ ] **Dispatcher is named after the WHMCS templatefile, not the URL slug**: `/supporttickets.php` → `supportticketslist.tpl`, `/announcements.php?id=X` → `viewannouncement.tpl`, etc. If unsure, add a temporary `<!-- tpl: {$templatefile} -->` to `header.tpl` and `curl` the live page after deploy. Trap: building `<urlslug>.tpl` instead of `<templatefile>.tpl` produces an HTTP 200 with an empty `.content-area` because WHMCS can't find a matching tpl.
- [ ] **Every sortable DataTables column has an explicit `columnDefs` type** — never rely on auto-detection. See §6f "Column type rules" matrix. Quick test: paste the verification snippet from §6f into DevTools and confirm every column reports the type you configured.
- [ ] Smarty assignments use `{assign}`, not `{$x = y}`
- [ ] `{foreach}` loops use the iterator's built-in `@iteration` / `@index` properties — no `{foreach $x as $y@custom}` (invalid syntax, silent compile failure that empties the content-area)
- [ ] Inline `<script>` (and `<style>` if it contains `{...}`) bodies are wrapped in `{literal}…{/literal}` so Smarty doesn't parse JS curly braces
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

## 9. Pages status (live as of `b42bfe7`)

**60 WHMCS pages covered.** Every page has the 5-file skeleton (dispatcher + page.php + default.tpl + pageoption.php + page CSS) and passes `scripts/check-pages.sh files lint` locally. Polish level varies — list below.

### Full content (real WHMCS variables wired, polished UI)

| Group | Pages |
|---|---|
| Core client area | clientareahome, clientareaproducts, clientareadomains, clientareainvoices, clientareaquotes, clientareadetails, clientareasecurity |
| Support | supporttickets (+ supportticketslist forwarder), supportticketsubmit, viewticket |
| Billing | viewinvoice (full CSS adapted from mockup), clientareaaddfunds, invoice-payment, account-paymentmethods, masspay |
| Content | announcements, viewannouncement, knowledgebase, knowledgebasecat, knowledgebasearticle |
| Auth | login, homepage, clientregister, pwreset (+ password-reset-{container,email-prompt,security-prompt,change-prompt} forwarders), two-factor-challenge, two-factor-new-backup-code, user-verify-email, user-invite-accept |
| Account | contact, clientareaproductdetails |

Localapi `mt*` fallback hooks registered: `ClientAreaPageProductsServices`, `ClientAreaPageDomains`, `ClientAreaPageInvoices`, `ClientAreaPageQuotes`, `ClientAreaPageSupportTickets`, `ClientAreaPageHome`.

### Scaffolded (5-file skeleton in place, WHMCS variable wiring pending)

These pages render a real H1 + page-prefixed div + working CSS link so they exist functionally and pass `scripts/check-pages.sh files lint`. Each needs follow-up to layer in real WHMCS variable rendering. Listed by group to make backlog work easy to batch:

| Group | Pages |
|---|---|
| Domain ops | clientareadomaindetails, clientareadomaindns, clientareadomainemailforwarding, clientareadomainregisterns, clientareadomaingetepp, clientareadomainaddons, clientareadomaincontactinfo, bulkdomainmanagement, domain-pricing |
| Billing detail | viewquote, clientareacancelrequest, subscription-manage, usagebillingpricing, account-paymentmethods-manage, account-paymentmethods-billing-contacts |
| Upgrade flow | upgrade, upgrade-configure, upgradesummary |
| Account contacts / users | account-contacts-manage, account-contacts-new, account-user-management, account-user-permissions |
| Account misc | clientareaemails, viewemail |
| SSL | configuressl-stepone, configuressl-steptwo, configuressl-complete, managessl |
| Ticket submit variants | supportticketsubmit-customfields, supportticketsubmit-kbsuggestions, supportticketsubmit-confirm |
| Public info | serverstatus, downloads, downloadscat |
| Utility / error | access-denied, banned, 3dsecure, markdown-guide, downloaddenied, ticketfeedback |

### Out of scope

| Page | Reason |
|---|---|
| `cart.php` (order form) | Different theme system — order-form templates live in a separate directory hierarchy outside `templates/mytheme/`. |

### Workflow for filling in a scaffolded page

1. Pick page from the "Scaffolded" list.
2. Identify the matching pattern from §1 (P1 list / P2 detail / P3 wizard / P4 form / P5 static) and the reference page in §1's pattern matrix.
3. Copy reference page's `default.tpl` structure, swap class prefix.
4. Wire WHMCS variables — verify variable names via the cross-check methods in §10 ("Gating on a WHMCS variable that doesn't exist").
5. Adapt CSS from the matching `apple-client-area/<page>.html` mockup style block (strip `body { display: block }` per §6 rule 5, scope `data-subnav-side="outside"` rules per §6c).
6. Run `bash scripts/check-pages.sh files lint <page>` locally — must pass.
7. Commit, push, wipe `templates_c/`, run `bash scripts/check-pages.sh live assets <page>`.

---

## 10. Common gotchas that have bitten us

- **CSS file untracked in git** → 404 on server → unstyled markup. Solution: `git ls-files` to verify, always.
- **WHMCS Smarty doesn't propagate `$products`/`$tickets`/etc. into our included tpl scope** → use the localAPI fallback hook.
- **WHMCS sends invoice (and sometimes product / ticket) status as `<span class="textred">Unpaid</span>` or `<span style="color:#779500">Open</span>`** → always `strip_tags()` (PHP-side) or `|strip_tags` (Smarty-side) before piping into a class attr AND before showing as visible text. If you don't, the raw HTML lands inside `class="status-pill ..."` and the browser parses the embedded `"` as terminating the attribute, smearing the rest of the HTML into the surrounding tag. Hit on `clientareaproducts/default/default.tpl` line 150 (status badge), `viewticket/default/default.tpl` line 27/201 (commit `adab4f7` — assigned `$tktStatusText = $status|strip_tags` once at the top, used it everywhere). Pattern: do the strip ONCE, assign to a `*Text` variable, then derive `*Lower` from that and use both.
- **`|date_format:"%B %e, %Y"` produces garbage on PHP 8.1+** → output looks like `AprApr/SatSat/2026202620262026` because strftime is deprecated and Smarty 4's `date_format` modifier misinterprets `%`-style codes against Carbon objects. Works fine for `$smarty.now|date_format:"%Y"` (a plain DateTime) but breaks for any WHMCS `$timestamp` variable that's a Carbon under the hood. The WHMCS-canonical fix that both Nexus and Lagom use is the `$carbon` helper with PHP `date()` format codes (no `%`): `{$carbon->createFromTimestamp($timestamp)->format('F j, Y')}`. Commit `adab4f7` fixed viewannouncement this way; any other page that formats a WHMCS-supplied timestamp should follow the same pattern.
- **`{$var = value}` inline assignment fails silently in WHMCS Smarty 4** → use `{assign var=var value=value}`.
- **Chained property access on potentially-missing `$myTheme.x.y.z`** → wrap in `isset()` chain before access, or short-circuit assigns won't fire.
- **Hyphenated keys in Smarty dot-notation get parsed as subtraction** → `$myTheme.pages.account-user-management.fullPath` becomes `account MINUS user MINUS management`, the whole template fails to compile, and `.content-area` ends up empty in view-source even though `data-tpl` looks right. Fix in every hyphenated dispatcher under `templates/mytheme/<page>.tpl`: switch to bracket form `$myTheme.pages['account-user-management'].fullPath` (works inside backticks too: `\`$myTheme.pages['account-user-management'].fullPath\``). Hit on 27 dispatchers (all `account-*`, `user-*`, `configuressl-*`, `two-factor-*`, `supportticketsubmit-{customfields,kbsuggestions,confirm}`, `upgrade-configure`, `subscription-manage`, `invoice-payment`, `domain-pricing`, `access-denied`, `markdown-guide`). `scripts/check-pages.sh lint` greps for the broken form now.
- **WHMCS v8 vs v9 data shapes diverge for account-* pages** → reference Nexus for v9 (production), NOT Lagom. Lagom 2.3 targets WHMCS 8. The trap that bit us: in v8, `$user->isOwner` returned a bool; in v9, `isOwner($client)` is a relationship method that requires a `WHMCS\Client` argument. Reading `$user->isOwner` as a property (or `$user.isOwner` in Smarty) triggers `Eloquent::getAttribute → getRelationshipFromMethod → call_user_func() with 0 args → ArgumentCountError`, which kills page rendering with the WHMCS "Oops!" screen. The v9 canonical "is this user the account owner" check is `$user->pivot->owner` (boolean on the client_user pivot table). Same applies to other v8/v9 forks: `$invites` is a separate Collection in v9 (use `$invites->count()` and iterate it for pending invites — they're NOT in `$users`), and `$user->hasTwoFactorAuthEnabled()`, `$user->pivot->hasLastLogin()`, `$user->pivot->getLastLogin()->diffForHumans()` are the v9 methods for the metadata column. **Rule of thumb**: when porting a Lagom snippet, sanity-check the same shape against Nexus first; if Nexus uses `$user->pivot->X` and Lagom uses `$user->X`, trust Nexus.
- **Both `when-empty` and `when-full` markup coexisting** → relies on `apple-layout.css` toggle rules; keep them active, never comment out.
- **`body { display: block; }` leak in page CSS** → kills the body's `display: flex` chain that holds sidebar + main-wrap, most visibly breaking **top-nav layout** since the sticky `.homepage-nav` needs intact flex. Strip this from every page CSS (was in 5 files: clientareahome, clientareaproducts, clientareadomains, clientareainvoices, supporttickets).
- **`[data-subnav-side="outside"]` content-area transforms unscoped** → in top layout there's no sidebar to offset against, so `translateX(-132px)` shoves content off-center. Always include `:not([data-layout="top"])` in the selector.
- **`.ph-main-wrap` missing `flex: 1`** → in top layout (sidebar/rail are fixed-positioned, removed from flex flow) the wrap shrinks to its content's max-width (1120px), leaving `.content-area`'s `margin: auto` no space to absorb, so content sticks to column 0 of the viewport. Required rules: `flex: 1; min-width: 0;` on `.ph-main-wrap`. See §6d.
- **Inline `<script>` blocks with `{...}` object literals or function bodies break Smarty parsing** → page renders HTTP 200 but the content-area is empty because Smarty bailed mid-template. The kebab/sort JS at the bottom of list-page tpls hits this hard with `var pickers = { id: function (row) { ... }, ... }`. ALWAYS wrap inline `<script>` blocks in `{literal} ... {/literal}` so Smarty treats them as opaque. Same trap for inline `<style>` blocks if they ever contain `{...}` selectors (rare).
- **GitHub Action deploys files but doesn't clear `templates_c/`** → manual cPanel wipe needed after every push that changes `.tpl` files.
- **Browser caches CSS aggressively** → bump the `?v=` query string in page tpls when changing CSS, or hard-refresh / use incognito to verify.
- **Top-level dispatcher checks `file_exists` against `"templates/$path"`** → that path is **relative to WHMCS root**, not the tpl's location. Don't refactor it to absolute.
- **Custom foreach iterator names `{foreach $x as $y@idx}` are invalid Smarty** → Smarty doesn't let you rename the iterator properties; trying to do so is a silent compile failure. Use the loop variable's properties directly: `{foreach $x as $y}{if $y@iteration <= 5}…` for 1-based count, or `$y@index` for 0-based. Same trap can appear with `$y@n` / `$y@i` / any custom suffix. Got bit by this in `knowledgebase/default/default.tpl` (commit `7859422`) — the whole content-area rendered empty because Smarty 4 won't compile the template at all.
- **Gating on a WHMCS variable that doesn't exist** → page renders the empty state ("Ticket not available", "Announcement not found") even when the data is there. Two real instances:
  - `viewticket/default.tpl` gated on `$ticketid`, but WHMCS only sets `$tid` (plus `$invalidTicketId` as the actual not-found signal).
  - `viewannouncement/default.tpl` gated on `$announcement_title`, but WHMCS only sets `$title` (the announcement variables on `announcements.php?id=X` are bare top-level: `$id`, `$title`, `$text`, `$timestamp`, `$author`).

  Both fixed in the same commit. Lesson: never invent WHMCS variable names. Verify by either (a) cross-referencing the standard WHMCS Six theme, (b) checking Lagom's tpl for the same page, or (c) printing `{$smarty.template_object|@count}` and `{var_dump($vars)}` temporarily to confirm what's in scope. The variable list in the tpl docblock must match what WHMCS actually sets, not what felt natural to name.
- **DataTables column type auto-detection picks wrong** → a sortable column appears to do nothing on click, or sorts in an unexpected order. Cause: DataTables samples the first row's `data-order` value and guesses "num", "date", "html", "string"; ambiguous data ("5.99", "2024", a lowercased status name) gets typed wrong. Fix: always set `columnDefs: [{ type: 'string', targets: [...text cols...] }, { type: 'num', targets: [...numeric cols...] }]`. Got bit on supporttickets where the Subject column wouldn't sort alphabetically (commit `2ffdc1c` fixed it). See §6f "Column type rules" for the per-column-content type matrix.
- **URL path ≠ WHMCS templatefile** → `/supporttickets.php` is routed through templatefile `supportticketslist`, not `supporttickets`. `/announcements.php?id=X` uses `viewannouncement`, not `announcements`. The dispatcher tpl you need is named after the **templatefile**, not the URL slug. Verification: `view-source:` the live page and look at `data-page-title` in the body tag — that's the WHMCS pageTitle, which usually maps closely to the templatefile. Or add `<!-- tpl: {$templatefile} -->` to header.tpl temporarily. Got bit by this in commit `02e5101` — `supportticketslist.tpl` + `core/pages/supportticketslist/` were never committed, so the live server had no dispatcher for the page and the content-area rendered empty.
- **Empty `.content-area` on view-source = silent Smarty compile failure OR missing dispatcher** → page renders HTTP 200, header + sidebar + footer all paint correctly, but `<div class="content-area">` contains only whitespace. Two top causes:
  1. Smarty parse error in the page's `default.tpl` (invalid syntax, unbalanced tags, modifier-on-wrong-type). Smarty 4 in production mode swallows the error and emits nothing for that include.
  2. WHMCS's templatefile doesn't resolve to any tpl on disk (either the dispatcher file is missing, or it's untracked in git so never deployed via the SFTP action).

  Debug flow: (a) `view-source:`, locate `.content-area`, confirm it's empty. (b) Search for the template's class hooks in the source — if they're entirely absent, the include never ran. (c) `git ls-files | grep <page>` on local repo to confirm everything is tracked. (d) `curl -sI https://bill.hostnodes.com/templates/mytheme/<page>.tpl` to confirm the file is on the live server. (e) If on-disk but still empty, suspect Smarty syntax — `php -l` won't catch this; eyeball the tpl for `$x@custom` iterators, unbalanced `{if}`/`{/if}`, or modifier chains where one step doesn't accept the previous step's output type.

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
