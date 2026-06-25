{if isset($hadrian.pages.login.fullPath) && $hadrian.pages.login.fullPath && file_exists("templates/`$hadrian.pages.login.fullPath`")}
	{include file="`$hadrian.pages.login.fullPath`"}
{else}
	{include file="`$template`/core/pages/login/default/default.tpl"}
{/if}
