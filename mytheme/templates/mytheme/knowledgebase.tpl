{if isset($myTheme.pages.knowledgebase.fullPath) && $myTheme.pages.knowledgebase.fullPath && file_exists("templates/`$myTheme.pages.knowledgebase.fullPath`")}
	{include file="`$myTheme.pages.knowledgebase.fullPath`"}
{else}
	{include file="`$template`/core/pages/knowledgebase/default/default.tpl"}
{/if}
