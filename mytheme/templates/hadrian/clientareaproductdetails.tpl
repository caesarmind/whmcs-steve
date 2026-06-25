{if isset($hadrian.pages.clientareaproductdetails.fullPath) && $hadrian.pages.clientareaproductdetails.fullPath && file_exists("templates/`$hadrian.pages.clientareaproductdetails.fullPath`")}
	{include file="`$hadrian.pages.clientareaproductdetails.fullPath`"}
{else}
	{include file="`$template`/core/pages/clientareaproductdetails/default/default.tpl"}
{/if}
