{* viewquote is a special WHMCS route — same as viewinvoice, it does NOT
   auto-wrap in our client-area chrome (header.tpl + footer.tpl). Include
   them manually here so core-theme.css and friends load. Without this
   the page renders with no styling because the CSS variables go undefined. *}
{include file="`$template`/header.tpl"}

{if isset($hadrian.pages.viewquote.fullPath) && $hadrian.pages.viewquote.fullPath && file_exists("templates/`$hadrian.pages.viewquote.fullPath`")}
	{include file="`$hadrian.pages.viewquote.fullPath`"}
{else}
	{include file="`$template`/core/pages/viewquote/default/default.tpl"}
{/if}

{include file="`$template`/footer.tpl"}
