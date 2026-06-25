{if isset($hadrian.pages['configuressl-stepone'].fullPath) && $hadrian.pages['configuressl-stepone'].fullPath && file_exists("templates/`$hadrian.pages['configuressl-stepone'].fullPath`")}
	{include file="`$hadrian.pages['configuressl-stepone'].fullPath`"}
{else}
	{include file="`$template`/core/pages/configuressl-stepone/default/default.tpl"}
{/if}
