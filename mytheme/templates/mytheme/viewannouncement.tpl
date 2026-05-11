{if isset($myTheme.pages.viewannouncement.fullPath) && $myTheme.pages.viewannouncement.fullPath && file_exists("templates/`$myTheme.pages.viewannouncement.fullPath`")}
	{include file="`$myTheme.pages.viewannouncement.fullPath`"}
{else}
	{include file="`$template`/core/pages/viewannouncement/default/default.tpl"}
{/if}
