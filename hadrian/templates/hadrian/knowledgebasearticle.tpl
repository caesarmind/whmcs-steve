{if isset($hadrian.pages.knowledgebasearticle.fullPath) && $hadrian.pages.knowledgebasearticle.fullPath && file_exists("templates/`$hadrian.pages.knowledgebasearticle.fullPath`")}
	{include file="`$hadrian.pages.knowledgebasearticle.fullPath`"}
{else}
	{include file="`$template`/core/pages/knowledgebasearticle/default/default.tpl"}
{/if}
