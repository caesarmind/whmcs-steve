{if isset($hadrian.pages.clientareadomaincontactinfo.fullPath) && $hadrian.pages.clientareadomaincontactinfo.fullPath && file_exists("templates/`$hadrian.pages.clientareadomaincontactinfo.fullPath`")}
	{include file="`$hadrian.pages.clientareadomaincontactinfo.fullPath`"}
{else}
	{include file="`$template`/core/pages/clientareadomaincontactinfo/default/default.tpl"}
{/if}
