{if isset($hadrian.pages['two-factor-challenge'].fullPath) && $hadrian.pages['two-factor-challenge'].fullPath && file_exists("templates/`$hadrian.pages['two-factor-challenge'].fullPath`")}
	{include file="`$hadrian.pages['two-factor-challenge'].fullPath`"}
{else}
	{include file="`$template`/core/pages/two-factor-challenge/default/default.tpl"}
{/if}
