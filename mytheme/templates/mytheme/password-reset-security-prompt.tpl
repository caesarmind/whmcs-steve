{if isset($myTheme.pages['password-reset-security-prompt'].fullPath) && $myTheme.pages['password-reset-security-prompt'].fullPath && file_exists("templates/`$myTheme.pages['password-reset-security-prompt'].fullPath`")}
	{include file="`$myTheme.pages['password-reset-security-prompt'].fullPath`"}
{else}
	{include file="`$template`/core/pages/password-reset-security-prompt/default/default.tpl"}
{/if}
