{if isset($myTheme.pages['password-reset-email-prompt'].fullPath) && $myTheme.pages['password-reset-email-prompt'].fullPath && file_exists("templates/`$myTheme.pages['password-reset-email-prompt'].fullPath`")}
	{include file="`$myTheme.pages['password-reset-email-prompt'].fullPath`"}
{else}
	{include file="`$template`/core/pages/password-reset-email-prompt/default/default.tpl"}
{/if}
