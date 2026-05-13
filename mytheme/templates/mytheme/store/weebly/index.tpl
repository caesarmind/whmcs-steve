{if isset($myTheme.pages['store-weebly'].fullPath) && $myTheme.pages['store-weebly'].fullPath && file_exists("templates/`$myTheme.pages['store-weebly'].fullPath`")}
	{include file="`$myTheme.pages['store-weebly'].fullPath`"}
{else}
	{include file="`$template`/core/pages/store-weebly/default/default.tpl"}
{/if}
