{* =========================================================================
   knowledgebasearticle.tpl — single KB article.
   ========================================================================= *}
<div class="page-header">
    <h1 class="page-title">{$kbarticle.title}</h1>
    <a href="{routePath('knowledgebase-index')}" class="btn btn-secondary btn-sm"><i class="fas fa-arrow-left"></i> {lang key='back'}</a>
</div>

<div class="card">
    <div class="card-body">
        <div class="markdown-content kb-article-body">{$kbarticle.article}</div>

        {if $kbarticle.useful}
            <hr>
            <div class="kb-vote">
                <p>{lang key='kbArticleFeedback'}</p>
                <div class="btn-group">
                    <button type="button" class="btn btn-secondary btn-sm" data-vote="yes"><i class="fas fa-thumbs-up"></i> {lang key='yes'}</button>
                    <button type="button" class="btn btn-secondary btn-sm" data-vote="no"><i class="fas fa-thumbs-down"></i> {lang key='no'}</button>
                </div>
            </div>
        {/if}
    </div>
</div>

{if $relatedArticles}
    <div class="card">
        <div class="card-header"><h3 class="card-title">{lang key='kbRelatedArticles'}</h3></div>
        <div class="card-body">
            {foreach $relatedArticles as $related}
                <a href="{routePath('knowledgebase-article-view', $related.id, $related.urlfriendlyname)}" class="service-item">
                    <div class="service-icon"><i class="far fa-file-alt"></i></div>
                    <div class="service-info"><div class="service-name">{$related.title}</div></div>
                    <span class="service-chevron"><i class="fas fa-chevron-right"></i></span>
                </a>
            {/foreach}
        </div>
    </div>
{/if}
