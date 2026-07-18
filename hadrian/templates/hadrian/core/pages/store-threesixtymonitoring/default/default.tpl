{* Store landing - 360 Monitoring (site + server).
   Ported from apple-client-area/monitoring-360.html (Public/Marketing landing).
   header.tpl/footer.tpl provide the shell + .content-area, so we emit only the
   inner content (page-header + when-full marketing + when-empty offline state).

   Real pricing: the WHMCS 360 store controller assigns $planComparisonData
   (keyed 'website' / 'server'), $websitePlanCount, $serverPlanCount, $inPreview -
   same contract as six/store/threesixtymonitoring/index.tpl. The mockup's two
   pricing panes keep their exact card copy/specs; we wire each card's price +
   order button to the real plan (captured by position), falling back to the
   mockup values otherwise. Prose is tokenized into the hadrianLang store group
   (mon-prefixed keys); terse spec bullets, decorative illustrations, and
   testimonials are kept verbatim. The page-specific mon-* CSS and the
   mode/sub-tab/pricing toggles are carried inline (literal-wrapped) since they
   are unique to this page and not part of apple-theme.css. *}

{assign var=_monWebCount value=0}
{assign var=_monSrvCount value=0}
{if isset($planComparisonData) && isset($planComparisonData.website)}{assign var=_monWebCount value=$planComparisonData.website|@count}{/if}
{if isset($planComparisonData) && isset($planComparisonData.server)}{assign var=_monSrvCount value=$planComparisonData.server|@count}{/if}
{if $_monWebCount > 0}
    {assign var=_wi value=0}
    {foreach $planComparisonData.website as $_wp}
        {if $_wi == 0}{assign var=_ws0 value=$_wp}{elseif $_wi == 1}{assign var=_ws1 value=$_wp}{elseif $_wi == 2}{assign var=_ws2 value=$_wp}{elseif $_wi == 3}{assign var=_ws3 value=$_wp}{/if}
        {assign var=_wi value=$_wi+1}
    {/foreach}
{/if}
{if $_monSrvCount > 0}
    {assign var=_si value=0}
    {foreach $planComparisonData.server as $_sp}
        {if $_si == 0}{assign var=_sv0 value=$_sp}{elseif $_si == 1}{assign var=_sv1 value=$_sp}{elseif $_si == 2}{assign var=_sv2 value=$_sp}{/if}
        {assign var=_si value=$_si+1}
    {/foreach}
{/if}
{if $_monWebCount > 0 || $_monSrvCount > 0 || (isset($inPreview) && $inPreview)}
    {assign var=storeIsEmpty value='full'}
{else}
    {assign var=storeIsEmpty value='empty'}
{/if}

