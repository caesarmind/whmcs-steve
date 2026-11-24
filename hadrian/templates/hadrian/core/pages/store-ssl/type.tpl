{* SSL certificate type page: /store/<ssl slug>/dv | ov | ev | wildcard.

   WHMCS renders store/ssl/<type>.tpl for each certificate class; the four
   dispatchers include this with sslType set. Same data as stock twenty-one:
     $certificates.<type>[]     products (id, configoption1, isFeatured,
                                pricing()->annual()/biennial()/triennial())
     $certificateFeatures[<configoption1>]  displayName, issuance, for, warranty
     $certTypes.<type>          count per class (drives the type nav)
     $hasFeatured.<type>        a "Recommended" product exists
     $routePathSlug             the SSL product group's slug
     $inCompetitiveUpgrade / $competitiveUpgradeDomain   arrived from the
                                competitive-upgrade check
     $currencies / $activeCurrency   guest currency switch
   Copy is WHMCS's own store.ssl.* strings, so WHMCS's translations apply.
   Buy posts the product to the cart-order route, as stock does. *}
{assign var=sslCerts value=[]}
{assign var=sslCount value=0}
{if isset($certificates[$sslType])}{assign var=sslCerts value=$certificates[$sslType]}{assign var=sslCount value=$certificates[$sslType]|@count}{/if}
{assign var=sslFeatured value=false}
{if isset($hasFeatured[$sslType]) && $hasFeatured[$sslType]}{assign var=sslFeatured value=true}{/if}

