{if isset($hadrian.pages['upgrade-configure'].fullPath) && $hadrian.pages['upgrade-configure'].fullPath && file_exists("templates/`$hadrian.pages['upgrade-configure'].fullPath`")}
	{include file="`$hadrian.pages['upgrade-configure'].fullPath`"}
{else}
	{include file="`$template`/core/pages/upgrade-configure/default/default.tpl"}
{/if}
