{if isset($myTheme.pages['subscription-manage'].fullPath) && $myTheme.pages['subscription-manage'].fullPath && file_exists("templates/`$myTheme.pages['subscription-manage'].fullPath`")}
	{include file="`$myTheme.pages['subscription-manage'].fullPath`"}
{else}
	{include file="`$template`/core/pages/subscription-manage/default/default.tpl"}
{/if}
