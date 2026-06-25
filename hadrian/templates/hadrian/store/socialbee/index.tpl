{if isset($hadrian.pages['store-socialbee'].fullPath) && $hadrian.pages['store-socialbee'].fullPath && file_exists("templates/`$hadrian.pages['store-socialbee'].fullPath`")}
	{include file="`$hadrian.pages['store-socialbee'].fullPath`"}
{else}
	{include file="`$template`/core/pages/store-socialbee/default/default.tpl"}
{/if}
