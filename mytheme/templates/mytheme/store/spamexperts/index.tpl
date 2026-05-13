{if isset($myTheme.pages['store-spamexperts'].fullPath) && $myTheme.pages['store-spamexperts'].fullPath && file_exists("templates/`$myTheme.pages['store-spamexperts'].fullPath`")}
	{include file="`$myTheme.pages['store-spamexperts'].fullPath`"}
{else}
	{include file="`$template`/core/pages/store-spamexperts/default/default.tpl"}
{/if}
