{* Hostnodes - Client Home dashboard, "minimal" variant.

   A quieter dashboard than core/pages/clientareahome/default: a greeting, four
   summary tiles, three quick actions, then every list the client owns as plain
   rows on one white surface. No panel grid, no promo slider, no account
   sub-nav aside - the theme's own sidebar/rail already carries that navigation.

   Variables from WHMCS:
     $clientsdetails.firstname
     $clientsstats.productsnumactive / .numactivedomains
                   .numunpaidinvoices / .numactivetickets

   From the Hadrian ClientAreaPageHome hook ($dashboard):
     greeting        'morning'|'afternoon'|'evening'
     activeServices[] id, name, domain, status, nextDueDate
     domains[]        id, domain, status, statusLower, expirydate, nextduedate
     recentInvoices[] id, date, total, status, statusLower
     openTickets[]    tid, c, subject, status, date, lastreply
     announcements[]  id, title, date

   NOTE on empty states: each section branches on its OWN row count with {if},
   not on the global .when-full/.when-empty classes. Those are driven by one
   page-level body[data-data] flag, so using them per-section would show an
   empty Domains card to a client who has services but no domains. The
   page-level flag is still emitted below, for the theme's global affordances.

   Variant options (admin: Hadrian > Pages > Dashboard), read as
   $hadrian.pages.clientareahome.options.* - NOT .config.*, which does not exist:
     min_section_titles   outside|inside
     min_visible_rows     how many rows before "Show more"
     min_show_actions     bool - the quick-action row
*}

{* ---------- options ---------- *}
{assign var=minTitles value=$hadrian.pages.clientareahome.options.min_section_titles|default:'outside'}
{assign var=minRows   value=$hadrian.pages.clientareahome.options.min_visible_rows|default:5}
{assign var=minActs   value=$hadrian.pages.clientareahome.options.min_show_actions|default:true}
{if $minRows < 1}{assign var=minRows value=5}{/if}
{* Row count at which a list grows its own filter box. 0 (or anything that is
   not a positive number) switches the filter off everywhere. Applies to the
   Services and Domains lists only -- see rows.tpl.

   Deliberately NOT |default:8. Zero is a meaningful stored value here ("off"),
   and whether |default: treats 0 as missing depends on which implementation of
   the modifier is in play -- the compiled form tests null/'' and would keep the
   0, an empty()-based one would replace it with 8 and make "off" unreachable.
   Testing isset() explicitly is correct either way. *}
{assign var=minSearchAt value=8}
{if isset($hadrian.pages.clientareahome.options.min_search_at)
    && $hadrian.pages.clientareahome.options.min_search_at !== ''}
    {assign var=minSearchAt value=$hadrian.pages.clientareahome.options.min_search_at}
{/if}
{if !($minSearchAt > 0)}{assign var=minSearchAt value=0}{/if}

{* ---------- data ---------- *}
{assign var=minServices value=$dashboard.activeServices|default:[]}
{assign var=minDomains  value=$dashboard.domains|default:[]}
{assign var=minInvoices value=$dashboard.recentInvoices|default:[]}
{assign var=minTickets  value=$dashboard.openTickets|default:[]}
{assign var=minNews     value=$dashboard.announcements|default:[]}

{assign var=nServices value=$minServices|@count}
{assign var=nDomains  value=$minDomains|@count}
{assign var=nInvoices value=$minInvoices|@count}
{assign var=nTickets  value=$minTickets|@count}
{assign var=nNews     value=$minNews|@count}

{if $nServices > 0 || $nDomains > 0 || $nInvoices > 0 || $nTickets > 0 || $nNews > 0
    || $clientsstats.productsnumactive > 0 || $clientsstats.numactivedomains > 0
    || $clientsstats.numunpaidinvoices > 0 || $clientsstats.numactivetickets > 0}
    {assign var=dashIsEmpty value='full'}
{else}
    {assign var=dashIsEmpty value='empty'}
{/if}

{* Unpaid tile. A COUNT, like its three siblings and like the label above it.
   The amount owed is deliberately not shown here: the tile is a pointer to the
   invoices page, not a bill, and a currency figure made one tile read in a
   different unit from the rest of the row. *}
{assign var=minUnpaid value=$clientsstats.numunpaidinvoices|default:0}

