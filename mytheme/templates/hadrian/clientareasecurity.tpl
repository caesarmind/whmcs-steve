{if isset($hadrian.pages.clientareasecurity.fullPath) && $hadrian.pages.clientareasecurity.fullPath && file_exists("templates/`$hadrian.pages.clientareasecurity.fullPath`")}
	{include file="`$hadrian.pages.clientareasecurity.fullPath`"}
{else}
	{include file="`$template`/core/pages/clientareasecurity/default/default.tpl"}
{/if}
