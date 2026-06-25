{* Dispatcher for the custom page.

   custom-page.php (WHMCS root) calls setTemplate('custom-page'), so WHMCS loads
   THIS file wrapped by the theme header.tpl + footer.tpl. We just include the
   page body from core/pages, exactly like every other hadrian page. *}
{if isset($hadrian.pages['custom-page'].fullPath) && $hadrian.pages['custom-page'].fullPath && file_exists("templates/`$hadrian.pages['custom-page'].fullPath`")}
	{include file="`$hadrian.pages['custom-page'].fullPath`"}
{else}
	{include file="`$template`/core/pages/custom-page/default/default.tpl"}
{/if}
