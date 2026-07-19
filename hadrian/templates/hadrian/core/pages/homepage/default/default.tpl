{* Hostnodes - Public marketing homepage (Apple "Hosting, redesigned").

   Ported from apple-client-area/homepage.html. The mockup is a full standalone
   page; header.tpl/footer.tpl already provide the nav + footer, so we emit only
   the inner content. The hero keeps the working domain-search form + captcha
   from the previous portal homepage (now preserved as the 'portal' variant).

   Reuses the hp-* marketing classes (already in apple-theme.css, zero CSS work)
   and the ph-domain-* hero-form classes (homepage.css). Static marketing copy
   is tokenized into the hadrianLang 'home' group; representative pricing/specs
   and decorative illustration blocks are kept verbatim. CTAs point at real
   WHMCS routes (domainchecker.php / cart.php).

   WHMCS variables expected: $loggedin, $companyname, $LANG.*, $captcha. *}

{assign var=_hTitle value=$hadrian.pages.homepage.config.heroTitle|default:''}
{assign var=_hSub value=$hadrian.pages.homepage.config.heroSubtitle|default:''}

{* ── Real-data state ────────────────────────────────────────────────────────
   $homeProductGroups  ← Hooks::clientAreaPageHomepage (live product catalogue)
   $announcements      ← WHMCS native on homepage.tpl (see stock six/homepage.tpl)
   $hadrianLang.home.testimonials ← lang file; ships empty so no invented quotes
                                    ever render. Fill it to enable the section.

   The page-level full/empty flag follows the product catalogue, since that is
   the primary dynamic content here. Announcements and testimonials gate
   themselves on their own presence as well. *}
{assign var=hpGroups value=$homeProductGroups|default:[]}
{assign var=groupCount value=$hpGroups|@count}
{assign var=annCount value=$announcements|default:[]|@count}
{assign var=hpTestimonials value=$hadrianLang.home.testimonials|default:[]}
{if $groupCount > 0}
    {assign var=dashIsEmpty value='full'}
{else}
    {assign var=dashIsEmpty value='empty'}
{/if}

<link rel="stylesheet" href="{$WEB_ROOT}/templates/{$template}/assets/css/pages/homepage.css?v={$hadrian.version|default:'1.0'}">

<script>
(function () {
    var b = document.body;
    if (!b) return;
    b.setAttribute('data-data', '{$dashIsEmpty}');
})();
</script>

