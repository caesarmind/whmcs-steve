{if isset($myTheme.pages['account-paymentmethods-billing-contacts'].fullPath) && $myTheme.pages['account-paymentmethods-billing-contacts'].fullPath && file_exists("templates/`$myTheme.pages['account-paymentmethods-billing-contacts'].fullPath`")}
	{include file="`$myTheme.pages['account-paymentmethods-billing-contacts'].fullPath`"}
{else}
	{include file="`$template`/core/pages/account-paymentmethods-billing-contacts/default/default.tpl"}
{/if}
