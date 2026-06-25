{if isset($hadrian.pages['account-paymentmethods'].fullPath) && $hadrian.pages['account-paymentmethods'].fullPath && file_exists("templates/`$hadrian.pages['account-paymentmethods'].fullPath`")}
	{include file="`$hadrian.pages['account-paymentmethods'].fullPath`"}
{else}
	{include file="`$template`/core/pages/account-paymentmethods/default/default.tpl"}
{/if}