{* 1. Hero - "Hosting, redesigned" + working domain search *}
<section class="hp-hero" style="padding: 96px 22px 40px; background: transparent;">
    <div class="hp-eyebrow">{$hadrianLang.home.heroEyebrow}</div>
    <h1>{if $_hTitle != ''}{$_hTitle}{else}{$hadrianLang.home.heroTitle}{/if}</h1>
    <p class="hp-subhead">{if $_hSub != ''}{$_hSub}{else}{$hadrianLang.home.heroSubtitle}{/if}</p>

    {* Working domain search (reused from the portal homepage) *}
    <form class="ph-domain-form" action="{$WEB_ROOT}/domainchecker.php" method="post" style="max-width: 600px; margin: 28px auto 0;">
        <div class="ph-domain-tabs" role="tablist">
            <button type="button" class="active" data-dtab="search" role="tab" aria-selected="true">{$LANG.search}</button>
            <button type="button" data-dtab="transfer" role="tab" aria-selected="false">{$LANG.transferdomain}</button>
        </div>
        <div class="ph-domain-box">
            <svg class="search-ico" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
            <input type="text" name="domain" placeholder="{$LANG.exampledomain}" autocapitalize="none" autocomplete="off">
            <button type="submit" id="domainCta" class="{if isset($captcha) && $captcha}{$captcha->getButtonClass($captchaForm)}{/if}">{$LANG.search}</button>
        </div>
        {if isset($captcha) && $captcha->isEnabled() && $captcha->isEnabledForForm($captchaForm)}
        <div class="ph-captcha">{include file="`$template`/includes/captcha.tpl"}</div>
        {/if}
        {* Live TLD register prices (Hooks::fetchDomainTldPricing -> localAPI
           GetTLDPricing, visitor's currency). Renders nothing when WHMCS has no
           priced TLDs, so the hero never shows an empty rail. *}
        {if $homeTldPricing}
        <div class="hp-tld-strip">
            {foreach $homeTldPricing as $mtTld}
                <a class="hp-tld" href="{$WEB_ROOT}/index.php?rp=/domain/pricing">
                    <span class="hp-tld-ext">{$mtTld.tld|escape}</span>
                    <span class="hp-tld-price">{$mtTld.price|escape}</span>
                </a>
            {/foreach}
        </div>
        {/if}
        <div class="ph-domain-footer">
            <span>{$hadrianLang.dashboard.heroDomainSubtitle}</span>
            {* Domain Pricing page, NOT the cart. cart.php?gid=domain 302s (WHMCS
               has no group with that id) and dumps the visitor on the hosting
               list — the opposite of what this link promises. *}
            <a href="{$WEB_ROOT}/index.php?rp=/domain/pricing">{$LANG.viewallpricing|default:'View all pricing'} &rarr;</a>
        </div>
    </form>

    <div class="hp-cta-row" style="margin-top: 20px;">
        <a href="{$WEB_ROOT}/cart.php" class="hp-buy-btn">{$hadrianLang.home.heroCta}</a>
        <a href="#how">{$hadrianLang.home.heroSecondary} &rsaquo;</a>
    </div>
    <div style="display: inline-flex; align-items: center; gap: 10px; margin-top: 28px; padding: 10px 18px; background: var(--color-surface-secondary); border-radius: 999px;">
        <span style="color: #30d158; font-size: 15px; letter-spacing: 1px;">&starf;&starf;&starf;&starf;&starf;</span>
        <span style="font-size: 13px; font-weight: 500; color: var(--color-text-primary);"><strong>{$hadrianLang.home.trustStrong}</strong> &middot; {$hadrianLang.home.trustText}</span>
    </div>
</section>

{* 2. Trust stats strip *}
{* Full-bleed band — see the body[data-tpl="homepage"] block in apple-layout.css.
   Padding comes from .hp-stats-strip in apple-theme.css (56px 22px); the inline
   48px override that used to sit here is gone so the band has one source. *}
<section class="hp-stats-strip">
    <div class="stats-inner">
        <div class="hp-stat"><div class="stat-num">10K+</div><div class="stat-label">{$hadrianLang.home.stat1}</div></div>
        <div class="hp-stat"><div class="stat-num">99.9%</div><div class="stat-label">{$hadrianLang.home.stat2}</div></div>
        <div class="hp-stat"><div class="stat-num">&lt; 1s</div><div class="stat-label">{$hadrianLang.home.stat3}</div></div>
        <div class="hp-stat"><div class="stat-num">24/7</div><div class="stat-label">{$hadrianLang.home.stat4}</div></div>
    </div>
</section>

{* 3. cPanel comparison - duo *}
<section id="how" style="padding: 72px 22px 24px; text-align: center; max-width: 900px; margin: 0 auto;">
    <div class="hp-eyebrow" style="color: var(--color-accent);">{$hadrianLang.home.duoEyebrow}</div>
    <h2 style="font-size: 48px; font-weight: 600; letter-spacing: -0.02em; margin: 12px 0;">{$hadrianLang.home.duoTitle}</h2>
    <p style="font-size: 17px; color: #6e6e73; max-width: 600px; margin: 0 auto;">{$hadrianLang.home.duoSub}</p>
</section>
<section class="hp-duo-feature">
    <div class="hp-duo-card">
        <p class="duo-text"><strong>{$hadrianLang.home.duoOldStrong}</strong> {$hadrianLang.home.duoOldText}</p>
        <div class="duo-visual duo-visual--left">
            <div style="width: 100%; height: 100%; background: linear-gradient(135deg, #1c1c1e, #2c2c2e); border-radius: 14px; display: flex; align-items: center; justify-content: center; padding: 30px;">
                <div style="background: #0f0f12; border-radius: 10px; padding: 14px; width: 100%; max-width: 320px; border: 1px solid #2a2a2c;">
                    <div style="display: grid; grid-template-columns: repeat(4, 1fr); gap: 4px;">
                        <div style="height: 24px; background: rgba(255,255,255,0.08); border-radius: 3px;"></div><div style="height: 24px; background: rgba(255,255,255,0.08); border-radius: 3px;"></div><div style="height: 24px; background: rgba(255,255,255,0.08); border-radius: 3px;"></div><div style="height: 24px; background: rgba(255,255,255,0.08); border-radius: 3px;"></div><div style="height: 24px; background: rgba(255,255,255,0.08); border-radius: 3px;"></div><div style="height: 24px; background: rgba(255,255,255,0.08); border-radius: 3px;"></div><div style="height: 24px; background: rgba(255,255,255,0.08); border-radius: 3px;"></div><div style="height: 24px; background: rgba(255,255,255,0.08); border-radius: 3px;"></div><div style="height: 24px; background: rgba(255,255,255,0.08); border-radius: 3px;"></div><div style="height: 24px; background: rgba(255,255,255,0.08); border-radius: 3px;"></div><div style="height: 24px; background: rgba(255,255,255,0.08); border-radius: 3px;"></div><div style="height: 24px; background: rgba(255,255,255,0.08); border-radius: 3px;"></div>
                    </div>
                    <div style="margin-top: 10px; font-size: 10px; color: rgba(255,255,255,0.3); text-align: center;">47 menu items &middot; 12 toolbars</div>
                </div>
            </div>
        </div>
    </div>
    <div class="hp-duo-card">
        <p class="duo-text"><strong>{$hadrianLang.home.duoNewStrong}</strong> {$hadrianLang.home.duoNewText}</p>
        <div class="duo-visual duo-visual--right">
            <div style="width: 100%; height: 100%; background: linear-gradient(135deg, #0a84ff, #64d2ff); border-radius: 14px; display: flex; align-items: center; justify-content: center; padding: 30px;">
                <div style="background: #fff; border-radius: 10px; padding: 16px; width: 100%; max-width: 260px; box-shadow: 0 12px 32px rgba(0,0,0,0.2);">
                    <div style="display: flex; align-items: center; gap: 8px; padding-bottom: 10px; border-bottom: 1px solid #f5f5f7;"><div style="width: 8px; height: 8px; background: #30d158; border-radius: 50%;"></div><span style="font-size: 11px; font-weight: 600; color: #1d1d1f;">OpenPanel</span></div>
                    <div style="display: flex; flex-direction: column; gap: 8px; margin-top: 12px;">
                        <div style="display: flex; align-items: center; gap: 10px; padding: 6px 0;"><div style="width: 14px; height: 14px; background: rgba(0,113,227,0.1); border-radius: 4px;"></div><span style="font-size: 11px; color: #1d1d1f;">Sites</span></div>
                        <div style="display: flex; align-items: center; gap: 10px; padding: 6px 0;"><div style="width: 14px; height: 14px; background: rgba(48,209,88,0.1); border-radius: 4px;"></div><span style="font-size: 11px; color: #1d1d1f;">Resources</span></div>
                        <div style="display: flex; align-items: center; gap: 10px; padding: 6px 0;"><div style="width: 14px; height: 14px; background: rgba(191,90,242,0.1); border-radius: 4px;"></div><span style="font-size: 11px; color: #1d1d1f;">Backups</span></div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</section>

{* 4. Isolation - 4-up icon grid *}
{* cols-4: this section has 4 items and the base grid is 3-wide, which left the
   fourth card stranded alone on a second row. *}
<section class="hp-icon-grid cols-4" style="padding: 72px 22px 48px;">
    <div style="grid-column: 1 / -1; text-align: center; max-width: 800px; margin: 0 auto 40px;">
        <div class="hp-eyebrow" style="color: var(--color-accent);">{$hadrianLang.home.isoEyebrow}</div>
        <h2 style="font-size: 40px; font-weight: 600; letter-spacing: -0.02em; margin: 12px 0;">{$hadrianLang.home.isoTitle}</h2>
        <p style="font-size: 17px; color: #6e6e73;">{$hadrianLang.home.isoSub}</p>
    </div>
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

{* 7. White-label + dev tools - intel duo *}
<section class="hp-intel-duo">
    <div class="hp-intel-big">
        <div class="eyebrow">{$hadrianLang.home.wlEyebrow}</div>
        <h2>{$hadrianLang.home.wlTitle}</h2>
        <p><strong>{$hadrianLang.home.wlStrong}</strong> {$hadrianLang.home.wlText}</p>
        <a href="{$WEB_ROOT}/cart.php" class="link">{$hadrianLang.home.wlLink} &rsaquo;</a>
        <div class="intel-visual" style="display: flex; align-items: center; justify-content: center; padding: 48px; min-height: 320px;">
            <div style="display: flex; gap: 12px; flex-wrap: wrap; justify-content: center;">
                <div style="background: #fff; border-radius: 12px; padding: 14px; box-shadow: 0 8px 24px rgba(0,0,0,0.08); min-width: 140px;"><div style="display: flex; align-items: center; gap: 6px; margin-bottom: 10px;"><div style="width: 22px; height: 22px; background: linear-gradient(135deg, #ff453a, #ff9f0a); border-radius: 6px;"></div><span style="font-size: 11px; font-weight: 600; color: #1d1d1f;">AcmeHost</span></div><div style="height: 6px; background: #ffefec; border-radius: 3px; margin-bottom: 4px;"></div><div style="height: 6px; background: #f5f5f7; border-radius: 3px; margin-bottom: 4px;"></div><div style="height: 6px; background: #f5f5f7; border-radius: 3px;"></div></div>
                <div style="background: #fff; border-radius: 12px; padding: 14px; box-shadow: 0 8px 24px rgba(0,0,0,0.12); min-width: 140px; border: 2px solid #0071e3;"><div style="display: flex; align-items: center; gap: 6px; margin-bottom: 10px;"><div style="width: 22px; height: 22px; background: linear-gradient(135deg, #0071e3, #5ac8fa); border-radius: 6px;"></div><span style="font-size: 11px; font-weight: 600; color: #1d1d1f;">Hostnodes</span></div><div style="height: 6px; background: #eaf4ff; border-radius: 3px; margin-bottom: 4px;"></div><div style="height: 6px; background: #f5f5f7; border-radius: 3px; margin-bottom: 4px;"></div><div style="height: 6px; background: #f5f5f7; border-radius: 3px;"></div></div>
                <div style="background: #fff; border-radius: 12px; padding: 14px; box-shadow: 0 8px 24px rgba(0,0,0,0.08); min-width: 140px;"><div style="display: flex; align-items: center; gap: 6px; margin-bottom: 10px;"><div style="width: 22px; height: 22px; background: linear-gradient(135deg, #30d158, #5cdb79); border-radius: 6px;"></div><span style="font-size: 11px; font-weight: 600; color: #1d1d1f;">StudioHost</span></div><div style="height: 6px; background: #e8f8ed; border-radius: 3px; margin-bottom: 4px;"></div><div style="height: 6px; background: #f5f5f7; border-radius: 3px; margin-bottom: 4px;"></div><div style="height: 6px; background: #f5f5f7; border-radius: 3px;"></div></div>
            </div>
        </div>
    </div>
    <div class="hp-intel-small">
        <div class="intel-small-shot" style="background: linear-gradient(135deg, #eaf4ff, #dbeafe); display: flex; align-items: center; justify-content: center; padding: 40px;">
            <div style="background: #fff; border-radius: 14px; padding: 20px; width: 100%; max-width: 260px; box-shadow: 0 8px 24px rgba(0,0,0,0.08);">
                <div style="font-size: 11px; font-weight: 600; color: #1d1d1f; margin-bottom: 12px;">PHP version</div>
                <div style="display: flex; flex-wrap: wrap; gap: 6px;"><span style="padding: 6px 12px; background: #0071e3; color: #fff; border-radius: 999px; font-size: 11px; font-weight: 600;">8.3</span><span style="padding: 6px 12px; background: #f5f5f7; color: #1d1d1f; border-radius: 999px; font-size: 11px;">8.2</span><span style="padding: 6px 12px; background: #f5f5f7; color: #1d1d1f; border-radius: 999px; font-size: 11px;">8.1</span><span style="padding: 6px 12px; background: #f5f5f7; color: #1d1d1f; border-radius: 999px; font-size: 11px;">8.0</span><span style="padding: 6px 12px; background: #f5f5f7; color: #1d1d1f; border-radius: 999px; font-size: 11px;">7.4</span></div>
                <div style="margin-top: 14px; padding-top: 12px; border-top: 1px solid #f5f5f7; display: flex; flex-direction: column; gap: 6px;">
                    <div style="display: flex; align-items: center; gap: 6px; font-size: 11px; color: #1d1d1f;"><svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="#30d158" stroke-width="2.5"><polyline points="20 6 9 17 4 12"/></svg>SSH &amp; SFTP access</div>
                    <div style="display: flex; align-items: center; gap: 6px; font-size: 11px; color: #1d1d1f;"><svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="#30d158" stroke-width="2.5"><polyline points="20 6 9 17 4 12"/></svg>Redis &amp; Memcached</div>
                    <div style="display: flex; align-items: center; gap: 6px; font-size: 11px; color: #1d1d1f;"><svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="#30d158" stroke-width="2.5"><polyline points="20 6 9 17 4 12"/></svg>Auto SSL via Let&rsquo;s Encrypt</div>
                </div>
            </div>
        </div>
        <div class="intel-small-content">
            <div class="icon-badge">&lt;/&gt;</div>
            <h3>{$hadrianLang.home.devTitle}</h3>
            <p><strong>{$hadrianLang.home.devStrong}</strong> {$hadrianLang.home.devText}</p>
        </div>
    </div>
</section>

{* 8. Audience - feature columns *}
<section class="hp-feature-columns" style="padding: 72px 22px;">
    <h2 style="font-size: 40px;">{$hadrianLang.home.colTitle}</h2>
    <p class="feat-sub">{$hadrianLang.home.colSub}</p>
    <div class="hp-columns-row">
        <div class="hp-column-item">
            <div class="col-num">{$hadrianLang.home.col1Num}</div>
            <h4>{$hadrianLang.home.col1Title}</h4>
            <p>{$hadrianLang.home.col1Text}</p>
            <a href="{$WEB_ROOT}/knowledgebase.php" class="col-link">{$hadrianLang.home.col1Link} &rsaquo;</a>
        </div>
        <div class="hp-column-item">
            <div class="col-num">{$hadrianLang.home.col2Num}</div>
            <h4>{$hadrianLang.home.col2Title}</h4>
            <p>{$hadrianLang.home.col2Text}</p>
            <a href="{$WEB_ROOT}/cart.php" class="col-link">{$hadrianLang.home.col2Link} &rsaquo;</a>
        </div>
        <div class="hp-column-item">
            <div class="col-num">{$hadrianLang.home.col3Num}</div>
            <h4>{$hadrianLang.home.col3Title}</h4>
            <p>{$hadrianLang.home.col3Text}</p>
            <a href="{$WEB_ROOT}/cart.php" class="col-link">{$hadrianLang.home.col3Link} &rsaquo;</a>
        </div>
    </div>
</section>

{* 9. Product categories — REAL WHMCS product groups.
     $homeProductGroups comes from Hooks::clientAreaPageHomepage(); each entry is
     {gid, name, tagline, url, fromPrice, cycle}. fromPrice is null when the group
     has no positively-priced product, in which case we show the group without a
     price rather than inventing one. Previously these were four hardcoded tiers
     ($0/$9/$29/$79) with untranslated English bullets and CTAs to a bare cart.php. *}
<section class="hp-pricing-segmented" id="pricing">
    <h2 style="font-size: 44px;">{$hadrianLang.home.pricingTitle}</h2>
    <p class="sub">{$hadrianLang.home.pricingSub}</p>

    <div class="when-full">
        {* .hp-pricing-grid + .hp-price-card is the theme's standard Apple card
           grid — already used by 7 store pages — rather than the joined
           .hp-segmented-bar, which reads as a dense comparison table and left a
           gaping void in any card that has no price.

           cols-N, never an inline grid-template-columns: an inline value
           outranks the responsive collapse in apple-theme.css.

           No "POPULAR" flag. It used to be pinned to $grp@iteration == 2, so
           whichever group happened to be second got badged as popular — a claim
           the data doesn't support. *}
        <div class="hp-pricing-grid{if $groupCount > 0 && $groupCount < 3} cols-{$groupCount}{/if}">
            {foreach $hpGroups as $grp}
            {* Order mirrors Lagom's "Products For All Businesses" block: name,
               tagline, then "Starting at" above the price with the billing cycle
               spelled out underneath. *}
            <div class="hp-price-card pc-group">
                <h3>{$grp.name|escape}</h3>
                {if $grp.tagline}<p class="pc-tagline">{$grp.tagline|escape}</p>{/if}
                {if $grp.fromPrice}
                <div class="pc-from">{$hadrianLang.home.startingAt}</div>
                <div class="price-row"><span class="price">{$grp.fromPrice}</span></div>
                <div class="pc-cycle">{$hadrianLang.home.cycleName[$grp.cycle]|default:''}</div>
                {/if}
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

    <p style="text-align: center; font-size: 14px; color: var(--color-text-secondary); margin-top: 32px;">{$hadrianLang.home.pricingNote} <a href="{$WEB_ROOT}/cart.php" style="color: var(--color-accent);">{$hadrianLang.home.pricingNoteLink} &rsaquo;</a></p>
</section>

{* 10b. Testimonials — "What our customers say".
     Driven by $hadrianLang.home.testimonials, which SHIPS EMPTY on purpose: the
     section renders nothing until real quotes are added, so no invented customer
     praise ever goes live. Lagom hardcodes its testimonials in the template; this
     keeps them in the lang system so they stay translatable.
     Reuses .hp-testimonials-grid, already in apple-theme.css. *}
{if $hpTestimonials}
<section class="hp-testimonials-grid">
    {* .hp-testimonials-grid h2 already centres itself in apple-theme.css. *}
    <h2>{$hadrianLang.home.testiTitle}</h2>
    <div class="hp-testimonial-cards">
        {foreach $hpTestimonials as $t}
        <div class="hp-testimonial-card">
            <div class="quote">{$t.quote|escape}</div>
            <div class="author">
                <div class="author-avatar">{$t.author|truncate:1:''|upper}</div>
                <div>
                    <div class="author-name">{$t.author|escape}</div>
                    {if $t.role || $t.company}
                    <div class="author-role">{$t.role|escape}{if $t.role && $t.company}, {/if}{$t.company|escape}</div>
                    {/if}
                </div>
            </div>
        </div>
        {/foreach}
    </div>
</section>
{/if}

{* 10c. Latest announcements — REAL data.
     $announcements is passed to homepage.tpl natively by WHMCS (stock
     six/homepage.tpl iterates the same var). WHMCS announcements carry only a
     title, date and body — there are no categories, so no tag chips here. *}
{if $annCount > 0}
{* Uses the .hp-announce-grid component already in apple-theme.css (header +
   .hp-announce-cards + .hp-announce-item-card, with dark-mode and mobile rules
   already written) rather than inline styles — inline styles can't be
   overridden by media queries, which is the exact cause of the marketing-page
   mobile overflows.

   Column count follows the announcement count, the way Lagom does it
   (1 → full row, 2 → halves, 3+ → thirds), so a single announcement fills the
   row instead of sitting narrow and centred with dead space beside it. *}
<section class="hp-announce-grid when-full">
    <div class="hp-announce-grid-header">
        <div>
            <h2>{$hadrianLang.home.newsTitle}</h2>
            <p>{$hadrianLang.home.newsSub}</p>
        </div>
        <a href="{$WEB_ROOT}/announcements.php" class="announce-view-all">{$hadrianLang.home.newsAll} &rsaquo;</a>
    </div>
    <div class="hp-announce-cards count-{if $annCount >= 3}3{else}{$annCount}{/if}">
        {foreach $announcements as $ann}
        {if $ann@iteration <= 3}
        <a href="{routePath('announcement-view', $ann.id, $ann.urlfriendlytitle)}" class="hp-announce-item-card">
            <h3>{$ann.title}</h3>
            {if $ann.summary}<p>{$ann.summary|strip_tags}</p>{/if}
            <div class="announce-foot">
                {* $carbon is provided by WHMCS here (stock six/homepage.tpl uses
                   it the same way), but guard anyway: a template fatal drops the
                   site to the six theme and poisons the compiled cache, which a
                   revert does not undo. *}
                <time>{if $carbon}{$carbon->translatePassedToFormat($ann.rawDate, 'M jS, Y')}{else}{$ann.rawDate}{/if}</time>
                <span class="announce-read">{$hadrianLang.home.newsReadMore} &rsaquo;</span>
            </div>
        </a>
        {/if}
        {/foreach}
    </div>
</section>
{/if}

{* 11. Final CTA *}
<section class="hp-cta-immersive">
    <div class="inner">
        <h2>{$hadrianLang.home.ctaTitle}</h2>
        <p>{$hadrianLang.home.ctaText}</p>
        <a href="{$WEB_ROOT}/cart.php" class="btn">{$hadrianLang.home.ctaBtn}</a>
    </div>
</section>

{* Domain tab toggle - search vs transfer affects form action *}
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
