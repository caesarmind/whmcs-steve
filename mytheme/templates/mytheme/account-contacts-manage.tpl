{if isset($myTheme.pages['account-contacts-manage'].fullPath) && $myTheme.pages['account-contacts-manage'].fullPath && file_exists("templates/`$myTheme.pages['account-contacts-manage'].fullPath`")}
	{include file="`$myTheme.pages['account-contacts-manage'].fullPath`"}
{else}
	{include file="`$template`/core/pages/account-contacts-manage/default/default.tpl"}
{/if}
