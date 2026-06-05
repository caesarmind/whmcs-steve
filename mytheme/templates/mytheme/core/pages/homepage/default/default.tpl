{* Hostnodes - Public marketing homepage (Apple "Hosting, redesigned").

   Ported from apple-client-area/homepage.html. The mockup is a full standalone
   page; header.tpl/footer.tpl already provide the nav + footer, so we emit only
   the inner content. The hero keeps the working domain-search form + captcha
   from the previous portal homepage (now preserved as the 'portal' variant).

   Reuses the hp-* marketing classes (already in apple-theme.css, zero CSS work)
   and the ph-domain-* hero-form classes (homepage.css). Static marketing copy
   is tokenized into the hadrianLang 'home' group; representative pricing/specs
   and decorative illustration blocks are kept verbatim. CTAs point at real
   WHMCS routes (domainchecker.php / cart.php).

   WHMCS variables expected: $loggedin, $companyname, $LANG.*, $captcha. *}

{assign var=_hTitle value=$myTheme.pages.homepage.config.heroTitle|default:''}
{assign var=_hSub value=$myTheme.pages.homepage.config.heroSubtitle|default:''}

<link rel="stylesheet" href="{$WEB_ROOT}/templates/{$template}/assets/css/pages/homepage.css?v={$myTheme.version|default:'1.0'}">

{* 1. Hero - "Hosting, redesigned" + working domain search *}
<section class="hp-hero" style="padding: 96px 22px 40px; background: transparent;">
    <div class="hp-eyebrow">{$hadrianLang.home.heroEyebrow}</div>
    <h1>{if $_hTitle != ''}{$_hTitle}{else}{$hadrianLang.home.heroTitle}{/if}</h1>
    <p class="hp-subhead">{if $_hSub != ''}{$_hSub}{else}{$hadrianLang.home.heroSubtitle}{/if}</p>

    {* Working domain search (reused from the portal homepage) *}
    <form class="ph-domain-form" action="{$WEB_ROOT}/domainchecker.php" method="post" style="max-width: 600px; margin: 28px auto 0;">
        <div class="ph-domain-tabs" role="tablist">
            <button type="button" class="active" data-dtab="search" role="tab" aria-selected="true">{$LANG.search}</button>
            <button type="button" data-dtab="transfer" role="tab" aria-selected="false">{$LANG.transferdomain}</button>
        </div>
        <div class="ph-domain-box">
            <svg class="search-ico" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
            <input type="text" name="domain" placeholder="{$LANG.exampledomain}" autocapitalize="none" autocomplete="off">
            <button type="submit" id="domainCta" class="{if isset($captcha) && $captcha}{$captcha->getButtonClass($captchaForm)}{/if}">{$LANG.search}</button>
        </div>
        {if isset($captcha) && $captcha->isEnabled() && $captcha->isEnabledForForm($captchaForm)}
        <div class="ph-captcha">{include file="`$template`/includes/captcha.tpl"}</div>
        {/if}
        <div class="ph-domain-footer">
            <span>{$hadrianLang.dashboard.heroDomainSubtitle}</span>
            <a href="{$WEB_ROOT}/cart.php?gid=domain">{$LANG.viewallpricing|default:'View all pricing'} &rarr;</a>
        </div>
    </form>

    <div class="hp-cta-row" style="margin-top: 20px;">
        <a href="{$WEB_ROOT}/cart.php" class="hp-buy-btn">{$hadrianLang.home.heroCta}</a>
        <a href="#how">{$hadrianLang.home.heroSecondary} &rsaquo;</a>
    </div>
    <div style="display: inline-flex; align-items: center; gap: 10px; margin-top: 28px; padding: 10px 18px; background: var(--color-surface-secondary); border-radius: 999px;">
        <span style="color: #30d158; font-size: 15px; letter-spacing: 1px;">&starf;&starf;&starf;&starf;&starf;</span>
        <span style="font-size: 13px; font-weight: 500; color: var(--color-text-primary);"><strong>{$hadrianLang.home.trustStrong}</strong> &middot; {$hadrianLang.home.trustText}</span>
    </div>
</section>

