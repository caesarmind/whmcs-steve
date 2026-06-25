{if isset($hadrian.pages.knowledgebase.fullPath) && $hadrian.pages.knowledgebase.fullPath && file_exists("templates/`$hadrian.pages.knowledgebase.fullPath`")}
	{include file="`$hadrian.pages.knowledgebase.fullPath`"}
{else}
	{include file="`$template`/core/pages/knowledgebase/default/default.tpl"}
{/if}
