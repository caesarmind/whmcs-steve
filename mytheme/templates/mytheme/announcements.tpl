{if isset($myTheme.pages.announcements.fullPath) && $myTheme.pages.announcements.fullPath && file_exists("templates/`$myTheme.pages.announcements.fullPath`")}
	{include file="`$myTheme.pages.announcements.fullPath`"}
{else}
	{include file="`$template`/core/pages/announcements/default/default.tpl"}
{/if}
