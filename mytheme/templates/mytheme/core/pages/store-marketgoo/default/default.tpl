{* Store landing - SEO Tools (MarketGoo).
   Ported from apple-client-area/seo-tools.html (Public/Marketing landing).
   header.tpl/footer.tpl provide the shell + .content-area, so we emit only the
   inner content (page-header + when-full marketing + when-empty offline state).

   Real pricing: the WHMCS MarketGoo store controller assigns $plans (Lite/Pro)
   and $inPreview - same contract as six/store/marketgoo/index.tpl. The mockup's
   two pricing cards map 1:1 to the real Lite/Pro plans, so we keep the exact
   card copy/features and wire each card's price + order button to the real plan
   (captured by position), falling back to the mockup values when MarketConnect
   isn't configured. Static copy is tokenized into the hadrianLang store group
   (mg-prefixed keys); decorative illustrations/testimonials kept verbatim.

   .hp-onboarding-steps is decorative and styled inline in the mockup (no
   stylesheet rule), so its markup is kept verbatim. *}

{assign var=_mgCount value=0}
{if isset($plans)}{assign var=_mgCount value=$plans|@count}{/if}
{assign var=_mgI value=0}
{if $_mgCount > 0}
    {foreach $plans as $_mgPlan}
        {if $_mgI == 0}{assign var=_mgLite value=$_mgPlan}{elseif $_mgI == 1}{assign var=_mgPro value=$_mgPlan}{/if}
        {assign var=_mgI value=$_mgI+1}
    {/foreach}
{/if}
{if $_mgCount > 0 || (isset($inPreview) && $inPreview)}
    {assign var=storeIsEmpty value='full'}
{else}
    {assign var=storeIsEmpty value='empty'}
{/if}

