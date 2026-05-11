{if isset($myTheme.pages.supportticketslist.fullPath) && $myTheme.pages.supportticketslist.fullPath && file_exists("templates/`$myTheme.pages.supportticketslist.fullPath`")}
    {include file="`$myTheme.pages.supportticketslist.fullPath`"}
{else}
    {include file="`$template`/core/pages/supportticketslist/default/default.tpl"}
{/if}