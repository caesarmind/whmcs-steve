{if isset($hadrian.pages.supporttickets.fullPath) && $hadrian.pages.supporttickets.fullPath && file_exists("templates/`$hadrian.pages.supporttickets.fullPath`")}
	{include file="`$hadrian.pages.supporttickets.fullPath`"}
{else}
	{include file="`$template`/core/pages/supporttickets/default/default.tpl"}
{/if}
