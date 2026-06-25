{if isset($hadrian.pages['user-invite-accept'].fullPath) && $hadrian.pages['user-invite-accept'].fullPath && file_exists("templates/`$hadrian.pages['user-invite-accept'].fullPath`")}
	{include file="`$hadrian.pages['user-invite-accept'].fullPath`"}
{else}
	{include file="`$template`/core/pages/user-invite-accept/default/default.tpl"}
{/if}
