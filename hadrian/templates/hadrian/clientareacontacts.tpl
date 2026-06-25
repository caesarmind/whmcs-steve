{if isset($hadrian.pages.clientareacontacts.fullPath) && $hadrian.pages.clientareacontacts.fullPath && file_exists("templates/`$hadrian.pages.clientareacontacts.fullPath`")}
	{include file="`$hadrian.pages.clientareacontacts.fullPath`"}
{else}
	{include file="`$template`/core/pages/clientareacontacts/default/default.tpl"}
{/if}
