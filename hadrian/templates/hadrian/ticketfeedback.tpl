{if isset($hadrian.pages.ticketfeedback.fullPath) && $hadrian.pages.ticketfeedback.fullPath && file_exists("templates/`$hadrian.pages.ticketfeedback.fullPath`")}
	{include file="`$hadrian.pages.ticketfeedback.fullPath`"}
{else}
	{include file="`$template`/core/pages/ticketfeedback/default/default.tpl"}
{/if}
