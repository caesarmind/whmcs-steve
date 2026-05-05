{if isset($myTheme.pages.clientareaproducts.fullPath) && $myTheme.pages.clientareaproducts.fullPath && file_exists("templates/`$myTheme.pages.clientareaproducts.fullPath`")}
	{include file="`$myTheme.pages.clientareaproducts.fullPath`"}
{else}
	{include file="`$template`/core/pages/clientareaproducts/default/default.tpl"}
{/if}
