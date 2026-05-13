{if isset($myTheme.pages['store-ssl'].fullPath) && $myTheme.pages['store-ssl'].fullPath && file_exists("templates/`$myTheme.pages['store-ssl'].fullPath`")}
	{include file="`$myTheme.pages['store-ssl'].fullPath`"}
{else}
	{include file="`$template`/core/pages/store-ssl/default/default.tpl"}
{/if}
