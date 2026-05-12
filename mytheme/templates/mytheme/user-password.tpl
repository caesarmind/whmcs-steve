{if isset($myTheme.pages['user-password'].fullPath) && $myTheme.pages['user-password'].fullPath && file_exists("templates/`$myTheme.pages['user-password'].fullPath`")}
	{include file="`$myTheme.pages['user-password'].fullPath`"}
{else}
	{include file="`$template`/core/pages/user-password/default/default.tpl"}
{/if}
