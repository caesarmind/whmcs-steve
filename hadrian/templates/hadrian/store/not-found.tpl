{* WHMCS renders the store not-found page as the FLAT template store/not-found.tpl (stock
   twenty-one/nexus ship it flat); landing pages use store/<slug>/index.tpl.
   This was store/not-found/index.tpl, a path WHMCS never requests. *}
{if isset($hadrian.pages['store-not-found'].fullPath) && $hadrian.pages['store-not-found'].fullPath && file_exists("templates/`$hadrian.pages['store-not-found'].fullPath`")}
	{include file="`$hadrian.pages['store-not-found'].fullPath`"}
{else}
	{include file="`$template`/core/pages/store-not-found/default/default.tpl"}
{/if}
