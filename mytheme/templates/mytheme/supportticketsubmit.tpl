{if isset($myTheme.pages.supportticketsubmit.fullPath) && $myTheme.pages.supportticketsubmit.fullPath && file_exists("templates/`$myTheme.pages.supportticketsubmit.fullPath`")}
	{include file="`$myTheme.pages.supportticketsubmit.fullPath`"}
{else}
	{include file="`$template`/core/pages/supportticketsubmit/default/default.tpl"}
{/if}
