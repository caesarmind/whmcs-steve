{if isset($myTheme.pages.user-security.fullPath) && $myTheme.pages.user-security.fullPath && file_exists("templates/`$myTheme.pages.user-security.fullPath`")}
	{include file="`$myTheme.pages.user-security.fullPath`"}
{else}
	{include file="`$template`/core/pages/user-security/default/default.tpl"}
{/if}
