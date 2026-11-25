{* Dispatcher for the accessibility statement.

   The site owner's accessibility.php (WHMCS root, a copy of custom-page.php
   with setTemplate('accessibility')) loads THIS file inside the theme
   header.tpl + footer.tpl. Hadrian does not ship that entry file on purpose:
   the statement should go live only after its owner has filled it in. *}
{if isset($hadrian.pages.accessibility.fullPath) && $hadrian.pages.accessibility.fullPath && file_exists("templates/`$hadrian.pages.accessibility.fullPath`")}
	{include file="`$hadrian.pages.accessibility.fullPath`"}
{else}
	{include file="`$template`/core/pages/accessibility/default/default.tpl"}
{/if}
