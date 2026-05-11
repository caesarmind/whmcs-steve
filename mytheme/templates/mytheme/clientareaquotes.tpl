{if isset($myTheme.pages.clientareaquotes.fullPath) && $myTheme.pages.clientareaquotes.fullPath && file_exists("templates/`$myTheme.pages.clientareaquotes.fullPath`")}
	{include file="`$myTheme.pages.clientareaquotes.fullPath`"}
{else}
	{include file="`$template`/core/pages/clientareaquotes/default/default.tpl"}
{/if}
