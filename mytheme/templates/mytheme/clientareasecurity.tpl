{if isset($myTheme.pages.clientareasecurity.fullPath) && $myTheme.pages.clientareasecurity.fullPath && file_exists("templates/`$myTheme.pages.clientareasecurity.fullPath`")}
	{include file="`$myTheme.pages.clientareasecurity.fullPath`"}
{else}
	{include file="`$template`/core/pages/clientareasecurity/default/default.tpl"}
{/if}
