{if isset($hadrian.pages.clientareadomaindetails.fullPath) && $hadrian.pages.clientareadomaindetails.fullPath && file_exists("templates/`$hadrian.pages.clientareadomaindetails.fullPath`")}
	{include file="`$hadrian.pages.clientareadomaindetails.fullPath`"}
{else}
	{include file="`$template`/core/pages/clientareadomaindetails/default/default.tpl"}
{/if}
