{if isset($myTheme.pages.upgrade.fullPath) && $myTheme.pages.upgrade.fullPath && file_exists("templates/`$myTheme.pages.upgrade.fullPath`")}
	{include file="`$myTheme.pages.upgrade.fullPath`"}
{else}
	{include file="`$template`/core/pages/upgrade/default/default.tpl"}
{/if}
