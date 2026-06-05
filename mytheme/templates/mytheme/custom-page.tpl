{* Dispatcher for the custom page.

   custom-page.php (WHMCS root) calls setTemplate('custom-page'), so WHMCS loads
   THIS file wrapped by the theme header.tpl + footer.tpl. We just include the
   page body from core/pages, exactly like every other mytheme page. *}
{if isset($myTheme.pages['custom-page'].fullPath) && $myTheme.pages['custom-page'].fullPath && file_exists("templates/`$myTheme.pages['custom-page'].fullPath`")}
	{include file="`$myTheme.pages['custom-page'].fullPath`"}
{else}
	{include file="`$template`/core/pages/custom-page/default/default.tpl"}
{/if}
