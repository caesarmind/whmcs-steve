{if isset($hadrian.pages.clientareaquotes.fullPath) && $hadrian.pages.clientareaquotes.fullPath && file_exists("templates/`$hadrian.pages.clientareaquotes.fullPath`")}
	{include file="`$hadrian.pages.clientareaquotes.fullPath`"}
{else}
	{include file="`$template`/core/pages/clientareaquotes/default/default.tpl"}
{/if}
