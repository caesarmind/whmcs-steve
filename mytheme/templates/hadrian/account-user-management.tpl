{if isset($hadrian.pages['account-user-management'].fullPath) && $hadrian.pages['account-user-management'].fullPath && file_exists("templates/`$hadrian.pages['account-user-management'].fullPath`")}
	{include file="`$hadrian.pages['account-user-management'].fullPath`"}
{else}
	{include file="`$template`/core/pages/account-user-management/default/default.tpl"}
{/if}
