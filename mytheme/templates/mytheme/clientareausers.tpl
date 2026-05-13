{if isset($myTheme.pages.clientareausers.fullPath) && $myTheme.pages.clientareausers.fullPath && file_exists("templates/`$myTheme.pages.clientareausers.fullPath`")}
	{include file="`$myTheme.pages.clientareausers.fullPath`"}
{else}
	{include file="`$template`/core/pages/clientareausers/default/default.tpl"}
{/if}
