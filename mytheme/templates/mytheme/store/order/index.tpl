{if isset($myTheme.pages['store-order'].fullPath) && $myTheme.pages['store-order'].fullPath && file_exists("templates/`$myTheme.pages['store-order'].fullPath`")}
	{include file="`$myTheme.pages['store-order'].fullPath`"}
{else}
	{include file="`$template`/core/pages/store-order/default/default.tpl"}
{/if}
