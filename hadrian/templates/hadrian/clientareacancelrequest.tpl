{if isset($hadrian.pages.clientareacancelrequest.fullPath) && $hadrian.pages.clientareacancelrequest.fullPath && file_exists("templates/`$hadrian.pages.clientareacancelrequest.fullPath`")}
	{include file="`$hadrian.pages.clientareacancelrequest.fullPath`"}
{else}
	{include file="`$template`/core/pages/clientareacancelrequest/default/default.tpl"}
{/if}
