{if isset($hadrian.pages['store-ox'].fullPath) && $hadrian.pages['store-ox'].fullPath && file_exists("templates/`$hadrian.pages['store-ox'].fullPath`")}
	{include file="`$hadrian.pages['store-ox'].fullPath`"}
{else}
	{include file="`$template`/core/pages/store-ox/default/default.tpl"}
{/if}
