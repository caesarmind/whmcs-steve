{if isset($hadrian.pages.upgradesummary.fullPath) && $hadrian.pages.upgradesummary.fullPath && file_exists("templates/`$hadrian.pages.upgradesummary.fullPath`")}
	{include file="`$hadrian.pages.upgradesummary.fullPath`"}
{else}
	{include file="`$template`/core/pages/upgradesummary/default/default.tpl"}
{/if}
