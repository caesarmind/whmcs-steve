{* Store landing - SocialBee.
   Ported from apple-client-area/socialbee.html (Public/Marketing landing).
   header.tpl/footer.tpl provide the shell + .content-area, so we emit only the
   inner content (page-header + when-full marketing + when-empty offline state).

   Real pricing: the WHMCS SocialBee store controller assigns $planComparisonData
   + $planFeatures - same contract as six/store/socialbee/index.tpl. The mockup's
   two-column comparison table keeps its exact feature rows; we wire the plan
   header names, prices, and order buttons to the real plans (captured by
   position), falling back to the mockup values otherwise. Static copy is
   tokenized into the hadrianLang store group (sb-prefixed keys); decorative
   dashboard/illustration blocks and testimonials are kept verbatim.

   The mockup's fictional "Latest from SocialBee" announcement cards are omitted:
   they invent product-news with category chips, have no real data source, and
   the theme avoids fabricated announcement labels. *}

{assign var=_sbCount value=0}
{if isset($planComparisonData)}{assign var=_sbCount value=$planComparisonData|@count}{/if}
{assign var=_sbI value=0}
{if $_sbCount > 0}
    {foreach $planComparisonData as $_sbPlan}
        {if $_sbI == 0}{assign var=_sb1 value=$_sbPlan}{elseif $_sbI == 1}{assign var=_sb2 value=$_sbPlan}{/if}
        {assign var=_sbI value=$_sbI+1}
    {/foreach}
{/if}
{assign var=_sbFrom value='$329.00'}
{if isset($_sb1) && !$_sb1->isFree()}{assign var=_sbFrom value=$_sb1->pricing()->first()->toPrefixedString()}{/if}
{if $_sbCount > 0 || (isset($inPreview) && $inPreview)}
    {assign var=storeIsEmpty value='full'}
{else}
    {assign var=storeIsEmpty value='empty'}
{/if}

