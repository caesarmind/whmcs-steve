{* Hostnodes — Support Tickets list (Apple-style).

   WHMCS standard variables expected:
     $tickets       — array, each: id, tid, c, subject, department, lastreply,
                      status, statusclass
     $openOnly      — bool — when true, only open tickets are shown
*}
{* Prefer WHMCS-native $tickets; fall back to $mtTickets populated by
   Hooks::clientAreaPageSupportTickets via localAPI when WHMCS doesn't
   propagate $tickets into our included tpl scope. *}
{if isset($tickets) && $tickets|@count > 0}
    {assign var=tkList value=$tickets}
{elseif isset($mtTickets) && $mtTickets|@count > 0}
    {assign var=tkList value=$mtTickets}
{else}
    {assign var=tkList value=[]}
{/if}
{assign var=tkCount value=$tkList|@count}
{if $tkCount > 0}
    {assign var=dashIsEmpty value='full'}
{else}
    {assign var=dashIsEmpty value='empty'}
{/if}
{assign var=tkUnreadCount value=0}
{assign var=tkUnreadTid value=''}
{assign var=tkUnreadC value=''}
{foreach $tkList as $tkt}
    {if !empty($tkt.unread)}
        {assign var=tkUnreadCount value=$tkUnreadCount+1}
        {if !$tkUnreadTid}
            {assign var=tkUnreadTid value=$tkt.tid}
            {assign var=tkUnreadC value=$tkt.c|default:''}
        {/if}
    {/if}
{/foreach}

{* Dynamic AJAX Loading toggle (admin Settings -> enable_dynamic_ajax). When on,
   the table loads server-side in pages of 10 via dynamic-tables.js. *}
{assign var=mtAjaxTables value=$myTheme.addonSettings.enable_dynamic_ajax|default:false}

{* Page-specific stylesheet *}
<link rel="stylesheet" href="{$WEB_ROOT}/templates/{$template}/assets/css/pages/supporttickets.css?v={$myTheme.version|default:'1.0'}">

{* Lagom-style instant sort: jQuery 3.x + DataTables 1.x for client-side reorder. *}
<script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
<script src="https://cdn.datatables.net/1.13.11/js/jquery.dataTables.min.js"></script>
{if $mtAjaxTables}<script src="{$WEB_ROOT}/templates/{$template}/assets/js/dynamic-tables.js?v={$myTheme.version|default:'1.0'}"></script>{/if}

<script>
(function () {
    var b = document.body;
    if (!b) return;
    b.setAttribute('data-data',          '{$dashIsEmpty}');
    b.setAttribute('data-subnav',        'on');
    b.setAttribute('data-svc-layout',    'inside');
})();
</script>

<div class="svc-table-card" aria-hidden="true"></div>

<header class="page-header">
    <div class="page-header-row">
        <div style="flex: 1; min-width: 0;">
            <h1>{$LANG.navtickets|default:'Tickets'}</h1>
            <p class="page-subtitle">{$LANG.ticketssub|default:'Open conversations with our team — filter by status or start a new ticket.'}</p>
        </div>
        <a href="{$WEB_ROOT}/submitticket.php" class="page-header-action">
            {$LANG.opennewticket|default:'Open a ticket'}
            <svg class="chev" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><polyline points="9 18 15 12 9 6"/></svg>
        </a>
    </div>
</header>

