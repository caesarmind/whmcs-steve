{if isset($myTheme.pages['user-profile'].fullPath) && $myTheme.pages['user-profile'].fullPath && file_exists("templates/`$myTheme.pages['user-profile'].fullPath`")}
	{include file="`$myTheme.pages['user-profile'].fullPath`"}
{else}
	{include file="`$template`/core/pages/user-profile/default/default.tpl"}
{/if}
