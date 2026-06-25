{if isset($hadrian.pages['supportticketsubmit-stepone'].fullPath) && $hadrian.pages['supportticketsubmit-stepone'].fullPath && file_exists("templates/`$hadrian.pages['supportticketsubmit-stepone'].fullPath`")}
	{include file="`$hadrian.pages['supportticketsubmit-stepone'].fullPath`"}
{else}
	{include file="`$template`/core/pages/supportticketsubmit-stepone/default/default.tpl"}
{/if}
