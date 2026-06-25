{if isset($hadrian.pages.clientareadetails.fullPath) && $hadrian.pages.clientareadetails.fullPath && file_exists("templates/`$hadrian.pages.clientareadetails.fullPath`")}
	{include file="`$hadrian.pages.clientareadetails.fullPath`"}
{else}
	{include file="`$template`/core/pages/clientareadetails/default/default.tpl"}
{/if}
