{if isset($myTheme.pages['supportticketsubmit-kbsuggestions'].fullPath) && $myTheme.pages['supportticketsubmit-kbsuggestions'].fullPath && file_exists("templates/`$myTheme.pages['supportticketsubmit-kbsuggestions'].fullPath`")}
	{include file="`$myTheme.pages['supportticketsubmit-kbsuggestions'].fullPath`"}
{else}
	{include file="`$template`/core/pages/supportticketsubmit-kbsuggestions/default/default.tpl"}
{/if}