<header class="page-header">
    <p class="page-eyebrow">{$hadrianLang.store.sbEyebrow}</p>
    <h1>{$hadrianLang.store.sbPageTitle}</h1>
    <p class="page-subtitle">{$hadrianLang.store.sbPageSubtitle}</p>
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

    {* 1. Hero centered *}
    <section class="hp-hero" style="padding: 80px 22px 20px; background: transparent;">
        <div class="hp-eyebrow">{$hadrianLang.store.sbHeroEyebrow}</div>
        <h1 style="font-size: 64px; max-width: 900px; margin-left: auto; margin-right: auto;">{$hadrianLang.store.sbHeroTitle}</h1>
        <p class="hp-subhead" style="font-size: 21px; max-width: 640px;">{$hadrianLang.store.sbHeroText}</p>
        <div class="hp-cta-row">
            <a href="#pricing" class="hp-buy-btn">{$hadrianLang.store.sbHeroCta}</a>
            <span style="font-size: 17px; font-weight: 600; color: var(--color-text-primary);">{$hadrianLang.store.sbFrom} {$_sbFrom}<span style="font-size: 14px; font-weight: 400; color: #86868b; margin-left: 2px;">/yr</span></span>
        </div>
    </section>

    {* Dashboard mock under hero (decorative) *}
    <section style="padding: 48px 22px 72px; max-width: 1024px; margin: 0 auto;">
        <div style="background: #fff; border: 1px solid #e8e8ed; border-radius: 24px; padding: 14px; box-shadow: 0 24px 60px rgba(0,0,0,0.08);">
            <div style="display: flex; gap: 6px; margin-bottom: 12px; padding: 4px 10px;">
                <span style="width: 9px; height: 9px; background: #ff453a; border-radius: 50%;"></span>
                <span style="width: 9px; height: 9px; background: #ff9f0a; border-radius: 50%;"></span>
                <span style="width: 9px; height: 9px; background: #30d158; border-radius: 50%;"></span>
            </div>
            <div style="display: grid; grid-template-columns: 180px 1fr 260px; gap: 12px; min-height: 380px;">
                <div style="background: #f5f5f7; border-radius: 14px; padding: 16px;">
                    <div style="display: flex; flex-direction: column; gap: 6px;">
                        <div style="padding: 10px; background: #fff; border-radius: 10px; display: flex; align-items: center; gap: 8px; color: var(--color-accent); font-weight: 600; font-size: 12px;"><svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="3" width="7" height="7"/><rect x="14" y="3" width="7" height="7"/><rect x="3" y="14" width="7" height="7"/><rect x="14" y="14" width="7" height="7"/></svg>Dashboard</div>
                        <div style="padding: 10px; display: flex; align-items: center; gap: 8px; color: #1d1d1f; font-size: 12px;"><svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="4" width="18" height="18" rx="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/></svg>Calendar</div>
                        <div style="padding: 10px; display: flex; align-items: center; gap: 8px; color: #1d1d1f; font-size: 12px;"><svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="23 6 13.5 15.5 8.5 10.5 1 18"/></svg>Analytics</div>
                        <div style="padding: 10px; display: flex; align-items: center; gap: 8px; color: #1d1d1f; font-size: 12px;"><svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M17 21v-2a4 4 0 00-4-4H5a4 4 0 00-4 4v2"/><circle cx="9" cy="7" r="4"/></svg>Team</div>
                    </div>
                </div>
                <div style="background: linear-gradient(135deg, #eaf4ff, #dbeafe); border-radius: 14px; padding: 16px;">
                    <div style="display: flex; align-items: center; justify-content: space-between; margin-bottom: 12px;">
                        <div style="font-size: 13px; font-weight: 600; color: #1d1d1f;">November 2026</div>
                        <div style="display: flex; gap: 4px;"><span style="padding: 4px 10px; background: #fff; border-radius: 6px; font-size: 10px;">Week</span><span style="padding: 4px 10px; background: #0071e3; color: #fff; border-radius: 6px; font-size: 10px;">Month</span></div>
                    </div>
                    <div style="display: grid; grid-template-columns: repeat(7, 1fr); gap: 6px;">
                        <div style="background: #fff; border-radius: 6px; padding: 8px; min-height: 44px;"><div style="font-size: 9px; color: #86868b;">25</div></div>
                        <div style="background: #fff; border-radius: 6px; padding: 8px; min-height: 44px;"><div style="font-size: 9px; color: #86868b;">26</div><div style="margin-top: 2px; height: 3px; background: #0071e3; border-radius: 2px;"></div></div>
                        <div style="background: #fff; border-radius: 6px; padding: 8px; min-height: 44px;"><div style="font-size: 9px; color: #86868b;">27</div><div style="margin-top: 2px; height: 3px; background: #bf5af2; border-radius: 2px;"></div></div>
                        <div style="background: #fff; border-radius: 6px; padding: 8px; min-height: 44px;"><div style="font-size: 9px; color: #86868b;">28</div></div>
                        <div style="background: #fff; border-radius: 6px; padding: 8px; min-height: 44px;"><div style="font-size: 9px; color: #86868b;">29</div><div style="margin-top: 2px; height: 3px; background: #30d158; border-radius: 2px;"></div></div>
                        <div style="background: #fff; border-radius: 6px; padding: 8px; min-height: 44px;"><div style="font-size: 9px; color: #86868b;">30</div></div>
                        <div style="background: #fff; border-radius: 6px; padding: 8px; min-height: 44px;"><div style="font-size: 9px; color: #86868b;">31</div></div>
                        <div style="background: #fff; border-radius: 6px; padding: 8px; min-height: 44px; border: 2px solid #0071e3;"><div style="font-size: 9px; color: var(--color-accent); font-weight: 700;">1</div><div style="margin-top: 2px; height: 3px; background: #0071e3; border-radius: 2px;"></div><div style="margin-top: 2px; height: 3px; background: #ff9f0a; border-radius: 2px;"></div></div>
                        <div style="background: #fff; border-radius: 6px; padding: 8px; min-height: 44px;"><div style="font-size: 9px; color: #1d1d1f;">2</div><div style="margin-top: 2px; height: 3px; background: #bf5af2; border-radius: 2px;"></div></div>
                        <div style="background: #fff; border-radius: 6px; padding: 8px; min-height: 44px;"><div style="font-size: 9px; color: #1d1d1f;">3</div></div>
                        <div style="background: #fff; border-radius: 6px; padding: 8px; min-height: 44px;"><div style="font-size: 9px; color: #1d1d1f;">4</div><div style="margin-top: 2px; height: 3px; background: #30d158; border-radius: 2px;"></div></div>
                        <div style="background: #fff; border-radius: 6px; padding: 8px; min-height: 44px;"><div style="font-size: 9px; color: #1d1d1f;">5</div></div>
                        <div style="background: #fff; border-radius: 6px; padding: 8px; min-height: 44px;"><div style="font-size: 9px; color: #1d1d1f;">6</div><div style="margin-top: 2px; height: 3px; background: #0071e3; border-radius: 2px;"></div></div>
                        <div style="background: #fff; border-radius: 6px; padding: 8px; min-height: 44px;"><div style="font-size: 9px; color: #1d1d1f;">7</div></div>
                    </div>
                </div>
                <div style="background: #f5f5f7; border-radius: 14px; padding: 16px;">
                    <div style="font-size: 11px; font-weight: 600; color: #1d1d1f; margin-bottom: 12px;">Upcoming posts</div>
                    <div style="display: flex; flex-direction: column; gap: 8px;">
                        <div style="background: #fff; padding: 10px; border-radius: 10px;"><div style="display: flex; align-items: center; gap: 6px; margin-bottom: 4px;"><div style="width: 16px; height: 16px; background: #0866ff; border-radius: 4px;"></div><span style="font-size: 9px; color: #86868b;">Facebook &middot; 2h</span></div><div style="font-size: 10px; color: #1d1d1f;">New product launch &#128640;</div></div>
                        <div style="background: #fff; padding: 10px; border-radius: 10px;"><div style="display: flex; align-items: center; gap: 6px; margin-bottom: 4px;"><div style="width: 16px; height: 16px; background: linear-gradient(135deg, #833AB4, #FD1D1D); border-radius: 4px;"></div><span style="font-size: 9px; color: #86868b;">Instagram &middot; 5h</span></div><div style="font-size: 10px; color: #1d1d1f;">Behind the scenes &#127916;</div></div>
                        <div style="background: #fff; padding: 10px; border-radius: 10px;"><div style="display: flex; align-items: center; gap: 6px; margin-bottom: 4px;"><div style="width: 16px; height: 16px; background: #0a66c2; border-radius: 4px;"></div><span style="font-size: 9px; color: #86868b;">LinkedIn &middot; 1d</span></div><div style="font-size: 10px; color: #1d1d1f;">Industry insights &#128202;</div></div>
                    </div>
                </div>
            </div>
        </div>
    </section>

    {* 2. Alt row intro *}
    <div class="hp-alternating">
        <div class="hp-alt-row">
            <div class="hp-alt-text">
                <div class="hp-eyebrow">{$hadrianLang.store.sbAllinoneEyebrow}</div>
                <h3>{$hadrianLang.store.sbAllinoneTitle}</h3>
                <p>{$hadrianLang.store.sbAllinoneP1}</p>
                <p style="margin-top: 12px;">{$hadrianLang.store.sbAllinoneP2}</p>
                <p style="margin-top: 12px;">{$hadrianLang.store.sbAllinoneP3}</p>
                <div class="hp-cta-row" style="margin-top: 20px; display: flex; align-items: center; gap: 20px; flex-wrap: wrap;">
                    <a href="#pricing" class="hp-buy-btn">{$hadrianLang.store.sbLearnMore}</a>
                    <span style="font-size: 17px; font-weight: 600; color: var(--color-text-primary);">{$hadrianLang.store.sbFrom} {$_sbFrom}<span style="font-size: 14px; font-weight: 400; color: #86868b; margin-left: 2px;">/yr</span></span>
                </div>
            </div>
            <div class="hp-alt-visual">
                <div class="visual-box" style="background: #f5f5f7; padding: 24px;">
                    <div style="width: 100%; max-width: 300px; background: #fff; border-radius: 14px; padding: 14px;">
                        <div style="font-size: 11px; font-weight: 600; color: #1d1d1f; margin-bottom: 10px;">Compose</div>
                        <div style="padding: 10px; background: #f5f5f7; border-radius: 10px; min-height: 60px; font-size: 11px; color: #1d1d1f;">Launching our new product next week &#128640; Stay tuned for&hellip;</div>
                        <div style="display: flex; gap: 6px; margin-top: 10px;">
                            <div style="width: 26px; height: 26px; background: #0866ff; border-radius: 6px;"></div>
                            <div style="width: 26px; height: 26px; background: linear-gradient(135deg, #833AB4, #FD1D1D); border-radius: 6px;"></div>
                            <div style="width: 26px; height: 26px; background: #1da1f2; border-radius: 6px;"></div>
                            <div style="width: 26px; height: 26px; background: #0a66c2; border-radius: 6px;"></div>
                            <button style="margin-left: auto; padding: 6px 12px; background: #0071e3; color: #fff; border: 0; border-radius: 6px; font-size: 11px; font-weight: 600;">Schedule</button>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    {* Values section *}
    <section class="hp-values-section" style="padding: 56px 22px;">
        <h2 style="font-size: 48px;">{$hadrianLang.store.sbValuesTitle}</h2>
        <div class="hp-values-grid">
            <div class="hp-value-item">
                <div class="value-icon"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5"><path d="M21 15a2 2 0 01-2 2H7l-4 4V5a2 2 0 012-2h14a2 2 0 012 2z"/></svg></div>
                <h3>{$hadrianLang.store.sbValue1Title}</h3>
                <p>{$hadrianLang.store.sbValue1Text}</p>
            </div>
            <div class="hp-value-item">
                <div class="value-icon"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5"><circle cx="12" cy="12" r="3"/><path d="M19.4 15a1.65 1.65 0 00.33 1.82l.06.06a2 2 0 01-2.83 2.83l-.06-.06a1.65 1.65 0 00-1.82-.33 1.65 1.65 0 00-1 1.51V21a2 2 0 01-4 0v-.09A1.65 1.65 0 009 19.4a1.65 1.65 0 00-1.82.33l-.06.06a2 2 0 01-2.83-2.83l.06-.06a1.65 1.65 0 00.33-1.82 1.65 1.65 0 00-1.51-1H3a2 2 0 010-4h.09A1.65 1.65 0 004.6 9a1.65 1.65 0 00-.33-1.82l-.06-.06a2 2 0 012.83-2.83l.06.06a1.65 1.65 0 001.82.33H9a1.65 1.65 0 001-1.51V3a2 2 0 014 0v.09a1.65 1.65 0 001 1.51 1.65 1.65 0 001.82-.33l.06-.06a2 2 0 012.83 2.83l-.06.06a1.65 1.65 0 00-.33 1.82V9a1.65 1.65 0 001.51 1H21a2 2 0 010 4h-.09a1.65 1.65 0 00-1.51 1z"/></svg></div>
                <h3>{$hadrianLang.store.sbValue2Title}</h3>
                <p>{$hadrianLang.store.sbValue2Text}</p>
            </div>
            <div class="hp-value-item">
                <div class="value-icon"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5"><path d="M17 21v-2a4 4 0 00-4-4H5a4 4 0 00-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 00-3-3.87"/><path d="M16 3.13a4 4 0 010 7.75"/></svg></div>
                <h3>{$hadrianLang.store.sbValue3Title}</h3>
                <p>{$hadrianLang.store.sbValue3Text}</p>
            </div>
        </div>
    </section>

    {* 3. Feature tab-switcher (hp-tab-switcher - inline styled; tabs decorative as in the mockup) *}
    <div style="background: var(--color-surface-secondary);">
    <section class="hp-tab-switcher" style="padding: 72px 22px; max-width: 1024px; margin: 0 auto;">
        <div style="text-align: center; color: var(--color-accent); font-size: 13px; font-weight: 600; text-transform: uppercase; letter-spacing: 0.05em; margin-bottom: 8px;">{$hadrianLang.store.sbWhyEyebrow}</div>
        <h2 style="text-align: center; font-size: 48px; font-weight: 600; letter-spacing: -0.02em; margin: 0 0 32px;">{$hadrianLang.store.sbWhyTitle}</h2>
        <div style="display: flex; justify-content: center; gap: 4px; margin-bottom: 40px; flex-wrap: wrap;">
            <button style="padding: 10px 20px; background: #fff; color: #1d1d1f; border: 1px solid #e8e8ed; border-radius: 999px; font-size: 13px; font-weight: 600; cursor: pointer; box-shadow: 0 2px 6px rgba(0,0,0,0.04);">{$hadrianLang.store.sbTabCreate}</button>
            <button style="padding: 10px 20px; background: transparent; color: #6e6e73; border: 0; border-radius: 999px; font-size: 13px; font-weight: 500; cursor: pointer;">{$hadrianLang.store.sbTabSchedule}</button>
            <button style="padding: 10px 20px; background: transparent; color: #6e6e73; border: 0; border-radius: 999px; font-size: 13px; font-weight: 500; cursor: pointer;">{$hadrianLang.store.sbTabEngage}</button>
            <button style="padding: 10px 20px; background: transparent; color: #6e6e73; border: 0; border-radius: 999px; font-size: 13px; font-weight: 500; cursor: pointer;">{$hadrianLang.store.sbTabCollaborate}</button>
            <button style="padding: 10px 20px; background: transparent; color: #6e6e73; border: 0; border-radius: 999px; font-size: 13px; font-weight: 500; cursor: pointer;">{$hadrianLang.store.sbTabAnalyze}</button>
        </div>
        <div style="display: grid; grid-template-columns: repeat(3, 1fr); gap: 20px;">
            <div style="background: #fff; border-radius: 18px; padding: 28px 22px;"><div style="width: 56px; height: 56px; background: linear-gradient(135deg, #0071e3, #5ac8fa); border-radius: 14px; display: flex; align-items: center; justify-content: center; margin-bottom: 16px;"><svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="#fff" stroke-width="2"><rect x="3" y="3" width="18" height="18" rx="2"/><circle cx="8.5" cy="8.5" r="1.5"/><polyline points="21 15 16 10 5 21"/></svg></div><h4 style="font-size: 17px; font-weight: 600; color: #1d1d1f; margin: 0 0 8px;">{$hadrianLang.store.sbF1Title}</h4><p style="font-size: 14px; color: #6e6e73; margin: 0;">{$hadrianLang.store.sbF1Text}</p></div>
            <div style="background: #fff; border-radius: 18px; padding: 28px 22px;"><div style="width: 56px; height: 56px; background: linear-gradient(135deg, #bf5af2, #c678ff); border-radius: 14px; display: flex; align-items: center; justify-content: center; margin-bottom: 16px;"><svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="#fff" stroke-width="2"><path d="M12 2l2 5 5 2-5 2-2 5-2-5-5-2 5-2z"/></svg></div><h4 style="font-size: 17px; font-weight: 600; color: #1d1d1f; margin: 0 0 8px;">{$hadrianLang.store.sbF2Title}</h4><p style="font-size: 14px; color: #6e6e73; margin: 0;">{$hadrianLang.store.sbF2Text}</p></div>
            <div style="background: #fff; border-radius: 18px; padding: 28px 22px;"><div style="width: 56px; height: 56px; background: linear-gradient(135deg, #ff9f0a, #ffb843); border-radius: 14px; display: flex; align-items: center; justify-content: center; margin-bottom: 16px;"><svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="#fff" stroke-width="2"><polyline points="23 6 13.5 15.5 8.5 10.5 1 18"/></svg></div><h4 style="font-size: 17px; font-weight: 600; color: #1d1d1f; margin: 0 0 8px;">{$hadrianLang.store.sbF3Title}</h4><p style="font-size: 14px; color: #6e6e73; margin: 0;">{$hadrianLang.store.sbF3Text}</p></div>
            <div style="background: #fff; border-radius: 18px; padding: 28px 22px;"><div style="width: 56px; height: 56px; background: linear-gradient(135deg, #30d158, #5cdb79); border-radius: 14px; display: flex; align-items: center; justify-content: center; margin-bottom: 16px;"><svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="#fff" stroke-width="2"><path d="M17 21v-2a4 4 0 00-4-4H5a4 4 0 00-4 4v2"/><circle cx="9" cy="7" r="4"/></svg></div><h4 style="font-size: 17px; font-weight: 600; color: #1d1d1f; margin: 0 0 8px;">{$hadrianLang.store.sbF4Title}</h4><p style="font-size: 14px; color: #6e6e73; margin: 0;">{$hadrianLang.store.sbF4Text}</p></div>
            <div style="background: #fff; border-radius: 18px; padding: 28px 22px;"><div style="width: 56px; height: 56px; background: linear-gradient(135deg, #5ac8fa, #9ad4ff); border-radius: 14px; display: flex; align-items: center; justify-content: center; margin-bottom: 16px;"><svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="#fff" stroke-width="2"><path d="M22 11.08V12a10 10 0 11-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg></div><h4 style="font-size: 17px; font-weight: 600; color: #1d1d1f; margin: 0 0 8px;">{$hadrianLang.store.sbF5Title}</h4><p style="font-size: 14px; color: #6e6e73; margin: 0;">{$hadrianLang.store.sbF5Text}</p></div>
            <div style="background: #fff; border-radius: 18px; padding: 28px 22px;"><div style="width: 56px; height: 56px; background: linear-gradient(135deg, #ff453a, #ff7a71); border-radius: 14px; display: flex; align-items: center; justify-content: center; margin-bottom: 16px;"><svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="#fff" stroke-width="2"><path d="M21 15a2 2 0 01-2 2H7l-4 4V5a2 2 0 012-2h14a2 2 0 012 2z"/></svg></div><h4 style="font-size: 17px; font-weight: 600; color: #1d1d1f; margin: 0 0 8px;">{$hadrianLang.store.sbF6Title}</h4><p style="font-size: 14px; color: #6e6e73; margin: 0;">{$hadrianLang.store.sbF6Text}</p></div>
        </div>
        <div style="text-align: center; margin-top: 32px;">
            <a href="#pricing" class="hp-buy-btn">{$hadrianLang.store.sbViewPlans}</a>
        </div>
    </section>
    </div>

    {* 4. Pricing comparison table - feature rows static; plan headers + buttons wired to real plans *}
    <div id="pricing" style="background: var(--color-surface-secondary);">
    <section class="hp-pricing-compare-table" style="padding: 72px 22px;">
        <div class="cmp-header">
            <div style="text-align: center; color: var(--color-accent); font-size: 13px; font-weight: 600; text-transform: uppercase; letter-spacing: 0.05em; margin-bottom: 8px;">{$hadrianLang.store.sbPricingEyebrow}</div>
            <h2>{$hadrianLang.store.sbPricingTitle}</h2>
            <p class="cmp-sub">{$hadrianLang.store.sbPricingSub}</p>
        </div>
        <div class="cmp-scroll">
            <table class="cmp-grid">
                <thead>
                    <tr>
                        <th class="cmp-corner" scope="col"><span class="sr-only">{$hadrianLang.store.sbFeatures}</span></th>
                        <th scope="col">
                            <div class="cmp-plan-name">{if isset($_sb1)}{$_sb1->name|escape}{else}Bronze{/if}</div>
                            <div class="cmp-plan-price">{if isset($_sb1) && !$_sb1->isFree()}{$_sb1->pricing()->first()->toPrefixedString()}{else}$329<span>/yr</span>{/if}</div>
                            <a href="{if isset($_sb1)}{$WEB_ROOT}/cart.php?a=add&amp;pid={$_sb1->id}{else}#pricing{/if}" class="cmp-plan-btn">{$hadrianLang.store.sbGetStarted}</a>
                        </th>
                        <th scope="col" class="cmp-featured-col">
                            <div class="cmp-plan-ribbon">{$hadrianLang.store.sbMostPopular}</div>
                            <div class="cmp-plan-name">{if isset($_sb2)}{$_sb2->name|escape}{else}Pro 50{/if}</div>
                            <div class="cmp-plan-price">{if isset($_sb2) && !$_sb2->isFree()}{$_sb2->pricing()->first()->toPrefixedString()}{else}$449<span>/yr</span>{/if}</div>
                            <a href="{if isset($_sb2)}{$WEB_ROOT}/cart.php?a=add&amp;pid={$_sb2->id}{else}#pricing{/if}" class="cmp-plan-btn primary">{$hadrianLang.store.sbGetStarted}</a>
                        </th>
                    </tr>
                </thead>
                <tbody>
                    <tr class="cmp-section-row" data-section="content"><th colspan="3" scope="colgroup"><button type="button" class="cmp-section-toggle" aria-expanded="true" aria-controls="cmp-group-content"><span class="chev" aria-hidden="true">&#9662;</span><span>{$hadrianLang.store.sbGrpContent}</span></button></th></tr>
                    <tr data-group="content"><th scope="row">{$hadrianLang.store.sbRowScheduling}</th><td><span class="cmp-check">&check;</span></td><td class="cmp-featured"><span class="cmp-check">&check;</span></td></tr>
                    <tr data-group="content"><th scope="row">{$hadrianLang.store.sbRowCategory}</th><td><span class="cmp-check">&check;</span></td><td class="cmp-featured"><span class="cmp-check">&check;</span></td></tr>
                    <tr data-group="content"><th scope="row">{$hadrianLang.store.sbRowAccounts}</th><td>5</td><td class="cmp-featured">50</td></tr>
                    <tr data-group="content"><th scope="row">{$hadrianLang.store.sbRowPosts}</th><td>1,000</td><td class="cmp-featured">5,000</td></tr>

                    <tr class="cmp-section-row" data-section="ai"><th colspan="3" scope="colgroup"><button type="button" class="cmp-section-toggle" aria-expanded="true" aria-controls="cmp-group-ai"><span class="chev" aria-hidden="true">&#9662;</span><span>{$hadrianLang.store.sbGrpAi}</span></button></th></tr>
                    <tr data-group="ai"><th scope="row">{$hadrianLang.store.sbRowAiGen}</th><td><span class="cmp-check">&check;</span></td><td class="cmp-featured"><span class="cmp-check">&check;</span></td></tr>
                    <tr data-group="ai"><th scope="row">{$hadrianLang.store.sbRowCanva}</th><td><span class="cmp-check">&check;</span></td><td class="cmp-featured"><span class="cmp-check">&check;</span></td></tr>
                    <tr data-group="ai"><th scope="row">{$hadrianLang.store.sbRowBranding}</th><td><span class="cmp-dash">&mdash;</span></td><td class="cmp-featured"><span class="cmp-check">&check;</span></td></tr>

                    <tr class="cmp-section-row" data-section="analytics"><th colspan="3" scope="colgroup"><button type="button" class="cmp-section-toggle" aria-expanded="true" aria-controls="cmp-group-analytics"><span class="chev" aria-hidden="true">&#9662;</span><span>{$hadrianLang.store.sbGrpAnalytics}</span></button></th></tr>
                    <tr data-group="analytics"><th scope="row">{$hadrianLang.store.sbRowAdvAnalytics}</th><td><span class="cmp-dash">&mdash;</span></td><td class="cmp-featured"><span class="cmp-check">&check;</span></td></tr>
                    <tr data-group="analytics"><th scope="row">{$hadrianLang.store.sbRowRss}</th><td><span class="cmp-dash">&mdash;</span></td><td class="cmp-featured"><span class="cmp-check">&check;</span></td></tr>
                    <tr data-group="analytics"><th scope="row">{$hadrianLang.store.sbRowUrl}</th><td><span class="cmp-check">&check;</span></td><td class="cmp-featured"><span class="cmp-check">&check;</span></td></tr>

                    <tr class="cmp-section-row" data-section="team"><th colspan="3" scope="colgroup"><button type="button" class="cmp-section-toggle" aria-expanded="true" aria-controls="cmp-group-team"><span class="chev" aria-hidden="true">&#9662;</span><span>{$hadrianLang.store.sbGrpTeam}</span></button></th></tr>
                    <tr data-group="team"><th scope="row">{$hadrianLang.store.sbRowTeam}</th><td>1</td><td class="cmp-featured">3</td></tr>
                    <tr data-group="team"><th scope="row">{$hadrianLang.store.sbRowApproval}</th><td><span class="cmp-dash">&mdash;</span></td><td class="cmp-featured"><span class="cmp-check">&check;</span></td></tr>
                    <tr data-group="team"><th scope="row">{$hadrianLang.store.sbRowPriority}</th><td><span class="cmp-dash">&mdash;</span></td><td class="cmp-featured"><span class="cmp-check">&check;</span></td></tr>
                </tbody>
            </table>
        </div>
    </section>
    </div>

    {* Star rating block *}
    <section class="hp-testi-reviews">
        <div class="big-stars">&starf;&starf;&starf;&starf;&starf;</div>
        <div class="rating-num">4.8</div>
        <div class="rating-of">{$hadrianLang.store.sbRatingOf}</div>
        <div class="review-sources">
            <div class="rev-src"><div class="stars">&starf;&starf;&starf;&starf;&starf;</div><div class="src-name">G2</div><div class="src-count">6,420 reviews</div></div>
            <div class="rev-src"><div class="stars">&starf;&starf;&starf;&starf;&starf;</div><div class="src-name">Trustpilot</div><div class="src-count">7,180 reviews</div></div>
            <div class="rev-src"><div class="stars">&starf;&starf;&starf;&starf;&starf;</div><div class="src-name">Capterra</div><div class="src-count">3,200 reviews</div></div>
            <div class="rev-src"><div class="stars">&starf;&starf;&starf;&starf;&starf;</div><div class="src-name">Product Hunt</div><div class="src-count">1,700 reviews</div></div>
        </div>
    </section>

    {* 5. Testimonials - decorative, kept verbatim *}
    <section class="hp-testi-masonry">
        <h2>{$hadrianLang.store.sbTestiTitle}</h2>
        <p class="hp-testi-masonry-sub">{$hadrianLang.store.sbTestiSub}</p>
        <div class="hp-testi-masonry-grid">
            <div class="hp-testi-tile"><div class="stars">&starf;&starf;&starf;&starf;&starf;</div><p class="quote">Getting set up was broadly effortless, and the success rests on the incredible service we subscribe to. Couldn&rsquo;t be happier with the switch.</p><div class="author"><div class="avatar" style="background-image:url('https://i.pravatar.cc/96?u=michaelsmith');"></div><div><div class="name">Michael Smith</div><div class="role">NextLabs</div></div></div></div>
            <div class="hp-testi-tile tall accent"><div class="stars">&starf;&starf;&starf;&starf;&starf;</div><p class="quote">Scheduling, social media, analytics &mdash; everything under one roof. The price point just makes sense for our agency, and we&rsquo;ve scaled from 3 clients to 18 without adding headcount. SocialBee pays for itself every month.</p><div class="author"><div class="avatar" style="background-image:url('https://i.pravatar.cc/96?u=robertjohanson');"></div><div><div class="name">Robert Johanson</div><div class="role">FreshStack</div></div></div></div>
            <div class="hp-testi-tile"><div class="stars">&starf;&starf;&starf;&starf;&starf;</div><p class="quote">Very helpful support. I&rsquo;m thoroughly impressed with the service. The standout feature for me is their outstanding customer support &mdash; quick, friendly, and incredibly helpful.</p><div class="author"><div class="avatar" style="background-image:url('https://i.pravatar.cc/96?u=elizawilliams');"></div><div><div class="name">Eliza Williams</div><div class="role">Studio34</div></div></div></div>
            <div class="hp-testi-tile dark"><div class="stars">&starf;&starf;&starf;&starf;&starf;</div><p class="quote">Happy for the switch. Switching was the best decision. Their scheduler saved my team hours every week.</p><div class="author"><div class="avatar" style="background-image:url('https://i.pravatar.cc/96?u=theresamiller');"></div><div><div class="name">Theresa Miller</div><div class="role">Brand Manager</div></div></div></div>
            <div class="hp-testi-tile"><div class="stars">&starf;&starf;&starf;&starf;&starf;</div><p class="quote">Easy to get started. The product has exceeded my expectations and saved me real time every single week.</p><div class="author"><div class="avatar" style="background-image:url('https://i.pravatar.cc/96?u=mariagarcia');"></div><div><div class="name">Maria Garcia</div><div class="role">PixelAgency</div></div></div></div>
            <div class="hp-testi-tile tall cream"><div class="stars">&starf;&starf;&starf;&starf;&starf;</div><p class="quote">Simply amazing. The quality, features, and value they offer have elevated my online presence. The Canva integration alone is worth the subscription.</p><div class="author"><div class="avatar" style="background-image:url('https://i.pravatar.cc/96?u=johntsi');"></div><div><div class="name">John Tsi</div><div class="role">Indie Creator</div></div></div></div>
        </div>
    </section>

    {* 6. FAQ *}
    <section class="hp-faq-section">
        <h2>{$hadrianLang.store.sbFaqTitle}</h2>
        <details class="hp-faq-item" open><summary>{$hadrianLang.store.sbFaqQ1}</summary><div class="faq-body">{$hadrianLang.store.sbFaqA1}</div></details>
        <details class="hp-faq-item"><summary>{$hadrianLang.store.sbFaqQ2}</summary><div class="faq-body">{$hadrianLang.store.sbFaqA2}</div></details>
        <details class="hp-faq-item"><summary>{$hadrianLang.store.sbFaqQ3}</summary><div class="faq-body">{$hadrianLang.store.sbFaqA3}</div></details>
        <details class="hp-faq-item"><summary>{$hadrianLang.store.sbFaqQ4}</summary><div class="faq-body">{$hadrianLang.store.sbFaqA4}</div></details>
    </section>

    {* 7. Split CTA *}
    <div class="hp-split-cta-wrapper" style="padding: 48px 22px;">
        <div class="hp-split-cta">
            <div class="cta-panel dark">
                <h3>{$hadrianLang.store.sbCtaDarkTitle}</h3>
                <p>{$hadrianLang.store.sbCtaDarkText}</p>
                <a href="#pricing" class="btn-primary-pill">{$hadrianLang.store.sbCtaDarkBtn}</a>
            </div>
            <div class="cta-panel light">
                <h3>{$hadrianLang.store.sbCtaLightTitle}</h3>
                <p>{$hadrianLang.store.sbCtaLightText}</p>
                <a href="{$WEB_ROOT}/contact.php" class="btn-outline-pill">{$hadrianLang.store.sbCtaLightBtn}</a>
            </div>
        </div>
    </div>
