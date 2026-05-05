{* Hostnodes — page header.
   Renders the html shell + body data-attributes that the apple-layout system uses
   to switch between top / side / rail layouts. All 3 partials are emitted; CSS
   shows only the one matching body[data-layout].

   Buyer override: drop a custom header.tpl into templates/<slug>/overwrites/. *}

{if file_exists("templates/$template/overwrites/header.tpl")}
    {include file="`$template`/overwrites/header.tpl"}
{else}
    {* data-layout reads from the active layout's manifest (sidebar/top/rail).
       Defensive — falls back to 'side' if the hook hasn't populated myTheme. *}
    {$mt_layout = 'side'}
    {if isset($myTheme.layouts) && isset($myTheme.layouts['main-menu']) && isset($myTheme.layouts['main-menu']['vars']['dataLayout'])}
        {$mt_layout = $myTheme.layouts['main-menu']['vars']['dataLayout']}
    {/if}
    {$mt_auth = $loggedin ? 'in' : 'out'}

    {* activeNav drives the sidebar/rail/topnav highlight. Map common WHMCS
       templatefiles to a sidebar slot. Defensive default + no chained lookups
       on potentially-undefined intermediates. *}
    {$_tf = $templatefile|default:''}
    {$mt_activeNav = 'dashboard'}
    {if $_tf == 'clientareaproducts' || $_tf == 'clientareaproductdetails'}
        {$mt_activeNav = 'services'}
    {elseif $_tf == 'clientareadomains' || $_tf == 'clientareadomaindetails' || $_tf == 'clientareadomaindns' || $_tf == 'clientareadomainregisterns' || $_tf == 'clientareadomaincontactinfo' || $_tf == 'clientareadomainemailforwarding' || $_tf == 'domainchecker'}
        {$mt_activeNav = 'domains'}
    {elseif $_tf == 'clientareainvoices' || $_tf == 'viewinvoice' || $_tf == 'invoicepdf'}
        {$mt_activeNav = 'invoices'}
    {elseif $_tf == 'clientareaquotes' || $_tf == 'viewquote'}
        {$mt_activeNav = 'quotes'}
    {elseif $_tf == 'supporttickets' || $_tf == 'supportticketslist' || $_tf == 'supportticketsubmit' || $_tf == 'viewticket'}
        {$mt_activeNav = 'tickets'}
    {elseif $_tf == 'knowledgebase' || $_tf == 'knowledgebasecat' || $_tf == 'knowledgebasearticle'}
        {$mt_activeNav = 'knowledgebase'}
    {elseif $_tf == 'announcements' || $_tf == 'viewannouncement'}
        {$mt_activeNav = 'announcements'}
    {elseif $_tf == 'clientareadetails' || $_tf == 'clientareacontacts'}
        {$mt_activeNav = 'details'}
    {elseif $_tf == 'clientareasecurity' || $_tf == 'twofactor'}
        {$mt_activeNav = 'security-account'}
    {elseif $_tf == 'login' || $_tf == 'register' || $_tf == 'pwreset'}
        {$mt_activeNav = ''}
    {/if}
    {* RTL detection — defensive against missing manifest / language *}
    {$_lang = $language|default:''}
    {$_rtlList = $myTheme.manifest.rtlLanguages|default:[]}
    {$_isRtl = false}
    {if $_lang && $_rtlList && is_array($_rtlList)}
        {if in_array($_lang, $_rtlList)}{$_isRtl = true}{/if}
    {/if}
<!DOCTYPE html>
<html lang="{$activeLocale.languageCode|default:'en'}"
      data-theme="light"
      {if $_isRtl}dir="rtl"{/if}>
<head>
    <meta charset="{$charset|default:'utf-8'}">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{if $pagetitle}{$pagetitle} — {/if}{$companyname|escape}</title>
    {if $tagline}<meta name="description" content="{$tagline|escape}">{/if}
    <link rel="stylesheet" href="{$WEB_ROOT}/templates/{$template}/assets/css/apple-theme.css?v={$myTheme.version|default:'1.0'}">
    <link rel="stylesheet" href="{$WEB_ROOT}/templates/{$template}/assets/css/apple-layout.css?v={$myTheme.version|default:'1.0'}">
    {$headoutput}
</head>
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
