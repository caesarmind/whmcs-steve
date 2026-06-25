{if isset($hadrian.pages.serverstatus.fullPath) && $hadrian.pages.serverstatus.fullPath && file_exists("templates/`$hadrian.pages.serverstatus.fullPath`")}
	{include file="`$hadrian.pages.serverstatus.fullPath`"}
{else}
	{include file="`$template`/core/pages/serverstatus/default/default.tpl"}
{/if}
