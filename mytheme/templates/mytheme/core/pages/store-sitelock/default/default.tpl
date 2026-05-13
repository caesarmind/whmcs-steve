{* Store landing — Website Security (SiteLock).
   Ported from apple-client-area/store/sitelock.html (2026-05-13).

   WHMCS MarketConnect populates $marketconnect / $product variables when
   the integration is connected — we read them with fallbacks to the
   mockup price/copy so the page renders cleanly even when MarketConnect
   isn't configured. Admin can override SEO + variant via the Pages tab. *}

<link rel="stylesheet" href="{$WEB_ROOT}/templates/{$template}/assets/css/pages/store-sitelock.css?v={$myTheme.version|default:'1.0'}">

<div class="store-landing store-sitelock">

    {* Cross-nav to sibling store landings. Same pattern as Nexus's
       store/<slug>/shared/nav.tpl, kept inline for now since we only have one
       layout. Active state highlights the current page. *}
    <nav class="store-nav" aria-label="Store products">
        <a href="{$WEB_ROOT}/store/ssl">SSL Certificates</a>
        <a href="{$WEB_ROOT}/store/weebly">Website Builder</a>
        <a href="{$WEB_ROOT}/store/sitelock" class="is-active" aria-current="page">Website Security</a>
        <a href="{$WEB_ROOT}/store/spamexperts">Email Services</a>
        <a href="{$WEB_ROOT}/store/codeguard">Website Backup</a>
        <a href="{$WEB_ROOT}/store/marketgoo">SEO Tools</a>
        <a href="{$WEB_ROOT}/store/ox">Professional Email</a>
        <a href="{$WEB_ROOT}/store/sitebuilder">Site Builder</a>
    </nav>

    {* Hero — product brand, tagline, pricing, CTA. *}
    <div class="store-hero">
        <div class="store-hero-icon tile-icon green" aria-hidden="true">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                <rect x="3" y="11" width="18" height="11" rx="2"/>
                <path d="M7 11V7a5 5 0 0 1 10 0v4"/>
            </svg>
        </div>
        <div class="store-hero-content">
            <h1>{if $LANG.storesitelocktitle}{$LANG.storesitelocktitle}{else}SiteLock Website Security{/if}</h1>
            <p>{if $LANG.storesitelocktagline}{$LANG.storesitelocktagline}{else}Malware scanning, firewall &amp; vulnerability patching.{/if}</p>

            {* Pricing — prefer WHMCS MarketConnect's resolved price (locale +
               currency aware). Fall back to mockup placeholder when the
               integration isn't connected, so the page never renders empty. *}
            <div class="store-hero-pricing">
                {if !empty($marketconnect.sitelock.pricing.monthly)}
                    <span class="store-hero-price">{$marketconnect.sitelock.pricing.monthly}</span>
                {elseif !empty($marketconnect.sitelock.fromPrice)}
                    <span class="store-hero-price">{$marketconnect.sitelock.fromPrice}</span>
                {else}
                    <span class="store-hero-price">$5.00</span>
                {/if}
                <span class="store-hero-cycle">/ mo</span>
            </div>

            <div class="store-hero-cta">
                {assign var=mt_orderUrl value=$marketconnect.sitelock.orderUrl|default:"{$WEB_ROOT}/cart.php?gid=marketconnect"}
                <a href="{$mt_orderUrl|escape}" class="btn-primary btn-lg">Add to cart</a>
                <a href="{$mt_orderUrl|escape}" class="btn-secondary btn-lg">Configure</a>
            </div>
        </div>
    </div>

    {* Feature list. MarketConnect doesn't typically expose a structured feature
       array, so the list lives in the template — easy to translate via
       $LANG keys when needed. *}
    <section class="store-features">
        <h2>What&rsquo;s included</h2>
        <ul class="feature-list">
            <li>Daily malware scans</li>
            <li>Web application firewall (WAF)</li>
            <li>Auto-patching for WordPress &amp; plugins</li>
            <li>PCI-compliance scan tool</li>
        </ul>
    </section>

    {* FAQ — static, edit copy in this file or convert each line to a
       $LANG.storesitelockfaqXq / $LANG.storesitelockfaqXa pair for i18n. *}
    <section class="store-faq">
        <h2>Questions</h2>
        <div class="faq-item">
            <div class="faq-q">How is this billed?</div>
            <div class="faq-a">Monthly or annually alongside your other services. Cancel anytime from the dashboard.</div>
        </div>
        <div class="faq-item">
            <div class="faq-q">Can I use this on a site I host elsewhere?</div>
            <div class="faq-a">Yes. Most add-ons work with any hosting provider; we&rsquo;ll guide setup in your welcome email.</div>
        </div>
        <div class="faq-item">
            <div class="faq-q">Is there a free trial?</div>
            <div class="faq-a">We offer a 30-day money-back guarantee. Try it risk-free.</div>
        </div>
    </section>

</div>
