{if isset($hadrian.pages.viewemail.fullPath) && $hadrian.pages.viewemail.fullPath && file_exists("templates/`$hadrian.pages.viewemail.fullPath`")}
	{include file="`$hadrian.pages.viewemail.fullPath`"}
{else}
	{include file="`$template`/core/pages/viewemail/default/default.tpl"}
{/if}