<div class="tk-split">
    <div class="tk-main">

        {if $tkUnreadCount > 0}
        <div class="tk-banner when-full">
            <span class="tk-banner-ico">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 15a2 2 0 01-2 2H7l-4 4V5a2 2 0 012-2h14a2 2 0 012 2z"/></svg>
            </span>
            <span><strong>{$tkUnreadCount} {if $tkUnreadCount == 1}{$LANG.ticket|default:'ticket'}{else}{$LANG.tickets|default:'tickets'}{/if}</strong> {$LANG.ticketnewreply|default:'has a new reply from our team.'}</span>
            <span class="spacer"></span>
            {if $tkUnreadTid}<a href="{$WEB_ROOT}/viewticket.php?tid={$tkUnreadTid|escape}{if $tkUnreadC}&c={$tkUnreadC|escape}{/if}" class="btn-secondary">{$LANG.viewreplies|default:'View replies'}</a>{/if}
        </div>
        {/if}

        <div class="filter-tabs when-full">
            <button type="button" class="filter-tab active" data-ticket-filter="all" data-mt-for="tkTable" data-mt-filter="">{$LANG.all|default:'All'}</button>
            <button type="button" class="filter-tab" data-ticket-filter="open" data-mt-for="tkTable" data-mt-filter="Open">{$LANG.supportticketsstatusopen|default:'Open'}</button>
            <button type="button" class="filter-tab" data-ticket-filter="answered" data-mt-for="tkTable" data-mt-filter="Answered">{$LANG.supportticketsstatusanswered|default:'Answered'}</button>
            <button type="button" class="filter-tab" data-ticket-filter="customer-reply" data-mt-for="tkTable" data-mt-filter="Customer-Reply">{$LANG.supportticketsstatuscustomerreply|default:'Customer-reply'}</button>
            <button type="button" class="filter-tab" data-ticket-filter="closed" data-mt-for="tkTable" data-mt-filter="Closed">{$LANG.supportticketsstatusclosed|default:'Closed'}</button>
            <span class="mt-list-search"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="7"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg><input type="search" placeholder="{$LANG.search|default:'Search'}…" aria-label="{$LANG.search|default:'Search'}" data-mt-search data-mt-for="tkTable"></span>
        </div>

        {* Sort: DataTables.js handles instant client-side sort on header click.
           Server returns rows pre-sorted per URL ?orderby=KEY&sort=ASC|DESC via
           Hooks::fetchAllTickets for initial render + no-JS fallback. *}
        {assign var=sortKey value=$smarty.get.orderby|default:'updated'}
        {assign var=sortDir value=$smarty.get.sort|default:'DESC'}
        {if $sortDir != 'ASC' && $sortDir != 'DESC'}{assign var=sortDir value='DESC'}{/if}
        {if $sortKey == 'department'}{assign var=sortColIdx value=1}
        {elseif $sortKey == 'status'}{assign var=sortColIdx value=2}
        {elseif $sortKey == 'updated'}{assign var=sortColIdx value=3}
        {else}{assign var=sortColIdx value=0}
        {/if}

        <div class="tk-stack">

            <div class="card tk-table-card">

                {* Empty state *}
                <div class="when-empty tk-empty">
                    <div class="tk-empty-ico">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M21 15a2 2 0 01-2 2H7l-4 4V5a2 2 0 012-2h14a2 2 0 012 2z"/></svg>
                    </div>
                    <p class="tk-empty-title">{$LANG.notickets|default:'No tickets yet'}</p>
                    <p class="tk-empty-sub">{$LANG.noticketssub|default:"You haven't opened any support tickets. Need a hand with something? Our team is here to help."}</p>
                    <a href="{$WEB_ROOT}/submitticket.php" class="btn-primary">{$LANG.opennewticket|default:'Open a ticket'}</a>
                </div>

                {if $tkCount > 0}
                <table class="tk-table when-full" id="tkTable"{if $mtAjaxTables} data-mt-action="tableTickets" data-mt-type="tickets" data-mt-endpoint="{$WEB_ROOT}/clientarea.php" data-mt-order="3:desc" data-mt-length="10"{/if}>
                    <colgroup>
                        <col class="tk-col-subject">
                        <col class="tk-col-department">
                        <col class="tk-col-status">
                        <col class="tk-col-updated">
                    </colgroup>
                    <thead>
                        <tr>
                            <th class="hl-subject">{$LANG.supportticketssubject|default:'Subject'} <span class="tk-sort-ico"></span></th>
                            <th class="hl-department">{$LANG.supportticketsdepartment|default:'Department'} <span class="tk-sort-ico"></span></th>
                            <th class="hl-status">{$LANG.supportticketsstatus|default:'Status'} <span class="tk-sort-ico"></span></th>
                            <th class="hl-updated">{$LANG.supportticketslastupdated|default:'Last updated'} <span class="tk-sort-ico"></span></th>
                        </tr>
                    </thead>
                    <tbody>
                        {if !$mtAjaxTables}
                        {foreach $tkList as $tkt}
                        {assign var=tktStatusClass value=$tkt.statusClass|default:$tkt.statusclass|default:$tkt.status|lower|replace:' ':'-'|replace:'_':'-'}
                        {assign var=tktPriority value=$tkt.priority|default:$tkt.urgency|default:''|lower|replace:' ':'-'}
                        {assign var=tktStatusLower value=$tkt.status|strip_tags|lower}
                        {* Raw sort values — DataTables reads data-order for sort comparisons.
                           _sort_lastreply_raw comes from Hooks::fetchAllTickets; fall back to
                           the display string if a non-hook source populates the list. *}
                        {assign var=sortLastReply value=$tkt._sort_lastreply_raw|default:$tkt.normalisedLastReply|default:$tkt.lastreply|default:''}
                        <tr data-href="{$WEB_ROOT}/viewticket.php?tid={$tkt.tid|escape}{if isset($tkt.c) && $tkt.c}&c={$tkt.c|escape}{/if}" data-status="{$tktStatusLower|escape:'html'}">
                            <td data-order="{$tkt.subject|escape:'html'}">
                                <div class="tk-subject-cell">
                                    <div class="tk-subject-id">#{$tkt.tid|escape}</div>
                                    <div class="tk-subject-title">{if $tktPriority == 'high' || $tktPriority == 'medium'}<span class="tk-prio-dot {$tktPriority}"></span>{/if}{$tkt.subject|escape}</div>
                                </div>
                            </td>
                            <td data-order="{$tkt.department|default:''|escape:'html'}">{$tkt.department|default:''|escape}</td>
                            <td data-order="{$tktStatusLower|escape:'html'}"><span class="status-pill {$tktStatusClass}"{if !empty($tkt.statusColor)} style="background-color:{$tkt.statusColor|escape};color:#fff"{/if}>{$tkt.status|strip_tags|escape}</span></td>
                            <td data-order="{$sortLastReply|escape:'html'}">
                                {if !empty($tkt.normalisedLastReply)}<span class="sr-only">{$tkt.normalisedLastReply|escape}</span>{/if}
                                <div class="tk-updated-date">{$tkt.lastreply|default:''|escape}</div>
                            </td>
                        </tr>
                        {/foreach}
                        {/if}
                    </tbody>
                </table>
                {/if}
            </div>

            <div class="tk-footer when-full">
                <div class="tk-page-size">
                    {$LANG.show|default:'Show'}
                    <select aria-label="{$LANG.rowsperpage|default:'Rows per page'}" data-dt-length data-mt-for="tkTable">
                        <option selected>10</option>
                        <option>25</option>
                        <option>50</option>
                        <option>100</option>
                    </select>
                    {$LANG.entries|default:'entries'}
                </div>
                <div class="spacer"></div>
                <span data-dt-info data-mt-for="tkTable">{$LANG.showing|default:'Showing'} 1–{$tkCount} {$LANG.of|default:'of'} {$tkCount}</span>
                <div class="tk-pages" data-dt-pager data-mt-for="tkTable">
                    <button type="button" disabled aria-label="{$LANG.previouspage|default:'Previous page'}"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="15 18 9 12 15 6"/></svg></button>
                    <button type="button" class="active">1</button>
                    <button type="button" disabled aria-label="{$LANG.nextpage|default:'Next page'}"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="9 18 15 12 9 6"/></svg></button>
                </div>
            </div>

        </div>{* /.tk-stack *}
    </div>

    {* ══ RIGHT: Support sub-nav ══ *}
    <aside>
        <div class="card subnav-card">
            <div class="subnav-heading">{$LANG.supporttab|default:'Support'}</div>
            <a href="{$WEB_ROOT}/supporttickets.php" class="subnav-item active">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M21 15a2 2 0 01-2 2H7l-4 4V5a2 2 0 012-2h14a2 2 0 012 2z"/></svg>
                {$LANG.mytickets|default:'My tickets'}
                <span class="subnav-count">{$tkCount}</span>
            </a>
            <a href="{$WEB_ROOT}/submitticket.php" class="subnav-item">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
                {$LANG.opennewticket|default:'Open a ticket'}
            </a>
            <a href="{$WEB_ROOT}/announcements.php" class="subnav-item">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M18 8A6 6 0 006 8c0 7-3 9-3 9h18s-3-2-3-9"/><path d="M13.73 21a2 2 0 01-3.46 0"/></svg>
                {$LANG.announcementstitle|default:'Announcements'}
            </a>
            <a href="{$WEB_ROOT}/knowledgebase.php" class="subnav-item">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M2 3h6a4 4 0 014 4v14a3 3 0 00-3-3H2z"/><path d="M22 3h-6a4 4 0 00-4 4v14a3 3 0 013-3h7z"/></svg>
                {$LANG.knowledgebasetitle|default:'Knowledgebase'}
            </a>
            <a href="{$WEB_ROOT}/downloads.php" class="subnav-item">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M21 15v4a2 2 0 01-2 2H5a2 2 0 01-2-2v-4"/><polyline points="7 10 12 15 17 10"/><line x1="12" y1="15" x2="12" y2="3"/></svg>
                {$LANG.downloadstitle|default:'Downloads'}
            </a>
            <a href="{$WEB_ROOT}/serverstatus.php" class="subnav-item">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><rect x="2" y="4" width="20" height="7" rx="1.5"/><rect x="2" y="13" width="20" height="7" rx="1.5"/></svg>
                {$LANG.networkstatus|default:'Network status'}
            </a>
        </div>
    </aside>
