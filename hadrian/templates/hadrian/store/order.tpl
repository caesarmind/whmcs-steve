{* WHMCS renders the store order page as the FLAT template store/order.tpl (stock
   twenty-one/nexus ship it flat); landing pages use store/<slug>/index.tpl.
   This was store/order/index.tpl, a path WHMCS never requests. *}
{if isset($hadrian.pages['store-order'].fullPath) && $hadrian.pages['store-order'].fullPath && file_exists("templates/`$hadrian.pages['store-order'].fullPath`")}
	{include file="`$hadrian.pages['store-order'].fullPath`"}
{else}
	{include file="`$template`/core/pages/store-order/default/default.tpl"}
{/if}
