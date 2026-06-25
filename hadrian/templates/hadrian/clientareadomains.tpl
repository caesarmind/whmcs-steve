{if isset($hadrian.pages.clientareadomains.fullPath) && $hadrian.pages.clientareadomains.fullPath && file_exists("templates/`$hadrian.pages.clientareadomains.fullPath`")}
	{include file="`$hadrian.pages.clientareadomains.fullPath`"}
{else}
	{include file="`$template`/core/pages/clientareadomains/default/default.tpl"}
{/if}
