{if isset($hadrian.pages.clientareaaddfunds.fullPath) && $hadrian.pages.clientareaaddfunds.fullPath && file_exists("templates/`$hadrian.pages.clientareaaddfunds.fullPath`")}
	{include file="`$hadrian.pages.clientareaaddfunds.fullPath`"}
{else}
	{include file="`$template`/core/pages/clientareaaddfunds/default/default.tpl"}
{/if}
