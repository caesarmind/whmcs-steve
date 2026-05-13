{if isset($myTheme.pages['password-reset-change-prompt'].fullPath) && $myTheme.pages['password-reset-change-prompt'].fullPath && file_exists("templates/`$myTheme.pages['password-reset-change-prompt'].fullPath`")}
	{include file="`$myTheme.pages['password-reset-change-prompt'].fullPath`"}
{else}
	{include file="`$template`/core/pages/password-reset-change-prompt/default/default.tpl"}
{/if}
