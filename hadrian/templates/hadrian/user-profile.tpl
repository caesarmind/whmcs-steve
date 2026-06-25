{if isset($hadrian.pages['user-profile'].fullPath) && $hadrian.pages['user-profile'].fullPath && file_exists("templates/`$hadrian.pages['user-profile'].fullPath`")}
	{include file="`$hadrian.pages['user-profile'].fullPath`"}
{else}
	{include file="`$template`/core/pages/user-profile/default/default.tpl"}
{/if}
