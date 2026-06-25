{if isset($hadrian.pages.affiliatessignup.fullPath) && $hadrian.pages.affiliatessignup.fullPath && file_exists("templates/`$hadrian.pages.affiliatessignup.fullPath`")}
	{include file="`$hadrian.pages.affiliatessignup.fullPath`"}
{else}
	{include file="`$template`/core/pages/affiliatessignup/default/default.tpl"}
{/if}
