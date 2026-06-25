{if isset($hadrian.pages['configuressl-steptwo'].fullPath) && $hadrian.pages['configuressl-steptwo'].fullPath && file_exists("templates/`$hadrian.pages['configuressl-steptwo'].fullPath`")}
	{include file="`$hadrian.pages['configuressl-steptwo'].fullPath`"}
{else}
	{include file="`$template`/core/pages/configuressl-steptwo/default/default.tpl"}
{/if}
