<!DOCTYPE html>
<!-- mytheme header v10 -->
<html lang="{$activeLocale.languageCode|default:'en'}" data-theme="light" data-header-sentinel="v10">
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

{if $loggedin}
    {assign var=mt_auth value='in'}
{else}
    {assign var=mt_auth value='out'}
{/if}

{* Layout selection: ?layout=top|side|rail via URL. Default = side. *}
{assign var=mt_layout value='side'}
{if isset($smarty.get.layout)}
    {assign var=_lq value=$smarty.get.layout}
    {if $_lq == 'top'}{assign var=mt_layout value='top'}
    {elseif $_lq == 'rail'}{assign var=mt_layout value='rail'}
    {elseif $_lq == 'side'}{assign var=mt_layout value='side'}
    {/if}
{/if}

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

<body class="client-area-layout"
      data-auth="{$mt_auth}"
      data-layout="{$mt_layout}"
      data-active-nav="{$mt_activeNav|escape}"
      data-page-title="{$pagetitle|escape|default:'Page'}">

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
