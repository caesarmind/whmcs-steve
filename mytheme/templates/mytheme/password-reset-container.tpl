{if isset($myTheme.pages['password-reset-container'].fullPath) && $myTheme.pages['password-reset-container'].fullPath && file_exists("templates/`$myTheme.pages['password-reset-container'].fullPath`")}
	{include file="`$myTheme.pages['password-reset-container'].fullPath`"}
{else}
	{include file="`$template`/core/pages/password-reset-container/default/default.tpl"}
{/if}
