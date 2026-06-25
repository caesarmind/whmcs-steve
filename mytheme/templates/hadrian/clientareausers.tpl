{if isset($hadrian.pages.clientareausers.fullPath) && $hadrian.pages.clientareausers.fullPath && file_exists("templates/`$hadrian.pages.clientareausers.fullPath`")}
	{include file="`$hadrian.pages.clientareausers.fullPath`"}
{else}
	{include file="`$template`/core/pages/clientareausers/default/default.tpl"}
{/if}
