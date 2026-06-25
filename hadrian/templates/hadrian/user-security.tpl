{if isset($hadrian.pages['user-security'].fullPath) && $hadrian.pages['user-security'].fullPath && file_exists("templates/`$hadrian.pages['user-security'].fullPath`")}
	{include file="`$hadrian.pages['user-security'].fullPath`"}
{else}
	{include file="`$template`/core/pages/user-security/default/default.tpl"}
{/if}
