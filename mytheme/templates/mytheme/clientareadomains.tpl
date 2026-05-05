{if isset($myTheme.pages.clientareadomains.fullPath) && $myTheme.pages.clientareadomains.fullPath && file_exists("templates/`$myTheme.pages.clientareadomains.fullPath`")}
	{include file="`$myTheme.pages.clientareadomains.fullPath`"}
{else}
	{include file="`$template`/core/pages/clientareadomains/default/default.tpl"}
{/if}
