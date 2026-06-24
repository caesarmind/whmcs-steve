{* Store landing - Website Security (SiteLock).
   Ported from apple-client-area/website-security.html (Public/Marketing landing).
   header.tpl/footer.tpl provide the shell + .content-area, so we emit only the
   inner content (page-header + when-full marketing + when-empty offline state).

   Real pricing: the WHMCS SiteLock store controller assigns $plans (each $plan
   exposes ->id, ->name, ->isFree(), ->pricing()->first()->toPrefixedString()) +
   $inPreview - same contract as six/store/sitelock/index.tpl (which reads price
   directly off $plan->pricing(), not a $pricings[] map). The mockup's 3-card
   pricing grid keeps its exact spec bullets; we wire each card's name, price, and
   order button to the real plan (captured by position), falling back to the
   mockup values otherwise. We also capture the first plan/price into $_slFrom and
   build a live add-to-cart link $_slOrder for the hero/CTA "order" buttons,
   falling back to the marketconnect group cart. Static prose is tokenized into
   the hadrianLang store group (sl-prefixed keys); decorative dashboards, the
   security shield SVG, and testimonials are kept verbatim. *}

{assign var=_slCount value=0}
{if isset($plans)}{assign var=_slCount value=$plans|@count}{/if}
{assign var=_slI value=0}
{if $_slCount > 0}
    {foreach $plans as $_slPlan}
        {if $_slI == 0}{assign var=_sl1 value=$_slPlan}{elseif $_slI == 1}{assign var=_sl2 value=$_slPlan}{elseif $_slI == 2}{assign var=_sl3 value=$_slPlan}{/if}
        {assign var=_slI value=$_slI+1}
    {/foreach}
{/if}
{assign var=_slFrom value='$1.75'}
{if isset($_sl1) && !$_sl1->isFree()}{assign var=_slFrom value=$_sl1->pricing()->first()->toPrefixedString()}{/if}
{if isset($_sl1)}
    {assign var=_slOrder value="`$WEB_ROOT`/cart.php?a=add&pid=`$_sl1->id`"}
{else}
    {assign var=_slOrder value="`$WEB_ROOT`/cart.php?gid=marketconnect"}
{/if}
{if $_slCount > 0 || (isset($inPreview) && $inPreview)}
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

    {* 1. Hero - split text + protected-site card visual *}
    <section class="hp-hero-split" style="padding: 60px 22px;">
        <div class="hp-split-text">
            <div class="hp-eyebrow">{$hadrianLang.store.slHeroEyebrow}</div>
            <h1>{$hadrianLang.store.slHeroTitle}</h1>
            <p>{$hadrianLang.store.slHeroText}</p>
            <div class="hp-cta-row">
                <a href="{$_slOrder|escape}" class="hp-buy-btn">{$hadrianLang.store.slHeroCta}</a>
                <a href="#pricing">{$hadrianLang.store.slLearnMore} &rsaquo;</a>
            </div>
        </div>
        <div class="hp-split-visual">
            <div class="visual-box" style="background: linear-gradient(135deg, #eef5ff 0%, #dbeafe 100%); padding: 28px;">
                <div style="background: var(--color-surface); border-radius: 14px; padding: 14px; width: 100%; max-width: 300px; box-shadow: 0 8px 24px rgba(0,0,0,0.08);">
                    <div style="display: flex; align-items: center; justify-content: space-between; margin-bottom: 12px;">
                        <span style="font-size: 11px; font-weight: 600; color: var(--color-text-primary);">Site protected</span>
                        <span style="font-size: 10px; color: #30d158; font-weight: 600;">&bull; CLEAN</span>
                    </div>
                    <div style="display: flex; align-items: center; gap: 12px;">
                        <div style="width: 56px; height: 56px; background: linear-gradient(135deg, #30d158, #5cdb79); border-radius: 14px; display: flex; align-items: center; justify-content: center;"><svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="#fff" stroke-width="2"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/><path d="M9 12l2 2 4-4"/></svg></div>
                        <div style="flex: 1;">
                            <div style="font-size: 13px; font-weight: 600; color: var(--color-text-primary);">No threats found</div>
                            <div style="font-size: 11px; color: var(--color-text-tertiary);">Last scan: 2h ago</div>
                        </div>
                    </div>
                    <div style="margin-top: 12px; display: grid; grid-template-columns: repeat(3, 1fr); gap: 8px;">
                        <div style="padding: 8px; background: var(--color-surface-secondary); border-radius: 8px; text-align: center;"><div style="font-size: 13px; font-weight: 700; color: var(--color-text-primary);">2,847</div><div style="font-size: 9px; color: var(--color-text-tertiary);">Files</div></div>
                        <div style="padding: 8px; background: var(--color-surface-secondary); border-radius: 8px; text-align: center;"><div style="font-size: 13px; font-weight: 700; color: #30d158;">0</div><div style="font-size: 9px; color: var(--color-text-tertiary);">Threats</div></div>
                        <div style="padding: 8px; background: var(--color-surface-secondary); border-radius: 8px; text-align: center;"><div style="font-size: 13px; font-weight: 700; color: var(--color-accent);">99%</div><div style="font-size: 9px; color: var(--color-text-tertiary);">Score</div></div>
                    </div>
                </div>
            </div>
        </div>
    </section>

    {* 2. Pricing grid - spec bullets static; plan name + price + order wired to real plans *}
    <section class="hp-pricing-section" id="pricing" style="padding: 40px 22px 72px;">
        <div class="hp-billing-toggle" style="margin-bottom: 32px;"><button class="active">{$hadrianLang.store.slCycleMonthly}</button><button>{$hadrianLang.store.slCycleQuarterly}</button><button>{$hadrianLang.store.slCycleSemi}</button><button>{$hadrianLang.store.slCycleAnnually}</button></div>
        <div class="hp-pricing-grid">
            <div class="hp-price-card dim">
                <div class="label">{if isset($_sl1)}{$_sl1->name|escape}{else}Find{/if}</div>
                <h3>{$hadrianLang.store.slPlan1Tagline}</h3>
                <div class="price-row">{if isset($_sl1)}<span class="price">{if $_sl1->isFree()}$0.00{else}{$_sl1->pricing()->first()->toPrefixedString()}{/if}</span>{else}<span class="price">$1.75</span><span class="per">/mo</span>{/if}</div>
                <ul>
                    <li>Daily malware scanning</li>
                    <li>Number of pages: 25</li>
                    <li>Daily blacklist monitoring</li>
                    <li>Malware alert hours</li>
                    <li>Scan time: 1x Daily</li>
                    <li>Alert time: Daily</li>
                    <li>SSL scan: No</li>
                    <li>Support: 24/7</li>
                    <li>TrustSeal: No</li>
                </ul>
                <a class="buy" href="{if isset($_sl1)}{$WEB_ROOT}/cart.php?a=add&amp;pid={$_sl1->id}{else}#pricing{/if}">{$hadrianLang.store.slOrderNow}</a>
            </div>
            <div class="hp-price-card highlight">
                <div class="label" style="color: var(--color-accent);">{if isset($_sl2)}{$_sl2->name|escape}{else}Fix{/if}</div>
                <h3>{$hadrianLang.store.slPlan2Tagline}</h3>
                <div class="price-row">{if isset($_sl2)}<span class="price">{if $_sl2->isFree()}$0.00{else}{$_sl2->pricing()->first()->toPrefixedString()}{/if}</span>{else}<span class="price">$6.94</span><span class="per">/mo</span>{/if}</div>
                <ul>
                    <li>Daily malware scanning</li>
                    <li>Number of pages: 500</li>
                    <li>Daily blacklist monitoring</li>
                    <li>Malware removal</li>
                    <li>SQL injection scan: Daily</li>
                    <li>XSS injection scan: Daily</li>
                    <li>Scan time: 3x Daily</li>
                    <li>Alert time: 12h</li>
                    <li>Support: 24/7</li>
                    <li>TrustSeal included</li>
                </ul>
                <a class="buy" href="{if isset($_sl2)}{$WEB_ROOT}/cart.php?a=add&amp;pid={$_sl2->id}{else}#pricing{/if}">{$hadrianLang.store.slOrderNow}</a>
            </div>
            <div class="hp-price-card dim">
                <div class="label">{if isset($_sl3)}{$_sl3->name|escape}{else}Defend{/if}</div>
                <h3>{$hadrianLang.store.slPlan3Tagline}</h3>
                <div class="price-row">{if isset($_sl3)}<span class="price">{if $_sl3->isFree()}$0.00{else}{$_sl3->pricing()->first()->toPrefixedString()}{/if}</span>{else}<span class="price">$22.22</span><span class="per">/mo</span>{/if}</div>
                <ul>
                    <li>Daily malware scanning</li>
                    <li>Number of pages: 2,500</li>
                    <li>Daily blacklist monitoring</li>
                    <li>Malware removal</li>
                    <li>SQL injection scan: Daily</li>
                    <li>XSS injection scan: Daily</li>
                    <li>Automatic malware removal</li>
                    <li>Web app firewall</li>
                    <li>SmartPatch: Yes</li>
                    <li>TrustSeal included</li>
                </ul>
                <a class="buy" href="{if isset($_sl3)}{$WEB_ROOT}/cart.php?a=add&amp;pid={$_sl3->id}{else}#pricing{/if}">{$hadrianLang.store.slOrderNow}</a>
            </div>
        </div>
    </section>

    {* 3. Alt rows - what is SiteLock / who uses SiteLock *}
    <div class="hp-alternating">
        <div class="hp-alt-row">
            <div class="hp-alt-text">
                <div class="hp-eyebrow">{$hadrianLang.store.slWhatEyebrow}</div>
                <h3>{$hadrianLang.store.slWhatTitle}</h3>
                <p>{$hadrianLang.store.slWhatText}</p>
            </div>
            <div class="hp-alt-visual">
                <div class="visual-box" style="background: var(--color-surface-secondary); padding: 24px;">
                    <div style="width: 100%; max-width: 300px; background: var(--color-surface); border-radius: 14px; padding: 14px;">
                        <div style="font-size: 11px; font-weight: 600; color: var(--color-text-primary); margin-bottom: 10px;">Threats blocked &middot; Last 7 days</div>
                        <div style="display: flex; align-items: end; gap: 6px; height: 80px;">
                            <div style="flex: 1; background: linear-gradient(180deg, #ff453a, #ff9f0a); border-radius: 4px 4px 0 0; height: 60%;"></div>
                            <div style="flex: 1; background: linear-gradient(180deg, #ff453a, #ff9f0a); border-radius: 4px 4px 0 0; height: 45%;"></div>
                            <div style="flex: 1; background: linear-gradient(180deg, #ff453a, #ff9f0a); border-radius: 4px 4px 0 0; height: 80%;"></div>
                            <div style="flex: 1; background: linear-gradient(180deg, #ff453a, #ff9f0a); border-radius: 4px 4px 0 0; height: 50%;"></div>
                            <div style="flex: 1; background: linear-gradient(180deg, #ff453a, #ff9f0a); border-radius: 4px 4px 0 0; height: 70%;"></div>
                            <div style="flex: 1; background: linear-gradient(180deg, #ff453a, #ff9f0a); border-radius: 4px 4px 0 0; height: 55%;"></div>
                            <div style="flex: 1; background: linear-gradient(180deg, #ff453a, #ff9f0a); border-radius: 4px 4px 0 0; height: 90%;"></div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <div class="hp-alt-row reverse">
            <div class="hp-alt-text">
                <div class="hp-eyebrow">{$hadrianLang.store.slWhoEyebrow}</div>
                <h3>{$hadrianLang.store.slWhoTitle}</h3>
                <p>{$hadrianLang.store.slWhoText}</p>
            </div>
            <div class="hp-alt-visual">
                <div class="visual-box" style="background: #eaf4ff; padding: 24px;">
                    <div style="width: 100%; max-width: 300px; background: var(--color-surface); border-radius: 14px; padding: 14px;">
                        <div style="display: flex; flex-direction: column; gap: 8px;">
                            <div style="display: flex; align-items: center; gap: 10px; padding: 8px 10px; background: #e8f8ed; border-radius: 8px;"><svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#1a7f37" stroke-width="2.5"><polyline points="20 6 9 17 4 12"/></svg><span style="font-size: 11px; color: #1a7f37; font-weight: 600;">WordPress core &middot; clean</span></div>
                            <div style="display: flex; align-items: center; gap: 10px; padding: 8px 10px; background: #e8f8ed; border-radius: 8px;"><svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#1a7f37" stroke-width="2.5"><polyline points="20 6 9 17 4 12"/></svg><span style="font-size: 11px; color: #1a7f37; font-weight: 600;">All plugins &middot; verified</span></div>
                            <div style="display: flex; align-items: center; gap: 10px; padding: 8px 10px; background: #e8f8ed; border-radius: 8px;"><svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#1a7f37" stroke-width="2.5"><polyline points="20 6 9 17 4 12"/></svg><span style="font-size: 11px; color: #1a7f37; font-weight: 600;">Database &middot; encrypted</span></div>
                            <div style="display: flex; align-items: center; gap: 10px; padding: 8px 10px; background: #e8f8ed; border-radius: 8px;"><svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#1a7f37" stroke-width="2.5"><polyline points="20 6 9 17 4 12"/></svg><span style="font-size: 11px; color: #1a7f37; font-weight: 600;">SSL &middot; valid</span></div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    {* 4. Comprehensive website scan - 3 cards *}
    <div style="background: var(--color-surface-secondary);">
    <section class="hp-features-section" style="padding: 72px 22px;">
        <div style="text-align: center; color: var(--color-accent); font-size: 13px; font-weight: 600; text-transform: uppercase; letter-spacing: 0.05em; margin-bottom: 8px;">{$hadrianLang.store.slScanEyebrow}</div>
        <h2>{$hadrianLang.store.slScanTitle}</h2>
        <div class="hp-feature-cards" style="margin-top: 40px; grid-template-columns: repeat(3, 1fr);">
            <div class="hp-feature-card">
                <div class="feat-icon red"><svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/></svg></div>
                <h4>{$hadrianLang.store.slScan1Title}</h4>
                <p>{$hadrianLang.store.slScan1Text}</p>
                <a href="{$_slOrder|escape}" style="color: var(--color-accent); font-size: 13px; font-weight: 500; margin-top: 8px;">{$hadrianLang.store.slHeroCta} &rsaquo;</a>
            </div>
            <div class="hp-feature-card">
                <div class="feat-icon blue"><svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg></div>
                <h4>{$hadrianLang.store.slScan2Title}</h4>
                <p>{$hadrianLang.store.slScan2Text}</p>
                <a href="{$_slOrder|escape}" style="color: var(--color-accent); font-size: 13px; font-weight: 500; margin-top: 8px;">{$hadrianLang.store.slHeroCta} &rsaquo;</a>
            </div>
            <div class="hp-feature-card">
                <div class="feat-icon purple"><svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="11" width="18" height="11" rx="2"/><path d="M7 11V7a5 5 0 0110 0v4"/></svg></div>
                <h4>{$hadrianLang.store.slScan3Title}</h4>
                <p>{$hadrianLang.store.slScan3Text}</p>
                <a href="{$_slOrder|escape}" style="color: var(--color-accent); font-size: 13px; font-weight: 500; margin-top: 8px;">{$hadrianLang.store.slHeroCta} &rsaquo;</a>
            </div>
        </div>
    </section>
    </div>

    {* 5. Apple-style security full - No compromises (security shield SVG kept verbatim) *}
    <section class="hp-apple-security-full">
        <div class="sec-inner">
            <div class="sec-eyebrow">{$hadrianLang.store.slSecEyebrow}</div>
            <h2>{$hadrianLang.store.slSecTitle}</h2>
            <div class="sec-shot">
                <svg viewBox="0 0 900 420" fill="none" aria-hidden="true" role="img" aria-label="Websites protected by SiteLock encryption shield">
                    <defs>
                        <linearGradient id="sslBg" x1="0%" y1="0%" x2="0%" y2="100%"><stop offset="0%" stop-color="#0a0a0d"/><stop offset="100%" stop-color="#1a1a1f"/></linearGradient>
                        <linearGradient id="sslShield" x1="0%" y1="0%" x2="100%" y2="100%"><stop offset="0%" stop-color="#0a84ff"/><stop offset="100%" stop-color="#64d2ff"/></linearGradient>
                        <linearGradient id="sslShieldFill" x1="50%" y1="0%" x2="50%" y2="100%"><stop offset="0%" stop-color="#0a84ff" stop-opacity="0.18"/><stop offset="100%" stop-color="#0a84ff" stop-opacity="0"/></linearGradient>
                        <linearGradient id="sslRack" x1="0%" y1="0%" x2="100%" y2="0%"><stop offset="0%" stop-color="#2a2a2f"/><stop offset="100%" stop-color="#1c1c20"/></linearGradient>
                        <radialGradient id="sslGlow" cx="50%" cy="55%" r="40%"><stop offset="0%" stop-color="#0a84ff" stop-opacity="0.25"/><stop offset="100%" stop-color="#0a84ff" stop-opacity="0"/></radialGradient>
                    </defs>
                    <rect width="900" height="420" fill="url(#sslBg)"/>
                    <rect width="900" height="420" fill="url(#sslGlow)"/>
                    <g transform="translate(70, 132)">
                        <rect width="160" height="210" rx="10" fill="url(#sslRack)" stroke="#3a3a3f" stroke-width="0.8"/>
                        <rect x="12" y="16" width="136" height="26" rx="3" fill="#0c0c10" stroke="#3a3a3f" stroke-width="0.5"/><circle cx="26" cy="29" r="2.5" fill="#30d158"/><circle cx="36" cy="29" r="2.5" fill="#30d158" opacity="0.4"/><rect x="80" y="25" width="56" height="8" rx="1.5" fill="#3a3a3f"/>
                        <rect x="12" y="50" width="136" height="26" rx="3" fill="#0c0c10" stroke="#3a3a3f" stroke-width="0.5"/><circle cx="26" cy="63" r="2.5" fill="#30d158"/><circle cx="36" cy="63" r="2.5" fill="#30d158"/><rect x="80" y="59" width="56" height="8" rx="1.5" fill="#3a3a3f"/>
                        <rect x="12" y="84" width="136" height="26" rx="3" fill="#0c0c10" stroke="#3a3a3f" stroke-width="0.5"/><circle cx="26" cy="97" r="2.5" fill="#30d158"/><circle cx="36" cy="97" r="2.5" fill="#30d158" opacity="0.4"/><rect x="80" y="93" width="56" height="8" rx="1.5" fill="#3a3a3f"/>
                        <rect x="12" y="118" width="136" height="26" rx="3" fill="#0c0c10" stroke="#3a3a3f" stroke-width="0.5"/><circle cx="26" cy="131" r="2.5" fill="#30d158"/><circle cx="36" cy="131" r="2.5" fill="#30d158"/><rect x="80" y="127" width="56" height="8" rx="1.5" fill="#3a3a3f"/>
                        <rect x="12" y="152" width="136" height="26" rx="3" fill="#0c0c10" stroke="#3a3a3f" stroke-width="0.5"/><circle cx="26" cy="165" r="2.5" fill="#30d158"/><circle cx="36" cy="165" r="2.5" fill="#ffd60a"/><rect x="80" y="161" width="56" height="8" rx="1.5" fill="#3a3a3f"/>
                    </g>
                    <g transform="translate(670, 132)">
                        <rect width="160" height="210" rx="10" fill="url(#sslRack)" stroke="#3a3a3f" stroke-width="0.8"/>
                        <rect x="12" y="16" width="136" height="26" rx="3" fill="#0c0c10" stroke="#3a3a3f" stroke-width="0.5"/><circle cx="26" cy="29" r="2.5" fill="#30d158"/><circle cx="36" cy="29" r="2.5" fill="#30d158"/><rect x="80" y="25" width="56" height="8" rx="1.5" fill="#3a3a3f"/>
                        <rect x="12" y="50" width="136" height="26" rx="3" fill="#0c0c10" stroke="#3a3a3f" stroke-width="0.5"/><circle cx="26" cy="63" r="2.5" fill="#30d158"/><circle cx="36" cy="63" r="2.5" fill="#30d158" opacity="0.4"/><rect x="80" y="59" width="56" height="8" rx="1.5" fill="#3a3a3f"/>
                        <rect x="12" y="84" width="136" height="26" rx="3" fill="#0c0c10" stroke="#3a3a3f" stroke-width="0.5"/><circle cx="26" cy="97" r="2.5" fill="#30d158"/><circle cx="36" cy="97" r="2.5" fill="#30d158"/><rect x="80" y="93" width="56" height="8" rx="1.5" fill="#3a3a3f"/>
                        <rect x="12" y="118" width="136" height="26" rx="3" fill="#0c0c10" stroke="#3a3a3f" stroke-width="0.5"/><circle cx="26" cy="131" r="2.5" fill="#30d158"/><circle cx="36" cy="131" r="2.5" fill="#30d158"/><rect x="80" y="127" width="56" height="8" rx="1.5" fill="#3a3a3f"/>
                        <rect x="12" y="152" width="136" height="26" rx="3" fill="#0c0c10" stroke="#3a3a3f" stroke-width="0.5"/><circle cx="26" cy="165" r="2.5" fill="#30d158"/><circle cx="36" cy="165" r="2.5" fill="#30d158" opacity="0.4"/><rect x="80" y="161" width="56" height="8" rx="1.5" fill="#3a3a3f"/>
                    </g>
                    <g stroke="#0a84ff" stroke-width="1" opacity="0.35" stroke-dasharray="3 4">
                        <path d="M230 200 L 360 215"/><path d="M230 240 L 360 235"/><path d="M670 200 L 540 215"/><path d="M670 240 L 540 235"/>
                    </g>
                    <g transform="translate(450, 210)">
                        <path d="M0 -120 L 100 -84 V 20 C 100 80, 50 118, 0 138 C -50 118, -100 80, -100 20 V -84 Z" fill="url(#sslShieldFill)"/>
                        <path d="M0 -110 L 92 -78 V 14 C 92 70, 46 106, 0 124 C -46 106, -92 70, -92 14 V -78 Z" fill="#0c1622" stroke="url(#sslShield)" stroke-width="2.5"/>
                        <rect x="-28" y="-10" width="56" height="48" rx="6" fill="url(#sslShield)"/>
                        <path d="M-16 -10 V -32 C -16 -44, -8 -52, 0 -52 C 8 -52, 16 -44, 16 -32 V -10" stroke="url(#sslShield)" stroke-width="5" fill="none" stroke-linecap="round"/>
                        <circle cx="0" cy="8" r="4" fill="#0c1622"/>
                        <rect x="-2" y="8" width="4" height="14" rx="1" fill="#0c1622"/>
                        <text x="0" y="80" text-anchor="middle" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Text', sans-serif" font-size="12" font-weight="600" fill="#a1d0ff" letter-spacing="2">SITELOCK</text>
                        <text x="0" y="97" text-anchor="middle" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Text', sans-serif" font-size="10" fill="#6e8aab" letter-spacing="1">Daily scans &middot; WAF &middot; Auto-remove</text>
                    </g>
                    <g transform="translate(280, 68)"><rect x="-44" y="-14" width="88" height="28" rx="14" fill="#1a1f2e" stroke="#30d158" stroke-width="0.8" opacity="0.9"/><circle cx="-28" cy="0" r="3" fill="#30d158"/><text x="-18" y="4" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Text', sans-serif" font-size="11" font-weight="500" fill="#f5f5f7">Malware Cleaned</text></g>
                    <g transform="translate(620, 72)"><rect x="-38" y="-14" width="76" height="28" rx="14" fill="#1a1f2e" stroke="#0a84ff" stroke-width="0.8" opacity="0.9"/><circle cx="-22" cy="0" r="3" fill="#0a84ff"/><text x="-12" y="4" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Text', sans-serif" font-size="11" font-weight="500" fill="#f5f5f7">WAF Active</text></g>
                    <g transform="translate(450, 380)"><rect x="-56" y="-14" width="112" height="28" rx="14" fill="#1a1f2e" stroke="#30d158" stroke-width="0.8" opacity="0.9"/><circle cx="-40" cy="0" r="3" fill="#30d158"/><text x="-30" y="4" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Text', sans-serif" font-size="11" font-weight="500" fill="#f5f5f7">Daily Scan Passed</text></g>
                </svg>
            </div>
            <p class="sec-lead"><strong>{$hadrianLang.store.slSecLeadStrong}</strong> {$hadrianLang.store.slSecLeadText}</p>
            <div class="sec-features">
                <div class="sec-feature"><p><strong>{$hadrianLang.store.slSecF1Strong}</strong> {$hadrianLang.store.slSecF1Text}</p></div>
                <div class="sec-feature"><p><strong>{$hadrianLang.store.slSecF2Strong}</strong> {$hadrianLang.store.slSecF2Text}</p></div>
                <div class="sec-feature"><p><strong>{$hadrianLang.store.slSecF3Strong}</strong> {$hadrianLang.store.slSecF3Text}</p></div>
            </div>
        </div>
    </section>

    {* 6. Emergency response step flow *}
    <div style="background: var(--color-surface-secondary);">
    <section class="hp-step-flow" style="padding: 72px 22px; max-width: 1024px; margin: 0 auto;">
        <div style="text-align: center; color: var(--color-accent); font-size: 13px; font-weight: 600; text-transform: uppercase; letter-spacing: 0.05em; margin-bottom: 8px;">{$hadrianLang.store.slEmergencyEyebrow}</div>
        <h2 style="text-align: center; font-size: 48px; font-weight: 600; letter-spacing: -0.02em; margin: 0 0 12px;">{$hadrianLang.store.slEmergencyTitle}</h2>
        <p style="text-align: center; color: var(--color-text-secondary); font-size: 16px; max-width: 720px; margin: 0 auto 48px;">{$hadrianLang.store.slEmergencySub}</p>
        <div class="step-flow-row" style="display: grid; grid-template-columns: repeat(3, 1fr); gap: 20px; margin-bottom: 20px;">
            <div style="background: var(--color-surface); border-radius: 16px; padding: 28px 20px; text-align: center; position: relative;">
                <div style="width: 44px; height: 44px; margin: 0 auto 16px; background: linear-gradient(135deg, #0071e3, #5ac8fa); color: #fff; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-weight: 700; font-size: 18px;">1</div>
                <h4 style="font-size: 15px; font-weight: 600; color: var(--color-text-primary); margin: 0 0 8px;">{$hadrianLang.store.slStep1Title}</h4>
                <p style="font-size: 13px; color: var(--color-text-secondary); margin: 0;">{$hadrianLang.store.slStep1Text}</p>
            </div>
            <div style="background: var(--color-surface); border-radius: 16px; padding: 28px 20px; text-align: center; position: relative;">
                <div style="width: 44px; height: 44px; margin: 0 auto 16px; background: linear-gradient(135deg, #0071e3, #5ac8fa); color: #fff; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-weight: 700; font-size: 18px;">2</div>
                <h4 style="font-size: 15px; font-weight: 600; color: var(--color-text-primary); margin: 0 0 8px;">{$hadrianLang.store.slStep2Title}</h4>
                <p style="font-size: 13px; color: var(--color-text-secondary); margin: 0;">{$hadrianLang.store.slStep2Text}</p>
            </div>
            <div style="background: var(--color-surface); border-radius: 16px; padding: 28px 20px; text-align: center; position: relative;">
                <div style="width: 44px; height: 44px; margin: 0 auto 16px; background: linear-gradient(135deg, #0071e3, #5ac8fa); color: #fff; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-weight: 700; font-size: 18px;">3</div>
                <h4 style="font-size: 15px; font-weight: 600; color: var(--color-text-primary); margin: 0 0 8px;">{$hadrianLang.store.slStep3Title}</h4>
                <p style="font-size: 13px; color: var(--color-text-secondary); margin: 0;">{$hadrianLang.store.slStep3Text}</p>
            </div>
        </div>
        <div class="step-flow-row" style="display: grid; grid-template-columns: repeat(3, 1fr); gap: 20px;">
            <div style="background: var(--color-surface); border-radius: 16px; padding: 28px 20px; text-align: center; position: relative;">
                <div style="width: 44px; height: 44px; margin: 0 auto 16px; background: linear-gradient(135deg, #0071e3, #5ac8fa); color: #fff; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-weight: 700; font-size: 18px;">4</div>
                <h4 style="font-size: 15px; font-weight: 600; color: var(--color-text-primary); margin: 0 0 8px;">{$hadrianLang.store.slStep4Title}</h4>
                <p style="font-size: 13px; color: var(--color-text-secondary); margin: 0;">{$hadrianLang.store.slStep4Text}</p>
            </div>
            <div style="background: var(--color-surface); border-radius: 16px; padding: 28px 20px; text-align: center; position: relative;">
                <div style="width: 44px; height: 44px; margin: 0 auto 16px; background: linear-gradient(135deg, #0071e3, #5ac8fa); color: #fff; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-weight: 700; font-size: 18px;">5</div>
                <h4 style="font-size: 15px; font-weight: 600; color: var(--color-text-primary); margin: 0 0 8px;">{$hadrianLang.store.slStep5Title}</h4>
                <p style="font-size: 13px; color: var(--color-text-secondary); margin: 0;">{$hadrianLang.store.slStep5Text}</p>
            </div>
            <div style="background: var(--color-surface); border-radius: 16px; padding: 28px 20px; text-align: center; position: relative;">
                <div style="width: 44px; height: 44px; margin: 0 auto 16px; background: linear-gradient(135deg, #0071e3, #5ac8fa); color: #fff; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-weight: 700; font-size: 18px;">6</div>
                <h4 style="font-size: 15px; font-weight: 600; color: var(--color-text-primary); margin: 0 0 8px;">{$hadrianLang.store.slStep6Title}</h4>
                <p style="font-size: 13px; color: var(--color-text-secondary); margin: 0;">{$hadrianLang.store.slStep6Text}</p>
            </div>
        </div>
        <div style="text-align: center; margin-top: 40px;">
            <a href="{$_slOrder|escape}" class="hp-buy-btn">{$hadrianLang.store.slEmergencyCta}</a>
        </div>
    </section>
    </div>

    {* Star rating block - decorative, kept verbatim *}
    <section class="hp-testi-reviews">
        <div class="big-stars">&starf;&starf;&starf;&starf;&starf;</div>
        <div class="rating-num">4.9</div>
        <div class="rating-of">{$hadrianLang.store.slRatingOf}</div>
        <div class="review-sources">
            <div class="rev-src"><div class="stars">&starf;&starf;&starf;&starf;&starf;</div><div class="src-name">G2</div><div class="src-count">5,420 reviews</div></div>
            <div class="rev-src"><div class="stars">&starf;&starf;&starf;&starf;&starf;</div><div class="src-name">Trustpilot</div><div class="src-count">9,180 reviews</div></div>
            <div class="rev-src"><div class="stars">&starf;&starf;&starf;&starf;&starf;</div><div class="src-name">Capterra</div><div class="src-count">4,200 reviews</div></div>
            <div class="rev-src"><div class="stars">&starf;&starf;&starf;&starf;&starf;</div><div class="src-name">SecurityWeek</div><div class="src-count">2,940 reviews</div></div>
        </div>
    </section>

    {* 7. Testimonials - decorative, kept verbatim *}
    <section class="hp-testi-masonry">
        <h2>{$hadrianLang.store.slTestiTitle}</h2>
        <p class="hp-testi-masonry-sub">{$hadrianLang.store.slTestiSub}</p>
        <div class="hp-testi-masonry-grid">
            <div class="hp-testi-tile"><div class="stars">&starf;&starf;&starf;&starf;&starf;</div><p class="quote">Easy app installation. The hosting has exceeded my expectations. Their one-click app installation saved me time, and the speed optimization has bumped my visitor load by 50%.</p><div class="author"><div class="avatar" style="background-image:url('https://i.pravatar.cc/96?u=sealltwilson');"></div><div><div class="name">Seall Twilson</div><div class="role">Studio34</div></div></div></div>
            <div class="hp-testi-tile tall accent"><div class="stars">&starf;&starf;&starf;&starf;&starf;</div><p class="quote">Very helpful support. I&rsquo;m thoroughly impressed with their hosting services. The standout feature for me is their outstanding customer support &mdash; quick, friendly, and incredibly helpful. I&rsquo;ve been using their services for 18 months and zero malware incidents.</p><div class="author"><div class="avatar" style="background-image:url('https://i.pravatar.cc/96?u=seamusjohanson');"></div><div><div class="name">Seamus Johanson</div><div class="role">FreshStack</div></div></div></div>
            <div class="hp-testi-tile"><div class="stars">&starf;&starf;&starf;&starf;&starf;</div><p class="quote">High Quality Servers. I&rsquo;m thoroughly impressed with their services. The performance has been exceptional.</p><div class="author"><div class="avatar" style="background-image:url('https://i.pravatar.cc/96?u=michaelsugott');"></div><div><div class="name">Michael Sugott</div><div class="role">NextLabs</div></div></div></div>
            <div class="hp-testi-tile dark"><div class="stars">&starf;&starf;&starf;&starf;&starf;</div><p class="quote">Very helpful support. They helped me fix a malware injection in under an hour. Unmatched response.</p><div class="author"><div class="avatar" style="background-image:url('https://i.pravatar.cc/96?u=elaryalaty');"></div><div><div class="name">Ellery Alaty</div><div class="role">Agency Director</div></div></div></div>
            <div class="hp-testi-tile"><div class="stars">&starf;&starf;&starf;&starf;&starf;</div><p class="quote">Simply Amazing. Their products are simply amazing. The quality, features, and value they offer have elevated my online presence.</p><div class="author"><div class="avatar" style="background-image:url('https://i.pravatar.cc/96?u=mariagarcia');"></div><div><div class="name">Maria Garcia</div><div class="role">PixelAgency</div></div></div></div>
            <div class="hp-testi-tile tall cream"><div class="stars">&starf;&starf;&starf;&starf;&starf;</div><p class="quote">Great Hosting Company. Cutting my very own WordPress website hosted into an entity broadly effortless takes of success of the incredible hosting service we subscribe to the provider. The automated daily scans have already caught 3 potential issues &mdash; peace of mind is priceless.</p><div class="author"><div class="avatar" style="background-image:url('https://i.pravatar.cc/96?u=elizawilliams');"></div><div><div class="name">Eliza Williams</div><div class="role">Studio34</div></div></div></div>
        </div>
    </section>

    {* 8. FAQ - tabbed categories (toggle wired below) *}
    <section class="hp-faq-tabs-section">
        <h2>{$hadrianLang.store.slFaqTitle}</h2>
        <p class="sub">{$hadrianLang.store.slFaqSub}</p>
        <div class="hp-faq-cat-tabs">
            <button class="hp-faq-cat active">{$hadrianLang.store.slFaqTabOverview}</button>
            <button class="hp-faq-cat">{$hadrianLang.store.slFaqTabScanning}</button>
            <button class="hp-faq-cat">{$hadrianLang.store.slFaqTabAttacks}</button>
            <button class="hp-faq-cat">{$hadrianLang.store.slFaqTabSeal}</button>
        </div>
        <div class="hp-faq-cat-panel active">
            <details class="hp-faq-item"><summary>{$hadrianLang.store.slFaqO1Q}</summary><div class="faq-body">{$hadrianLang.store.slFaqO1A}</div></details>
            <details class="hp-faq-item"><summary>{$hadrianLang.store.slFaqO2Q}</summary><div class="faq-body">{$hadrianLang.store.slFaqO2A}</div></details>
        </div>
        <div class="hp-faq-cat-panel">
            <details class="hp-faq-item"><summary>{$hadrianLang.store.slFaqS1Q}</summary><div class="faq-body">{$hadrianLang.store.slFaqS1A}</div></details>
            <details class="hp-faq-item"><summary>{$hadrianLang.store.slFaqS2Q}</summary><div class="faq-body">{$hadrianLang.store.slFaqS2A}</div></details>
        </div>
        <div class="hp-faq-cat-panel">
            <details class="hp-faq-item"><summary>{$hadrianLang.store.slFaqA1Q}</summary><div class="faq-body">{$hadrianLang.store.slFaqA1A}</div></details>
            <details class="hp-faq-item"><summary>{$hadrianLang.store.slFaqA2Q}</summary><div class="faq-body">{$hadrianLang.store.slFaqA2A}</div></details>
        </div>
        <div class="hp-faq-cat-panel">
            <details class="hp-faq-item"><summary>{$hadrianLang.store.slFaqT1Q}</summary><div class="faq-body">{$hadrianLang.store.slFaqT1A}</div></details>
            <details class="hp-faq-item"><summary>{$hadrianLang.store.slFaqT2Q}</summary><div class="faq-body">{$hadrianLang.store.slFaqT2A}</div></details>
        </div>
    </section>

    {* 9. Immersive CTA *}
    <section class="hp-cta-immersive">
        <div class="inner">
            <h2>{$hadrianLang.store.slCtaTitle}</h2>
            <p>{$hadrianLang.store.slCtaText}</p>
            <a href="{$_slOrder|escape}" class="btn">{$hadrianLang.store.slCtaBtn}</a>
        </div>
    </section>
