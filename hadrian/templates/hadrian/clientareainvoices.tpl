{if isset($hadrian.pages.clientareainvoices.fullPath) && $hadrian.pages.clientareainvoices.fullPath && file_exists("templates/`$hadrian.pages.clientareainvoices.fullPath`")}
	{include file="`$hadrian.pages.clientareainvoices.fullPath`"}
{else}
	{include file="`$template`/core/pages/clientareainvoices/default/default.tpl"}
{/if}