<header class="page-header">
    <p class="page-eyebrow">{$hadrianLang.store.mgEyebrow}</p>
    <h1>{$hadrianLang.store.mgPageTitle}</h1>
    <p class="page-subtitle">{$hadrianLang.store.mgPageSubtitle}</p>
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

    {* 1. Hero Split *}
    <section class="hp-hero-split" style="padding: 60px 22px;">
        <div class="hp-split-text">
            <div class="hp-eyebrow">{$hadrianLang.store.mgHeroEyebrow}</div>
            <h1>{$hadrianLang.store.mgHeroTitle}</h1>
            <p>{$hadrianLang.store.mgHeroText}</p>
            <div class="hp-cta-row">
                <a href="#pricing" class="hp-buy-btn">{$hadrianLang.store.mgHeroCta}</a>
                <a href="#pricing">{$hadrianLang.store.mgLearnMore} &rsaquo;</a>
            </div>
        </div>
        <div class="hp-split-visual">
            <div class="visual-box" style="background: linear-gradient(135deg, #eef5ff 0%, #dbeafe 100%); padding: 28px;">
                <div style="background: #fff; border-radius: 14px; padding: 14px; width: 100%; max-width: 300px; box-shadow: 0 8px 24px rgba(0,0,0,0.08);">
                    <div style="font-size: 11px; font-weight: 600; color: #1d1d1f; margin-bottom: 10px;">SEO Score</div>
                    <div style="display: flex; align-items: center; gap: 10px; margin-bottom: 12px;">
                        <div style="width: 56px; height: 56px; background: conic-gradient(#30d158 0% 82%, #e8e8ed 82% 100%); border-radius: 50%; display: flex; align-items: center; justify-content: center;">
                            <div style="width: 42px; height: 42px; background: #fff; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-size: 13px; font-weight: 700; color: #1d1d1f;">82</div>
                        </div>
                        <div style="flex: 1;">
                            <div style="font-size: 11px; color: #86868b;">Organic traffic</div>
                            <div style="font-size: 16px; font-weight: 700; color: #30d158;">+ 47%</div>
                        </div>
                    </div>
                    <svg viewBox="0 0 240 60" style="width: 100%; height: 60px;">
                        <path d="M0,45 L30,40 L60,42 L90,30 L120,25 L150,18 L180,20 L210,12 L240,8" fill="none" stroke="#0071e3" stroke-width="2"/>
                    </svg>
                </div>
            </div>
        </div>
    </section>

    {* 2. 3-step onboarding (hp-onboarding-steps - inline styled in the mockup) *}
    <section class="hp-onboarding-steps" style="padding: 72px 22px; max-width: 1100px; margin: 0 auto;">
        <div style="text-align: center; color: var(--color-accent); font-size: 13px; font-weight: 600; text-transform: uppercase; letter-spacing: 0.05em; margin-bottom: 8px;">{$hadrianLang.store.mgStepsEyebrow}</div>
        <h2 style="text-align: center; font-size: 48px; font-weight: 600; letter-spacing: -0.02em; margin: 0 0 48px;">{$hadrianLang.store.mgStepsTitle}</h2>
        <div style="display: grid; grid-template-columns: repeat(3, 1fr); gap: 20px; position: relative;">
            <div style="background: #fff; border: 1px solid #e8e8ed; border-radius: 18px; padding: 32px 24px; text-align: center; position: relative;">
                <div style="position: absolute; top: -18px; left: 50%; transform: translateX(-50%); width: 36px; height: 36px; background: #0071e3; color: #fff; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-weight: 700; font-size: 14px;">1</div>
                <div style="width: 72px; height: 72px; margin: 8px auto 16px; background: linear-gradient(135deg, #eaf4ff, #dbeafe); border-radius: 18px; display: flex; align-items: center; justify-content: center;">
                    <svg width="36" height="36" viewBox="0 0 24 24" fill="none" stroke="#0071e3" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"><path d="M20 21v-2a4 4 0 00-4-4H8a4 4 0 00-4 4v2"/><circle cx="12" cy="7" r="4"/><line x1="19" y1="8" x2="19" y2="14"/><line x1="22" y1="11" x2="16" y2="11"/></svg>
                </div>
                <h4 style="font-size: 17px; font-weight: 600; color: #1d1d1f; margin: 0 0 8px;">{$hadrianLang.store.mgStep1Title}</h4>
                <p style="font-size: 14px; color: #6e6e73; margin: 0;">{$hadrianLang.store.mgStep1Text}</p>
            </div>
            <div style="background: #fff; border: 1px solid #e8e8ed; border-radius: 18px; padding: 32px 24px; text-align: center; position: relative;">
                <div style="position: absolute; top: -18px; left: 50%; transform: translateX(-50%); width: 36px; height: 36px; background: #0071e3; color: #fff; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-weight: 700; font-size: 14px;">2</div>
                <div style="width: 72px; height: 72px; margin: 8px auto 16px; background: linear-gradient(135deg, #eaf8ee, #d4f0dc); border-radius: 18px; display: flex; align-items: center; justify-content: center;">
                    <svg width="36" height="36" viewBox="0 0 24 24" fill="none" stroke="#30d158" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"><path d="M14 2H6a2 2 0 00-2 2v16a2 2 0 002 2h12a2 2 0 002-2V8z"/><polyline points="14 2 14 8 20 8"/></svg>
                </div>
                <h4 style="font-size: 17px; font-weight: 600; color: #1d1d1f; margin: 0 0 8px;">{$hadrianLang.store.mgStep2Title}</h4>
                <p style="font-size: 14px; color: #6e6e73; margin: 0;">{$hadrianLang.store.mgStep2Text}</p>
            </div>
            <div style="background: #fff; border: 1px solid #e8e8ed; border-radius: 18px; padding: 32px 24px; text-align: center; position: relative;">
                <div style="position: absolute; top: -18px; left: 50%; transform: translateX(-50%); width: 36px; height: 36px; background: #0071e3; color: #fff; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-weight: 700; font-size: 14px;">3</div>
                <div style="width: 72px; height: 72px; margin: 8px auto 16px; background: linear-gradient(135deg, #faf0ff, #f0dbff); border-radius: 18px; display: flex; align-items: center; justify-content: center;">
                    <svg width="36" height="36" viewBox="0 0 24 24" fill="none" stroke="#bf5af2" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"><polyline points="9 11 12 14 22 4"/><path d="M21 12v7a2 2 0 01-2 2H5a2 2 0 01-2-2V5a2 2 0 012-2h11"/></svg>
                </div>
                <h4 style="font-size: 17px; font-weight: 600; color: #1d1d1f; margin: 0 0 8px;">{$hadrianLang.store.mgStep3Title}</h4>
                <p style="font-size: 14px; color: #6e6e73; margin: 0;">{$hadrianLang.store.mgStep3Text}</p>
            </div>
        </div>
        <div style="text-align: center; margin-top: 32px;">
            <a href="#pricing" class="hp-buy-btn">{$hadrianLang.store.mgHeroCta}</a>
        </div>
    </section>

    {* 3. Alt rows *}
    <div class="hp-alternating">
        <div class="hp-alt-row">
            <div class="hp-alt-text">
                <div class="hp-eyebrow">{$hadrianLang.store.mgHowEyebrow}</div>
                <h3>{$hadrianLang.store.mgHowTitle}</h3>
                <p>{$hadrianLang.store.mgHowText}</p>
            </div>
            <div class="hp-alt-visual">
                <div class="visual-box" style="background: #f5f5f7; padding: 24px;">
                    <div style="width: 100%; max-width: 300px; background: #fff; border-radius: 14px; padding: 14px;">
                        <div style="display: flex; align-items: center; gap: 8px; margin-bottom: 12px;">
                            <div style="width: 56px; height: 56px; background: conic-gradient(#0071e3 0% 62%, #e8e8ed 62% 100%); border-radius: 50%; display: flex; align-items: center; justify-content: center;">
                                <div style="width: 42px; height: 42px; background: #fff; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-size: 13px; font-weight: 700; color: var(--color-accent);">62%</div>
                            </div>
                            <div style="flex: 1;">
                                <div style="font-size: 11px; color: #86868b;">Plan progress</div>
                                <div style="font-size: 13px; font-weight: 600; color: #1d1d1f;">16 of 26 tasks</div>
                            </div>
                        </div>
                        <div style="display: flex; flex-direction: column; gap: 8px;">
                            <div style="display: flex; align-items: center; gap: 8px; padding: 8px 10px; background: #e8f8ed; border-radius: 8px;"><svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#1a7f37" stroke-width="2.5"><polyline points="20 6 9 17 4 12"/></svg><span style="font-size: 11px; color: #1a7f37; font-weight: 500;">Add meta descriptions</span></div>
                            <div style="display: flex; align-items: center; gap: 8px; padding: 8px 10px; background: #f5f5f7; border-radius: 8px;"><svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#86868b" stroke-width="2"><circle cx="12" cy="12" r="10"/></svg><span style="font-size: 11px; color: #1d1d1f;">Optimize images</span></div>
                            <div style="display: flex; align-items: center; gap: 8px; padding: 8px 10px; background: #f5f5f7; border-radius: 8px;"><svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#86868b" stroke-width="2"><circle cx="12" cy="12" r="10"/></svg><span style="font-size: 11px; color: #1d1d1f;">Add internal links</span></div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <div class="hp-alt-row reverse">
            <div class="hp-alt-text">
                <div class="hp-eyebrow">{$hadrianLang.store.mgTrackEyebrow}</div>
                <h3>{$hadrianLang.store.mgTrackTitle}</h3>
                <p>{$hadrianLang.store.mgTrackText}</p>
            </div>
            <div class="hp-alt-visual">
                <div class="visual-box" style="background: #eaf4ff; padding: 24px;">
                    <div style="width: 100%; max-width: 300px; background: #fff; border-radius: 14px; padding: 14px;">
                        <div style="font-size: 11px; font-weight: 600; color: #1d1d1f; margin-bottom: 10px;">Keyword tracking</div>
                        <div style="display: flex; flex-direction: column; gap: 8px;">
                            <div style="display: flex; align-items: center; justify-content: space-between; padding: 8px 10px; background: #f5f5f7; border-radius: 8px;"><span style="font-size: 11px; color: #1d1d1f;">best hosting 2026</span><span style="display: flex; align-items: center; gap: 4px; color: #30d158; font-size: 11px; font-weight: 600;"><svg width="10" height="10" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3"><polyline points="18 15 12 9 6 15"/></svg>#3</span></div>
                            <div style="display: flex; align-items: center; justify-content: space-between; padding: 8px 10px; background: #f5f5f7; border-radius: 8px;"><span style="font-size: 11px; color: #1d1d1f;">cloud hosting deals</span><span style="display: flex; align-items: center; gap: 4px; color: #30d158; font-size: 11px; font-weight: 600;"><svg width="10" height="10" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3"><polyline points="18 15 12 9 6 15"/></svg>#7</span></div>
                            <div style="display: flex; align-items: center; justify-content: space-between; padding: 8px 10px; background: #f5f5f7; border-radius: 8px;"><span style="font-size: 11px; color: #1d1d1f;">vps server</span><span style="display: flex; align-items: center; gap: 4px; color: #ff9f0a; font-size: 11px; font-weight: 600;"><svg width="10" height="10" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3"><polyline points="6 9 12 15 18 9"/></svg>#12</span></div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <div class="hp-alt-row">
            <div class="hp-alt-text">
                <div class="hp-eyebrow">{$hadrianLang.store.mgZeroEyebrow}</div>
                <h3>{$hadrianLang.store.mgZeroTitle}</h3>
                <p>{$hadrianLang.store.mgZeroText}</p>
                <div class="hp-cta-row" style="margin-top: 20px;">
                    <a href="#pricing" class="hp-buy-btn">{$hadrianLang.store.mgHeroCta}</a>
                    <span style="font-size: 21px; font-weight: 600; color: #1d1d1f;">{if isset($_mgLite) && !$_mgLite->isFree()}{$_mgLite->pricing()->first()->toPrefixedString()}{else}$4.99{/if}</span>
                </div>
            </div>
            <div class="hp-alt-visual">
                <div class="visual-box" style="background: #f5f5f7; padding: 24px;">
                    <div style="width: 100%; max-width: 300px; background: #fff; border-radius: 14px; padding: 20px; text-align: center;">
                        <div style="width: 80px; height: 80px; margin: 0 auto 12px; background: linear-gradient(135deg, #0071e3, #5ac8fa); border-radius: 20px; display: flex; align-items: center; justify-content: center; color: #fff; font-size: 32px; font-weight: 700;">SEO</div>
                        <div style="font-size: 13px; font-weight: 600; color: #1d1d1f;">Report ready</div>
                        <div style="font-size: 11px; color: #86868b; margin-top: 4px;">42 recommendations</div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    {* 4. Testimonial band *}
    <div style="background: var(--color-surface-secondary);">
    <section class="hp-features-section" style="padding: 72px 22px;">
        <div style="text-align: center; color: var(--color-accent); font-size: 13px; font-weight: 600; text-transform: uppercase; letter-spacing: 0.05em; margin-bottom: 8px;">{$hadrianLang.store.mgCustomersEyebrow}</div>
        <h2>{$hadrianLang.store.mgCustomersTitle}</h2>
        <div class="hp-feature-cards" style="margin-top: 40px; grid-template-columns: repeat(3, 1fr);">
            <div class="hp-feature-card">
                <div class="stars" style="color: #ffd60a; font-size: 18px; margin-bottom: 10px;">&starf;&starf;&starf;&starf;&starf;</div>
                <p style="font-size: 14px; color: var(--color-text-primary);">marketgoo made me stand out in just 2 months. Traffic tripled. I worked through the plan tasks, followed every recommendation, and the rank-tracking dashboard is the cherry on top.</p>
                <div style="display: flex; align-items: center; gap: 10px; margin-top: 16px;"><div style="width: 36px; height: 36px; border-radius: 50%; background-image: url('https://i.pravatar.cc/96?u=rachelkg'); background-size: cover;"></div><div><div style="font-size: 13px; font-weight: 600; color: var(--color-text-primary);">Rachel Kg</div><div style="font-size: 11px; color: #86868b;">Marketing Director</div></div></div>
            </div>
            <div class="hp-feature-card">
                <div class="stars" style="color: #ffd60a; font-size: 18px; margin-bottom: 10px;">&starf;&starf;&starf;&starf;&starf;</div>
                <p style="font-size: 14px; color: var(--color-text-primary);">A simple, reliable plan that matched our own SEO tooling. We had it up and running in minutes, and the guide that shows me the next step to take is impressively straightforward.</p>
                <div style="display: flex; align-items: center; gap: 10px; margin-top: 16px;"><div style="width: 36px; height: 36px; border-radius: 50%; background-image: url('https://i.pravatar.cc/96?u=simonjude'); background-size: cover;"></div><div><div style="font-size: 13px; font-weight: 600; color: var(--color-text-primary);">Simon Jude</div><div style="font-size: 11px; color: #86868b;">Founder, BrightStack</div></div></div>
            </div>
            <div class="hp-feature-card">
                <div class="stars" style="color: #ffd60a; font-size: 18px; margin-bottom: 10px;">&starf;&starf;&starf;&starf;&starf;</div>
                <p style="font-size: 14px; color: var(--color-text-primary);">marketgoo is excellent and easy to use for a non-technical team. I love the service and support. The fact that the plan re-generates after I complete tasks is the smartest SEO feature.</p>
                <div style="display: flex; align-items: center; gap: 10px; margin-top: 16px;"><div style="width: 36px; height: 36px; border-radius: 50%; background-image: url('https://i.pravatar.cc/96?u=saraazzonger'); background-size: cover;"></div><div><div style="font-size: 13px; font-weight: 600; color: var(--color-text-primary);">Sara Azzonger</div><div style="font-size: 11px; color: #86868b;">Ecommerce Manager</div></div></div>
            </div>
        </div>
    </section>
    </div>

    {* 5. Pricing - mockup's Lite/Pro cards with price + order wired to real plans *}
    <section class="hp-pricing-section" id="pricing" style="padding: 72px 22px;">
        <div style="text-align: center; color: var(--color-accent); font-size: 13px; font-weight: 600; text-transform: uppercase; letter-spacing: 0.05em; margin-bottom: 8px;">{$hadrianLang.store.mgPricingEyebrow}</div>
        <h2 style="text-align: center;">{$hadrianLang.store.mgPricingTitle}</h2>
        <div class="hp-pricing-grid" style="grid-template-columns: repeat(2, 1fr); max-width: 760px; margin: 40px auto 0;">
            <div class="hp-price-card dim">
                <div class="label">{if isset($_mgLite)}{$_mgLite->name|escape}{else}Lite{/if}</div>
                <h3>{$hadrianLang.store.mgLiteTagline}</h3>
                <div class="price-row">{if isset($_mgLite)}{if $_mgLite->isFree()}<span class="price">{$hadrianLang.store.mgFree}</span>{else}<span class="price">{$_mgLite->pricing()->first()->toPrefixedString()}</span>{/if}{else}<span class="price">$4.99</span><span class="per">/mo</span>{/if}</div>
                <ul>
                    <li>{$hadrianLang.store.mgLiteF1}</li>
                    <li>{$hadrianLang.store.mgLiteF2}</li>
                    <li>{$hadrianLang.store.mgLiteF3}</li>
                    <li>{$hadrianLang.store.mgLiteF4}</li>
                    <li>{$hadrianLang.store.mgLiteF5}</li>
                    <li>{$hadrianLang.store.mgLiteF6}</li>
                    <li>{$hadrianLang.store.mgLiteF7}</li>
                </ul>
                <a class="buy" href="{if isset($_mgLite)}{$WEB_ROOT}/cart.php?a=add&amp;pid={$_mgLite->id}{else}#pricing{/if}">{$hadrianLang.store.mgOrderNow}</a>
            </div>
            <div class="hp-price-card highlight">
                <div class="label" style="color: var(--color-accent);">{if isset($_mgPro)}{$_mgPro->name|escape}{else}Pro{/if}</div>
                <h3>{$hadrianLang.store.mgProTagline}</h3>
                <div class="price-row">{if isset($_mgPro)}{if $_mgPro->isFree()}<span class="price">{$hadrianLang.store.mgFree}</span>{else}<span class="price">{$_mgPro->pricing()->first()->toPrefixedString()}</span>{/if}{else}<span class="price">$14.99</span><span class="per">/mo</span>{/if}</div>
                <ul>
                    <li>{$hadrianLang.store.mgProF1}</li>
                    <li>{$hadrianLang.store.mgProF2}</li>
                    <li>{$hadrianLang.store.mgProF3}</li>
                    <li>{$hadrianLang.store.mgProF4}</li>
                    <li>{$hadrianLang.store.mgProF5}</li>
                    <li>{$hadrianLang.store.mgProF6}</li>
                    <li>{$hadrianLang.store.mgProF7}</li>
                </ul>
                <a class="buy" href="{if isset($_mgPro)}{$WEB_ROOT}/cart.php?a=add&amp;pid={$_mgPro->id}{else}#pricing{/if}">{$hadrianLang.store.mgOrderNow}</a>
            </div>
        </div>
    </section>

    {* 6. Big number results *}
    <section class="hp-feature-bignum">
        <h2 style="font-size: 36px;">{$hadrianLang.store.mgBignumTitle}</h2>
        <p class="sub">{$hadrianLang.store.mgBignumSub}</p>
        <div class="hp-bignum-grid">
            <div class="hp-bignum-item">
                <div class="num">35,000+</div>
                <h4>{$hadrianLang.store.mgBignum1Title}</h4>
                <p>{$hadrianLang.store.mgBignum1Text}</p>
            </div>
            <div class="hp-bignum-item">
                <div class="num">+47%</div>
                <h4>{$hadrianLang.store.mgBignum2Title}</h4>
                <p>{$hadrianLang.store.mgBignum2Text}</p>
            </div>
            <div class="hp-bignum-item">
                <div class="num">4.8/5</div>
                <h4>{$hadrianLang.store.mgBignum3Title}</h4>
                <p>{$hadrianLang.store.mgBignum3Text}</p>
            </div>
        </div>
    </section>

    {* Star rating block *}
    <section class="hp-testi-reviews">
        <div class="big-stars">&starf;&starf;&starf;&starf;&starf;</div>
        <div class="rating-num">4.8</div>
        <div class="rating-of">{$hadrianLang.store.mgRatingOf}</div>
        <div class="review-sources">
            <div class="rev-src"><div class="stars">&starf;&starf;&starf;&starf;&starf;</div><div class="src-name">G2</div><div class="src-count">9,200 reviews</div></div>
            <div class="rev-src"><div class="stars">&starf;&starf;&starf;&starf;&starf;</div><div class="src-name">Trustpilot</div><div class="src-count">12,400 reviews</div></div>
            <div class="rev-src"><div class="stars">&starf;&starf;&starf;&starf;&starf;</div><div class="src-name">WordPress.org</div><div class="src-count">5,820 reviews</div></div>
            <div class="rev-src"><div class="stars">&starf;&starf;&starf;&starf;&starf;</div><div class="src-name">Capterra</div><div class="src-count">7,580 reviews</div></div>
        </div>
    </section>

    {* 7. FAQ *}
    <section class="hp-faq-section">
        <h2>{$hadrianLang.store.mgFaqTitle}</h2>
        <details class="hp-faq-item" open>
            <summary>{$hadrianLang.store.mgFaqQ1}</summary>
            <div class="faq-body">{$hadrianLang.store.mgFaqA1}</div>
        </details>
        <details class="hp-faq-item">
            <summary>{$hadrianLang.store.mgFaqQ2}</summary>
            <div class="faq-body">{$hadrianLang.store.mgFaqA2}</div>
        </details>
        <details class="hp-faq-item">
            <summary>{$hadrianLang.store.mgFaqQ3}</summary>
            <div class="faq-body">{$hadrianLang.store.mgFaqA3}</div>
        </details>
    </section>

    {* 8. Immersive CTA *}
    <section class="hp-cta-immersive">
        <div class="inner">
            <h2>{$hadrianLang.store.mgCtaTitle}</h2>
            <p>{$hadrianLang.store.mgCtaText}</p>
            <a href="#pricing" class="btn">{$hadrianLang.store.mgCtaBtn}</a>
        </div>
    </section>
</div>

<div class="when-empty" style="text-align:center;padding:60px 24px;background:var(--color-surface);border:1px solid var(--color-border);border-radius:14px;">
    <div style="width:56px;height:56px;border-radius:50%;background:var(--color-bg);display:inline-flex;align-items:center;justify-content:center;margin-bottom:16px;color:var(--color-text-tertiary);">
        <svg viewBox="0 0 24 24" width="22" height="22" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="8"/><path d="M21 21l-4.3-4.3"/></svg>
    </div>
    <p style="font-size:17px;font-weight:600;color:var(--color-text-primary);margin:0 0 6px;">{$hadrianLang.store.mgEmptyTitle}</p>
    <p style="font-size:14px;color:var(--color-text-secondary);margin:0 0 20px;max-width:380px;margin-left:auto;margin-right:auto;line-height:1.5;">{$hadrianLang.store.mgEmptyText}</p>
    <a href="{$WEB_ROOT}/" class="btn-primary">{$hadrianLang.store.mgEmptyHome}</a>
</div>
