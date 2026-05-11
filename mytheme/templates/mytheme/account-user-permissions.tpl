{if isset($myTheme.pages.account-user-permissions.fullPath) && $myTheme.pages.account-user-permissions.fullPath && file_exists("templates/`$myTheme.pages.account-user-permissions.fullPath`")}
	{include file="`$myTheme.pages.account-user-permissions.fullPath`"}
{else}
	{include file="`$template`/core/pages/account-user-permissions/default/default.tpl"}
{/if}
