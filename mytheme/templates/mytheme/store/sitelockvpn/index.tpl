{if isset($myTheme.pages['store-sitelockvpn'].fullPath) && $myTheme.pages['store-sitelockvpn'].fullPath && file_exists("templates/`$myTheme.pages['store-sitelockvpn'].fullPath`")}
	{include file="`$myTheme.pages['store-sitelockvpn'].fullPath`"}
{else}
	{include file="`$template`/core/pages/store-sitelockvpn/default/default.tpl"}
{/if}
