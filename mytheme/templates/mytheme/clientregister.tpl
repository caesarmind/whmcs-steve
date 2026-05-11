{if isset($myTheme.pages.clientregister.fullPath) && $myTheme.pages.clientregister.fullPath && file_exists("templates/`$myTheme.pages.clientregister.fullPath`")}
	{include file="`$myTheme.pages.clientregister.fullPath`"}
{else}
	{include file="`$template`/core/pages/clientregister/default/default.tpl"}
{/if}
