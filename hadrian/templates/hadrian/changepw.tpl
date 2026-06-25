{if isset($hadrian.pages.changepw.fullPath) && $hadrian.pages.changepw.fullPath && file_exists("templates/`$hadrian.pages.changepw.fullPath`")}
	{include file="`$hadrian.pages.changepw.fullPath`"}
{else}
	{include file="`$template`/core/pages/changepw/default/default.tpl"}
{/if}
