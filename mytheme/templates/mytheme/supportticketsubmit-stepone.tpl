{if isset($myTheme.pages['supportticketsubmit-stepone'].fullPath) && $myTheme.pages['supportticketsubmit-stepone'].fullPath && file_exists("templates/`$myTheme.pages['supportticketsubmit-stepone'].fullPath`")}
	{include file="`$myTheme.pages['supportticketsubmit-stepone'].fullPath`"}
{else}
	{include file="`$template`/core/pages/supportticketsubmit-stepone/default/default.tpl"}
{/if}
