{if isset($myTheme.pages.3dsecure.fullPath) && $myTheme.pages.3dsecure.fullPath && file_exists("templates/`$myTheme.pages.3dsecure.fullPath`")}
	{include file="`$myTheme.pages.3dsecure.fullPath`"}
{else}
	{include file="`$template`/core/pages/3dsecure/default/default.tpl"}
{/if}
