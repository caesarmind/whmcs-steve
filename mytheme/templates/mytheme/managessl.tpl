{if isset($myTheme.pages.managessl.fullPath) && $myTheme.pages.managessl.fullPath && file_exists("templates/`$myTheme.pages.managessl.fullPath`")}
	{include file="`$myTheme.pages.managessl.fullPath`"}
{else}
	{include file="`$template`/core/pages/managessl/default/default.tpl"}
{/if}
