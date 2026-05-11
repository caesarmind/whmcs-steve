{if isset($myTheme.pages.configuressl-stepone.fullPath) && $myTheme.pages.configuressl-stepone.fullPath && file_exists("templates/`$myTheme.pages.configuressl-stepone.fullPath`")}
	{include file="`$myTheme.pages.configuressl-stepone.fullPath`"}
{else}
	{include file="`$template`/core/pages/configuressl-stepone/default/default.tpl"}
{/if}
