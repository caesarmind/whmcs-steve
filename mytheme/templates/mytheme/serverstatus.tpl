{if isset($myTheme.pages.serverstatus.fullPath) && $myTheme.pages.serverstatus.fullPath && file_exists("templates/`$myTheme.pages.serverstatus.fullPath`")}
	{include file="`$myTheme.pages.serverstatus.fullPath`"}
{else}
	{include file="`$template`/core/pages/serverstatus/default/default.tpl"}
{/if}
