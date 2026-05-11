{if isset($myTheme.pages.downloads.fullPath) && $myTheme.pages.downloads.fullPath && file_exists("templates/`$myTheme.pages.downloads.fullPath`")}
	{include file="`$myTheme.pages.downloads.fullPath`"}
{else}
	{include file="`$template`/core/pages/downloads/default/default.tpl"}
{/if}
