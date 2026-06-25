{if isset($hadrian.pages['user-verify-email'].fullPath) && $hadrian.pages['user-verify-email'].fullPath && file_exists("templates/`$hadrian.pages['user-verify-email'].fullPath`")}
	{include file="`$hadrian.pages['user-verify-email'].fullPath`"}
{else}
	{include file="`$template`/core/pages/user-verify-email/default/default.tpl"}
{/if}
