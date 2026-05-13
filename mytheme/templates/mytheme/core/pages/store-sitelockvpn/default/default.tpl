{* Store landing — SiteLock VPN bundle.
   Ported from apple-client-area/store/sitelockvpn.html (2026-05-13).

   MarketConnect doesn't typically expose plan tiers as a structured
   array — the three plan cards below are static. When the integration
   surfaces real pricing variables ($marketconnect.sitelockvpn.* or
   similar), wrap each .store-plan-card in an {if !empty(...)} cascade
   so admin can edit copy in code while live data fills price/quotas. *}

<link rel="stylesheet" href="{$WEB_ROOT}/templates/{$template}/assets/css/pages/store-sitelockvpn.css?v={$myTheme.version|default:'1.0'}">

<div class="store-landing store-sitelockvpn">

    {* Cross-nav to sibling store landings. *}
    <nav class="store-nav" aria-label="Store products">
        <a href="{$WEB_ROOT}/store/ssl">SSL Certificates</a>
        <a href="{$WEB_ROOT}/store/weebly">Website Builder</a>
        <a href="{$WEB_ROOT}/store/sitelock">Website Security</a>
        <a href="{$WEB_ROOT}/store/spamexperts">Email Services</a>
        <a href="{$WEB_ROOT}/store/codeguard">Website Backup</a>
        <a href="{$WEB_ROOT}/store/marketgoo">SEO Tools</a>
        <a href="{$WEB_ROOT}/store/ox">Professional Email</a>
        <a href="{$WEB_ROOT}/store/sitebuilder">Site Builder</a>
        <a href="{$WEB_ROOT}/store/nordvpn">VPN</a>
    </nav>

    {* Hero — single-line title + tagline, shield icon. *}
    <div class="store-hero">
        <div class="store-hero-icon tile-icon green" aria-hidden="true">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                <path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/>
            </svg>
        </div>
        <h1 class="store-hero-title">{if $LANG.storesitelockvpntitle}{$LANG.storesitelockvpntitle}{else}SiteLock VPN{/if}</h1>
        <p class="store-hero-subtitle">{if $LANG.storesitelockvpntagline}{$LANG.storesitelockvpntagline}{else}Browse securely and protect your online identity.{/if}</p>
    </div>

    {* 3 plan tiers — static; replace per-card content when MarketConnect
       publishes real pricing. The "featured" modifier on the middle card
       lifts it visually and uses the primary CTA button. *}
    {assign var=mt_orderUrl value=$marketconnect.sitelockvpn.orderUrl|default:"{$WEB_ROOT}/cart.php?gid=marketconnect"}
    <div class="store-plans">
        <div class="store-plan-card">
            <div class="store-plan-name">Basic</div>
            <div class="store-plan-price">$4.99 <span class="period">/mo</span></div>
            <div class="store-plan-desc">Essential protection for individuals</div>
            <ul class="store-plan-features">
                <li>Unlimited bandwidth</li>
                <li>50+ server locations</li>
                <li>1 device connection</li>
                <li>Basic threat protection</li>
                <li>Email support</li>
            </ul>
            <a href="{$mt_orderUrl|escape}" class="store-plan-cta btn-secondary">Order Now</a>
        </div>
        <div class="store-plan-card featured">
            <div class="store-plan-name">Pro</div>
            <div class="store-plan-price">$7.99 <span class="period">/mo</span></div>
            <div class="store-plan-desc">Advanced security for power users</div>
            <ul class="store-plan-features">
                <li>Unlimited bandwidth</li>
                <li>100+ server locations</li>
                <li>5 device connections</li>
                <li>Advanced threat protection</li>
                <li>Priority support</li>
            </ul>
            <a href="{$mt_orderUrl|escape}" class="store-plan-cta btn-primary">Order Now</a>
        </div>
        <div class="store-plan-card">
            <div class="store-plan-name">Business</div>
            <div class="store-plan-price">$12.99 <span class="period">/mo</span></div>
            <div class="store-plan-desc">Complete protection for teams</div>
            <ul class="store-plan-features">
                <li>Unlimited bandwidth</li>
                <li>150+ server locations</li>
                <li>10 device connections</li>
                <li>Enterprise threat protection</li>
                <li>Dedicated account manager</li>
            </ul>
            <a href="{$mt_orderUrl|escape}" class="store-plan-cta btn-secondary">Order Now</a>
        </div>
    </div>

    {* Key Features card. *}
    <div class="card">
        <div class="card-header">
            <h3 class="card-title">Key Features</h3>
        </div>
        <div class="card-body">
            <div class="store-feature-grid">
                <div class="store-feature">
                    <div class="store-feature-icon" aria-hidden="true">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="11" width="18" height="11" rx="2" ry="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/></svg>
                    </div>
                    <div class="store-feature-content">
                        <div class="store-feature-title">Military-Grade Encryption</div>
                        <div class="store-feature-desc">AES-256 encryption keeps your data safe from hackers and surveillance on any network.</div>
                    </div>
                </div>
                <div class="store-feature">
                    <div class="store-feature-icon" aria-hidden="true">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg>
                    </div>
                    <div class="store-feature-content">
                        <div class="store-feature-title">Malware Protection</div>
                        <div class="store-feature-desc">Built-in malware scanner blocks malicious websites and downloads before they reach your device.</div>
                    </div>
                </div>
                <div class="store-feature">
                    <div class="store-feature-icon" aria-hidden="true">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="2" y1="12" x2="22" y2="12"/><path d="M12 2a15.3 15.3 0 0 1 4 10 15.3 15.3 0 0 1-4 10 15.3 15.3 0 0 1-4-10 15.3 15.3 0 0 1 4-10z"/></svg>
                    </div>
                    <div class="store-feature-content">
                        <div class="store-feature-title">Global Network</div>
                        <div class="store-feature-desc">Connect through optimized servers worldwide for fast, reliable access to content and services.</div>
                    </div>
                </div>
                <div class="store-feature">
                    <div class="store-feature-icon" aria-hidden="true">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/></svg>
                    </div>
                    <div class="store-feature-content">
                        <div class="store-feature-title">Kill Switch</div>
                        <div class="store-feature-desc">Automatic kill switch ensures your data is never exposed, even if the VPN connection drops.</div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    {* FAQ — uses native <details>/<summary> for keyboard + screen reader
       accessibility (no JS needed). *}
    <div class="card">
        <div class="card-header">
            <h3 class="card-title">Frequently Asked Questions</h3>
        </div>
        <div class="card-body">
            <div class="store-faq">
                <details>
                    <summary>How does SiteLock VPN differ from other VPN services?</summary>
                    <div class="faq-answer">SiteLock VPN integrates directly with your hosting account and includes built-in malware protection. It&rsquo;s designed specifically for website owners who need both browsing security and site protection in one solution.</div>
                </details>
                <details>
                    <summary>Can I use SiteLock VPN on my mobile devices?</summary>
                    <div class="faq-answer">Yes, SiteLock VPN has dedicated apps for iOS, Android, Windows, and macOS. Simply download the app, log in with your credentials, and you&rsquo;re protected on any device.</div>
                </details>
                <details>
                    <summary>Is there a money-back guarantee?</summary>
                    <div class="faq-answer">Yes, all SiteLock VPN plans come with a 30-day money-back guarantee. If you&rsquo;re not satisfied, contact our support team for a full refund within the first 30 days.</div>
                </details>
            </div>
        </div>
    </div>

    {* Bottom CTA — links to support so a hesitant buyer can ask before
       ordering. Uses the existing supportticketslist route. *}
    <div class="store-cta-section">
        <h2 class="store-cta-title">Need help choosing?</h2>
        <p class="store-cta-subtitle">Our team can help you select the right VPN plan for your needs.</p>
        <a href="{$WEB_ROOT}/supporttickets.php" class="btn-primary btn-lg">Contact Sales</a>
    </div>

</div>
