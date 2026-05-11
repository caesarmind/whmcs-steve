{* Hostnodes — View single announcement (Apple-style).

   WHMCS standard variables on announcements.php?id=X:
     $id         — announcement id
     $title      — announcement title
     $text       — body HTML (already sanitized server-side)
     $timestamp  — unix timestamp; we format via |date_format
     $date       — fallback pre-formatted date string (some WHMCS versions)
     $author     — optional author name
*}

{* Trap: earlier version of this tpl used $announcement_title / $announcement_text,
   which WHMCS does NOT expose — page always rendered "Announcement not found".
   See PAGE-CHECKLIST §6f and §10 columnDefs gotcha for the pattern. *}
{assign var=annTitle value=$title|default:''}
{assign var=annText  value=$text|default:''}
{assign var=annDate  value=$date|default:''}
{if !$annDate && isset($timestamp) && $timestamp}
    {assign var=annDate value=$timestamp|date_format:"%B %e, %Y"}
{/if}

{if $annTitle}
    {assign var=dashIsEmpty value='full'}
{else}
    {assign var=dashIsEmpty value='empty'}
{/if}

{* Page-specific stylesheet *}
<link rel="stylesheet" href="{$WEB_ROOT}/templates/{$template}/assets/css/pages/viewannouncement.css?v={$myTheme.version|default:'1.0'}">

<script>
(function () {
    var b = document.body;
    if (!b) return;
    b.setAttribute('data-data',   '{$dashIsEmpty}');
    b.setAttribute('data-subnav', 'on');
})();
</script>

<header class="page-header">
    <h1>{$LANG.announcementstitle|default:'Announcements'}</h1>
    <p class="page-subtitle">{$LANG.viewannouncementsub|default:'Read the full announcement and related news.'}</p>
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

    {* ══ RIGHT: article ══ *}
    <div class="ann-main when-full">
        <article class="card">
            <header class="article-head">
                <h1 class="article-title">{$annTitle|escape}</h1>
                <div class="article-meta">
                    {if $annDate}<span>{$annDate|escape}</span>{/if}
                    {if isset($author) && $author}<span class="dot">·</span><span>{$author|escape}</span>{/if}
                </div>
            </header>
            <div class="article-body">
                {$annText}
            </div>
            <footer class="article-foot">
                <a href="{$WEB_ROOT}/announcements.php" class="btn-secondary">
                    <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="15 18 9 12 15 6"/></svg>
                    {$LANG.allannouncements|default:'All announcements'}
                </a>
                <div class="article-foot-spacer"></div>
                <button type="button" class="share-btn" data-copy-link>
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M10 13a5 5 0 007.54.54l3-3a5 5 0 00-7.07-7.07l-1.72 1.71"/><path d="M14 11a5 5 0 00-7.54-.54l-3 3a5 5 0 007.07 7.07l1.71-1.71"/></svg>
                    {$LANG.copylink|default:'Copy link'}
                </button>
            </footer>
        </article>
    </div>

    {* Empty state — announcement not found *}
    <div class="ann-main when-empty">
        <div class="card ann-empty">
            <div class="ann-empty-ico">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
            </div>
            <p class="ann-empty-title">{$LANG.announcementnotfound|default:'Announcement not found'}</p>
            <p class="ann-empty-sub">{$LANG.announcementnotfoundsub|default:'This announcement may have been removed or is no longer accessible.'}</p>
            <a href="{$WEB_ROOT}/announcements.php" class="btn-secondary">{$LANG.allannouncements|default:'All announcements'}</a>
        </div>
    </div>

</div>{* /.ann-split *}

<script>
{literal}
// Copy permalink to clipboard
document.addEventListener('click', function (e) {
    var btn = e.target.closest('[data-copy-link]');
    if (!btn) return;
    e.preventDefault();
    var url = window.location.href;
    if (navigator.clipboard && navigator.clipboard.writeText) {
        navigator.clipboard.writeText(url).then(function () {
            var orig = btn.innerHTML;
            btn.innerHTML = '<svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"/></svg> Copied';
            setTimeout(function () { btn.innerHTML = orig; }, 1600);
        });
    }
});
{/literal}
</script>
