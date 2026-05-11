{* Hostnodes — Knowledgebase root (Apple-style).

   WHMCS standard variables expected:
     $kbcategories     — array of top-level categories: id, name, description, numarticles
     $kbarticles       — popular root articles: id, title, views
     $kbsearchterm     — current search query (if any)
*}

{if isset($kbcategories) && $kbcategories|@count > 0}
    {assign var=dashIsEmpty value='full'}
{else}
    {assign var=dashIsEmpty value='empty'}
{/if}

<link rel="stylesheet" href="{$WEB_ROOT}/templates/{$template}/assets/css/pages/knowledgebase.css?v={$myTheme.version|default:'1.0'}">

<script>
(function () {
    var b = document.body;
    if (!b) return;
    b.setAttribute('data-data',   '{$dashIsEmpty}');
    b.setAttribute('data-subnav', 'on');
})();
</script>

<header class="page-header">
    <h1>{$LANG.knowledgebasetitle|default:'Knowledgebase'}</h1>
    <p class="page-subtitle">{$LANG.knowledgebasesub|default:'Setup guides, troubleshooting and answers to frequently asked questions.'}</p>
</header>

<div class="kb-split">

    {* ══ LEFT: Support sub-nav + popular ══ *}
    <aside class="kb-aside">
        <div class="card subnav-card">
            <div class="subnav-heading">{$LANG.supporttab|default:'Support'}</div>
            <a href="{$WEB_ROOT}/supporttickets.php" class="subnav-item">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M21 15a2 2 0 01-2 2H7l-4 4V5a2 2 0 012-2h14a2 2 0 012 2z"/></svg>
                {$LANG.mytickets|default:'My support tickets'}
            </a>
            <a href="{$WEB_ROOT}/announcements.php" class="subnav-item">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M18 8A6 6 0 006 8c0 7-3 9-3 9h18s-3-2-3-9"/><path d="M13.73 21a2 2 0 01-3.46 0"/></svg>
                {$LANG.announcementstitle|default:'Announcements'}
            </a>
            <a href="{$WEB_ROOT}/knowledgebase.php" class="subnav-item active">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M2 3h6a4 4 0 014 4v14a3 3 0 00-3-3H2z"/><path d="M22 3h-6a4 4 0 00-4 4v14a3 3 0 013-3h7z"/></svg>
                {$LANG.knowledgebasetitle|default:'Knowledgebase'}
            </a>
            <a href="{$WEB_ROOT}/submitticket.php" class="subnav-item">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
                {$LANG.opennewticket|default:'Open ticket'}
            </a>
        </div>

        {if isset($kbarticles) && $kbarticles|@count > 0}
        <div class="card subnav-card">
            <div class="subnav-heading">{$LANG.knowledgebasepop|default:'Most popular'}</div>
            {foreach $kbarticles as $art}
            {if $art@iteration <= 5}
            <a href="{$WEB_ROOT}/knowledgebase.php?action=displayarticle&id={$art.id}" class="pop-row">
                <span class="pop-rank">{$art@iteration}</span>
                <div class="pop-row-info">
                    <div class="pop-row-title">{$art.title|escape}</div>
                    {if isset($art.views)}<div class="pop-row-meta">{$art.views|escape} {$LANG.views|default:'views'}</div>{/if}
                </div>
            </a>
            {/if}
            {/foreach}
        </div>
        {/if}
    </aside>

    {* ══ RIGHT: hero + category grid ══ *}
    <div class="kb-main">

        <div class="card when-full">
            <div class="kb-hero">
                <h2 class="kb-hero-title">{$LANG.kbherotitle|default:'How can we help?'}</h2>
                <p class="kb-hero-sub">{$LANG.kbherosub|default:'Search the knowledgebase or browse by category below.'}</p>
                <form class="kb-hero-search" method="get" action="{$WEB_ROOT}/knowledgebase.php">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
                    <input type="search" name="search" placeholder="{$LANG.kbsearchplaceholder|default:'Search guides, troubleshooting, billing…'}" value="{$kbsearchterm|default:''|escape}" autocomplete="off">
                </form>
            </div>

            {if isset($kbcategories) && $kbcategories|@count > 0}
            <div class="kb-grid">
                {foreach $kbcategories as $cat}
                <a href="{$WEB_ROOT}/knowledgebase.php?action=displaycat&catid={$cat.id}" class="kb-card">
                    <span class="tile-icon">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M2 3h6a4 4 0 014 4v14a3 3 0 00-3-3H2z"/><path d="M22 3h-6a4 4 0 00-4 4v14a3 3 0 013-3h7z"/></svg>
                    </span>
                    <div class="kb-card-title">{$cat.name|escape}</div>
                    {if isset($cat.numarticles)}<div class="kb-card-count">{$cat.numarticles|escape} {$LANG.kbarticles|default:'articles'}</div>{/if}
                </a>
                {/foreach}
            </div>
            {/if}
        </div>

        {* Empty state *}
        <div class="card when-empty">
            <div class="kb-empty">
                <div class="kb-empty-ico">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M2 3h6a4 4 0 014 4v14a3 3 0 00-3-3H2z"/><path d="M22 3h-6a4 4 0 00-4 4v14a3 3 0 013-3h7z"/></svg>
                </div>
                <p class="kb-empty-title">{$LANG.kbempty|default:'No articles yet'}</p>
                <p class="kb-empty-sub">{$LANG.kbemptysub|default:'When our team publishes setup guides and troubleshooting articles, they will appear here.'}</p>
                <a href="{$WEB_ROOT}/submitticket.php" class="btn-primary">{$LANG.opennewticket|default:'Open a ticket instead'}</a>
            </div>
        </div>
    </div>

</div>{* /.kb-split *}
