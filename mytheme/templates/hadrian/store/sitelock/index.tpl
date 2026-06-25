{if isset($hadrian.pages['store-sitelock'].fullPath) && $hadrian.pages['store-sitelock'].fullPath && file_exists("templates/`$hadrian.pages['store-sitelock'].fullPath`")}
	{include file="`$hadrian.pages['store-sitelock'].fullPath`"}
{else}
	{include file="`$template`/core/pages/store-sitelock/default/default.tpl"}
{/if}
