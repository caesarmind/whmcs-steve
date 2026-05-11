{if isset($myTheme.pages.pwreset.fullPath) && $myTheme.pages.pwreset.fullPath && file_exists("templates/`$myTheme.pages.pwreset.fullPath`")}
	{include file="`$myTheme.pages.pwreset.fullPath`"}
{else}
	{include file="`$template`/core/pages/pwreset/default/default.tpl"}
{/if}