<link rel="stylesheet" href="{$WEB_ROOT}/templates/{$template}/assets/css/pages/clientareahome.css?v={$hadrian.version|default:'1.0'}">

{* Page-level signals. header.tpl owns data-layout / data-subnav / data-svc-layout,
   so only the two this page actually decides are set here. *}
<script>
(function () {
    var b = document.body;
    if (!b) return;
    b.setAttribute('data-data', '{$dashIsEmpty}');
    b.setAttribute('data-min-title', '{$minTitles|escape:'javascript'}');
})();
</script>

<div class="min-head">
    <h1 class="min-greeting">{if $dashboard.greeting == 'morning'}{$hadrianLang.dashboard.goodMorning}{elseif $dashboard.greeting == 'evening'}{$hadrianLang.dashboard.goodEvening}{else}{$hadrianLang.dashboard.goodAfternoon}{/if}{if $clientsdetails.firstname}, {$clientsdetails.firstname|escape}{/if}.</h1>
    <p class="min-sub">{$hadrianLang.dashboard.accountOverview}</p>
</div>

{* ---------- summary tiles ---------- *}
<div class="min-tiles">
    <a href="{$WEB_ROOT}/clientarea.php?action=services" class="min-tile">
        <div class="n">{$clientsstats.productsnumactive|default:0}</div>
        <div class="l">{$LANG.navservices|default:'Services'}</div>
    </a>
    <a href="{$WEB_ROOT}/clientarea.php?action=domains" class="min-tile">
        <div class="n">{$clientsstats.numactivedomains|default:0}</div>
        <div class="l">{$LANG.navdomains|default:'Domains'}</div>
    </a>
    {* .due (the page's only accent) only when there is something to act on --
       a blue $0.00 draws the eye to nothing. *}
    <a href="{$WEB_ROOT}/clientarea.php?action=invoices" class="min-tile{if $minUnpaid > 0} due{/if}">
        <div class="n">{$minUnpaid}</div>
        <div class="l">{$LANG.clientHomePanels.unpaidInvoices|default:'Unpaid Invoices'}</div>
    </a>
    <a href="{$WEB_ROOT}/supporttickets.php" class="min-tile">
        <div class="n">{$clientsstats.numactivetickets|default:0}</div>
        <div class="l">{$LANG.navtickets|default:'Support'}</div>
    </a>
</div>

{* ---------- quick actions ----------
   Always rendered, including on an empty account, which needs them most. *}
{if $minActs}
<div class="min-actions">
    <a href="{$WEB_ROOT}/cart.php" class="min-act primary">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="9"/><line x1="12" y1="8" x2="12" y2="16"/><line x1="8" y1="12" x2="16" y2="12"/></svg>
        {$LANG.orderproducts|default:'Order a service'}
    </a>
    <a href="{$WEB_ROOT}/cart.php?a=add&amp;domain=register" class="min-act">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="9"/><line x1="3" y1="12" x2="21" y2="12"/><path d="M12 3a15 15 0 0 1 0 18 15 15 0 0 1 0-18z"/></svg>
        {$LANG.registerdomain|default:'Register a domain'}
    </a>
    <a href="{$WEB_ROOT}/submitticket.php" class="min-act">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"/></svg>
        {$LANG.navopenticket|default:'Open a ticket'}
    </a>
</div>
{/if}


{* ---------- Sections ----------
   Two shells. The CLASSIC one is what every install gets until an admin opts
   in: Services and Domains full width, then the asymmetric two-column grid.
   It is hand-packed with .min-gcol, which is why Announcements always sits
   directly under Support no matter how tall Invoices grows.

   The CUSTOM shell renders whatever the admin arranged in
   Hadrian > Pages > Dashboard: any order, any subset, each at 1/1, 2/3, 1/2 or
   1/3 of a six-column grid. Being a real grid, items sit on shared rows, so a
   short section beside a tall one leaves the row's full height -- unavoidable
   once arbitrary ordering is the point, and the reason the classic path is
   kept rather than reimplemented on top of the grid.

   $minSecs is resolved in PHP (Hooks::resolveCurrentPage -> SectionLayout).
   An empty list means "no admin layout saved" and selects the classic shell,
   so this is fail-safe: if the theme deploys ahead of the addon the read is
   null, |default:[] gives [], and the page renders exactly as before. *}
{assign var=minSecs value=$hadrian.pages.clientareahome.sections.min_sections|default:[]}

{if $minSecs|@count > 0}
<div class="min-grid min-grid-custom">
    {foreach $minSecs as $s}
        {if $s.visible}
            {* The include path is a constant; only `sec` varies, and it is
               whitelisted here as well as in SectionLayout::parse. Never
               interpolate a stored value into a file path -- an unresolvable
               {include} drops the whole client area to the Six theme, and the
               poisoned compiled-template cache survives a git revert. *}
            {if $s.key == 'services' || $s.key == 'domains' || $s.key == 'invoices' || $s.key == 'tickets' || $s.key == 'announcements' || $s.key == 'domainreg' || $s.key == 'profile'}
                {include file="`$template`/core/pages/clientareahome/minimal/rows.tpl" sec=$s.key secSpan=$s.span secHideEmpty=$s.hideEmpty secPaint=$s.paint secFill=$s.fill}
            {/if}
        {/if}
    {/foreach}
</div>
{else}
{include file="`$template`/core/pages/clientareahome/minimal/rows.tpl" sec='services' secSpan=6}
{include file="`$template`/core/pages/clientareahome/minimal/rows.tpl" sec='domains' secSpan=6}
<div class="min-grid">
    <div class="min-gcol">
        {include file="`$template`/core/pages/clientareahome/minimal/rows.tpl" sec='invoices' secSpan=3}
    </div>
    <div class="min-gcol">
        {include file="`$template`/core/pages/clientareahome/minimal/rows.tpl" sec='tickets' secSpan=3}
        {include file="`$template`/core/pages/clientareahome/minimal/rows.tpl" sec='announcements' secSpan=3}
    </div>
</div>
{/if}

{* Progressive disclosure. All markup above is server-rendered - this only binds
   behaviour, so the page is complete and readable with JS off (every row is in
   the DOM; .min-more rows are simply collapsed).
   {literal} because Smarty would otherwise parse the JS braces as tags. *}
{literal}
<script>
(function () {
    // Show more / Show less. One delegated listener rather than an inline
    // handler per button; labels come from data-* so they stay translatable.
    document.addEventListener('click', function (e) {
        var btn = e.target.closest ? e.target.closest('.min-showmore') : null;
        if (!btn) return;
        var list = btn.closest('.min-list');
        if (!list) return;
        var open = list.classList.toggle('expanded');
        var label = btn.querySelector('.min-showmore-label');
        if (label) label.textContent = open ? btn.dataset.less : btn.dataset.more;
    });

    // In-list filter. Rendered server-side only on lists long enough to need
    // it; while a query is active every row becomes a candidate (including the
    // collapsed .min-more ones) and Show more steps aside.
    document.querySelectorAll('.min-list').forEach(function (list) {
        var search = list.querySelector('.min-search');
        if (!search) return;
        var input = search.querySelector('input');
        var clear = search.querySelector('.min-search-clear');
        var rows  = Array.prototype.slice.call(list.querySelectorAll('.min-row'));
        var more  = list.querySelector('.min-showmore');
        if (!input) return;

        function apply() {
            var q = input.value.trim().toLowerCase();
            var matches = 0;
            list.classList.toggle('searching', !!q);
            search.classList.toggle('has-q', !!q);
            rows.forEach(function (row) {
                var name = row.querySelector('.min-name');
                var hit = !q || (name && name.textContent.toLowerCase().indexOf(q) !== -1);
                row.classList.toggle('min-hidden', !!q && !hit);
                if (hit) matches++;
            });
            list.classList.toggle('no-results', !!q && matches === 0);
            if (more) more.style.display = q ? 'none' : '';
        }

        input.addEventListener('input', apply);
        if (clear) clear.addEventListener('click', function () {
            input.value = '';
            apply();
            input.focus();
        });
    });
})();
</script>
{/literal}
