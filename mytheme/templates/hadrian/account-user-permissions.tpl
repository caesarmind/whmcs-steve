{if isset($hadrian.pages['account-user-permissions'].fullPath) && $hadrian.pages['account-user-permissions'].fullPath && file_exists("templates/`$hadrian.pages['account-user-permissions'].fullPath`")}
	{include file="`$hadrian.pages['account-user-permissions'].fullPath`"}
{else}
	{include file="`$template`/core/pages/account-user-permissions/default/default.tpl"}
{/if}
