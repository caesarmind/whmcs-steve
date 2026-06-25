{if isset($hadrian.pages['store-ssl'].fullPath) && $hadrian.pages['store-ssl'].fullPath && file_exists("templates/`$hadrian.pages['store-ssl'].fullPath`")}
	{include file="`$hadrian.pages['store-ssl'].fullPath`"}
{else}
	{include file="`$template`/core/pages/store-ssl/default/default.tpl"}
{/if}
