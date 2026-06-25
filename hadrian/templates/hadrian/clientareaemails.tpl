{if isset($hadrian.pages.clientareaemails.fullPath) && $hadrian.pages.clientareaemails.fullPath && file_exists("templates/`$hadrian.pages.clientareaemails.fullPath`")}
	{include file="`$hadrian.pages.clientareaemails.fullPath`"}
{else}
	{include file="`$template`/core/pages/clientareaemails/default/default.tpl"}
{/if}
