{if isset($hadrian.pages.viewannouncement.fullPath) && $hadrian.pages.viewannouncement.fullPath && file_exists("templates/`$hadrian.pages.viewannouncement.fullPath`")}
	{include file="`$hadrian.pages.viewannouncement.fullPath`"}
{else}
	{include file="`$template`/core/pages/viewannouncement/default/default.tpl"}
{/if}
