{if isset($myTheme.pages.login.fullPath) && $myTheme.pages.login.fullPath && file_exists("templates/`$myTheme.pages.login.fullPath`")}
	{include file="`$myTheme.pages.login.fullPath`"}
{else}
	{include file="`$template`/core/pages/login/default/default.tpl"}
{/if}
