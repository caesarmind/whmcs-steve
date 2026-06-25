{if isset($hadrian.pages['configuressl-complete'].fullPath) && $hadrian.pages['configuressl-complete'].fullPath && file_exists("templates/`$hadrian.pages['configuressl-complete'].fullPath`")}
	{include file="`$hadrian.pages['configuressl-complete'].fullPath`"}
{else}
	{include file="`$template`/core/pages/configuressl-complete/default/default.tpl"}
{/if}
