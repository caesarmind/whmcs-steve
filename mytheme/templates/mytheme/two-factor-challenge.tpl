{if isset($myTheme.pages['two-factor-challenge'].fullPath) && $myTheme.pages['two-factor-challenge'].fullPath && file_exists("templates/`$myTheme.pages['two-factor-challenge'].fullPath`")}
	{include file="`$myTheme.pages['two-factor-challenge'].fullPath`"}
{else}
	{include file="`$template`/core/pages/two-factor-challenge/default/default.tpl"}
{/if}
