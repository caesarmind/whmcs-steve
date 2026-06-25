{if isset($hadrian.pages['user-password'].fullPath) && $hadrian.pages['user-password'].fullPath && file_exists("templates/`$hadrian.pages['user-password'].fullPath`")}
	{include file="`$hadrian.pages['user-password'].fullPath`"}
{else}
	{include file="`$template`/core/pages/user-password/default/default.tpl"}
{/if}
