{if isset($hadrian.pages['store-spamexperts'].fullPath) && $hadrian.pages['store-spamexperts'].fullPath && file_exists("templates/`$hadrian.pages['store-spamexperts'].fullPath`")}
	{include file="`$hadrian.pages['store-spamexperts'].fullPath`"}
{else}
	{include file="`$template`/core/pages/store-spamexperts/default/default.tpl"}
{/if}
