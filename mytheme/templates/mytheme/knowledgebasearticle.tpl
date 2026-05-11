{if isset($myTheme.pages.knowledgebasearticle.fullPath) && $myTheme.pages.knowledgebasearticle.fullPath && file_exists("templates/`$myTheme.pages.knowledgebasearticle.fullPath`")}
	{include file="`$myTheme.pages.knowledgebasearticle.fullPath`"}
{else}
	{include file="`$template`/core/pages/knowledgebasearticle/default/default.tpl"}
{/if}
