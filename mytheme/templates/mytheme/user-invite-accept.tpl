{if isset($myTheme.pages['user-invite-accept'].fullPath) && $myTheme.pages['user-invite-accept'].fullPath && file_exists("templates/`$myTheme.pages['user-invite-accept'].fullPath`")}
	{include file="`$myTheme.pages['user-invite-accept'].fullPath`"}
{else}
	{include file="`$template`/core/pages/user-invite-accept/default/default.tpl"}
{/if}
