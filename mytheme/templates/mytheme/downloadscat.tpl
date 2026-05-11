{if isset($myTheme.pages.downloadscat.fullPath) && $myTheme.pages.downloadscat.fullPath && file_exists("templates/`$myTheme.pages.downloadscat.fullPath`")}
	{include file="`$myTheme.pages.downloadscat.fullPath`"}
{else}
	{include file="`$template`/core/pages/downloadscat/default/default.tpl"}
{/if}
