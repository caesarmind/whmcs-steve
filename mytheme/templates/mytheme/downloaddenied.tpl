{if isset($myTheme.pages.downloaddenied.fullPath) && $myTheme.pages.downloaddenied.fullPath && file_exists("templates/`$myTheme.pages.downloaddenied.fullPath`")}
	{include file="`$myTheme.pages.downloaddenied.fullPath`"}
{else}
	{include file="`$template`/core/pages/downloaddenied/default/default.tpl"}
{/if}
