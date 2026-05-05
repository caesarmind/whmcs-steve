{* =========================================================================
   downloads.tpl — list of downloadable categories.
   ========================================================================= *}
<div class="page-header"><h1 class="page-title">{lang key='downloadstitle'}</h1></div>

<div class="kb-grid">
    {foreach $downloadcats as $cat}
        <a href="{routePath('downloads-category-view', $cat.id, $cat.urlfriendlyname)}" class="kb-category-card card">
            <div class="kb-category-icon"><i class="far fa-folder"></i></div>
            <div class="kb-category-title">{$cat.name}</div>
            <div class="kb-category-count">{$cat.numdownloads} {lang key='downloadsname'}</div>
        </a>
    {/foreach}
</div>

{if !$downloadcats}
    {include file="$template/includes/alert.tpl" type="info" msg="{lang key='nodownloads'}" textcenter=true}
{/if}
