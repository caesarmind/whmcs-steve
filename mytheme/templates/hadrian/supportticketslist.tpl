{if isset($hadrian.pages.supportticketslist.fullPath) && $hadrian.pages.supportticketslist.fullPath && file_exists("templates/`$hadrian.pages.supportticketslist.fullPath`")}
    {include file="`$hadrian.pages.supportticketslist.fullPath`"}
{else}
    {include file="`$template`/core/pages/supportticketslist/default/default.tpl"}
{/if}