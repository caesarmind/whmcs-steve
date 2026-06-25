{if isset($hadrian.pages['supportticketsubmit-confirm'].fullPath) && $hadrian.pages['supportticketsubmit-confirm'].fullPath && file_exists("templates/`$hadrian.pages['supportticketsubmit-confirm'].fullPath`")}
	{include file="`$hadrian.pages['supportticketsubmit-confirm'].fullPath`"}
{else}
	{include file="`$template`/core/pages/supportticketsubmit-confirm/default/default.tpl"}
{/if}
