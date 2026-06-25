{if isset($hadrian.pages.viewticket.fullPath) && $hadrian.pages.viewticket.fullPath && file_exists("templates/`$hadrian.pages.viewticket.fullPath`")}
	{include file="`$hadrian.pages.viewticket.fullPath`"}
{else}
	{include file="`$template`/core/pages/viewticket/default/default.tpl"}
{/if}
