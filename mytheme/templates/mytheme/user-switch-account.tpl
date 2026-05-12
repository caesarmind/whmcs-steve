{if isset($myTheme.pages.user-switch-account.fullPath) && $myTheme.pages.user-switch-account.fullPath && file_exists("templates/`$myTheme.pages.user-switch-account.fullPath`")}
	{include file="`$myTheme.pages.user-switch-account.fullPath`"}
{else}
	{include file="`$template`/core/pages/user-switch-account/default/default.tpl"}
{/if}
