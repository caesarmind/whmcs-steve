{if isset($hadrian.pages.knowledgebasecat.fullPath) && $hadrian.pages.knowledgebasecat.fullPath && file_exists("templates/`$hadrian.pages.knowledgebasecat.fullPath`")}
	{include file="`$hadrian.pages.knowledgebasecat.fullPath`"}
{else}
	{include file="`$template`/core/pages/knowledgebasecat/default/default.tpl"}
{/if}
