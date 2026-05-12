{if isset($myTheme.pages['account-contacts-new'].fullPath) && $myTheme.pages['account-contacts-new'].fullPath && file_exists("templates/`$myTheme.pages['account-contacts-new'].fullPath`")}
	{include file="`$myTheme.pages['account-contacts-new'].fullPath`"}
{else}
	{include file="`$template`/core/pages/account-contacts-new/default/default.tpl"}
{/if}
