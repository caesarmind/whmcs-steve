{if isset($hadrian.pages.bulkdomainmanagement.fullPath) && $hadrian.pages.bulkdomainmanagement.fullPath && file_exists("templates/`$hadrian.pages.bulkdomainmanagement.fullPath`")}
	{include file="`$hadrian.pages.bulkdomainmanagement.fullPath`"}
{else}
	{include file="`$template`/core/pages/bulkdomainmanagement/default/default.tpl"}
{/if}
