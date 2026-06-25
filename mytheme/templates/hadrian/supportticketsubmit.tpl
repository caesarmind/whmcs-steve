{if isset($hadrian.pages.supportticketsubmit.fullPath) && $hadrian.pages.supportticketsubmit.fullPath && file_exists("templates/`$hadrian.pages.supportticketsubmit.fullPath`")}
	{include file="`$hadrian.pages.supportticketsubmit.fullPath`"}
{else}
	{include file="`$template`/core/pages/supportticketsubmit/default/default.tpl"}
{/if}
