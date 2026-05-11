{if isset($myTheme.pages.account-user-management.fullPath) && $myTheme.pages.account-user-management.fullPath && file_exists("templates/`$myTheme.pages.account-user-management.fullPath`")}
	{include file="`$myTheme.pages.account-user-management.fullPath`"}
{else}
	{include file="`$template`/core/pages/account-user-management/default/default.tpl"}
{/if}
