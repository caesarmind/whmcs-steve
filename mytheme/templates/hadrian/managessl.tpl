{if isset($hadrian.pages.managessl.fullPath) && $hadrian.pages.managessl.fullPath && file_exists("templates/`$hadrian.pages.managessl.fullPath`")}
	{include file="`$hadrian.pages.managessl.fullPath`"}
{else}
	{include file="`$template`/core/pages/managessl/default/default.tpl"}
{/if}
