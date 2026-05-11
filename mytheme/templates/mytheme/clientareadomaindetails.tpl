{if isset($myTheme.pages.clientareadomaindetails.fullPath) && $myTheme.pages.clientareadomaindetails.fullPath && file_exists("templates/`$myTheme.pages.clientareadomaindetails.fullPath`")}
	{include file="`$myTheme.pages.clientareadomaindetails.fullPath`"}
{else}
	{include file="`$template`/core/pages/clientareadomaindetails/default/default.tpl"}
{/if}
