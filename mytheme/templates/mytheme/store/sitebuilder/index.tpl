{if isset($myTheme.pages['store-sitebuilder'].fullPath) && $myTheme.pages['store-sitebuilder'].fullPath && file_exists("templates/`$myTheme.pages['store-sitebuilder'].fullPath`")}
	{include file="`$myTheme.pages['store-sitebuilder'].fullPath`"}
{else}
	{include file="`$template`/core/pages/store-sitebuilder/default/default.tpl"}
{/if}
