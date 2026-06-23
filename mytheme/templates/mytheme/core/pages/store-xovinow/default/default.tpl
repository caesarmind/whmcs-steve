{* Store landing - XOVI NOW (all-in-one SEO &amp; online-marketing suite).
   Ported from apple-client-area/xovi-now.html (Public/Marketing landing).
   header.tpl/footer.tpl provide the shell + .content-area, so we emit only the
   inner content (no page-header: the page leads with its hero; then when-full
   marketing + when-empty offline state).

   Real pricing: the WHMCS XOVI NOW store controller assigns $plans (each
   $plan->id, ->features, ->isFree(), ->pricing()->first()->toPrefixedString(),
   ->is_featured) + $inPreview - same contract as six/store/xovinow/index.tpl.
   The mockup's two pricing cards (Starter/Professional) map 1:1 to the first
   two real plans, so we keep the exact card copy/features and wire each card's
   price + order button to the real plan (captured by position), capturing the
   first plan/price into $_xoFrom and the add-to-cart link into $_xoOrder for
   the hero/CTA mentions, falling back to the mockup values otherwise. Static
   copy is tokenized into the hadrianLang store group (xo-prefixed keys);
   decorative illustrations/testimonials/SVG logos are kept verbatim. *}

{assign var=_xoCount value=0}
{if isset($plans)}{assign var=_xoCount value=$plans|@count}{/if}
{assign var=_xoFrom value='$19.00'}
{assign var=_xoPid value=0}
{assign var=_xoI value=0}
{if $_xoCount > 0}
    {foreach $plans as $_xoPlan}
        {if $_xoI == 0}
            {assign var=_xoStarter value=$_xoPlan}
            {assign var=_xoPid value=$_xoPlan->id}
            {if !$inPreview && !$_xoPlan->isFree() && $_xoPlan->pricing()->first()}
                {assign var=_xoFrom value=$_xoPlan->pricing()->first()->toPrefixedString()}
            {/if}
        {elseif $_xoI == 1}
            {assign var=_xoPro value=$_xoPlan}
        {/if}
        {assign var=_xoI value=$_xoI+1}
    {/foreach}
{/if}
{if $_xoPid > 0}
    {assign var=_xoOrder value="`$WEB_ROOT`/cart.php?a=add&pid=`$_xoPid`"}
{else}
    {assign var=_xoOrder value="`$WEB_ROOT`/cart.php?gid=marketconnect"}
{/if}
{if $_xoCount > 0 || (isset($inPreview) && $inPreview)}
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

    {* 1. Hero Aurora (animated mesh gradient) *}
    <section class="hp-hero-aurora">
        <div class="aurora-layer aurora-1"></div>
        <div class="aurora-layer aurora-2"></div>
        <div class="aurora-layer aurora-3"></div>
        <div class="aurora-inner">
            <div class="hp-eyebrow">XOVI NOW</div>
            <h1>{$hadrianLang.store.xoHeroTitle}<br><span style="color: #64d2ff;">{$hadrianLang.store.xoHeroTitleAccent}</span></h1>
            <p>{$hadrianLang.store.xoHeroText}</p>
            <div class="hp-cta-row">
                <a href="{$_xoOrder|escape}" class="hp-buy-btn">{$hadrianLang.store.xoHeroCta}</a>
                <a href="#pricing">{$hadrianLang.store.xoLearnMore} &rsaquo;</a>
            </div>
        </div>
    </section>

    {* Logo Bar: SEO stack partners - decorative SVG kept verbatim *}
    <section class="hp-logo-bar">
        <div class="hp-logo-bar-inner">
            <span class="logo-item" title="WordPress"><svg viewBox="0 0 24 24" fill="currentColor"><path d="M12,2A10,10 0 0,0 2,12A10,10 0 0,0 12,22A10,10 0 0,0 22,12A10,10 0 0,0 12,2M3.009,12a9,9 0 0,1 5.067-8.092L3.788,8.341C3.289,9.459 3.009,10.696 3.009,12M18.069,11.546c0-1.112-.399-1.881-.741-2.48-.456-.741-.883-1.368-.883-2.109,0-.826.627-1.596 1.51-1.596.04,0 .078.005.116.007C16.472,3.901 14.34,3.009 12,3.009c-3.141,0-5.904,1.612-7.512,4.052.211.007.41.011.579.011.94,0 2.396-.114 2.396-.114.484-.028.541.684.057.741,0,0-.487.057-1.029.085l3.274,9.739 1.968-5.901-1.401-3.838c-.484-.028-.943-.085-.943-.085-.485-.029-.428-.769.057-.741,0,0 1.484.114 2.368.114.94,0 2.397-.114 2.397-.114.485-.028.542.684.057.741,0,0-.488.057-1.029.085l3.249,9.665.897-2.996C17.794,13.13 18.069,12.295 18.069,11.546M12.158,12.786L9.46,20.625c.806.237 1.657.366 2.54.366 1.047,0 2.051-.181 2.986-.51-.024-.038-.046-.079-.065-.124L12.158,12.786Z"/></svg></span>
            <span class="logo-item" title="Shopify"><svg viewBox="0 0 24 24" fill="currentColor"><path d="M17.28,4.21c0-.08-.07-.12-.13-.13c-.06,0-1.3-.02-1.3-.02s-1.03-1-1.13-1.1c-.1-.1-.29-.07-.37-.05c0,0-.2.06-.53.16c-.05-.17-.12-.37-.22-.58-.32-.62-.8-.94-1.37-.94h0c-.04,0-.08,0-.12,0c-.02-.02-.03-.04-.05-.06-.24-.26-.55-.39-.93-.38-.72.02-1.44.54-2.02,1.47-.41.65-.72,1.47-.81,2.11-.83.26-1.41.44-1.42.44-.42.13-.43.14-.49.53-.04.3-1.13,8.72-1.13,8.72L13.3,22l6.15-1.53S17.29,4.29,17.28,4.21M13.04,3.29c-.25.08-.54.17-.85.27c-.01-.43-.06-1.03-.27-1.55-.65.12-.99.77-1.17,1.49-.12.04-.23.07-.34.1.19-.89.58-1.83,1.23-1.83.16,0,.3.04.43.12.25.16.44.45.56.82.05.16.09.32.11.49c.08-.02.19-.05.3-.08v.17M11.21,2.22c-.11-.05-.24-.08-.38-.08-.12,0-.24.03-.35.08.13,0,.24,0,.35,0,.13,0,.25.01.38,0Z"/></svg></span>
            <span class="logo-item" title="Google Search Console"><svg viewBox="0 0 24 24" fill="currentColor"><path d="M12,2A10,10 0 0,0 2,12A10,10 0 0,0 12,22A10,10 0 0,0 22,12A10,10 0 0,0 12,2M12.19,4H12.2L14.75,6.54L12.41,8.88L9.87,6.34L12.19,4M7.66,8.54L10.2,11.08L7.86,13.42L5.32,10.88L7.66,8.54M12.41,13L14.95,15.54L10.54,20H10.53L9.72,20L9.71,15.74L12.41,13M15.66,11.5L18.2,14.04L15.86,16.38L13.32,13.84L15.66,11.5Z"/></svg></span>
            <span class="logo-item" title="Ahrefs"><svg viewBox="0 0 24 24" fill="currentColor"><circle cx="12" cy="12" r="9"/></svg></span>
            <span class="logo-item" title="SEMrush"><svg viewBox="0 0 24 24" fill="currentColor"><path d="M3,3h18v18H3V3m2,2v14h14V5H5Z"/></svg></span>
            <span class="logo-item" title="Moz"><svg viewBox="0 0 24 24" fill="currentColor"><path d="M12,2A10,10 0 1,0 22,12A10,10 0 0,0 12,2Z"/></svg></span>
        </div>
    </section>

    {* 2. 3-up tool cards *}
    <section class="hp-icon-grid" style="padding: 40px 22px 48px;">
        <div class="hp-icon-item">
            <div class="icon-circle blue"><svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg></div>
            <h4>{$hadrianLang.store.xoTool1Title}</h4>
            <p>{$hadrianLang.store.xoTool1Text}</p>
            <a href="#pricing" style="color: var(--color-accent); font-size: 13px; font-weight: 500; margin-top: 8px;">{$hadrianLang.store.xoLearnMore} &rsaquo;</a>
        </div>
        <div class="hp-icon-item">
            <div class="icon-circle green"><svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M22 11.08V12a10 10 0 11-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg></div>
            <h4>{$hadrianLang.store.xoTool2Title}</h4>
            <p>{$hadrianLang.store.xoTool2Text}</p>
            <a href="#pricing" style="color: var(--color-accent); font-size: 13px; font-weight: 500; margin-top: 8px;">{$hadrianLang.store.xoLearnMore} &rsaquo;</a>
        </div>
        <div class="hp-icon-item">
            <div class="icon-circle purple"><svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="23 6 13.5 15.5 8.5 10.5 1 18"/><polyline points="17 6 23 6 23 12"/></svg></div>
            <h4>{$hadrianLang.store.xoTool3Title}</h4>
            <p>{$hadrianLang.store.xoTool3Text}</p>
            <a href="#pricing" style="color: var(--color-accent); font-size: 13px; font-weight: 500; margin-top: 8px;">{$hadrianLang.store.xoLearnMore} &rsaquo;</a>
        </div>
    </section>

    {* 3. Alt rows *}
    <div class="hp-alternating">
        <div class="hp-alt-row">
            <div class="hp-alt-text">
                <div class="hp-eyebrow">{$hadrianLang.store.xoKwEyebrow}</div>
                <h3>{$hadrianLang.store.xoKwTitle}</h3>
                <p>{$hadrianLang.store.xoKwP1}</p>
                <p style="margin-top: 12px;">{$hadrianLang.store.xoKwP2}</p>
            </div>
            <div class="hp-alt-visual">
                <div class="visual-box" style="background: #f5f5f7; padding: 24px;">
                    <div style="width: 100%; max-width: 300px; background: #fff; border-radius: 14px; padding: 14px;">
                        <div style="font-size: 11px; font-weight: 600; color: #1d1d1f; margin-bottom: 10px;">Keyword research</div>
                        <div style="display: flex; flex-direction: column; gap: 8px;">
                            <div style="padding: 8px 10px; background: #f5f5f7; border-radius: 8px; display: flex; justify-content: space-between;"><span style="font-size: 11px; color: #1d1d1f;">cheap vps hosting</span><span style="font-size: 10px; color: #86868b;">18.4K /mo</span></div>
                            <div style="padding: 8px 10px; background: #e8f8ed; border-radius: 8px; display: flex; justify-content: space-between;"><span style="font-size: 11px; color: #1a7f37; font-weight: 600;">best cloud hosting 2026</span><span style="font-size: 10px; color: #1a7f37;">9.2K /mo</span></div>
                            <div style="padding: 8px 10px; background: #f5f5f7; border-radius: 8px; display: flex; justify-content: space-between;"><span style="font-size: 11px; color: #1d1d1f;">managed wordpress</span><span style="font-size: 10px; color: #86868b;">5.1K /mo</span></div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <div class="hp-alt-row reverse">
            <div class="hp-alt-text">
                <div class="hp-eyebrow">{$hadrianLang.store.xoAdvEyebrow}</div>
                <h3>{$hadrianLang.store.xoAdvTitle}</h3>
                <p>{$hadrianLang.store.xoAdvP1}</p>
            </div>
            <div class="hp-alt-visual">
                <div class="visual-box" style="background: #eaf4ff; padding: 24px;">
                    <div style="width: 100%; max-width: 300px; background: #fff; border-radius: 14px; padding: 14px;">
                        <div style="display: flex; align-items: center; gap: 8px; padding: 10px; background: #eaf4ff; border-radius: 10px; margin-bottom: 8px;">
                            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#0071e3" stroke-width="2"><path d="M12 2l2 5 5 2-5 2-2 5-2-5-5-2 5-2z"/></svg>
                            <span style="font-size: 12px; font-weight: 600; color: var(--color-accent);">AI Advisor</span>
                        </div>
                        <div style="font-size: 11px; color: #1d1d1f; line-height: 1.45;">&ldquo;Your homepage is missing H1 tags. Adding a clear H1 with your main keyword will likely boost rankings by 15% within 4 weeks.&rdquo;</div>
                    </div>
                </div>
            </div>
        </div>
        <div class="hp-alt-row">
            <div class="hp-alt-text">
                <div class="hp-eyebrow">{$hadrianLang.store.xoRankEyebrow}</div>
                <h3>{$hadrianLang.store.xoRankTitle}</h3>
                <p>{$hadrianLang.store.xoRankP1}</p>
            </div>
            <div class="hp-alt-visual">
                <div class="visual-box" style="background: #f5f5f7; padding: 24px;">
                    <div style="width: 100%; max-width: 300px; background: #fff; border-radius: 14px; padding: 14px;">
                        <div style="font-size: 11px; font-weight: 600; color: #1d1d1f; margin-bottom: 10px;">Rank tracker &mdash; 30d</div>
                        <svg viewBox="0 0 260 80" style="width: 100%; height: 80px;">
                            <defs><linearGradient id="xoviGrad" x1="0" y1="0" x2="0" y2="1"><stop offset="0%" stop-color="#0071e3" stop-opacity="0.3"/><stop offset="100%" stop-color="#0071e3" stop-opacity="0"/></linearGradient></defs>
                            <path d="M0,65 L30,55 L60,50 L90,40 L120,30 L150,22 L180,18 L210,14 L260,8 L260,80 L0,80 Z" fill="url(#xoviGrad)"/>
                            <path d="M0,65 L30,55 L60,50 L90,40 L120,30 L150,22 L180,18 L210,14 L260,8" fill="none" stroke="#0071e3" stroke-width="2"/>
                        </svg>
                    </div>
                </div>
            </div>
        </div>
    </div>

    {* 4. Feature Masonry - Other SEO Tools *}
    <section class="hp-feature-masonry" style="padding: 72px 22px;">
        <h2 style="font-size: 36px;">{$hadrianLang.store.xoMasonryTitle}</h2>
        <p class="feat-sub">{$hadrianLang.store.xoMasonrySub}</p>
        <div class="hp-masonry-grid">
            <div class="hp-masonry-card accent tall">
                <div class="m-icon"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg></div>
                <h4>{$hadrianLang.store.xoMason1Title}</h4>
                <p>{$hadrianLang.store.xoMason1Text}</p>
                <div class="m-visual"><svg viewBox="0 0 80 80" fill="none" stroke="currentColor" stroke-width="1.4"><rect x="10" y="14" width="60" height="52" rx="4"/><line x1="18" y1="28" x2="50" y2="28"/><line x1="18" y1="40" x2="44" y2="40"/><line x1="18" y1="52" x2="48" y2="52"/></svg></div>
            </div>
            <div class="hp-masonry-card">
                <div class="m-icon"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6"><polyline points="14 2 14 8 20 8"/><path d="M14 2H6a2 2 0 00-2 2v16a2 2 0 002 2h12a2 2 0 002-2V8z"/></svg></div>
                <h4>{$hadrianLang.store.xoMason2Title}</h4>
                <p>{$hadrianLang.store.xoMason2Text}</p>
            </div>
            <div class="hp-masonry-card dark">
                <div class="m-icon"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6"><path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"/><polyline points="22 6 12 13 2 6"/></svg></div>
                <h4>{$hadrianLang.store.xoMason3Title}</h4>
                <p>{$hadrianLang.store.xoMason3Text}</p>
            </div>
            <div class="hp-masonry-card cream">
                <div class="m-icon"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6"><line x1="12" y1="20" x2="12" y2="10"/><line x1="18" y1="20" x2="18" y2="4"/><line x1="6" y1="20" x2="6" y2="14"/><line x1="3" y1="20" x2="21" y2="20"/></svg></div>
                <h4>{$hadrianLang.store.xoMason4Title}</h4>
                <p>{$hadrianLang.store.xoMason4Text}</p>
            </div>
            <div class="hp-masonry-card dark tall">
                <div class="m-icon"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6"><path d="M12 2l2 5 5 2-5 2-2 5-2-5-5-2 5-2z"/></svg></div>
                <h4>{$hadrianLang.store.xoMason5Title}</h4>
                <p>{$hadrianLang.store.xoMason5Text}</p>
                <div class="m-visual"><svg viewBox="0 0 80 80" fill="none" stroke="currentColor" stroke-width="1.4"><path d="M40 12 L46 28 L62 28 L50 38 L56 54 L40 44 L24 54 L30 38 L18 28 L34 28 Z"/></svg></div>
            </div>
            <div class="hp-masonry-card">
                <div class="m-icon"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6"><polyline points="23 4 23 10 17 10"/><polyline points="1 20 1 14 7 14"/><path d="M3.51 9a9 9 0 0114.85-3.36L23 10"/></svg></div>
                <h4>{$hadrianLang.store.xoMason6Title}</h4>
                <p>{$hadrianLang.store.xoMason6Text}</p>
            </div>
        </div>
    </section>

    {* 5. Dashboard Screenshot Showcase *}
    <section class="hp-screenshot-showcase" style="padding: 72px 22px; max-width: 1024px; margin: 0 auto;">
        <div style="text-align: center; color: var(--color-accent); font-size: 13px; font-weight: 600; text-transform: uppercase; letter-spacing: 0.05em; margin-bottom: 8px;">{$hadrianLang.store.xoShowcaseEyebrow}</div>
        <h2 style="text-align: center; font-size: 48px; font-weight: 600; letter-spacing: -0.02em; margin: 0 0 12px;">{$hadrianLang.store.xoShowcaseTitle}</h2>
        <p style="text-align: center; color: #6e6e73; font-size: 17px; max-width: 700px; margin: 0 auto 48px;">{$hadrianLang.store.xoShowcaseText}</p>
        <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 32px;">
            <div style="background: #fff; border: 1px solid #e8e8ed; border-radius: 18px; padding: 14px; box-shadow: 0 8px 24px rgba(0,0,0,0.06); overflow: hidden;">
                <div style="display: flex; gap: 4px; margin-bottom: 10px;">
                    <span style="width: 7px; height: 7px; background: #ff453a; border-radius: 50%;"></span>
                    <span style="width: 7px; height: 7px; background: #ff9f0a; border-radius: 50%;"></span>
                    <span style="width: 7px; height: 7px; background: #30d158; border-radius: 50%;"></span>
                    <div style="flex: 1; margin-left: 8px; padding: 2px 8px; background: #f5f5f7; border-radius: 4px; font-size: 9px; color: #86868b;">xovi.now/dashboard</div>
                </div>
                <div style="background: linear-gradient(135deg, #eaf4ff, #dbeafe); border-radius: 10px; padding: 14px; min-height: 240px;">
                    <div style="display: flex; align-items: center; justify-content: space-between; margin-bottom: 10px;"><div style="font-size: 11px; font-weight: 600; color: #1d1d1f;">Dashboard</div><div style="font-size: 9px; color: #86868b;">Last 30 days</div></div>
                    <div style="display: grid; grid-template-columns: repeat(3, 1fr); gap: 6px; margin-bottom: 10px;">
                        <div style="background: #fff; padding: 8px; border-radius: 8px; text-align: center;"><div style="font-size: 14px; font-weight: 700; color: var(--color-accent);">342</div><div style="font-size: 8px; color: #86868b;">Keywords</div></div>
                        <div style="background: #fff; padding: 8px; border-radius: 8px; text-align: center;"><div style="font-size: 14px; font-weight: 700; color: #30d158;">+68%</div><div style="font-size: 8px; color: #86868b;">Traffic</div></div>
                        <div style="background: #fff; padding: 8px; border-radius: 8px; text-align: center;"><div style="font-size: 14px; font-weight: 700; color: #bf5af2;">82</div><div style="font-size: 8px; color: #86868b;">SEO Score</div></div>
                    </div>
                    <div style="background: #fff; border-radius: 8px; padding: 10px; margin-bottom: 8px;">
                        <div style="font-size: 9px; color: #86868b; margin-bottom: 4px;">Organic traffic</div>
                        <svg viewBox="0 0 240 50" style="width: 100%; height: 50px;">
                            <defs><linearGradient id="xoviDashGrad" x1="0" y1="0" x2="0" y2="1"><stop offset="0%" stop-color="#0071e3" stop-opacity="0.3"/><stop offset="100%" stop-color="#0071e3" stop-opacity="0"/></linearGradient></defs>
                            <path d="M0,40 L24,32 L48,36 L72,22 L96,28 L120,14 L144,18 L168,8 L192,12 L216,4 L240,6 L240,50 L0,50 Z" fill="url(#xoviDashGrad)"/>
                            <path d="M0,40 L24,32 L48,36 L72,22 L96,28 L120,14 L144,18 L168,8 L192,12 L216,4 L240,6" fill="none" stroke="#0071e3" stroke-width="1.5"/>
                        </svg>
                    </div>
                    <div style="background: #fff; border-radius: 8px; padding: 8px;">
                        <div style="font-size: 9px; color: #86868b; margin-bottom: 4px;">Top movers</div>
                        <div style="display: flex; align-items: center; justify-content: space-between; padding: 3px 0;"><span style="font-size: 10px; color: #1d1d1f;">cloud hosting deals</span><span style="font-size: 10px; color: #30d158; font-weight: 600;">#3 &uarr;</span></div>
                        <div style="display: flex; align-items: center; justify-content: space-between; padding: 3px 0;"><span style="font-size: 10px; color: #1d1d1f;">vps best 2026</span><span style="font-size: 10px; color: #30d158; font-weight: 600;">#7 &uarr;</span></div>
                    </div>
                </div>
                <div style="text-align: center; margin-top: 10px; font-size: 11px; color: #86868b;">{$hadrianLang.store.xoShowcaseCap1}</div>
            </div>
            <div style="background: #fff; border: 1px solid #e8e8ed; border-radius: 18px; padding: 14px; box-shadow: 0 8px 24px rgba(0,0,0,0.06);">
                <div style="display: flex; gap: 4px; margin-bottom: 10px;">
                    <span style="width: 7px; height: 7px; background: #ff453a; border-radius: 50%;"></span>
                    <span style="width: 7px; height: 7px; background: #ff9f0a; border-radius: 50%;"></span>
                    <span style="width: 7px; height: 7px; background: #30d158; border-radius: 50%;"></span>
                    <div style="flex: 1; margin-left: 8px; padding: 2px 8px; background: #f5f5f7; border-radius: 4px; font-size: 9px; color: #86868b;">xovi.now/advisor</div>
                </div>
                <div style="background: linear-gradient(135deg, #faf0ff, #f0dbff); border-radius: 10px; padding: 14px; min-height: 240px;">
                    <div style="display: flex; align-items: center; justify-content: space-between; margin-bottom: 10px;"><div style="font-size: 11px; font-weight: 600; color: #1d1d1f;">SEO Advisor</div><div style="font-size: 9px; color: #86868b;">12 tasks &middot; 4 done</div></div>
                    <div style="display: flex; flex-direction: column; gap: 6px;">
                        <div style="background: #fff; border-radius: 8px; padding: 8px; display: flex; align-items: center; gap: 6px;">
                            <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="#30d158" stroke-width="2.5"><polyline points="20 6 9 17 4 12"/></svg>
                            <span style="font-size: 10px; color: #1d1d1f;">Add meta descriptions</span>
                            <span style="margin-left: auto; font-size: 9px; color: #30d158;">+4 pts</span>
                        </div>
                        <div style="background: #fff; border-radius: 8px; padding: 8px; display: flex; align-items: center; gap: 6px;">
                            <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="#ff9f0a" stroke-width="2"><circle cx="12" cy="12" r="10"/></svg>
                            <span style="font-size: 10px; color: #1d1d1f;">Compress hero images</span>
                            <span style="margin-left: auto; font-size: 9px; color: #86868b;">2.4 MB</span>
                        </div>
                        <div style="background: #fff; border-radius: 8px; padding: 8px; display: flex; align-items: center; gap: 6px;">
                            <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="#ff9f0a" stroke-width="2"><circle cx="12" cy="12" r="10"/></svg>
                            <span style="font-size: 10px; color: #1d1d1f;">Fix broken internal links</span>
                            <span style="margin-left: auto; font-size: 9px; color: #ff9f0a;">7 found</span>
                        </div>
                        <div style="background: #fff; border-radius: 8px; padding: 8px; display: flex; align-items: center; gap: 6px;">
                            <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="#ff9f0a" stroke-width="2"><circle cx="12" cy="12" r="10"/></svg>
                            <span style="font-size: 10px; color: #1d1d1f;">Improve page load speed</span>
                            <span style="margin-left: auto; font-size: 9px; color: #86868b;">1.2s</span>
                        </div>
                        <div style="background: #fff; border-radius: 8px; padding: 8px; display: flex; align-items: center; gap: 6px;">
                            <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="#30d158" stroke-width="2.5"><polyline points="20 6 9 17 4 12"/></svg>
                            <span style="font-size: 10px; color: #1d1d1f;">Add structured data (schema.org)</span>
                            <span style="margin-left: auto; font-size: 9px; color: #30d158;">+6 pts</span>
                        </div>
                    </div>
                </div>
                <div style="text-align: center; margin-top: 10px; font-size: 11px; color: #86868b;">{$hadrianLang.store.xoShowcaseCap2}</div>
            </div>
        </div>
    </section>

    {* 6. Pricing - mockup's Starter/Professional cards with price + order wired to real plans *}
    <section class="hp-pricing-section" id="pricing" style="padding: 48px 22px 72px;">
        <div style="text-align: center; color: var(--color-accent); font-size: 13px; font-weight: 600; text-transform: uppercase; letter-spacing: 0.05em; margin-bottom: 8px;">{$hadrianLang.store.xoPricingEyebrow}</div>
        <h2 style="text-align: center;">{$hadrianLang.store.xoPricingTitle}</h2>
        <div class="hp-pricing-grid" style="grid-template-columns: repeat(2, 1fr); max-width: 760px; margin: 40px auto 0;">
            <div class="hp-price-card dim">
                <div class="label">{if isset($_xoStarter)}{$_xoStarter->name|escape}{else}Starter{/if}</div>
                <h3>{$hadrianLang.store.xoStarterTagline}</h3>
                <div class="price-row">{if isset($_xoStarter)}{if $_xoStarter->isFree()}<span class="price">{$hadrianLang.store.xoFree}</span>{else}<span class="price">{$_xoStarter->pricing()->first()->toPrefixedString()}</span>{/if}{else}<span class="price">$19.00</span><span class="per">/mo</span>{/if}</div>
                <ul>
                    <li>{$hadrianLang.store.xoStarterF1}</li>
                    <li>{$hadrianLang.store.xoStarterF2}</li>
                    <li>{$hadrianLang.store.xoStarterF3}</li>
                    <li>{$hadrianLang.store.xoStarterF4}</li>
                    <li>{$hadrianLang.store.xoStarterF5}</li>
                    <li>{$hadrianLang.store.xoStarterF6}</li>
                    <li>{$hadrianLang.store.xoStarterF7}</li>
                    <li>{$hadrianLang.store.xoStarterF8}</li>
                    <li>{$hadrianLang.store.xoStarterF9}</li>
                </ul>
                <a class="buy" href="{if isset($_xoStarter)}{$WEB_ROOT}/cart.php?a=add&amp;pid={$_xoStarter->id}{else}{$_xoOrder|escape}{/if}">{$hadrianLang.store.xoOrderNow}</a>
            </div>
            <div class="hp-price-card highlight">
                <div class="label" style="color: var(--color-accent);">{if isset($_xoPro)}{$_xoPro->name|escape}{else}Professional{/if}</div>
                <h3>{$hadrianLang.store.xoProTagline}</h3>
                <div class="price-row">{if isset($_xoPro)}{if $_xoPro->isFree()}<span class="price">{$hadrianLang.store.xoFree}</span>{else}<span class="price">{$_xoPro->pricing()->first()->toPrefixedString()}</span>{/if}{else}<span class="price">$79.00</span><span class="per">/mo</span>{/if}</div>
                <ul>
                    <li>{$hadrianLang.store.xoProF1}</li>
                    <li>{$hadrianLang.store.xoProF2}</li>
                    <li>{$hadrianLang.store.xoProF3}</li>
                    <li>{$hadrianLang.store.xoProF4}</li>
                    <li>{$hadrianLang.store.xoProF5}</li>
                    <li>{$hadrianLang.store.xoProF6}</li>
                    <li>{$hadrianLang.store.xoProF7}</li>
                    <li>{$hadrianLang.store.xoProF8}</li>
                    <li>{$hadrianLang.store.xoProF9}</li>
                    <li>{$hadrianLang.store.xoProF10}</li>
                    <li>{$hadrianLang.store.xoProF11}</li>
                </ul>
                <a class="buy" href="{if isset($_xoPro)}{$WEB_ROOT}/cart.php?a=add&amp;pid={$_xoPro->id}{else}{$_xoOrder|escape}{/if}">{$hadrianLang.store.xoOrderNow}</a>
            </div>
        </div>
    </section>

    {* Apple-style Star Rating Block *}
    <section class="hp-testi-reviews">
        <div class="big-stars">&starf;&starf;&starf;&starf;&starf;</div>
        <div class="rating-num">4.9</div>
        <div class="rating-of">{$hadrianLang.store.xoRatingOf}</div>
        <div class="review-sources">
            <div class="rev-src"><div class="stars">&starf;&starf;&starf;&starf;&starf;</div><div class="src-name">G2</div><div class="src-count">2,140 reviews</div></div>
            <div class="rev-src"><div class="stars">&starf;&starf;&starf;&starf;&starf;</div><div class="src-name">Trustpilot</div><div class="src-count">3,892 reviews</div></div>
            <div class="rev-src"><div class="stars">&starf;&starf;&starf;&starf;&starf;</div><div class="src-name">Capterra</div><div class="src-count">1,508 reviews</div></div>
            <div class="rev-src"><div class="stars">&starf;&starf;&starf;&starf;&starf;</div><div class="src-name">App Store</div><div class="src-count">880 reviews</div></div>
        </div>
    </section>

    {* 7. Testimonials - decorative, kept verbatim *}
    <section class="hp-testi-masonry">
        <h2>{$hadrianLang.store.xoTestiTitle}</h2>
        <p class="hp-testi-masonry-sub">{$hadrianLang.store.xoTestiSub}</p>
        <div class="hp-testi-masonry-grid">
            <div class="hp-testi-tile"><div class="stars">&starf;&starf;&starf;&starf;&starf;</div><p class="quote">Five Star Hosting Service! I&rsquo;ve thrilled to express my utmost satisfaction with the truly exceptional hosting service provided by this platform. Their commitment to maintaining a robust infrastructure.</p><div class="author"><div class="avatar" style="background-image:url('https://i.pravatar.cc/96?u=michaelsmith');"></div><div><div class="name">Michael Smith</div><div class="role">NextLabs</div></div></div></div>
            <div class="hp-testi-tile tall accent"><div class="stars">&starf;&starf;&starf;&starf;&starf;</div><p class="quote">High Quality Servers. I&rsquo;m thoroughly impressed with their hosting services. The performance has been exceptional and I&rsquo;d recommend them to anyone looking for a trusted partner.</p><div class="author"><div class="avatar" style="background-image:url('https://i.pravatar.cc/96?u=grahamjohanson');"></div><div><div class="name">Graham Johanson</div><div class="role">FreshStack</div></div></div></div>
            <div class="hp-testi-tile"><div class="stars">&starf;&starf;&starf;&starf;&starf;</div><p class="quote">Great Hosting Company. Tackling my very own WordPress website hosted into an entity broadly effortless with the incredible hosting services they provide.</p><div class="author"><div class="avatar" style="background-image:url('https://i.pravatar.cc/96?u=daniellewilson');"></div><div><div class="name">Danielle Wilson</div><div class="role">Studio34</div></div></div></div>
            <div class="hp-testi-tile dark"><div class="stars">&starf;&starf;&starf;&starf;&starf;</div><p class="quote">Easy App Installation. This hosting has exceeded my expectations. Their one-click app installation saved me time.</p><div class="author"><div class="avatar" style="background-image:url('https://i.pravatar.cc/96?u=lianawilliams');"></div><div><div class="name">Liana Williams</div><div class="role">PixelAgency</div></div></div></div>
            <div class="hp-testi-tile"><div class="stars">&starf;&starf;&starf;&starf;&starf;</div><p class="quote">Why XOVI NOW buys us? The keywords dashboard and SEO Advisor alone are worth the subscription. Rankings have genuinely improved every month we&rsquo;ve used it.</p><div class="author"><div class="avatar" style="background-image:url('https://i.pravatar.cc/96?u=johncole');"></div><div><div class="name">John Cole</div><div class="role">Freelance SEO</div></div></div></div>
            <div class="hp-testi-tile tall cream"><div class="stars">&starf;&starf;&starf;&starf;&starf;</div><p class="quote">Simply Amazing. I have been using XOVI for three months. Immediately in love with the platform. Couldn&rsquo;t ask for more for the price &mdash; the ROI on this tool pays for itself many times over.</p><div class="author"><div class="avatar" style="background-image:url('https://i.pravatar.cc/96?u=marianoble');"></div><div><div class="name">Maria Noble</div><div class="role">Founder, Brightlab</div></div></div></div>
        </div>
    </section>

    {* 8. FAQ *}
    <section class="hp-faq-section">
        <h2>{$hadrianLang.store.xoFaqTitle}</h2>
        <details class="hp-faq-item" open>
            <summary>{$hadrianLang.store.xoFaqQ1}</summary>
            <div class="faq-body">{$hadrianLang.store.xoFaqA1}</div>
        </details>
        <details class="hp-faq-item">
            <summary>{$hadrianLang.store.xoFaqQ2}</summary>
            <div class="faq-body">{$hadrianLang.store.xoFaqA2}</div>
        </details>
        <details class="hp-faq-item">
            <summary>{$hadrianLang.store.xoFaqQ3}</summary>
            <div class="faq-body">{$hadrianLang.store.xoFaqA3}</div>
        </details>
        <details class="hp-faq-item">
            <summary>{$hadrianLang.store.xoFaqQ4}</summary>
            <div class="faq-body">{$hadrianLang.store.xoFaqA4}</div>
        </details>
        <details class="hp-faq-item">
            <summary>{$hadrianLang.store.xoFaqQ5}</summary>
            <div class="faq-body">{$hadrianLang.store.xoFaqA5}</div>
        </details>
    </section>

    {* 9. Newsletter CTA *}
    <section class="hp-cta-newsletter">
        <h2>{$hadrianLang.store.xoNewsTitle}</h2>
        <p class="sub">{$hadrianLang.store.xoNewsSub}</p>
        <form class="hp-newsletter-form">
            <input type="email" placeholder="you@example.com" required>
            <button type="submit">{$hadrianLang.store.xoNewsBtn}</button>
        </form>
        <p class="note">{$hadrianLang.store.xoNewsNote}</p>
    </section>
</div>

<div class="when-empty" style="text-align:center;padding:60px 24px;background:var(--color-surface);border:1px solid var(--color-border);border-radius:14px;">
    <div style="width:56px;height:56px;border-radius:50%;background:var(--color-bg);display:inline-flex;align-items:center;justify-content:center;margin-bottom:16px;color:var(--color-text-tertiary);">
        <svg viewBox="0 0 24 24" width="22" height="22" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="8"/><path d="M21 21l-4.3-4.3"/></svg>
    </div>
    <p style="font-size:17px;font-weight:600;color:var(--color-text-primary);margin:0 0 6px;">{$hadrianLang.store.xoEmptyTitle}</p>
    <p style="font-size:14px;color:var(--color-text-secondary);margin:0 0 20px;max-width:380px;margin-left:auto;margin-right:auto;line-height:1.5;">{$hadrianLang.store.xoEmptyText}</p>
    <a href="{$WEB_ROOT}/" class="btn-primary">{$hadrianLang.store.xoEmptyHome}</a>
</div>
