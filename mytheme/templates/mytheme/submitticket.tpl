{if isset($myTheme.pages.submitticket.fullPath) && $myTheme.pages.submitticket.fullPath && file_exists("templates/`$myTheme.pages.submitticket.fullPath`")}
	{include file="`$myTheme.pages.submitticket.fullPath`"}
{else}
	{include file="`$template`/core/pages/submitticket/default/default.tpl"}
{/if}
