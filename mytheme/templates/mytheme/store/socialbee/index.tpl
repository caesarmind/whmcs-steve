{if isset($myTheme.pages['store-socialbee'].fullPath) && $myTheme.pages['store-socialbee'].fullPath && file_exists("templates/`$myTheme.pages['store-socialbee'].fullPath`")}
	{include file="`$myTheme.pages['store-socialbee'].fullPath`"}
{else}
	{include file="`$template`/core/pages/store-socialbee/default/default.tpl"}
{/if}
