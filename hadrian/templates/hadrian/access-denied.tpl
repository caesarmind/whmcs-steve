{if isset($hadrian.pages['access-denied'].fullPath) && $hadrian.pages['access-denied'].fullPath && file_exists("templates/`$hadrian.pages['access-denied'].fullPath`")}
	{include file="`$hadrian.pages['access-denied'].fullPath`"}
{else}
	{include file="`$template`/core/pages/access-denied/default/default.tpl"}
{/if}
