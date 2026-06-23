{* Store landing - SSL Certificates.
   Ported from apple-client-area/ssl-certificates.html (Public/Marketing
   landing). The source is a full standalone page; header.tpl/footer.tpl
   already provide html/head/nav/breadcrumb/footer + the .content-area
   wrapper, so we emit only the inner content (page-header + when-full
   marketing + when-empty offline state).

   Real pricing: the WHMCS SSL store controller assigns $certificates
   (keyed dv/ov/ev/wildcard, each an array of $product objects), $inPreview,
   etc. - same contract as six/store/ssl/index.tpl. The "Available
   certificates" table loops that real data into the mockup's exact row
   markup; static hero/feature/FAQ copy is tokenized into the hadrianLang
   store group (ssl-prefixed keys). Decorative inline-style SVG/illustration
   blocks are kept verbatim from the mockup. *}

{* Resolve data state: full when we have a real certificate to sell (or are
   in admin preview), else the graceful "marketing offline" empty state. *}
{assign var=_sslCount value=0}
{if isset($certificates)}
    {foreach $certificates as $_type => $_certProducts}
        {assign var=_sslCount value=$_sslCount+($_certProducts|@count)}
    {/foreach}
{/if}
{if $_sslCount > 0 || (isset($inPreview) && $inPreview)}
    {assign var=storeIsEmpty value='full'}
{else}
    {assign var=storeIsEmpty value='empty'}
{/if}


{* Hand the resolved data state to the body - the global rule in
   apple-layout.css (body[data-data="empty"] .when-full / .when-empty)
   keys off it; the preview chip can override under ?preview=1. *}
<script>
(function () {
    var b = document.body;
    if (!b) return;
    b.setAttribute('data-data', '{$storeIsEmpty}');
    b.setAttribute('data-svc-layout', 'inside');
})();
</script>

