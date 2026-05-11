{if isset($myTheme.pages.upgradesummary.fullPath) && $myTheme.pages.upgradesummary.fullPath && file_exists("templates/`$myTheme.pages.upgradesummary.fullPath`")}
	{include file="`$myTheme.pages.upgradesummary.fullPath`"}
{else}
	{include file="`$template`/core/pages/upgradesummary/default/default.tpl"}
{/if}