{* 2. Trust stats strip *}
<section class="hp-stats-strip" style="padding: 48px 22px;">
    <div class="stats-inner">
        <div class="hp-stat"><div class="stat-num">10K+</div><div class="stat-label">{$hadrianLang.home.stat1}</div></div>
        <div class="hp-stat"><div class="stat-num">99.9%</div><div class="stat-label">{$hadrianLang.home.stat2}</div></div>
        <div class="hp-stat"><div class="stat-num">&lt; 1s</div><div class="stat-label">{$hadrianLang.home.stat3}</div></div>
        <div class="hp-stat"><div class="stat-num">24/7</div><div class="stat-label">{$hadrianLang.home.stat4}</div></div>
    </div>
</section>

{* 3. cPanel comparison - duo *}
<section id="how" style="padding: 72px 22px 24px; text-align: center; max-width: 900px; margin: 0 auto;">
    <div class="hp-eyebrow" style="color: var(--color-accent);">{$hadrianLang.home.duoEyebrow}</div>
    <h2 style="font-size: 48px; font-weight: 600; letter-spacing: -0.02em; margin: 12px 0;">{$hadrianLang.home.duoTitle}</h2>
    <p style="font-size: 17px; color: #6e6e73; max-width: 600px; margin: 0 auto;">{$hadrianLang.home.duoSub}</p>
</section>
<section class="hp-duo-feature">
    <div class="hp-duo-card">
        <p class="duo-text"><strong>{$hadrianLang.home.duoOldStrong}</strong> {$hadrianLang.home.duoOldText}</p>
        <div class="duo-visual duo-visual--left">
            <div style="width: 100%; height: 100%; background: linear-gradient(135deg, #1c1c1e, #2c2c2e); border-radius: 14px; display: flex; align-items: center; justify-content: center; padding: 30px;">
                <div style="background: #0f0f12; border-radius: 10px; padding: 14px; width: 100%; max-width: 320px; border: 1px solid #2a2a2c;">
                    <div style="display: grid; grid-template-columns: repeat(4, 1fr); gap: 4px;">
                        <div style="height: 24px; background: rgba(255,255,255,0.08); border-radius: 3px;"></div><div style="height: 24px; background: rgba(255,255,255,0.08); border-radius: 3px;"></div><div style="height: 24px; background: rgba(255,255,255,0.08); border-radius: 3px;"></div><div style="height: 24px; background: rgba(255,255,255,0.08); border-radius: 3px;"></div><div style="height: 24px; background: rgba(255,255,255,0.08); border-radius: 3px;"></div><div style="height: 24px; background: rgba(255,255,255,0.08); border-radius: 3px;"></div><div style="height: 24px; background: rgba(255,255,255,0.08); border-radius: 3px;"></div><div style="height: 24px; background: rgba(255,255,255,0.08); border-radius: 3px;"></div><div style="height: 24px; background: rgba(255,255,255,0.08); border-radius: 3px;"></div><div style="height: 24px; background: rgba(255,255,255,0.08); border-radius: 3px;"></div><div style="height: 24px; background: rgba(255,255,255,0.08); border-radius: 3px;"></div><div style="height: 24px; background: rgba(255,255,255,0.08); border-radius: 3px;"></div>
                    </div>
                    <div style="margin-top: 10px; font-size: 10px; color: rgba(255,255,255,0.3); text-align: center;">47 menu items &middot; 12 toolbars</div>
                </div>
            </div>
        </div>
    </div>
    <div class="hp-duo-card">
        <p class="duo-text"><strong>{$hadrianLang.home.duoNewStrong}</strong> {$hadrianLang.home.duoNewText}</p>
        <div class="duo-visual duo-visual--right">
            <div style="width: 100%; height: 100%; background: linear-gradient(135deg, #0a84ff, #64d2ff); border-radius: 14px; display: flex; align-items: center; justify-content: center; padding: 30px;">
                <div style="background: #fff; border-radius: 10px; padding: 16px; width: 100%; max-width: 260px; box-shadow: 0 12px 32px rgba(0,0,0,0.2);">
                    <div style="display: flex; align-items: center; gap: 8px; padding-bottom: 10px; border-bottom: 1px solid #f5f5f7;"><div style="width: 8px; height: 8px; background: #30d158; border-radius: 50%;"></div><span style="font-size: 11px; font-weight: 600; color: #1d1d1f;">OpenPanel</span></div>
                    <div style="display: flex; flex-direction: column; gap: 8px; margin-top: 12px;">
                        <div style="display: flex; align-items: center; gap: 10px; padding: 6px 0;"><div style="width: 14px; height: 14px; background: rgba(0,113,227,0.1); border-radius: 4px;"></div><span style="font-size: 11px; color: #1d1d1f;">Sites</span></div>
                        <div style="display: flex; align-items: center; gap: 10px; padding: 6px 0;"><div style="width: 14px; height: 14px; background: rgba(48,209,88,0.1); border-radius: 4px;"></div><span style="font-size: 11px; color: #1d1d1f;">Resources</span></div>
                        <div style="display: flex; align-items: center; gap: 10px; padding: 6px 0;"><div style="width: 14px; height: 14px; background: rgba(191,90,242,0.1); border-radius: 4px;"></div><span style="font-size: 11px; color: #1d1d1f;">Backups</span></div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</section>

