{if isset($myTheme.pages['domain-pricing'].fullPath) && $myTheme.pages['domain-pricing'].fullPath && file_exists("templates/`$myTheme.pages['domain-pricing'].fullPath`")}
	{include file="`$myTheme.pages['domain-pricing'].fullPath`"}
{else}
	{include file="`$template`/core/pages/domain-pricing/default/default.tpl"}
{/if}
