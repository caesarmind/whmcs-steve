{* Store landing - Professional Email (Open-Xchange).
   Ported from apple-client-area/email.html (Public/Marketing landing).
   header.tpl/footer.tpl provide the shell + .content-area, so we emit only the
   inner content (page-header + when-full marketing + when-empty offline state).

   Real pricing: the WHMCS OX store controller assigns $plans + $inPreview -
   same contract as six/store/ox/index.tpl. The mockup's three price cards map to
   the real plans (captured by position); we keep the card copy/features and wire
   each price + order button to the real plan, falling back to the mockup values
   otherwise. The monthly/annual toggle's inline onclick (raw JS braces) is moved
   to a literal-wrapped script so Smarty doesn't parse it. Static copy is tokenized
   into the hadrianLang store group (ox-prefixed keys); decorative inbox/visual
   blocks and testimonials are kept verbatim. *}

{assign var=_oxCount value=0}
{if isset($plans)}{assign var=_oxCount value=$plans|@count}{/if}
{assign var=_oxI value=0}
{if $_oxCount > 0}
    {foreach $plans as $_oxPlan}
        {if $_oxI == 0}{assign var=_ox1 value=$_oxPlan}{elseif $_oxI == 1}{assign var=_ox2 value=$_oxPlan}{elseif $_oxI == 2}{assign var=_ox3 value=$_oxPlan}{/if}
        {assign var=_oxI value=$_oxI+1}
    {/foreach}
{/if}
{if $_oxCount > 0 || (isset($inPreview) && $inPreview)}
    {assign var=storeIsEmpty value='full'}
{else}
    {assign var=storeIsEmpty value='empty'}
{/if}

