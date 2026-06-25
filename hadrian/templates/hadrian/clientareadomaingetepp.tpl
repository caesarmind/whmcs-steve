{if isset($hadrian.pages.clientareadomaingetepp.fullPath) && $hadrian.pages.clientareadomaingetepp.fullPath && file_exists("templates/`$hadrian.pages.clientareadomaingetepp.fullPath`")}
	{include file="`$hadrian.pages.clientareadomaingetepp.fullPath`"}
{else}
	{include file="`$template`/core/pages/clientareadomaingetepp/default/default.tpl"}
{/if}
