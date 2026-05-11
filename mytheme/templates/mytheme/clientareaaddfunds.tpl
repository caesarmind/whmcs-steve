{if isset($myTheme.pages.clientareaaddfunds.fullPath) && $myTheme.pages.clientareaaddfunds.fullPath && file_exists("templates/`$myTheme.pages.clientareaaddfunds.fullPath`")}
	{include file="`$myTheme.pages.clientareaaddfunds.fullPath`"}
{else}
	{include file="`$template`/core/pages/clientareaaddfunds/default/default.tpl"}
{/if}