<header class="page-header">
    <p class="page-eyebrow">{$hadrianLang.store.oxEyebrow}</p>
    <h1>{$hadrianLang.store.oxPageTitle}</h1>
    <p class="page-subtitle">{$hadrianLang.store.oxPageSubtitle}</p>
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
    <section class="hp-hero-split">
        <div class="hp-split-text">
            <div class="hp-eyebrow">{$hadrianLang.store.oxHeroEyebrow}</div>
            <h1>{$hadrianLang.store.oxHeroTitle}</h1>
            <p>{$hadrianLang.store.oxHeroText}</p>
            <div class="hp-cta-row">
                <a href="#pricing" class="hp-buy-btn">{$hadrianLang.store.oxHeroCta}</a>
                <a href="#pricing">{$hadrianLang.store.oxSeePlans} &rsaquo;</a>
            </div>
        </div>
        <div class="hp-split-visual">
            <div class="hp-browser-frame">
                <div class="hp-browser-bar">
                    <span class="dot" style="background: #ff5f57;"></span>
                    <span class="dot" style="background: #febc2e;"></span>
                    <span class="dot" style="background: #28c840;"></span>
                </div>
                <div class="hp-dash-shot" style="padding: 0;">
                    <div style="background: #fff; border-radius: 0 0 10px 10px; overflow: hidden;">
                        <div style="display: flex; align-items: center; justify-content: space-between; padding: 10px 16px; border-bottom: 1px solid #e8e8ed;">
                            <div style="display: flex; align-items: center; gap: 8px;">
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#86868b" stroke-width="1.8" stroke-linecap="round"><path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"/><polyline points="22,6 12,13 2,6"/></svg>
                                <span style="font-size: 13px; font-weight: 600; color: #1d1d1f;">Inbox</span>
                                <span style="font-size: 11px; color: #86868b; background: #f0f0f0; padding: 1px 7px; border-radius: 10px;">4</span>
                            </div>
                            <div style="display: flex; gap: 12px;">
                                <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#86868b" stroke-width="1.8" stroke-linecap="round"><path d="M3 6h18M3 12h18M3 18h18"/></svg>
                                <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#86868b" stroke-width="1.8" stroke-linecap="round"><path d="M12 5v14M5 12h14"/></svg>
                            </div>
                        </div>
                        <div style="display: flex; align-items: flex-start; gap: 12px; padding: 12px 16px; border-bottom: 1px solid #f0f0f0; background: #f0f5ff;">
                            <div style="width: 34px; height: 34px; border-radius: 50%; background: linear-gradient(135deg, #0071e3, #40a0ff); display: flex; align-items: center; justify-content: center; font-size: 13px; font-weight: 600; color: #fff; flex-shrink: 0;">JC</div>
                            <div style="flex: 1; min-width: 0;">
                                <div style="display: flex; justify-content: space-between; align-items: baseline; margin-bottom: 2px;"><span style="font-size: 13px; font-weight: 600; color: #1d1d1f;">James Chen</span><span style="font-size: 10px; color: #86868b; flex-shrink: 0;">10:42 AM</span></div>
                                <div style="font-size: 12px; font-weight: 600; color: #1d1d1f; margin-bottom: 1px;">Q2 Brand Campaign Draft</div>
                                <div style="font-size: 11px; color: #86868b; white-space: nowrap; overflow: hidden; text-overflow: ellipsis;">Hey team, I&rsquo;ve attached the latest mockups for the Q2 campaign. Let me know...</div>
                            </div>
                        </div>
                        <div style="display: flex; align-items: flex-start; gap: 12px; padding: 12px 16px; border-bottom: 1px solid #f0f0f0; background: #f0f5ff;">
                            <div style="width: 34px; height: 34px; border-radius: 50%; background: linear-gradient(135deg, #30d158, #5ae07a); display: flex; align-items: center; justify-content: center; font-size: 13px; font-weight: 600; color: #fff; flex-shrink: 0;">SL</div>
                            <div style="flex: 1; min-width: 0;">
                                <div style="display: flex; justify-content: space-between; align-items: baseline; margin-bottom: 2px;"><span style="font-size: 13px; font-weight: 600; color: #1d1d1f;">Sara Lee</span><span style="font-size: 10px; color: #86868b; flex-shrink: 0;">9:15 AM</span></div>
                                <div style="font-size: 12px; font-weight: 600; color: #1d1d1f; margin-bottom: 1px;">Invoice #4021 - Payment Received</div>
                                <div style="font-size: 11px; color: #86868b; white-space: nowrap; overflow: hidden; text-overflow: ellipsis;">Hi, confirming we received the payment for invoice #4021. Thank you for...</div>
                            </div>
                        </div>
                        <div style="display: flex; align-items: flex-start; gap: 12px; padding: 12px 16px; border-bottom: 1px solid #f0f0f0;">
                            <div style="width: 34px; height: 34px; border-radius: 50%; background: linear-gradient(135deg, #ff9f0a, #ffb940); display: flex; align-items: center; justify-content: center; font-size: 13px; font-weight: 600; color: #fff; flex-shrink: 0;">MR</div>
                            <div style="flex: 1; min-width: 0;">
                                <div style="display: flex; justify-content: space-between; align-items: baseline; margin-bottom: 2px;"><span style="font-size: 13px; font-weight: 500; color: #1d1d1f;">Mark Rivera</span><span style="font-size: 10px; color: #86868b; flex-shrink: 0;">Yesterday</span></div>
                                <div style="font-size: 12px; font-weight: 500; color: #3a3a3c; margin-bottom: 1px;">Re: Meeting notes - Product sync</div>
                                <div style="font-size: 11px; color: #86868b; white-space: nowrap; overflow: hidden; text-overflow: ellipsis;">Sounds good. I&rsquo;ll update the roadmap and share the revised timeline by...</div>
                            </div>
                        </div>
                        <div style="display: flex; align-items: flex-start; gap: 12px; padding: 12px 16px;">
                            <div style="width: 34px; height: 34px; border-radius: 50%; background: linear-gradient(135deg, #ff3b30, #ff6961); display: flex; align-items: center; justify-content: center; font-size: 13px; font-weight: 600; color: #fff; flex-shrink: 0;">DN</div>
                            <div style="flex: 1; min-width: 0;">
                                <div style="display: flex; justify-content: space-between; align-items: baseline; margin-bottom: 2px;"><span style="font-size: 13px; font-weight: 500; color: #1d1d1f;">David Nguyen</span><span style="font-size: 10px; color: #86868b; flex-shrink: 0;">Apr 10</span></div>
                                <div style="font-size: 12px; font-weight: 500; color: #3a3a3c; margin-bottom: 1px;">DNS records updated</div>
                                <div style="font-size: 11px; color: #86868b; white-space: nowrap; overflow: hidden; text-overflow: ellipsis;">All MX and SPF records are live. DKIM signing is active. Deliverability...</div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>

    {* 2. Horizontal scroll cards *}
    <section class="hp-strip-section">
        <div class="hp-strip-header">
            <h2>{$hadrianLang.store.oxStripTitle}</h2>
        </div>
        <div class="hp-strip-scroll">
            <div class="hp-strip-card a">
                <div class="tag">{$hadrianLang.store.oxStrip1Tag}</div>
                <h3>{$hadrianLang.store.oxStrip1Title}</h3>
                <p>{$hadrianLang.store.oxStrip1Text}</p>
                <div class="strip-visual">
                    <div style="background: rgba(0,0,0,0.2); border-radius: 12px; padding: 18px 20px; width: 100%; max-width: 260px;">
                        <div style="font-size: 11px; color: rgba(255,255,255,0.5); margin-bottom: 10px;">FROM</div>
                        <div style="display: flex; align-items: center; gap: 10px; margin-bottom: 14px;">
                            <div style="width: 30px; height: 30px; border-radius: 50%; background: linear-gradient(135deg, #ff9f0a, #ffb940); display: flex; align-items: center; justify-content: center; font-size: 12px; font-weight: 600; color: #fff;">Y</div>
                            <div><div style="font-size: 13px; font-weight: 600;">you@yourbrand.com</div><div style="font-size: 10px; opacity: 0.5;">Your Brand Inc.</div></div>
                        </div>
                        <div style="height: 1px; background: rgba(255,255,255,0.1); margin-bottom: 10px;"></div>
                        <div style="font-size: 11px; color: rgba(255,255,255,0.5); margin-bottom: 6px;">TO</div>
                        <div style="font-size: 13px; font-weight: 500;">client@example.com</div>
                    </div>
                </div>
            </div>
            <div class="hp-strip-card b">
                <div class="tag">{$hadrianLang.store.oxStrip2Tag}</div>
                <h3>{$hadrianLang.store.oxStrip2Title}</h3>
                <p>{$hadrianLang.store.oxStrip2Text}</p>
                <div class="strip-visual">
                    <div style="width: 120px; height: 120px; position: relative;">
                        <svg width="120" height="120" viewBox="0 0 120 120" fill="none">
                            <circle cx="60" cy="60" r="50" stroke="rgba(255,255,255,0.1)" stroke-width="8"/>
                            <circle cx="60" cy="60" r="50" stroke="#2997ff" stroke-width="8" stroke-linecap="round" stroke-dasharray="62 314" transform="rotate(-90 60 60)"/>
                        </svg>
                        <div style="position: absolute; top: 50%; left: 50%; transform: translate(-50%,-50%); text-align: center;">
                            <div style="font-size: 28px; font-weight: 600; letter-spacing: -0.02em;">50</div>
                            <div style="font-size: 11px; opacity: 0.6; margin-top: -2px;">GB</div>
                        </div>
                    </div>
                </div>
            </div>
            <div class="hp-strip-card c">
                <div class="tag">{$hadrianLang.store.oxStrip3Tag}</div>
                <h3>{$hadrianLang.store.oxStrip3Title}</h3>
                <p>{$hadrianLang.store.oxStrip3Text}</p>
                <div class="strip-visual">
                    <div style="display: flex; flex-direction: column; gap: 8px; width: 100%; max-width: 220px;">
                        <div style="display: flex; align-items: center; gap: 10px; background: rgba(0,0,0,0.15); padding: 10px 14px; border-radius: 10px;"><svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#30d158" stroke-width="2" stroke-linecap="round"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg><div><div style="font-size: 12px; font-weight: 600;">Team Standup</div><div style="font-size: 10px; opacity: 0.6;">Mon-Fri &middot; 9:00 AM</div></div></div>
                        <div style="display: flex; align-items: center; gap: 10px; background: rgba(0,0,0,0.15); padding: 10px 14px; border-radius: 10px;"><svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#30d158" stroke-width="2" stroke-linecap="round"><path d="M20 21v-2a4 4 0 00-4-4H8a4 4 0 00-4 4v2"/><circle cx="12" cy="7" r="4"/></svg><div><div style="font-size: 12px; font-weight: 600;">Client Review</div><div style="font-size: 10px; opacity: 0.6;">Wed &middot; 2:00 PM</div></div></div>
                        <div style="display: flex; align-items: center; gap: 10px; background: rgba(0,0,0,0.15); padding: 10px 14px; border-radius: 10px;"><svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#30d158" stroke-width="2" stroke-linecap="round"><polyline points="20 6 9 17 4 12"/></svg><div><div style="font-size: 12px; font-weight: 600;">128 contacts synced</div><div style="font-size: 10px; opacity: 0.6;">Last sync &middot; 2 min ago</div></div></div>
                    </div>
                </div>
            </div>
            <div class="hp-strip-card d">
                <div class="tag">{$hadrianLang.store.oxStrip4Tag}</div>
                <h3>{$hadrianLang.store.oxStrip4Title}</h3>
                <p>{$hadrianLang.store.oxStrip4Text}</p>
                <div class="strip-visual">
                    <div style="position: relative; width: 100px; height: 120px;">
                        <svg width="100" height="120" viewBox="0 0 100 120" fill="none">
                            <path d="M50 8 L92 28 L92 60 C92 88 50 112 50 112 C50 112 8 88 8 60 L8 28 Z" fill="rgba(255,59,48,0.15)" stroke="#ff3b30" stroke-width="2.5"/>
                            <path d="M36 60 L46 70 L66 50" stroke="#ff3b30" stroke-width="3.5" stroke-linecap="round" stroke-linejoin="round" fill="none"/>
                        </svg>
                    </div>
                </div>
            </div>
            <div class="hp-strip-card e">
                <div class="tag">{$hadrianLang.store.oxStrip5Tag}</div>
                <h3>{$hadrianLang.store.oxStrip5Title}</h3>
                <p>{$hadrianLang.store.oxStrip5Text}</p>
                <div class="strip-visual">
                    <div style="display: flex; gap: 16px; align-items: flex-end;">
                        <div style="width: 64px; height: 110px; background: rgba(255,255,255,0.08); border: 2px solid rgba(255,255,255,0.2); border-radius: 12px; padding: 8px 6px; display: flex; flex-direction: column; align-items: center; gap: 4px;">
                            <div style="width: 20px; height: 3px; background: rgba(255,255,255,0.2); border-radius: 2px; margin-bottom: 4px;"></div>
                            <div style="width: 100%; height: 6px; background: rgba(175,130,255,0.3); border-radius: 3px;"></div>
                            <div style="width: 100%; height: 6px; background: rgba(175,130,255,0.2); border-radius: 3px;"></div>
                            <div style="width: 100%; height: 6px; background: rgba(175,130,255,0.15); border-radius: 3px;"></div>
                            <div style="width: 100%; height: 6px; background: rgba(175,130,255,0.1); border-radius: 3px;"></div>
                            <div style="flex: 1;"></div>
                            <div style="width: 16px; height: 16px; border: 1.5px solid rgba(255,255,255,0.2); border-radius: 50%;"></div>
                        </div>
                        <div style="width: 100px; height: 130px; background: rgba(255,255,255,0.08); border: 2px solid rgba(255,255,255,0.2); border-radius: 10px; padding: 10px 8px; display: flex; flex-direction: column; gap: 5px;">
                            <div style="width: 24px; height: 3px; background: rgba(255,255,255,0.2); border-radius: 2px; align-self: center; margin-bottom: 2px;"></div>
                            <div style="width: 100%; height: 7px; background: rgba(175,130,255,0.3); border-radius: 3px;"></div>
                            <div style="width: 100%; height: 7px; background: rgba(175,130,255,0.2); border-radius: 3px;"></div>
                            <div style="width: 100%; height: 7px; background: rgba(175,130,255,0.15); border-radius: 3px;"></div>
                            <div style="width: 100%; height: 7px; background: rgba(175,130,255,0.1); border-radius: 3px;"></div>
                            <div style="width: 100%; height: 7px; background: rgba(175,130,255,0.08); border-radius: 3px;"></div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>

    {* 3. Pricing - 3 cards wired to real plans (monthly/annual toggle via literal script) *}
    <section class="hp-pricing-toggle-section" id="pricing">
        <h2>{$hadrianLang.store.oxPricingTitle}</h2>
        <p class="sub">{$hadrianLang.store.oxPricingSub}</p>
        <div class="hp-billing-toggle">
            <button class="active" data-ox-cycle="monthly">{$hadrianLang.store.oxCycleMonthly}</button>
            <button data-ox-cycle="annual">{$hadrianLang.store.oxCycleAnnual}</button>
        </div>
        <div class="hp-pricing-grid">
            <div class="hp-price-card dim">
                <div class="label">{if isset($_ox1)}{$_ox1->name|escape}{else}{$hadrianLang.store.oxPlan1Name}{/if}</div>
                <h3>{$hadrianLang.store.oxPlan1Tagline}</h3>
                {if isset($_ox1)}<span class="price">{$_ox1->pricing()->first()->toFullString()}</span>{else}<span class="price" data-monthly="$1.99" data-annual="$19.99">$1.99</span><span class="per">/mo</span>{/if}
                <ul>
                    <li>{$hadrianLang.store.oxPlan1F1}</li>
                    <li>{$hadrianLang.store.oxPlan1F2}</li>
                    <li>{$hadrianLang.store.oxPlan1F3}</li>
                    <li>{$hadrianLang.store.oxPlan1F4}</li>
                </ul>
                <a class="buy" href="{if isset($_ox1)}{$WEB_ROOT}/cart.php?a=add&amp;pid={$_ox1->id}{else}#pricing{/if}">{$hadrianLang.store.oxSelect} {if isset($_ox1)}{$_ox1->name|escape}{else}{$hadrianLang.store.oxPlan1Name}{/if}</a>
            </div>
            <div class="hp-price-card highlight">
                <div class="label" style="color: var(--color-accent);">{if isset($_ox2)}{$_ox2->name|escape}{else}{$hadrianLang.store.oxPlan2Name}{/if} - {$hadrianLang.store.oxMostPopular}</div>
                <h3>{$hadrianLang.store.oxPlan2Tagline}</h3>
                {if isset($_ox2)}<span class="price">{$_ox2->pricing()->first()->toFullString()}</span>{else}<span class="price" data-monthly="$4.99" data-annual="$49.99">$4.99</span><span class="per">/mo</span>{/if}
                <ul>
                    <li>{$hadrianLang.store.oxPlan2F1}</li>
                    <li>{$hadrianLang.store.oxPlan2F2}</li>
                    <li>{$hadrianLang.store.oxPlan2F3}</li>
                    <li>{$hadrianLang.store.oxPlan2F4}</li>
                </ul>
                <a class="buy" href="{if isset($_ox2)}{$WEB_ROOT}/cart.php?a=add&amp;pid={$_ox2->id}{else}#pricing{/if}">{$hadrianLang.store.oxSelect} {if isset($_ox2)}{$_ox2->name|escape}{else}{$hadrianLang.store.oxPlan2Name}{/if}</a>
            </div>
            <div class="hp-price-card dim">
                <div class="label">{if isset($_ox3)}{$_ox3->name|escape}{else}{$hadrianLang.store.oxPlan3Name}{/if}</div>
                <h3>{$hadrianLang.store.oxPlan3Tagline}</h3>
                {if isset($_ox3)}<span class="price">{$_ox3->pricing()->first()->toFullString()}</span>{else}<span class="price" data-monthly="$9.99" data-annual="$99.99">$9.99</span><span class="per">/mo</span>{/if}
                <ul>
                    <li>{$hadrianLang.store.oxPlan3F1}</li>
                    <li>{$hadrianLang.store.oxPlan3F2}</li>
                    <li>{$hadrianLang.store.oxPlan3F3}</li>
                    <li>{$hadrianLang.store.oxPlan3F4}</li>
                    <li>{$hadrianLang.store.oxPlan3F5}</li>
                </ul>
                <a class="buy" href="{if isset($_ox3)}{$WEB_ROOT}/cart.php?a=add&amp;pid={$_ox3->id}{else}#pricing{/if}">{$hadrianLang.store.oxSelect} {if isset($_ox3)}{$_ox3->name|escape}{else}{$hadrianLang.store.oxPlan3Name}{/if}</a>
            </div>
        </div>
    </section>

    {* 4. Alternating sections *}
    <section class="hp-alternating">
        <div class="hp-alt-row">
            <div class="hp-alt-text">
                <div class="hp-eyebrow" style="color: var(--color-accent);">{$hadrianLang.store.oxCompatEyebrow}</div>
                <h2>{$hadrianLang.store.oxCompatTitle}</h2>
                <p>{$hadrianLang.store.oxCompatText}</p>
            </div>
            <div class="hp-alt-visual">
                <div class="visual-box">
                    <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 14px; width: 100%; max-width: 280px;">
                        <div style="background: #fff; border-radius: 16px; padding: 20px; text-align: center; box-shadow: 0 2px 8px rgba(0,0,0,0.06);"><div style="width: 48px; height: 48px; background: linear-gradient(135deg, #0078d4, #28a8ea); border-radius: 12px; display: flex; align-items: center; justify-content: center; margin: 0 auto 10px; font-size: 22px; font-weight: 700; color: #fff;">O</div><div style="font-size: 12px; font-weight: 600; color: #1d1d1f;">Outlook</div></div>
                        <div style="background: #fff; border-radius: 16px; padding: 20px; text-align: center; box-shadow: 0 2px 8px rgba(0,0,0,0.06);"><div style="width: 48px; height: 48px; background: linear-gradient(135deg, #007aff, #5ac8fa); border-radius: 12px; display: flex; align-items: center; justify-content: center; margin: 0 auto 10px; font-size: 22px; font-weight: 700; color: #fff;">M</div><div style="font-size: 12px; font-weight: 600; color: #1d1d1f;">Apple Mail</div></div>
                        <div style="background: #fff; border-radius: 16px; padding: 20px; text-align: center; box-shadow: 0 2px 8px rgba(0,0,0,0.06);"><div style="width: 48px; height: 48px; background: linear-gradient(135deg, #0a84ff, #1e5fc9); border-radius: 12px; display: flex; align-items: center; justify-content: center; margin: 0 auto 10px; font-size: 22px; font-weight: 700; color: #fff;">T</div><div style="font-size: 12px; font-weight: 600; color: #1d1d1f;">Thunderbird</div></div>
                        <div style="background: #fff; border-radius: 16px; padding: 20px; text-align: center; box-shadow: 0 2px 8px rgba(0,0,0,0.06);"><div style="width: 48px; height: 48px; background: linear-gradient(135deg, #ea4335, #fbbc04); border-radius: 12px; display: flex; align-items: center; justify-content: center; margin: 0 auto 10px; font-size: 22px; font-weight: 700; color: #fff;">G</div><div style="font-size: 12px; font-weight: 600; color: #1d1d1f;">Gmail</div></div>
                    </div>
                </div>
            </div>
        </div>
        <div class="hp-alt-row reverse">
            <div class="hp-alt-text">
                <div class="hp-eyebrow" style="color: #30d158;">{$hadrianLang.store.oxSecEyebrow}</div>
                <h2>{$hadrianLang.store.oxSecTitle}</h2>
                <p>{$hadrianLang.store.oxSecText}</p>
            </div>
            <div class="hp-alt-visual">
                <div class="visual-box dark" style="position: relative;">
                    <div style="width: 100%; display: flex; flex-direction: column; align-items: center; gap: 20px; padding: 10px 0;">
                        <svg width="80" height="96" viewBox="0 0 100 120" fill="none">
                            <path d="M50 8 L92 28 L92 60 C92 88 50 112 50 112 C50 112 8 88 8 60 L8 28 Z" fill="rgba(48,209,88,0.1)" stroke="#30d158" stroke-width="2"/>
                            <rect x="38" y="48" width="24" height="20" rx="3" fill="none" stroke="#30d158" stroke-width="2"/>
                            <path d="M43 48 V42 C43 36 57 36 57 42 V48" fill="none" stroke="#30d158" stroke-width="2" stroke-linecap="round"/>
                            <circle cx="50" cy="59" r="3" fill="#30d158"/>
                        </svg>
                        <div style="display: flex; gap: 10px; flex-wrap: wrap; justify-content: center;">
                            <div style="background: rgba(48,209,88,0.12); color: #30d158; font-size: 11px; font-weight: 600; padding: 6px 14px; border-radius: 20px;">TLS 1.3</div>
                            <div style="background: rgba(48,209,88,0.12); color: #30d158; font-size: 11px; font-weight: 600; padding: 6px 14px; border-radius: 20px;">AES-256</div>
                            <div style="background: rgba(48,209,88,0.12); color: #30d158; font-size: 11px; font-weight: 600; padding: 6px 14px; border-radius: 20px;">SPF</div>
                            <div style="background: rgba(48,209,88,0.12); color: #30d158; font-size: 11px; font-weight: 600; padding: 6px 14px; border-radius: 20px;">DKIM</div>
                            <div style="background: rgba(48,209,88,0.12); color: #30d158; font-size: 11px; font-weight: 600; padding: 6px 14px; border-radius: 20px;">DMARC</div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>

    {* 5. Trust bar *}
    <section class="hp-trust-bar">
        <div class="trust-inner">
            <div class="hp-hero-stat"><div class="stat-num" style="font-size: 48px; color: #1d1d1f;">50 GB</div><div class="stat-label">{$hadrianLang.store.oxTrust1}</div></div>
            <div class="hp-hero-stat"><div class="stat-num" style="font-size: 48px; color: #1d1d1f;">99.9%</div><div class="stat-label">{$hadrianLang.store.oxTrust2}</div></div>
            <div class="hp-hero-stat"><div class="stat-num" style="font-size: 48px; color: #1d1d1f;">Anti-spam</div><div class="stat-label">{$hadrianLang.store.oxTrust3}</div></div>
            <div class="hp-hero-stat"><div class="stat-num" style="font-size: 48px; color: #1d1d1f;">IMAP &amp; POP3</div><div class="stat-label">{$hadrianLang.store.oxTrust4}</div></div>
        </div>
    </section>

    {* 6. Upgrade section *}
    <section class="hp-upgrade-section">
        <h2>{$hadrianLang.store.oxUpgradeTitle}</h2>
        <p class="upgrade-sub">{$hadrianLang.store.oxUpgradeSub}</p>
        <div class="hp-upgrade-grid">
            <div class="hp-upgrade-item"><div class="upgrade-metric">50 GB</div><h4>{$hadrianLang.store.oxUp1Title}</h4><p>{$hadrianLang.store.oxUp1Text}</p></div>
            <div class="hp-upgrade-item"><div class="upgrade-metric">@you</div><h4>{$hadrianLang.store.oxUp2Title}</h4><p>{$hadrianLang.store.oxUp2Text}</p></div>
            <div class="hp-upgrade-item"><div class="upgrade-metric">0</div><h4>{$hadrianLang.store.oxUp3Title}</h4><p>{$hadrianLang.store.oxUp3Text}</p></div>
            <div class="hp-upgrade-item"><div class="upgrade-metric">99.9%</div><h4>{$hadrianLang.store.oxUp4Title}</h4><p>{$hadrianLang.store.oxUp4Text}</p></div>
            <div class="hp-upgrade-item"><div class="upgrade-metric">24/7</div><h4>{$hadrianLang.store.oxUp5Title}</h4><p>{$hadrianLang.store.oxUp5Text}</p></div>
            <div class="hp-upgrade-item"><div class="upgrade-metric">HIPAA</div><h4>{$hadrianLang.store.oxUp6Title}</h4><p>{$hadrianLang.store.oxUp6Text}</p></div>
        </div>
    </section>

    {* 7. Locations compact *}
    <section class="hp-locations-compact">
        <h2>{$hadrianLang.store.oxLocTitle}</h2>
        <p class="loc-sub">{$hadrianLang.store.oxLocSub}</p>
        <div class="loc-pills">
            <span class="loc-pill"><span class="flag">&#128241;</span> iOS</span>
            <span class="loc-pill"><span class="flag">&#129302;</span> Android</span>
            <span class="loc-pill"><span class="flag">&#128187;</span> macOS</span>
            <span class="loc-pill"><span class="flag">&#129003;</span> Windows</span>
            <span class="loc-pill"><span class="flag">&#128039;</span> Linux</span>
            <span class="loc-pill"><span class="flag">&#127760;</span> Webmail</span>
            <span class="loc-pill"><span class="flag">&#128232;</span> Outlook</span>
            <span class="loc-pill"><span class="flag">&#127822;</span> Apple Mail</span>
            <span class="loc-pill"><span class="flag">&#129413;</span> Thunderbird</span>
        </div>
    </section>

    {* 8. Features *}
    <section class="hp-features-section">
        <h2>{$hadrianLang.store.oxFeaturesTitle}</h2>
        <p class="feat-sub">{$hadrianLang.store.oxFeaturesSub}</p>
        <div class="hp-feature-cards">
            <div class="hp-feature-card"><div class="feat-icon blue"><svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/><path d="M2 12h20M12 2a15.3 15.3 0 014 10 15.3 15.3 0 01-4 10 15.3 15.3 0 01-4-10 15.3 15.3 0 014-10z"/></svg></div><h4>{$hadrianLang.store.oxFeat1Title}</h4><p>{$hadrianLang.store.oxFeat1Text}</p></div>
            <div class="hp-feature-card"><div class="feat-icon green"><svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="5" y="2" width="14" height="20" rx="2"/><line x1="12" y1="18" x2="12" y2="18"/></svg></div><h4>{$hadrianLang.store.oxFeat2Title}</h4><p>{$hadrianLang.store.oxFeat2Text}</p></div>
            <div class="hp-feature-card"><div class="feat-icon purple"><svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="4" width="18" height="18" rx="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg></div><h4>{$hadrianLang.store.oxFeat3Title}</h4><p>{$hadrianLang.store.oxFeat3Text}</p></div>
            <div class="hp-feature-card"><div class="feat-icon orange"><svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/></svg></div><h4>{$hadrianLang.store.oxFeat4Title}</h4><p>{$hadrianLang.store.oxFeat4Text}</p></div>
            <div class="hp-feature-card"><div class="feat-icon teal"><svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M17 21v-2a4 4 0 00-4-4H5a4 4 0 00-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 00-3-3.87"/><path d="M16 3.13a4 4 0 010 7.75"/></svg></div><h4>{$hadrianLang.store.oxFeat5Title}</h4><p>{$hadrianLang.store.oxFeat5Text}</p></div>
            <div class="hp-feature-card"><div class="feat-icon red"><svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="22 12 18 12 15 21 9 3 6 12 2 12"/></svg></div><h4>{$hadrianLang.store.oxFeat6Title}</h4><p>{$hadrianLang.store.oxFeat6Text}</p></div>
        </div>
    </section>

    {* 9. Testimonials scroll - decorative, kept verbatim *}
    <section class="hp-testimonials-scroll">
        <h2>{$hadrianLang.store.oxTestiTitle}</h2>
        <div class="hp-testimonials-strip">
            <div class="hp-testi-slide"><div class="stars">&starf;&starf;&starf;&starf;&starf;</div><div class="quote">Finally, professional email that just works. Setup took 5 minutes and our whole team was up and running with @ourcompany.com addresses the same day.</div><div class="author"><div class="author-avatar" style="background: url('https://i.pravatar.cc/96?u=katiewalsh') center/cover;">KW</div><div><div class="author-name">Katie Walsh</div><div class="author-role">Operations Manager, BrightCo</div></div></div></div>
            <div class="hp-testi-slide"><div class="stars">&starf;&starf;&starf;&starf;&starf;</div><div class="quote">The shared calendar feature transformed how we schedule. No more back-and-forth emails &mdash; everyone can see availability and book meetings instantly.</div><div class="author"><div class="author-avatar" style="background: url('https://i.pravatar.cc/96?u=tommitchell') center/cover;">TM</div><div><div class="author-name">Tom Mitchell</div><div class="author-role">Project Manager, Arcadia</div></div></div></div>
            <div class="hp-testi-slide"><div class="stars">&starf;&starf;&starf;&starf;&starf;</div><div class="quote">50 GB per mailbox means I never have to worry about storage. The spam filter is so good I forgot what junk mail looks like.</div><div class="author"><div class="author-avatar" style="background: url('https://i.pravatar.cc/96?u=juliaross') center/cover;">JR</div><div><div class="author-name">Julia Ross</div><div class="author-role">Freelance Consultant</div></div></div></div>
            <div class="hp-testi-slide"><div class="stars">&starf;&starf;&starf;&starf;&starf;</div><div class="quote">We moved 200+ mailboxes from another provider. The migration was seamless and we&rsquo;re saving $3,000/year. Support helped with every step.</div><div class="author"><div class="author-avatar" style="background: url('https://i.pravatar.cc/96?u=benharper') center/cover;">BH</div><div><div class="author-name">Ben Harper</div><div class="author-role">IT Director, TechVentures</div></div></div></div>
        </div>
        <div class="carousel-scroll-nav"><button class="carousel-arrow prev"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="15 18 9 12 15 6"/></svg></button><button class="carousel-arrow next"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="9 6 15 12 9 18"/></svg></button></div>
    </section>

    {* 10. FAQ *}
    <section class="hp-faq-section">
        <h2>{$hadrianLang.store.oxFaqTitle}</h2>
        <p class="faq-sub">{$hadrianLang.store.oxFaqSub}</p>
        <details class="hp-faq-item" open><summary>{$hadrianLang.store.oxFaqQ1}</summary><div class="faq-body">{$hadrianLang.store.oxFaqA1}</div></details>
        <details class="hp-faq-item"><summary>{$hadrianLang.store.oxFaqQ2}</summary><div class="faq-body">{$hadrianLang.store.oxFaqA2}</div></details>
        <details class="hp-faq-item"><summary>{$hadrianLang.store.oxFaqQ3}</summary><div class="faq-body">{$hadrianLang.store.oxFaqA3}</div></details>
        <details class="hp-faq-item"><summary>{$hadrianLang.store.oxFaqQ4}</summary><div class="faq-body">{$hadrianLang.store.oxFaqA4}</div></details>
    </section>

    {* 11. Final CTA *}
    <section class="hp-final-cta">
        <h2>{$hadrianLang.store.oxCtaTitle}</h2>
        <p>{$hadrianLang.store.oxCtaText}</p>
        <div>
            <a href="#pricing" class="btn">{$hadrianLang.store.oxCtaBtn}</a>
            <a href="#pricing" class="second-link">{$hadrianLang.store.oxCtaLink} &rsaquo;</a>
        </div>
    </section>