{* 4. Isolation - 4-up icon grid *}
<section class="hp-icon-grid" style="padding: 72px 22px 48px;">
    <div style="grid-column: 1 / -1; text-align: center; max-width: 800px; margin: 0 auto 40px;">
        <div class="hp-eyebrow" style="color: var(--color-accent);">{$hadrianLang.home.isoEyebrow}</div>
        <h2 style="font-size: 40px; font-weight: 600; letter-spacing: -0.02em; margin: 12px 0;">{$hadrianLang.home.isoTitle}</h2>
        <p style="font-size: 17px; color: #6e6e73;">{$hadrianLang.home.isoSub}</p>
    </div>
    <div class="hp-icon-item">
        <div class="icon-circle blue"><svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><ellipse cx="12" cy="5" rx="9" ry="3"/><path d="M21 12c0 1.66-4.03 3-9 3s-9-1.34-9-3"/><path d="M3 5v14c0 1.66 4.03 3 9 3s9-1.34 9-3V5"/></svg></div>
        <h4>{$hadrianLang.home.iso1Title}</h4>
        <p>{$hadrianLang.home.iso1Text}</p>
    </div>
    <div class="hp-icon-item">
        <div class="icon-circle purple"><svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="16 18 22 12 16 6"/><polyline points="8 6 2 12 8 18"/></svg></div>
        <h4>{$hadrianLang.home.iso2Title}</h4>
        <p>{$hadrianLang.home.iso2Text}</p>
    </div>
    <div class="hp-icon-item">
        <div class="icon-circle red"><svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M13 2L3 14h9l-1 8 10-12h-9l1-8z"/></svg></div>
        <h4>{$hadrianLang.home.iso3Title}</h4>
        <p>{$hadrianLang.home.iso3Text}</p>
    </div>
    <div class="hp-icon-item">
        <div class="icon-circle green"><svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="2" y="2" width="20" height="8" rx="2"/><rect x="2" y="14" width="20" height="8" rx="2"/></svg></div>
        <h4>{$hadrianLang.home.iso4Title}</h4>
        <p>{$hadrianLang.home.iso4Text}</p>
    </div>
</section>

