{if isset($hadrian.pages.3dsecure.fullPath) && $hadrian.pages.3dsecure.fullPath && file_exists("templates/`$hadrian.pages.3dsecure.fullPath`")}
	{include file="`$hadrian.pages.3dsecure.fullPath`"}
{else}
	{include file="`$template`/core/pages/3dsecure/default/default.tpl"}
{/if}
