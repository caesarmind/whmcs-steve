{if isset($myTheme.pages.viewticket.fullPath) && $myTheme.pages.viewticket.fullPath && file_exists("templates/`$myTheme.pages.viewticket.fullPath`")}
	{include file="`$myTheme.pages.viewticket.fullPath`"}
{else}
	{include file="`$template`/core/pages/viewticket/default/default.tpl"}
{/if}
