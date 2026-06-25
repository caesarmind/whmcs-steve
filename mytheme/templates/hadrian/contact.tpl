{if isset($hadrian.pages.contact.fullPath) && $hadrian.pages.contact.fullPath && file_exists("templates/`$hadrian.pages.contact.fullPath`")}
	{include file="`$hadrian.pages.contact.fullPath`"}
{else}
	{include file="`$template`/core/pages/contact/default/default.tpl"}
{/if}
