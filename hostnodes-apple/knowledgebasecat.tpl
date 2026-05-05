{* =========================================================================
   knowledgebasecat.tpl — articles under a single KB category.
   ========================================================================= *}
<div class="page-header">
    <h1 class="page-title">{$categoryname}</h1>
    {if $categorydescription}<p class="page-subtitle">{$categorydescription}</p>{/if}
</div>

{if $subcats}
    <div class="kb-grid">
        {foreach $subcats as $subcat}
            <a href="{routePath('knowledgebase-category-view', $subcat.id, $subcat.urlfriendlyname)}" class="kb-category-card card">
                <div class="kb-category-icon"><i class="fas fa-folder"></i></div>
                <div class="kb-category-title">{$subcat.name}</div>
                <div class="kb-category-count">{$subcat.numarticles} {lang key='kbArticles'}</div>
            </a>
        {/foreach}
    </div>
{/if}

{if $kbarticles}
    <div class="card">
        <div class="card-header"><h3 class="card-title">{lang key='kbArticles'}</h3></div>
        <div class="card-body">
            {foreach $kbarticles as $article}
                <a href="{routePath('knowledgebase-article-view', $article.id, $article.urlfriendlyname)}" class="service-item">
                    <div class="service-icon"><i class="far fa-file-alt"></i></div>
                    <div class="service-info">
                        <div class="service-name">{$article.title}</div>
                        {if $article.firstline}<div class="service-domain">{$article.firstline}</div>{/if}
                    </div>
                    <span class="service-chevron"><i class="fas fa-chevron-right"></i></span>
                </a>
            {/foreach}
        </div>
    </div>
{/if}
