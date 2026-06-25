{* Store landing - NordVPN.
   Ported from apple-client-area/nordvpn.html (Public/Marketing landing).
   header.tpl/footer.tpl provide the shell + .content-area, so we emit only the
   inner content (page-header + when-full marketing + when-empty offline state).

   Real pricing: the WHMCS NordVPN store controller assigns $plans and
   $pricings[$plan->id] (per-cycle) + $inPreview - same contract as
   six/store/nordvpn/index.tpl. The mockup has no pricing table (price only
   appears in the hero/CTA as "from $X/mo"), so we capture the first real
   plan/price for those mentions and point the CTAs at a live add-to-cart link,
   falling back to the mockup value otherwise. Static copy is tokenized into the
   hadrianLang store group (nv-prefixed keys); decorative illustrations and
   testimonials are kept verbatim. *}

{assign var=_nvCount value=0}
{if isset($plans)}{assign var=_nvCount value=$plans|@count}{/if}
{assign var=_nvFrom value='$8.99'}
{assign var=_nvPid value=0}
{if $_nvCount > 0}
    {foreach $plans as $_nvPlan}
        {assign var=_nvPid value=$_nvPlan->id}
        {if isset($pricings) && isset($pricings[$_nvPlan->id])}
            {foreach $pricings[$_nvPlan->id] as $_nvPricing}
                {if !$inPreview}{assign var=_nvFrom value=$_nvPricing->monthlyPrice()}{/if}
                {break}
            {/foreach}
        {/if}
        {break}
    {/foreach}
{/if}
{if $_nvPid > 0}
    {assign var=_nvOrder value="`$WEB_ROOT`/cart.php?a=add&pid=`$_nvPid`"}
{else}
    {assign var=_nvOrder value="`$WEB_ROOT`/cart.php?gid=marketconnect"}
{/if}
{if $_nvCount > 0 || (isset($inPreview) && $inPreview)}
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

    {* 1. Hero Orb *}
    <section class="hp-hero-orb">
        <div class="orb-bg"></div>
        <div class="orb-inner">
            <div class="hp-eyebrow">{$hadrianLang.store.nvHeroEyebrow}</div>
            <h1>{$hadrianLang.store.nvHeroTitle}</h1>
            <p>{$hadrianLang.store.nvHeroText}</p>
            <div class="hp-cta-row">
                <a href="{$_nvOrder|escape}" class="hp-buy-btn">{$hadrianLang.store.nvHeroCta}</a>
                <a href="{$_nvOrder|escape}">{$hadrianLang.store.nvSeePlans} &middot; {$hadrianLang.store.nvFrom} {$_nvFrom}/mo &rsaquo;</a>
            </div>
        </div>
    </section>

    {* 2. 3-up feature icons *}
    <section class="hp-icon-grid" style="padding: 40px 22px 48px;">
        <div class="hp-icon-item">
            <div class="icon-circle blue"><svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="2" y="3" width="20" height="14" rx="2"/><line x1="8" y1="21" x2="16" y2="21"/><line x1="12" y1="17" x2="12" y2="21"/></svg></div>
            <h4>{$hadrianLang.store.nvIcon1Title}</h4>
            <p>{$hadrianLang.store.nvIcon1Text}</p>
        </div>
        <div class="hp-icon-item">
            <div class="icon-circle green"><svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="2" y1="12" x2="22" y2="12"/><path d="M12 2a15.3 15.3 0 0 1 4 10 15.3 15.3 0 0 1-4 10 15.3 15.3 0 0 1-4-10 15.3 15.3 0 0 1 4-10z"/></svg></div>
            <h4>{$hadrianLang.store.nvIcon2Title}</h4>
            <p>{$hadrianLang.store.nvIcon2Text}</p>
        </div>
        <div class="hp-icon-item">
            <div class="icon-circle purple"><svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="23 6 13.5 15.5 8.5 10.5 1 18"/><polyline points="17 6 23 6 23 12"/></svg></div>
            <h4>{$hadrianLang.store.nvIcon3Title}</h4>
            <p>{$hadrianLang.store.nvIcon3Text}</p>
        </div>
    </section>

    {* 3. Works on all devices *}
    <section class="hp-features-section" style="padding: 48px 22px;">
        <h2>{$hadrianLang.store.nvDevicesTitle}</h2>
        <p class="feat-sub">{$hadrianLang.store.nvDevicesSub}</p>
        <div class="hp-feature-cards" style="margin-top: 40px; grid-template-columns: repeat(5, 1fr);">
            <div class="hp-feature-card" style="align-items: center; text-align: center;"><div class="feat-icon blue"><svg width="28" height="28" viewBox="0 0 24 24" fill="currentColor"><path d="M3 5.48L10.93 4.4v7.74H3V5.48zM3 18.52l7.93 1.08v-7.68H3v6.6zM11.86 4.27L22.4 2.85v9.29H11.86V4.27zM11.86 19.73L22.4 21.15v-9.01H11.86v7.59z"/></svg></div><h4>Windows</h4><p style="font-size: 12px;">Windows 10, 11</p></div>
            <div class="hp-feature-card" style="align-items: center; text-align: center;"><div class="feat-icon" style="background: var(--color-surface-secondary); color: var(--color-text-primary);"><svg width="28" height="28" viewBox="0 0 24 24" fill="currentColor"><path d="M17.05 12.54c-.02-2.62 2.14-3.87 2.24-3.94-1.22-1.78-3.12-2.03-3.79-2.05-1.61-.16-3.15.95-3.97.95-.83 0-2.09-.93-3.45-.9-1.77.03-3.41 1.03-4.32 2.62-1.86 3.22-.47 7.97 1.32 10.58.88 1.28 1.92 2.71 3.28 2.66 1.32-.05 1.82-.85 3.42-.85 1.59 0 2.04.85 3.44.82 1.43-.02 2.32-1.29 3.18-2.58 1.01-1.48 1.42-2.92 1.44-3-.03-.01-2.77-1.06-2.79-4.21z"/></svg></div><h4>macOS</h4><p style="font-size: 12px;">macOS 11+</p></div>
            <div class="hp-feature-card" style="align-items: center; text-align: center;"><div class="feat-icon green"><svg width="28" height="28" viewBox="0 0 24 24" fill="currentColor"><path d="M17.6 9.48l1.84-3.18c.16-.31.04-.69-.26-.85-.29-.15-.65-.06-.83.22l-1.88 3.24c-2.86-1.21-6.08-1.21-8.94 0L5.65 5.67c-.19-.29-.58-.38-.87-.2-.28.18-.37.54-.22.83L6.4 9.48C3.3 11.25 1.28 14.44 1 18h22c-.28-3.56-2.3-6.75-5.4-8.52z"/></svg></div><h4>Android</h4><p style="font-size: 12px;">Play Store</p></div>
            <div class="hp-feature-card" style="align-items: center; text-align: center;"><div class="feat-icon orange"><svg width="28" height="28" viewBox="0 0 24 24" fill="currentColor"><circle cx="12" cy="12" r="10"/></svg></div><h4>Firefox</h4><p style="font-size: 12px;">Browser extension</p></div>
            <div class="hp-feature-card" style="align-items: center; text-align: center;"><div class="feat-icon red"><svg width="28" height="28" viewBox="0 0 24 24" fill="currentColor"><circle cx="12" cy="12" r="10"/><circle cx="12" cy="12" r="4" fill="#fff"/></svg></div><h4>Chrome</h4><p style="font-size: 12px;">Web Store</p></div>
        </div>
    </section>

    {* 4. Alt Row - What is a VPN *}
    <div class="hp-alternating">
        <div class="hp-alt-row">
            <div class="hp-alt-text">
                <div class="hp-eyebrow">{$hadrianLang.store.nvWhatEyebrow}</div>
                <h3>{$hadrianLang.store.nvWhatTitle}</h3>
                <p>{$hadrianLang.store.nvWhatP1}</p>
                <p style="margin-top: 12px;">{$hadrianLang.store.nvWhatP2}</p>
                <div class="hp-cta-row" style="margin-top: 20px;">
                    <a href="{$_nvOrder|escape}" class="hp-buy-btn">{$hadrianLang.store.nvWhatCta}</a>
                    <span style="font-size: 20px; font-weight: 600; color: var(--color-text-primary);">{$_nvFrom}</span>
                </div>
            </div>
            <div class="hp-alt-visual">
                <div class="visual-box" style="background: var(--color-surface-secondary); padding: 24px;">
                    <div style="width: 100%; max-width: 320px;">
                        <div style="font-size: 12px; font-weight: 600; color: var(--color-text-primary); margin-bottom: 14px; display: flex; align-items: center; gap: 6px;"><span style="width: 6px; height: 6px; background: #30d158; border-radius: 50%;"></span> Secured Connection</div>
                        <div style="display: flex; align-items: center; justify-content: space-between; gap: 10px;">
                            <div style="flex: 1; background: var(--color-surface); padding: 10px; border-radius: 10px; text-align: center;"><svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="#0071e3" stroke-width="2"><rect x="2" y="3" width="20" height="14" rx="2"/></svg><div style="font-size: 10px; margin-top: 4px; color: var(--color-text-tertiary);">Device</div></div>
                            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#0071e3" stroke-width="2"><line x1="5" y1="12" x2="19" y2="12"/><polyline points="12 5 19 12 12 19"/></svg>
                            <div style="flex: 1; background: #0071e3; padding: 10px; border-radius: 10px; text-align: center; color: #fff;"><svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/></svg><div style="font-size: 10px; margin-top: 4px;">NordVPN</div></div>
                            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#0071e3" stroke-width="2"><line x1="5" y1="12" x2="19" y2="12"/><polyline points="12 5 19 12 12 19"/></svg>
                            <div style="flex: 1; background: var(--color-surface); padding: 10px; border-radius: 10px; text-align: center;"><svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="#86868b" stroke-width="2"><circle cx="12" cy="12" r="10"/></svg><div style="font-size: 10px; margin-top: 4px; color: var(--color-text-tertiary);">Internet</div></div>
                        </div>
                        <div style="margin-top: 14px; padding: 10px 12px; background: #e8f8ed; border-radius: 8px; display: flex; align-items: center; gap: 8px;">
                            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#1a7f37" stroke-width="2.5"><polyline points="20 6 9 17 4 12"/></svg>
                            <span style="font-size: 11px; color: #1a7f37; font-weight: 600;">Connection encrypted &middot; 256-bit AES</span>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    {* 5. VPN benefits 3-col *}
    <div style="background: var(--color-surface-secondary);">
    <section class="hp-features-section" style="padding: 48px 22px;">
        <div class="hp-feature-cards" style="max-width: 1024px; margin: 0 auto; grid-template-columns: repeat(3, 1fr);">
            <div class="hp-feature-card">
                <div class="feat-icon blue"><svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/></svg></div>
                <h4>{$hadrianLang.store.nvBenefit1Title}</h4>
                <p>{$hadrianLang.store.nvBenefit1Text}</p>
            </div>
            <div class="hp-feature-card">
                <div class="feat-icon green"><svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polygon points="22 11.08 22 12 22 4 12 14.01 9 11.01"/><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/></svg></div>
                <h4>{$hadrianLang.store.nvBenefit2Title}</h4>
                <p>{$hadrianLang.store.nvBenefit2Text}</p>
            </div>
            <div class="hp-feature-card">
                <div class="feat-icon purple"><svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"/></svg></div>
                <h4>{$hadrianLang.store.nvBenefit3Title}</h4>
                <p>{$hadrianLang.store.nvBenefit3Text}</p>
            </div>
        </div>
    </section>
    </div>

    {* 6. More than just a VPN + duo cards *}
    <section style="padding: 72px 22px 24px; text-align: center;">
        <h2 style="font-size: 48px; font-weight: 600; letter-spacing: -0.02em; margin: 0 0 12px;">{$hadrianLang.store.nvMoreTitle}</h2>
        <p style="font-size: 17px; color: var(--color-text-secondary); max-width: 700px; margin: 0 auto;">{$hadrianLang.store.nvMoreText}</p>
    </section>
    <section class="hp-duo-feature">
        <div class="hp-duo-card">
            <p class="duo-text"><strong>{$hadrianLang.store.nvDuo1Strong}</strong> {$hadrianLang.store.nvDuo1Text}</p>
            <div class="duo-visual duo-visual--left">
                <div style="width: 100%; height: 100%; background: linear-gradient(135deg, #1c1c1e, #2c2c2e); border-radius: 14px; display: flex; align-items: center; justify-content: center; padding: 40px;">
                    <div style="background: #2a2a2c; border-radius: 12px; padding: 20px; width: 100%; max-width: 240px; box-shadow: 0 8px 24px rgba(0,0,0,0.4);">
                        <div style="display: flex; gap: 8px; align-items: center; margin-bottom: 14px;"><svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#ff453a" stroke-width="2"><circle cx="12" cy="12" r="10"/><line x1="4.93" y1="4.93" x2="19.07" y2="19.07"/></svg><span style="font-size: 12px; color: #ff453a; font-weight: 600;">Threat blocked</span></div>
                        <div style="font-size: 11px; color: rgba(255,255,255,0.7); margin-bottom: 4px;">tracker.malicious-ads.example.com</div>
                        <div style="font-size: 9px; color: rgba(255,255,255,0.4);">Blocked 2 minutes ago</div>
                    </div>
                </div>
            </div>
        </div>
        <div class="hp-duo-card">
            <p class="duo-text"><strong>{$hadrianLang.store.nvDuo2Strong}</strong> {$hadrianLang.store.nvDuo2Text}</p>
            <div class="duo-visual duo-visual--right">
                <div style="width: 100%; height: 100%; background: linear-gradient(135deg, #1c1c1e, #2c2c2e); border-radius: 14px; display: flex; align-items: center; justify-content: center; padding: 40px;">
                    <div style="background: #2a2a2c; border-radius: 12px; padding: 20px; width: 100%; max-width: 240px; box-shadow: 0 8px 24px rgba(0,0,0,0.4);">
                        <div style="display: flex; gap: 8px; align-items: center; margin-bottom: 14px;"><svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#30d158" stroke-width="2.5"><polyline points="20 6 9 17 4 12"/></svg><span style="font-size: 12px; color: #30d158; font-weight: 600;">File scan clean</span></div>
                        <div style="font-size: 11px; color: rgba(255,255,255,0.7); margin-bottom: 4px;">report-q4.pdf &middot; 2.4 MB</div>
                        <div style="font-size: 9px; color: rgba(255,255,255,0.4);">Scanned in 0.3s</div>
                    </div>
                </div>
            </div>
        </div>
    </section>

    {* 7. Use cases *}
    <div style="background: var(--color-surface-secondary);">
    <section class="hp-features-section" style="padding: 48px 22px;">
        <h2>{$hadrianLang.store.nvUseTitle}</h2>
        <p class="feat-sub">{$hadrianLang.store.nvUseSub}</p>
        <div class="hp-feature-cards" style="margin-top: 40px; grid-template-columns: repeat(3, 1fr); max-width: 1024px; margin-left: auto; margin-right: auto;">
            <div class="hp-feature-card">
                <div class="feat-icon blue"><svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M5 12.55a11 11 0 0114.08 0"/><path d="M1.42 9a16 16 0 0121.16 0"/><path d="M8.53 16.11a6 6 0 016.95 0"/><line x1="12" y1="20" x2="12.01" y2="20"/></svg></div>
                <h4>{$hadrianLang.store.nvUse1Title}</h4>
                <p>{$hadrianLang.store.nvUse1Text}</p>
            </div>
            <div class="hp-feature-card">
                <div class="feat-icon red"><svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/><line x1="4.93" y1="4.93" x2="19.07" y2="19.07"/></svg></div>
                <h4>{$hadrianLang.store.nvUse2Title}</h4>
                <p>{$hadrianLang.store.nvUse2Text}</p>
            </div>
            <div class="hp-feature-card">
                <div class="feat-icon orange"><svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M21 11.5a8.38 8.38 0 01-.9 3.8 8.5 8.5 0 01-7.6 4.7 8.38 8.38 0 01-3.8-.9L3 21l1.9-5.7a8.38 8.38 0 01-.9-3.8 8.5 8.5 0 014.7-7.6 8.38 8.38 0 013.8-.9h.5a8.48 8.48 0 018 8v.5z"/></svg></div>
                <h4>{$hadrianLang.store.nvUse3Title}</h4>
                <p>{$hadrianLang.store.nvUse3Text}</p>
            </div>
            <div class="hp-feature-card">
                <div class="feat-icon purple"><svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polygon points="23 7 16 12 23 17 23 7"/><rect x="1" y="5" width="15" height="14" rx="2"/></svg></div>
                <h4>{$hadrianLang.store.nvUse4Title}</h4>
                <p>{$hadrianLang.store.nvUse4Text}</p>
            </div>
            <div class="hp-feature-card">
                <div class="feat-icon green"><svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M22 11.08V12a10 10 0 11-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg></div>
                <h4>{$hadrianLang.store.nvUse5Title}</h4>
                <p>{$hadrianLang.store.nvUse5Text}</p>
            </div>
            <div class="hp-feature-card">
                <div class="feat-icon teal"><svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/></svg></div>
                <h4>{$hadrianLang.store.nvUse6Title}</h4>
                <p>{$hadrianLang.store.nvUse6Text}</p>
            </div>
        </div>
    </section>
    </div>

    {* Trust bar *}
    <section class="hp-trust-bar">
        <div class="trust-inner">
            <div class="hp-hero-stat"><div class="stat-num" style="font-size: 48px; color: var(--color-text-primary);">5,500+</div><div class="stat-label">{$hadrianLang.store.nvTrust1}</div></div>
            <div class="hp-hero-stat"><div class="stat-num" style="font-size: 48px; color: var(--color-text-primary);">59</div><div class="stat-label">{$hadrianLang.store.nvTrust2}</div></div>
            <div class="hp-hero-stat"><div class="stat-num" style="font-size: 48px; color: var(--color-text-primary);">No-logs</div><div class="stat-label">{$hadrianLang.store.nvTrust3}</div></div>
            <div class="hp-hero-stat"><div class="stat-num" style="font-size: 48px; color: var(--color-text-primary);">14M+</div><div class="stat-label">{$hadrianLang.store.nvTrust4}</div></div>
        </div>
    </section>

    {* 8. Testimonials - decorative, kept verbatim *}
    <section class="hp-testi-masonry">
        <h2>{$hadrianLang.store.nvTestiTitle}</h2>
        <p class="hp-testi-masonry-sub">{$hadrianLang.store.nvTestiSub}</p>
        <div class="hp-testi-masonry-grid">
            <div class="hp-testi-tile"><div class="stars">&starf;&starf;&starf;&starf;&starf;</div><p class="quote">Switching to NordVPN is a hands-down favorite. Their reliable connection and efficient support has helped me live my digital life without interruption.</p><div class="author"><div class="avatar" style="background-image:url('https://i.pravatar.cc/96?u=michaelbrown');"></div><div><div class="name">Michael Brown</div><div class="role">NextLabs</div></div></div></div>
            <div class="hp-testi-tile tall accent"><div class="stars">&starf;&starf;&starf;&starf;&starf;</div><p class="quote">Five-star service! Reviews are positive and the speeds are maintained thanks to unwavering cost-effectiveness, hospitable work, and outstanding performance.</p><div class="author"><div class="avatar" style="background-image:url('https://i.pravatar.cc/96?u=michaelsmith');"></div><div><div class="name">Michael Smith</div><div class="role">GrowthLab</div></div></div></div>
            <div class="hp-testi-tile"><div class="stars">&starf;&starf;&starf;&starf;&starf;</div><p class="quote">Their products are simply amazing. The quality, features, and value they offer have elevated my online presence. A fantastic choice for anyone looking for security.</p><div class="author"><div class="avatar" style="background-image:url('https://i.pravatar.cc/96?u=mariasusto');"></div><div><div class="name">Maria Susto</div><div class="role">PixelAgency</div></div></div></div>
            <div class="hp-testi-tile dark"><div class="stars">&starf;&starf;&starf;&starf;&starf;</div><p class="quote">Thoroughly impressed with their service. The standout feature for me is the support &mdash; quick, friendly, and incredibly helpful.</p><div class="author"><div class="avatar" style="background-image:url('https://i.pravatar.cc/96?u=johndoe');"></div><div><div class="name">John Doe</div><div class="role">Indie Developer</div></div></div></div>
            <div class="hp-testi-tile"><div class="stars">&starf;&starf;&starf;&starf;&starf;</div><p class="quote">Opting for NordVPN was the affordable solution, and incredibly, it&rsquo;s extended my passion for secure browsing. Reliable and well worth the price.</p><div class="author"><div class="avatar" style="background-image:url('https://i.pravatar.cc/96?u=ritawilliams');"></div><div><div class="name">Rita Williams</div><div class="role">Studio34</div></div></div></div>
            <div class="hp-testi-tile tall cream"><div class="stars">&starf;&starf;&starf;&starf;&starf;</div><p class="quote">Thrilled with their service. The performance has been exceptional. Kudos to their tech-savvy team! I&rsquo;ve been using it for three years and still recommend it.</p><div class="author"><div class="avatar" style="background-image:url('https://i.pravatar.cc/96?u=michaelsmithalt');"></div><div><div class="name">Michael Smith</div><div class="role">NextLabs</div></div></div></div>
        </div>
    </section>

    {* 9. FAQ - tabbed categories (toggle wired below) *}
    <section class="hp-faq-tabs-section">
        <h2>{$hadrianLang.store.nvFaqTitle}</h2>
        <p class="sub">{$hadrianLang.store.nvFaqSub}</p>
        <div class="hp-faq-cat-tabs">
            <button class="hp-faq-cat active">{$hadrianLang.store.nvFaqTabBasics}</button>
            <button class="hp-faq-cat">{$hadrianLang.store.nvFaqTabSecurity}</button>
            <button class="hp-faq-cat">{$hadrianLang.store.nvFaqTabFeatures}</button>
            <button class="hp-faq-cat">{$hadrianLang.store.nvFaqTabSetup}</button>
        </div>
        <div class="hp-faq-cat-panel active">
            <details class="hp-faq-item"><summary>{$hadrianLang.store.nvFaqB1Q}</summary><div class="faq-body">{$hadrianLang.store.nvFaqB1A}</div></details>
            <details class="hp-faq-item"><summary>{$hadrianLang.store.nvFaqB2Q}</summary><div class="faq-body">{$hadrianLang.store.nvFaqB2A}</div></details>
            <details class="hp-faq-item"><summary>{$hadrianLang.store.nvFaqB3Q}</summary><div class="faq-body">{$hadrianLang.store.nvFaqB3A}</div></details>
        </div>
        <div class="hp-faq-cat-panel">
            <details class="hp-faq-item"><summary>{$hadrianLang.store.nvFaqS1Q}</summary><div class="faq-body">{$hadrianLang.store.nvFaqS1A}</div></details>
            <details class="hp-faq-item"><summary>{$hadrianLang.store.nvFaqS2Q}</summary><div class="faq-body">{$hadrianLang.store.nvFaqS2A}</div></details>
        </div>
        <div class="hp-faq-cat-panel">
            <details class="hp-faq-item"><summary>{$hadrianLang.store.nvFaqF1Q}</summary><div class="faq-body">{$hadrianLang.store.nvFaqF1A}</div></details>
            <details class="hp-faq-item"><summary>{$hadrianLang.store.nvFaqF2Q}</summary><div class="faq-body">{$hadrianLang.store.nvFaqF2A}</div></details>
        </div>
        <div class="hp-faq-cat-panel">
            <details class="hp-faq-item"><summary>{$hadrianLang.store.nvFaqP1Q}</summary><div class="faq-body">{$hadrianLang.store.nvFaqP1A}</div></details>
            <details class="hp-faq-item"><summary>{$hadrianLang.store.nvFaqP2Q}</summary><div class="faq-body">{$hadrianLang.store.nvFaqP2A}</div></details>
        </div>
    </section>

    {* 10. Immersive CTA *}
    <section class="hp-cta-immersive">
        <div class="inner">
            <h2>{$hadrianLang.store.nvCtaTitle}</h2>
            <p>{$hadrianLang.store.nvCtaText}</p>
            <a href="{$_nvOrder|escape}" class="btn">{$hadrianLang.store.nvCtaBtn} &mdash; {$_nvFrom}/mo</a>
        </div>
    </section>
</div>

<div class="when-empty" style="text-align:center;padding:60px 24px;background:var(--color-surface);border:1px solid var(--color-border);border-radius:14px;">
    <div style="width:56px;height:56px;border-radius:50%;background:var(--color-bg);display:inline-flex;align-items:center;justify-content:center;margin-bottom:16px;color:var(--color-text-tertiary);">
        <svg viewBox="0 0 24 24" width="22" height="22" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/></svg>
    </div>
    <p style="font-size:17px;font-weight:600;color:var(--color-text-primary);margin:0 0 6px;">{$hadrianLang.store.nvEmptyTitle}</p>
    <p style="font-size:14px;color:var(--color-text-secondary);margin:0 0 20px;max-width:380px;margin-left:auto;margin-right:auto;line-height:1.5;">{$hadrianLang.store.nvEmptyText}</p>
    <a href="{$WEB_ROOT}/" class="btn-primary">{$hadrianLang.store.nvEmptyHome}</a>
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
