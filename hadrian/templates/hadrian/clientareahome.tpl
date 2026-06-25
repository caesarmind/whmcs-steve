{if isset($hadrian.pages.clientareahome.fullPath) && $hadrian.pages.clientareahome.fullPath && file_exists("templates/`$hadrian.pages.clientareahome.fullPath`")}
	{include file="`$hadrian.pages.clientareahome.fullPath`"}
{else}
	{include file="`$template`/core/pages/clientareahome/default/default.tpl"}
{/if}
