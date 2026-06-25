{if isset($hadrian.pages.affiliates.fullPath) && $hadrian.pages.affiliates.fullPath && file_exists("templates/`$hadrian.pages.affiliates.fullPath`")}
	{include file="`$hadrian.pages.affiliates.fullPath`"}
{else}
	{include file="`$template`/core/pages/affiliates/default/default.tpl"}
{/if}
