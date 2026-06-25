{if isset($hadrian.pages['store-codeguard'].fullPath) && $hadrian.pages['store-codeguard'].fullPath && file_exists("templates/`$hadrian.pages['store-codeguard'].fullPath`")}
	{include file="`$hadrian.pages['store-codeguard'].fullPath`"}
{else}
	{include file="`$template`/core/pages/store-codeguard/default/default.tpl"}
{/if}
