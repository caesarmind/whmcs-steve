{if isset($myTheme.pages.clientareadomaindns.fullPath) && $myTheme.pages.clientareadomaindns.fullPath && file_exists("templates/`$myTheme.pages.clientareadomaindns.fullPath`")}
	{include file="`$myTheme.pages.clientareadomaindns.fullPath`"}
{else}
	{include file="`$template`/core/pages/clientareadomaindns/default/default.tpl"}
{/if}
