{if isset($hadrian.pages['account-contacts-new'].fullPath) && $hadrian.pages['account-contacts-new'].fullPath && file_exists("templates/`$hadrian.pages['account-contacts-new'].fullPath`")}
	{include file="`$hadrian.pages['account-contacts-new'].fullPath`"}
{else}
	{include file="`$template`/core/pages/account-contacts-new/default/default.tpl"}
{/if}
