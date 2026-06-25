{if isset($hadrian.pages['store-order'].fullPath) && $hadrian.pages['store-order'].fullPath && file_exists("templates/`$hadrian.pages['store-order'].fullPath`")}
	{include file="`$hadrian.pages['store-order'].fullPath`"}
{else}
	{include file="`$template`/core/pages/store-order/default/default.tpl"}
{/if}
