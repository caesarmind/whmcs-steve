{* ════════════════════════════════════════════════════════════════════════
   Hostnodes — page header.

   ALL Smarty assignments live above the DOCTYPE so $mt_palette etc. are
   available when the <html> tag renders.

   URL params (every chip toggle is reachable via the address bar):
     ?layout=top|side|rail
     ?align=center|content|left
     ?subnav=on|off
     ?subnavside=left|right|outside-left|outside
     ?svclayout=inside|outside
     ?data=full|empty
     ?tiles=all|a|b|c|d|e|f
     ?form=all|a|b|c
     ?plan=all|a|b|c|d|e|f|g|h
     ?product=all|a|b|c
     ?palette=blue|emerald|violet|rose|amber|slate
   These set body data-* attributes (palette sets html data-palette).
   The chip JS still drives runtime toggling + localStorage; URL value
   wins on initial render.
   ════════════════════════════════════════════════════════════════════════ *}

{* auth state *}
{if $loggedin}{assign var=mt_auth value='in'}{else}{assign var=mt_auth value='out'}{/if}

{* layout *}
{assign var=mt_layout value='side'}
{if isset($smarty.get.layout)}
    {assign var=_q value=$smarty.get.layout}
    {if $_q == 'top'}{assign var=mt_layout value='top'}
    {elseif $_q == 'rail'}{assign var=mt_layout value='rail'}
    {elseif $_q == 'side'}{assign var=mt_layout value='side'}
    {/if}
{/if}

{* align *}
{assign var=mt_align value=''}
{if isset($smarty.get.align)}
    {assign var=_q value=$smarty.get.align}
    {if $_q == 'center' || $_q == 'content' || $_q == 'left'}{assign var=mt_align value=$_q}{/if}
{/if}

{* subnav (on/off) *}
{assign var=mt_subnav value=''}
{if isset($smarty.get.subnav)}
    {assign var=_q value=$smarty.get.subnav}
    {if $_q == 'on' || $_q == 'off'}{assign var=mt_subnav value=$_q}{/if}
{/if}

{* subnav side *}
{assign var=mt_subnavSide value=''}
{if isset($smarty.get.subnavside)}
    {assign var=_q value=$smarty.get.subnavside}
    {if $_q == 'left' || $_q == 'right' || $_q == 'outside' || $_q == 'outside-left'}
        {assign var=mt_subnavSide value=$_q}
    {/if}
{/if}

{* services layout (inside/outside) *}
{assign var=mt_svcLayout value=''}
{if isset($smarty.get.svclayout)}
    {assign var=_q value=$smarty.get.svclayout}
    {if $_q == 'inside' || $_q == 'outside'}{assign var=mt_svcLayout value=$_q}{/if}
{/if}

{* data state *}
{assign var=mt_data value=''}
{if isset($smarty.get.data)}
    {assign var=_q value=$smarty.get.data}
    {if $_q == 'full' || $_q == 'empty'}{assign var=mt_data value=$_q}{/if}
{/if}

{* tiles *}
{assign var=mt_tiles value=''}
{if isset($smarty.get.tiles)}
    {assign var=_q value=$smarty.get.tiles}
    {if $_q == 'all' || $_q == 'a' || $_q == 'b' || $_q == 'c' || $_q == 'd' || $_q == 'e' || $_q == 'f'}
        {assign var=mt_tiles value=$_q}
    {/if}
{/if}

{* form *}
{assign var=mt_form value=''}
{if isset($smarty.get.form)}
    {assign var=_q value=$smarty.get.form}
    {if $_q == 'all' || $_q == 'a' || $_q == 'b' || $_q == 'c'}{assign var=mt_form value=$_q}{/if}
{/if}

{* plan *}
{assign var=mt_plan value=''}
{if isset($smarty.get.plan)}
    {assign var=_q value=$smarty.get.plan}
    {if $_q == 'all' || $_q == 'a' || $_q == 'b' || $_q == 'c' || $_q == 'd' || $_q == 'e' || $_q == 'f' || $_q == 'g' || $_q == 'h'}
        {assign var=mt_plan value=$_q}
    {/if}
{/if}

{* product *}
{assign var=mt_product value=''}
{if isset($smarty.get.product)}
    {assign var=_q value=$smarty.get.product}
    {if $_q == 'all' || $_q == 'a' || $_q == 'b' || $_q == 'c'}{assign var=mt_product value=$_q}{/if}
{/if}

