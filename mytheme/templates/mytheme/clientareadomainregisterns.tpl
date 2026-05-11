{if isset($myTheme.pages.clientareadomainregisterns.fullPath) && $myTheme.pages.clientareadomainregisterns.fullPath && file_exists("templates/`$myTheme.pages.clientareadomainregisterns.fullPath`")}
	{include file="`$myTheme.pages.clientareadomainregisterns.fullPath`"}
{else}
	{include file="`$template`/core/pages/clientareadomainregisterns/default/default.tpl"}
{/if}
