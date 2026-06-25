{if isset($hadrian.pages.clientregister.fullPath) && $hadrian.pages.clientregister.fullPath && file_exists("templates/`$hadrian.pages.clientregister.fullPath`")}
	{include file="`$hadrian.pages.clientregister.fullPath`"}
{else}
	{include file="`$template`/core/pages/clientregister/default/default.tpl"}
{/if}
