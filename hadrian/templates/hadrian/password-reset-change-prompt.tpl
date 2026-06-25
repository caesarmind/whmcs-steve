{if isset($hadrian.pages['password-reset-change-prompt'].fullPath) && $hadrian.pages['password-reset-change-prompt'].fullPath && file_exists("templates/`$hadrian.pages['password-reset-change-prompt'].fullPath`")}
	{include file="`$hadrian.pages['password-reset-change-prompt'].fullPath`"}
{else}
	{include file="`$template`/core/pages/password-reset-change-prompt/default/default.tpl"}
{/if}