{* palette (sets <html data-palette>) *}
{assign var=mt_palette value=''}
{if isset($smarty.get.palette)}
    {assign var=_q value=$smarty.get.palette}
    {if $_q == 'blue' || $_q == 'emerald' || $_q == 'violet' || $_q == 'rose' || $_q == 'amber' || $_q == 'slate'}
        {assign var=mt_palette value=$_q}
    {/if}
{/if}

{* active nav + page label per WHMCS templatefile *}
{assign var=mt_activeNav value=''}
{assign var=mt_pageLabel value=$pagetitle}
{assign var=_tf value=$templatefile|default:''}
{if $_tf == 'clientareahome'}
    {assign var=mt_activeNav value='dashboard'}
    {assign var=mt_pageLabel value='Dashboard'}
{elseif $_tf == 'clientareaproducts'}
    {assign var=mt_activeNav value='services'}
    {assign var=mt_pageLabel value='My Products & Services'}
{elseif $_tf == 'clientareaproductdetails'}
    {assign var=mt_activeNav value='services'}
{elseif $_tf == 'clientareadomains'}
    {assign var=mt_activeNav value='domains'}
    {assign var=mt_pageLabel value='My Domains'}
{elseif $_tf == 'clientareainvoices'}
    {assign var=mt_activeNav value='invoices'}
    {assign var=mt_pageLabel value='My Invoices'}
{elseif $_tf == 'viewinvoice'}
    {assign var=mt_activeNav value='invoices'}
{elseif $_tf == 'supporttickets' || $_tf == 'supportticketslist'}
    {assign var=mt_activeNav value='tickets'}
    {assign var=mt_pageLabel value='Support Tickets'}
{elseif $_tf == 'viewticket'}
    {assign var=mt_activeNav value='tickets'}
{elseif $_tf == 'clientareadetails'}
    {assign var=mt_activeNav value='details'}
    {assign var=mt_pageLabel value='My Details'}
{elseif $_tf == 'announcements'}
    {assign var=mt_pageLabel value='Announcements'}
{/if}
<!DOCTYPE html>
<!-- mytheme header v11 -->
<html lang="{$activeLocale.languageCode|default:'en'}" data-theme="light" data-header-sentinel="v11"{if $mt_palette} data-palette="{$mt_palette|escape}"{/if}>
<head>
    <meta charset="{$charset|default:'utf-8'}">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{if $pagetitle}{$pagetitle} — {/if}{$companyname|escape}</title>
    {if $tagline}<meta name="description" content="{$tagline|escape}">{/if}
    <link rel="stylesheet" href="{$WEB_ROOT}/templates/{$template}/assets/css/apple-theme.css?v=1.0">
    <link rel="stylesheet" href="{$WEB_ROOT}/templates/{$template}/assets/css/apple-layout.css?v=1.0">
    {$headoutput}
</head>
<body class="client-area-layout"
      data-auth="{$mt_auth}"
      data-layout="{$mt_layout}"
      data-active-nav="{$mt_activeNav|escape}"
      data-page-title="{$pagetitle|escape|default:'Page'}"{if $mt_align} data-align="{$mt_align|escape}"{/if}{if $mt_subnav} data-subnav="{$mt_subnav|escape}"{/if}{if $mt_subnavSide} data-subnav-side="{$mt_subnavSide|escape}"{/if}{if $mt_svcLayout} data-svc-layout="{$mt_svcLayout|escape}"{/if}{if $mt_data} data-data="{$mt_data|escape}"{/if}{if $mt_tiles} data-tiles="{$mt_tiles|escape}"{/if}{if $mt_form} data-form="{$mt_form|escape}"{/if}{if $mt_plan} data-plan="{$mt_plan|escape}"{/if}{if $mt_product} data-product="{$mt_product|escape}"{/if}>

{$headeroutput}

{* Dev preview chip — render on ?preview=1 or for admins *}
{include file="`$template`/includes/partials/state-chip.tpl"}

{include file="`$template`/includes/partials/rail.tpl"}
{include file="`$template`/includes/partials/sidebar.tpl"}

<div class="ph-main-wrap">

    {include file="`$template`/includes/partials/topnav.tpl"}
    {include file="`$template`/includes/partials/inner-topbar.tpl"}

    <nav class="ph-breadcrumb only-top" aria-label="breadcrumb">
        <div class="ph-breadcrumb-inner">
            <a href="{$WEB_ROOT}/">{$LANG.home|default:'Home'}</a>
            <span class="sep">/</span>
            <span class="current" aria-current="page">{$mt_pageLabel|escape|default:'Page'}</span>
        </div>
    </nav>

    <div class="content-area">
