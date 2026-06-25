{if isset($hadrian.pages['password-reset-email-prompt'].fullPath) && $hadrian.pages['password-reset-email-prompt'].fullPath && file_exists("templates/`$hadrian.pages['password-reset-email-prompt'].fullPath`")}
	{include file="`$hadrian.pages['password-reset-email-prompt'].fullPath`"}
{else}
	{include file="`$template`/core/pages/password-reset-email-prompt/default/default.tpl"}
{/if}
