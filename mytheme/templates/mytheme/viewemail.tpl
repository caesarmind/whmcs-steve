{if isset($myTheme.pages.viewemail.fullPath) && $myTheme.pages.viewemail.fullPath && file_exists("templates/`$myTheme.pages.viewemail.fullPath`")}
	{include file="`$myTheme.pages.viewemail.fullPath`"}
{else}
	{include file="`$template`/core/pages/viewemail/default/default.tpl"}
{/if}
