{if isset($myTheme.pages.viewquote.fullPath) && $myTheme.pages.viewquote.fullPath && file_exists("templates/`$myTheme.pages.viewquote.fullPath`")}
	{include file="`$myTheme.pages.viewquote.fullPath`"}
{else}
	{include file="`$template`/core/pages/viewquote/default/default.tpl"}
{/if}