<div class="when-full">

    {* 1. Hero Split *}
    <section class="hp-hero-split" style="padding: 60px 22px;">
        <div class="hp-split-text">
            <div class="hp-eyebrow">{$hadrianLang.store.sslHeroEyebrow}</div>
            <h1>{$hadrianLang.store.sslHeroTitle}</h1>
            <p>{$hadrianLang.store.sslHeroText}</p>
            <div class="hp-cta-row">
                <a href="#pricing" class="hp-buy-btn">{$hadrianLang.store.sslHeroCta}</a>
                <a href="#pricing">{$hadrianLang.store.sslLearnMore} &rsaquo;</a>
            </div>
        </div>
        <div class="hp-split-visual">
            <div class="visual-box" style="background: linear-gradient(135deg, #eef5ff 0%, #dbeafe 100%); padding: 28px;">
                <div style="background: #fff; border-radius: 14px; padding: 16px; width: 100%; max-width: 300px; box-shadow: 0 8px 24px rgba(0,0,0,0.08);">
                    <div style="display: flex; align-items: center; gap: 8px; padding: 10px 14px; background: #f5f5f7; border-radius: 10px; margin-bottom: 14px;">
                        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#1a7f37" stroke-width="2.5"><rect x="3" y="11" width="18" height="11" rx="2"/><path d="M7 11V7a5 5 0 0110 0v4"/></svg>
                        <span style="font-size: 13px; color: #1d1d1f; font-weight: 500;">https://yourdomain.com</span>
                    </div>
                    <div style="padding: 14px; background: linear-gradient(135deg, #0071e3, #5ac8fa); border-radius: 12px; color: #fff; text-align: center;">
                        <svg width="48" height="48" viewBox="0 0 24 24" fill="none" stroke="#fff" stroke-width="1.5" style="margin-bottom: 8px;"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/><path d="M9 12l2 2 4-4"/></svg>
                        <div style="font-size: 13px; font-weight: 600;">Secure Connection</div>
                        <div style="font-size: 11px; opacity: 0.8;">256-bit AES encryption</div>
                    </div>
                    <div style="margin-top: 12px; display: flex; gap: 6px;">
                        <span style="flex: 1; text-align: center; padding: 6px; background: #e8f8ed; border-radius: 8px; font-size: 10px; font-weight: 600; color: #1a7f37;">&check; Verified</span>
                        <span style="flex: 1; text-align: center; padding: 6px; background: #e8f8ed; border-radius: 8px; font-size: 10px; font-weight: 600; color: #1a7f37;">&check; Trusted</span>
                    </div>
                </div>
            </div>
        </div>
    </section>

    {* 2. 3-up certificate types *}
    <section class="hp-icon-grid" style="padding: 40px 22px 48px;">
        <div class="hp-icon-item">
            <div class="icon-circle blue"><svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="11" width="18" height="11" rx="2"/><path d="M7 11V7a5 5 0 0110 0v4"/></svg></div>
            <h4>{$hadrianLang.store.sslDvTitle}</h4>
            <p>{$hadrianLang.store.sslDvText}</p>
            <a href="#pricing" style="color: var(--color-accent); font-size: 13px; font-weight: 500; margin-top: 8px;">{$hadrianLang.store.sslLearnMore} &rsaquo;</a>
        </div>
        <div class="hp-icon-item">
            <div class="icon-circle green"><svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/></svg></div>
            <h4>{$hadrianLang.store.sslOvTitle}</h4>
            <p>{$hadrianLang.store.sslOvText}</p>
            <a href="#pricing" style="color: var(--color-accent); font-size: 13px; font-weight: 500; margin-top: 8px;">{$hadrianLang.store.sslLearnMore} &rsaquo;</a>
        </div>
        <div class="hp-icon-item">
            <div class="icon-circle purple"><svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/><path d="M9 12l2 2 4-4"/></svg></div>
            <h4>{$hadrianLang.store.sslEvTitle}</h4>
            <p>{$hadrianLang.store.sslEvText}</p>
            <a href="#pricing" style="color: var(--color-accent); font-size: 13px; font-weight: 500; margin-top: 8px;">{$hadrianLang.store.sslLearnMore} &rsaquo;</a>
        </div>
    </section>

    {* 3. Alternating rows *}
    <div class="hp-alternating">

        <div class="hp-alt-row">
            <div class="hp-alt-text">
                <div class="hp-eyebrow">{$hadrianLang.store.sslWhatEyebrow}</div>
                <h3>{$hadrianLang.store.sslWhatTitle}</h3>
                <p>{$hadrianLang.store.sslWhatP1}</p>
                <p style="margin-top: 12px;">{$hadrianLang.store.sslWhatP2}</p>
            </div>
            <div class="hp-alt-visual">
                <div class="visual-box" style="background: #f5f5f7; padding: 24px;">
                    <div style="width: 100%; max-width: 300px;">
                        <div style="display: flex; align-items: center; justify-content: space-between; padding: 12px 16px; background: #fff; border-radius: 12px; margin-bottom: 10px;">
                            <div style="display: flex; align-items: center; gap: 10px;"><svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#86868b" stroke-width="2"><circle cx="12" cy="12" r="10"/></svg><span style="font-size: 12px; color: #1d1d1f;">Browser</span></div>
                        </div>
                        <div style="display: flex; justify-content: center; margin: 6px 0;">
                            <div style="display: flex; flex-direction: column; align-items: center; gap: 4px;">
                                <div style="width: 2px; height: 12px; background: linear-gradient(180deg, transparent, #0071e3);"></div>
                                <div style="background: linear-gradient(135deg, #0071e3, #5ac8fa); padding: 6px 12px; border-radius: 8px; display: flex; align-items: center; gap: 6px; color: #fff; font-size: 11px; font-weight: 600;">
                                    <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><rect x="3" y="11" width="18" height="11" rx="2"/><path d="M7 11V7a5 5 0 0110 0v4"/></svg>
                                    SSL/TLS
                                </div>
                                <div style="width: 2px; height: 12px; background: linear-gradient(180deg, #0071e3, transparent);"></div>
                            </div>
                        </div>
                        <div style="display: flex; align-items: center; justify-content: space-between; padding: 12px 16px; background: #fff; border-radius: 12px;">
                            <div style="display: flex; align-items: center; gap: 10px;"><svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#86868b" stroke-width="2"><rect x="2" y="2" width="20" height="8" rx="2"/><rect x="2" y="14" width="20" height="8" rx="2"/></svg><span style="font-size: 12px; color: #1d1d1f;">Server</span></div>
                        </div>
                        <div style="margin-top: 12px; padding: 10px 12px; background: #e8f8ed; border-radius: 8px; display: flex; align-items: center; gap: 8px;">
                            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#1a7f37" stroke-width="2.5"><polyline points="20 6 9 17 4 12"/></svg>
                            <span style="font-size: 11px; color: #1a7f37; font-weight: 600;">Encrypted &amp; authenticated</span>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <div class="hp-alt-row reverse">
            <div class="hp-alt-text">
                <div class="hp-eyebrow">{$hadrianLang.store.sslSeoEyebrow}</div>
                <h3>{$hadrianLang.store.sslSeoTitle}</h3>
                <p>{$hadrianLang.store.sslSeoP1}</p>
                <p style="margin-top: 12px;">{$hadrianLang.store.sslSeoP2}</p>
            </div>
            <div class="hp-alt-visual">
                <div class="visual-box" style="background: #eaf4ff; padding: 24px;">
                    <div style="width: 100%; max-width: 300px; background: #fff; border-radius: 14px; padding: 14px;">
                        <div style="font-size: 11px; font-weight: 600; color: #1d1d1f; margin-bottom: 12px;">SEO impact after HTTPS migration</div>
                        <svg viewBox="0 0 260 80" style="width: 100%; height: 80px;">
                            <defs><linearGradient id="seoGrad" x1="0" y1="0" x2="0" y2="1"><stop offset="0%" stop-color="#30d158" stop-opacity="0.3"/><stop offset="100%" stop-color="#30d158" stop-opacity="0"/></linearGradient></defs>
                            <path d="M0,65 L32,60 L64,62 L96,50 L128,45 L160,30 L192,22 L224,15 L260,10 L260,80 L0,80 Z" fill="url(#seoGrad)"/>
                            <path d="M0,65 L32,60 L64,62 L96,50 L128,45 L160,30 L192,22 L224,15 L260,10" fill="none" stroke="#30d158" stroke-width="2"/>
                            <line x1="96" y1="0" x2="96" y2="80" stroke="#86868b" stroke-width="1" stroke-dasharray="3"/>
                        </svg>
                        <div style="display: flex; justify-content: space-between; margin-top: 8px; font-size: 10px; color: #86868b;">
                            <span>HTTP</span><span>&larr; migration &rarr;</span><span>HTTPS</span>
                        </div>
                        <div style="margin-top: 12px; padding: 10px; background: #e8f8ed; border-radius: 8px; display: flex; justify-content: space-between; align-items: center;">
                            <span style="font-size: 11px; color: #1a7f37; font-weight: 600;">Organic traffic</span>
                            <span style="font-size: 13px; font-weight: 700; color: #1a7f37;">+ 37%</span>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <div class="hp-alt-row">
            <div class="hp-alt-text">
                <div class="hp-eyebrow">{$hadrianLang.store.sslChooseEyebrow}</div>
                <h3>{$hadrianLang.store.sslChooseTitle}</h3>
                <p>{$hadrianLang.store.sslChooseP1}</p>
            </div>
            <div class="hp-alt-visual">
                <div class="visual-box" style="background: #f5f5f7; padding: 24px;">
                    <div style="width: 100%; max-width: 300px; display: flex; flex-direction: column; gap: 8px;">
                        <div style="background: #fff; border-radius: 10px; padding: 10px 12px; display: flex; align-items: center; gap: 10px;"><span style="width: 32px; height: 32px; background: #e8f0ff; border-radius: 8px; display: flex; align-items: center; justify-content: center; color: var(--color-accent); font-weight: 700; font-size: 11px;">DV</span><div><div style="font-size: 12px; font-weight: 600; color: #1d1d1f;">Domain Validation</div><div style="font-size: 10px; color: #86868b;">Instant issuance</div></div></div>
                        <div style="background: #fff; border-radius: 10px; padding: 10px 12px; display: flex; align-items: center; gap: 10px;"><span style="width: 32px; height: 32px; background: #e8f8ed; border-radius: 8px; display: flex; align-items: center; justify-content: center; color: #30d158; font-weight: 700; font-size: 11px;">OV</span><div><div style="font-size: 12px; font-weight: 600; color: #1d1d1f;">Organization Validation</div><div style="font-size: 10px; color: #86868b;">1&ndash;3 day vetting</div></div></div>
                        <div style="background: #fff; border-radius: 10px; padding: 10px 12px; display: flex; align-items: center; gap: 10px;"><span style="width: 32px; height: 32px; background: #f3ebff; border-radius: 8px; display: flex; align-items: center; justify-content: center; color: #bf5af2; font-weight: 700; font-size: 11px;">EV</span><div><div style="font-size: 12px; font-weight: 600; color: #1d1d1f;">Extended Validation</div><div style="font-size: 10px; color: #86868b;">3&ndash;7 day vetting</div></div></div>
                    </div>
                </div>
            </div>
        </div>

    </div>

    {* 4. What comes with SSL - 5 feature cards *}
    <div style="background: var(--color-surface-secondary);">
    <section class="hp-features-section" style="padding: 72px 22px;">
        <h2>{$hadrianLang.store.sslFeaturesTitle}</h2>
        <div class="hp-feature-cards" style="margin-top: 40px; max-width: 1024px; margin-left: auto; margin-right: auto; grid-template-columns: repeat(5, 1fr);">
            <div class="hp-feature-card">
                <div class="feat-icon blue"><svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="11" width="18" height="11" rx="2"/><path d="M7 11V7a5 5 0 0110 0v4"/></svg></div>
                <h4>{$hadrianLang.store.sslFeat1Title}</h4>
                <p>{$hadrianLang.store.sslFeat1Text}</p>
            </div>
            <div class="hp-feature-card">
                <div class="feat-icon green"><svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M22 11.08V12a10 10 0 11-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg></div>
                <h4>{$hadrianLang.store.sslFeat2Title}</h4>
                <p>{$hadrianLang.store.sslFeat2Text}</p>
            </div>
            <div class="hp-feature-card">
                <div class="feat-icon purple"><svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"/></svg></div>
                <h4>{$hadrianLang.store.sslFeat3Title}</h4>
                <p>{$hadrianLang.store.sslFeat3Text}</p>
            </div>
            <div class="hp-feature-card">
                <div class="feat-icon orange"><svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/><line x1="2" y1="12" x2="22" y2="12"/><path d="M12 2a15.3 15.3 0 014 10 15.3 15.3 0 01-4 10 15.3 15.3 0 01-4-10 15.3 15.3 0 014-10z"/></svg></div>
                <h4>{$hadrianLang.store.sslFeat4Title}</h4>
                <p>{$hadrianLang.store.sslFeat4Text}</p>
            </div>
            <div class="hp-feature-card">
                <div class="feat-icon teal"><svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="23 4 23 10 17 10"/><polyline points="1 20 1 14 7 14"/><path d="M3.51 9a9 9 0 0114.85-3.36L23 10M1 14l4.64 4.36A9 9 0 0020.49 15"/></svg></div>
                <h4>{$hadrianLang.store.sslFeat5Title}</h4>
                <p>{$hadrianLang.store.sslFeat5Text}</p>
            </div>
        </div>
        <div style="text-align: center; margin-top: 32px;">
            <a href="#pricing" class="hp-buy-btn">{$hadrianLang.store.sslHeroCta}</a>
        </div>
    </section>
    </div>

    {* 5. Per-type alternating rows (DV, OV, EV, Wildcard) *}
    <div class="hp-alternating">

        <div class="hp-alt-row">
            <div class="hp-alt-text">
                <div class="hp-eyebrow">{$hadrianLang.store.sslDvTitle}</div>
                <h3>{$hadrianLang.store.sslDvRowTitle}</h3>
                <p>{$hadrianLang.store.sslDvRowText}</p>
                <a href="#pricing" class="hp-buy-btn" style="margin-top: 20px; display: inline-block;">{$hadrianLang.store.sslHeroCta}</a>
            </div>
            <div class="hp-alt-visual">
                <div class="visual-box" style="background: #f5f5f7; padding: 24px;">
                    <div style="width: 120px; height: 120px; background: linear-gradient(135deg, #0071e3, #5ac8fa); border-radius: 24px; display: flex; align-items: center; justify-content: center; color: #fff; font-size: 48px; font-weight: 700;">DV</div>
                </div>
            </div>
        </div>

        <div class="hp-alt-row reverse">
            <div class="hp-alt-text">
                <div class="hp-eyebrow">{$hadrianLang.store.sslOvTitle}</div>
                <h3>{$hadrianLang.store.sslOvRowTitle}</h3>
                <p>{$hadrianLang.store.sslOvRowText}</p>
                <a href="#pricing" class="hp-buy-btn" style="margin-top: 20px; display: inline-block;">{$hadrianLang.store.sslHeroCta}</a>
            </div>
            <div class="hp-alt-visual">
                <div class="visual-box" style="background: #eaf4ff; padding: 24px;">
                    <div style="width: 120px; height: 120px; background: linear-gradient(135deg, #30d158, #5cdb79); border-radius: 24px; display: flex; align-items: center; justify-content: center; color: #fff; font-size: 48px; font-weight: 700;">OV</div>
                </div>
            </div>
        </div>

        <div class="hp-alt-row">
            <div class="hp-alt-text">
                <div class="hp-eyebrow">{$hadrianLang.store.sslEvTitle}</div>
                <h3>{$hadrianLang.store.sslEvRowTitle}</h3>
                <p>{$hadrianLang.store.sslEvRowText}</p>
                <a href="#pricing" class="hp-buy-btn" style="margin-top: 20px; display: inline-block;">{$hadrianLang.store.sslHeroCta}</a>
            </div>
            <div class="hp-alt-visual">
                <div class="visual-box" style="background: #f5f5f7; padding: 24px;">
                    <div style="width: 120px; height: 120px; background: linear-gradient(135deg, #bf5af2, #c678ff); border-radius: 24px; display: flex; align-items: center; justify-content: center; color: #fff; font-size: 48px; font-weight: 700;">EV</div>
                </div>
            </div>
        </div>

        <div class="hp-alt-row reverse">
            <div class="hp-alt-text">
                <div class="hp-eyebrow">{$hadrianLang.store.sslWildcardEyebrow}</div>
                <h3>{$hadrianLang.store.sslWildcardTitle}</h3>
                <p>{$hadrianLang.store.sslWildcardText}</p>
                <a href="#pricing" class="hp-buy-btn" style="margin-top: 20px; display: inline-block;">{$hadrianLang.store.sslHeroCta}</a>
            </div>
            <div class="hp-alt-visual">
                <div class="visual-box" style="background: #eaf4ff; padding: 24px;">
                    <div style="position: relative; width: 140px; height: 120px;">
                        <div style="position: absolute; top: 0; left: 50%; transform: translateX(-50%); width: 60px; height: 60px; background: linear-gradient(135deg, #ff9f0a, #ffb843); border-radius: 14px; display: flex; align-items: center; justify-content: center; color: #fff; font-size: 16px; font-weight: 700;">*</div>
                        <div style="position: absolute; bottom: 0; left: 0; width: 40px; height: 40px; background: #fff; border-radius: 10px; box-shadow: 0 2px 8px rgba(0,0,0,0.08); display: flex; align-items: center; justify-content: center; font-size: 10px; font-weight: 600;">api</div>
                        <div style="position: absolute; bottom: 0; left: 50%; transform: translateX(-50%); width: 40px; height: 40px; background: #fff; border-radius: 10px; box-shadow: 0 2px 8px rgba(0,0,0,0.08); display: flex; align-items: center; justify-content: center; font-size: 10px; font-weight: 600;">app</div>
                        <div style="position: absolute; bottom: 0; right: 0; width: 40px; height: 40px; background: #fff; border-radius: 10px; box-shadow: 0 2px 8px rgba(0,0,0,0.08); display: flex; align-items: center; justify-content: center; font-size: 10px; font-weight: 600;">cdn</div>
                    </div>
                </div>
            </div>
        </div>

    </div>

    {* 6. Pricing - real $certificates looped into the mockup's row markup *}
    <section id="pricing" style="padding: 72px 22px; max-width: 1024px; margin: 0 auto;">
        <h2 style="text-align: center; margin-bottom: 8px;">{$hadrianLang.store.sslPricingTitle}</h2>
        <p style="text-align: center; color: #86868b; margin-bottom: 40px;">{$hadrianLang.store.sslPricingSubtitle}</p>
        <div class="hp-billing-toggle" style="justify-content: center; margin-bottom: 32px; display: flex; gap: 8px;"><button class="active">{$hadrianLang.store.sslFilterAll}</button><button>{$hadrianLang.store.sslFilterDv}</button><button>{$hadrianLang.store.sslFilterOv}</button><button>{$hadrianLang.store.sslFilterEv}</button><button>{$hadrianLang.store.sslFilterWildcard}</button></div>
        <div style="display: grid; grid-template-columns: 1fr; gap: 12px;">
            {if $_sslCount > 0}
                {foreach $certificates as $_type => $_certProducts}
                    {foreach $_certProducts as $_cert}
                    <div style="display: grid; grid-template-columns: 80px 1fr 120px 120px; align-items: center; gap: 16px; padding: 20px; background: var(--color-surface-secondary); border-radius: 14px;">
                        <div style="width: 56px; height: 56px; border-radius: 12px; display: flex; align-items: center; justify-content: center; color: #fff; font-size: 13px; font-weight: 700; text-transform: uppercase; background: {if $_type == 'dv'}linear-gradient(135deg, #0071e3, #5ac8fa){elseif $_type == 'ov'}linear-gradient(135deg, #30d158, #5cdb79){elseif $_type == 'ev'}linear-gradient(135deg, #bf5af2, #c678ff){else}linear-gradient(135deg, #ff9f0a, #ffb843){/if};">{$_type|escape}</div>
                        <div>
                            <div style="font-weight: 600; color: var(--color-text-primary); font-size: 15px;">{$_cert->name|escape}</div>
                            <p style="font-size: 13px; color: #6e6e73; margin: 4px 0 0;">{$_cert->description|escape}</p>
                        </div>
                        <div style="text-align: right;"><div style="font-size: 22px; font-weight: 700; color: var(--color-text-primary);">{$_cert->pricing()->best()->yearlyPrice()}</div><div style="font-size: 11px; color: #86868b;">{$hadrianLang.store.sslPerYear}</div></div>
                        <a href="{$WEB_ROOT}/cart.php?a=add&amp;pid={$_cert->id}" style="text-align: center; padding: 10px 16px; background: #1d1d1f; color: #fff; border-radius: 10px; text-decoration: none; font-size: 13px; font-weight: 500;">{$hadrianLang.store.sslOrderNow}</a>
                    </div>
                    {/foreach}
                {/foreach}
            {else}
                <p style="text-align:center; color:#86868b; padding: 24px;">{$hadrianLang.store.sslNoProducts}</p>
            {/if}
        </div>
    </section>

    {* Compliance badges *}
    <section class="hp-trust-badges">
        <h2>{$hadrianLang.store.sslBadgesTitle}</h2>
        <p class="sub">{$hadrianLang.store.sslBadgesSub}</p>
        <div class="hp-badges-grid">
            <div class="hp-badge"><div class="ic">&#128274;</div><div class="name">PCI DSS</div></div>
            <div class="hp-badge"><div class="ic">&#127466;&#127482;</div><div class="name">GDPR</div></div>
            <div class="hp-badge"><div class="ic">&#128737;</div><div class="name">ISO 27001</div></div>
            <div class="hp-badge"><div class="ic">&#127973;</div><div class="name">HIPAA</div></div>
            <div class="hp-badge"><div class="ic">&check;</div><div class="name">CA/B Forum</div></div>
            <div class="hp-badge"><div class="ic">&#9881;</div><div class="name">WebTrust</div></div>
        </div>
    </section>

    {* Big number highlights *}
    <section class="hp-feature-bignum">
        <h2 style="font-size: 36px;">{$hadrianLang.store.sslBignumTitle}</h2>
        <p class="sub">{$hadrianLang.store.sslBignumSub}</p>
        <div class="hp-bignum-grid">
            <div class="hp-bignum-item">
                <div class="num">256-bit</div>
                <h4>{$hadrianLang.store.sslBignum1Title}</h4>
                <p>{$hadrianLang.store.sslBignum1Text}</p>
            </div>
            <div class="hp-bignum-item">
                <div class="num">$1.75M</div>
                <h4>{$hadrianLang.store.sslBignum2Title}</h4>
                <p>{$hadrianLang.store.sslBignum2Text}</p>
            </div>
            <div class="hp-bignum-item">
                <div class="num">5 min</div>
                <h4>{$hadrianLang.store.sslBignum3Title}</h4>
                <p>{$hadrianLang.store.sslBignum3Text}</p>
            </div>
        </div>
    </section>

    {* 7. FAQ *}
    <section class="hp-faq-section">
        <h2>{$hadrianLang.store.sslFaqTitle}</h2>
        <details class="hp-faq-item" open>
            <summary>{$hadrianLang.store.sslFaqQ1}</summary>
            <div class="faq-body">{$hadrianLang.store.sslFaqA1}</div>
        </details>
        <details class="hp-faq-item">
            <summary>{$hadrianLang.store.sslFaqQ2}</summary>
            <div class="faq-body">{$hadrianLang.store.sslFaqA2}</div>
        </details>
        <details class="hp-faq-item">
            <summary>{$hadrianLang.store.sslFaqQ3}</summary>
            <div class="faq-body">{$hadrianLang.store.sslFaqA3}</div>
        </details>
        <details class="hp-faq-item">
            <summary>{$hadrianLang.store.sslFaqQ4}</summary>
            <div class="faq-body">{$hadrianLang.store.sslFaqA4}</div>
        </details>
        <details class="hp-faq-item">
            <summary>{$hadrianLang.store.sslFaqQ5}</summary>
            <div class="faq-body">{$hadrianLang.store.sslFaqA5}</div>
        </details>
    </section>

    {* 8. Final CTA *}
    <section class="hp-final-cta">
        <h2>{$hadrianLang.store.sslCtaTitle}</h2>
        <p>{$hadrianLang.store.sslCtaText}</p>
        <div>
            <a href="{$WEB_ROOT}/contact.php" class="btn">{$hadrianLang.store.sslCtaPrimary}</a>
            <a href="#pricing" class="second-link">{$hadrianLang.store.sslCtaSecondary} &rsaquo;</a>
        </div>
    </section>
</div>

<div class="when-empty" style="text-align:center;padding:60px 24px;background:var(--color-surface);border:1px solid var(--color-border);border-radius:14px;">
    <div style="width:56px;height:56px;border-radius:50%;background:var(--color-bg);display:inline-flex;align-items:center;justify-content:center;margin-bottom:16px;color:var(--color-text-tertiary);">
        <svg viewBox="0 0 24 24" width="22" height="22" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="11" width="18" height="11" rx="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/></svg>
    </div>
    <p style="font-size:17px;font-weight:600;color:var(--color-text-primary);margin:0 0 6px;">{$hadrianLang.store.sslEmptyTitle}</p>
    <p style="font-size:14px;color:var(--color-text-secondary);margin:0 0 20px;max-width:380px;margin-left:auto;margin-right:auto;line-height:1.5;">{$hadrianLang.store.sslEmptyText}</p>
    <a href="{$WEB_ROOT}/" class="btn-primary">{$hadrianLang.store.sslEmptyHome}</a>
</div>
