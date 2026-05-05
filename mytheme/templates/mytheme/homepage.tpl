{* MyTheme — Marketing homepage dispatch. *}

{if isset($myTheme.pages.homepage.fullPath) && file_exists("templates/`$myTheme.pages.homepage.fullPath`")}
    {include file="`$myTheme.pages.homepage.fullPath`"}
{else}
    {include file="`$template`/core/pages/homepage/default/default.tpl"}
{/if}
