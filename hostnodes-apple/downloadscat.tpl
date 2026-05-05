{* =========================================================================
   downloadscat.tpl — downloads inside a category.
   ========================================================================= *}
<div class="page-header">
    <h1 class="page-title">{$categoryname}</h1>
    <a href="{routePath('downloads-index')}" class="btn btn-secondary btn-sm"><i class="fas fa-arrow-left"></i> {lang key='back'}</a>
</div>

<div class="card">
    <div class="card-body">
        {foreach $downloads as $download}
            <a href="dl.php?type=d&id={$download.id}" class="service-item">
                <div class="service-icon"><i class="fas fa-download"></i></div>
                <div class="service-info">
                    <div class="service-name">{$download.title}</div>
                    {if $download.description}<div class="service-domain">{$download.description}</div>{/if}
                </div>
                <span class="service-meta"><span class="form-hint">{$download.filesize}</span></span>
            </a>
        {foreachelse}
            {include file="$template/includes/alert.tpl" type="info" msg="{lang key='nodownloads'}" textcenter=true}
        {/foreach}
    </div>
</div>