{* 5. OpenPanel spotlight *}
<div style="background: var(--color-surface-secondary);">
<section class="hp-feature-spotlight" style="padding: 72px 22px;">
    <div class="spotlight-inner" style="max-width: 1100px; margin: 0 auto; display: grid; grid-template-columns: 1fr 1.2fr; gap: 60px; align-items: center;">
        <div>
            <div class="hp-eyebrow" style="color: var(--color-accent);">{$hadrianLang.home.spotEyebrow}</div>
            <h2 style="font-size: 44px; font-weight: 600; letter-spacing: -0.02em; margin: 12px 0;">{$hadrianLang.home.spotTitle}</h2>
            <p style="font-size: 17px; color: #6e6e73; line-height: 1.5;">{$hadrianLang.home.spotText}</p>
            <div style="display: grid; grid-template-columns: repeat(3, 1fr); gap: 16px; margin-top: 32px;">
                <div><div style="font-size: 28px; font-weight: 700; color: #1d1d1f;">12</div><div style="font-size: 12px; color: #86868b;">{$hadrianLang.home.spotStat1}</div></div>
                <div><div style="font-size: 28px; font-weight: 700; color: #30d158;">99.9%</div><div style="font-size: 12px; color: #86868b;">{$hadrianLang.home.spotStat2}</div></div>
                <div><div style="font-size: 28px; font-weight: 700; color: var(--color-accent);">14 GB</div><div style="font-size: 12px; color: #86868b;">{$hadrianLang.home.spotStat3}</div></div>
            </div>
        </div>
        <div>
            <div style="background: #fff; border-radius: 18px; padding: 12px; box-shadow: 0 24px 60px rgba(0,0,0,0.10); overflow: hidden;">
                <div style="display: flex; gap: 5px; margin-bottom: 10px; padding: 4px 8px;"><span style="width: 8px; height: 8px; background: #ff453a; border-radius: 50%;"></span><span style="width: 8px; height: 8px; background: #ff9f0a; border-radius: 50%;"></span><span style="width: 8px; height: 8px; background: #30d158; border-radius: 50%;"></span></div>
                <div style="display: grid; grid-template-columns: 140px 1fr; gap: 12px; min-height: 320px;">
                    <div style="background: #f5f5f7; border-radius: 12px; padding: 14px; display: flex; flex-direction: column; gap: 4px;">
                        <div style="padding: 8px; background: #fff; border-radius: 8px; font-size: 11px; font-weight: 600; color: var(--color-accent); display: flex; align-items: center; gap: 6px;"><svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="3" width="7" height="7"/><rect x="14" y="3" width="7" height="7"/><rect x="3" y="14" width="7" height="7"/><rect x="14" y="14" width="7" height="7"/></svg>Dashboard</div>
                        <div style="padding: 8px; font-size: 11px; color: #1d1d1f; display: flex; align-items: center; gap: 6px;"><svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/><line x1="2" y1="12" x2="22" y2="12"/></svg>Sites</div>
                        <div style="padding: 8px; font-size: 11px; color: #1d1d1f; display: flex; align-items: center; gap: 6px;"><svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><ellipse cx="12" cy="5" rx="9" ry="3"/><path d="M3 5v14c0 1.66 4.03 3 9 3s9-1.34 9-3V5"/></svg>Databases</div>
                        <div style="padding: 8px; font-size: 11px; color: #1d1d1f; display: flex; align-items: center; gap: 6px;"><svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"/><polyline points="22 6 12 13 2 6"/></svg>Email</div>
                        <div style="padding: 8px; font-size: 11px; color: #1d1d1f; display: flex; align-items: center; gap: 6px;"><svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="1 4 1 10 7 10"/><path d="M3.51 15a9 9 0 102.13-9.36L1 10"/></svg>Backups</div>
                    </div>
                    <div style="display: flex; flex-direction: column; gap: 10px;">
                        <div style="display: grid; grid-template-columns: repeat(3, 1fr); gap: 8px;">
                            <div style="background: #f5f5f7; border-radius: 10px; padding: 12px;"><div style="font-size: 10px; color: #86868b;">{$hadrianLang.home.spotStat1}</div><div style="font-size: 22px; font-weight: 700; color: #1d1d1f; margin-top: 2px;">12</div></div>
                            <div style="background: #e8f8ed; border-radius: 10px; padding: 12px;"><div style="font-size: 10px; color: #1a7f37;">{$hadrianLang.home.spotStat2}</div><div style="font-size: 22px; font-weight: 700; color: #1a7f37; margin-top: 2px;">99.9%</div></div>
                            <div style="background: #eaf4ff; border-radius: 10px; padding: 12px;"><div style="font-size: 10px; color: var(--color-accent);">Storage</div><div style="font-size: 22px; font-weight: 700; color: var(--color-accent); margin-top: 2px;">14 GB</div></div>
                        </div>
                        <div style="background: #f5f5f7; border-radius: 12px; padding: 12px;">
                            <div style="font-size: 11px; font-weight: 600; color: #1d1d1f; margin-bottom: 10px;">Your sites</div>
                            <div style="display: flex; flex-direction: column; gap: 6px;">
                                <div style="display: flex; align-items: center; gap: 10px; padding: 8px; background: #fff; border-radius: 8px;"><span style="width: 6px; height: 6px; background: #30d158; border-radius: 50%;"></span><span style="font-size: 11px; color: #1d1d1f; flex: 1;">morganstudio.com</span><span style="font-size: 10px; color: #30d158; font-weight: 600;">Running</span></div>
                                <div style="display: flex; align-items: center; gap: 10px; padding: 8px; background: #fff; border-radius: 8px;"><span style="width: 6px; height: 6px; background: #30d158; border-radius: 50%;"></span><span style="font-size: 11px; color: #1d1d1f; flex: 1;">alexmorgan.io</span><span style="font-size: 10px; color: #30d158; font-weight: 600;">Running</span></div>
                                <div style="display: flex; align-items: center; gap: 10px; padding: 8px; background: #fff; border-radius: 8px;"><span style="width: 6px; height: 6px; background: #30d158; border-radius: 50%;"></span><span style="font-size: 11px; color: #1d1d1f; flex: 1;">ourstudio.design</span><span style="font-size: 10px; color: #30d158; font-weight: 600;">Running</span></div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</section>
