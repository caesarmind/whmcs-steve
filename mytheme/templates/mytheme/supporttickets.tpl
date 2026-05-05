{if isset($myTheme.pages.supporttickets.fullPath) && $myTheme.pages.supporttickets.fullPath && file_exists("templates/`$myTheme.pages.supporttickets.fullPath`")}
	{include file="`$myTheme.pages.supporttickets.fullPath`"}
{else}
	{include file="`$template`/core/pages/supporttickets/default/default.tpl"}
{/if}
