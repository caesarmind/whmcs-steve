{if isset($hadrian.pages.downloads.fullPath) && $hadrian.pages.downloads.fullPath && file_exists("templates/`$hadrian.pages.downloads.fullPath`")}
	{include file="`$hadrian.pages.downloads.fullPath`"}
{else}
	{include file="`$template`/core/pages/downloads/default/default.tpl"}
{/if}