</div>

{* 6. Data centers - locations *}
<section class="hp-locations-section" style="padding: 72px 22px;">
    <h2 style="font-size: 48px; font-weight: 600; letter-spacing: -0.02em; margin-bottom: 12px;">{$hadrianLang.home.locTitle}</h2>
    <p class="loc-sub">{$hadrianLang.home.locSub}</p>
    <div class="hp-loc-grid" style="grid-template-columns: 1fr 1fr; max-width: 1000px; margin: 40px auto 0;">
        <div class="hp-loc-card" style="padding: 32px;">
            <div class="loc-flag" style="font-size: 42px; margin-bottom: 16px;">&#127465;&#127466;</div>
            <h4 style="font-size: 22px;">{$hadrianLang.home.loc1Title}</h4>
            <p style="margin-bottom: 16px;">{$hadrianLang.home.loc1Coverage}</p>
            <div style="display: flex; flex-direction: column; gap: 6px; font-size: 13px;">
                <div style="display: flex; align-items: center; gap: 8px;"><span style="color: #86868b;">{$hadrianLang.home.locInfraLabel} &middot;</span><span style="color: var(--color-text-primary); font-weight: 500;">Google Cloud &middot; europe-west3</span></div>
                <div style="display: flex; align-items: center; gap: 8px;"><span style="color: #86868b;">{$hadrianLang.home.locComplianceLabel} &middot;</span><span style="color: var(--color-text-primary); font-weight: 500;">{$hadrianLang.home.loc1Compliance}</span></div>
                <div style="display: flex; align-items: center; gap: 8px; margin-top: 8px;"><span style="width: 8px; height: 8px; background: #30d158; border-radius: 50%;"></span><span style="color: #30d158; font-weight: 600; font-size: 12px;">{$hadrianLang.home.locOnline}</span></div>
            </div>
        </div>
        <div class="hp-loc-card" style="padding: 32px;">
            <div class="loc-flag" style="font-size: 42px; margin-bottom: 16px;">&#127482;&#127480;</div>
            <h4 style="font-size: 22px;">{$hadrianLang.home.loc2Title}</h4>
            <p style="margin-bottom: 16px;">{$hadrianLang.home.loc2Coverage}</p>
            <div style="display: flex; flex-direction: column; gap: 6px; font-size: 13px;">
                <div style="display: flex; align-items: center; gap: 8px;"><span style="color: #86868b;">{$hadrianLang.home.locInfraLabel} &middot;</span><span style="color: var(--color-text-primary); font-weight: 500;">Google Cloud &middot; us-east1</span></div>
                <div style="display: flex; align-items: center; gap: 8px;"><span style="color: #86868b;">{$hadrianLang.home.locComplianceLabel} &middot;</span><span style="color: var(--color-text-primary); font-weight: 500;">{$hadrianLang.home.loc2Compliance}</span></div>
                <div style="display: flex; align-items: center; gap: 8px; margin-top: 8px;"><span style="width: 8px; height: 8px; background: #30d158; border-radius: 50%;"></span><span style="color: #30d158; font-weight: 600; font-size: 12px;">{$hadrianLang.home.locOnline}</span></div>
            </div>
        </div>
    </div>
