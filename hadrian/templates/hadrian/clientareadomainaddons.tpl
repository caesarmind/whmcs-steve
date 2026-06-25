{if isset($hadrian.pages.clientareadomainaddons.fullPath) && $hadrian.pages.clientareadomainaddons.fullPath && file_exists("templates/`$hadrian.pages.clientareadomainaddons.fullPath`")}
	{include file="`$hadrian.pages.clientareadomainaddons.fullPath`"}
{else}
	{include file="`$template`/core/pages/clientareadomainaddons/default/default.tpl"}
{/if}