</div>

<div class="when-empty" style="text-align:center;padding:60px 24px;background:var(--color-surface);border:1px solid var(--color-border);border-radius:14px;">
    <div style="width:56px;height:56px;border-radius:50%;background:var(--color-bg);display:inline-flex;align-items:center;justify-content:center;margin-bottom:16px;color:var(--color-text-tertiary);">
        <svg viewBox="0 0 24 24" width="22" height="22" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><rect x="2" y="4" width="20" height="16" rx="2"/><path d="M22 7l-10 7L2 7"/></svg>
    </div>
    <p style="font-size:17px;font-weight:600;color:var(--color-text-primary);margin:0 0 6px;">{$hadrianLang.store.oxEmptyTitle}</p>
    <p style="font-size:14px;color:var(--color-text-secondary);margin:0 0 20px;max-width:380px;margin-left:auto;margin-right:auto;line-height:1.5;">{$hadrianLang.store.oxEmptyText}</p>
    <a href="{$WEB_ROOT}/" class="btn-primary">{$hadrianLang.store.oxEmptyHome}</a>
</div>

{literal}
<script>
(function () {
    var toggle = document.querySelector('.hp-pricing-toggle-section .hp-billing-toggle');
    if (!toggle) return;
    toggle.querySelectorAll('button[data-ox-cycle]').forEach(function (btn) {
        btn.addEventListener('click', function () {
            toggle.querySelectorAll('button').forEach(function (b) { b.classList.remove('active'); });
            btn.classList.add('active');
            var cycle = btn.getAttribute('data-ox-cycle');
            document.querySelectorAll('.hp-pricing-toggle-section [data-monthly][data-annual]').forEach(function (el) {
                var val = el.getAttribute('data-' + cycle);
                if (val) el.textContent = val;
            });
        });
    });
})();
</script>
{/literal}
