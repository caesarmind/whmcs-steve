{if isset($hadrian.pages.downloaddenied.fullPath) && $hadrian.pages.downloaddenied.fullPath && file_exists("templates/`$hadrian.pages.downloaddenied.fullPath`")}
	{include file="`$hadrian.pages.downloaddenied.fullPath`"}
{else}
	{include file="`$template`/core/pages/downloaddenied/default/default.tpl"}
{/if}
