{if isset($myTheme.pages['store-sitelock'].fullPath) && $myTheme.pages['store-sitelock'].fullPath && file_exists("templates/`$myTheme.pages['store-sitelock'].fullPath`")}
	{include file="`$myTheme.pages['store-sitelock'].fullPath`"}
{else}
	{include file="`$template`/core/pages/store-sitelock/default/default.tpl"}
{/if}
