{if isset($myTheme.pages.markdown-guide.fullPath) && $myTheme.pages.markdown-guide.fullPath && file_exists("templates/`$myTheme.pages.markdown-guide.fullPath`")}
	{include file="`$myTheme.pages.markdown-guide.fullPath`"}
{else}
	{include file="`$template`/core/pages/markdown-guide/default/default.tpl"}
{/if}
