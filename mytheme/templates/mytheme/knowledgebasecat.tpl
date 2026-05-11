{if isset($myTheme.pages.knowledgebasecat.fullPath) && $myTheme.pages.knowledgebasecat.fullPath && file_exists("templates/`$myTheme.pages.knowledgebasecat.fullPath`")}
	{include file="`$myTheme.pages.knowledgebasecat.fullPath`"}
{else}
	{include file="`$template`/core/pages/knowledgebasecat/default/default.tpl"}
{/if}
