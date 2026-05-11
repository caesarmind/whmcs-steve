{if isset($myTheme.pages.clientareaemails.fullPath) && $myTheme.pages.clientareaemails.fullPath && file_exists("templates/`$myTheme.pages.clientareaemails.fullPath`")}
	{include file="`$myTheme.pages.clientareaemails.fullPath`"}
{else}
	{include file="`$template`/core/pages/clientareaemails/default/default.tpl"}
{/if}
