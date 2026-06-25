{if isset($hadrian.pages.clientareadomaindns.fullPath) && $hadrian.pages.clientareadomaindns.fullPath && file_exists("templates/`$hadrian.pages.clientareadomaindns.fullPath`")}
	{include file="`$hadrian.pages.clientareadomaindns.fullPath`"}
{else}
	{include file="`$template`/core/pages/clientareadomaindns/default/default.tpl"}
{/if}
