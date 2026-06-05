{* Store landing - Website Backup (CodeGuard).
   Ported from apple-client-area/website-backup.html (Public/Marketing
   landing). header.tpl/footer.tpl provide the shell + .content-area, so we
   emit only the inner content (page-header + when-full marketing + when-empty
   offline state).

   Real pricing: the WHMCS CodeGuard store controller assigns $products (the
   backup-size tiers), $inPreview - same contract as six/store/codeguard/index.tpl.
   The pricing bar loops that real data into the mockup's hp-seg-col cards when
   configured, falling back to the mockup's representative tiers otherwise so
   the page always renders cleanly. Static hero/feature/FAQ copy is tokenized
   into the hadrianLang store group (cg-prefixed keys); decorative
   SVG/illustration blocks and testimonial social-proof are kept verbatim. *}

{assign var=_cgCount value=0}
{if isset($products) && is_array($products)}{assign var=_cgCount value=$products|@count}{/if}
{if $_cgCount > 0 || (isset($inPreview) && $inPreview)}
    {assign var=storeIsEmpty value='full'}
{else}
    {assign var=storeIsEmpty value='empty'}
{/if}

<header class="page-header">
    <p class="page-eyebrow">{$hadrianLang.store.cgEyebrow}</p>
    <h1>{$hadrianLang.store.cgPageTitle}</h1>
    <p class="page-subtitle">{$hadrianLang.store.cgPageSubtitle}</p>
</header>

<script>
(function () {
    var b = document.body;
    if (!b) return;
    b.setAttribute('data-data', '{$storeIsEmpty}');
    b.setAttribute('data-svc-layout', 'inside');
})();
</script>

