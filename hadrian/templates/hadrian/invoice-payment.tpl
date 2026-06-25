{if isset($hadrian.pages['invoice-payment'].fullPath) && $hadrian.pages['invoice-payment'].fullPath && file_exists("templates/`$hadrian.pages['invoice-payment'].fullPath`")}
	{include file="`$hadrian.pages['invoice-payment'].fullPath`"}
{else}
	{include file="`$template`/core/pages/invoice-payment/default/default.tpl"}
{/if}
