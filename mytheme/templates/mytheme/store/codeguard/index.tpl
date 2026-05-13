{if isset($myTheme.pages['store-codeguard'].fullPath) && $myTheme.pages['store-codeguard'].fullPath && file_exists("templates/`$myTheme.pages['store-codeguard'].fullPath`")}
	{include file="`$myTheme.pages['store-codeguard'].fullPath`"}
{else}
	{include file="`$template`/core/pages/store-codeguard/default/default.tpl"}
{/if}
