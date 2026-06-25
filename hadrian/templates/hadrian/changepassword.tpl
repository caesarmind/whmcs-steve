{if isset($hadrian.pages.changepassword.fullPath) && $hadrian.pages.changepassword.fullPath && file_exists("templates/`$hadrian.pages.changepassword.fullPath`")}
	{include file="`$hadrian.pages.changepassword.fullPath`"}
{else}
	{include file="`$template`/core/pages/changepassword/default/default.tpl"}
{/if}
