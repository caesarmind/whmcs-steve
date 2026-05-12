{if isset($myTheme.pages['supportticketsubmit-customfields'].fullPath) && $myTheme.pages['supportticketsubmit-customfields'].fullPath && file_exists("templates/`$myTheme.pages['supportticketsubmit-customfields'].fullPath`")}
	{include file="`$myTheme.pages['supportticketsubmit-customfields'].fullPath`"}
{else}
	{include file="`$template`/core/pages/supportticketsubmit-customfields/default/default.tpl"}
{/if}
