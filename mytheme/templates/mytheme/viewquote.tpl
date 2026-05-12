{* viewquote is a special WHMCS route — same as viewinvoice, it does NOT
   auto-wrap in our client-area chrome (header.tpl + footer.tpl). Include
   them manually here so apple-theme.css and friends load. Without this
   the page renders with no styling because the CSS variables go undefined. *}
{include file="`$template`/header.tpl"}

{if isset($myTheme.pages.viewquote.fullPath) && $myTheme.pages.viewquote.fullPath && file_exists("templates/`$myTheme.pages.viewquote.fullPath`")}
	{include file="`$myTheme.pages.viewquote.fullPath`"}
{else}
	{include file="`$template`/core/pages/viewquote/default/default.tpl"}
{/if}

{include file="`$template`/footer.tpl"}
