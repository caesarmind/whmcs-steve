{if isset($myTheme.pages.banned.fullPath) && $myTheme.pages.banned.fullPath && file_exists("templates/`$myTheme.pages.banned.fullPath`")}
	{include file="`$myTheme.pages.banned.fullPath`"}
{else}
	{include file="`$template`/core/pages/banned/default/default.tpl"}
{/if}
