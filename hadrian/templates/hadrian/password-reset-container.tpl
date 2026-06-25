{if isset($hadrian.pages['password-reset-container'].fullPath) && $hadrian.pages['password-reset-container'].fullPath && file_exists("templates/`$hadrian.pages['password-reset-container'].fullPath`")}
	{include file="`$hadrian.pages['password-reset-container'].fullPath`"}
{else}
	{include file="`$template`/core/pages/password-reset-container/default/default.tpl"}
{/if}
