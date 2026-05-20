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

{* ────────────────────────────────────────────────────────────────────────
   LICENSE GATE — set to true once the theme is ready for commercial release.
   When false, the gate never renders and the theme is usable without the
   MyTheme addon being active. The check below ALSO bypasses when the addon
   IS active and dev_mode is on (in which case canRender is set to true). *}
{assign var=mtLicenseGateEnabled value=false}

{if $mtLicenseGateEnabled && empty($myTheme.license.canRender)}
<!DOCTYPE html>
<html lang="{$activeLocale.languageCode|default:'en'}">
<head>
    <meta charset="{$charset|default:'utf-8'}">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Theme License Required</title>
    <style>
        body { margin: 0; font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif; background: #f5f5f7; color: #1d1d1f; }
        .mt-license-required { min-height: 100vh; display: grid; place-items: center; padding: 32px; box-sizing: border-box; }
        .mt-license-required-card { width: min(100%, 520px); padding: 32px; border-radius: 24px; background: #fff; box-shadow: 0 24px 80px rgba(0,0,0,.12); text-align: center; }
        .mt-license-required-card h1 { margin: 0 0 10px; font-size: 26px; line-height: 1.2; }
        .mt-license-required-card p { margin: 0; color: #6e6e73; line-height: 1.55; }
    </style>
</head>
<body class="mt-license-blocked">
    {include file="`$template`/error/license-required.tpl"}
    <div hidden aria-hidden="true">
{else}

{* auth state *}
{if $loggedin}{assign var=mt_auth value='in'}{else}{assign var=mt_auth value='out'}{/if}

{* preview mode — ?preview=1 unlocks the dev state-chip's live layout switch.
   The switch toggles between layouts in-browser via CSS, which needs all three
   rendered. Outside preview, the server renders ONLY the admin-picked layout. *}
{assign var=mt_preview value=false}
{if isset($smarty.get.preview) && $smarty.get.preview == '1'}{assign var=mt_preview value=true}{/if}

{* layout — resolved server-side from the admin Layouts pick (audience- and
   per-page-override-aware; see Hooks::resolveActiveLayout). vars.dataLayout is
   the body[data-layout] token: top|side|rail. ?layout= overrides in preview. *}
{assign var=mt_layout value=$myTheme.layouts['main-menu'].vars.dataLayout|default:'side'}
{if $mt_preview && isset($smarty.get.layout)}
    {assign var=_q value=$smarty.get.layout}
    {if $_q == 'top' || $_q == 'rail' || $_q == 'side'}{assign var=mt_layout value=$_q}{/if}
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
    {* WHMCS base URL declaration. Without this, scripts.min.js logs
       "Warning: The WHMCS Base URL definition is missing from your active
       template" on every page load and throws a TypeError trying to read
       WHMCS.BaseUrl.validateBaseUrl. The canonical fix per
       docs.whmcs.com/9-0/customization/whmcs-base-url-template/ is a
       <base> tag with the absolute install URL.
       Variable resolution order:
         1. $BASE_PATH_HREF -- the documented WHMCS variable. Empty on
            this install for unknown reasons; kept as the first option
            so other installs still work.
         2. Construct from $smarty.server -- scheme + host + WEB_ROOT.
            WEB_ROOT is empty for root installs (no subdirectory). *}
    <base href="{if $BASE_PATH_HREF}{$BASE_PATH_HREF}{else}{$smarty.server.REQUEST_SCHEME|default:'https'}://{$smarty.server.HTTP_HOST}{$WEB_ROOT}/{/if}">
    {* Admin-configured SEO (from the Pages tab) layers on top of WHMCS defaults.
       $myTheme.pages[<templatefile>] is populated by Hooks::resolveCurrentPage. *}
    {assign var=mt_pageEntry value=null}
    {if isset($myTheme.pages) && isset($myTheme.pages[$templatefile])}
        {assign var=mt_pageEntry value=$myTheme.pages[$templatefile]}
    {/if}
    <title>{if $mt_pageEntry && !empty($mt_pageEntry.seo.title)}{$mt_pageEntry.seo.title|escape}{else}{if $pagetitle}{$pagetitle} — {/if}{$companyname|escape}{/if}</title>
    {if $mt_pageEntry && !empty($mt_pageEntry.seo.description)}
        <meta name="description" content="{$mt_pageEntry.seo.description|escape}">
    {elseif $tagline}
        <meta name="description" content="{$tagline|escape}">
    {/if}
    {if $mt_pageEntry && $mt_pageEntry.indexing == 'disallow'}
        <meta name="robots" content="noindex, nofollow">
    {/if}
    {if $mt_pageEntry && !empty($mt_pageEntry.seo.social_image)}
        <meta property="og:image" content="{$mt_pageEntry.seo.social_image|escape}">
        <meta name="twitter:card" content="summary_large_image">
    {/if}
    {* Admin-uploaded favicon (from Branding tab). When absent the browser
       falls back to its default; we deliberately do NOT emit a stale
       /favicon.ico reference because most installs don't ship one. *}
    {if !empty($myTheme.branding.favicon)}
        <link rel="icon" href="{$myTheme.branding.favicon|escape}">
        <link rel="shortcut icon" href="{$myTheme.branding.favicon|escape}">
        {* Square logo (light) doubles as apple-touch-icon when set —
           mobile bookmarks pick this up over the favicon. *}
        {if !empty($myTheme.branding.square.light)}
            <link rel="apple-touch-icon" href="{$myTheme.branding.square.light|escape}">
        {/if}
    {/if}
    <link rel="stylesheet" href="{$WEB_ROOT}/templates/{$template}/assets/css/apple-theme.css?v={$myTheme.version|default:'1.0'}">
    <link rel="stylesheet" href="{$WEB_ROOT}/templates/{$template}/assets/css/apple-layout.css?v={$myTheme.version|default:'1.0'}">

    {* ── jQuery + Bootstrap 4 + plugins for all cart-flow pages ──
       Loaded on cart-flow pages regardless of which cart theme is
       active. mytheme_cart inherits from standard_cart and only
       overrides products.tpl with a custom Apple-language version —
       every other cart template comes from standard_cart and uses
       its scripts.min.js, which needs jQuery + Bootstrap + multiselect
       in scope. Synchronous load (no defer) because scripts.min.js
       executes mid-body and references:
         · $.fn.tooltip   (Bootstrap)
         · $.fn.modal     (Bootstrap)
         · $.fn.tab       (Bootstrap)
         · $.fn.multiselect  (Bootstrap-Multiselect — separate plugin)
         · csrfToken (top-level global, injected inline below) ── *}
    {if in_array($templatefile, ['cart','viewcart','configureproduct','configureproductdomain','configuredomains','checkout','products','domainregister','domaintransfer','domainoptions','ordersummary','addons','complete','fraudcheck'])}
        {* Globals that classic WHMCS themes inject inline before the cart
           scripts run. standard_cart's scripts.min.js references these
           directly as globals (not via window.X), so they need to be
           top-level `var` declarations before that file is parsed.
           Missing csrfToken → ReferenceError on the first form submit. *}
        <script>
            var csrfToken      = "{$token|escape:'javascript'}";
            var language       = "{$language|default:'english'|escape:'javascript'}";
            var WEB_ROOT       = "{$WEB_ROOT|escape:'javascript'}";
            var markdownGuideUri = "{$WEB_ROOT|escape:'javascript'}/index.php/markdown-guide";
            {* scripts.min.js's WHMCS.utils.validateBaseUrl() literally
               checks `typeof window.whmcsBaseUrl === "undefined"` and
               logs the "Base URL definition is missing" warning when
               true. The variable is camelCase with a lowercase whmcs
               prefix -- verified by case-mapping the minified source
               byte-for-byte. Set the global to the install root so
               the check passes. *}
            var whmcsBaseUrl = "{$smarty.server.REQUEST_SCHEME|default:'https'}://{$smarty.server.HTTP_HOST}{$WEB_ROOT}";
        </script>

        {* No SRI integrity attributes — adding them requires fetching the
           current canonical hash from the CDN, which we can't verify here.
           Re-add with correct hashes from https://www.srihash.org/ later
           if supply-chain hardening matters. *}
        <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-multiselect@1.1.2/dist/css/bootstrap-multiselect.min.css">
        <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@4.6.2/dist/js/bootstrap.bundle.min.js"></script>
        <script src="https://cdn.jsdelivr.net/npm/bootstrap-multiselect@1.1.2/dist/js/bootstrap-multiselect.min.js"></script>
    {/if}

    {$headoutput}
</head>
<body class="client-area-layout"
      data-auth="{$mt_auth}"
      data-layout="{$mt_layout}"
      data-active-nav="{$mt_activeNav|escape}"
      data-page-title="{$pagetitle|escape|default:'Page'}"
      data-tpl="{$templatefile|default:''|escape}"{if $mt_align} data-align="{$mt_align|escape}"{/if}{if $mt_subnav} data-subnav="{$mt_subnav|escape}"{/if}{if $mt_subnavSide} data-subnav-side="{$mt_subnavSide|escape}"{/if}{if $mt_svcLayout} data-svc-layout="{$mt_svcLayout|escape}"{/if}{if $mt_data} data-data="{$mt_data|escape}"{/if}{if $mt_tiles} data-tiles="{$mt_tiles|escape}"{/if}{if $mt_form} data-form="{$mt_form|escape}"{/if}{if $mt_plan} data-plan="{$mt_plan|escape}"{/if}{if $mt_product} data-product="{$mt_product|escape}"{/if}>

{$headeroutput}

{* Dev preview chip — renders only on ?preview=1 (never in the live portal) *}
{include file="`$template`/includes/partials/state-chip.tpl"}

{* ── Main-menu layout dispatch ──────────────────────────────────────────
   Production renders ONLY the admin-picked layout's chrome; ?preview=1
   renders all three so the state-chip can switch live via CSS. rail + sidebar
   are siblings before .ph-main-wrap; the top navbar renders inside it. *}
{if $mt_preview || $mt_layout == 'rail'}
    {include file="`$template`/includes/partials/rail.tpl"}
{/if}
{if $mt_preview || $mt_layout == 'side'}
    {include file="`$template`/includes/partials/sidebar.tpl"}
{/if}

<div class="ph-main-wrap">

    {if $mt_preview || $mt_layout == 'top'}
        {include file="`$template`/includes/partials/topnav.tpl"}
    {/if}
    {if $mt_preview || $mt_layout != 'top'}
        {include file="`$template`/includes/partials/inner-topbar.tpl"}
    {/if}

    {* Breadcrumb (top layout only): Apple-style single back-link to Home.
       The page title below carries the current page, so a "< Home" affordance
       is cleaner than a full "Home / Page" trail. *}
    {if $mt_preview || $mt_layout == 'top'}
    <nav class="ph-breadcrumb ph-breadcrumb-back only-top" aria-label="breadcrumb">
        <div class="ph-breadcrumb-inner">
            <a href="{$WEB_ROOT}/" class="ph-back-link">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"><polyline points="15 18 9 12 15 6"/></svg>
                {$LANG.home|default:'Home'}
            </a>
        </div>
    </nav>
    {/if}

    <div class="content-area">
{/if}
