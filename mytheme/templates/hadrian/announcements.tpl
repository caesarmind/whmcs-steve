{if isset($hadrian.pages.announcements.fullPath) && $hadrian.pages.announcements.fullPath && file_exists("templates/`$hadrian.pages.announcements.fullPath`")}
	{include file="`$hadrian.pages.announcements.fullPath`"}
{else}
	{include file="`$template`/core/pages/announcements/default/default.tpl"}
{/if}
