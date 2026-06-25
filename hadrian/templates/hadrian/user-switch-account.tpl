{if isset($hadrian.pages['user-switch-account'].fullPath) && $hadrian.pages['user-switch-account'].fullPath && file_exists("templates/`$hadrian.pages['user-switch-account'].fullPath`")}
	{include file="`$hadrian.pages['user-switch-account'].fullPath`"}
{else}
	{include file="`$template`/core/pages/user-switch-account/default/default.tpl"}
{/if}
