{if isset($myTheme.pages.viewinvoice.fullPath) && $myTheme.pages.viewinvoice.fullPath && file_exists("templates/`$myTheme.pages.viewinvoice.fullPath`")}
	{include file="`$myTheme.pages.viewinvoice.fullPath`"}
{else}
	{include file="`$template`/core/pages/viewinvoice/default/default.tpl"}
{/if}
