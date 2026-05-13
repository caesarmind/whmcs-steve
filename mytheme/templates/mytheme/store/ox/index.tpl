{if isset($myTheme.pages['store-ox'].fullPath) && $myTheme.pages['store-ox'].fullPath && file_exists("templates/`$myTheme.pages['store-ox'].fullPath`")}
	{include file="`$myTheme.pages['store-ox'].fullPath`"}
{else}
	{include file="`$template`/core/pages/store-ox/default/default.tpl"}
{/if}
