{if isset($hadrian.pages.clientareadomainemailforwarding.fullPath) && $hadrian.pages.clientareadomainemailforwarding.fullPath && file_exists("templates/`$hadrian.pages.clientareadomainemailforwarding.fullPath`")}
	{include file="`$hadrian.pages.clientareadomainemailforwarding.fullPath`"}
{else}
	{include file="`$template`/core/pages/clientareadomainemailforwarding/default/default.tpl"}
{/if}
