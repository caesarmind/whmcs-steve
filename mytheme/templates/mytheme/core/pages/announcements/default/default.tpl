{* Hostnodes — Announcements list (Apple-style).

   WHMCS standard variables expected:
     $announcements    — array, each: id, date, title, text
     $startnumber      — pagination start offset (optional)
     $pagesize         — rows per page (optional)
     $numannouncements — total count (optional)
*}

{if isset($announcements) && $announcements|count > 0}
    {assign var=dashIsEmpty value='full'}
    {assign var=annCount value=$announcements|count}
{else}
    {assign var=dashIsEmpty value='empty'}
    {assign var=annCount value=0}
{/if}

{* Page-specific stylesheet *}
<link rel="stylesheet" href="{$WEB_ROOT}/templates/{$template}/assets/css/pages/announcements.css?v={$myTheme.version|default:'1.0'}">

<script>
(function () {
    var b = document.body;
    if (!b) return;
    b.setAttribute('data-data', '{$dashIsEmpty}');
})();
</script>

<header class="page-header">
    <h1>{$LANG.announcementstitle|default:'Announcements'}</h1>
    <p class="page-subtitle">{$LANG.announcementssub|default:'Product updates, network notices, and news from Hostnodes.'}</p>
</header>

<div class="ann-split">

    {* ══ LEFT: Support sub-nav ══ *}
    <aside class="ann-aside">
        <div class="card subnav-card">
            <div class="subnav-heading">{$LANG.supporttab|default:'Support'}</div>
            <a href="{$WEB_ROOT}/supporttickets.php" class="subnav-item">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M21 15a2 2 0 01-2 2H7l-4 4V5a2 2 0 012-2h14a2 2 0 012 2z"/></svg>
                {$LANG.mytickets|default:'My support tickets'}
            </a>
            <a href="{$WEB_ROOT}/announcements.php" class="subnav-item active">
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
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><rect x="2" y="4" width="20" height="7" rx="1.5"/><rect x="2" y="13" width="20" height="7" rx="1.5"/><line x1="6" y1="7.5" x2="6.01" y2="7.5"/><line x1="6" y1="16.5" x2="6.01" y2="16.5"/></svg>
                {$LANG.networkstatus|default:'Network status'}
            </a>
            <a href="{$WEB_ROOT}/submitticket.php" class="subnav-item">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
                {$LANG.opennewticket|default:'Open ticket'}
            </a>
            <a href="{$WEB_ROOT}/announcements.php?rss=true" class="subnav-item">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M4 11a9 9 0 019 9"/><path d="M4 4a16 16 0 0116 16"/><circle cx="5" cy="19" r="1"/></svg>
                {$LANG.viewrss|default:'View RSS feed'}
            </a>
        </div>
    </aside>

    {* ══ RIGHT: announcement list ══ *}
    <div class="ann-main">

        {* Empty state *}
        <div class="card when-empty">
            <div class="ann-empty">
                <div class="ann-empty-ico">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M18 8A6 6 0 006 8c0 7-3 9-3 9h18s-3-2-3-9"/><path d="M13.73 21a2 2 0 01-3.46 0"/></svg>
                </div>
                <p class="ann-empty-title">{$LANG.announcementsnone|default:'No announcements yet'}</p>
                <p class="ann-empty-sub">{$LANG.announcementsnonesub|default:'Product updates, network notices and news will appear here. Subscribe to the RSS feed to be notified when new posts arrive.'}</p>
                <a href="{$WEB_ROOT}/announcements.php?rss=true" class="btn-secondary">
                    <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M4 11a9 9 0 019 9"/><path d="M4 4a16 16 0 0116 16"/><circle cx="5" cy="19" r="1"/></svg>
                    {$LANG.subscribetorss|default:'Subscribe to RSS'}
                </a>
            </div>
        </div>

        {if isset($announcements) && $announcements|count > 0}
        <div class="when-full">
            {foreach $announcements as $ann}
            <div class="card">
                <div class="card-body">
                    <a href="{$WEB_ROOT}/announcements.php?id={$ann.id}" class="announcement-link">
                        <h3 class="announcement-title">{$ann.title|escape}</h3>
                        {if isset($ann.text) && $ann.text}
                        <p class="announcement-excerpt">{$ann.text|strip_tags|truncate:240:"…"}</p>
                        {/if}
                        <div class="announcement-footer">
                            <div class="announcement-date">{$ann.date|escape}</div>
                            <span class="service-chevron"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><polyline points="9 18 15 12 9 6"/></svg></span>
                        </div>
                    </a>
                </div>
            </div>
            {/foreach}
        </div>
        {/if}
    </div>
</div>{* /.ann-split *}
