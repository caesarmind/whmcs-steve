{* Hostnodes — Knowledgebase Category (Apple-style).

   WHMCS standard variables expected:
     $category         — current category: id, name, description, parent
     $kbarticles       — articles in this category: id, title, views
     $kbcategories     — direct sub-categories
     $kbsearchterm     — current search query (in-category)
     $kbpopulararticles — popular articles for sidebar
*}

{if (isset($kbarticles) && $kbarticles|@count > 0) || (isset($kbcategories) && $kbcategories|@count > 0)}
    {assign var=dashIsEmpty value='full'}
{else}
    {assign var=dashIsEmpty value='empty'}
{/if}

<link rel="stylesheet" href="{$WEB_ROOT}/templates/{$template}/assets/css/pages/knowledgebasecat.css?v={$myTheme.version|default:'1.0'}">

<script>
(function () {
    var b = document.body;
    if (!b) return;
    b.setAttribute('data-data',   '{$dashIsEmpty}');
    b.setAttribute('data-subnav', 'on');
})();
</script>

<header class="page-header">
    <h1>{if isset($category.name)}{$category.name|escape}{else}{$LANG.knowledgebasetitle|default:'Knowledgebase'}{/if}</h1>
    {if isset($category.description) && $category.description}
    <p class="page-subtitle">{$category.description|strip_tags|truncate:240:"…"}</p>
    {else}
    <p class="page-subtitle">{$LANG.kbcatsub|default:'Browse articles in this category or search to narrow down.'}</p>
    {/if}
</header>

<div class="kb-split">

    {* ══ LEFT: Support sub-nav ══ *}
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
    </aside>

    {* ══ RIGHT: in-category search + article rows ══ *}
    <div class="kb-main">
        <div class="card when-full" style="padding:0;">

            <form class="kb-cat-search" method="get" action="{$WEB_ROOT}/knowledgebase.php">
                <input type="hidden" name="action" value="displaycat">
                {if isset($category.id)}<input type="hidden" name="catid" value="{$category.id|escape}">{/if}
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
                <input type="search" name="search" placeholder="{$LANG.searchincategory|default:'Search in this category…'}" value="{$kbsearchterm|default:''|escape}" autocomplete="off">
            </form>

            {if isset($kbcategories) && $kbcategories|@count > 0}
            {foreach $kbcategories as $cat}
            <a href="{$WEB_ROOT}/knowledgebase.php?action=displaycat&catid={$cat.id}" class="kb-row">
                <div class="kb-row-ico">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M2 3h6a4 4 0 014 4v14a3 3 0 00-3-3H2z"/><path d="M22 3h-6a4 4 0 00-4 4v14a3 3 0 013-3h7z"/></svg>
                </div>
                <div class="kb-row-info">
                    <div class="kb-row-title">{$cat.name|escape}</div>
                    {if isset($cat.numarticles)}<div class="kb-row-sub">{$cat.numarticles|escape} {$LANG.kbarticles|default:'articles'}</div>{/if}
                </div>
                <span class="kb-row-chev"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="9 18 15 12 9 6"/></svg></span>
            </a>
            {/foreach}
            {/if}

            {if isset($kbarticles) && $kbarticles|@count > 0}
            {foreach $kbarticles as $art}
            <a href="{$WEB_ROOT}/knowledgebase.php?action=displayarticle&id={$art.id}" class="kb-row">
                <div class="kb-row-ico">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M14 2H6a2 2 0 00-2 2v16a2 2 0 002 2h12a2 2 0 002-2V8z"/><polyline points="14 2 14 8 20 8"/><line x1="9" y1="13" x2="15" y2="13"/></svg>
                </div>
                <div class="kb-row-info">
                    <div class="kb-row-title">{$art.title|escape}</div>
                    {if isset($art.views) && $art.views}<div class="kb-row-sub">{$art.views|escape} {$LANG.views|default:'views'}</div>{/if}
                </div>
                <span class="kb-row-chev"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="9 18 15 12 9 6"/></svg></span>
            </a>
            {/foreach}
            {/if}

        </div>

        {* Empty state *}
        <div class="card when-empty">
            <div class="kb-empty">
                <div class="kb-empty-ico">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
                </div>
                <p class="kb-empty-title">{$LANG.kbnoresults|default:'No matching articles'}</p>
                <p class="kb-empty-sub">{$LANG.kbnoresultssub|default:'Try a broader search or browse all categories.'}</p>
                <a href="{$WEB_ROOT}/knowledgebase.php" class="btn-secondary">{$LANG.kballcategories|default:'All categories'}</a>
            </div>
        </div>
    </div>

</div>
