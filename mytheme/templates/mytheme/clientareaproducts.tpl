{* MyTheme — My Products & Services dispatch.

   This is a 5-line dispatcher. Implementation lives in
   core/pages/clientareaproducts/<variant>/<variant>.tpl *}

{if isset($myTheme.pages.clientareaproducts.fullPath) && file_exists("templates/`$myTheme.pages.clientareaproducts.fullPath`")}
    {include file="`$myTheme.pages.clientareaproducts.fullPath`"}
{else}
    {include file="`$template`/core/pages/clientareaproducts/default/default.tpl"}
{/if}
