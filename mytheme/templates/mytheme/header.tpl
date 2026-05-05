{* Hostnodes — page header.
   Renders the html shell + body data-attributes that the apple-layout system uses
   to switch between top / side / rail layouts. All 3 partials are emitted; CSS
   shows only the one matching body[data-layout].

   Buyer override: drop a custom header.tpl into templates/<slug>/overwrites/. *}

{if file_exists("templates/$template/overwrites/header.tpl")}
    {include file="`$template`/overwrites/header.tpl"}
{else}
<!DOCTYPE html>
<!-- mytheme header v6 -->
<html lang="{$activeLocale.languageCode|default:'en'}" data-theme="light"
      data-header-sentinel="v6">
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

{* Body data-attrs — keep this DEAD simple. No $myTheme chains here.
   Layout/activeNav lookups can be added back once we confirm header
   renders end-to-end on the server. *}
{$mt_auth = $loggedin ? 'in' : 'out'}
{$mt_layout = 'side'}
{$mt_activeNav = ''}
{$_tf = $templatefile|default:''}
{if $_tf == 'clientareahome'}{$mt_activeNav = 'dashboard'}
{elseif $_tf == 'clientareaproducts' || $_tf == 'clientareaproductdetails'}{$mt_activeNav = 'services'}
{elseif $_tf == 'clientareadomains'}{$mt_activeNav = 'domains'}
{elseif $_tf == 'clientareainvoices' || $_tf == 'viewinvoice'}{$mt_activeNav = 'invoices'}
{elseif $_tf == 'supporttickets' || $_tf == 'supportticketslist' || $_tf == 'viewticket'}{$mt_activeNav = 'tickets'}
{elseif $_tf == 'clientareadetails'}{$mt_activeNav = 'details'}
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
