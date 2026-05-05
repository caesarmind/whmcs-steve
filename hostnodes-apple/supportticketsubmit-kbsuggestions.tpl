{* =========================================================================
   supportticketsubmit-kbsuggestions.tpl — KB article suggestions shown while
   the user is typing a ticket subject.
   ========================================================================= *}
{if $suggestedarticles}
    <div class="callout info">
        <h4 class="callout-title">{lang key='supportticketssuggestions'}</h4>
        <ul class="kb-suggestions-list">
            {foreach $suggestedarticles as $article}
                <li>
                    <a href="{routePath('knowledgebase-article-view', $article.id, $article.slug)}" target="_blank" rel="noopener">
                        <i class="far fa-file-alt"></i> {$article.title}
                    </a>
                </li>
            {/foreach}
        </ul>
    </div>
{/if}
