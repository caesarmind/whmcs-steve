{if isset($hadrian.pages['store-sitebuilder'].fullPath) && $hadrian.pages['store-sitebuilder'].fullPath && file_exists("templates/`$hadrian.pages['store-sitebuilder'].fullPath`")}
	{include file="`$hadrian.pages['store-sitebuilder'].fullPath`"}
{else}
	{include file="`$template`/core/pages/store-sitebuilder/default/default.tpl"}
{/if}
