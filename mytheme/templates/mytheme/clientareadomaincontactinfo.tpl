{if isset($myTheme.pages.clientareadomaincontactinfo.fullPath) && $myTheme.pages.clientareadomaincontactinfo.fullPath && file_exists("templates/`$myTheme.pages.clientareadomaincontactinfo.fullPath`")}
	{include file="`$myTheme.pages.clientareadomaincontactinfo.fullPath`"}
{else}
	{include file="`$template`/core/pages/clientareadomaincontactinfo/default/default.tpl"}
{/if}