</div>

<div class="when-empty" style="text-align:center;padding:60px 24px;background:var(--color-surface);border:1px solid var(--color-border);border-radius:14px;">
    <div style="width:56px;height:56px;border-radius:50%;background:var(--color-bg);display:inline-flex;align-items:center;justify-content:center;margin-bottom:16px;color:var(--color-text-tertiary);">
        <svg viewBox="0 0 24 24" width="22" height="22" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="11" width="18" height="11" rx="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/></svg>
    </div>
    <p style="font-size:17px;font-weight:600;color:var(--color-text-primary);margin:0 0 6px;">{$hadrianLang.store.slEmptyTitle}</p>
    <p style="font-size:14px;color:var(--color-text-secondary);margin:0 0 20px;max-width:380px;margin-left:auto;margin-right:auto;line-height:1.5;">{$hadrianLang.store.slEmptyText}</p>
    <a href="{$WEB_ROOT}/" class="btn-primary">{$hadrianLang.store.slEmptyHome}</a>
</div>

{literal}
<script>
(function () {
    var tabs = document.querySelectorAll('.hp-faq-tabs-section .hp-faq-cat');
    var panels = document.querySelectorAll('.hp-faq-tabs-section .hp-faq-cat-panel');
    tabs.forEach(function (tab, i) {
        tab.addEventListener('click', function () {
            tabs.forEach(function (t) { t.classList.remove('active'); });
            panels.forEach(function (p) { p.classList.remove('active'); });
            tab.classList.add('active');
            if (panels[i]) panels[i].classList.add('active');
        });
    });
})();
</script>
{/literal}
