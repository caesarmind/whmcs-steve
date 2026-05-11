{if isset($myTheme.pages.user-verify-email.fullPath) && $myTheme.pages.user-verify-email.fullPath && file_exists("templates/`$myTheme.pages.user-verify-email.fullPath`")}
	{include file="`$myTheme.pages.user-verify-email.fullPath`"}
{else}
	{include file="`$template`/core/pages/user-verify-email/default/default.tpl"}
{/if}
