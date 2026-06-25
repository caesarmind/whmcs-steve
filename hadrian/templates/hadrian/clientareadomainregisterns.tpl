{if isset($hadrian.pages.clientareadomainregisterns.fullPath) && $hadrian.pages.clientareadomainregisterns.fullPath && file_exists("templates/`$hadrian.pages.clientareadomainregisterns.fullPath`")}
	{include file="`$hadrian.pages.clientareadomainregisterns.fullPath`"}
{else}
	{include file="`$template`/core/pages/clientareadomainregisterns/default/default.tpl"}
{/if}