</div>

<div class="when-empty" style="text-align:center;padding:60px 24px;background:var(--color-surface);border:1px solid var(--color-border);border-radius:14px;">
    <div style="width:56px;height:56px;border-radius:50%;background:var(--color-bg);display:inline-flex;align-items:center;justify-content:center;margin-bottom:16px;color:var(--color-text-tertiary);">
        <svg viewBox="0 0 24 24" width="22" height="22" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"/></svg>
    </div>
    <p style="font-size:17px;font-weight:600;color:var(--color-text-primary);margin:0 0 6px;">{$hadrianLang.store.sbEmptyTitle}</p>
    <p style="font-size:14px;color:var(--color-text-secondary);margin:0 0 20px;max-width:380px;margin-left:auto;margin-right:auto;line-height:1.5;">{$hadrianLang.store.sbEmptyText}</p>
    <a href="{$WEB_ROOT}/" class="btn-primary">{$hadrianLang.store.sbEmptyHome}</a>
</div>

{literal}
<script>
(function () {
    document.querySelectorAll('.hp-pricing-compare-table .cmp-section-toggle').forEach(function (btn) {
        var row = btn.closest('.cmp-section-row');
        if (!row) return;
        var section = row.getAttribute('data-section');
        btn.addEventListener('click', function () {
            var expanded = btn.getAttribute('aria-expanded') !== 'false';
            btn.setAttribute('aria-expanded', expanded ? 'false' : 'true');
            document.querySelectorAll('.hp-pricing-compare-table tr[data-group="' + section + '"]').forEach(function (r) {
                r.style.display = expanded ? 'none' : '';
            });
        });
    });
})();
</script>
{/literal}
