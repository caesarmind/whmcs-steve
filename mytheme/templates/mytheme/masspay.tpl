{if isset($myTheme.pages.masspay.fullPath) && $myTheme.pages.masspay.fullPath && file_exists("templates/`$myTheme.pages.masspay.fullPath`")}
	{include file="`$myTheme.pages.masspay.fullPath`"}
{else}
	{include file="`$template`/core/pages/masspay/default/default.tpl"}
{/if}
