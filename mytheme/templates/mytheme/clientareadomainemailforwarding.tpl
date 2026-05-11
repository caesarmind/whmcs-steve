{if isset($myTheme.pages.clientareadomainemailforwarding.fullPath) && $myTheme.pages.clientareadomainemailforwarding.fullPath && file_exists("templates/`$myTheme.pages.clientareadomainemailforwarding.fullPath`")}
	{include file="`$myTheme.pages.clientareadomainemailforwarding.fullPath`"}
{else}
	{include file="`$template`/core/pages/clientareadomainemailforwarding/default/default.tpl"}
{/if}
