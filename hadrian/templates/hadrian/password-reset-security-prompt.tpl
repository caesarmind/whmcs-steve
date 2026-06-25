{if isset($hadrian.pages['password-reset-security-prompt'].fullPath) && $hadrian.pages['password-reset-security-prompt'].fullPath && file_exists("templates/`$hadrian.pages['password-reset-security-prompt'].fullPath`")}
	{include file="`$hadrian.pages['password-reset-security-prompt'].fullPath`"}
{else}
	{include file="`$template`/core/pages/password-reset-security-prompt/default/default.tpl"}
{/if}
