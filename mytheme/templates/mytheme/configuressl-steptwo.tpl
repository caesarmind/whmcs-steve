{if isset($myTheme.pages.configuressl-steptwo.fullPath) && $myTheme.pages.configuressl-steptwo.fullPath && file_exists("templates/`$myTheme.pages.configuressl-steptwo.fullPath`")}
	{include file="`$myTheme.pages.configuressl-steptwo.fullPath`"}
{else}
	{include file="`$template`/core/pages/configuressl-steptwo/default/default.tpl"}
{/if}
