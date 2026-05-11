{if isset($myTheme.pages.usagebillingpricing.fullPath) && $myTheme.pages.usagebillingpricing.fullPath && file_exists("templates/`$myTheme.pages.usagebillingpricing.fullPath`")}
	{include file="`$myTheme.pages.usagebillingpricing.fullPath`"}
{else}
	{include file="`$template`/core/pages/usagebillingpricing/default/default.tpl"}
{/if}
