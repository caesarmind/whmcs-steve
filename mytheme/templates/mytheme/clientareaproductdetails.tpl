{if isset($myTheme.pages.clientareaproductdetails.fullPath) && $myTheme.pages.clientareaproductdetails.fullPath && file_exists("templates/`$myTheme.pages.clientareaproductdetails.fullPath`")}
	{include file="`$myTheme.pages.clientareaproductdetails.fullPath`"}
{else}
	{include file="`$template`/core/pages/clientareaproductdetails/default/default.tpl"}
{/if}
