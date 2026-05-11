{if isset($myTheme.pages.clientareadomaingetepp.fullPath) && $myTheme.pages.clientareadomaingetepp.fullPath && file_exists("templates/`$myTheme.pages.clientareadomaingetepp.fullPath`")}
	{include file="`$myTheme.pages.clientareadomaingetepp.fullPath`"}
{else}
	{include file="`$template`/core/pages/clientareadomaingetepp/default/default.tpl"}
{/if}
