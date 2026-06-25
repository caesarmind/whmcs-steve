{if isset($hadrian.pages.downloadscat.fullPath) && $hadrian.pages.downloadscat.fullPath && file_exists("templates/`$hadrian.pages.downloadscat.fullPath`")}
	{include file="`$hadrian.pages.downloadscat.fullPath`"}
{else}
	{include file="`$template`/core/pages/downloadscat/default/default.tpl"}
{/if}
