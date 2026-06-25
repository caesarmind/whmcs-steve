{if isset($hadrian.pages['supportticketsubmit-steptwo'].fullPath) && $hadrian.pages['supportticketsubmit-steptwo'].fullPath && file_exists("templates/`$hadrian.pages['supportticketsubmit-steptwo'].fullPath`")}
	{include file="`$hadrian.pages['supportticketsubmit-steptwo'].fullPath`"}
{else}
	{include file="`$template`/core/pages/supportticketsubmit-steptwo/default/default.tpl"}
{/if}
