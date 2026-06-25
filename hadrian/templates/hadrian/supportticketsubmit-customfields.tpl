{if isset($hadrian.pages['supportticketsubmit-customfields'].fullPath) && $hadrian.pages['supportticketsubmit-customfields'].fullPath && file_exists("templates/`$hadrian.pages['supportticketsubmit-customfields'].fullPath`")}
	{include file="`$hadrian.pages['supportticketsubmit-customfields'].fullPath`"}
{else}
	{include file="`$template`/core/pages/supportticketsubmit-customfields/default/default.tpl"}
{/if}
