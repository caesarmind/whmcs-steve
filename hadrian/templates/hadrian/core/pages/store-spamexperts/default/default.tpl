{* Store landing - E-mail Services (SpamExperts).
   Ported from the v18 Email Services mockup (Public/Marketing landing).
   header.tpl/footer.tpl provide the shell + .content-area, so we emit only the
   inner content (page-header + when-full marketing + when-empty offline state).

   Real pricing: the WHMCS SpamExperts store controller assigns $products (a
   named-slot object: ->incoming / ->outgoing / ->incomingoutgoing + archiving
   variants), $numberOfFeaturedProducts and $inPreview - same contract as
   six/store/spamexperts/index.tpl. The mockup's three pricing cards (Incoming,
   Outgoing, Bundle) keep their exact spec copy; we wire each card's price +
   order button to the matching real product (->pricing()->best()->toFullString()
   + ->id), falling back to the mockup values otherwise so the page always
   renders cleanly. We also capture the first available product into $_seFrom /
   $_seOrder for the hero/CTA mentions. Static prose is tokenized into the
   hadrianLang store group (se-prefixed keys); decorative SVG/illustration
   blocks and testimonials are kept verbatim. *}

{assign var=_seInc value=null}
{assign var=_seOut value=null}
{assign var=_seBundle value=null}
{if isset($products)}
    {if isset($products.incoming) && $products.incoming}{assign var=_seInc value=$products.incoming}{/if}
    {if isset($products.outgoing) && $products.outgoing}{assign var=_seOut value=$products.outgoing}{/if}
    {if isset($products.incomingoutgoing) && $products.incomingoutgoing}{assign var=_seBundle value=$products.incomingoutgoing}{/if}
{/if}

