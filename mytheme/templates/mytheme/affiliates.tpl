{if isset($myTheme.pages.affiliates.fullPath) && $myTheme.pages.affiliates.fullPath && file_exists("templates/`$myTheme.pages.affiliates.fullPath`")}
	{include file="`$myTheme.pages.affiliates.fullPath`"}
{else}
	{include file="`$template`/core/pages/affiliates/default/default.tpl"}
{/if}
