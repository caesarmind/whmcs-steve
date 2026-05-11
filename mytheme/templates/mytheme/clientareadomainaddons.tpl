{if isset($myTheme.pages.clientareadomainaddons.fullPath) && $myTheme.pages.clientareadomainaddons.fullPath && file_exists("templates/`$myTheme.pages.clientareadomainaddons.fullPath`")}
	{include file="`$myTheme.pages.clientareadomainaddons.fullPath`"}
{else}
	{include file="`$template`/core/pages/clientareadomainaddons/default/default.tpl"}
{/if}
