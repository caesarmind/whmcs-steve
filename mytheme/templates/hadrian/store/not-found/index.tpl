{if isset($hadrian.pages['store-not-found'].fullPath) && $hadrian.pages['store-not-found'].fullPath && file_exists("templates/`$hadrian.pages['store-not-found'].fullPath`")}
	{include file="`$hadrian.pages['store-not-found'].fullPath`"}
{else}
	{include file="`$template`/core/pages/store-not-found/default/default.tpl"}
{/if}
