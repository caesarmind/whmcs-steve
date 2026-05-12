{if isset($myTheme.pages['upgrade-configure'].fullPath) && $myTheme.pages['upgrade-configure'].fullPath && file_exists("templates/`$myTheme.pages['upgrade-configure'].fullPath`")}
	{include file="`$myTheme.pages['upgrade-configure'].fullPath`"}
{else}
	{include file="`$template`/core/pages/upgrade-configure/default/default.tpl"}
{/if}
