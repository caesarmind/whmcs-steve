{if isset($hadrian.pages['domain-pricing'].fullPath) && $hadrian.pages['domain-pricing'].fullPath && file_exists("templates/`$hadrian.pages['domain-pricing'].fullPath`")}
	{include file="`$hadrian.pages['domain-pricing'].fullPath`"}
{else}
	{include file="`$template`/core/pages/domain-pricing/default/default.tpl"}
{/if}
