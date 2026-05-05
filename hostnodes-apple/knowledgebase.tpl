{* =========================================================================
   knowledgebase.tpl — KB home listing all categories.
   ========================================================================= *}
<div class="page-header"><h1 class="page-title">{lang key='knowledgebase'}</h1></div>

{if $searchquery}
    {include file="$template/includes/alert.tpl" type="info" msg="{lang key='kbSearchResultsFor'}: <strong>{$searchquery|escape}</strong>" textcenter=true}
{/if}

<div class="card">
    <div class="card-body">
        <form method="post" action="{routePath('knowledgebase-search')}" class="form-group">
            <input type="text" name="search" class="form-input" placeholder="{lang key='kbSearchBoxText'}" value="{$searchquery|escape}">
        </form>
    </div>
</div>

<div class="kb-grid">
    {foreach $kbcats as $cat}
        <a href="{routePath('knowledgebase-category-view', $cat.id, $cat.urlfriendlyname)}" class="kb-category-card card">
            <div class="kb-category-icon"><i class="fas fa-folder"></i></div>
            <div class="kb-category-title">{$cat.name}</div>
            <div class="kb-category-count">{$cat.numarticles} {lang key='kbArticles'}</div>
        </a>
    {/foreach}
</div>

{if !$kbcats && !$searchquery}
    {include file="$template/includes/alert.tpl" type="info" msg="{lang key='kbNoArticles'}" textcenter=true}
{/if}
