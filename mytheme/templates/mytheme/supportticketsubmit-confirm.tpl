{if isset($myTheme.pages.supportticketsubmit-confirm.fullPath) && $myTheme.pages.supportticketsubmit-confirm.fullPath && file_exists("templates/`$myTheme.pages.supportticketsubmit-confirm.fullPath`")}
	{include file="`$myTheme.pages.supportticketsubmit-confirm.fullPath`"}
{else}
	{include file="`$template`/core/pages/supportticketsubmit-confirm/default/default.tpl"}
{/if}
