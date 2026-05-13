{if isset($myTheme.pages['supportticketsubmit-steptwo'].fullPath) && $myTheme.pages['supportticketsubmit-steptwo'].fullPath && file_exists("templates/`$myTheme.pages['supportticketsubmit-steptwo'].fullPath`")}
	{include file="`$myTheme.pages['supportticketsubmit-steptwo'].fullPath`"}
{else}
	{include file="`$template`/core/pages/supportticketsubmit-steptwo/default/default.tpl"}
{/if}
