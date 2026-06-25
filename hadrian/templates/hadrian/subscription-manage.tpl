{if isset($hadrian.pages['subscription-manage'].fullPath) && $hadrian.pages['subscription-manage'].fullPath && file_exists("templates/`$hadrian.pages['subscription-manage'].fullPath`")}
	{include file="`$hadrian.pages['subscription-manage'].fullPath`"}
{else}
	{include file="`$template`/core/pages/subscription-manage/default/default.tpl"}
{/if}
