{if isset($myTheme.pages.changepassword.fullPath) && $myTheme.pages.changepassword.fullPath && file_exists("templates/`$myTheme.pages.changepassword.fullPath`")}
	{include file="`$myTheme.pages.changepassword.fullPath`"}
{else}
	{include file="`$template`/core/pages/changepassword/default/default.tpl"}
{/if}
