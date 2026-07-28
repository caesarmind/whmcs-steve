{* Hostnodes - Public marketing homepage, "Simple" variant.

   A deliberately lean five-section landing page: hero + domain search, the real
   product catalogue, four capability tiles, latest announcements, one closing
   CTA. Roughly half the length of the 'default' marketing variant, with no
   invented metrics and no new CSS -- every class used already ships in
   assets/css/apple-theme.css, assets/css/apple-layout.css or
   assets/css/pages/homepage.css.

   Section ideas mapped from Lagom 2.3 homepage/modern (7 sections), rendered
   entirely in the Apple/Hadrian visual language -- ideas only, none of Lagom's
   markup idiom, class names, Bootstrap grid or icon font:
     Lagom 1 + 2  banner slider + domain search -> section 1 (merged, static)
     Lagom 3      promoted product groups       -> section 2 (real WHMCS groups)
     Lagom 4      8-tile "Our Guarantees" grid  -> section 3 (cut to 4 tiles)
     Lagom 5      testimonials                  -> DROPPED, no WHMCS source
     Lagom 6      latest news                   -> section 4 (real announcements)
     Lagom 7      "Let's Get Started!" CTA      -> section 5

   The one structural habit borrowed wholesale from Lagom: every section gates
   on its DATA as well as on its admin toggle, so a section never renders as an
   empty shell.

   Deliberately NOT carried over from the 'default' variant: the 10K+ / 99.9% /
   < 1s / 24/7 stats strip and the white-label mock-panel block. Both assert
   figures and capabilities with no source behind them.

   WHMCS / Hadrian variables expected:
     $homeProductGroups, $homeTldPricing   <- Hooks::clientAreaPageHomepage
     $announcements, $carbon               <- WHMCS native on homepage.tpl
     $registerdomainenabled, $transferdomainenabled
     $captcha, $captchaForm, $LANG.*, $hadrianLang.*, $WEB_ROOT, $template *}

{* Admin page options. NOTE THE PATH: $hadrian.pages.homepage.options.<key>.
   Hooks::resolveCurrentPage builds the per-page entry with an 'options' member
   and NO 'config' member, so the $hadrian.pages.homepage.config.* path the
   other two homepage variants use always resolves empty. Options are also not
   merged with their declared defaults at render time (the stored array is taken
   raw), so every read carries its own |default:. That round-trips correctly:
   before the first save the key is absent so |default: fires, and the admin
   editor posts a hidden 0 alongside each checkbox so switching a default-on
   toggle off stores a real false. Declared in ../page.php 'supportedOptions'. *}
{assign var=_hTitle       value=$hadrian.pages.homepage.options.heroTitle|default:''}
{assign var=_hSub         value=$hadrian.pages.homepage.options.heroSubtitle|default:''}
{assign var=_showDomain   value=$hadrian.pages.homepage.options.show_domain_search|default:true}
{assign var=_showProducts value=$hadrian.pages.homepage.options.show_products|default:true}
{assign var=_showFeatures value=$hadrian.pages.homepage.options.show_features|default:true}
{assign var=_showNews     value=$hadrian.pages.homepage.options.show_news|default:true}
{assign var=_showCta      value=$hadrian.pages.homepage.options.show_cta|default:true}

{* Real-data state.
   $homeProductGroups is the primary dynamic content on this page, so it drives
   the page-wide full/empty flag; announcements and the TLD strip gate
   themselves on their own presence as well. *}
{assign var=hpGroups   value=$homeProductGroups|default:[]}
{assign var=groupCount value=$hpGroups|@count}
{assign var=annCount   value=$announcements|default:[]|@count}
{if $groupCount > 0}
    {assign var=dashIsEmpty value='full'}
{else}
    {assign var=dashIsEmpty value='empty'}
{/if}

{* NOT optional: pages/homepage.css is the only file defining .ph-domain-form,
   .ph-domain-box, .search-ico, .ph-domain-footer, .ph-captcha and the
   .hp-tld-* strip. Without this link the whole hero form renders unstyled.
   Cache-bust reads $hadrian.version (core/hadrian.php), not theme.json. *}
<link rel="stylesheet" href="{$WEB_ROOT}/templates/{$template}/assets/css/pages/homepage.css?v={$hadrian.version|default:'1.0'}">

{* Stamps body[data-data] so apple-layout.css can show exactly one of the
   .when-full / .when-empty branches in section 2. *}
<script>
(function () {
    var b = document.body;
    if (!b) return;
    b.setAttribute('data-data', '{$dashIsEmpty}');
})();
</script>

