{if isset($myTheme.pages.contact.fullPath) && $myTheme.pages.contact.fullPath && file_exists("templates/`$myTheme.pages.contact.fullPath`")}
	{include file="`$myTheme.pages.contact.fullPath`"}
{else}
	{include file="`$template`/core/pages/contact/default/default.tpl"}
{/if}
