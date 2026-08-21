{* Store landing - Website Builder (Weebly).
   Ported from apple-client-area/website-builder.html (Public/Marketing landing).
   header.tpl/footer.tpl provide the shell + .content-area, so we emit only the
   inner content (page-header + when-full marketing + when-empty offline state).

   Real pricing: the WHMCS Weebly store controller assigns $products, $inPreview -
   same contract as six/store/weebly/index.tpl. The mockup's three pricing cards
   keep their copy/features and wire each price + order button to the real
   product (captured by position), falling back to the mockup values otherwise.
   Prose is tokenized into the hadrianLang store group (wbl-prefixed keys); terse
   spec bullets, decorative illustrations, and testimonials are kept verbatim.
   The mockup's stats strip uses .stat-item, not in core-theme.css, so we use
   the theme's styled .hp-stat. *}

{assign var=_wblCount value=0}
{if isset($products)}{assign var=_wblCount value=$products|@count}{/if}
{assign var=_wblI value=0}
{if $_wblCount > 0}
    {foreach $products as $_wblProduct}
        {if $_wblI == 0}{assign var=_wbl0 value=$_wblProduct}{elseif $_wblI == 1}{assign var=_wbl1 value=$_wblProduct}{elseif $_wblI == 2}{assign var=_wbl2 value=$_wblProduct}{/if}
        {assign var=_wblI value=$_wblI+1}
    {/foreach}
{/if}
{if $_wblCount > 0 || (isset($inPreview) && $inPreview)}
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

    {* 1. Hero gradient + floating cards *}
    <section class="hp-hero-gradient purple">
        <h1>{$hadrianLang.store.wblHeroTitle}</h1>
        <p class="hp-hero-sub">{$hadrianLang.store.wblHeroSub}</p>
        <div class="hp-floating-cards">
            <div class="hp-floating-card">
                <div class="card-icon"><svg width="32" height="32" viewBox="0 0 24 24" fill="none" stroke="#af52de" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><path d="M15 9.5c0 0-1-1.5-3-1.5s-3 1.5-3 1.5"/><path d="M9 14.5c0 0 1 1.5 3 1.5s3-1.5 3-1.5"/><line x1="8" y1="12" x2="16" y2="12"/></svg></div>
                <div class="card-label">Restaurant</div>
                <div class="card-sub">200+ templates</div>
            </div>
            <div class="hp-floating-card">
                <div class="card-icon"><svg width="32" height="32" viewBox="0 0 24 24" fill="none" stroke="#5856d6" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M23 19a2 2 0 01-2 2H3a2 2 0 01-2-2V8a2 2 0 012-2h4l2-3h6l2 3h4a2 2 0 012 2z"/><circle cx="12" cy="13" r="4"/></svg></div>
                <div class="card-label">Portfolio</div>
                <div class="card-sub">150+ templates</div>
            </div>
            <div class="hp-floating-card">
                <div class="card-icon"><svg width="32" height="32" viewBox="0 0 24 24" fill="none" stroke="#0071e3" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><rect x="2" y="7" width="20" height="14" rx="2" ry="2"/><path d="M16 7V5a2 2 0 00-2-2h-4a2 2 0 00-2 2v2"/></svg></div>
                <div class="card-label">Business</div>
                <div class="card-sub">180+ templates</div>
            </div>
            <div class="hp-floating-card">
                <div class="card-icon"><svg width="32" height="32" viewBox="0 0 24 24" fill="none" stroke="#ff9f0a" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="9" cy="21" r="1"/><circle cx="20" cy="21" r="1"/><path d="M1 1h4l2.68 13.39a2 2 0 002 1.61h9.72a2 2 0 002-1.61L23 6H6"/></svg></div>
                <div class="card-label">Online Store</div>
                <div class="card-sub">120+ templates</div>
            </div>
        </div>
    </section>

    {* 2. Icon grid *}
    <div class="hp-icon-grid">
        <div class="hp-icon-item"><div class="icon-circle blue"><svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M12 2l3.09 6.26L22 9.27l-5 4.87 1.18 6.88L12 17.77l-6.18 3.25L7 14.14 2 9.27l6.91-1.01L12 2z"/></svg></div><h4>{$hadrianLang.store.wblIcon1Title}</h4><p>{$hadrianLang.store.wblIcon1Text}</p></div>
        <div class="hp-icon-item"><div class="icon-circle purple"><svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="3" width="7" height="7"/><rect x="14" y="3" width="7" height="7"/><rect x="3" y="14" width="7" height="7"/><rect x="14" y="14" width="7" height="7"/></svg></div><h4>{$hadrianLang.store.wblIcon2Title}</h4><p>{$hadrianLang.store.wblIcon2Text}</p></div>
        <div class="hp-icon-item"><div class="icon-circle green"><svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><rect x="5" y="2" width="14" height="20" rx="2" ry="2"/><line x1="12" y1="18" x2="12.01" y2="18"/></svg></div><h4>{$hadrianLang.store.wblIcon3Title}</h4><p>{$hadrianLang.store.wblIcon3Text}</p></div>
        <div class="hp-icon-item"><div class="icon-circle orange"><svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg></div><h4>{$hadrianLang.store.wblIcon4Title}</h4><p>{$hadrianLang.store.wblIcon4Text}</p></div>
        <div class="hp-icon-item"><div class="icon-circle teal"><svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="9" cy="21" r="1"/><circle cx="20" cy="21" r="1"/><path d="M1 1h4l2.68 13.39a2 2 0 002 1.61h9.72a2 2 0 002-1.61L23 6H6"/></svg></div><h4>{$hadrianLang.store.wblIcon5Title}</h4><p>{$hadrianLang.store.wblIcon5Text}</p></div>
        <div class="hp-icon-item"><div class="icon-circle red"><svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/></svg></div><h4>{$hadrianLang.store.wblIcon6Title}</h4><p>{$hadrianLang.store.wblIcon6Text}</p></div>
    </div>

    {* 3. Alternating sections *}
    <section class="hp-alternating">
        <div class="hp-alt-row">
            <div class="hp-alt-text">
                <div class="hp-eyebrow" style="color: #af52de;">{$hadrianLang.store.wblTplEyebrow}</div>
                <h2>{$hadrianLang.store.wblTplTitle}</h2>
                <p>{$hadrianLang.store.wblTplText}</p>
            </div>
            <div class="hp-alt-visual">
                <div class="visual-box">
                    <div style="width: 100%;">
                        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 16px;"><span style="font-size: 13px; font-weight: 600; color: var(--color-text-primary);">Choose a template</span><span style="font-size: 11px; color: var(--color-text-tertiary);">206 available</span></div>
                        <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 10px;">
                            <div style="border-radius: 10px; overflow: hidden; box-shadow: 0 2px 8px rgba(0,0,0,0.08);"><div style="height: 80px; background: linear-gradient(135deg, #667eea, #764ba2);"></div><div style="padding: 8px 10px; background: var(--color-surface);"><div style="font-size: 10px; font-weight: 600; color: var(--color-text-primary);">Starter Portfolio</div><div style="font-size: 9px; color: var(--color-text-tertiary);">Creative</div></div></div>
                            <div style="border-radius: 10px; overflow: hidden; box-shadow: 0 2px 8px rgba(0,0,0,0.08);"><div style="height: 80px; background: linear-gradient(135deg, #f093fb, #f5576c);"></div><div style="padding: 8px 10px; background: var(--color-surface);"><div style="font-size: 10px; font-weight: 600; color: var(--color-text-primary);">Bloom Bakery</div><div style="font-size: 9px; color: var(--color-text-tertiary);">Restaurant</div></div></div>
                            <div style="border-radius: 10px; overflow: hidden; box-shadow: 0 2px 8px rgba(0,0,0,0.08);"><div style="height: 80px; background: linear-gradient(135deg, #4facfe, #00f2fe);"></div><div style="padding: 8px 10px; background: var(--color-surface);"><div style="font-size: 10px; font-weight: 600; color: var(--color-text-primary);">TechCorp</div><div style="font-size: 9px; color: var(--color-text-tertiary);">Business</div></div></div>
                            <div style="border-radius: 10px; overflow: hidden; box-shadow: 0 2px 8px rgba(0,0,0,0.08);"><div style="height: 80px; background: linear-gradient(135deg, #0c3483, #a2b6df);"></div><div style="padding: 8px 10px; background: var(--color-surface);"><div style="font-size: 10px; font-weight: 600; color: var(--color-text-primary);">ShopFront</div><div style="font-size: 9px; color: var(--color-text-tertiary);">Online Store</div></div></div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <div class="hp-alt-row reverse">
            <div class="hp-alt-text">
                <div class="hp-eyebrow" style="color: var(--color-accent);">{$hadrianLang.store.wblEditorEyebrow}</div>
                <h2>{$hadrianLang.store.wblEditorTitle}</h2>
                <p>{$hadrianLang.store.wblEditorText}</p>
            </div>
            <div class="hp-alt-visual">
                <div class="visual-box" style="background: var(--color-surface-secondary);">
                    <div style="width: 100%;">
                        <div style="background: var(--color-surface); border-radius: 10px; padding: 8px 12px; margin-bottom: 12px; display: flex; align-items: center; gap: 8px; box-shadow: 0 1px 4px rgba(0,0,0,0.06);">
                            <div style="display: flex; gap: 4px;"><div style="width: 24px; height: 24px; background: #e8e8ed; border-radius: 6px;"></div><div style="width: 24px; height: 24px; background: #e8e8ed; border-radius: 6px;"></div><div style="width: 24px; height: 24px; background: #e8e8ed; border-radius: 6px;"></div></div>
                            <div style="width: 1px; height: 16px; background: #e8e8ed;"></div>
                            <div style="display: flex; gap: 4px; align-items: center;"><div style="width: 16px; height: 16px; background: var(--color-accent); border-radius: 4px;"></div><div style="width: 16px; height: 16px; background: #1d1d1f; border-radius: 4px;"></div><div style="width: 16px; height: 16px; background: var(--color-surface-secondary); border: 1px solid var(--color-border); border-radius: 4px;"></div></div>
                        </div>
                        <div style="background: var(--color-surface); border-radius: 10px; padding: 16px; box-shadow: 0 1px 4px rgba(0,0,0,0.06);">
                            <div style="border: 2px dashed var(--color-accent); border-radius: 8px; padding: 14px; margin-bottom: 10px; position: relative;"><div style="position: absolute; top: -8px; left: 12px; background: var(--color-accent); color: #fff; font-size: 8px; padding: 2px 6px; border-radius: 4px; font-weight: 600;">HERO</div><div style="height: 40px; background: linear-gradient(135deg, #667eea, #764ba2); border-radius: 6px;"></div></div>
                            <div style="border: 1px solid var(--color-border); border-radius: 8px; padding: 10px; margin-bottom: 10px;"><div style="width: 80px; height: 3px; background: #1d1d1f; border-radius: 2px; margin-bottom: 6px;"></div><div style="width: 100%; height: 3px; background: #e8e8ed; border-radius: 2px; margin-bottom: 4px;"></div><div style="width: 70%; height: 3px; background: #e8e8ed; border-radius: 2px;"></div></div>
                            <div style="border: 1px solid var(--color-border); border-radius: 8px; padding: 8px; display: grid; grid-template-columns: 1fr 1fr 1fr; gap: 6px;"><div style="height: 32px; background: #f0f0f5; border-radius: 4px;"></div><div style="height: 32px; background: #f0f0f5; border-radius: 4px;"></div><div style="height: 32px; background: #f0f0f5; border-radius: 4px;"></div></div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <div class="hp-alt-row">
            <div class="hp-alt-text">
                <div class="hp-eyebrow" style="color: #30d158;">{$hadrianLang.store.wblEcomEyebrow}</div>
                <h2>{$hadrianLang.store.wblEcomTitle}</h2>
                <p>{$hadrianLang.store.wblEcomText}</p>
            </div>
            <div class="hp-alt-visual">
                <div class="visual-box">
                    <div style="width: 100%;">
                        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 16px;"><span style="font-size: 13px; font-weight: 600; color: var(--color-text-primary);">Your Store</span><span style="font-size: 11px; color: #30d158; font-weight: 500;">3 products live</span></div>
                        <div style="display: grid; grid-template-columns: 1fr 1fr 1fr; gap: 10px;">
                            <div style="border-radius: 10px; overflow: hidden; box-shadow: 0 2px 8px rgba(0,0,0,0.06); background: var(--color-surface);"><div style="height: 70px; background: linear-gradient(135deg, #ffecd2, #fcb69f);"></div><div style="padding: 8px;"><div style="font-size: 10px; font-weight: 600; color: var(--color-text-primary);">Leather Bag</div><div style="font-size: 11px; font-weight: 600; color: var(--color-accent); margin-top: 2px;">$89.00</div></div></div>
                            <div style="border-radius: 10px; overflow: hidden; box-shadow: 0 2px 8px rgba(0,0,0,0.06); background: var(--color-surface);"><div style="height: 70px; background: linear-gradient(135deg, #a1c4fd, #c2e9fb);"></div><div style="padding: 8px;"><div style="font-size: 10px; font-weight: 600; color: var(--color-text-primary);">Candle Set</div><div style="font-size: 11px; font-weight: 600; color: var(--color-accent); margin-top: 2px;">$34.00</div></div></div>
                            <div style="border-radius: 10px; overflow: hidden; box-shadow: 0 2px 8px rgba(0,0,0,0.06); background: var(--color-surface);"><div style="height: 70px; background: linear-gradient(135deg, #d4fc79, #96e6a1);"></div><div style="padding: 8px;"><div style="font-size: 10px; font-weight: 600; color: var(--color-text-primary);">Art Print</div><div style="font-size: 11px; font-weight: 600; color: var(--color-accent); margin-top: 2px;">$24.00</div></div></div>
                        </div>
                        <div style="margin-top: 12px; background: var(--color-surface); border-radius: 10px; padding: 10px 14px; display: flex; justify-content: space-between; align-items: center; box-shadow: 0 1px 4px rgba(0,0,0,0.06);"><div style="font-size: 11px; color: var(--color-text-tertiary);">3 items in cart</div><div style="background: #30d158; color: #fff; font-size: 10px; font-weight: 600; padding: 5px 12px; border-radius: 20px;">Checkout $147.00</div></div>
                    </div>
                </div>
            </div>
        </div>
    </section>

    {* 4. Pricing - 3 cards wired to real products by position *}
    <section class="hp-pricing-section" id="pricing">
        <h2>{$hadrianLang.store.wblPricingTitle}</h2>
        <p class="sub">{$hadrianLang.store.wblPricingSub}</p>
        <div class="hp-pricing-grid">
            <div class="hp-price-card dim">
                <div class="label">{if isset($_wbl0)}{$_wbl0->name|escape}{else}Basic{/if}</div>
                <h3>{$hadrianLang.store.wblPlan1Tagline}</h3>
                {if isset($_wbl0)}<span class="price">{if $_wbl0->isFree()}$0{else}{$_wbl0->pricing()->first()->price()}{/if}</span>{else}<span class="price">$4.99</span><span class="per">/mo</span>{/if}
                <ul><li>1 website</li><li>500 MB storage</li><li>Free SSL</li><li>Basic templates</li><li>Email support</li></ul>
                <a class="buy" href="{if isset($_wbl0)}{$WEB_ROOT}/cart.php?a=add&amp;pid={$_wbl0->id}{else}#pricing{/if}">{$hadrianLang.store.wblSelect} {if isset($_wbl0)}{$_wbl0->name|escape}{else}Basic{/if}</a>
            </div>
            <div class="hp-price-card highlight">
                <div class="label" style="color: var(--color-accent);">{if isset($_wbl1)}{$_wbl1->name|escape}{else}Pro{/if} - {$hadrianLang.store.wblMostPopular}</div>
                <h3>{$hadrianLang.store.wblPlan2Tagline}</h3>
                {if isset($_wbl1)}<span class="price">{if $_wbl1->isFree()}$0{else}{$_wbl1->pricing()->first()->price()}{/if}</span>{else}<span class="price">$12.99</span><span class="per">/mo</span>{/if}
                <ul><li>5 websites</li><li>10 GB storage</li><li>All templates</li><li>E-commerce (10 products)</li><li>Priority support</li></ul>
                <a class="buy" href="{if isset($_wbl1)}{$WEB_ROOT}/cart.php?a=add&amp;pid={$_wbl1->id}{else}#pricing{/if}">{$hadrianLang.store.wblSelect} {if isset($_wbl1)}{$_wbl1->name|escape}{else}Pro{/if}</a>
            </div>
            <div class="hp-price-card dim">
                <div class="label">{if isset($_wbl2)}{$_wbl2->name|escape}{else}Business{/if}</div>
                <h3>{$hadrianLang.store.wblPlan3Tagline}</h3>
                {if isset($_wbl2)}<span class="price">{if $_wbl2->isFree()}$0{else}{$_wbl2->pricing()->first()->price()}{/if}</span>{else}<span class="price">$24.99</span><span class="per">/mo</span>{/if}
                <ul><li>Unlimited websites</li><li>50 GB storage</li><li>All templates</li><li>Unlimited e-commerce</li><li>Phone support</li><li>Custom domain</li></ul>
                <a class="buy" href="{if isset($_wbl2)}{$WEB_ROOT}/cart.php?a=add&amp;pid={$_wbl2->id}{else}#pricing{/if}">{$hadrianLang.store.wblSelect} {if isset($_wbl2)}{$_wbl2->name|escape}{else}Business{/if}</a>
            </div>
        </div>
        <div class="hp-compare-link"><a href="#pricing">{$hadrianLang.store.wblCompare} &rsaquo;</a></div>
    </section>

    {* 5. Stats strip (.hp-stat - theme-styled equivalent of the mockup's .stat-item) *}
    <section class="hp-stats-strip">
        <div class="stats-inner">
            <div class="hp-stat"><div class="stat-num">200+</div><div class="stat-label">{$hadrianLang.store.wblStat1}</div></div>
            <div class="hp-stat"><div class="stat-num">50M+</div><div class="stat-label">{$hadrianLang.store.wblStat2}</div></div>
            <div class="hp-stat"><div class="stat-num">99.9%</div><div class="stat-label">{$hadrianLang.store.wblStat3}</div></div>
            <div class="hp-stat"><div class="stat-num">0</div><div class="stat-label">{$hadrianLang.store.wblStat4}</div></div>
        </div>
    </section>

    {* 6. Locations visual *}
    <section class="hp-locations-visual">
        <h2>{$hadrianLang.store.wblLocTitle}</h2>
        <p class="loc-sub">{$hadrianLang.store.wblLocSub}</p>
        <div class="loc-map-dots">
            <span class="hp-loc-dot"><span class="dot"></span> US East</span>
            <span class="hp-loc-dot"><span class="dot"></span> US West</span>
            <span class="hp-loc-dot"><span class="dot"></span> Europe</span>
            <span class="hp-loc-dot"><span class="dot"></span> Asia</span>
            <span class="hp-loc-dot"><span class="dot"></span> Oceania</span>
        </div>
        <div class="loc-stats-row">
            <div class="loc-stat"><div class="num">200+</div><div class="label">{$hadrianLang.store.wblLocStat1}</div></div>
            <div class="loc-stat"><div class="num">&lt;50ms</div><div class="label">{$hadrianLang.store.wblLocStat2}</div></div>
            <div class="loc-stat"><div class="num">99.9%</div><div class="label">{$hadrianLang.store.wblLocStat3}</div></div>
            <div class="loc-stat"><div class="num">Free</div><div class="label">{$hadrianLang.store.wblLocStat4}</div></div>
        </div>
    </section>

    {* 7. Numbered steps *}
    <section class="hp-features-numbered">
        <h2>{$hadrianLang.store.wblStepsTitle}</h2>
        <div class="hp-numbered-list">
            <div class="hp-numbered-item"><div class="num">01</div><div><h4>{$hadrianLang.store.wblStep1Title}</h4><p>{$hadrianLang.store.wblStep1Text}</p></div></div>
            <div class="hp-numbered-item"><div class="num">02</div><div><h4>{$hadrianLang.store.wblStep2Title}</h4><p>{$hadrianLang.store.wblStep2Text}</p></div></div>
            <div class="hp-numbered-item"><div class="num">03</div><div><h4>{$hadrianLang.store.wblStep3Title}</h4><p>{$hadrianLang.store.wblStep3Text}</p></div></div>
            <div class="hp-numbered-item"><div class="num">04</div><div><h4>{$hadrianLang.store.wblStep4Title}</h4><p>{$hadrianLang.store.wblStep4Text}</p></div></div>
        </div>
    </section>

    {* 8. Testimonials grid - decorative, kept verbatim *}
    <section class="hp-testimonials-grid">
        <h2>{$hadrianLang.store.wblTestiTitle}</h2>
        <div class="hp-testimonial-cards">
            <div class="hp-testimonial-card"><div class="stars">&starf;&starf;&starf;&starf;&starf;</div><div class="quote">I built my restaurant&rsquo;s website in an afternoon with zero technical skills. The food photography templates are gorgeous and the menu builder is perfect.</div><div class="author"><div class="author-avatar" style="background: url('https://i.pravatar.cc/96?u=mariacosta') center/cover;">MC</div><div><div class="author-name">Maria Costa</div><div class="author-role">Owner, Bella Cucina</div></div></div></div>
            <div class="hp-testimonial-card"><div class="stars">&starf;&starf;&starf;&starf;&starf;</div><div class="quote">As a photographer, I needed a portfolio that loads fast and looks stunning. The drag-and-drop gallery builder is exactly what I was looking for.</div><div class="author"><div class="author-avatar" style="background: url('https://i.pravatar.cc/96?u=alexjohnson') center/cover;">AJ</div><div><div class="author-name">Alex Johnson</div><div class="author-role">Photographer</div></div></div></div>
            <div class="hp-testimonial-card"><div class="stars">&starf;&starf;&starf;&starf;&starf;</div><div class="quote">Launched my online store in a weekend. The e-commerce tools handle inventory, payments, and shipping &mdash; I just focus on my products.</div><div class="author"><div class="author-avatar" style="background: url('https://i.pravatar.cc/96?u=priyalakshmi') center/cover;">PL</div><div><div class="author-name">Priya Lakshmi</div><div class="author-role">Founder, HandmadeByP</div></div></div></div>
        </div>
        <div class="carousel-nav"><button class="carousel-arrow prev"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="15 18 9 12 15 6"/></svg></button><div class="carousel-dots"><button class="carousel-dot active"></button><button class="carousel-dot"></button><button class="carousel-dot"></button></div><button class="carousel-arrow next"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="9 6 15 12 9 18"/></svg></button></div>
    </section>

    {* 9. FAQ grid *}
    <section class="hp-faq-grid">
        <h2>{$hadrianLang.store.wblFaqTitle}</h2>
        <div class="faq-grid-inner">
            <div class="hp-faq-card"><h4>{$hadrianLang.store.wblFaqQ1}</h4><p>{$hadrianLang.store.wblFaqA1}</p></div>
            <div class="hp-faq-card"><h4>{$hadrianLang.store.wblFaqQ2}</h4><p>{$hadrianLang.store.wblFaqA2}</p></div>
            <div class="hp-faq-card"><h4>{$hadrianLang.store.wblFaqQ3}</h4><p>{$hadrianLang.store.wblFaqA3}</p></div>
            <div class="hp-faq-card"><h4>{$hadrianLang.store.wblFaqQ4}</h4><p>{$hadrianLang.store.wblFaqA4}</p></div>
        </div>
    </section>

    {* 10. Split CTA *}
    <div class="hp-split-cta-wrapper">
        <div class="hp-split-cta">
            <div class="cta-panel dark">
                <h3>{$hadrianLang.store.wblCtaDarkTitle}</h3>
                <p>{$hadrianLang.store.wblCtaDarkText}</p>
                <a href="#pricing" class="btn-primary-pill">{$hadrianLang.store.wblCtaDarkBtn}</a>
            </div>
            <div class="cta-panel light">
                <h3>{$hadrianLang.store.wblCtaLightTitle}</h3>
                <p>{$hadrianLang.store.wblCtaLightText}</p>
                <a href="#pricing" class="btn-outline-pill">{$hadrianLang.store.wblCtaLightBtn}</a>
            </div>
        </div>
    </div>
</div>

<div class="when-empty" style="text-align:center;padding:60px 24px;background:var(--color-surface);border:1px solid var(--color-border);border-radius:14px;">
    <div style="width:56px;height:56px;border-radius:50%;background:var(--color-bg);display:inline-flex;align-items:center;justify-content:center;margin-bottom:16px;color:var(--color-text-tertiary);">
        <svg viewBox="0 0 24 24" width="22" height="22" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="3" width="7" height="7"/><rect x="14" y="3" width="7" height="7"/><rect x="14" y="14" width="7" height="7"/><rect x="3" y="14" width="7" height="7"/></svg>
    </div>
    <p style="font-size:17px;font-weight:600;color:var(--color-text-primary);margin:0 0 6px;">{$hadrianLang.store.wblEmptyTitle}</p>
    <p style="font-size:14px;color:var(--color-text-secondary);margin:0 0 20px;max-width:380px;margin-left:auto;margin-right:auto;line-height:1.5;">{$hadrianLang.store.wblEmptyText}</p>
    <a href="{$WEB_ROOT}/" class="btn-primary">{$hadrianLang.store.wblEmptyHome}</a>
</div>
