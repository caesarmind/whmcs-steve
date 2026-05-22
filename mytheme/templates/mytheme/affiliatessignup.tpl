{if isset($myTheme.pages.affiliatessignup.fullPath) && $myTheme.pages.affiliatessignup.fullPath && file_exists("templates/`$myTheme.pages.affiliatessignup.fullPath`")}
	{include file="`$myTheme.pages.affiliatessignup.fullPath`"}
{else}
	{include file="`$template`/core/pages/affiliatessignup/default/default.tpl"}
{/if}
