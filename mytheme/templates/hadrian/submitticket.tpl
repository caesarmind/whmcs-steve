{if isset($hadrian.pages.submitticket.fullPath) && $hadrian.pages.submitticket.fullPath && file_exists("templates/`$hadrian.pages.submitticket.fullPath`")}
	{include file="`$hadrian.pages.submitticket.fullPath`"}
{else}
	{include file="`$template`/core/pages/submitticket/default/default.tpl"}
{/if}
