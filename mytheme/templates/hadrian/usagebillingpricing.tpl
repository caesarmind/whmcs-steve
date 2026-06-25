{if isset($hadrian.pages.usagebillingpricing.fullPath) && $hadrian.pages.usagebillingpricing.fullPath && file_exists("templates/`$hadrian.pages.usagebillingpricing.fullPath`")}
	{include file="`$hadrian.pages.usagebillingpricing.fullPath`"}
{else}
	{include file="`$template`/core/pages/usagebillingpricing/default/default.tpl"}
{/if}
