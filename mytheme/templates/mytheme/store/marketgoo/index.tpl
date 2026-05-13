{if isset($myTheme.pages['store-marketgoo'].fullPath) && $myTheme.pages['store-marketgoo'].fullPath && file_exists("templates/`$myTheme.pages['store-marketgoo'].fullPath`")}
	{include file="`$myTheme.pages['store-marketgoo'].fullPath`"}
{else}
	{include file="`$template`/core/pages/store-marketgoo/default/default.tpl"}
{/if}
