{if isset($hadrian.pages.clientareaproducts.fullPath) && $hadrian.pages.clientareaproducts.fullPath && file_exists("templates/`$hadrian.pages.clientareaproducts.fullPath`")}
	{include file="`$hadrian.pages.clientareaproducts.fullPath`"}
{else}
	{include file="`$template`/core/pages/clientareaproducts/default/default.tpl"}
{/if}
