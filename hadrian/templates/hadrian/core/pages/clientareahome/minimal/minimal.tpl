{* Hostnodes - Client Home dashboard, "minimal" variant.

   A quieter dashboard than core/pages/clientareahome/default: a greeting, four
   summary tiles, three quick actions, then every list the client owns as plain
   rows on one white surface. No panel grid, no promo slider, no account
   sub-nav aside - the theme's own sidebar/rail already carries that navigation.

   Variables from WHMCS:
     $clientsdetails.firstname
     $clientsstats.productsnumactive / .numactivedomains
                   .numunpaidinvoices / .numactivetickets
                   .dueinvoicesbalance (pre-formatted currency, may be absent)

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
{assign var=minSearchAt value=8}

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

{* Unpaid tile. Prefer the pre-formatted currency balance; fall back to the
   count so the tile never renders blank on an install that does not expose it. *}
{assign var=minDueValue value=$clientsstats.dueinvoicesbalance|default:''}
{if !$minDueValue}{assign var=minDueValue value=$clientsstats.unpaidinvoicesamount|default:''}{/if}
{if !$minDueValue}{assign var=minDueValue value=$clientsstats.numunpaidinvoices|default:0}{/if}

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
    <a href="{$WEB_ROOT}/clientarea.php?action=invoices" class="min-tile due">
        <div class="n">{$minDueValue}</div>
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

{* ---------- Services ---------- *}
<div class="min-section">
    <div class="min-section-head">
        <span class="min-section-label">{$LANG.navservices|default:'Services'}</span>
        {if $nServices > 0}<a href="{$WEB_ROOT}/clientarea.php?action=services" class="min-section-link">{$LANG.viewall|default:'View All'}{if $clientsstats.productsnumactive > 0} ({$clientsstats.productsnumactive}){/if} &rarr;</a>{/if}
    </div>
    <div class="min-list">
        {if $nServices > 0}
            {if $nServices >= $minSearchAt}
            <div class="min-search">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="7"/><path d="M21 21l-4-4"/></svg>
                <input type="text" placeholder="{$hadrianLang.dashboard.searchPlaceholder|escape}" aria-label="{$hadrianLang.dashboard.searchPlaceholder|escape}">
                <button type="button" class="min-search-clear" aria-label="{$LANG.clear|default:'Clear'|escape}">&times;</button>
            </div>
            {/if}
            {foreach $minServices as $svc}
            <a href="{$WEB_ROOT}/clientarea.php?action=productdetails&amp;id={$svc.id|escape:'url'}" class="min-row{if $svc@iteration > $minRows} min-more{/if}">
                <span class="min-name">{$svc.name|escape}{if $svc.domain} &mdash; {$svc.domain|escape}{/if}</span>
                <span class="status-pill {$svc.status|default:'Active'|lower|replace:' ':'-'|escape}">{$svc.status|default:'Active'|escape}</span>
            </a>
            {/foreach}
            {if $nServices > $minRows}
            <button type="button" class="min-showmore" data-more="{$hadrianLang.dashboard.showMore|escape}" data-less="{$hadrianLang.dashboard.showLess|escape}"><span class="min-showmore-label">{$hadrianLang.dashboard.showMore}</span><span class="chev">&#9662;</span></button>
            {/if}
            {* Only meaningful when a search box exists to produce no matches. Emitting it
               unconditionally left a permanently hidden last child, which kept the final
               visible row on its non-:last-child branch and drew a stray hairline. *}
            {if $nServices >= $minSearchAt}<div class="min-noresults">{$hadrianLang.dashboard.noMatches}</div>{/if}
        {else}
        <div class="min-empty">
            <p>{$hadrianLang.dashboard.noServicesSub}</p>
            <div class="acts"><a href="{$WEB_ROOT}/cart.php" class="btn-primary">{$LANG.orderproducts|default:'Order a service'}</a></div>
        </div>
        {/if}
    </div>
</div>

{* ---------- Domains ---------- *}
<div class="min-section">
    <div class="min-section-head">
        <span class="min-section-label">{$LANG.navdomains|default:'Domains'}</span>
        {if $nDomains > 0}<a href="{$WEB_ROOT}/clientarea.php?action=domains" class="min-section-link">{$LANG.viewall|default:'View All'}{if $clientsstats.numactivedomains > 0} ({$clientsstats.numactivedomains}){/if} &rarr;</a>{/if}
    </div>
    <div class="min-list">
        {if $nDomains > 0}
            {if $nDomains >= $minSearchAt}
            <div class="min-search">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="7"/><path d="M21 21l-4-4"/></svg>
                <input type="text" placeholder="{$hadrianLang.dashboard.searchPlaceholder|escape}" aria-label="{$hadrianLang.dashboard.searchPlaceholder|escape}">
                <button type="button" class="min-search-clear" aria-label="{$LANG.clear|default:'Clear'|escape}">&times;</button>
            </div>
            {/if}
            {foreach $minDomains as $dom}
            <a href="{$WEB_ROOT}/clientarea.php?action=domaindetails&amp;id={$dom.id|escape:'url'}" class="min-row{if $dom@iteration > $minRows} min-more{/if}">
                <span class="min-name">{$dom.domain|escape}</span>
                {if $dom.status == 'Active' && $dom.expirydate}
                    {* Custom key, not $LANG.domainrenewals -- that one is the
                       "Domain Renewals" PAGE title, so it would read
                       "Domain Renewals Aug 24, 2026" and the |default: would
                       never fire to save it. *}
                    <span class="min-when">{$hadrianLang.dashboard.renews} {$dom.expirydate|escape}</span>
                {else}
                    <span class="status-pill {$dom.statusLower|default:'active'|replace:' ':'-'|escape}">{$dom.status|default:'Active'|escape}</span>
                {/if}
            </a>
            {/foreach}
            {if $nDomains > $minRows}
            <button type="button" class="min-showmore" data-more="{$hadrianLang.dashboard.showMore|escape}" data-less="{$hadrianLang.dashboard.showLess|escape}"><span class="min-showmore-label">{$hadrianLang.dashboard.showMore}</span><span class="chev">&#9662;</span></button>
            {/if}
            {* Only meaningful when a search box exists to produce no matches. Emitting it
               unconditionally left a permanently hidden last child, which kept the final
               visible row on its non-:last-child branch and drew a stray hairline. *}
            {if $nDomains >= $minSearchAt}<div class="min-noresults">{$hadrianLang.dashboard.noMatches}</div>{/if}
        {else}
        <div class="min-empty">
            <p>{$hadrianLang.dashboard.noDomainsSub}</p>
            <div class="acts"><a href="{$WEB_ROOT}/cart.php?a=add&amp;domain=register" class="btn-primary">{$LANG.registerdomain|default:'Register a domain'}</a></div>
        </div>
        {/if}
    </div>
</div>

{* ---------- Secondary: invoices | tickets + announcements ---------- *}
<div class="min-grid">
    <div class="min-gcol">

        <div class="min-section">
            <div class="min-section-head">
                <span class="min-section-label">{$hadrianLang.dashboard.recentInvoices}</span>
                {if $nInvoices > 0}<a href="{$WEB_ROOT}/clientarea.php?action=invoices" class="min-section-link">{$LANG.viewall|default:'View All'} &rarr;</a>{/if}
            </div>
            <div class="min-list">
                {if $nInvoices > 0}
                    {foreach $minInvoices as $inv}
                    <a href="{$WEB_ROOT}/viewinvoice.php?id={$inv.id|escape:'url'}" class="min-row{if $inv@iteration > $minRows} min-more{/if}">
                        {* invoicestitle ("Invoice"), NOT invoicenumber ("Invoice #") --
                           the latter carries its own hash and would render "Invoice # #12".
                           Matches viewinvoice/default.tpl:43 and invoice-payment/default.tpl:14. *}
                        <span class="min-name">{$LANG.invoicestitle|default:'Invoice'} #{$inv.id|escape}</span>
                        <span class="min-right">
                            {if $inv.total}<span class="min-amt">{$inv.total|escape}</span>{/if}
                            {if $inv.status}<span class="status-pill {$inv.statusLower|default:''|escape}">{$inv.status|escape}</span>{/if}
                        </span>
                    </a>
                    {/foreach}
                    {if $nInvoices > $minRows}
                    <button type="button" class="min-showmore" data-more="{$hadrianLang.dashboard.showMore|escape}" data-less="{$hadrianLang.dashboard.showLess|escape}"><span class="min-showmore-label">{$hadrianLang.dashboard.showMore}</span><span class="chev">&#9662;</span></button>
                    {/if}
                {else}
                <div class="min-empty compact"><p>{$hadrianLang.dashboard.noInvoices}</p></div>
                {/if}
            </div>
        </div>

    </div>
    <div class="min-gcol">

        <div class="min-section">
            <div class="min-section-head">
                <span class="min-section-label">{$LANG.navtickets|default:'Support'}</span>
                {if $nTickets > 0}<a href="{$WEB_ROOT}/supporttickets.php" class="min-section-link">{$LANG.viewall|default:'View All'}{if $clientsstats.numactivetickets > 0} ({$clientsstats.numactivetickets}){/if} &rarr;</a>{/if}
            </div>
            <div class="min-list">
                {if $nTickets > 0}
                    {foreach $minTickets as $tkt}
                    <a href="{$WEB_ROOT}/viewticket.php?tid={$tkt.tid|escape:'url'}{if $tkt.c}&amp;c={$tkt.c|escape:'url'}{/if}" class="min-row{if $tkt@iteration > $minRows} min-more{/if}">
                        <span class="min-name">{$tkt.subject|escape}</span>
                        <span class="status-pill {$tkt.status|default:'Open'|lower|replace:' ':'-'|escape}">{$tkt.status|default:'Open'|escape}</span>
                    </a>
                    {/foreach}
                    {if $nTickets > $minRows}
                    <button type="button" class="min-showmore" data-more="{$hadrianLang.dashboard.showMore|escape}" data-less="{$hadrianLang.dashboard.showLess|escape}"><span class="min-showmore-label">{$hadrianLang.dashboard.showMore}</span><span class="chev">&#9662;</span></button>
                    {/if}
                {else}
                <div class="min-empty compact"><p>{$hadrianLang.dashboard.noOpenTickets}</p></div>
                {/if}
            </div>
        </div>

        <div class="min-section">
            <div class="min-section-head">
                <span class="min-section-label">{$LANG.announcements|default:'Announcements'}</span>
                {if $nNews > 0}<a href="{$WEB_ROOT}/announcements.php" class="min-section-link">{$LANG.viewall|default:'View All'} &rarr;</a>{/if}
            </div>
            <div class="min-list">
                {if $nNews > 0}
                    {foreach $minNews as $ann}
                    <a href="{$WEB_ROOT}/announcements.php?id={$ann.id|escape:'url'}" class="min-row{if $ann@iteration > $minRows} min-more{/if}">
                        <span class="min-name">{$ann.title|escape}</span>
                        {if $ann.date}<span class="min-when">{$ann.date|escape}</span>{/if}
                    </a>
                    {/foreach}
                    {if $nNews > $minRows}
                    <button type="button" class="min-showmore" data-more="{$hadrianLang.dashboard.showMore|escape}" data-less="{$hadrianLang.dashboard.showLess|escape}"><span class="min-showmore-label">{$hadrianLang.dashboard.showMore}</span><span class="chev">&#9662;</span></button>
                    {/if}
                {else}
                <div class="min-empty compact"><p>{$hadrianLang.dashboard.noAnnouncementsShort}</p></div>
                {/if}
            </div>
        </div>

    </div>
</div>

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
