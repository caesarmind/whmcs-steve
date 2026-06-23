{if isset($myTheme.pages['store-xovinow'].fullPath) && $myTheme.pages['store-xovinow'].fullPath && file_exists("templates/`$myTheme.pages['store-xovinow'].fullPath`")}
	{include file="`$myTheme.pages['store-xovinow'].fullPath`"}
{else}
	{include file="`$template`/core/pages/store-xovinow/default/default.tpl"}
{/if}
