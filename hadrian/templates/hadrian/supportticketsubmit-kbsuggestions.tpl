{if isset($hadrian.pages['supportticketsubmit-kbsuggestions'].fullPath) && $hadrian.pages['supportticketsubmit-kbsuggestions'].fullPath && file_exists("templates/`$hadrian.pages['supportticketsubmit-kbsuggestions'].fullPath`")}
	{include file="`$hadrian.pages['supportticketsubmit-kbsuggestions'].fullPath`"}
{else}
	{include file="`$template`/core/pages/supportticketsubmit-kbsuggestions/default/default.tpl"}
{/if}
