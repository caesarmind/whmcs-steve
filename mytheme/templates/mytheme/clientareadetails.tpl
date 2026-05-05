{if isset($myTheme.pages.clientareadetails.fullPath) && $myTheme.pages.clientareadetails.fullPath && file_exists("templates/`$myTheme.pages.clientareadetails.fullPath`")}
	{include file="`$myTheme.pages.clientareadetails.fullPath`"}
{else}
	{include file="`$template`/core/pages/clientareadetails/default/default.tpl"}
{/if}
