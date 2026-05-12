{if isset($myTheme.pages['access-denied'].fullPath) && $myTheme.pages['access-denied'].fullPath && file_exists("templates/`$myTheme.pages['access-denied'].fullPath`")}
	{include file="`$myTheme.pages['access-denied'].fullPath`"}
{else}
	{include file="`$template`/core/pages/access-denied/default/default.tpl"}
{/if}
