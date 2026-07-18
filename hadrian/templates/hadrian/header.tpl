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
   Hadrian addon being active. The check below ALSO bypasses when the addon
   IS active and dev_mode is on (in which case canRender is set to true). *}
{assign var=mtLicenseGateEnabled value=false}

{if $mtLicenseGateEnabled && empty($hadrian.license.canRender)}
<!DOCTYPE html>
<html lang="{$activeLocale.languageCode|default:'en'}">
<head>
    <meta charset="{$charset|default:'utf-8'}">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{$hadrianLang.common.licenseRequiredTitle}</title>
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
{assign var=mt_layout value=$hadrian.layouts['main-menu'].vars.dataLayout|default:'side'}
{if $mt_preview && isset($smarty.get.layout)}
    {assign var=_q value=$smarty.get.layout}
    {if $_q == 'top' || $_q == 'rail' || $_q == 'side'}{assign var=mt_layout value=$_q}{/if}
{/if}

{* align — default from the active main-menu layout's saved option (admin
   Layouts card); ?align= overrides in preview. 'center' emits no attribute.
   Only non-top layouts honor data-align (apple-layout.css). *}
{assign var=mt_align value=$hadrian.layouts['main-menu'].options.align|default:'center'}
{if $mt_preview && isset($smarty.get.align)}
    {assign var=_q value=$smarty.get.align}
    {if $_q == 'center' || $_q == 'content' || $_q == 'left'}{assign var=mt_align value=$_q}{/if}
{/if}
{if $mt_align == 'center'}{assign var=mt_align value=''}{/if}

{* subnav (on/off) *}
{assign var=mt_subnav value=''}
{if isset($smarty.get.subnav)}
    {assign var=_q value=$smarty.get.subnav}
    {if $_q == 'on' || $_q == 'off'}{assign var=mt_subnav value=$_q}{/if}
{/if}

{* Sub-nav visibility is resolved in PHP (Hooks::resolveSubnav): per-page editor
   field > Settings exception-list picker > global toggle. header.tpl just maps the
   effective boolean to the body attribute the CSS reads. *}

{* order (cart) sub-nav → body[data-subnav-order]; consumed by hadrian_cart CSS
   (.st-split / .dp-split). The dev chip's ?subnav=off still overrides in preview. *}
{assign var=mt_subnavOrder value=''}
{if !($hadrian.subnav.order|default:true)}{assign var=mt_subnavOrder value='off'}{/if}
{if $mt_preview && isset($smarty.get.subnav) && $smarty.get.subnav == 'off'}
    {assign var=mt_subnavOrder value='off'}
{/if}

{* website (client-area) sub-nav → body[data-subnav-website]. Gated to NON-order
   pages so it never touches the cart's *-split grids (shared class names, e.g.
   cp-split). Consumed by apple-layout.css ([class$="-split"]). *}
{assign var=mt_isOrder value=false}
{if ($inShoppingCart|default:false) || in_array($templatefile|default:'', ['cart','viewcart','configureproduct','configureproductdomain','configuredomains','checkout','products','domainregister','domaintransfer','domainoptions','ordersummary','addons','complete','fraudcheck']) || (($templatefile|default:'')|strstr:'store')}
    {assign var=mt_isOrder value=true}
{/if}
{assign var=mt_subnavWebsite value=''}
{if !$mt_isOrder && !($hadrian.subnav.website|default:true)}
    {assign var=mt_subnavWebsite value='off'}
{/if}

{* subnav side *}
{assign var=mt_subnavSide value=''}
{if isset($smarty.get.subnavside)}
    {assign var=_q value=$smarty.get.subnavside}
    {if $_q == 'left' || $_q == 'right' || $_q == 'outside' || $_q == 'outside-left'}
        {assign var=mt_subnavSide value=$_q}
    {/if}
{/if}

