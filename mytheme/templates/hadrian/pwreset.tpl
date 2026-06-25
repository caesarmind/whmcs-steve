{if isset($hadrian.pages.pwreset.fullPath) && $hadrian.pages.pwreset.fullPath && file_exists("templates/`$hadrian.pages.pwreset.fullPath`")}
	{include file="`$hadrian.pages.pwreset.fullPath`"}
{else}
	{include file="`$template`/core/pages/pwreset/default/default.tpl"}
{/if}
