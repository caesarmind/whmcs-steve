{if isset($hadrian.pages['account-paymentmethods-manage'].fullPath) && $hadrian.pages['account-paymentmethods-manage'].fullPath && file_exists("templates/`$hadrian.pages['account-paymentmethods-manage'].fullPath`")}
	{include file="`$hadrian.pages['account-paymentmethods-manage'].fullPath`"}
{else}
	{include file="`$template`/core/pages/account-paymentmethods-manage/default/default.tpl"}
{/if}