{* services layout (inside/outside) — server-resolved from the admin "Service
   List Controls" toggle / per-page override (Hooks::resolveSvcLayout). Only
   'outside' emits an attribute; 'inside' is the CSS default (no attr), so the
   live DOM is unchanged for the default case. ?svclayout= overrides in preview only. *}
{assign var=mt_svcLayout value=''}
{if ($hadrian.svcLayout|default:'inside') == 'outside'}{assign var=mt_svcLayout value='outside'}{/if}
{if $mt_preview && isset($smarty.get.svclayout)}
    {assign var=_q value=$smarty.get.svclayout}
    {if $_q == 'outside'}{assign var=mt_svcLayout value='outside'}{elseif $_q == 'inside'}{assign var=mt_svcLayout value=''}{/if}
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
<!-- hadrian header v11 -->
<html lang="{$activeLocale.languageCode|default:'en'}" data-theme="{$mtThemeMode|default:'light'}" data-dark-mode="{$mtDarkMode|default:'off'}" data-header-sentinel="v11"{if $mt_palette} data-palette="{$mt_palette|escape}"{/if}>
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
       $hadrian.pages[<templatefile>] is populated by Hooks::resolveCurrentPage. *}
    {assign var=mt_pageEntry value=null}
    {if isset($hadrian.pages) && isset($hadrian.pages[$templatefile])}
        {assign var=mt_pageEntry value=$hadrian.pages[$templatefile]}
    {/if}
    {* Full-bleed pages (e.g. the login "split" variant) suppress the portal
       chrome below — nav, sidebar/rail, breadcrumb and footer. *}
    {assign var=mt_fullPage value=false}
    {if $mt_pageEntry && !empty($mt_pageEntry.fullPage)}{assign var=mt_fullPage value=true}{/if}
    {* ── SEO / social meta ───────────────────────────────────────────────
       Per-page title/description/robots/social image come from the admin
       Pages tab ($mt_pageEntry); canonical, og:url, og:type and the hreflang
       set are computed server-side in Hooks::resolveSeoContext ($hadrian.seo).
       Title + description are captured ONCE and reused across <title>, OG and
       Twitter so the three can never drift apart. The <title> keeps its prior
       behaviour: a custom SEO title renders verbatim; otherwise it's the WHMCS
       page title + company name. *}
    {capture name="mtTitle"}{if $mt_pageEntry && !empty($mt_pageEntry.seo.title)}{$mt_pageEntry.seo.title}{else}{if $pagetitle}{$pagetitle} — {/if}{$companyname}{/if}{/capture}
    {capture name="mtDesc"}{if $mt_pageEntry && !empty($mt_pageEntry.seo.description)}{$mt_pageEntry.seo.description}{elseif $tagline}{$tagline}{/if}{/capture}
    {assign var=mt_titleTag value=$smarty.capture.mtTitle}
    {assign var=mt_metaDesc value=$smarty.capture.mtDesc}

    <title>{$mt_titleTag|escape}</title>
    {if $mt_metaDesc}<meta name="description" content="{$mt_metaDesc|escape}">{/if}
    {if $mt_pageEntry && $mt_pageEntry.indexing == 'disallow'}<meta name="robots" content="noindex, nofollow">{/if}
    {if $hadrian.seo.canonical}<link rel="canonical" href="{$hadrian.seo.canonical|escape}">{/if}

    {* Open Graph *}
    <meta property="og:type" content="{$hadrian.seo.ogType|default:'website'}">
    <meta property="og:site_name" content="{$companyname|escape}">
    <meta property="og:title" content="{$mt_titleTag|escape}">
    {if $mt_metaDesc}<meta property="og:description" content="{$mt_metaDesc|escape}">{/if}
    {if $hadrian.seo.canonical}<meta property="og:url" content="{$hadrian.seo.canonical|escape}">{/if}
    {if $mt_pageEntry && !empty($mt_pageEntry.seo.social_image)}<meta property="og:image" content="{$mt_pageEntry.seo.social_image|escape}">{/if}

    {* Twitter Card *}
    <meta name="twitter:card" content="{if $mt_pageEntry && !empty($mt_pageEntry.seo.social_image)}summary_large_image{else}summary{/if}">
    <meta name="twitter:title" content="{$mt_titleTag|escape}">
    {if $mt_metaDesc}<meta name="twitter:description" content="{$mt_metaDesc|escape}">{/if}
    {if $mt_pageEntry && !empty($mt_pageEntry.seo.social_image)}<meta name="twitter:image" content="{$mt_pageEntry.seo.social_image|escape}">{/if}

    {* hreflang alternate links — emitted only when "Enable Alternate Links" is
       on AND at least one language code resolves (see resolveSeoContext). *}
    {if $hadrian.seo.hreflang}
        {foreach $hadrian.seo.hreflang as $mt_alt}
        <link rel="alternate" hreflang="{$mt_alt.code|escape}" href="{$mt_alt.url|escape}">
        {/foreach}
    {/if}
    {* Admin-uploaded favicon (from Branding tab). When absent the browser
       falls back to its default; we deliberately do NOT emit a stale
       /favicon.ico reference because most installs don't ship one. *}
    {if !empty($hadrian.branding.favicon)}
        <link rel="icon" href="{$hadrian.branding.favicon|escape}">
        <link rel="shortcut icon" href="{$hadrian.branding.favicon|escape}">
        {* Square logo (light) doubles as apple-touch-icon when set —
           mobile bookmarks pick this up over the favicon. *}
        {if !empty($hadrian.branding.square.light)}
            <link rel="apple-touch-icon" href="{$hadrian.branding.square.light|escape}">
        {/if}
    {/if}
    <link rel="stylesheet" href="{$WEB_ROOT}/templates/{$template}/assets/css/apple-theme.css?v={$hadrian.version|default:'1.0'}">
    <link rel="stylesheet" href="{$WEB_ROOT}/templates/{$template}/assets/css/apple-layout.css?v={$hadrian.version|default:'1.0'}">

    {* ── jQuery + Bootstrap 4 + plugins for all cart-flow pages ──
       Loaded on cart-flow pages regardless of which cart theme is
       active. hadrian_cart inherits from standard_cart and only
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
<body class="{if $mt_fullPage}mt-login-fullpage{else}client-area-layout{/if}"
      data-auth="{$mt_auth}"
      data-layout="{$mt_layout}"
      data-active-nav="{$mt_activeNav|escape}"
      data-page-title="{$pagetitle|escape|default:'Page'}"
      data-tpl="{$templatefile|default:''|escape}"{if ($templatefile|default:''|strstr:'store') && !($templatefile|default:''|strstr:'order') && !($templatefile|default:''|strstr:'not-found')} data-bleed="1"{/if}{if $mt_align} data-align="{$mt_align|escape}"{/if}{if $mt_subnav} data-subnav="{$mt_subnav|escape}"{/if}{if $mt_subnavOrder} data-subnav-order="{$mt_subnavOrder|escape}"{/if}{if $mt_subnavWebsite} data-subnav-website="{$mt_subnavWebsite|escape}"{/if}{if $mt_subnavSide} data-subnav-side="{$mt_subnavSide|escape}"{/if}{if $mt_svcLayout} data-svc-layout="{$mt_svcLayout|escape}"{/if}{if $mt_data} data-data="{$mt_data|escape}"{/if}{if $mt_tiles} data-tiles="{$mt_tiles|escape}"{/if}{if $mt_form} data-form="{$mt_form|escape}"{/if}{if $mt_plan} data-plan="{$mt_plan|escape}"{/if}{if $mt_product} data-product="{$mt_product|escape}"{/if}{if $hadrian.addonSettings.hide_breadcrumb} data-hide-breadcrumb="1"{/if}{if $hadrian.addonSettings.affixed_navigation} data-affixed-nav="1"{/if}{if !($hadrian.addonSettings.capitalize_titles|default:true)} data-capitalize-titles="0"{/if}{if $hadrian.addonSettings.hide_cycle_discounts} data-hide-discounts="1"{/if}>

{$headeroutput}

{if !$mt_fullPage}
{* Dev preview chip — renders only on ?preview=1 (never in the live portal) *}
{include file="`$template`/includes/partials/state-chip.tpl"}

{* ── Main-menu layout dispatch ──────────────────────────────────────────
   Production renders ONLY the admin-picked layout's chrome; ?preview=1
   renders all three so the state-chip can switch live via CSS. rail + sidebar
   are siblings before .ph-main-wrap; the top navbar renders inside it. *}
{if $mt_preview || $mt_layout == 'rail'}
    {include file="`$template`/includes/partials/rail.tpl"}
{/if}
{* Sidebar also renders on the TOP layout, where it stays off-canvas and acts
   as the mobile slide-in drawer (opened by the top-nav hamburger). CSS scoped
   to body[data-layout="top"] keeps it hidden until .nav-open. *}
{if $mt_preview || $mt_layout == 'side' || $mt_layout == 'top'}
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
       is cleaner than a full "Home / Page" trail. Skipped on the portal home
       page ($_tf == 'homepage'), where "back to Home" would point at itself. *}
    {if ($mt_preview || $mt_layout == 'top') && $_tf != 'homepage'}
    <nav class="ph-breadcrumb ph-breadcrumb-back only-top" aria-label="breadcrumb">
        <div class="ph-breadcrumb-inner">
            <a href="{$WEB_ROOT}/" class="ph-back-link">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"><polyline points="15 18 9 12 15 6"/></svg>
                {$LANG.home|default:'Portal Home'}
            </a>
        </div>
    </nav>
    {/if}

    <div class="content-area">
    {* Email-verification banner (renders only when WHMCS flags the email unverified). *}
    {include file="`$template`/includes/verifyemail.tpl"}
    {/if}{* end portal chrome (skipped when fullPage) *}
{/if}
