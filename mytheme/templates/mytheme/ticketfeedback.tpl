{if isset($myTheme.pages.ticketfeedback.fullPath) && $myTheme.pages.ticketfeedback.fullPath && file_exists("templates/`$myTheme.pages.ticketfeedback.fullPath`")}
	{include file="`$myTheme.pages.ticketfeedback.fullPath`"}
{else}
	{include file="`$template`/core/pages/ticketfeedback/default/default.tpl"}
{/if}
