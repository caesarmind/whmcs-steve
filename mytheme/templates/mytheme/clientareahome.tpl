{* MyTheme — Client Home dispatch.

   This is a 5-line dispatcher. Implementation lives in
   core/pages/clientareahome/<variant>/<variant>.tpl

   ✗ NOT a 300-line "shim with inline fallback" like Lagom.
   ✓ The variant always exists — `default` is shipped, others are buyer-added. *}

{if isset($myTheme.pages.clientareahome.fullPath) && file_exists("templates/`$myTheme.pages.clientareahome.fullPath`")}
    {include file="`$myTheme.pages.clientareahome.fullPath`"}
{else}
    {include file="`$template`/core/pages/clientareahome/default/default.tpl"}
{/if}
