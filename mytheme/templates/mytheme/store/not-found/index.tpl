{if isset($myTheme.pages['store-not-found'].fullPath) && $myTheme.pages['store-not-found'].fullPath && file_exists("templates/`$myTheme.pages['store-not-found'].fullPath`")}
	{include file="`$myTheme.pages['store-not-found'].fullPath`"}
{else}
	{include file="`$template`/core/pages/store-not-found/default/default.tpl"}
{/if}
