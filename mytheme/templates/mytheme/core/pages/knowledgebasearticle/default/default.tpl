{* Hostnodes — Knowledgebase Article (Apple-style).

   WHMCS standard variables expected:
     $kbarticle        — the article: id, title, text, views, parentlink
     $relatedarticles  — array of related articles
     $kbpopulararticles — popular articles for sidebar
     $useful           — count of "Yes" votes
     $notuseful        — count of "No" votes
     $userVoted        — true if current user has already voted
*}

{if isset($kbarticle.title) && $kbarticle.title}
    {assign var=dashIsEmpty value='full'}
{else}
    {assign var=dashIsEmpty value='empty'}
{/if}

<link rel="stylesheet" href="{$WEB_ROOT}/templates/{$template}/assets/css/pages/knowledgebasearticle.css?v={$myTheme.version|default:'1.0'}">

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
    <p class="page-subtitle">{$LANG.kbarticlesub|default:'Read the full article and rate it.'}</p>
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
    </aside>

    {* ══ RIGHT: article + helpful + related ══ *}
    <div class="kb-main when-full">

        <article class="card">
            <header class="article-head">
                <h1 class="article-title">{$kbarticle.title|default:''|escape}</h1>
                <div class="article-meta">
                    {if isset($kbarticle.views) && $kbarticle.views}
                    <span>{$kbarticle.views|escape} {$LANG.views|default:'views'}</span>
                    {/if}
                </div>
            </header>
            <div class="article-body">
                {$kbarticle.text}
            </div>
        </article>

        <div class="card helpful-card">
            <h3 class="helpful-title">{$LANG.helpfultitle|default:'Was this article helpful?'}</h3>
            <form method="post" action="{$WEB_ROOT}/knowledgebase.php?action=displayarticle&id={$kbarticle.id|default:0}" class="helpful-actions">
                <button type="submit" name="rate" value="useful" class="helpful-btn yes">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M14 9V5a3 3 0 00-3-3l-4 9v11h11.28a2 2 0 002-1.7L21.66 11A2 2 0 0019.72 9zM7 22H4a2 2 0 01-2-2v-7a2 2 0 012-2h3"/></svg>
                    {$LANG.yes|default:'Yes'}
                </button>
                <button type="submit" name="rate" value="notuseful" class="helpful-btn no">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M10 15v4a3 3 0 003 3l4-9V2H5.72a2 2 0 00-2 1.7l-1.38 9a2 2 0 002 2.3zm7-13h2.67A2.31 2.31 0 0122 4v7a2.31 2.31 0 01-2.33 2H17"/></svg>
                    {$LANG.no|default:'No'}
                </button>
            </form>
            {if isset($useful) && ($useful > 0 || (isset($notuseful) && $notuseful > 0))}
            <p class="helpful-stats">
                <strong>{$useful|default:0|escape}</strong> {$LANG.helpfulvotes|default:'people found this helpful'}{if isset($notuseful) && $notuseful > 0}, <strong>{$notuseful|escape}</strong> {$LANG.didnt|default:"didn't"}{/if}
            </p>
            {/if}
        </div>

        {if isset($relatedarticles) && $relatedarticles|@count > 0}
        <div class="card">
            <div class="related-head">{$LANG.relatedarticles|default:'Related articles'}</div>
            {foreach $relatedarticles as $rel}
            <a href="{$WEB_ROOT}/knowledgebase.php?action=displayarticle&id={$rel.id}" class="related-row">
                <div class="rel-info">
                    <div class="rel-title">{$rel.title|escape}</div>
                    {if isset($rel.views)}<div class="rel-date">{$rel.views|escape} {$LANG.views|default:'views'}</div>{/if}
                </div>
                <span class="rel-chev"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="9 18 15 12 9 6"/></svg></span>
            </a>
            {/foreach}
        </div>
        {/if}

    </div>

    {* Empty state — article not found *}
    <div class="kb-main when-empty">
        <div class="card kb-empty">
            <div class="kb-empty-ico">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
            </div>
            <p class="kb-empty-title">{$LANG.articlenotfound|default:'Article not found'}</p>
            <p class="kb-empty-sub">{$LANG.articlenotfoundsub|default:'This article may have been removed or is no longer accessible.'}</p>
            <a href="{$WEB_ROOT}/knowledgebase.php" class="btn-secondary">{$LANG.kballcategories|default:'All categories'}</a>
        </div>
    </div>

</div>
