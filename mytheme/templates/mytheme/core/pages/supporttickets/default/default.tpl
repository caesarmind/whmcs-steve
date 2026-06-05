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

{* Unified list-table engine (client-side + Dynamic AJAX Loading) — loaded once. *}
{include file="`$template`/includes/partials/list-table-assets.tpl"}

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
            <h1>{$LANG.navtickets}</h1>
            <p class="page-subtitle">{$hadrianLang.support.ticketsListSub}</p>
        </div>
        <a href="{$WEB_ROOT}/submitticket.php" class="page-header-action">
            {$LANG.opennewticket}
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
            <span><strong>{$tkUnreadCount} {if $tkUnreadCount == 1}{$hadrianLang.support.ticketSingular}{else}{$hadrianLang.support.ticketPlural}{/if}</strong> {$hadrianLang.support.newReplyBanner}</span>
            <span class="spacer"></span>
            {if $tkUnreadTid}<a href="{$WEB_ROOT}/viewticket.php?tid={$tkUnreadTid|escape}{if $tkUnreadC}&c={$tkUnreadC|escape}{/if}" class="btn-secondary">{$hadrianLang.support.viewReplies}</a>{/if}
        </div>
        {/if}

        <div class="filter-tabs when-full">
            <button type="button" class="filter-tab active" data-ticket-filter="all" data-mt-for="tkTable" data-mt-filter="">{$hadrianLang.common.filterAll}</button>
            <button type="button" class="filter-tab" data-ticket-filter="open" data-mt-for="tkTable" data-mt-filter="Open">{$LANG.supportticketsstatusopen|default:'Open'}</button>
            <button type="button" class="filter-tab" data-ticket-filter="answered" data-mt-for="tkTable" data-mt-filter="Answered">{$LANG.supportticketsstatusanswered|default:'Answered'}</button>
            <button type="button" class="filter-tab" data-ticket-filter="customer-reply" data-mt-for="tkTable" data-mt-filter="Customer-Reply">{$LANG.supportticketsstatuscustomerreply|default:'Customer-reply'}</button>
            <button type="button" class="filter-tab" data-ticket-filter="closed" data-mt-for="tkTable" data-mt-filter="Closed">{$LANG.supportticketsstatusclosed}</button>
            <span class="mt-list-search"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="7"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg><input type="search" placeholder="{$LANG.search}…" aria-label="{$LANG.search}" data-mt-search data-mt-for="tkTable"></span>
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
                    <p class="tk-empty-title">{$hadrianLang.support.noTicketsTitle}</p>
                    <p class="tk-empty-sub">{$hadrianLang.support.noTicketsSub}</p>
                    <a href="{$WEB_ROOT}/submitticket.php" class="btn-primary">{$LANG.opennewticket}</a>
                </div>

                {if $tkCount > 0}
                <table class="tk-table when-full" id="tkTable" data-mt-type="tickets" data-mt-order="{$sortColIdx}:{$sortDir|lower}" data-mt-length="10" data-mt-filter-col="2"{if $mtAjaxTables} data-mt-action="tableTickets" data-mt-endpoint="{$WEB_ROOT}/clientarea.php"{/if}>
                    <colgroup>
                        <col class="tk-col-subject">
                        <col class="tk-col-department">
                        <col class="tk-col-status">
                        <col class="tk-col-updated">
                    </colgroup>
                    <thead>
                        <tr>
                            <th class="hl-subject">{$LANG.supportticketssubject} <span class="tk-sort-ico"></span></th>
                            <th class="hl-department">{$LANG.supportticketsdepartment} <span class="tk-sort-ico"></span></th>
                            <th class="hl-status">{$LANG.supportticketsstatus} <span class="tk-sort-ico"></span></th>
                            <th class="hl-updated">{$LANG.supportticketsticketlastupdated} <span class="tk-sort-ico"></span></th>
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
                    {$hadrianLang.common.tableShow}
                    <select aria-label="{$hadrianLang.common.rowsPerPage}" data-dt-length data-mt-for="tkTable">
                        <option selected>10</option>
                        <option>25</option>
                        <option>50</option>
                        <option>100</option>
                    </select>
                    {$hadrianLang.common.tableEntries}
                </div>
                <div class="spacer"></div>
                <span data-dt-info data-mt-for="tkTable">{$hadrianLang.common.tableShowing} 1–{$tkCount} {$hadrianLang.common.tableOf} {$tkCount}</span>
                <div class="tk-pages" data-dt-pager data-mt-for="tkTable">
                    <button type="button" disabled aria-label="{$LANG.previouspage}"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="15 18 9 12 15 6"/></svg></button>
                    <button type="button" class="active">1</button>
                    <button type="button" disabled aria-label="{$LANG.nextpage}"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="9 18 15 12 9 6"/></svg></button>
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
                {$hadrianLang.support.myTickets}
                <span class="subnav-count">{$tkCount}</span>
            </a>
            <a href="{$WEB_ROOT}/submitticket.php" class="subnav-item">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
                {$LANG.opennewticket}
            </a>
            <a href="{$WEB_ROOT}/announcements.php" class="subnav-item">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M18 8A6 6 0 006 8c0 7-3 9-3 9h18s-3-2-3-9"/><path d="M13.73 21a2 2 0 01-3.46 0"/></svg>
                {$LANG.announcementstitle}
            </a>
            <a href="{$WEB_ROOT}/knowledgebase.php" class="subnav-item">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M2 3h6a4 4 0 014 4v14a3 3 0 00-3-3H2z"/><path d="M22 3h-6a4 4 0 00-4 4v14a3 3 0 013-3h7z"/></svg>
                {$LANG.knowledgebasetitle}
            </a>
            <a href="{$WEB_ROOT}/downloads.php" class="subnav-item">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M21 15v4a2 2 0 01-2 2H5a2 2 0 01-2-2v-4"/><polyline points="7 10 12 15 17 10"/><line x1="12" y1="15" x2="12" y2="3"/></svg>
                {$LANG.downloadstitle}
            </a>
            <a href="{$WEB_ROOT}/serverstatus.php" class="subnav-item">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><rect x="2" y="4" width="20" height="7" rx="1.5"/><rect x="2" y="13" width="20" height="7" rx="1.5"/></svg>
                {$LANG.networkstatus|default:'Network status'}
            </a>
        </div>
    </aside>
</div>{* /.tk-split *}