<script>
(function () {
    var b = document.body;
    if (b) b.setAttribute('data-svc-layout', 'inside');
})();
</script>
<style>{literal}
.hn-ssl-nav{display:flex;flex-wrap:wrap;justify-content:center;gap:8px;padding:0 22px 8px}
.hn-ssl-nav a{padding:8px 16px;border-radius:999px;background:var(--color-surface-secondary);color:var(--color-text-secondary);font-size:var(--text-sm);font-weight:var(--fw-medium);text-decoration:none}
.hn-ssl-nav a.active,.hn-ssl-nav a:hover{background:var(--color-accent);color:#fff}
.hn-ssl-wrap{max-width:var(--w-prose);margin:0 auto;padding:48px 22px}
.hn-ssl-wrap h2{margin:0 0 12px}
.hn-ssl-copy{color:var(--color-text-secondary);line-height:1.6}
.hn-ssl-plan{display:grid;grid-template-columns:minmax(0,1.4fr) repeat(3,minmax(0,1fr)) auto;gap:16px;align-items:center;padding:20px;border-radius:14px;background:var(--color-surface-secondary)}
.hn-ssl-plan.featured{box-shadow:inset 0 0 0 2px var(--color-accent)}
.hn-ssl-plan-name{font-weight:var(--fw-semibold);font-size:var(--text-lg);color:var(--color-text-primary)}
.hn-ssl-plan-meta{font-size:var(--text-sm);color:var(--color-text-secondary);margin-top:4px;line-height:1.5}
.hn-ssl-plan-tag{display:inline-block;margin-left:8px;padding:2px 8px;border-radius:999px;background:var(--color-accent);color:#fff;font-size:var(--text-xs);font-weight:var(--fw-semibold);vertical-align:middle}
.hn-ssl-price{text-align:right}
.hn-ssl-price strong{display:block;font-size:var(--text-lg);color:var(--color-text-primary)}
.hn-ssl-price span{font-size:var(--text-xs);color:var(--color-text-tertiary)}
.hn-ssl-logos{display:flex;flex-wrap:wrap;justify-content:center;align-items:center;gap:40px;margin-top:20px}
.hn-ssl-logos img{max-height:40px;width:auto}
@media (max-width:760px){.hn-ssl-plan{grid-template-columns:1fr 1fr}.hn-ssl-plan>:first-child{grid-column:1/-1}.hn-ssl-price{text-align:left}}
{/literal}</style>

{* 1. Hero *}
<section class="hp-hero-split" style="padding: 60px 22px 32px;">
    <div class="hp-split-text">
        <div class="hp-eyebrow">{lang key='store.ssl.shared.pricing'}</div>
        <h1>{lang key="store.ssl.`$sslType`.title"}</h1>
        <p>{lang key="store.ssl.`$sslType`.tagline"}</p>
        {if $sslCount > 0}
        <div class="hp-cta-row"><a href="#pricing" class="hp-buy-btn">{lang key='store.ssl.landingPage.buyNow'}</a></div>
        {/if}
    </div>
</section>

{* 2. Certificate type navigation (stock shared/nav.tpl) *}
<nav class="hn-ssl-nav" aria-label="{lang key='store.ssl.shared.pricing'}">
    <a href="{routePath('store-product-group', $routePathSlug)}">{lang key='overview'}</a>
    {if (isset($certTypes.dv) && $certTypes.dv > 0) || (isset($inPreview) && $inPreview)}<a href="{routePath('store-product-group', $routePathSlug, 'dv')}"{if $sslType == 'dv'} class="active" aria-current="page"{/if}>{lang key='store.ssl.shared.dvSsl'}</a>{/if}
    {if (isset($certTypes.wildcard) && $certTypes.wildcard > 0) || (isset($inPreview) && $inPreview)}<a href="{routePath('store-product-group', $routePathSlug, 'wildcard')}"{if $sslType == 'wildcard'} class="active" aria-current="page"{/if}>{lang key='store.ssl.shared.wcSsl'}</a>{/if}
    {if (isset($certTypes.ov) && $certTypes.ov > 0) || (isset($inPreview) && $inPreview)}<a href="{routePath('store-product-group', $routePathSlug, 'ov')}"{if $sslType == 'ov'} class="active" aria-current="page"{/if}>{lang key='store.ssl.shared.ovSsl'}</a>{/if}
    {if (isset($certTypes.ev) && $certTypes.ev > 0) || (isset($inPreview) && $inPreview)}<a href="{routePath('store-product-group', $routePathSlug, 'ev')}"{if $sslType == 'ev'} class="active" aria-current="page"{/if}>{lang key='store.ssl.shared.evSsl'}</a>{/if}
</nav>

{if isset($inCompetitiveUpgrade) && $inCompetitiveUpgrade}
<div class="hn-ssl-wrap" style="padding-bottom:0;">
    <div class="callout info" role="status">
        <div class="callout-text">
            <strong style="display:block;margin-bottom:4px">{lang key="store.ssl.competitiveUpgrade"}</strong>
            {lang key="store.ssl.competitiveUpgradeBannerMsg" domain=$competitiveUpgradeDomain}
        </div>
    </div>
</div>
{/if}

{* 3. What this certificate class is, and what it suits *}
<section class="hn-ssl-wrap">
    <h2>{lang key="store.ssl.`$sslType`.descriptionTitle"}</h2>
    <div class="hn-ssl-copy">{lang key="store.ssl.`$sslType`.descriptionContent"}</div>
    {if $sslType == 'ov' || $sslType == 'ev'}
        <h3 style="margin:28px 0 8px;">{lang key="store.ssl.`$sslType`.orgInfo"}</h3>
        <div class="hn-ssl-copy">{lang key="store.ssl.`$sslType`.orgInfoDescription"}</div>
    {/if}
</section>

{if $sslType != 'wildcard'}
<section class="hp-icon-grid" style="padding: 8px 22px 40px;">
    {if $sslType == 'dv'}
        {assign var=sslUses value=['blogs','infoPages','serverComms']}
    {elseif $sslType == 'ov'}
        {assign var=sslUses value=['loginPages','intranetSites','webmail']}
    {else}
        {assign var=sslUses value=['criticalDomains','ecommerce','signupPages']}
    {/if}
    {foreach $sslUses as $sslUse}
    <div class="hp-icon-item">
        <div class="icon-circle {if $sslUse@index == 0}blue{elseif $sslUse@index == 1}green{else}purple{/if}"><svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="11" width="18" height="11" rx="2"/><path d="M7 11V7a5 5 0 0110 0v4"/></svg></div>
        {if $sslUse@first}<p style="font-size:var(--text-xs);text-transform:uppercase;letter-spacing:.06em;color:var(--color-text-tertiary);margin:0 0 4px;">{lang key='store.ssl.useCases.title'}</p>{/if}
        <h4>{lang key="store.ssl.useCases.$sslUse"}</h4>
    </div>
    {/foreach}
</section>
{/if}

{* 4. Pricing (stock shared/certificate-pricing.tpl) *}
<section class="hn-ssl-wrap" id="pricing">
    <div style="display:flex;flex-wrap:wrap;justify-content:space-between;align-items:center;gap:12px;margin-bottom:20px;">
        <h2 style="margin:0;">{lang key='store.ssl.shared.pricing'}</h2>
        {if !$loggedin && isset($currencies) && $currencies}
        <form method="post" action="">
            <select name="currency" class="form-select" onchange="this.form.submit()" aria-label="{lang key='changeCurrency'}">
                <option>{lang key="changeCurrency"} ({$activeCurrency.prefix} {$activeCurrency.code})</option>
                {foreach $currencies as $currency}
                    <option value="{$currency['id']}">{$currency['prefix']} {$currency['code']}</option>
                {/foreach}
            </select>
        </form>
        {/if}
    </div>

    <div style="display:grid;gap:12px;">
        {if $sslCount > 0}
            {foreach $sslCerts as $product}
                {assign var=sslFeat value=[]}
                {if isset($certificateFeatures[$product->configoption1])}{assign var=sslFeat value=$certificateFeatures[$product->configoption1]}{/if}
                <div class="hn-ssl-plan{if $sslFeatured && $product->isFeatured} featured{/if}">
                    <div>
                        <div class="hn-ssl-plan-name">{$sslFeat.displayName|default:$product->name}{if $sslFeatured && $product->isFeatured}<span class="hn-ssl-plan-tag">{lang key='recommended'}</span>{/if}</div>
                        <div class="hn-ssl-plan-meta">
                            {lang key='store.ssl.shared.issuanceTime'}: {$sslFeat.issuance|default:'-'}<br>
                            {lang key='store.ssl.shared.greatFor'}: {$sslFeat.for|default:'-'}<br>
                            {lang key='store.ssl.shared.warrantyValue'}: {if $sslFeat.warranty}USD ${$sslFeat.warranty}{else}-{/if}
                        </div>
                    </div>
                    <div class="hn-ssl-price"><strong>{if $product->pricing()->annual()}{$product->pricing()->annual()->yearlyPrice()}{else}-{/if}</strong><span>{lang key='store.ssl.shared.oneYearPrice'}</span></div>
                    <div class="hn-ssl-price"><strong>{if $product->pricing()->biennial()}{$product->pricing()->biennial()->yearlyPrice()}{else}-{/if}</strong><span>{lang key='store.ssl.shared.twoYearPrice'}</span></div>
                    <div class="hn-ssl-price"><strong>{if $product->pricing()->triennial()}{$product->pricing()->triennial()->yearlyPrice()}{else}-{/if}</strong><span>{lang key='store.ssl.shared.threeYearPrice'}</span></div>
                    <form method="post" action="{routePath('cart-order')}">
                        <input type="hidden" name="pid" value="{$product->id}">
                        <button type="submit" class="hp-buy-btn">{lang key='store.ssl.landingPage.buyNow'}</button>
                    </form>
                </div>
            {/foreach}
        {else}
            <p style="text-align:center;color:var(--color-text-tertiary);padding:24px;">{lang key='store.ssl.shared.noProducts'}</p>
        {/if}
    </div>
    <p style="text-align:center;margin-top:20px;"><a href="{routePath('store-product-group', $routePathSlug)}#helpmechoose">{lang key='store.ssl.shared.helpMeChoose'}</a></p>
</section>

{* 5. Features (stock shared/features.tpl) *}
<section class="hp-features-section" style="padding: 56px 22px;">
    <div class="hp-feature-cards" style="display:grid;grid-template-columns:repeat(auto-fit,minmax(240px,1fr));gap:16px;max-width: var(--w-prose); margin: 0 auto;">
        <div class="hp-feature-card">
            {if $sslType == 'ev'}<h4>{lang key='store.ssl.shared.ev.visualVerification'}</h4><p>{lang key='store.ssl.shared.ev.visualVerificationDescription'}</p>
            {elseif $sslType == 'ov'}<h4>{lang key='store.ssl.shared.ov.ov'}</h4><p>{lang key='store.ssl.shared.ov.ovDescription'}</p>
            {else}<h4>{lang key='store.ssl.shared.delivery'}</h4><p>{lang key='store.ssl.shared.deliveryDescription'}</p>{/if}
        </div>
        <div class="hp-feature-card">
            <h4>{lang key='store.ssl.shared.siteSeal'}</h4><p>{lang key='store.ssl.shared.siteSealDescription'}</p>
        </div>
        <div class="hp-feature-card">
            {if $sslType == 'ev'}<h4>{lang key='store.ssl.shared.ev.warranty'}</h4><p>{lang key='store.ssl.shared.ev.warrantyDescription'}</p>
            {elseif $sslType == 'ov'}<h4>{lang key='store.ssl.shared.ov.warranty'}</h4><p>{lang key='store.ssl.shared.ov.warrantyDescription'}</p>
            {else}<h4>{lang key='store.ssl.shared.googleRanking'}</h4><p>{lang key='store.ssl.shared.googleRankingDescription'}</p>{/if}
        </div>
    </div>
    <h2 style="text-align:center;margin:48px 0 20px;">{lang key='store.ssl.shared.features'}</h2>
    <div class="hp-feature-cards cols-4" style="max-width: var(--w-prose); margin: 0 auto;">
        <div class="hp-feature-card"><h4>{lang key='store.ssl.shared.encryptData'}</h4></div>
        <div class="hp-feature-card"><h4>{lang key='store.ssl.shared.secureTransactions'}</h4></div>
        <div class="hp-feature-card"><h4>{lang key='store.ssl.shared.legitimacy'}</h4></div>
        <div class="hp-feature-card"><h4>{lang key='store.ssl.shared.fastestSsl'}</h4></div>
        <div class="hp-feature-card"><h4>{lang key='store.ssl.shared.browserCompatability'}</h4></div>
        <div class="hp-feature-card"><h4>{lang key='store.ssl.shared.seoRank'}</h4></div>
        <div class="hp-feature-card"><h4>{if $sslType == 'ev'}{lang key='store.ssl.shared.ev.issuance'}{elseif $sslType == 'ov'}{lang key='store.ssl.shared.ov.issuance'}{else}{lang key='store.ssl.shared.issuance'}{/if}</h4></div>
        <div class="hp-feature-card"><h4>{lang key='store.ssl.shared.freeReissues'}</h4></div>
    </div>
</section>

{* 6. Certificate brands (stock shared/logos.tpl) *}
<section class="hn-ssl-wrap" style="text-align:center;">
    <p class="hn-ssl-copy">{lang key='store.ssl.shared.trusted'}</p>
    <div class="hn-ssl-logos">
        <img src="{$WEB_ROOT}/assets/img/marketconnect/symantec/rapidssl-logo.png" alt="RapidSSL">
        <img src="{$WEB_ROOT}/assets/img/marketconnect/symantec/geotrust-logo.png" alt="GeoTrust">
        <img src="{$WEB_ROOT}/assets/img/marketconnect/symantec/symantec-logo.png" alt="DigiCert">
    </div>
</section>
