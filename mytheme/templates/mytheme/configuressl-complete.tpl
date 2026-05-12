{if isset($myTheme.pages['configuressl-complete'].fullPath) && $myTheme.pages['configuressl-complete'].fullPath && file_exists("templates/`$myTheme.pages['configuressl-complete'].fullPath`")}
	{include file="`$myTheme.pages['configuressl-complete'].fullPath`"}
{else}
	{include file="`$template`/core/pages/configuressl-complete/default/default.tpl"}
{/if}
