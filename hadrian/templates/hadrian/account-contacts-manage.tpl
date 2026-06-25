{if isset($hadrian.pages['account-contacts-manage'].fullPath) && $hadrian.pages['account-contacts-manage'].fullPath && file_exists("templates/`$hadrian.pages['account-contacts-manage'].fullPath`")}
	{include file="`$hadrian.pages['account-contacts-manage'].fullPath`"}
{else}
	{include file="`$template`/core/pages/account-contacts-manage/default/default.tpl"}
{/if}
