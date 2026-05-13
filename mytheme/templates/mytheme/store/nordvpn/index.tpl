{if isset($myTheme.pages['store-nordvpn'].fullPath) && $myTheme.pages['store-nordvpn'].fullPath && file_exists("templates/`$myTheme.pages['store-nordvpn'].fullPath`")}
	{include file="`$myTheme.pages['store-nordvpn'].fullPath`"}
{else}
	{include file="`$template`/core/pages/store-nordvpn/default/default.tpl"}
{/if}
