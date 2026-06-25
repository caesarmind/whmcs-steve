{if isset($hadrian.pages.upgrade.fullPath) && $hadrian.pages.upgrade.fullPath && file_exists("templates/`$hadrian.pages.upgrade.fullPath`")}
	{include file="`$hadrian.pages.upgrade.fullPath`"}
{else}
	{include file="`$template`/core/pages/upgrade/default/default.tpl"}
{/if}
