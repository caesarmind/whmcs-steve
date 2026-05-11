{if isset($myTheme.pages.clientareacancelrequest.fullPath) && $myTheme.pages.clientareacancelrequest.fullPath && file_exists("templates/`$myTheme.pages.clientareacancelrequest.fullPath`")}
	{include file="`$myTheme.pages.clientareacancelrequest.fullPath`"}
{else}
	{include file="`$template`/core/pages/clientareacancelrequest/default/default.tpl"}
{/if}
