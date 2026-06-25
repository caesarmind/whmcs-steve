{if isset($hadrian.pages['store-marketgoo'].fullPath) && $hadrian.pages['store-marketgoo'].fullPath && file_exists("templates/`$hadrian.pages['store-marketgoo'].fullPath`")}
	{include file="`$hadrian.pages['store-marketgoo'].fullPath`"}
{else}
	{include file="`$template`/core/pages/store-marketgoo/default/default.tpl"}
{/if}
