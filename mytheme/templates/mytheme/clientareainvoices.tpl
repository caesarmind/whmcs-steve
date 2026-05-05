{if isset($myTheme.pages.clientareainvoices.fullPath) && $myTheme.pages.clientareainvoices.fullPath && file_exists("templates/`$myTheme.pages.clientareainvoices.fullPath`")}
	{include file="`$myTheme.pages.clientareainvoices.fullPath`"}
{else}
	{include file="`$template`/core/pages/clientareainvoices/default/default.tpl"}
{/if}
