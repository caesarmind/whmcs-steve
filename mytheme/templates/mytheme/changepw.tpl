{if isset($myTheme.pages.changepw.fullPath) && $myTheme.pages.changepw.fullPath && file_exists("templates/`$myTheme.pages.changepw.fullPath`")}
	{include file="`$myTheme.pages.changepw.fullPath`"}
{else}
	{include file="`$template`/core/pages/changepw/default/default.tpl"}
{/if}
