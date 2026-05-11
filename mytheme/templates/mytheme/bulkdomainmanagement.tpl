{if isset($myTheme.pages.bulkdomainmanagement.fullPath) && $myTheme.pages.bulkdomainmanagement.fullPath && file_exists("templates/`$myTheme.pages.bulkdomainmanagement.fullPath`")}
	{include file="`$myTheme.pages.bulkdomainmanagement.fullPath`"}
{else}
	{include file="`$template`/core/pages/bulkdomainmanagement/default/default.tpl"}
{/if}