{assign var=_seFrom value='$2.99'}
{assign var=_sePid value=0}
{if $_seInc}
    {assign var=_sePid value=$_seInc->id}
    {if !$inPreview && $_seInc->pricing()->best()}{assign var=_seFrom value=$_seInc->pricing()->best()->toFullString()}{/if}
{elseif $_seOut}
    {assign var=_sePid value=$_seOut->id}
    {if !$inPreview && $_seOut->pricing()->best()}{assign var=_seFrom value=$_seOut->pricing()->best()->toFullString()}{/if}
{elseif $_seBundle}
    {assign var=_sePid value=$_seBundle->id}
    {if !$inPreview && $_seBundle->pricing()->best()}{assign var=_seFrom value=$_seBundle->pricing()->best()->toFullString()}{/if}
{/if}
{if $_sePid > 0}
    {assign var=_seOrder value="`$WEB_ROOT`/cart.php?a=add&pid=`$_sePid`"}
{else}
    {assign var=_seOrder value="`$WEB_ROOT`/cart.php?gid=marketconnect"}
{/if}
{assign var=_seFeatured value=0}
{if isset($numberOfFeaturedProducts)}{assign var=_seFeatured value=$numberOfFeaturedProducts}{/if}
{if $_seFeatured > 0 || (isset($inPreview) && $inPreview)}
    {assign var=storeIsEmpty value='full'}
{else}
    {assign var=storeIsEmpty value='empty'}
{/if}


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
            <div class="hp-eyebrow">{$hadrianLang.store.seHeroEyebrow}</div>
            <h1>{$hadrianLang.store.seHeroTitle}</h1>
            <p>{$hadrianLang.store.seHeroText}</p>
            <div class="hp-cta-row">
                <a href="{$_seOrder|escape}" class="hp-buy-btn">{$hadrianLang.store.seHeroCta}</a>
                <a href="#pricing">{$hadrianLang.store.seLearnMore} &rsaquo;</a>
            </div>
        </div>
        <div class="hp-split-visual">
            <div class="visual-box" style="background: linear-gradient(135deg, #eef5ff 0%, #dbeafe 100%); padding: 28px;">
                <div style="background: var(--color-surface); border-radius: 14px; padding: 14px; width: 100%; max-width: 300px; box-shadow: 0 8px 24px rgba(0,0,0,0.08);">
                    <div style="display: flex; align-items: center; gap: 10px; padding: 10px; background: #e8f8ed; border-radius: 10px; margin-bottom: 8px;">
                        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#1a7f37" stroke-width="2.5"><polyline points="20 6 9 17 4 12"/></svg>
                        <div style="flex: 1;">
                            <div style="font-size: 12px; font-weight: 600; color: var(--color-text-primary);">team@yoursite.com</div>
                            <div style="font-size: 10px; color: var(--color-text-tertiary);">Delivered &middot; Clean</div>
                        </div>
                    </div>
                    <div style="display: flex; align-items: center; gap: 10px; padding: 10px; background: #ffefec; border-radius: 10px; margin-bottom: 8px;">
                        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#ff453a" stroke-width="2.5"><circle cx="12" cy="12" r="10"/><line x1="15" y1="9" x2="9" y2="15"/><line x1="9" y1="9" x2="15" y2="15"/></svg>
                        <div style="flex: 1;">
                            <div style="font-size: 12px; font-weight: 600; color: var(--color-text-primary);">Malware payload</div>
                            <div style="font-size: 10px; color: #ff453a;">Blocked &middot; Quarantined</div>
                        </div>
                    </div>
                    <div style="display: flex; align-items: center; gap: 10px; padding: 10px; background: #fff6e6; border-radius: 10px;">
                        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#ff9f0a" stroke-width="2.5"><path d="M10.29 3.86L1.82 18a2 2 0 001.71 3h16.94a2 2 0 001.71-3L13.71 3.86a2 2 0 00-3.42 0z"/></svg>
                        <div style="flex: 1;">
                            <div style="font-size: 12px; font-weight: 600; color: var(--color-text-primary);">Phishing attempt</div>
                            <div style="font-size: 10px; color: #ff9f0a;">Flagged &middot; Reviewed</div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>

    {* 2. 3-up feature icons *}
    <section class="hp-icon-grid" style="padding: 40px 22px 48px;">
        <div class="hp-icon-item">
            <div class="icon-circle blue"><svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M22 11.08V12a10 10 0 11-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg></div>
            <h4>{$hadrianLang.store.seIcon1Title}</h4>
            <p>{$hadrianLang.store.seIcon1Text}</p>
            <a href="{$_seOrder|escape}" style="color: var(--color-accent); font-size: 13px; font-weight: 500; margin-top: 8px;">{$hadrianLang.store.seLearnMore} &rsaquo;</a>
        </div>
        <div class="hp-icon-item">
            <div class="icon-circle green"><svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="16 12 22 12 22 6"/><path d="M22 12H2"/><path d="M2 12l4-4"/><path d="M2 12l4 4"/></svg></div>
            <h4>{$hadrianLang.store.seIcon2Title}</h4>
            <p>{$hadrianLang.store.seIcon2Text}</p>
            <a href="{$_seOrder|escape}" style="color: var(--color-accent); font-size: 13px; font-weight: 500; margin-top: 8px;">{$hadrianLang.store.seLearnMore} &rsaquo;</a>
        </div>
        <div class="hp-icon-item">
            <div class="icon-circle purple"><svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="2" y="3" width="20" height="14" rx="2"/><line x1="8" y1="21" x2="16" y2="21"/><line x1="12" y1="17" x2="12" y2="21"/></svg></div>
            <h4>{$hadrianLang.store.seIcon3Title}</h4>
            <p>{$hadrianLang.store.seIcon3Text}</p>
            <a href="{$_seOrder|escape}" style="color: var(--color-accent); font-size: 13px; font-weight: 500; margin-top: 8px;">{$hadrianLang.store.seLearnMore} &rsaquo;</a>
        </div>
    </section>

    {* Trust awards strip - brand names kept verbatim *}
    <section class="hp-trust-awards">
        <div class="award-label">{$hadrianLang.store.seAwardLabel}</div>
        <div class="hp-awards-row">
            <div class="hp-award tc">Tech<span class="tc-c">Crunch</span></div>
            <div class="hp-award wired">WIRED</div>
            <div class="hp-award verge">Verge</div>
            <div class="hp-award forbes">Forbes</div>
            <div class="hp-award gtm"><span class="stars-sm">&starf;&starf;&starf;&starf;&starf;</span> G2 Leader</div>
        </div>
    </section>

    {* 3. Alt rows *}
    <div class="hp-alternating">

        <div class="hp-alt-row">
            <div class="hp-alt-text">
                <div class="hp-eyebrow">{$hadrianLang.store.seAlt1Eyebrow}</div>
                <h3>{$hadrianLang.store.seAlt1Title}</h3>
                <p>{$hadrianLang.store.seAlt1P1}</p>
                <p style="margin-top: 12px;">{$hadrianLang.store.seAlt1P2}</p>
            </div>
            <div class="hp-alt-visual">
                <div class="visual-box" style="background: var(--color-surface-secondary); padding: 24px;">
                    <div style="width: 100%; max-width: 300px;">
                        <div style="background: var(--color-surface); border-radius: 14px; padding: 14px;">
                            <div style="font-size: 11px; font-weight: 600; color: var(--color-text-primary); margin-bottom: 12px;">Protection Summary &mdash; Last 7 days</div>
                            <div style="display: flex; align-items: end; gap: 6px; height: 80px; margin-bottom: 12px;">
                                <div style="flex: 1; background: linear-gradient(180deg, #0071e3, #5ac8fa); border-radius: 4px 4px 0 0; height: 50%;"></div>
                                <div style="flex: 1; background: linear-gradient(180deg, #0071e3, #5ac8fa); border-radius: 4px 4px 0 0; height: 70%;"></div>
                                <div style="flex: 1; background: linear-gradient(180deg, #0071e3, #5ac8fa); border-radius: 4px 4px 0 0; height: 60%;"></div>
                                <div style="flex: 1; background: linear-gradient(180deg, #0071e3, #5ac8fa); border-radius: 4px 4px 0 0; height: 90%;"></div>
                                <div style="flex: 1; background: linear-gradient(180deg, #0071e3, #5ac8fa); border-radius: 4px 4px 0 0; height: 65%;"></div>
                                <div style="flex: 1; background: linear-gradient(180deg, #0071e3, #5ac8fa); border-radius: 4px 4px 0 0; height: 78%;"></div>
                                <div style="flex: 1; background: linear-gradient(180deg, #0071e3, #5ac8fa); border-radius: 4px 4px 0 0; height: 55%;"></div>
                            </div>
                            <div style="display: flex; gap: 10px; font-size: 10px;">
                                <div style="flex: 1;"><div style="color: var(--color-text-tertiary);">Blocked</div><div style="font-weight: 700; color: var(--color-text-primary); font-size: 14px;">28,471</div></div>
                                <div style="flex: 1;"><div style="color: var(--color-text-tertiary);">Delivered</div><div style="font-weight: 700; color: var(--color-text-primary); font-size: 14px;">52,883</div></div>
                                <div style="flex: 1;"><div style="color: var(--color-text-tertiary);">Accuracy</div><div style="font-weight: 700; color: #30d158; font-size: 14px;">99.9%</div></div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <div class="hp-alt-row reverse">
            <div class="hp-alt-text">
                <div class="hp-eyebrow">{$hadrianLang.store.seAlt2Eyebrow}</div>
                <h3>{$hadrianLang.store.seAlt2Title}</h3>
                <p>{$hadrianLang.store.seAlt2P1}</p>
                <p style="margin-top: 12px;">{$hadrianLang.store.seAlt2P2}</p>
            </div>
            <div class="hp-alt-visual">
                <div class="visual-box" style="background: #eaf4ff; padding: 24px;">
                    <div style="width: 100%; max-width: 300px; background: var(--color-surface); border-radius: 14px; padding: 14px;">
                        <div style="display: flex; align-items: center; gap: 8px; padding: 8px 10px; background: var(--color-surface-secondary); border-radius: 8px;">
                            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#86868b" stroke-width="2"><circle cx="12" cy="12" r="10"/></svg>
                            <span style="font-size: 11px; color: var(--color-text-primary); flex: 1;">Incoming email</span>
                            <span style="font-size: 10px; color: var(--color-text-tertiary);">SMTP</span>
                        </div>
                        <div style="display: flex; justify-content: center; margin: 8px 0;">
                            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#0071e3" stroke-width="2"><polyline points="6 9 12 15 18 9"/></svg>
                        </div>
                        <div style="padding: 10px; background: linear-gradient(135deg, #0071e3, #5ac8fa); border-radius: 10px; display: flex; align-items: center; gap: 8px; color: #fff;">
                            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/></svg>
                            <span style="font-size: 11px; font-weight: 600;">SpamExperts Filter</span>
                        </div>
                        <div style="display: flex; justify-content: center; margin: 8px 0;">
                            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#0071e3" stroke-width="2"><polyline points="6 9 12 15 18 9"/></svg>
                        </div>
                        <div style="display: flex; align-items: center; gap: 8px; padding: 8px 10px; background: #e8f8ed; border-radius: 8px;">
                            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#1a7f37" stroke-width="2.5"><polyline points="20 6 9 17 4 12"/></svg>
                            <span style="font-size: 11px; color: #1a7f37; flex: 1; font-weight: 600;">Clean inbox</span>
                            <span style="font-size: 10px; color: #1a7f37;">IMAP</span>
                        </div>
                    </div>
                </div>
            </div>
        </div>

    </div>

    {* 4. Benefits 6-up grid *}
    <div style="background: var(--color-surface-secondary);">
    <section class="hp-features-section" style="padding: 72px 22px;">
        <div style="text-align: center; margin-bottom: 8px; color: var(--color-accent); font-size: 13px; font-weight: 600; text-transform: uppercase; letter-spacing: 0.05em;">{$hadrianLang.store.seBenefitsEyebrow}</div>
        <h2>{$hadrianLang.store.seBenefitsTitle}</h2>
        <div class="hp-feature-cards" style="margin-top: 40px; max-width: 1024px; margin-left: auto; margin-right: auto;">
            <div class="hp-feature-card">
                <div class="feat-icon blue"><svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M14 9V5a3 3 0 00-3-3l-4 9v11h11.28a2 2 0 002-1.7l1.38-9a2 2 0 00-2-2.3zM7 22H4a2 2 0 01-2-2v-7a2 2 0 012-2h3"/></svg></div>
                <h4>{$hadrianLang.store.seBenefit1Title}</h4>
                <p>{$hadrianLang.store.seBenefit1Text}</p>
            </div>
            <div class="hp-feature-card">
                <div class="feat-icon red"><svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/><line x1="4.93" y1="4.93" x2="19.07" y2="19.07"/></svg></div>
                <h4>{$hadrianLang.store.seBenefit2Title}</h4>
                <p>{$hadrianLang.store.seBenefit2Text}</p>
            </div>
            <div class="hp-feature-card">
                <div class="feat-icon green"><svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg></div>
                <h4>{$hadrianLang.store.seBenefit3Title}</h4>
                <p>{$hadrianLang.store.seBenefit3Text}</p>
            </div>
            <div class="hp-feature-card">
                <div class="feat-icon purple"><svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M20.84 4.61a5.5 5.5 0 00-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 00-7.78 7.78l1.06 1.06L12 21.23l7.78-7.78 1.06-1.06a5.5 5.5 0 000-7.78z"/></svg></div>
                <h4>{$hadrianLang.store.seBenefit4Title}</h4>
                <p>{$hadrianLang.store.seBenefit4Text}</p>
            </div>
            <div class="hp-feature-card">
                <div class="feat-icon orange"><svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/></svg></div>
                <h4>{$hadrianLang.store.seBenefit5Title}</h4>
                <p>{$hadrianLang.store.seBenefit5Text}</p>
            </div>
            <div class="hp-feature-card">
                <div class="feat-icon teal"><svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="3" width="18" height="18" rx="2"/><path d="M9 9h6v6H9z"/></svg></div>
                <h4>{$hadrianLang.store.seBenefit6Title}</h4>
                <p>{$hadrianLang.store.seBenefit6Text}</p>
            </div>
        </div>
        <div style="text-align: center; margin-top: 32px;">
            <a href="{$_seOrder|escape}" class="hp-buy-btn">{$hadrianLang.store.seHeroCta}</a>
        </div>
    </section>
    </div>

    {* 5. Pricing - three cards wired to the real incoming/outgoing/bundle
       products; mockup spec rows + values are the fallback. *}
    <section class="hp-pricing-section" id="pricing" style="padding: 72px 22px;">
        <div style="text-align: center; margin-bottom: 8px; color: var(--color-accent); font-size: 13px; font-weight: 600; text-transform: uppercase; letter-spacing: 0.05em;">{$hadrianLang.store.sePricingEyebrow}</div>
        <h2 style="text-align: center;">{$hadrianLang.store.sePricingTitle}</h2>
        <div class="hp-billing-toggle" style="margin: 20px auto 40px;"><button class="active">{$hadrianLang.store.sePricingTabProxy}</button><button>{$hadrianLang.store.sePricingTabArchiving}</button></div>
        <div class="hp-pricing-grid">
            <div class="hp-price-card dim">
                <div class="label">{if $_seInc}{$_seInc->name|escape}{else}{$hadrianLang.store.sePlanIncLabel}{/if}</div>
                <h3>{$hadrianLang.store.sePlanIncTagline}</h3>
                <div class="price-row">{if $_seInc && !$inPreview && $_seInc->pricing()->best()}<span class="price">{$_seInc->pricing()->best()->toFullString()}</span>{else}<span class="price">$2.99</span><span class="per">/mo</span>{/if}</div>
                <ul>
                    <li>{$hadrianLang.store.sePlanIncFeat1}</li>
                    <li>{$hadrianLang.store.sePlanIncFeat2}</li>
                    <li>{$hadrianLang.store.sePlanIncFeat3}</li>
                    <li>{$hadrianLang.store.sePlanIncFeat4}</li>
                    <li>{$hadrianLang.store.sePlanIncFeat5}</li>
                </ul>
                <a class="buy" href="{if $_seInc}{$WEB_ROOT}/cart.php?a=add&amp;pid={$_seInc->id}{else}{$_seOrder|escape}{/if}">{$hadrianLang.store.seOrderNow}</a>
            </div>
            <div class="hp-price-card dim">
                <div class="label">{if $_seOut}{$_seOut->name|escape}{else}{$hadrianLang.store.sePlanOutLabel}{/if}</div>
                <h3>{$hadrianLang.store.sePlanOutTagline}</h3>
                <div class="price-row">{if $_seOut && !$inPreview && $_seOut->pricing()->best()}<span class="price">{$_seOut->pricing()->best()->toFullString()}</span>{else}<span class="price">$2.99</span><span class="per">/mo</span>{/if}</div>
                <ul>
                    <li>{$hadrianLang.store.sePlanOutFeat1}</li>
                    <li>{$hadrianLang.store.sePlanOutFeat2}</li>
                    <li>{$hadrianLang.store.sePlanOutFeat3}</li>
                    <li>{$hadrianLang.store.sePlanOutFeat4}</li>
                    <li>{$hadrianLang.store.sePlanOutFeat5}</li>
                </ul>
                <a class="buy" href="{if $_seOut}{$WEB_ROOT}/cart.php?a=add&amp;pid={$_seOut->id}{else}{$_seOrder|escape}{/if}">{$hadrianLang.store.seOrderNow}</a>
            </div>
            <div class="hp-price-card highlight">
                <div class="label" style="color: var(--color-accent);">{if $_seBundle}{$_seBundle->name|escape}{else}{$hadrianLang.store.sePlanBundleLabel}{/if}</div>
                <h3>{$hadrianLang.store.sePlanBundleTagline}</h3>
                <div class="price-row">{if $_seBundle && !$inPreview && $_seBundle->pricing()->best()}<span class="price">{$_seBundle->pricing()->best()->toFullString()}</span>{else}<span class="price">$5.98</span><span class="per">/mo</span>{/if}</div>
                <ul>
                    <li>{$hadrianLang.store.sePlanBundleFeat1}</li>
                    <li>{$hadrianLang.store.sePlanBundleFeat2}</li>
                    <li>{$hadrianLang.store.sePlanBundleFeat3}</li>
                    <li>{$hadrianLang.store.sePlanBundleFeat4}</li>
                    <li>{$hadrianLang.store.sePlanBundleFeat5}</li>
                </ul>
                <a class="buy" href="{if $_seBundle}{$WEB_ROOT}/cart.php?a=add&amp;pid={$_seBundle->id}{else}{$_seOrder|escape}{/if}">{$hadrianLang.store.seOrderNow}</a>
            </div>
        </div>
    </section>

    {* 6. Testimonials - decorative, kept verbatim *}
    <section class="hp-testi-masonry">
        <h2>{$hadrianLang.store.seTestiTitle}</h2>
        <p class="hp-testi-masonry-sub">{$hadrianLang.store.seTestiSub}</p>
        <div class="hp-testi-masonry-grid">
            <div class="hp-testi-tile">
                <div class="stars">&starf;&starf;&starf;&starf;&starf;</div>
                <p class="quote">Very helpful support. I&rsquo;m thoroughly impressed with their services. The standout feature for me is the customer support &mdash; quick, friendly, and incredibly helpful.</p>
                <div class="author"><div class="avatar" style="background-image:url('https://i.pravatar.cc/96?u=johndoe');"></div><div><div class="name">John Doe</div><div class="role">Indie Developer</div></div></div>
            </div>
            <div class="hp-testi-tile tall accent">
                <div class="stars">&starf;&starf;&starf;&starf;&starf;</div>
                <p class="quote">Fastest hosting I&rsquo;ve used. I&rsquo;m amazed by the speed of their service. My website loads in an instant, providing an exceptional user experience. The filtering engine boosted my team&rsquo;s productivity immediately.</p>
                <div class="author"><div class="avatar" style="background-image:url('https://i.pravatar.cc/96?u=robertjohanson');"></div><div><div class="name">Robert Johanson</div><div class="role">FreshStack</div></div></div>
            </div>
            <div class="hp-testi-tile">
                <div class="stars">&starf;&starf;&starf;&starf;&starf;</div>
                <p class="quote">Happy for the switch. Moving our email flow to this platform has been life-changing. Stable inbox, zero spam, 18 months in.</p>
                <div class="author"><div class="avatar" style="background-image:url('https://i.pravatar.cc/96?u=michaelbrown');"></div><div><div class="name">Michael Brown</div><div class="role">NextLabs</div></div></div>
            </div>
            <div class="hp-testi-tile dark">
                <div class="stars">&starf;&starf;&starf;&starf;&starf;</div>
                <p class="quote">High quality servers. Thrilled with the performance. Kudos to their tech-savvy team!</p>
                <div class="author"><div class="avatar" style="background-image:url('https://i.pravatar.cc/96?u=michaelsmith');"></div><div><div class="name">Michael Smith</div><div class="role">GrowthLab</div></div></div>
            </div>
            <div class="hp-testi-tile">
                <div class="stars">&starf;&starf;&starf;&starf;&starf;</div>
                <p class="quote">Simply amazing. Their products are simply amazing. The quality, features, and value have elevated my online presence. A fantastic choice.</p>
                <div class="author"><div class="avatar" style="background-image:url('https://i.pravatar.cc/96?u=mariagarcia');"></div><div><div class="name">Maria Garcia</div><div class="role">PixelAgency</div></div></div>
            </div>
            <div class="hp-testi-tile tall cream">
                <div class="stars">&starf;&starf;&starf;&starf;&starf;</div>
                <p class="quote">Easy app installation and intelligent filtering. The hosting has exceeded my expectations &mdash; one-click setup saved me hours, and the anti-spam engine has caught every phishing attempt so far.</p>
                <div class="author"><div class="avatar" style="background-image:url('https://i.pravatar.cc/96?u=davidwilson');"></div><div><div class="name">David Wilson</div><div class="role">Studio34</div></div></div>
            </div>
        </div>
    </section>

    {* Star rating block - decorative numbers kept verbatim *}
    <section class="hp-testi-reviews">
        <div class="big-stars">&starf;&starf;&starf;&starf;&starf;</div>
        <div class="rating-num">4.9</div>
        <div class="rating-of">{$hadrianLang.store.seRatingOf}</div>
        <div class="review-sources">
            <div class="rev-src"><div class="stars">&starf;&starf;&starf;&starf;&starf;</div><div class="src-name">G2</div><div class="src-count">3,840 reviews</div></div>
            <div class="rev-src"><div class="stars">&starf;&starf;&starf;&starf;&starf;</div><div class="src-name">Trustpilot</div><div class="src-count">4,920 reviews</div></div>
            <div class="rev-src"><div class="stars">&starf;&starf;&starf;&starf;&starf;</div><div class="src-name">Capterra</div><div class="src-count">2,100 reviews</div></div>
            <div class="rev-src"><div class="stars">&starf;&starf;&starf;&starf;&starf;</div><div class="src-name">Software Advice</div><div class="src-count">1,140 reviews</div></div>
        </div>
    </section>

    {* 7. FAQ with contact sidebar *}
    <section class="hp-faq-contact">
        <div>
            <h2>{$hadrianLang.store.seFaqTitle}</h2>
            <details class="hp-faq-item"><summary>{$hadrianLang.store.seFaqQ1}</summary><div class="faq-body">{$hadrianLang.store.seFaqA1}</div></details>
            <details class="hp-faq-item"><summary>{$hadrianLang.store.seFaqQ2}</summary><div class="faq-body">{$hadrianLang.store.seFaqA2}</div></details>
            <details class="hp-faq-item"><summary>{$hadrianLang.store.seFaqQ3}</summary><div class="faq-body">{$hadrianLang.store.seFaqA3}</div></details>
            <details class="hp-faq-item"><summary>{$hadrianLang.store.seFaqQ4}</summary><div class="faq-body">{$hadrianLang.store.seFaqA4}</div></details>
            <details class="hp-faq-item"><summary>{$hadrianLang.store.seFaqQ5}</summary><div class="faq-body">{$hadrianLang.store.seFaqA5}</div></details>
        </div>
        <div class="hp-faq-contact-card">
            <div class="icon-lg">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M21 15a2 2 0 01-2 2H7l-4 4V5a2 2 0 012-2h14a2 2 0 012 2z"/></svg>
            </div>
            <h4>{$hadrianLang.store.seFaqContactTitle}</h4>
            <p>{$hadrianLang.store.seFaqContactText}</p>
            <a href="{$WEB_ROOT}/submitticket.php" class="contact-btn">{$hadrianLang.store.seFaqContactBtn}</a>
            <a href="{$WEB_ROOT}/knowledgebase.php" class="contact-link">{$hadrianLang.store.seFaqContactLink} &rsaquo;</a>
        </div>
    </section>

    {* 8. Immersive CTA *}
    <section class="hp-cta-immersive">
        <div class="inner">
            <h2>{$hadrianLang.store.seCtaTitle}</h2>
            <p>{$hadrianLang.store.seCtaText}</p>
            <a href="{$_seOrder|escape}" class="btn">{$hadrianLang.store.seCtaBtn} &mdash; {$hadrianLang.store.seFrom} {$_seFrom}/mo</a>
        </div>
    </section>
</div>

<div class="when-empty" style="text-align:center;padding:60px 24px;background:var(--color-surface);border:1px solid var(--color-border);border-radius:14px;">
    <div style="width:56px;height:56px;border-radius:50%;background:var(--color-bg);display:inline-flex;align-items:center;justify-content:center;margin-bottom:16px;color:var(--color-text-tertiary);">
        <svg viewBox="0 0 24 24" width="22" height="22" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"/></svg>
    </div>
    <p style="font-size:17px;font-weight:600;color:var(--color-text-primary);margin:0 0 6px;">{$hadrianLang.store.seEmptyTitle}</p>
    <p style="font-size:14px;color:var(--color-text-secondary);margin:0 0 20px;max-width:380px;margin-left:auto;margin-right:auto;line-height:1.5;">{$hadrianLang.store.seEmptyText}</p>
    <a href="{$WEB_ROOT}/" class="btn-primary">{$hadrianLang.store.seEmptyHome}</a>
</div>