</div>{* /.tk-split *}

{if !$mtAjaxTables}
<script>
{literal}
// Row navigation — click a row to go to viewticket
document.addEventListener('DOMContentLoaded', function () {
    document.querySelectorAll('.tk-table tbody tr[data-href]').forEach(function (row) {
        row.setAttribute('tabindex', '0');
        row.setAttribute('role', 'link');
        row.addEventListener('click', function (e) {
            if (e.target.closest('a, button, input, select')) return;
            window.location.href = row.dataset.href;
        });
        row.addEventListener('keydown', function (e) {
            if (e.key === 'Enter' || e.key === ' ') {
                e.preventDefault();
                window.location.href = row.dataset.href;
            }
        });
    });

    // Status filter — hide rows whose data-status doesn't match the active tab.
    // DataTables keeps the rows in DOM but [hidden] CSS rule removes them visually.
    document.querySelectorAll('[data-ticket-filter]').forEach(function (btn) {
        btn.addEventListener('click', function () {
            var filter = btn.dataset.ticketFilter || 'all';
            document.querySelectorAll('[data-ticket-filter]').forEach(function (tab) {
                tab.classList.toggle('active', tab === btn);
            });
            document.querySelectorAll('.tk-table tbody tr').forEach(function (row) {
                var status = (row.getAttribute('data-status') || '').toLowerCase().replace(/\s+/g, '-');
                row.hidden = filter !== 'all' && status !== filter;
            });
        });
    });
});
{/literal}

