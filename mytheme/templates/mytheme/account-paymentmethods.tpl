{if isset($myTheme.pages['account-paymentmethods'].fullPath) && $myTheme.pages['account-paymentmethods'].fullPath && file_exists("templates/`$myTheme.pages['account-paymentmethods'].fullPath`")}
	{include file="`$myTheme.pages['account-paymentmethods'].fullPath`"}
{else}
	{include file="`$template`/core/pages/account-paymentmethods/default/default.tpl"}
{/if}
