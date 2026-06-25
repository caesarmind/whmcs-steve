{if isset($hadrian.pages['account-paymentmethods-billing-contacts'].fullPath) && $hadrian.pages['account-paymentmethods-billing-contacts'].fullPath && file_exists("templates/`$hadrian.pages['account-paymentmethods-billing-contacts'].fullPath`")}
	{include file="`$hadrian.pages['account-paymentmethods-billing-contacts'].fullPath`"}
{else}
	{include file="`$template`/core/pages/account-paymentmethods-billing-contacts/default/default.tpl"}
{/if}
