{* viewinvoice is a special WHMCS route — it does NOT auto-wrap in our
   client-area chrome (header.tpl + footer.tpl). Both Nexus and Lagom solve
   this by emitting their own HTML envelope. We use the chrome we already
   have by including header + footer manually. Without this, apple-theme.css
   never loads → CSS variables undefined → page renders completely unstyled. *}
{include file="`$template`/header.tpl"}

{if isset($hadrian.pages.viewinvoice.fullPath) && $hadrian.pages.viewinvoice.fullPath && file_exists("templates/`$hadrian.pages.viewinvoice.fullPath`")}
	{include file="`$hadrian.pages.viewinvoice.fullPath`"}
{else}
	{include file="`$template`/core/pages/viewinvoice/default/default.tpl"}
{/if}

{include file="`$template`/footer.tpl"}