</section>

{* 7. White-label + dev tools - intel duo *}
<section class="hp-intel-duo">
    <div class="hp-intel-big">
        <div class="eyebrow">{$hadrianLang.home.wlEyebrow}</div>
        <h2>{$hadrianLang.home.wlTitle}</h2>
        <p><strong>{$hadrianLang.home.wlStrong}</strong> {$hadrianLang.home.wlText}</p>
        <a href="{$WEB_ROOT}/cart.php" class="link">{$hadrianLang.home.wlLink} &rsaquo;</a>
        <div class="intel-visual" style="display: flex; align-items: center; justify-content: center; padding: 48px; min-height: 320px;">
            <div style="display: flex; gap: 12px; flex-wrap: wrap; justify-content: center;">
                <div style="background: #fff; border-radius: 12px; padding: 14px; box-shadow: 0 8px 24px rgba(0,0,0,0.08); min-width: 140px;"><div style="display: flex; align-items: center; gap: 6px; margin-bottom: 10px;"><div style="width: 22px; height: 22px; background: linear-gradient(135deg, #ff453a, #ff9f0a); border-radius: 6px;"></div><span style="font-size: 11px; font-weight: 600; color: #1d1d1f;">AcmeHost</span></div><div style="height: 6px; background: #ffefec; border-radius: 3px; margin-bottom: 4px;"></div><div style="height: 6px; background: #f5f5f7; border-radius: 3px; margin-bottom: 4px;"></div><div style="height: 6px; background: #f5f5f7; border-radius: 3px;"></div></div>
                <div style="background: #fff; border-radius: 12px; padding: 14px; box-shadow: 0 8px 24px rgba(0,0,0,0.12); min-width: 140px; border: 2px solid #0071e3;"><div style="display: flex; align-items: center; gap: 6px; margin-bottom: 10px;"><div style="width: 22px; height: 22px; background: linear-gradient(135deg, #0071e3, #5ac8fa); border-radius: 6px;"></div><span style="font-size: 11px; font-weight: 600; color: #1d1d1f;">Hostnodes</span></div><div style="height: 6px; background: #eaf4ff; border-radius: 3px; margin-bottom: 4px;"></div><div style="height: 6px; background: #f5f5f7; border-radius: 3px; margin-bottom: 4px;"></div><div style="height: 6px; background: #f5f5f7; border-radius: 3px;"></div></div>
                <div style="background: #fff; border-radius: 12px; padding: 14px; box-shadow: 0 8px 24px rgba(0,0,0,0.08); min-width: 140px;"><div style="display: flex; align-items: center; gap: 6px; margin-bottom: 10px;"><div style="width: 22px; height: 22px; background: linear-gradient(135deg, #30d158, #5cdb79); border-radius: 6px;"></div><span style="font-size: 11px; font-weight: 600; color: #1d1d1f;">StudioHost</span></div><div style="height: 6px; background: #e8f8ed; border-radius: 3px; margin-bottom: 4px;"></div><div style="height: 6px; background: #f5f5f7; border-radius: 3px; margin-bottom: 4px;"></div><div style="height: 6px; background: #f5f5f7; border-radius: 3px;"></div></div>
            </div>
        </div>
    </div>
    <div class="hp-intel-small">
        <div class="intel-small-shot" style="background: linear-gradient(135deg, #eaf4ff, #dbeafe); display: flex; align-items: center; justify-content: center; padding: 40px;">
            <div style="background: #fff; border-radius: 14px; padding: 20px; width: 100%; max-width: 260px; box-shadow: 0 8px 24px rgba(0,0,0,0.08);">
                <div style="font-size: 11px; font-weight: 600; color: #1d1d1f; margin-bottom: 12px;">PHP version</div>
                <div style="display: flex; flex-wrap: wrap; gap: 6px;"><span style="padding: 6px 12px; background: #0071e3; color: #fff; border-radius: 999px; font-size: 11px; font-weight: 600;">8.3</span><span style="padding: 6px 12px; background: #f5f5f7; color: #1d1d1f; border-radius: 999px; font-size: 11px;">8.2</span><span style="padding: 6px 12px; background: #f5f5f7; color: #1d1d1f; border-radius: 999px; font-size: 11px;">8.1</span><span style="padding: 6px 12px; background: #f5f5f7; color: #1d1d1f; border-radius: 999px; font-size: 11px;">8.0</span><span style="padding: 6px 12px; background: #f5f5f7; color: #1d1d1f; border-radius: 999px; font-size: 11px;">7.4</span></div>
                <div style="margin-top: 14px; padding-top: 12px; border-top: 1px solid #f5f5f7; display: flex; flex-direction: column; gap: 6px;">
                    <div style="display: flex; align-items: center; gap: 6px; font-size: 11px; color: #1d1d1f;"><svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="#30d158" stroke-width="2.5"><polyline points="20 6 9 17 4 12"/></svg>SSH &amp; SFTP access</div>
                    <div style="display: flex; align-items: center; gap: 6px; font-size: 11px; color: #1d1d1f;"><svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="#30d158" stroke-width="2.5"><polyline points="20 6 9 17 4 12"/></svg>Redis &amp; Memcached</div>
                    <div style="display: flex; align-items: center; gap: 6px; font-size: 11px; color: #1d1d1f;"><svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="#30d158" stroke-width="2.5"><polyline points="20 6 9 17 4 12"/></svg>Auto SSL via Let&rsquo;s Encrypt</div>
                </div>
            </div>
        </div>
        <div class="intel-small-content">
            <div class="icon-badge">&lt;/&gt;</div>
            <h3>{$hadrianLang.home.devTitle}</h3>
            <p><strong>{$hadrianLang.home.devStrong}</strong> {$hadrianLang.home.devText}</p>
        </div>
    </div>
