{if isset($myTheme.pages.invoice-payment.fullPath) && $myTheme.pages.invoice-payment.fullPath && file_exists("templates/`$myTheme.pages.invoice-payment.fullPath`")}
	{include file="`$myTheme.pages.invoice-payment.fullPath`"}
{else}
	{include file="`$template`/core/pages/invoice-payment/default/default.tpl"}
{/if}
