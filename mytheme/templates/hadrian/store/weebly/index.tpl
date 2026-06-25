{if isset($hadrian.pages['store-weebly'].fullPath) && $hadrian.pages['store-weebly'].fullPath && file_exists("templates/`$hadrian.pages['store-weebly'].fullPath`")}
	{include file="`$hadrian.pages['store-weebly'].fullPath`"}
{else}
	{include file="`$template`/core/pages/store-weebly/default/default.tpl"}
{/if}