{* ================================================================
   SECTION 1 -- Hero + domain search + live TLD prices.
   Lagom sections 1 and 2 merged. Lagom's multi-slide banner machinery,
   pagination tiles, autoplay and MarketConnect data gate are all dropped: a
   static Apple hero says the same thing with none of the gating. The search
   box is the page's single primary action, so the 'default' variant's trailing
   .hp-cta-row is deliberately not carried over -- a second CTA row beside a
   working search field only duplicates it.
   ================================================================ *}
<section class="hp-hero">
    <div class="hp-eyebrow">{$hadrianLang.home.heroEyebrow}</div>
    {* |escape on the overrides, not on the lang fallbacks: the override is
       admin-typed free text arriving straight from the page-options form, while
       the $hadrianLang strings are ours and may legitimately carry entities. *}
    <h1>{if $_hTitle != ''}{$_hTitle|escape}{else}{$hadrianLang.home.heroTitle}{/if}</h1>
    <p class="hp-subhead">{if $_hSub != ''}{$_hSub|escape}{else}{$hadrianLang.home.heroSubtitle}{/if}</p>

    {* Double-gated the way Lagom gates its own search block: the admin toggle
       AND $registerdomainenabled, so the form never renders as a dead control
       on an install with domain registration switched off. *}
    {if $_showDomain && $registerdomainenabled}
    <form class="ph-domain-form" action="{$WEB_ROOT}/domainchecker.php" method="post">
        <div class="ph-domain-tabs" role="tablist">
            <button type="button" class="active" data-dtab="search" role="tab" aria-selected="true">{$LANG.search|default:'Search'}</button>
            {if $transferdomainenabled}
            <button type="button" data-dtab="transfer" role="tab" aria-selected="false">{$LANG.transferdomain|default:'Transfer'}</button>
            {/if}
        </div>
        <div class="ph-domain-box">
            <svg class="search-ico" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
            <input type="text" name="domain" placeholder="{$LANG.exampledomain|default:'yourdomain.com'}" autocapitalize="none" autocomplete="off">
            <button type="submit" id="domainCta" class="{if isset($captcha) && $captcha}{$captcha->getButtonClass($captchaForm)}{/if}">{$LANG.search|default:'Search'}</button>
        </div>
        {* $captcha is an OBJECT: gate on isEnabled()/isEnabledForForm() and let
           includes/captcha.tpl emit the widget. reCAPTCHA api.js is injected by
           {$headoutput}, so no extra script tag here. *}
        {if isset($captcha) && $captcha->isEnabled() && $captcha->isEnabledForForm($captchaForm)}
        <div class="ph-captcha">{include file="`$template`/includes/captcha.tpl"}</div>
        {/if}
        {* Live TLD register prices (Hooks::fetchDomainTldPricing -> localAPI
           GetTLDPricing, visitor's currency). Already formatted PHP-side, so no
           |money and no currency prefix here. Renders nothing when WHMCS has no
           priced TLDs, so the hero never shows an empty rail. *}
        {if $homeTldPricing}
        <div class="hp-tld-strip">
            {foreach $homeTldPricing as $mtTld}
                <a class="hp-tld" href="{$WEB_ROOT}/cart.php?a=add&domain=register">
                    <span class="hp-tld-ext">{$mtTld.tld|escape}</span>
                    <span class="hp-tld-price">{$mtTld.price|escape}</span>
                </a>
            {/foreach}
        </div>
        {/if}
        <div class="ph-domain-footer">
            <span>{$hadrianLang.dashboard.heroDomainSubtitle}</span>
            {* Cart domain-registration step, which lists TLD pricing AND lets
               the visitor buy in one place. NOT cart.php?gid=domain -- WHMCS has
               no group with that id, so it 302s onto the hosting list. *}
            <a href="{$WEB_ROOT}/cart.php?a=add&domain=register">{$LANG.viewallpricing|default:'View all pricing'} &rarr;</a>
        </div>
    </form>
    {/if}
</section>

{* ================================================================
   SECTION 2 -- Product groups (real WHMCS catalogue).
   Lagom section 3, "Products For All Businesses": icon, group name, tagline,
   "Starting at", price with billing-cycle suffix, one CTA into the cart. Two
   pieces of Lagom bloat dropped -- its hardcoded gid array (Hadrian queries the
   catalogue, which is strictly better) and its productGroupPriceDisplay
   billing-cycle select (Hadrian already picks the cheapest cycle per group, and
   "Starting at" answers the question).

   $homeProductGroups comes from Hooks::clientAreaPageHomepage(); each entry is
   {gid, name, tagline, url, fromPrice, cycle}. fromPrice is null when the group
   has no positively-priced product, so the price rows are gated and a group
   renders name + tagline + link rather than a fake price. fromPrice arrives
   pre-formatted and is deliberately NOT escaped; name/tagline are.

   .hp-price-card.pc-group restyles .buy from a filled pill into a quiet accent
   text link with an auto chevron -- correct here, since a row of solid slabs
   would outweigh the group names above them.
   ================================================================ *}
{if $_showProducts}
<section class="hp-pricing-segmented" id="pricing">
    <h2>{$hadrianLang.home.pricingTitle}</h2>
    <p class="sub">{$hadrianLang.home.pricingSub}</p>

    <div class="when-full">
        {* cols-N, never an inline grid-template-columns: an inline value
           outranks the max-width:820px collapse in apple-theme.css, which is
           how the store pages once ended up hundreds of px wide on phones. *}
        <div class="hp-pricing-grid{if $groupCount > 0 && $groupCount < 3} cols-{$groupCount}{/if}">
            {foreach $hpGroups as $grp}
            <div class="hp-price-card pc-group">
                <h3>{$grp.name|escape}</h3>
                {if $grp.tagline}<p class="pc-tagline">{$grp.tagline|escape}</p>{/if}
                {if $grp.fromPrice}
                <div class="pc-from">{$hadrianLang.home.startingAt}</div>
                <div class="price-row"><span class="price">{$grp.fromPrice}</span></div>
                <div class="pc-cycle">{$hadrianLang.home.cycleName[$grp.cycle]|default:''}</div>
                {/if}
                {* url is relative, so the WEB_ROOT prefix is mandatory. *}
                <a href="{$WEB_ROOT}/{$grp.url}" class="buy">{$hadrianLang.home.buyGroup}</a>
            </div>
            {/foreach}
        </div>
    </div>

    {* No visible product groups configured, or the catalogue query failed. *}
    <div class="when-empty hp-pricing-empty">
        <p>{$hadrianLang.home.noProductsText}</p>
        <a href="{$WEB_ROOT}/cart.php" class="btn-primary">{$hadrianLang.home.noProductsCta}</a>
    </div>
</section>
{/if}

{* ================================================================
   SECTION 3 -- Why us, four tiles.
   Lagom section 4, "Our Guarantees": an 8-tile icon/title/body grid. That is
   Lagom's single largest block and every word of it is invented marketing,
   including two subtitles that hardcode "trusted by over 35,000 clients". Cut
   to 4 tiles and swapped for factual product statements the theme already ships
   -- the isolation story (dedicated MySQL, per-site PHP versions, private
   Redis, capped CPU/RAM). Capability statements, so there is no number to
   invent anywhere in this section.

   .hp-icon-grid-header is a sibling section, not a grid child: the 'default'
   variant hand-rolls its header as an inline-styled grid child (grid-column
   1/-1, font-size 40px, a hardcoded #6e6e73) because .hp-eyebrow has no
   standalone rule outside a hero. Using the real header component instead drops
   the eyebrow and all five inline styles and keeps typography on tokens.

   cols-4 is required: the base grid is 3-wide and would strand the fourth tile
   alone on a second row.

   Carries id="how" so any "see how it works" link elsewhere lands somewhere
   real.
   ================================================================ *}
{if $_showFeatures}
<div class="hp-icon-grid-header" id="how">
    <h2>{$hadrianLang.home.isoTitle}</h2>
    <p>{$hadrianLang.home.isoSub}</p>
</div>
<section class="hp-icon-grid cols-4">
    <div class="hp-icon-item">
        <div class="icon-circle blue"><svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><ellipse cx="12" cy="5" rx="9" ry="3"/><path d="M21 12c0 1.66-4.03 3-9 3s-9-1.34-9-3"/><path d="M3 5v14c0 1.66 4.03 3 9 3s9-1.34 9-3V5"/></svg></div>
        <h4>{$hadrianLang.home.iso1Title}</h4>
        <p>{$hadrianLang.home.iso1Text}</p>
    </div>
    <div class="hp-icon-item">
        <div class="icon-circle purple"><svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="16 18 22 12 16 6"/><polyline points="8 6 2 12 8 18"/></svg></div>
        <h4>{$hadrianLang.home.iso2Title}</h4>
        <p>{$hadrianLang.home.iso2Text}</p>
    </div>
    <div class="hp-icon-item">
        <div class="icon-circle red"><svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M13 2L3 14h9l-1 8 10-12h-9l1-8z"/></svg></div>
        <h4>{$hadrianLang.home.iso3Title}</h4>
        <p>{$hadrianLang.home.iso3Text}</p>
    </div>
    <div class="hp-icon-item">
        <div class="icon-circle green"><svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="2" y="2" width="20" height="8" rx="2"/><rect x="2" y="14" width="20" height="8" rx="2"/></svg></div>
        <h4>{$hadrianLang.home.iso4Title}</h4>
        <p>{$hadrianLang.home.iso4Text}</p>
    </div>
</section>
{/if}

{* ================================================================
   SECTION 4 -- Latest announcements (real WHMCS data).
   Lagom section 6, "Latest News", kept essentially as-is: it is Lagom's only
   other genuinely data-backed section. $announcements is passed to homepage.tpl
   natively by WHMCS (stock six/homepage.tpl iterates the same var).

   WHMCS announcements carry only a title, date and body -- there are no
   categories, so no tag chips here even though the .announce-cat classes exist.

   Column count follows the announcement count the way Lagom does it (1 fills
   the row, 2 take halves, 3+ thirds), and the cap is enforced inside the loop.

   The {if $carbon} guard is mandatory: a template fatal drops the whole site to
   the six theme and poisons the compiled cache in a way a revert does not undo.
   ================================================================ *}
{if $_showNews && $annCount > 0}
<section class="hp-announce-grid">
    <div class="hp-announce-grid-header">
        <div>
            <h2>{$hadrianLang.home.newsTitle}</h2>
            <p>{$hadrianLang.home.newsSub}</p>
        </div>
        <a href="{$WEB_ROOT}/announcements.php" class="announce-view-all">{$hadrianLang.home.newsAll} &rsaquo;</a>
    </div>
    {* count-1/count-2 only. There is no .count-3 rule and none is needed: the
       base .hp-announce-cards is already repeat(3, 1fr), so 3+ announcements
       want no modifier at all. Emitting count-3 would be a class that matches
       nothing, which reads to the next person like a missing stylesheet. *}
    <div class="hp-announce-cards{if $annCount < 3} count-{$annCount}{/if}">
        {foreach $announcements as $ann}
        {if $ann@iteration <= 3}
        <a href="{routePath('announcement-view', $ann.id, $ann.urlfriendlytitle)}" class="hp-announce-item-card">
            <h3>{$ann.title}</h3>
            {if $ann.summary}<p>{$ann.summary|strip_tags}</p>{/if}
            <div class="announce-foot">
                <time>{if $carbon}{$carbon->translatePassedToFormat($ann.rawDate, 'M jS, Y')}{else}{$ann.rawDate}{/if}</time>
                <span class="announce-read">{$hadrianLang.home.newsReadMore} &rsaquo;</span>
            </div>
        </a>
        {/if}
        {/foreach}
    </div>
</section>
{/if}

{* ================================================================
   SECTION 5 -- Closing CTA band.
   Lagom section 7, "Let's Get Started!": a centred heading, one supporting
   paragraph and exactly one button. Kept verbatim in structure; only the
   destination changes from contact.php to the cart, since the page just showed
   the real catalogue.

   .hp-cta-immersive is the theme's canonical page-ender and what apple-layout
   .css expects the homepage to finish on -- it drops the content-area bottom
   padding so this band meets the footer edge to edge.

   The paragraph uses home.simpleCtaText rather than the existing home.ctaText
   ("Start free today - no card needed"), and the button uses the real WHMCS key
   $LANG.browseProducts rather than home.ctaBtn ("Start for free"): both of the
   existing strings assert a free plan the real catalogue may not contain, which
   is the same reason that framing was already retired from the pricing section.
   ================================================================ *}
{if $_showCta}
<section class="hp-cta-immersive">
    <div class="inner">
        <h2>{$hadrianLang.home.ctaTitle}</h2>
        <p>{$hadrianLang.home.simpleCtaText}</p>
        <a href="{$WEB_ROOT}/cart.php" class="btn">{$LANG.browseProducts|default:'Browse products'}</a>
    </div>
</section>
{/if}

{* Domain tab toggle -- search vs transfer is handled purely by rewriting
   form.action; there is no hidden input, so this script is required whenever
   the form renders. Emitted inside the same gate so no dead JS ships. *}
{if $_showDomain && $registerdomainenabled}
<script>
(function () {
    var form = document.querySelector('.ph-domain-form');
    if (!form) return;
    document.querySelectorAll('.ph-domain-tabs button').forEach(function (btn) {
        btn.addEventListener('click', function () {
            document.querySelectorAll('.ph-domain-tabs button').forEach(function (b) {
                b.classList.toggle('active', b === btn);
                b.setAttribute('aria-selected', b === btn ? 'true' : 'false');
            });
            form.action = btn.dataset.dtab === 'transfer'
                ? '{$WEB_ROOT}/cart.php?a=add&domain=transfer'
                : '{$WEB_ROOT}/domainchecker.php';
        });
    });
})();
</script>
{/if}