</section>

{* 8. Audience - feature columns *}
<section class="hp-feature-columns" style="padding: 72px 22px;">
    <h2 style="font-size: 40px;">{$hadrianLang.home.colTitle}</h2>
    <p class="feat-sub">{$hadrianLang.home.colSub}</p>
    <div class="hp-columns-row">
        <div class="hp-column-item">
            <div class="col-num">{$hadrianLang.home.col1Num}</div>
            <h4>{$hadrianLang.home.col1Title}</h4>
            <p>{$hadrianLang.home.col1Text}</p>
            <a href="{$WEB_ROOT}/knowledgebase.php" class="col-link">{$hadrianLang.home.col1Link} &rsaquo;</a>
        </div>
        <div class="hp-column-item">
            <div class="col-num">{$hadrianLang.home.col2Num}</div>
            <h4>{$hadrianLang.home.col2Title}</h4>
            <p>{$hadrianLang.home.col2Text}</p>
            <a href="{$WEB_ROOT}/cart.php" class="col-link">{$hadrianLang.home.col2Link} &rsaquo;</a>
        </div>
        <div class="hp-column-item">
            <div class="col-num">{$hadrianLang.home.col3Num}</div>
            <h4>{$hadrianLang.home.col3Title}</h4>
            <p>{$hadrianLang.home.col3Text}</p>
            <a href="{$WEB_ROOT}/cart.php" class="col-link">{$hadrianLang.home.col3Link} &rsaquo;</a>
        </div>
    </div>
</section>

