{if isset($myTheme.pages.clientareahome.fullPath) && $myTheme.pages.clientareahome.fullPath && file_exists("templates/`$myTheme.pages.clientareahome.fullPath`")}
	{include file="`$myTheme.pages.clientareahome.fullPath`"}
{else}
	{include file="`$template`/core/pages/clientareahome/default/default.tpl"}
{/if}
