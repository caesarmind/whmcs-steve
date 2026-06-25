{if isset($hadrian.pages.masspay.fullPath) && $hadrian.pages.masspay.fullPath && file_exists("templates/`$hadrian.pages.masspay.fullPath`")}
	{include file="`$hadrian.pages.masspay.fullPath`"}
{else}
	{include file="`$template`/core/pages/masspay/default/default.tpl"}
{/if}
