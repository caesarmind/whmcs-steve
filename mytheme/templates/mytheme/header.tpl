{* Hostnodes — page header.
   Renders the html shell + body data-attributes that the apple-layout system uses
   to switch between top / side / rail layouts. All 3 partials are emitted; CSS
   shows only the one matching body[data-layout].

   Layout selection is admin-driven:
     Admin → MyTheme → Layouts → main-menu → pick sidebar | top | rail
     → saved to mytheme_settings as "mytheme_active_layout_main-menu"
     → Hooks::resolveActiveLayout reads the layout.php manifest
     → exposes $myTheme.layouts['main-menu'].vars.dataLayout = side|top|rail

   Buyer override: drop a custom header.tpl into templates/<slug>/overwrites/. *}

{if file_exists("templates/$template/overwrites/header.tpl")}
    {include file="`$template`/overwrites/header.tpl"}
{else}
<!DOCTYPE html>
<!-- mytheme header v7 -->
<html lang="{$activeLocale.languageCode|default:'en'}" data-theme="light">
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

{* ── Resolve the active layout from admin settings.
      Hook populates $myTheme.layouts['main-menu'].vars.dataLayout based on
      whichever layout the admin picked (sidebar → 'side', top → 'top',
      rail → 'rail'). Falls back to 'side' if myTheme isn't populated. ── *}
{assign var=mt_layout value='side'}
{if isset($myTheme) && isset($myTheme.layouts) && isset($myTheme.layouts['main-menu'])}
    {if isset($myTheme.layouts['main-menu'].vars) && isset($myTheme.layouts['main-menu'].vars.dataLayout)}
        {assign var=mt_layout value=$myTheme.layouts['main-menu'].vars.dataLayout}
    {/if}
{/if}

{assign var=mt_auth value='out'}
{if $loggedin}{assign var=mt_auth value='in'}{/if}

{* activeNav drives the sidebar/rail/topnav highlight. Map common WHMCS
   templatefiles to a sidebar slot. *}
{assign var=_tf value=$templatefile|default:''}
{assign var=mt_activeNav value='dashboard'}
{if $_tf == 'clientareaproducts' || $_tf == 'clientareaproductdetails'}
    {assign var=mt_activeNav value='services'}
{elseif $_tf == 'clientareadomains' || $_tf == 'clientareadomaindetails' || $_tf == 'clientareadomaindns' || $_tf == 'clientareadomainregisterns' || $_tf == 'clientareadomaincontactinfo' || $_tf == 'clientareadomainemailforwarding' || $_tf == 'domainchecker'}
    {assign var=mt_activeNav value='domains'}
{elseif $_tf == 'clientareainvoices' || $_tf == 'viewinvoice' || $_tf == 'invoicepdf'}
    {assign var=mt_activeNav value='invoices'}
{elseif $_tf == 'clientareaquotes' || $_tf == 'viewquote'}
    {assign var=mt_activeNav value='quotes'}
{elseif $_tf == 'supporttickets' || $_tf == 'supportticketslist' || $_tf == 'supportticketsubmit' || $_tf == 'viewticket'}
    {assign var=mt_activeNav value='tickets'}
{elseif $_tf == 'knowledgebase' || $_tf == 'knowledgebasecat' || $_tf == 'knowledgebasearticle'}
    {assign var=mt_activeNav value='knowledgebase'}
{elseif $_tf == 'announcements' || $_tf == 'viewannouncement'}
    {assign var=mt_activeNav value='announcements'}
{elseif $_tf == 'clientareadetails' || $_tf == 'clientareacontacts'}
    {assign var=mt_activeNav value='details'}
{elseif $_tf == 'clientareasecurity' || $_tf == 'twofactor'}
    {assign var=mt_activeNav value='security-account'}
{elseif $_tf == 'login' || $_tf == 'register' || $_tf == 'pwreset'}
    {assign var=mt_activeNav value=''}
{/if}

<body class="client-area-layout"
      data-auth="{$mt_auth}"
      data-layout="{$mt_layout}"
      data-active-nav="{$mt_activeNav|escape}"
      data-page-title="{$pagetitle|escape|default:'Page'}">

{$headeroutput}

{* All 3 layout partials emit their markup; CSS shows only the active one. *}
{include file="`$template`/includes/partials/rail.tpl"}
{include file="`$template`/includes/partials/sidebar.tpl"}

<div class="ph-main-wrap">

    {* Top-layout topnav (only-top) *}
    {include file="`$template`/includes/partials/topnav.tpl"}

    {* Inner topbar (sidebar + rail layouts) *}
    {include file="`$template`/includes/partials/inner-topbar.tpl"}

    {* Top-layout breadcrumb *}
    <nav class="ph-breadcrumb only-top" aria-label="breadcrumb">
        <div class="ph-breadcrumb-inner">
            <a href="{$WEB_ROOT}/">{$LANG.home|default:'Home'}</a>
            <span class="sep">/</span>
            <span class="current" aria-current="page">{$pagetitle|escape|default:'Page'}</span>
        </div>
    </nav>

    <div class="content-area">
{/if}
