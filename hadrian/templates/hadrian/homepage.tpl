{if isset($hadrian.pages.homepage.fullPath) && $hadrian.pages.homepage.fullPath && file_exists("templates/`$hadrian.pages.homepage.fullPath`")}
	{include file="`$hadrian.pages.homepage.fullPath`"}
{else}
	{include file="`$template`/core/pages/homepage/default/default.tpl"}
{/if}
