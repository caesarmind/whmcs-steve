{if isset($myTheme.pages.clientareacontacts.fullPath) && $myTheme.pages.clientareacontacts.fullPath && file_exists("templates/`$myTheme.pages.clientareacontacts.fullPath`")}
	{include file="`$myTheme.pages.clientareacontacts.fullPath`"}
{else}
	{include file="`$template`/core/pages/clientareacontacts/default/default.tpl"}
{/if}