{literal}
<style>
/* Unify content column - align every major block to the 1024px theme width */
.hp-intel-duo,
.hp-testi-masonry { max-width: 1024px; }
.mon-mode-toggle { display: inline-flex; background: var(--color-surface-secondary); border-radius: 980px; padding: 3px; }
.mon-mode-toggle button { border: none; background: none; padding: 8px 22px; font-size: 14px; font-weight: 500; border-radius: 980px; cursor: pointer; color: var(--color-text-secondary); transition: all 0.2s ease; font-family: inherit; }
.mon-mode-toggle button.active { background: var(--color-surface); color: var(--color-text-primary); box-shadow: 0 1px 4px rgba(0,0,0,0.1); }
[data-theme="dark"] .mon-mode-toggle { background: #2a2a2c; }
[data-theme="dark"] .mon-mode-toggle button { color: #a1a1a6; }
[data-theme="dark"] .mon-mode-toggle button.active { background: #3a3a3c; color: #f5f5f7; }
.mon-check-form { display: grid; grid-template-columns: 1fr 220px auto; gap: 8px; margin-top: 20px; max-width: 620px; }
.mon-check-form .ds-search-box { grid-column: 1 / 2; }
.mon-check-form .mon-location { display: flex; align-items: center; gap: 8px; background: var(--color-surface); border: 1px solid var(--color-border); border-radius: 16px; padding: 0 14px; box-shadow: 0 12px 32px rgba(0,0,0,0.06); }
.mon-check-form .mon-location svg { width: 16px; height: 16px; color: var(--color-accent); flex-shrink: 0; }
.mon-check-form .mon-location select { flex: 1; border: 0; outline: none; background: transparent; font: inherit; font-size: 14px; color: var(--color-text-primary); padding: 14px 0; appearance: none; cursor: pointer; -webkit-appearance: none; }
.mon-check-form .mon-check-btn { background: var(--color-accent); color: #fff; border: 0; border-radius: 16px; padding: 0 22px; font: inherit; font-size: 14px; font-weight: 500; cursor: pointer; display: flex; align-items: center; gap: 8px; transition: background 0.15s; }
.mon-check-form .mon-check-btn:hover { background: #0077ed; }
[data-theme="dark"] .mon-check-form .mon-location { background: #1c1c1e; border-color: #3a3a3c; }
[data-theme="dark"] .mon-check-form .mon-location select { color: #f5f5f7; }
[data-theme="dark"] .mon-check-form .mon-location svg { color: #2997ff; }
@media (max-width: 720px) { .mon-check-form { grid-template-columns: 1fr; } }
.mon-subtabs { display: flex; justify-content: center; gap: 6px; margin: 8px 0 40px; }
.mon-subtabs button { border: none; background: transparent; padding: 10px 22px; font-size: 14px; font-weight: 500; border-radius: 980px; cursor: pointer; color: var(--color-text-secondary); transition: all 0.2s ease; font-family: inherit; }
.mon-subtabs button.active { background: var(--color-accent); color: #fff; }
[data-theme="dark"] .mon-subtabs button { color: #a1a1a6; }
[data-theme="dark"] .mon-subtabs button.active { background: #2997ff; color: #fff; }
.mon-pane { display: none; }
.mon-pane.active { display: block; }
.mon-alerts-grid { display: grid; grid-template-columns: repeat(7, 1fr); gap: 20px 16px; max-width: 900px; margin: 0 auto; }
@media (max-width: 900px) { .mon-alerts-grid { grid-template-columns: repeat(5, 1fr); } }
@media (max-width: 560px) { .mon-alerts-grid { grid-template-columns: repeat(4, 1fr); } }
.mon-alert-cell { display: flex; flex-direction: column; align-items: center; gap: 8px; }
.mon-alert-ico { width: 56px; height: 56px; background: var(--color-surface); border-radius: 16px; display: flex; align-items: center; justify-content: center; box-shadow: 0 2px 10px rgba(0,0,0,0.06); }
.mon-alert-ico svg { width: 24px; height: 24px; }
.mon-alert-label { font-size: 12px; font-weight: 500; color: var(--color-text-primary); text-align: center; }
[data-theme="dark"] .mon-alert-ico { background: #2a2a2c; box-shadow: 0 2px 10px rgba(0,0,0,0.3); }
.mon-uptime-row { display: grid; grid-template-columns: repeat(4, 1fr); gap: 14px; max-width: 900px; margin: 32px auto 0; }
@media (max-width: 720px) { .mon-uptime-row { grid-template-columns: repeat(2, 1fr); } }
.mon-uptime-card { background: var(--color-surface); border: 1px solid var(--color-border); border-radius: 18px; padding: 28px 20px; text-align: center; }
.mon-uptime-card .up { font-size: 28px; font-weight: 600; letter-spacing: -0.02em; color: var(--color-text-primary); }
.mon-uptime-card .up-lbl { font-size: 11px; color: var(--color-text-tertiary); letter-spacing: 0.04em; text-transform: uppercase; margin-bottom: 14px; }
.mon-uptime-card .eq { font-size: 16px; color: var(--color-text-tertiary); margin: 8px 0; }
.mon-uptime-card .cost { font-size: 26px; font-weight: 600; color: #ff3b30; letter-spacing: -0.02em; }
.mon-uptime-card .cost-lbl { font-size: 11px; color: var(--color-text-tertiary); margin-top: 4px; }
[data-theme="dark"] .mon-uptime-card { background: #2a2a2c; border-color: #3a3a3c; }
[data-theme="dark"] .mon-uptime-card .up { color: #f5f5f7; }
</style>
{/literal}


<script>
(function () {
    var b = document.body;
    if (!b) return;
    b.setAttribute('data-data', '{$storeIsEmpty}');
    b.setAttribute('data-svc-layout', 'inside');
})();
</script>

<div class="when-full">

    {* 1. Hero - mode toggle + URL check (site) / uptime pitch (server) *}
    <section class="hp-hero-split" style="padding: 60px 22px 40px;">
        <div class="hp-split-text">
            <div class="hp-eyebrow">{$hadrianLang.store.monHeroEyebrow}</div>
            <div style="margin-bottom: 20px;">
                <div class="mon-mode-toggle" role="tablist" aria-label="Monitoring mode">
                    <button class="active" data-mode="site" role="tab" aria-selected="true">{$hadrianLang.store.monModeSite}</button>
                    <button data-mode="server" role="tab" aria-selected="false">{$hadrianLang.store.monModeServer}</button>
                </div>
            </div>
            <div class="mon-mode-pane mon-pane active" data-pane="site">
                <h1>{$hadrianLang.store.monSiteHeroTitle}</h1>
                <p>{$hadrianLang.store.monSiteHeroText}</p>
                <form class="mon-check-form" onsubmit="event.preventDefault();">
                    <div class="ds-search-box">
                        <svg class="ds-search-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
                        <input type="text" class="ds-search-input" placeholder="www.example.com" aria-label="Check your website">
                    </div>
                    <div class="mon-location">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 1118 0z"/><circle cx="12" cy="10" r="3"/></svg>
                        <select aria-label="Probe location">
                            <option value="">{$hadrianLang.store.monSelectLocation}</option>
                            <option>Nuremberg #1, DE</option><option>Falkenstein #1, DE</option><option>Helsinki #1, FI</option><option>Amsterdam, NL</option><option>London #1, UK</option><option>Paris, FR</option><option>Stockholm, SE</option><option>New York, US</option><option>Ashburn, US</option><option>Dallas, US</option><option>Los Angeles, US</option><option>Seattle, US</option><option>Toronto, CA</option><option>Sao Paulo, BR</option><option>Tokyo, JP</option><option>Singapore, SG</option><option>Sydney, AU</option>
                        </select>
                    </div>
                    <button type="submit" class="mon-check-btn">
                        <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
                        {$hadrianLang.store.monCheckNow}
                    </button>
                </form>
                <p style="font-size: 12px; color: var(--color-text-tertiary); margin-top: 10px;">{$hadrianLang.store.monCheckNote}</p>
            </div>
            <div class="mon-mode-pane mon-pane" data-pane="server">
                <h1>{$hadrianLang.store.monServerHeroTitle}</h1>
                <p>{$hadrianLang.store.monServerHeroText}</p>
                <div class="hp-cta-row" style="margin-top: 20px;">
                    <a href="#pricing" class="hp-buy-btn">{$hadrianLang.store.monGetStarted}</a>
                    <a href="#features">{$hadrianLang.store.monSeeFeatures} &rsaquo;</a>
                </div>
            </div>
        </div>
        <div class="hp-split-visual">
            <div class="visual-box" style="background: linear-gradient(135deg, #eef5ff 0%, #dbeafe 100%); padding: 28px;">
                <div style="background: var(--color-surface); border-radius: 14px; padding: 16px; width: 100%; max-width: 300px; box-shadow: 0 8px 24px rgba(0,0,0,0.08);">
                    <div style="display: flex; align-items: center; justify-content: space-between; margin-bottom: 12px;">
                        <div style="font-size: 11px; font-weight: 600; color: var(--color-text-primary);">Monitor &middot; 24h</div>
                        <span style="font-size: 10px; color: #30d158; font-weight: 600;">&bull; ONLINE</span>
                    </div>
                    <svg viewBox="0 0 240 80" style="width: 100%; height: 80px;">
                        <defs><linearGradient id="monitorGrad" x1="0" y1="0" x2="0" y2="1"><stop offset="0%" stop-color="#0071e3" stop-opacity="0.3"/><stop offset="100%" stop-color="#0071e3" stop-opacity="0"/></linearGradient></defs>
                        <path d="M0,60 L24,45 L48,52 L72,30 L96,38 L120,22 L144,28 L168,18 L192,25 L216,12 L240,20 L240,80 L0,80 Z" fill="url(#monitorGrad)"/>
                        <path d="M0,60 L24,45 L48,52 L72,30 L96,38 L120,22 L144,28 L168,18 L192,25 L216,12 L240,20" fill="none" stroke="#0071e3" stroke-width="2"/>
                    </svg>
                    <div style="display: grid; grid-template-columns: repeat(3, 1fr); gap: 8px; margin-top: 12px;">
                        <div style="padding: 8px; background: var(--color-surface-secondary); border-radius: 8px; text-align: center;"><div style="font-size: 13px; font-weight: 700; color: var(--color-text-primary);">99.98%</div><div style="font-size: 9px; color: var(--color-text-tertiary);">Uptime</div></div>
                        <div style="padding: 8px; background: var(--color-surface-secondary); border-radius: 8px; text-align: center;"><div style="font-size: 13px; font-weight: 700; color: var(--color-text-primary);">187ms</div><div style="font-size: 9px; color: var(--color-text-tertiary);">Response</div></div>
                        <div style="padding: 8px; background: var(--color-surface-secondary); border-radius: 8px; text-align: center;"><div style="font-size: 13px; font-weight: 700; color: #30d158;">0</div><div style="font-size: 9px; color: var(--color-text-tertiary);">Incidents</div></div>
                    </div>
                </div>
            </div>
        </div>
    </section>

    {* 2. 3 pillar icons *}
    <section class="hp-icon-grid" style="padding: 32px 22px 72px;">
        <div class="hp-icon-item">
            <div class="icon-circle blue"><svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg></div>
            <h4>{$hadrianLang.store.monPillar1Title}</h4>
            <p>{$hadrianLang.store.monPillar1Text}</p>
        </div>
        <div class="hp-icon-item">
            <div class="icon-circle orange"><svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M18 8A6 6 0 006 8c0 7-3 9-3 9h18s-3-2-3-9"/><path d="M13.73 21a2 2 0 01-3.46 0"/></svg></div>
            <h4>{$hadrianLang.store.monPillar2Title}</h4>
            <p>{$hadrianLang.store.monPillar2Text}</p>
        </div>
        <div class="hp-icon-item">
            <div class="icon-circle green"><svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M22 11.08V12a10 10 0 11-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg></div>
            <h4>{$hadrianLang.store.monPillar3Title}</h4>
            <p>{$hadrianLang.store.monPillar3Text}</p>
        </div>
    </section>

    {* 3. Features sub-tabs *}
    <section id="features" style="background: var(--color-surface-secondary); padding: 80px 22px;">
        <div style="max-width: 1024px; margin: 0 auto; text-align: center;">
            <h2 style="font-size: 48px; font-weight: 600; letter-spacing: -0.02em; margin: 0 0 14px; color: var(--color-text-primary);">{$hadrianLang.store.monFeaturesTitle}</h2>
            <p style="font-size: 17px; color: var(--color-text-secondary); margin: 0 0 8px;">{$hadrianLang.store.monFeaturesSub}</p>
            <div class="mon-subtabs" role="tablist">
                <button class="active" data-feat="site" role="tab" aria-selected="true">{$hadrianLang.store.monModeSite}</button>
                <button data-feat="fsc" role="tab" aria-selected="false">{$hadrianLang.store.monFullSiteCheck}</button>
            </div>
            <div class="mon-pane active" data-featpane="site">
                <div class="hp-feature-cards" >
                    <div class="hp-feature-card"><div class="feat-icon red"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M10.29 3.86L1.82 18a2 2 0 001.71 3h16.94a2 2 0 001.71-3L13.71 3.86a2 2 0 00-3.42 0z"/><line x1="12" y1="9" x2="12" y2="13"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg></div><h4>{$hadrianLang.store.monSF1Title}</h4><p>{$hadrianLang.store.monSF1Text}</p></div>
                    <div class="hp-feature-card"><div class="feat-icon blue"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="22 12 18 12 15 21 9 3 6 12 2 12"/></svg></div><h4>{$hadrianLang.store.monSF2Title}</h4><p>{$hadrianLang.store.monSF2Text}</p></div>
                    <div class="hp-feature-card"><div class="feat-icon teal"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 1118 0z"/><circle cx="12" cy="10" r="3"/></svg></div><h4>{$hadrianLang.store.monSF3Title}</h4><p>{$hadrianLang.store.monSF3Text}</p></div>
                    <div class="hp-feature-card"><div class="feat-icon purple"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/><line x1="8" y1="11" x2="14" y2="11"/></svg></div><h4>{$hadrianLang.store.monSF4Title}</h4><p>{$hadrianLang.store.monSF4Text}</p></div>
                    <div class="hp-feature-card"><div class="feat-icon orange"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="4" width="18" height="12" rx="2"/><line x1="8" y1="20" x2="16" y2="20"/><line x1="12" y1="16" x2="12" y2="20"/></svg></div><h4>{$hadrianLang.store.monSF5Title}</h4><p>{$hadrianLang.store.monSF5Text}</p></div>
                    <div class="hp-feature-card"><div class="feat-icon green"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/></svg></div><h4>{$hadrianLang.store.monSF6Title}</h4><p>{$hadrianLang.store.monSF6Text}</p></div>
                </div>
            </div>
            <div class="mon-pane" data-featpane="fsc">
                <div class="hp-feature-cards cols-2"  style="max-width: 720px; margin: 0 auto">
                    <div class="hp-feature-card"><div class="feat-icon red"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M10 13a5 5 0 007.54.54l3-3a5 5 0 00-7.07-7.07l-1.72 1.71"/><path d="M14 11a5 5 0 00-7.54-.54l-3 3a5 5 0 007.07 7.07l1.71-1.71"/></svg></div><h4>{$hadrianLang.store.monFF1Title}</h4><p>{$hadrianLang.store.monFF1Text}</p></div>
                    <div class="hp-feature-card"><div class="feat-icon orange"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 15v4a2 2 0 01-2 2H5a2 2 0 01-2-2v-4"/><polyline points="17 8 12 3 7 8"/><line x1="12" y1="3" x2="12" y2="15"/></svg></div><h4>{$hadrianLang.store.monFF2Title}</h4><p>{$hadrianLang.store.monFF2Text}</p></div>
                    <div class="hp-feature-card"><div class="feat-icon blue"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="23 6 13.5 15.5 8.5 10.5 1 18"/><polyline points="17 6 23 6 23 12"/></svg></div><h4>{$hadrianLang.store.monFF3Title}</h4><p>{$hadrianLang.store.monFF3Text}</p></div>
                    <div class="hp-feature-card"><div class="feat-icon purple"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="4 7 4 4 20 4 20 7"/><line x1="9" y1="20" x2="15" y2="20"/><line x1="12" y1="4" x2="12" y2="20"/></svg></div><h4>{$hadrianLang.store.monFF4Title}</h4><p>{$hadrianLang.store.monFF4Text}</p></div>
                </div>
            </div>
        </div>
    </section>

    {* 4. Alerts - 13 channels (labels are proper nouns, kept verbatim) *}
    <section style="padding: 72px 22px; text-align: center;">
        <h2 style="font-size: 40px; font-weight: 600; letter-spacing: -0.02em; margin: 0 0 8px;">{$hadrianLang.store.monAlertsTitle}</h2>
        <p style="color: var(--color-text-secondary); margin: 0 0 40px; font-size: 17px;">{$hadrianLang.store.monAlertsSub}</p>
        <div class="mon-alerts-grid">
            <div class="mon-alert-cell"><div class="mon-alert-ico"><svg viewBox="0 0 24 24" fill="none" stroke="#0071e3" stroke-width="2"><rect x="2" y="4" width="20" height="16" rx="2"/><path d="M22 6l-10 7L2 6"/></svg></div><div class="mon-alert-label">Email</div></div>
            <div class="mon-alert-cell"><div class="mon-alert-ico"><svg viewBox="0 0 24 24" fill="none" stroke="#30d158" stroke-width="2"><path d="M21 15a2 2 0 01-2 2H7l-4 4V5a2 2 0 012-2h14a2 2 0 012 2z"/></svg></div><div class="mon-alert-label">SMS</div></div>
            <div class="mon-alert-cell"><div class="mon-alert-ico"><svg viewBox="0 0 24 24" fill="none" stroke="#ff9f0a" stroke-width="2"><path d="M18 8A6 6 0 006 8c0 7-3 9-3 9h18s-3-2-3-9"/><path d="M13.73 21a2 2 0 01-3.46 0"/></svg></div><div class="mon-alert-label">Pushbullet</div></div>
            <div class="mon-alert-cell"><div class="mon-alert-ico"><svg viewBox="0 0 24 24" fill="none" stroke="#ff453a" stroke-width="2"><path d="M21 15a2 2 0 01-2 2H7l-4 4V5a2 2 0 012-2h14a2 2 0 012 2z"/></svg></div><div class="mon-alert-label">Google Chat</div></div>
            <div class="mon-alert-cell"><div class="mon-alert-ico"><svg viewBox="0 0 24 24" fill="none" stroke="#bf5af2" stroke-width="2"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg></div><div class="mon-alert-label">Pushover</div></div>
            <div class="mon-alert-cell"><div class="mon-alert-ico"><svg viewBox="0 0 24 24" fill="none" stroke="#5865f2" stroke-width="2"><circle cx="9" cy="10" r="1.5" fill="currentColor"/><circle cx="15" cy="10" r="1.5" fill="currentColor"/><path d="M5 17c0 1.5 1 3 2.5 3s2.5-1.5 2.5-3"/><path d="M14 17c0 1.5 1 3 2.5 3s2.5-1.5 2.5-3"/><rect x="3" y="6" width="18" height="12" rx="3"/></svg></div><div class="mon-alert-label">Discord</div></div>
            <div class="mon-alert-cell"><div class="mon-alert-ico"><svg viewBox="0 0 24 24" fill="none" stroke="#e01e5a" stroke-width="2"><rect x="2" y="9" width="6" height="6" rx="1"/><rect x="9" y="2" width="6" height="6" rx="1"/><rect x="16" y="9" width="6" height="6" rx="1"/><rect x="9" y="16" width="6" height="6" rx="1"/></svg></div><div class="mon-alert-label">Slack</div></div>
            <div class="mon-alert-cell"><div class="mon-alert-ico"><svg viewBox="0 0 24 24" fill="none" stroke="#1d1d1f" stroke-width="2"><path d="M10 13a5 5 0 007.54.54l3-3a5 5 0 00-7.07-7.07l-1.72 1.71"/><path d="M14 11a5 5 0 00-7.54-.54l-3 3a5 5 0 007.07 7.07l1.71-1.71"/></svg></div><div class="mon-alert-label">Webhook</div></div>
            <div class="mon-alert-cell"><div class="mon-alert-ico"><svg viewBox="0 0 24 24" fill="none" stroke="#4a90e2" stroke-width="2"><path d="M21 11.5a8.38 8.38 0 01-.9 3.8 8.5 8.5 0 01-7.6 4.7 8.38 8.38 0 01-3.8-.9L3 21l1.9-5.7a8.38 8.38 0 01-.9-3.8 8.5 8.5 0 014.7-7.6 8.38 8.38 0 013.8-.9h.5a8.48 8.48 0 018 8v.5z"/></svg></div><div class="mon-alert-label">Stride</div></div>
            <div class="mon-alert-cell"><div class="mon-alert-ico"><svg viewBox="0 0 24 24" fill="none" stroke="#06ac38" stroke-width="2"><circle cx="12" cy="12" r="10"/><path d="M8 12l2.5 2.5L16 9"/></svg></div><div class="mon-alert-label">PagerDuty</div></div>
            <div class="mon-alert-cell"><div class="mon-alert-ico"><svg viewBox="0 0 24 24" fill="none" stroke="#2aabee" stroke-width="2"><path d="M22 2L11 13"/><path d="M22 2l-7 20-4-9-9-4 20-7z"/></svg></div><div class="mon-alert-label">Telegram</div></div>
            <div class="mon-alert-cell"><div class="mon-alert-ico"><svg viewBox="0 0 24 24" fill="none" stroke="#0071e3" stroke-width="2"><rect x="2" y="4" width="9" height="9" rx="1"/><rect x="13" y="4" width="9" height="9" rx="1"/><rect x="2" y="15" width="9" height="5" rx="1"/><rect x="13" y="15" width="9" height="5" rx="1"/></svg></div><div class="mon-alert-label">Microsoft 365</div></div>
            <div class="mon-alert-cell"><div class="mon-alert-ico"><svg viewBox="0 0 24 24" fill="none" stroke="#172b4d" stroke-width="2"><circle cx="12" cy="12" r="10"/><path d="M12 8v4l3 3"/></svg></div><div class="mon-alert-label">OpsGenie</div></div>
        </div>
    </section>

    {* 5. Alt rows *}
    <div class="hp-alternating">
        <div class="hp-alt-row">
            <div class="hp-alt-text">
                <div class="hp-eyebrow">{$hadrianLang.store.monAlt1Eyebrow}</div>
                <h3>{$hadrianLang.store.monAlt1Title}</h3>
                <p>{$hadrianLang.store.monAlt1Text}</p>
                <a href="#pricing" class="hp-buy-btn" style="margin-top: 20px; display: inline-block;">{$hadrianLang.store.monAlt1Cta}</a>
            </div>
            <div class="hp-alt-visual">
                <div class="visual-box" style="background: var(--color-surface-secondary); padding: 24px; flex-direction: column; gap: 14px;">
                    <div style="width: 100%; max-width: 300px; background: var(--color-surface); border-radius: 12px; padding: 14px;">
                        <div style="display: flex; align-items: center; justify-content: space-between; margin-bottom: 10px;"><span style="font-size: 11px; font-weight: 600; color: var(--color-text-primary);">Website Performance</span><span style="font-size: 10px; color: #30d158;">&bull; Healthy</span></div>
                        <svg viewBox="0 0 240 60" style="width: 100%; height: 60px;"><path d="M0,40 L30,30 L60,35 L90,20 L120,25 L150,15 L180,22 L210,10 L240,18" fill="none" stroke="#0071e3" stroke-width="2"/></svg>
                    </div>
                    <div style="display: flex; gap: 10px; width: 100%; max-width: 300px;">
                        <div style="flex: 1; background: var(--color-surface); padding: 10px; border-radius: 10px;"><div style="display: flex; align-items: start; gap: 8px;"><svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#30d158" stroke-width="2.5" style="flex-shrink: 0; margin-top: 2px;"><polyline points="20 6 9 17 4 12"/></svg><span style="font-size: 11px; color: var(--color-text-primary);">Detect outages fast</span></div></div>
                        <div style="flex: 1; background: var(--color-surface); padding: 10px; border-radius: 10px;"><div style="display: flex; align-items: start; gap: 8px;"><svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#30d158" stroke-width="2.5" style="flex-shrink: 0; margin-top: 2px;"><polyline points="20 6 9 17 4 12"/></svg><span style="font-size: 11px; color: var(--color-text-primary);">Protect revenue</span></div></div>
                        <div style="flex: 1; background: var(--color-surface); padding: 10px; border-radius: 10px;"><div style="display: flex; align-items: start; gap: 8px;"><svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#30d158" stroke-width="2.5" style="flex-shrink: 0; margin-top: 2px;"><polyline points="20 6 9 17 4 12"/></svg><span style="font-size: 11px; color: var(--color-text-primary);">Diagnose issues</span></div></div>
                    </div>
                </div>
            </div>
        </div>
        <div class="hp-alt-row reverse">
            <div class="hp-alt-text">
                <div class="hp-eyebrow">{$hadrianLang.store.monAlt2Eyebrow}</div>
                <h3>{$hadrianLang.store.monAlt2Title}</h3>
                <p>{$hadrianLang.store.monAlt2Text}</p>
                <a href="#pricing" class="hp-buy-btn" style="margin-top: 20px; display: inline-block;">{$hadrianLang.store.monAlt2Cta}</a>
            </div>
            <div class="hp-alt-visual">
                <div class="visual-box" style="background: var(--color-surface-secondary); padding: 24px;">
                    <div style="width: 100%; max-width: 300px; background: var(--color-surface); border-radius: 12px; padding: 14px;">
                        <div style="display: flex; gap: 12px; margin-bottom: 12px;">
                            <div style="flex: 1;"><div style="font-size: 10px; color: var(--color-text-tertiary); margin-bottom: 4px;">CPU</div><div style="font-size: 18px; font-weight: 700; color: var(--color-text-primary);">47%</div><div style="height: 4px; background: var(--color-surface-secondary); border-radius: 2px; margin-top: 4px;"><div style="width: 47%; height: 100%; background: #0071e3; border-radius: 2px;"></div></div></div>
                            <div style="flex: 1;"><div style="font-size: 10px; color: var(--color-text-tertiary); margin-bottom: 4px;">Memory</div><div style="font-size: 18px; font-weight: 700; color: var(--color-text-primary);">62%</div><div style="height: 4px; background: var(--color-surface-secondary); border-radius: 2px; margin-top: 4px;"><div style="width: 62%; height: 100%; background: #30d158; border-radius: 2px;"></div></div></div>
                            <div style="flex: 1;"><div style="font-size: 10px; color: var(--color-text-tertiary); margin-bottom: 4px;">Disk</div><div style="font-size: 18px; font-weight: 700; color: var(--color-text-primary);">38%</div><div style="height: 4px; background: var(--color-surface-secondary); border-radius: 2px; margin-top: 4px;"><div style="width: 38%; height: 100%; background: #ff9f0a; border-radius: 2px;"></div></div></div>
                        </div>
                        <svg viewBox="0 0 240 50" style="width: 100%; height: 50px;"><path d="M0,30 Q30,15 60,25 T120,22 T180,18 T240,15" fill="none" stroke="#0071e3" stroke-width="2"/><path d="M0,38 Q30,32 60,36 T120,30 T180,34 T240,28" fill="none" stroke="#30d158" stroke-width="2"/></svg>
                    </div>
                </div>
            </div>
        </div>
        <div class="hp-alt-row">
            <div class="hp-alt-text">
                <div class="hp-eyebrow">{$hadrianLang.store.monAlt3Eyebrow}</div>
                <h3>{$hadrianLang.store.monAlt3Title}</h3>
                <p>{$hadrianLang.store.monAlt3Text}</p>
                <a href="#pricing" class="hp-buy-btn" style="margin-top: 20px; display: inline-block;">{$hadrianLang.store.monAlt3Cta}</a>
            </div>
            <div class="hp-alt-visual">
                <div class="visual-box" style="background: var(--color-surface-secondary); padding: 24px;">
                    <div style="width: 100%; max-width: 300px;">
                        <div style="background: var(--color-surface); border-radius: 12px; padding: 14px;">
                            <div style="display: flex; align-items: center; justify-content: space-between; padding: 10px 0; border-bottom: 1px solid #f5f5f7;"><div style="display: flex; align-items: center; gap: 10px;"><svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#30d158" stroke-width="2"><polyline points="20 6 9 17 4 12"/></svg><span style="font-size: 12px; color: var(--color-text-primary);">SSL Certificate</span></div><span style="font-size: 10px; color: #30d158; font-weight: 600;">Valid</span></div>
                            <div style="display: flex; align-items: center; justify-content: space-between; padding: 10px 0; border-bottom: 1px solid #f5f5f7;"><div style="display: flex; align-items: center; gap: 10px;"><svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#30d158" stroke-width="2"><polyline points="20 6 9 17 4 12"/></svg><span style="font-size: 12px; color: var(--color-text-primary);">DNS Records</span></div><span style="font-size: 10px; color: #30d158; font-weight: 600;">OK</span></div>
                            <div style="display: flex; align-items: center; justify-content: space-between; padding: 10px 0; border-bottom: 1px solid #f5f5f7;"><div style="display: flex; align-items: center; gap: 10px;"><svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#ff9f0a" stroke-width="2"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg><span style="font-size: 12px; color: var(--color-text-primary);">Broken Links</span></div><span style="font-size: 10px; color: #ff9f0a; font-weight: 600;">2 found</span></div>
                            <div style="display: flex; align-items: center; justify-content: space-between; padding: 10px 0;"><div style="display: flex; align-items: center; gap: 10px;"><svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#30d158" stroke-width="2"><polyline points="20 6 9 17 4 12"/></svg><span style="font-size: 12px; color: var(--color-text-primary);">Page Speed</span></div><span style="font-size: 10px; color: #30d158; font-weight: 600;">A+</span></div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    {* 6. Uptime is money *}
    <section style="background: var(--color-surface-secondary); padding: 80px 22px; text-align: center;">
        <div style="max-width: 1024px; margin: 0 auto;">
            <div class="hp-eyebrow" style="color: var(--color-accent); justify-content: center; text-align: center;">{$hadrianLang.store.monUptimeEyebrow}</div>
            <h2 style="font-size: 48px; font-weight: 600; letter-spacing: -0.02em; margin: 8px 0 14px; color: var(--color-text-primary);">{$hadrianLang.store.monUptimeTitle}</h2>
            <p style="font-size: 17px; color: var(--color-text-secondary); margin: 0;">{$hadrianLang.store.monUptimeSub}</p>
            <div class="mon-uptime-row">
                <div class="mon-uptime-card"><div class="up-lbl">{$hadrianLang.store.monUptimeLabel}</div><div class="up">99.9%</div><div class="eq">=</div><div class="cost">$500</div><div class="cost-lbl">{$hadrianLang.store.monUptimeLost}</div></div>
                <div class="mon-uptime-card"><div class="up-lbl">{$hadrianLang.store.monUptimeLabel}</div><div class="up">99.8%</div><div class="eq">=</div><div class="cost">$1,000</div><div class="cost-lbl">{$hadrianLang.store.monUptimeLost}</div></div>
                <div class="mon-uptime-card"><div class="up-lbl">{$hadrianLang.store.monUptimeLabel}</div><div class="up">99.7%</div><div class="eq">=</div><div class="cost">$1,500</div><div class="cost-lbl">{$hadrianLang.store.monUptimeLost}</div></div>
                <div class="mon-uptime-card"><div class="up-lbl">{$hadrianLang.store.monUptimeLabel}</div><div class="up">98.0%</div><div class="eq">=</div><div class="cost">$10,000</div><div class="cost-lbl">{$hadrianLang.store.monUptimeLost}</div></div>
            </div>
            <p style="font-size: 12px; color: var(--color-text-tertiary); margin-top: 18px;">{$hadrianLang.store.monUptimeFootnote}</p>
        </div>
    </section>

    {* 7. Pricing with site/server toggle - prices + order wired to real plans *}
    <section class="hp-pricing-section" id="pricing" style="padding: 80px 22px;">
        <h2 style="text-align: center;">{$hadrianLang.store.monPricingTitle}</h2>
        <p class="sub">{$hadrianLang.store.monPricingSub}</p>
        <div class="hp-billing-toggle" style="margin: 0 auto 40px;">
            <button class="active" data-cycle="site">{$hadrianLang.store.monModeSite}</button>
            <button data-cycle="server">{$hadrianLang.store.monModeServer}</button>
        </div>
        <div class="mon-pane active" data-pricepane="site">
            <div class="hp-pricing-grid cols-4" >
                <div class="hp-price-card dim">
                    <div class="label">{if isset($_ws0)}{$_ws0->name|escape}{else}Lite{/if}</div>
                    <h3>{$hadrianLang.store.monSitePlan1Tagline}</h3>
                    <div class="price-row">{if isset($_ws0)}<span class="price">{if $_ws0->isFree()}$0.00{else}{$_ws0->pricing()->first()->toPrefixedString()}{/if}</span>{else}<span class="price">$0.00</span><span class="per">/mo</span>{/if}</div>
                    <ul><li>1 website</li><li>10 min intervals</li><li>Email alerts only</li><li>24 hour retention</li></ul>
                    <a class="buy" href="{if isset($_ws0)}{$WEB_ROOT}/cart.php?a=add&amp;pid={$_ws0->id}{else}#pricing{/if}">{$hadrianLang.store.monOrder}</a>
                </div>
                <div class="hp-price-card dim">
                    <div class="label">{if isset($_ws1)}{$_ws1->name|escape}{else}Personal{/if}</div>
                    <h3>{$hadrianLang.store.monSitePlan2Tagline}</h3>
                    <div class="price-row">{if isset($_ws1)}<span class="price">{if $_ws1->isFree()}$0.00{else}{$_ws1->pricing()->first()->toPrefixedString()}{/if}</span>{else}<span class="price">$1.99</span><span class="per">/mo</span>{/if}</div>
                    <ul><li>5 websites</li><li>5 min intervals</li><li>Multi-channel alerts</li><li>30 day retention</li><li>Full Site Check</li><li>10 URL crawl depth</li></ul>
                    <a class="buy" href="{if isset($_ws1)}{$WEB_ROOT}/cart.php?a=add&amp;pid={$_ws1->id}{else}#pricing{/if}">{$hadrianLang.store.monOrder}</a>
                </div>
                <div class="hp-price-card highlight">
                    <div class="label" style="color: var(--color-accent);">{if isset($_ws2)}{$_ws2->name|escape}{else}Plus{/if}</div>
                    <h3>{$hadrianLang.store.monSitePlan3Tagline}</h3>
                    <div class="price-row">{if isset($_ws2)}<span class="price">{if $_ws2->isFree()}$0.00{else}{$_ws2->pricing()->first()->toPrefixedString()}{/if}</span>{else}<span class="price">$2.99</span><span class="per">/mo</span>{/if}</div>
                    <ul><li>15 websites</li><li>60 second intervals</li><li>Multi-channel alerts</li><li>30 day retention</li><li>Full Site Check</li><li>150 URL crawl depth</li></ul>
                    <a class="buy" href="{if isset($_ws2)}{$WEB_ROOT}/cart.php?a=add&amp;pid={$_ws2->id}{else}#pricing{/if}">{$hadrianLang.store.monOrder}</a>
                </div>
                <div class="hp-price-card dim">
                    <div class="label">{if isset($_ws3)}{$_ws3->name|escape}{else}Advanced{/if}</div>
                    <h3>{$hadrianLang.store.monSitePlan4Tagline}</h3>
                    <div class="price-row">{if isset($_ws3)}<span class="price">{if $_ws3->isFree()}$0.00{else}{$_ws3->pricing()->first()->toPrefixedString()}{/if}</span>{else}<span class="price">$5.99</span><span class="per">/mo</span>{/if}</div>
                    <ul><li>50 websites</li><li>60 second intervals</li><li>Multi-channel alerts</li><li>30 day retention</li><li>High-priority crawls</li><li>500 URL crawl depth</li></ul>
                    <a class="buy" href="{if isset($_ws3)}{$WEB_ROOT}/cart.php?a=add&amp;pid={$_ws3->id}{else}#pricing{/if}">{$hadrianLang.store.monOrder}</a>
                </div>
            </div>
        </div>
        <div class="mon-pane" data-pricepane="server">
            <div class="hp-pricing-grid" >
                <div class="hp-price-card dim">
                    <div class="label">{if isset($_sv0)}{$_sv0->name|escape}{else}Pro{/if}</div>
                    <h3>{$hadrianLang.store.monSrvPlan1Tagline}</h3>
                    <div class="price-row">{if isset($_sv0)}<span class="price">{if $_sv0->isFree()}$0.00{else}{$_sv0->pricing()->first()->toPrefixedString()}{/if}</span>{else}<span class="price">$4.99</span><span class="per">/mo</span>{/if}</div>
                    <ul><li>1 server</li><li>20 websites</li><li>60 second intervals</li><li>Multi-channel alerts</li><li>High-priority crawls</li><li>500 URL crawl depth</li></ul>
                    <a class="buy" href="{if isset($_sv0)}{$WEB_ROOT}/cart.php?a=add&amp;pid={$_sv0->id}{else}#pricing{/if}">{$hadrianLang.store.monOrder}</a>
                </div>
                <div class="hp-price-card highlight">
                    <div class="label" style="color: var(--color-accent);">{if isset($_sv1)}{$_sv1->name|escape}{else}Business{/if}</div>
                    <h3>{$hadrianLang.store.monSrvPlan2Tagline}</h3>
                    <div class="price-row">{if isset($_sv1)}<span class="price">{if $_sv1->isFree()}$0.00{else}{$_sv1->pricing()->first()->toPrefixedString()}{/if}</span>{else}<span class="price">$24.99</span><span class="per">/mo</span>{/if}</div>
                    <ul><li>10 servers</li><li>200 websites</li><li>3 concurrent crawls</li><li>Multi-channel alerts</li><li>Recurring scheduled crawls</li><li>1,000 URL crawl depth</li></ul>
                    <a class="buy" href="{if isset($_sv1)}{$WEB_ROOT}/cart.php?a=add&amp;pid={$_sv1->id}{else}#pricing{/if}">{$hadrianLang.store.monOrder}</a>
                </div>
                <div class="hp-price-card dim">
                    <div class="label">{if isset($_sv2)}{$_sv2->name|escape}{else}Enterprise{/if}</div>
                    <h3>{$hadrianLang.store.monSrvPlan3Tagline}</h3>
                    <div class="price-row">{if isset($_sv2)}<span class="price">{if $_sv2->isFree()}$0.00{else}{$_sv2->pricing()->first()->toPrefixedString()}{/if}</span>{else}<span class="price">$99.99</span><span class="per">/mo</span>{/if}</div>
                    <ul><li>100 servers</li><li>2,000 websites</li><li>5 concurrent crawls</li><li>Multi-channel alerts</li><li>Recurring scheduled crawls</li><li>1,500 URL crawl depth</li></ul>
                    <a class="buy" href="{if isset($_sv2)}{$WEB_ROOT}/cart.php?a=add&amp;pid={$_sv2->id}{else}#pricing{/if}">{$hadrianLang.store.monOrder}</a>
                </div>
            </div>
        </div>
    </section>

    {* 8. Intel duo - 24/7 support *}
    <section class="hp-intel-duo">
        <div class="hp-intel-big">
            <div class="eyebrow">{$hadrianLang.store.monSupportEyebrow}</div>
            <h2>{$hadrianLang.store.monSupportTitle}</h2>
            <p><strong>{$hadrianLang.store.monSupportStrong}</strong> {$hadrianLang.store.monSupportText}</p>
            <a href="{$WEB_ROOT}/submitticket.php" class="link">{$hadrianLang.store.monSupportLink} &rsaquo;</a>
            <div class="intel-visual" style="display: flex; align-items: center; justify-content: center; padding: 48px; min-height: 300px;">
                <div style="background: var(--color-surface); border-radius: 18px; padding: 24px; width: 100%; max-width: 420px; box-shadow: 0 8px 32px rgba(0,0,0,0.08);">
                    <div style="display: flex; gap: 10px; margin-bottom: 18px;">
                        <div style="width: 52px; height: 52px; border-radius: 50%; background-image: url('https://i.pravatar.cc/96?u=amelia'); background-size: cover; border: 2px solid #fff; box-shadow: 0 0 0 2px #e8e8ed;"></div>
                        <div style="width: 52px; height: 52px; border-radius: 50%; background-image: url('https://i.pravatar.cc/96?u=james2'); background-size: cover; border: 2px solid #fff; box-shadow: 0 0 0 2px #e8e8ed;"></div>
                        <div style="width: 52px; height: 52px; border-radius: 50%; background-image: url('https://i.pravatar.cc/96?u=sophia'); background-size: cover; border: 2px solid #fff; box-shadow: 0 0 0 2px #e8e8ed;"></div>
                        <div style="width: 52px; height: 52px; border-radius: 50%; background: var(--color-surface-secondary); display: flex; align-items: center; justify-content: center; font-size: 12px; font-weight: 600; color: var(--color-text-tertiary); border: 2px solid #fff; box-shadow: 0 0 0 2px #e8e8ed;">+12</div>
                    </div>
                    <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 10px;">
                        <div style="padding: 14px; background: var(--color-surface-secondary); border-radius: 12px;"><div style="font-size: 10px; color: var(--color-text-tertiary);">Response time</div><div style="font-size: 26px; font-weight: 700; color: var(--color-text-primary);">&lt; 15m</div></div>
                        <div style="padding: 14px; background: #e8f8ed; border-radius: 12px;"><div style="font-size: 10px; color: #1a7f37;">Online now</div><div style="font-size: 26px; font-weight: 700; color: #1a7f37;">24/7</div></div>
                    </div>
                </div>
            </div>
        </div>
        <div class="hp-intel-small">
            <div class="intel-small-shot" style="display: flex; align-items: center; justify-content: center; background: linear-gradient(135deg, #eaf4ff, #dbeafe); padding: 40px;">
                <div style="background: var(--color-surface); border-radius: 14px; padding: 16px; width: 100%; max-width: 280px; box-shadow: 0 8px 24px rgba(0,0,0,0.08);">
                    <div style="font-size: 11px; font-weight: 600; color: var(--color-text-primary); margin-bottom: 10px;">Support ticket &middot; #4821</div>
                    <div style="padding: 10px; background: var(--color-surface-secondary); border-radius: 8px; margin-bottom: 8px;"><div style="font-size: 10px; color: var(--color-text-tertiary); margin-bottom: 2px;">You &middot; 2 min ago</div><div style="font-size: 11px; color: var(--color-text-primary);">Uptime dropped below 99% overnight</div></div>
                    <div style="padding: 10px; background: #e8f0ff; border-radius: 8px;"><div style="font-size: 10px; color: var(--color-accent); margin-bottom: 2px;">Amelia &middot; 14 min ago</div><div style="font-size: 11px; color: var(--color-text-primary);">Investigated the probe logs &mdash; DNS hiccup at the LA edge. Patched. Monitoring now.</div></div>
                </div>
            </div>
            <div class="intel-small-content">
                <div class="icon-badge">&#10022;</div>
                <h3>{$hadrianLang.store.monKnowledgeTitle}</h3>
                <p>{$hadrianLang.store.monKnowledgeText}</p>
            </div>
        </div>
    </section>

    {* 9. Trust bar *}
    <section class="hp-trust-bar">
        <div class="trust-inner">
            <div class="hp-hero-stat"><div class="stat-num" style="font-size: 48px; color: var(--color-text-primary);">99.99%</div><div class="stat-label">{$hadrianLang.store.monTrust1}</div></div>
            <div class="hp-hero-stat"><div class="stat-num" style="font-size: 48px; color: var(--color-text-primary);">60s</div><div class="stat-label">{$hadrianLang.store.monTrust2}</div></div>
            <div class="hp-hero-stat"><div class="stat-num" style="font-size: 48px; color: var(--color-text-primary);">27</div><div class="stat-label">{$hadrianLang.store.monTrust3}</div></div>
            <div class="hp-hero-stat"><div class="stat-num" style="font-size: 48px; color: var(--color-text-primary);">&lt;15m</div><div class="stat-label">{$hadrianLang.store.monTrust4}</div></div>
        </div>
    </section>

    {* 10. Testimonials - decorative, kept verbatim *}
    <section class="hp-testi-masonry">
        <h2>{$hadrianLang.store.monTestiTitle}</h2>
        <p class="hp-testi-masonry-sub">{$hadrianLang.store.monTestiSub}</p>
        <div class="hp-testi-masonry-grid">
            <div class="hp-testi-tile"><div class="stars">&starf;&starf;&starf;&starf;&starf;</div><p class="quote">I&rsquo;m amazed by the quality. My website runs smoothly &mdash; the performance boost is instantly noticeable thanks to their monitoring.</p><div class="author"><div class="avatar" style="background-image:url('https://i.pravatar.cc/96?u=robertjohanson');"></div><div><div class="name">Robert Johanson</div><div class="role">FreshStack</div></div></div></div>
            <div class="hp-testi-tile tall accent"><div class="stars">&starf;&starf;&starf;&starf;&starf;</div><p class="quote">Having 360 makes my hosting stable and ridiculously easy. Notifications, dashboards, the speed problems are surfaced &mdash; all top-tier.</p><div class="author"><div class="avatar" style="background-image:url('https://i.pravatar.cc/96?u=michaelsmith');"></div><div><div class="name">Michael Smith</div><div class="role">GrowthLab</div></div></div></div>
            <div class="hp-testi-tile"><div class="stars">&starf;&starf;&starf;&starf;&starf;</div><p class="quote">Five star service! Their commitment to responsive support and stability has transformed my operations.</p><div class="author"><div class="avatar" style="background-image:url('https://i.pravatar.cc/96?u=davidwilson');"></div><div><div class="name">David Wilson</div><div class="role">Studio34</div></div></div></div>
            <div class="hp-testi-tile"><div class="stars">&starf;&starf;&starf;&starf;&starf;</div><p class="quote">Thoroughly impressed. The standout for me is their outstanding customer support.</p><div class="author"><div class="avatar" style="background-image:url('https://i.pravatar.cc/96?u=michaelbrown');"></div><div><div class="name">Michael Brown</div><div class="role">NextLabs</div></div></div></div>
            <div class="hp-testi-tile dark"><div class="stars">&starf;&starf;&starf;&starf;&starf;</div><p class="quote">Very helpful support. Fast response, real engineers &mdash; every time.</p><div class="author"><div class="avatar" style="background-image:url('https://i.pravatar.cc/96?u=johndoe');"></div><div><div class="name">John Doe</div><div class="role">Indie Developer</div></div></div></div>
            <div class="hp-testi-tile tall cream"><div class="stars">&starf;&starf;&starf;&starf;&starf;</div><p class="quote">Easy setup and clean dashboards. 360&rsquo;s reports saved us from two overnight outages &mdash; we caught them before customers did.</p><div class="author"><div class="avatar" style="background-image:url('https://i.pravatar.cc/96?u=ritawilliams');"></div><div><div class="name">Rita Williams</div><div class="role">PixelAgency</div></div></div></div>
        </div>
    </section>

    {* 11. FAQ *}
    <section class="hp-faq-section">
        <h2>{$hadrianLang.store.monFaqTitle}</h2>
        <details class="hp-faq-item" open><summary>{$hadrianLang.store.monFaqQ1}</summary><div class="faq-body">{$hadrianLang.store.monFaqA1}</div></details>
        <details class="hp-faq-item"><summary>{$hadrianLang.store.monFaqQ2}</summary><div class="faq-body">{$hadrianLang.store.monFaqA2}</div></details>
        <details class="hp-faq-item"><summary>{$hadrianLang.store.monFaqQ3}</summary><div class="faq-body">{$hadrianLang.store.monFaqA3}</div></details>
        <details class="hp-faq-item"><summary>{$hadrianLang.store.monFaqQ4}</summary><div class="faq-body">{$hadrianLang.store.monFaqA4}</div></details>
        <details class="hp-faq-item"><summary>{$hadrianLang.store.monFaqQ5}</summary><div class="faq-body">{$hadrianLang.store.monFaqA5}</div></details>
        <details class="hp-faq-item"><summary>{$hadrianLang.store.monFaqQ6}</summary><div class="faq-body">{$hadrianLang.store.monFaqA6}</div></details>
        <details class="hp-faq-item"><summary>{$hadrianLang.store.monFaqQ7}</summary><div class="faq-body">{$hadrianLang.store.monFaqA7}</div></details>
        <details class="hp-faq-item"><summary>{$hadrianLang.store.monFaqQ8}</summary><div class="faq-body">{$hadrianLang.store.monFaqA8}</div></details>
    </section>

    {* 12. Split CTA *}
    <div class="hp-split-cta-wrapper" style="padding: 48px 22px;">
        <div class="hp-split-cta">
            <div class="cta-panel dark">
                <h3>{$hadrianLang.store.monCtaDarkTitle}</h3>
                <p>{$hadrianLang.store.monCtaDarkText}</p>
                <a href="#pricing" class="btn-primary-pill">{$hadrianLang.store.monCtaDarkBtn}</a>
            </div>
            <div class="cta-panel light">
                <h3>{$hadrianLang.store.monCtaLightTitle}</h3>
                <p>{$hadrianLang.store.monCtaLightText}</p>
                <a href="{$WEB_ROOT}/submitticket.php" class="btn-outline-pill">{$hadrianLang.store.monCtaLightBtn}</a>
            </div>
        </div>
    </div>
</div>

<div class="when-empty" style="text-align:center;padding:60px 24px;background:var(--color-surface);border:1px solid var(--color-border);border-radius:14px;">
    <div style="width:56px;height:56px;border-radius:50%;background:var(--color-bg);display:inline-flex;align-items:center;justify-content:center;margin-bottom:16px;color:var(--color-text-tertiary);">
        <svg viewBox="0 0 24 24" width="22" height="22" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg>
    </div>
    <p style="font-size:17px;font-weight:600;color:var(--color-text-primary);margin:0 0 6px;">{$hadrianLang.store.monEmptyTitle}</p>
    <p style="font-size:14px;color:var(--color-text-secondary);margin:0 0 20px;max-width:380px;margin-left:auto;margin-right:auto;line-height:1.5;">{$hadrianLang.store.monEmptyText}</p>
    <a href="{$WEB_ROOT}/" class="btn-primary">{$hadrianLang.store.monEmptyHome}</a>
</div>

{literal}
<script>
(function () {
    function wireToggle(buttonSel, paneAttr, key) {
        document.querySelectorAll(buttonSel).forEach(function (btn) {
            btn.addEventListener('click', function () {
                var val = btn.getAttribute(key);
                btn.parentNode.querySelectorAll('button').forEach(function (b) {
                    var on = b.getAttribute(key) === val;
                    b.classList.toggle('active', on);
                    if (b.hasAttribute('aria-selected')) b.setAttribute('aria-selected', on ? 'true' : 'false');
                });
                document.querySelectorAll('[' + paneAttr + ']').forEach(function (p) {
                    p.classList.toggle('active', p.getAttribute(paneAttr) === val);
                });
            });
        });
    }
    wireToggle('.mon-mode-toggle button', 'data-pane', 'data-mode');
    wireToggle('.mon-subtabs button', 'data-featpane', 'data-feat');
    wireToggle('#pricing .hp-billing-toggle button', 'data-pricepane', 'data-cycle');
})();
</script>
{/literal}
