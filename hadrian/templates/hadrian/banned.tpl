{if isset($hadrian.pages.banned.fullPath) && $hadrian.pages.banned.fullPath && file_exists("templates/`$hadrian.pages.banned.fullPath`")}
	{include file="`$hadrian.pages.banned.fullPath`"}
{else}
	{include file="`$template`/core/pages/banned/default/default.tpl"}
{/if}