// DataTables init — Lagom-style instant sort (no page reload).
{literal}
if (typeof jQuery !== 'undefined' && jQuery.fn.DataTable) {
    jQuery(function ($) {
        var $tbl = $('#tkTable');
        if (!$tbl.length) return;
        var TID = 'tkTable';
        function ctrl(attr) { return document.querySelector('[' + attr + '][data-mt-for="' + TID + '"]'); }
        function buildPager(el, info) {
            var page = info.page, pages = info.pages, html = '';
            var L = '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="15 18 9 12 15 6"/></svg>';
            var R = '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="9 18 15 12 9 6"/></svg>';
            html += '<button type="button" data-page="' + (page - 1) + '"' + (page <= 0 ? ' disabled' : '') + ' aria-label="Previous page">' + L + '</button>';
            if (pages > 0) { var win = 5, start = Math.max(0, page - 2), end = Math.min(pages - 1, start + win - 1); start = Math.max(0, Math.min(start, end - win + 1)); for (var p = start; p <= end; p++) { html += '<button type="button" data-page="' + p + '"' + (p === page ? ' class="active"' : '') + '>' + (p + 1) + '</button>'; } } else { html += '<button type="button" class="active">1</button>'; }
            html += '<button type="button" data-page="' + (page + 1) + '"' + (page >= pages - 1 ? ' disabled' : '') + ' aria-label="Next page">' + R + '</button>';
            el.innerHTML = html;
        }
        function updateControls(api) {
            var info = api.page.info();
            var infoEl = ctrl('data-dt-info');
            if (infoEl) { var from = info.recordsDisplay ? info.start + 1 : 0; infoEl.textContent = 'Showing ' + from + '–' + info.end + ' of ' + info.recordsDisplay; }
            var pagerEl = ctrl('data-dt-pager');
            if (pagerEl) { buildPager(pagerEl, info); }
        }
        var table = $tbl.DataTable({
            paging:    true,
            searching: true,
            info:      false,
            autoWidth: false,
            ordering:  true,
            pageLength: 10,
            dom:       'rt',
{/literal}
            order:     [[{$sortColIdx}, '{$sortDir|lower}']],
{literal}
            // Force string type on every column — auto-detection picks "num" or
            // "date" when the first row's data-order value looks numeric/date,
            // which silently breaks alphabetic sort on text columns (subject).
            // ISO date strings still sort chronologically under string-asc.
            columnDefs: [{ type: 'string', targets: '_all' }],
            drawCallback: function () { updateControls(this.api()); }
        });
        var searchEl = ctrl('data-mt-search');
        if (searchEl) { searchEl.addEventListener('input', function () { table.search(this.value || '').draw(); }); }
        var lenEl = ctrl('data-dt-length');
        if (lenEl) { lenEl.value = String(table.page.len()); lenEl.addEventListener('change', function () { var n = parseInt(this.value, 10); if (n > 0) { table.page.len(n).draw(); } }); }
        var pagerEl = ctrl('data-dt-pager');
        if (pagerEl) { pagerEl.addEventListener('click', function (e) { var b = e.target.closest('button[data-page]'); if (!b || b.disabled) return; var p = parseInt(b.getAttribute('data-page'), 10); if (!isNaN(p) && p >= 0) { table.page(p).draw(false); } }); }
        var keyByCol = { 0: 'subject', 1: 'department', 2: 'status', 3: 'updated' };
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
{/if}