{* 9. Pricing - segmented bar (representative tiers; CTAs to the order form) *}
<section class="hp-pricing-segmented" id="pricing">
    <h2 style="font-size: 44px;">{$hadrianLang.home.pricingTitle}</h2>
    <p class="sub">{$hadrianLang.home.pricingSub}</p>
    <div class="hp-segmented-bar" style="grid-template-columns: repeat(4, 1fr);">
        <div class="hp-seg-col">
            <div class="tier">{$hadrianLang.home.tierFree}</div>
            <div class="price">$0<span class="per">{$hadrianLang.home.perForever}</span></div>
            <div class="desc">{$hadrianLang.home.tierFreeDesc}</div>
            <ul class="seg-features"><li>1 website</li><li>2 GB SSD</li><li>Free SSL</li><li>1 location</li></ul>
            <a href="{$WEB_ROOT}/cart.php" class="buy">{$hadrianLang.home.buyFree}</a>
        </div>
        <div class="hp-seg-col">
            <div class="tier">{$hadrianLang.home.tierStarter}</div>
            <div class="price">$9<span class="per">{$hadrianLang.home.perMo}</span></div>
            <div class="desc">{$hadrianLang.home.tierStarterDesc}</div>
            <ul class="seg-features"><li>5 websites</li><li>10 GB SSD</li><li>Free SSL</li><li>Daily backups</li></ul>
            <a href="{$WEB_ROOT}/cart.php" class="buy">{$hadrianLang.home.buyStarter}</a>
        </div>
        <div class="hp-seg-col highlight">
            <div class="tier">{$hadrianLang.home.tierPro}</div>
            <div class="price">$29<span class="per">{$hadrianLang.home.perMo}</span></div>
            <div class="desc">{$hadrianLang.home.tierProDesc}</div>
            <ul class="seg-features"><li>Unlimited sites</li><li>50 GB SSD</li><li>White-label</li><li>Priority support</li><li>Staging environments</li></ul>
            <a href="{$WEB_ROOT}/cart.php" class="buy">{$hadrianLang.home.buyPro}</a>
        </div>
        <div class="hp-seg-col">
            <div class="tier">{$hadrianLang.home.tierAgency}</div>
            <div class="price">$79<span class="per">{$hadrianLang.home.perMo}</span></div>
            <div class="desc">{$hadrianLang.home.tierAgencyDesc}</div>
            <ul class="seg-features"><li>Unlimited clients</li><li>200 GB SSD</li><li>Custom domain panel</li><li>Account manager</li></ul>
            <a href="{$WEB_ROOT}/cart.php" class="buy">{$hadrianLang.home.buyAgency}</a>
        </div>
    </div>
    <p style="text-align: center; font-size: 14px; color: #6e6e73; margin-top: 32px;">{$hadrianLang.home.pricingNote} <a href="{$WEB_ROOT}/cart.php" style="color: var(--color-accent);">{$hadrianLang.home.pricingNoteLink} &rsaquo;</a></p>
</section>

{* 10. Reviews *}
<section class="hp-testi-reviews">
    <div class="big-stars">&starf;&starf;&starf;&starf;&starf;</div>
    <div class="rating-num">4.9</div>
    <div class="rating-of">{$hadrianLang.home.ratingOf}</div>
    <div class="review-sources">
        <div class="rev-src"><div class="stars">&starf;&starf;&starf;&starf;&starf;</div><div class="src-name">Trustpilot</div><div class="src-count">2,400+ reviews</div></div>
        <div class="rev-src"><div class="stars">&starf;&starf;&starf;&starf;&starf;</div><div class="src-name">G2</div><div class="src-count">890 reviews</div></div>
        <div class="rev-src"><div class="stars">&starf;&starf;&starf;&starf;&starf;</div><div class="src-name">Product Hunt</div><div class="src-count">520 reviews</div></div>
        <div class="rev-src"><div class="stars">&starf;&starf;&starf;&starf;&starf;</div><div class="src-name">Indie Hackers</div><div class="src-count">310 reviews</div></div>
    </div>
</section>

{* 11. Final CTA *}
<section class="hp-cta-immersive">
    <div class="inner">
        <h2>{$hadrianLang.home.ctaTitle}</h2>
        <p>{$hadrianLang.home.ctaText}</p>
        <a href="{$WEB_ROOT}/cart.php" class="btn">{$hadrianLang.home.ctaBtn}</a>
    </div>
</section>

{* Domain tab toggle - search vs transfer affects form action *}
<script>
(function () {
    var form = document.querySelector('.ph-domain-form');
    if (!form) return;
    document.querySelectorAll('.ph-domain-tabs button').forEach(function (btn) {
        btn.addEventListener('click', function () {
            document.querySelectorAll('.ph-domain-tabs button').forEach(function (b) {
                b.classList.toggle('active', b === btn);
                b.setAttribute('aria-selected', b === btn ? 'true' : 'false');
            });
            form.action = btn.dataset.dtab === 'transfer'
                ? '{$WEB_ROOT}/cart.php?a=add&domain=transfer'
                : '{$WEB_ROOT}/domainchecker.php';
        });
    });
})();
</script>
