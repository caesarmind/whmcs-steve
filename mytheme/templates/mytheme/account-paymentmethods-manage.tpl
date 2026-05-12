{if isset($myTheme.pages['account-paymentmethods-manage'].fullPath) && $myTheme.pages['account-paymentmethods-manage'].fullPath && file_exists("templates/`$myTheme.pages['account-paymentmethods-manage'].fullPath`")}
	{include file="`$myTheme.pages['account-paymentmethods-manage'].fullPath`"}
{else}
	{include file="`$template`/core/pages/account-paymentmethods-manage/default/default.tpl"}
{/if}
