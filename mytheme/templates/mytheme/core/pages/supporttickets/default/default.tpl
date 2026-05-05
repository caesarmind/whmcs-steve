{* Hostnodes — Support Tickets list (Apple-style).

   WHMCS standard variables expected:
     $tickets       — array, each: id, tid, c, subject, department, lastreply,
                      status, statusclass
     $openOnly      — bool — when true, only open tickets are shown
*}

{if isset($tickets) && $tickets|count > 0}
    {assign var=dashIsEmpty value='full'}
    {assign var=tkCount value=$tickets|count}
{else}
    {assign var=dashIsEmpty value='empty'}
    {assign var=tkCount value=0}
{/if}

{* Page-specific stylesheet *}
<link rel="stylesheet" href="{$WEB_ROOT}/templates/{$template}/assets/css/pages/supporttickets.css?v={$myTheme.version|default:'1.0'}">

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

        <div class="filter-tabs when-full">
            <a href="{$WEB_ROOT}/supporttickets.php" class="filter-tab{if !$openOnly} active{/if}">{$LANG.all|default:'All'}</a>
            <a href="{$WEB_ROOT}/supporttickets.php?openonly=true" class="filter-tab{if $openOnly} active{/if}">{$LANG.supportticketsstatusopen|default:'Open'}</a>
        </div>

        <div class="tk-stack">

            <div class="tk-table-head-row when-full">
                <div><button type="button" class="tk-sort active" data-sort="subject" data-dir="asc">{$LANG.supportticketssubject|default:'Subject'} <span class="tk-sort-ico"></span></button></div>
                <div><button type="button" class="tk-sort" data-sort="department" data-dir="">{$LANG.supportticketsdepartment|default:'Department'} <span class="tk-sort-ico"></span></button></div>
                <div><button type="button" class="tk-sort" data-sort="status" data-dir="">{$LANG.supportticketsstatus|default:'Status'} <span class="tk-sort-ico"></span></button></div>
                <div><button type="button" class="tk-sort" data-sort="updated" data-dir="">{$LANG.supportticketslastupdated|default:'Last updated'} <span class="tk-sort-ico"></span></button></div>
            </div>

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

                {if isset($tickets) && $tickets|count > 0}
                <div class="tk-list when-full">
                    {foreach $tickets as $tkt}
                    {assign var=tktStatusClass value=$tkt.statusclass|default:$tkt.status|lower|replace:' ':'-'}
                    <div class="tk-row" data-href="{$WEB_ROOT}/viewticket.php?tid={$tkt.tid|escape}{if isset($tkt.c) && $tkt.c}&c={$tkt.c|escape}{/if}">
                        <div>
                            <div class="tk-subject-cell">
                                <div class="tk-subject-id">#{$tkt.tid|escape}</div>
                                <div class="tk-subject-title">{$tkt.subject|escape}</div>
                            </div>
                        </div>
                        <div>{$tkt.department|default:''|escape}</div>
                        <div><span class="status-pill {$tktStatusClass}">{$tkt.status|escape}</span></div>
                        <div>
                            <div class="tk-updated-date">{$tkt.lastreply|default:''|escape}</div>
                        </div>
                    </div>
                    {/foreach}
                </div>
                {/if}
            </div>

            <div class="tk-footer when-full">
                <div class="tk-page-size">
                    {$LANG.show|default:'Show'}
                    <select aria-label="{$LANG.rowsperpage|default:'Rows per page'}">
                        <option selected>10</option>
                        <option>25</option>
                        <option>50</option>
                        <option>100</option>
                    </select>
                    {$LANG.entries|default:'entries'}
                </div>
                <div class="spacer"></div>
                <span>{$LANG.showing|default:'Showing'} 1–{$tkCount} {$LANG.of|default:'of'} {$tkCount}</span>
                <div class="tk-pages">
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
