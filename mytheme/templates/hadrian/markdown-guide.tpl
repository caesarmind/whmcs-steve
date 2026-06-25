{if isset($hadrian.pages['markdown-guide'].fullPath) && $hadrian.pages['markdown-guide'].fullPath && file_exists("templates/`$hadrian.pages['markdown-guide'].fullPath`")}
	{include file="`$hadrian.pages['markdown-guide'].fullPath`"}
{else}
	{include file="`$template`/core/pages/markdown-guide/default/default.tpl"}
{/if}