<div class="when-full">

    {* 1. Hero *}
    <section class="hp-hero-split" style="padding: 60px 22px;">
        <div class="hp-split-text">
            <div class="hp-eyebrow">{$hadrianLang.store.cgHeroEyebrow}</div>
            <h1>{$hadrianLang.store.cgHeroTitle}</h1>
            <p>{$hadrianLang.store.cgHeroText}</p>
            <div class="hp-cta-row">
                <a href="#pricing" class="hp-buy-btn">{$hadrianLang.store.cgHeroCta}</a>
                <a href="#pricing">{$hadrianLang.store.cgLearnMore} &rsaquo;</a>
            </div>
        </div>
        <div class="hp-split-visual">
            <div class="visual-box" style="background: linear-gradient(135deg, #eef5ff 0%, #dbeafe 100%); padding: 28px;">
                <div style="background: #fff; border-radius: 14px; padding: 14px; width: 100%; max-width: 300px; box-shadow: 0 8px 24px rgba(0,0,0,0.08);">
                    <div style="display: flex; align-items: center; justify-content: space-between; margin-bottom: 12px;">
                        <div style="font-size: 11px; font-weight: 600; color: #1d1d1f;">Backup history</div>
                        <span style="font-size: 10px; color: #30d158; font-weight: 600;">&bull; Active</span>
                    </div>
                    <div style="display: flex; flex-direction: column; gap: 6px;">
                        <div style="display: flex; align-items: center; justify-content: space-between; padding: 8px 10px; background: #e8f8ed; border-radius: 8px;"><span style="font-size: 11px; color: #1a7f37;">Today &middot; 03:00 AM</span><svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#1a7f37" stroke-width="2.5"><polyline points="20 6 9 17 4 12"/></svg></div>
                        <div style="display: flex; align-items: center; justify-content: space-between; padding: 8px 10px; background: #f5f5f7; border-radius: 8px;"><span style="font-size: 11px; color: #1d1d1f;">Yesterday &middot; 03:00 AM</span><svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#30d158" stroke-width="2.5"><polyline points="20 6 9 17 4 12"/></svg></div>
                        <div style="display: flex; align-items: center; justify-content: space-between; padding: 8px 10px; background: #f5f5f7; border-radius: 8px;"><span style="font-size: 11px; color: #1d1d1f;">2 days ago &middot; 03:00 AM</span><svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#30d158" stroke-width="2.5"><polyline points="20 6 9 17 4 12"/></svg></div>
                        <div style="display: flex; align-items: center; justify-content: space-between; padding: 8px 10px; background: #f5f5f7; border-radius: 8px;"><span style="font-size: 11px; color: #1d1d1f;">3 days ago &middot; 03:00 AM</span><svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#30d158" stroke-width="2.5"><polyline points="20 6 9 17 4 12"/></svg></div>
                    </div>
                </div>
            </div>
        </div>
    </section>

    {* 2. Pricing - real $products looped into the mockup's segmented bar; static
       representative tiers as the fallback when MarketConnect isn't configured. *}
    <section class="hp-pricing-segmented" id="pricing">
        <h2 style="font-size: 36px;">{$hadrianLang.store.cgPricingTitle}</h2>
        <p class="sub">{$hadrianLang.store.cgPricingSub}</p>
        <div class="hp-billing-toggle" style="margin: 16px auto 24px;"><button class="active">{$hadrianLang.store.cgCycleMonthly}</button><button>{$hadrianLang.store.cgCycleQuarterly}</button><button>{$hadrianLang.store.cgCycleSemi}</button><button>{$hadrianLang.store.cgCycleAnnually}</button></div>
        <div class="hp-segmented-bar">
            {if $_cgCount > 0}
                {foreach $products as $_cgProduct}
                <div class="hp-seg-col{if $_cgProduct->isFeatured} highlight{/if}">
                    <div class="tier">{$_cgProduct->name|escape}</div>
                    <div class="price">{$_cgProduct->pricing()->first()->price()}</div>
                    <div class="desc">{if $_cgProduct->isFeatured}{$hadrianLang.store.cgMostPopular}{else}{$_cgProduct->diskSpace|escape}{/if}</div>
                    <ul class="seg-features">
                        <li>{$hadrianLang.store.cgSegFeat1}</li>
                        <li>{$hadrianLang.store.cgSegFeat2}</li>
                        <li>{$hadrianLang.store.cgSegFeat3}</li>
                        <li>{$hadrianLang.store.cgSegFeat4}</li>
                    </ul>
                    <a href="{$WEB_ROOT}/cart.php?a=add&amp;pid={$_cgProduct->id}" class="buy">{$hadrianLang.store.cgChoose}</a>
                </div>
                {/foreach}
            {else}
                <div class="hp-seg-col">
                    <div class="tier">1 GB Lite</div>
                    <div class="price">$2.08<span class="per">/mo</span></div>
                    <div class="desc">{$hadrianLang.store.cgTier1Desc}</div>
                    <ul class="seg-features"><li>1 GB backup storage</li><li>1 website</li><li>{$hadrianLang.store.cgSegFeat1}</li><li>{$hadrianLang.store.cgSegFeat2}</li></ul>
                    <a href="#pricing" class="buy">{$hadrianLang.store.cgChoose}</a>
                </div>
                <div class="hp-seg-col">
                    <div class="tier">5 GB Personal</div>
                    <div class="price">$3.33<span class="per">/mo</span></div>
                    <div class="desc">{$hadrianLang.store.cgTier2Desc}</div>
                    <ul class="seg-features"><li>5 GB backup storage</li><li>1 website</li><li>MySQL database backup</li><li>{$hadrianLang.store.cgSegFeat4}</li></ul>
                    <a href="#pricing" class="buy">{$hadrianLang.store.cgChoose}</a>
                </div>
                <div class="hp-seg-col highlight">
                    <div class="tier">10 GB Professional</div>
                    <div class="price">$6.58<span class="per">/mo</span></div>
                    <div class="desc">{$hadrianLang.store.cgMostPopular}</div>
                    <ul class="seg-features"><li>10 GB backup storage</li><li>3 websites</li><li>Multi-site support</li><li>Priority queue</li></ul>
                    <a href="#pricing" class="buy">{$hadrianLang.store.cgChoosePro}</a>
                </div>
                <div class="hp-seg-col">
                    <div class="tier">25 GB Business</div>
                    <div class="price">$16.25<span class="per">/mo</span></div>
                    <div class="desc">{$hadrianLang.store.cgTier4Desc}</div>
                    <ul class="seg-features"><li>25 GB backup storage</li><li>5 websites</li><li>Priority support</li><li>Custom retention policy</li></ul>
                    <a href="#pricing" class="buy">{$hadrianLang.store.cgChoose}</a>
                </div>
            {/if}
        </div>
        <p style="text-align: center; font-size: 14px; color: #6e6e73; margin-top: 32px;">{$hadrianLang.store.cgNeedMore}</p>
    </section>

    {* 3. Big stat callout (hp-stat-callout - inline styled in the mockup) *}
    <section class="hp-stat-callout" style="padding: 72px 22px; max-width: 1100px; margin: 0 auto;">
        <div style="display: grid; grid-template-columns: 1.1fr 1fr; gap: 48px; align-items: center;">
            <div>
                <div class="hp-eyebrow">{$hadrianLang.store.cgWhyEyebrow}</div>
                <h2 style="font-size: 56px; font-weight: 700; letter-spacing: -0.03em; line-height: 1.05; margin: 0 0 20px;"><span style="color: #ff453a;">{$hadrianLang.store.cgWhyHighlight}</span>{$hadrianLang.store.cgWhyTitle}</h2>
                <p style="font-size: 17px; color: #6e6e73; line-height: 1.55; margin: 0;">{$hadrianLang.store.cgWhyText}</p>
            </div>
            <div style="position: relative;">
                <div style="background: linear-gradient(135deg, #fff0ef, #ffefec); border-radius: 24px; padding: 40px; min-height: 320px; display: flex; align-items: center; justify-content: center;">
                    <div style="background: #fff; border-radius: 14px; padding: 20px; width: 100%; max-width: 260px; box-shadow: 0 8px 24px rgba(0,0,0,0.08); position: relative;">
                        <div style="display: flex; gap: 4px; margin-bottom: 14px;"><span style="width: 8px; height: 8px; background: #ff453a; border-radius: 50%;"></span><span style="width: 8px; height: 8px; background: #ff9f0a; border-radius: 50%;"></span><span style="width: 8px; height: 8px; background: #30d158; border-radius: 50%;"></span></div>
                        <div style="background: #ffefec; border-radius: 10px; padding: 14px; text-align: center;">
                            <svg width="40" height="40" viewBox="0 0 24 24" fill="none" stroke="#ff453a" stroke-width="2" style="margin-bottom: 8px;"><path d="M10.29 3.86L1.82 18a2 2 0 001.71 3h16.94a2 2 0 001.71-3L13.71 3.86a2 2 0 00-3.42 0z"/><line x1="12" y1="9" x2="12" y2="13"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg>
                            <div style="font-size: 13px; font-weight: 600; color: #ff453a;">Malware detected</div>
                            <div style="font-size: 11px; color: #86868b; margin-top: 4px;">wp-config.php</div>
                        </div>
                        <div style="margin-top: 12px; padding: 10px; background: #e8f8ed; border-radius: 10px; display: flex; align-items: center; gap: 8px;">
                            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#1a7f37" stroke-width="2.5"><polyline points="20 6 9 17 4 12"/></svg>
                            <span style="font-size: 11px; color: #1a7f37; font-weight: 600;">Restored from backup</span>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>

    {* 4. Alt rows *}
    <div class="hp-alternating">
        <div class="hp-alt-row">
            <div class="hp-alt-text">
                <div class="hp-eyebrow">{$hadrianLang.store.cgWhatEyebrow}</div>
                <h3>{$hadrianLang.store.cgWhatTitle}</h3>
                <p>{$hadrianLang.store.cgWhatText}</p>
            </div>
            <div class="hp-alt-visual">
                <div class="visual-box" style="background: #f5f5f7; padding: 24px;">
                    <div style="width: 100%; max-width: 300px; background: #fff; border-radius: 14px; padding: 16px;">
                        <div style="font-size: 11px; font-weight: 600; color: #1d1d1f; margin-bottom: 10px;">One-click restore</div>
                        <div style="display: flex; align-items: center; gap: 10px;">
                            <div style="width: 48px; height: 48px; background: linear-gradient(135deg, #0071e3, #5ac8fa); border-radius: 12px; display: flex; align-items: center; justify-content: center;"><svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="#fff" stroke-width="2"><polyline points="1 4 1 10 7 10"/><path d="M3.51 15a9 9 0 102.13-9.36L1 10"/></svg></div>
                            <div style="flex: 1;">
                                <div style="font-size: 13px; font-weight: 600; color: #1d1d1f;">Restore to yesterday</div>
                                <div style="font-size: 11px; color: #86868b;">Estimated time: 3 min</div>
                            </div>
                        </div>
                        <button style="width: 100%; margin-top: 12px; padding: 10px; background: #0071e3; color: #fff; border: 0; border-radius: 10px; font-size: 13px; font-weight: 600; cursor: pointer;">Start restore</button>
                    </div>
                </div>
            </div>
        </div>
        <div class="hp-alt-row reverse">
            <div class="hp-alt-text">
                <div class="hp-eyebrow">{$hadrianLang.store.cgHowEyebrow}</div>
                <h3>{$hadrianLang.store.cgHowTitle}</h3>
                <p>{$hadrianLang.store.cgHowText}</p>
            </div>
            <div class="hp-alt-visual">
                <div class="visual-box" style="background: #eaf4ff; padding: 24px;">
                    <div style="width: 100%; max-width: 300px; background: #fff; border-radius: 14px; padding: 14px;">
                        <div style="font-size: 11px; font-weight: 600; color: #1d1d1f; margin-bottom: 10px;">Snapshot timeline</div>
                        <svg viewBox="0 0 260 80" style="width: 100%; height: 80px;">
                            <line x1="10" y1="40" x2="250" y2="40" stroke="#e8e8ed" stroke-width="2"/>
                            <circle cx="20" cy="40" r="8" fill="#30d158"/>
                            <circle cx="70" cy="40" r="6" fill="#0071e3"/>
                            <circle cx="120" cy="40" r="6" fill="#0071e3"/>
                            <circle cx="170" cy="40" r="6" fill="#0071e3"/>
                            <circle cx="220" cy="40" r="8" fill="#30d158"/>
                            <text x="15" y="70" font-size="9" fill="#86868b">Mon</text>
                            <text x="65" y="70" font-size="9" fill="#86868b">Tue</text>
                            <text x="113" y="70" font-size="9" fill="#86868b">Wed</text>
                            <text x="163" y="70" font-size="9" fill="#86868b">Thu</text>
                            <text x="214" y="70" font-size="9" fill="#86868b">Fri</text>
                        </svg>
                    </div>
                </div>
            </div>
        </div>
    </div>

    {* 5. Features 6-up (8 cards) *}
    <div style="background: var(--color-surface-secondary);">
    <section class="hp-features-section" style="padding: 72px 22px;">
        <h2>{$hadrianLang.store.cgFeaturesTitle}</h2>
        <div class="hp-feature-cards" style="margin-top: 40px;">
            <div class="hp-feature-card"><div class="feat-icon blue"><svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M21 15a2 2 0 01-2 2H7l-4 4V5a2 2 0 012-2h14a2 2 0 012 2z"/></svg></div><h4>{$hadrianLang.store.cgFeat1Title}</h4><p>{$hadrianLang.store.cgFeat1Text}</p></div>
            <div class="hp-feature-card"><div class="feat-icon green"><svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="3" width="18" height="18" rx="2"/></svg></div><h4>{$hadrianLang.store.cgFeat2Title}</h4><p>{$hadrianLang.store.cgFeat2Text}</p></div>
            <div class="hp-feature-card"><div class="feat-icon purple"><svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="9 11 12 14 22 4"/></svg></div><h4>{$hadrianLang.store.cgFeat3Title}</h4><p>{$hadrianLang.store.cgFeat3Text}</p></div>
            <div class="hp-feature-card"><div class="feat-icon orange"><svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M22 11.08V12a10 10 0 11-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg></div><h4>{$hadrianLang.store.cgFeat4Title}</h4><p>{$hadrianLang.store.cgFeat4Text}</p></div>
            <div class="hp-feature-card"><div class="feat-icon teal"><svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="23 4 23 10 17 10"/><polyline points="1 20 1 14 7 14"/></svg></div><h4>{$hadrianLang.store.cgFeat5Title}</h4><p>{$hadrianLang.store.cgFeat5Text}</p></div>
            <div class="hp-feature-card"><div class="feat-icon red"><svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/><path d="M12 6v6l4 2"/></svg></div><h4>{$hadrianLang.store.cgFeat6Title}</h4><p>{$hadrianLang.store.cgFeat6Text}</p></div>
            <div class="hp-feature-card"><div class="feat-icon blue"><svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/></svg></div><h4>{$hadrianLang.store.cgFeat7Title}</h4><p>{$hadrianLang.store.cgFeat7Text}</p></div>
            <div class="hp-feature-card"><div class="feat-icon green"><svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="2" y="4" width="20" height="16" rx="2"/><path d="M22 6l-10 7L2 6"/></svg></div><h4>{$hadrianLang.store.cgFeat8Title}</h4><p>{$hadrianLang.store.cgFeat8Text}</p></div>
        </div>
        <div style="text-align: center; margin-top: 32px;">
            <a href="#pricing" class="hp-buy-btn">{$hadrianLang.store.cgHeroCta}</a>
        </div>
    </section>
    </div>

    {* Trust bar *}
    <section class="hp-trust-bar">
        <div class="trust-inner">
            <div class="hp-hero-stat"><div class="stat-num" style="font-size: 48px; color: var(--color-text-primary);">AES-256</div><div class="stat-label">{$hadrianLang.store.cgTrust1}</div></div>
            <div class="hp-hero-stat"><div class="stat-num" style="font-size: 48px; color: var(--color-text-primary);">90-day</div><div class="stat-label">{$hadrianLang.store.cgTrust2}</div></div>
            <div class="hp-hero-stat"><div class="stat-num" style="font-size: 48px; color: var(--color-text-primary);">5</div><div class="stat-label">{$hadrianLang.store.cgTrust3}</div></div>
            <div class="hp-hero-stat"><div class="stat-num" style="font-size: 48px; color: var(--color-text-primary);">1-click</div><div class="stat-label">{$hadrianLang.store.cgTrust4}</div></div>
        </div>
    </section>

    {* 6. Testimonials - decorative social proof, kept verbatim *}
    <section class="hp-testi-masonry">
        <h2>{$hadrianLang.store.cgTestiTitle}</h2>
        <p class="hp-testi-masonry-sub">{$hadrianLang.store.cgTestiSub}</p>
        <div class="hp-testi-masonry-grid">
            <div class="hp-testi-tile"><div class="stars">&starf;&starf;&starf;&starf;&starf;</div><p class="quote">Very helpful support. I&rsquo;m thoroughly impressed with their hosting services. The standout feature for me is their outstanding customer support &mdash; quick, friendly, and incredibly helpful.</p><div class="author"><div class="avatar" style="background-image:url('https://i.pravatar.cc/96?u=johndoe');"></div><div><div class="name">John Doe</div><div class="role">Indie Developer</div></div></div></div>
            <div class="hp-testi-tile tall accent"><div class="stars">&starf;&starf;&starf;&starf;&starf;</div><p class="quote">Simply amazing. The quality, features, and value they offer have elevated my online presence. A fantastic choice for anyone seeking top-tier hosting solutions.</p><div class="author"><div class="avatar" style="background-image:url('https://i.pravatar.cc/96?u=mariagarcia');"></div><div><div class="name">Maria Garcia</div><div class="role">PixelAgency</div></div></div></div>
            <div class="hp-testi-tile"><div class="stars">&starf;&starf;&starf;&starf;&starf;</div><p class="quote">Great hosting company. Getting my WordPress website hosted was broadly effortless, and the success rests on the incredible hosting service we subscribe to.</p><div class="author"><div class="avatar" style="background-image:url('https://i.pravatar.cc/96?u=elizawilliams');"></div><div><div class="name">Eliza Williams</div><div class="role">Studio34</div></div></div></div>
            <div class="hp-testi-tile dark"><div class="stars">&starf;&starf;&starf;&starf;&starf;</div><p class="quote">Five star hosting service! Reviews are positive and the speeds are maintained thanks to unwavering cost-effectiveness.</p><div class="author"><div class="avatar" style="background-image:url('https://i.pravatar.cc/96?u=michaelsmith');"></div><div><div class="name">Michael Smith</div><div class="role">NextLabs</div></div></div></div>
            <div class="hp-testi-tile"><div class="stars">&starf;&starf;&starf;&starf;&starf;</div><p class="quote">Easy app installation. The hosting has exceeded my expectations. Their one-click app installation saved me time, and the speed optimization bumped my visitor load by 50%.</p><div class="author"><div class="avatar" style="background-image:url('https://i.pravatar.cc/96?u=davidwilson');"></div><div><div class="name">David Wilson</div><div class="role">Indie Builder</div></div></div></div>
            <div class="hp-testi-tile tall cream"><div class="stars">&starf;&starf;&starf;&starf;&starf;</div><p class="quote">Happy for the switch. Switching to this hosting was the best decision. Their server spec, amazing uptime, and features are unmatched &mdash; this is the provider I recommend to my clients.</p><div class="author"><div class="avatar" style="background-image:url('https://i.pravatar.cc/96?u=michaelbrown');"></div><div><div class="name">Michael Brown</div><div class="role">FreshGoods</div></div></div></div>
        </div>
    </section>

    {* 7. FAQ *}
    <section class="hp-faq-section">
        <h2>{$hadrianLang.store.cgFaqTitle}</h2>
        <details class="hp-faq-item" open>
            <summary>{$hadrianLang.store.cgFaqQ1}</summary>
            <div class="faq-body">{$hadrianLang.store.cgFaqA1}</div>
        </details>
        <details class="hp-faq-item">
            <summary>{$hadrianLang.store.cgFaqQ2}</summary>
            <div class="faq-body">{$hadrianLang.store.cgFaqA2}</div>
        </details>
        <details class="hp-faq-item">
            <summary>{$hadrianLang.store.cgFaqQ3}</summary>
            <div class="faq-body">{$hadrianLang.store.cgFaqA3}</div>
        </details>
        <details class="hp-faq-item">
            <summary>{$hadrianLang.store.cgFaqQ4}</summary>
            <div class="faq-body">{$hadrianLang.store.cgFaqA4}</div>
        </details>
        <details class="hp-faq-item">
            <summary>{$hadrianLang.store.cgFaqQ5}</summary>
            <div class="faq-body">{$hadrianLang.store.cgFaqA5}</div>
        </details>
        <details class="hp-faq-item">
            <summary>{$hadrianLang.store.cgFaqQ6}</summary>
            <div class="faq-body">{$hadrianLang.store.cgFaqA6}</div>
        </details>
    </section>

    {* 8. Split CTA *}
    <div class="hp-split-cta-wrapper" style="padding: 48px 22px;">
        <div class="hp-split-cta">
            <div class="cta-panel dark">
                <h3>{$hadrianLang.store.cgCtaDarkTitle}</h3>
                <p>{$hadrianLang.store.cgCtaDarkText}</p>
                <a href="#pricing" class="btn-primary-pill">{$hadrianLang.store.cgCtaDarkBtn}</a>
            </div>
            <div class="cta-panel light">
                <h3>{$hadrianLang.store.cgCtaLightTitle}</h3>
                <p>{$hadrianLang.store.cgCtaLightText}</p>
                <a href="{$WEB_ROOT}/contact.php" class="btn-outline-pill">{$hadrianLang.store.cgCtaLightBtn}</a>
            </div>
        </div>
    </div>
</div>

<div class="when-empty" style="text-align:center;padding:60px 24px;background:var(--color-surface);border:1px solid var(--color-border);border-radius:14px;">
    <div style="width:56px;height:56px;border-radius:50%;background:var(--color-bg);display:inline-flex;align-items:center;justify-content:center;margin-bottom:16px;color:var(--color-text-tertiary);">
        <svg viewBox="0 0 24 24" width="22" height="22" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"/></svg>
    </div>
    <p style="font-size:17px;font-weight:600;color:var(--color-text-primary);margin:0 0 6px;">{$hadrianLang.store.cgEmptyTitle}</p>
    <p style="font-size:14px;color:var(--color-text-secondary);margin:0 0 20px;max-width:380px;margin-left:auto;margin-right:auto;line-height:1.5;">{$hadrianLang.store.cgEmptyText}</p>
    <a href="{$WEB_ROOT}/" class="btn-primary">{$hadrianLang.store.cgEmptyHome}</a>
</div>
