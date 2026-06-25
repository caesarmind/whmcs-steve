{* Store landing - Site Builder.
   Ported from apple-client-area/site-builder.html (Public/Marketing landing).
   header.tpl/footer.tpl provide the shell + .content-area, so we emit only the
   inner content (page-header + when-full marketing + when-empty offline state).

   Real pricing: the WHMCS Site Builder store controller assigns $plans,
   $trialPlan, $inPreview - same contract as six/store/sitebuilder/index.tpl.
   The mockup's three pricing cards keep their copy/features and wire each
   price + order button to the real plan (captured by position), falling back
   to the mockup values otherwise. Prose is tokenized into the hadrianLang store
   group (sib-prefixed keys); terse spec bullets, decorative illustrations, and
   testimonials are kept verbatim. The mockup's stats strip uses .stat-item,
   which is not in apple-theme.css, so we use the theme's styled .hp-stat. *}

{assign var=_sibCount value=0}
{if isset($plans)}{assign var=_sibCount value=$plans|@count}{/if}
{assign var=_sibI value=0}
{if $_sibCount > 0}
    {foreach $plans as $_sibPlan}
        {if $_sibI == 0}{assign var=_sib0 value=$_sibPlan}{elseif $_sibI == 1}{assign var=_sib1 value=$_sibPlan}{elseif $_sibI == 2}{assign var=_sib2 value=$_sibPlan}{/if}
        {assign var=_sibI value=$_sibI+1}
    {/foreach}
{/if}
{if $_sibCount > 0 || (isset($trialPlan) && $trialPlan) || (isset($inPreview) && $inPreview)}
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

    {* 1. Hero centered *}
    <section class="hp-hero">
        <div class="hp-eyebrow">{$hadrianLang.store.sibHeroEyebrow}</div>
        <h1>{$hadrianLang.store.sibHeroTitle}</h1>
        <p class="hp-subhead">{$hadrianLang.store.sibHeroText}</p>
        <div class="hp-cta-row">
            <a href="#pricing" class="hp-buy-btn">{$hadrianLang.store.sibHeroCta}</a>
            <a href="#templates">{$hadrianLang.store.sibBrowseTemplates} &rsaquo;</a>
        </div>
        <div style="display: flex; gap: 16px; justify-content: center; margin-top: 48px; flex-wrap: wrap;">
            <div style="width: 200px; border-radius: 16px; overflow: hidden; box-shadow: 0 4px 24px rgba(0,0,0,0.10); background: var(--color-surface);">
                <div style="height: 120px; background: linear-gradient(135deg, #667eea, #764ba2); position: relative;">
                    <div style="position: absolute; top: 14px; left: 14px;"><div style="width: 50px; height: 5px; background: rgba(255,255,255,0.8); border-radius: 3px; margin-bottom: 6px;"></div><div style="width: 34px; height: 4px; background: rgba(255,255,255,0.4); border-radius: 2px;"></div></div>
                    <div style="position: absolute; bottom: 14px; right: 14px; width: 36px; height: 36px; background: rgba(255,255,255,0.25); border-radius: 8px;"></div>
                </div>
                <div style="padding: 12px 14px;"><div style="font-size: 13px; font-weight: 600; color: var(--color-text-primary);">Starter</div><div style="font-size: 11px; color: var(--color-text-tertiary); margin-top: 2px;">Personal &amp; blog</div></div>
            </div>
            <div style="width: 200px; border-radius: 16px; overflow: hidden; box-shadow: 0 4px 24px rgba(0,0,0,0.10); background: var(--color-surface); transform: translateY(-8px);">
                <div style="height: 120px; background: linear-gradient(135deg, #0071e3, #2997ff); position: relative;">
                    <div style="position: absolute; top: 12px; left: 14px; display: flex; gap: 6px;"><div style="width: 20px; height: 20px; background: rgba(255,255,255,0.35); border-radius: 5px;"></div><div style="width: 20px; height: 20px; background: rgba(255,255,255,0.35); border-radius: 5px;"></div><div style="width: 20px; height: 20px; background: rgba(255,255,255,0.35); border-radius: 5px;"></div></div>
                    <div style="position: absolute; bottom: 14px; left: 14px;"><div style="width: 60px; height: 5px; background: rgba(255,255,255,0.7); border-radius: 3px; margin-bottom: 5px;"></div><div style="width: 80px; height: 4px; background: rgba(255,255,255,0.35); border-radius: 2px;"></div></div>
                </div>
                <div style="padding: 12px 14px;"><div style="font-size: 13px; font-weight: 600; color: var(--color-text-primary);">Business</div><div style="font-size: 11px; color: var(--color-text-tertiary); margin-top: 2px;">Company &amp; agency</div></div>
            </div>
            <div style="width: 200px; border-radius: 16px; overflow: hidden; box-shadow: 0 4px 24px rgba(0,0,0,0.10); background: var(--color-surface);">
                <div style="height: 120px; background: linear-gradient(135deg, #f5af19, #f12711); position: relative;">
                    <div style="position: absolute; top: 50%; left: 50%; transform: translate(-50%,-50%); display: grid; grid-template-columns: 1fr 1fr; gap: 6px;"><div style="width: 32px; height: 32px; background: rgba(255,255,255,0.35); border-radius: 6px;"></div><div style="width: 32px; height: 32px; background: rgba(255,255,255,0.35); border-radius: 6px;"></div><div style="width: 32px; height: 32px; background: rgba(255,255,255,0.35); border-radius: 6px;"></div><div style="width: 32px; height: 32px; background: rgba(255,255,255,0.35); border-radius: 6px;"></div></div>
                </div>
                <div style="padding: 12px 14px;"><div style="font-size: 13px; font-weight: 600; color: var(--color-text-primary);">Portfolio</div><div style="font-size: 11px; color: var(--color-text-tertiary); margin-top: 2px;">Creative &amp; photography</div></div>
            </div>
        </div>
    </section>

    {* 2. Alternating sections *}
    <section class="hp-alternating" id="templates">
        <div class="hp-alt-row">
            <div class="hp-alt-text">
                <div class="hp-eyebrow" style="color: #af52de;">{$hadrianLang.store.sibTplEyebrow}</div>
                <h3>{$hadrianLang.store.sibTplTitle}</h3>
                <p>{$hadrianLang.store.sibTplText}</p>
            </div>
            <div class="hp-alt-visual">
                <div class="visual-box">
                    <div style="width: 100%;">
                        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 16px;"><span style="font-size: 13px; font-weight: 600; color: var(--color-text-primary);">Template Gallery</span><span style="font-size: 11px; color: var(--color-text-tertiary);">150+ available</span></div>
                        <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 10px;">
                            <div style="border-radius: 10px; overflow: hidden; box-shadow: 0 2px 8px rgba(0,0,0,0.08);"><div style="height: 70px; background: linear-gradient(135deg, #f093fb, #f5576c);"></div><div style="padding: 8px 10px; background: var(--color-surface);"><div style="font-size: 10px; font-weight: 600; color: var(--color-text-primary);">Bistro</div><div style="font-size: 9px; color: var(--color-text-tertiary);">Restaurant</div></div></div>
                            <div style="border-radius: 10px; overflow: hidden; box-shadow: 0 2px 8px rgba(0,0,0,0.08);"><div style="height: 70px; background: linear-gradient(135deg, #667eea, #764ba2);"></div><div style="padding: 8px 10px; background: var(--color-surface);"><div style="font-size: 10px; font-weight: 600; color: var(--color-text-primary);">Showcase</div><div style="font-size: 9px; color: var(--color-text-tertiary);">Portfolio</div></div></div>
                            <div style="border-radius: 10px; overflow: hidden; box-shadow: 0 2px 8px rgba(0,0,0,0.08);"><div style="height: 70px; background: linear-gradient(135deg, #4facfe, #00f2fe);"></div><div style="padding: 8px 10px; background: var(--color-surface);"><div style="font-size: 10px; font-weight: 600; color: var(--color-text-primary);">Storefront</div><div style="font-size: 9px; color: var(--color-text-tertiary);">Online Shop</div></div></div>
                            <div style="border-radius: 10px; overflow: hidden; box-shadow: 0 2px 8px rgba(0,0,0,0.08);"><div style="height: 70px; background: linear-gradient(135deg, #0c3483, #a2b6df);"></div><div style="padding: 8px 10px; background: var(--color-surface);"><div style="font-size: 10px; font-weight: 600; color: var(--color-text-primary);">Catalyst</div><div style="font-size: 9px; color: var(--color-text-tertiary);">Agency</div></div></div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <div class="hp-alt-row reverse">
            <div class="hp-alt-text">
                <div class="hp-eyebrow" style="color: var(--color-accent);">{$hadrianLang.store.sibDndEyebrow}</div>
                <h3>{$hadrianLang.store.sibDndTitle}</h3>
                <p>{$hadrianLang.store.sibDndText}</p>
            </div>
            <div class="hp-alt-visual">
                <div class="visual-box dark">
                    <div style="width: 100%;">
                        <div style="background: rgba(255,255,255,0.08); border-radius: 10px; padding: 8px 12px; margin-bottom: 12px; display: flex; align-items: center; gap: 8px;">
                            <div style="display: flex; gap: 4px;"><div style="width: 24px; height: 24px; background: rgba(255,255,255,0.1); border-radius: 6px;"></div><div style="width: 24px; height: 24px; background: rgba(255,255,255,0.1); border-radius: 6px;"></div><div style="width: 24px; height: 24px; background: rgba(255,255,255,0.1); border-radius: 6px;"></div></div>
                            <div style="width: 1px; height: 16px; background: rgba(255,255,255,0.1);"></div>
                            <div style="display: flex; gap: 4px; align-items: center;"><div style="width: 16px; height: 16px; background: #0071e3; border-radius: 4px;"></div><div style="width: 16px; height: 16px; background: #f5f5f7; border-radius: 4px;"></div><div style="width: 16px; height: 16px; background: #ff9f0a; border-radius: 4px;"></div></div>
                        </div>
                        <div style="background: rgba(255,255,255,0.04); border-radius: 10px; padding: 16px;">
                            <div style="border: 2px dashed #0071e3; border-radius: 8px; padding: 14px; margin-bottom: 10px; position: relative;"><div style="position: absolute; top: -8px; left: 12px; background: #0071e3; color: #fff; font-size: 8px; padding: 2px 6px; border-radius: 4px; font-weight: 600;">HEADER</div><div style="height: 36px; background: linear-gradient(135deg, #667eea, #764ba2); border-radius: 6px;"></div></div>
                            <div style="border: 1px solid rgba(255,255,255,0.12); border-radius: 8px; padding: 10px; margin-bottom: 10px;"><div style="width: 70px; height: 3px; background: rgba(255,255,255,0.5); border-radius: 2px; margin-bottom: 6px;"></div><div style="width: 100%; height: 3px; background: rgba(255,255,255,0.12); border-radius: 2px; margin-bottom: 4px;"></div><div style="width: 65%; height: 3px; background: rgba(255,255,255,0.12); border-radius: 2px;"></div></div>
                            <div style="border: 2px dashed #ff9f0a; border-radius: 8px; padding: 8px; display: grid; grid-template-columns: 1fr 1fr 1fr; gap: 6px; position: relative; opacity: 0.85; transform: rotate(1deg);"><div style="position: absolute; top: -8px; left: 12px; background: #ff9f0a; color: #fff; font-size: 8px; padding: 2px 6px; border-radius: 4px; font-weight: 600;">GALLERY</div><div style="height: 28px; background: rgba(255,255,255,0.08); border-radius: 4px;"></div><div style="height: 28px; background: rgba(255,255,255,0.08); border-radius: 4px;"></div><div style="height: 28px; background: rgba(255,255,255,0.08); border-radius: 4px;"></div></div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <div class="hp-alt-row">
            <div class="hp-alt-text">
                <div class="hp-eyebrow" style="color: #30d158;">{$hadrianLang.store.sibEcomEyebrow}</div>
                <h3>{$hadrianLang.store.sibEcomTitle}</h3>
                <p>{$hadrianLang.store.sibEcomText}</p>
            </div>
            <div class="hp-alt-visual">
                <div class="visual-box" style="background: linear-gradient(180deg, #f0fdf4, #dcfce7);">
                    <div style="width: 100%;">
                        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 14px;"><span style="font-size: 13px; font-weight: 600; color: var(--color-text-primary);">My Store</span><span style="font-size: 11px; color: #30d158; font-weight: 500;">3 products</span></div>
                        <div style="display: grid; grid-template-columns: 1fr 1fr 1fr; gap: 10px; margin-bottom: 12px;">
                            <div style="border-radius: 10px; overflow: hidden; box-shadow: 0 2px 8px rgba(0,0,0,0.06); background: var(--color-surface);"><div style="height: 64px; background: linear-gradient(135deg, #ffecd2, #fcb69f);"></div><div style="padding: 8px;"><div style="font-size: 10px; font-weight: 600; color: var(--color-text-primary);">Canvas Tote</div><div style="font-size: 11px; font-weight: 600; color: #30d158; margin-top: 2px;">$39.00</div></div></div>
                            <div style="border-radius: 10px; overflow: hidden; box-shadow: 0 2px 8px rgba(0,0,0,0.06); background: var(--color-surface);"><div style="height: 64px; background: linear-gradient(135deg, #a1c4fd, #c2e9fb);"></div><div style="padding: 8px;"><div style="font-size: 10px; font-weight: 600; color: var(--color-text-primary);">Candle Set</div><div style="font-size: 11px; font-weight: 600; color: #30d158; margin-top: 2px;">$28.00</div></div></div>
                            <div style="border-radius: 10px; overflow: hidden; box-shadow: 0 2px 8px rgba(0,0,0,0.06); background: var(--color-surface);"><div style="height: 64px; background: linear-gradient(135deg, #d4fc79, #96e6a1);"></div><div style="padding: 8px;"><div style="font-size: 10px; font-weight: 600; color: var(--color-text-primary);">Art Print</div><div style="font-size: 11px; font-weight: 600; color: #30d158; margin-top: 2px;">$18.00</div></div></div>
                        </div>
                        <div style="background: var(--color-surface); border-radius: 10px; padding: 10px 14px; display: flex; justify-content: space-between; align-items: center; box-shadow: 0 1px 4px rgba(0,0,0,0.06);"><div style="font-size: 11px; color: var(--color-text-tertiary);">2 items</div><div style="background: #30d158; color: #fff; font-size: 10px; font-weight: 600; padding: 5px 12px; border-radius: 20px;">Checkout $67.00</div></div>
                    </div>
                </div>
            </div>
        </div>
    </section>

    {* 3. Stats strip (.hp-stat - theme-styled equivalent of the mockup's .stat-item) *}
    <section class="hp-stats-strip">
        <div class="stats-inner">
            <div class="hp-stat"><div class="stat-num">150+</div><div class="stat-label">{$hadrianLang.store.sibStat1}</div></div>
            <div class="hp-stat"><div class="stat-num">10M+</div><div class="stat-label">{$hadrianLang.store.sibStat2}</div></div>
            <div class="hp-stat"><div class="stat-num">99.9%</div><div class="stat-label">{$hadrianLang.store.sibStat3}</div></div>
            <div class="hp-stat"><div class="stat-num">0</div><div class="stat-label">{$hadrianLang.store.sibStat4}</div></div>
        </div>
    </section>

    {* 4. Horizontal scroll cards *}
    <section class="hp-strip-section">
        <div class="hp-strip-header"><h2>{$hadrianLang.store.sibStripTitle}</h2></div>
        <div class="hp-strip-scroll">
            <div class="hp-strip-card a">
                <div class="tag">{$hadrianLang.store.sibStrip1Tag}</div>
                <h3>{$hadrianLang.store.sibStrip1Title}</h3>
                <p>{$hadrianLang.store.sibStrip1Text}</p>
                <div class="strip-visual">
                    <div style="display: flex; gap: 12px; align-items: flex-end; justify-content: center;">
                        <div style="width: 60px; height: 44px; background: rgba(0,0,0,0.15); border-radius: 4px; border: 2px solid rgba(0,0,0,0.25);"></div>
                        <div style="width: 36px; height: 48px; background: rgba(0,0,0,0.15); border-radius: 4px; border: 2px solid rgba(0,0,0,0.25);"></div>
                        <div style="width: 22px; height: 40px; background: rgba(0,0,0,0.15); border-radius: 4px; border: 2px solid rgba(0,0,0,0.25);"></div>
                    </div>
                </div>
            </div>
            <div class="hp-strip-card b">
                <div class="tag">{$hadrianLang.store.sibStrip2Tag}</div>
                <h3>{$hadrianLang.store.sibStrip2Title}</h3>
                <p>{$hadrianLang.store.sibStrip2Text}</p>
                <div class="strip-visual">
                    <div style="text-align: center;"><div style="display: inline-block; background: rgba(255,255,255,0.1); border-radius: 12px; padding: 14px 20px;"><div style="font-size: 36px; font-weight: 700; color: #2997ff; line-height: 1;">A+</div><div style="font-size: 10px; color: rgba(255,255,255,0.5); margin-top: 4px;">SEO Score</div></div></div>
                </div>
            </div>
            <div class="hp-strip-card c">
                <div class="tag">{$hadrianLang.store.sibStrip3Tag}</div>
                <h3>{$hadrianLang.store.sibStrip3Title}</h3>
                <p>{$hadrianLang.store.sibStrip3Text}</p>
                <div class="strip-visual" style="font-size: 72px;">&#128274;</div>
            </div>
            <div class="hp-strip-card d">
                <div class="tag">{$hadrianLang.store.sibStrip4Tag}</div>
                <h3>{$hadrianLang.store.sibStrip4Title}</h3>
                <p>{$hadrianLang.store.sibStrip4Text}</p>
                <div class="strip-visual">
                    <div style="background: rgba(255,255,255,0.4); border-radius: 10px; padding: 12px 16px; display: inline-flex; align-items: center; gap: 8px;"><svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="2" y1="12" x2="22" y2="12"/><path d="M12 2a15.3 15.3 0 014 10 15.3 15.3 0 01-4 10 15.3 15.3 0 01-4-10 15.3 15.3 0 014-10z"/></svg><span style="font-size: 13px; font-weight: 600;">mysite.com</span></div>
                </div>
            </div>
            <div class="hp-strip-card e">
                <div class="tag">{$hadrianLang.store.sibStrip5Tag}</div>
                <h3>{$hadrianLang.store.sibStrip5Title}</h3>
                <p>{$hadrianLang.store.sibStrip5Text}</p>
                <div class="strip-visual">
                    <div style="display: flex; gap: 6px; align-items: flex-end; justify-content: center; height: 80px;"><div style="width: 14px; height: 30%; background: rgba(255,255,255,0.3); border-radius: 3px;"></div><div style="width: 14px; height: 50%; background: rgba(255,255,255,0.3); border-radius: 3px;"></div><div style="width: 14px; height: 75%; background: rgba(255,255,255,0.3); border-radius: 3px;"></div><div style="width: 14px; height: 60%; background: rgba(255,255,255,0.3); border-radius: 3px;"></div><div style="width: 14px; height: 90%; background: rgba(255,255,255,0.5); border-radius: 3px;"></div><div style="width: 14px; height: 100%; background: rgba(255,255,255,0.6); border-radius: 3px;"></div><div style="width: 14px; height: 80%; background: rgba(255,255,255,0.4); border-radius: 3px;"></div></div>
                </div>
            </div>
        </div>
    </section>

    {* 5. Pricing - 3 cards wired to real plans by position *}
    <section class="hp-pricing-section" id="pricing">
        <h2>{$hadrianLang.store.sibPricingTitle}</h2>
        <p class="sub">{$hadrianLang.store.sibPricingSub}</p>
        <div class="hp-pricing-grid">
            <div class="hp-price-card dim">
                <div class="label">{if isset($_sib0)}{$_sib0->name|escape}{else}Free{/if}</div>
                <h3>{$hadrianLang.store.sibPlan1Tagline}</h3>
                {if isset($_sib0)}<span class="price">{if $_sib0->isFree()}$0{else}{$_sib0->pricing()->first()->price()}{/if}</span>{else}<span class="price">$0</span><span class="per">/mo</span>{/if}
                <ul><li>1 site</li><li>Subdomain only</li><li>500 MB storage</li><li>Basic templates</li><li>Ads shown</li></ul>
                <a class="buy" href="{if isset($_sib0)}{$WEB_ROOT}/cart.php?a=add&amp;pid={$_sib0->id}{else}#pricing{/if}">{$hadrianLang.store.sibStartFree}</a>
            </div>
            <div class="hp-price-card highlight">
                <div class="label" style="color: var(--color-accent);">{if isset($_sib1)}{$_sib1->name|escape}{else}Pro{/if} - {$hadrianLang.store.sibMostPopular}</div>
                <h3>{$hadrianLang.store.sibPlan2Tagline}</h3>
                {if isset($_sib1)}<span class="price">{if $_sib1->isFree()}$0{else}{$_sib1->pricing()->first()->price()}{/if}</span>{else}<span class="price">$9.99</span><span class="per">/mo</span>{/if}
                <ul><li>3 sites</li><li>Custom domain</li><li>10 GB storage</li><li>All templates</li><li>E-commerce (25 products)</li><li>No ads</li></ul>
                <a class="buy" href="{if isset($_sib1)}{$WEB_ROOT}/cart.php?a=add&amp;pid={$_sib1->id}{else}#pricing{/if}">{$hadrianLang.store.sibSelect} {if isset($_sib1)}{$_sib1->name|escape}{else}Pro{/if}</a>
            </div>
            <div class="hp-price-card dim">
                <div class="label">{if isset($_sib2)}{$_sib2->name|escape}{else}Business{/if}</div>
                <h3>{$hadrianLang.store.sibPlan3Tagline}</h3>
                {if isset($_sib2)}<span class="price">{if $_sib2->isFree()}$0{else}{$_sib2->pricing()->first()->price()}{/if}</span>{else}<span class="price">$19.99</span><span class="per">/mo</span>{/if}
                <ul><li>Unlimited sites</li><li>Custom domain</li><li>50 GB storage</li><li>All templates</li><li>Unlimited e-commerce</li><li>Priority support</li><li>Analytics</li></ul>
                <a class="buy" href="{if isset($_sib2)}{$WEB_ROOT}/cart.php?a=add&amp;pid={$_sib2->id}{else}#pricing{/if}">{$hadrianLang.store.sibSelect} {if isset($_sib2)}{$_sib2->name|escape}{else}Business{/if}</a>
            </div>
        </div>
        <div class="hp-compare-link"><a href="#pricing">{$hadrianLang.store.sibCompare} &rsaquo;</a></div>
    </section>

    {* 6. Numbered steps *}
    <section class="hp-features-numbered">
        <h2>{$hadrianLang.store.sibStepsTitle}</h2>
        <div class="hp-numbered-list">
            <div class="hp-numbered-item"><div class="num">01</div><div><h4>{$hadrianLang.store.sibStep1Title}</h4><p>{$hadrianLang.store.sibStep1Text}</p></div></div>
            <div class="hp-numbered-item"><div class="num">02</div><div><h4>{$hadrianLang.store.sibStep2Title}</h4><p>{$hadrianLang.store.sibStep2Text}</p></div></div>
            <div class="hp-numbered-item"><div class="num">03</div><div><h4>{$hadrianLang.store.sibStep3Title}</h4><p>{$hadrianLang.store.sibStep3Text}</p></div></div>
            <div class="hp-numbered-item"><div class="num">04</div><div><h4>{$hadrianLang.store.sibStep4Title}</h4><p>{$hadrianLang.store.sibStep4Text}</p></div></div>
        </div>
    </section>

    {* 7. Testimonials scroll - decorative, kept verbatim *}
    <section class="hp-testimonials-scroll">
        <h2>{$hadrianLang.store.sibTestiTitle}</h2>
        <div class="hp-testimonials-strip">
            <div class="hp-testi-slide"><div class="stars">&starf;&starf;&starf;&starf;&starf;</div><div class="quote">As someone with zero tech skills, I built a beautiful portfolio site in one evening. The templates are stunning and editing is completely intuitive.</div><div class="author"><div class="author-avatar" style="background: url('https://i.pravatar.cc/96?u=hannahmiller') center/cover;">HM</div><div><div class="author-name">Hannah Miller</div><div class="author-role">Illustrator</div></div></div></div>
            <div class="hp-testi-slide"><div class="stars">&starf;&starf;&starf;&starf;&starf;</div><div class="quote">Launched my bakery&rsquo;s online ordering system in a weekend. The e-commerce integration handles everything &mdash; from product photos to payment processing.</div><div class="author"><div class="author-avatar" style="background: url('https://i.pravatar.cc/96?u=carlosdiaz') center/cover;">CD</div><div><div class="author-name">Carlos Diaz</div><div class="author-role">Owner, Sweet Spot Bakery</div></div></div></div>
            <div class="hp-testi-slide"><div class="stars">&starf;&starf;&starf;&starf;&starf;</div><div class="quote">I&rsquo;ve tried the big builders. This is the cleanest, fastest one I&rsquo;ve used. The free tier is genuinely useful &mdash; not just a demo.</div><div class="author"><div class="author-avatar" style="background: url('https://i.pravatar.cc/96?u=nadiarusso') center/cover;">NR</div><div><div class="author-name">Nadia Russo</div><div class="author-role">Blogger</div></div></div></div>
            <div class="hp-testi-slide"><div class="stars">&starf;&starf;&starf;&starf;&starf;</div><div class="quote">Built 8 client sites on this platform. The business plan is incredibly good value &mdash; unlimited sites, all templates, and the support team is phenomenal.</div><div class="author"><div class="author-avatar" style="background: url('https://i.pravatar.cc/96?u=alextorres') center/cover;">AT</div><div><div class="author-name">Alex Torres</div><div class="author-role">Freelance Designer</div></div></div></div>
        </div>
        <div class="carousel-scroll-nav"><button class="carousel-arrow prev"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="15 18 9 12 15 6"/></svg></button><button class="carousel-arrow next"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="9 6 15 12 9 18"/></svg></button></div>
    </section>

    {* 8. Locations *}
    <section class="hp-locations-section">
        <h2>{$hadrianLang.store.sibLocTitle}</h2>
        <p class="loc-sub">{$hadrianLang.store.sibLocSub}</p>
        <div class="hp-loc-grid">
            <div class="hp-loc-card"><div class="loc-flag">&#127482;&#127480;</div><h4>{$hadrianLang.store.sibLoc1Title}</h4><p>Virginia &amp; Oregon</p></div>
            <div class="hp-loc-card"><div class="loc-flag">&#127468;&#127463;</div><h4>{$hadrianLang.store.sibLoc2Title}</h4><p>London &amp; Frankfurt</p></div>
            <div class="hp-loc-card"><div class="loc-flag">&#127480;&#127468;</div><h4>{$hadrianLang.store.sibLoc3Title}</h4><p>Singapore &amp; Tokyo</p></div>
            <div class="hp-loc-card"><div class="loc-flag">&#127462;&#127482;</div><h4>{$hadrianLang.store.sibLoc4Title}</h4><p>Sydney, Australia</p></div>
        </div>
    </section>

    {* 9. Split CTA *}
    <div class="hp-split-cta-wrapper">
        <div class="hp-split-cta">
            <div class="cta-panel dark">
                <h3>{$hadrianLang.store.sibCtaDarkTitle}</h3>
                <p>{$hadrianLang.store.sibCtaDarkText}</p>
                <a href="#pricing" class="btn-primary-pill">{$hadrianLang.store.sibStartFree}</a>
            </div>
            <div class="cta-panel light">
                <h3>{$hadrianLang.store.sibCtaLightTitle}</h3>
                <p>{$hadrianLang.store.sibCtaLightText}</p>
                <a href="#templates" class="btn-outline-pill">{$hadrianLang.store.sibBrowseTemplates}</a>
            </div>
        </div>
    </div>
</div>

<div class="when-empty" style="text-align:center;padding:60px 24px;background:var(--color-surface);border:1px solid var(--color-border);border-radius:14px;">
    <div style="width:56px;height:56px;border-radius:50%;background:var(--color-bg);display:inline-flex;align-items:center;justify-content:center;margin-bottom:16px;color:var(--color-text-tertiary);">
        <svg viewBox="0 0 24 24" width="22" height="22" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="3" width="18" height="18" rx="2"/><path d="M3 9h18M9 21V9"/></svg>
    </div>
    <p style="font-size:17px;font-weight:600;color:var(--color-text-primary);margin:0 0 6px;">{$hadrianLang.store.sibEmptyTitle}</p>
    <p style="font-size:14px;color:var(--color-text-secondary);margin:0 0 20px;max-width:380px;margin-left:auto;margin-right:auto;line-height:1.5;">{$hadrianLang.store.sibEmptyText}</p>
    <a href="{$WEB_ROOT}/" class="btn-primary">{$hadrianLang.store.sibEmptyHome}</a>
</div>
