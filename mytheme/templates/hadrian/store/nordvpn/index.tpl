{if isset($hadrian.pages['store-nordvpn'].fullPath) && $hadrian.pages['store-nordvpn'].fullPath && file_exists("templates/`$hadrian.pages['store-nordvpn'].fullPath`")}
	{include file="`$hadrian.pages['store-nordvpn'].fullPath`"}
{else}
	{include file="`$template`/core/pages/store-nordvpn/default/default.tpl"}
{/if}
