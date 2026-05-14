{*
 * mytheme_cart/domaintransfer.tpl — Domain transfer step.
 *
 * Rendered URL: /cart.php?a=add&domain=transfer
 *
 * Visual source: apple-client-area/cart-domain-transfer.html.
 * Layout: page header → search form → result card (eligible /
 *         ineligible) → "Why transfer to us" 3-up.
 *
 * Available Smarty variables:
 *   $domain          — searched domain
 *   $transferresult  — { eligible (bool), reason, pricing, sld, tld }
 *   $WEB_ROOT, $carttpl
 *}

{include file="orderforms/$carttpl/common.tpl"}

<style>{literal}
/* Reuses .dr-* tokens from domainregister.tpl, plus a small .dt-* set
   for the "why transfer" 3-up. We keep both stylesheets inline for now
   since the two pages are typically requested independently. */
.dt-page-header { margin-bottom: 28px; }
.dt-page-header .page-eyebrow { font-size: 11px; font-weight: 600; color: var(--color-text-tertiary); text-transform: uppercase; letter-spacing: 0.06em; margin: 0 0 6px; }
.dt-page-header h1 { font-size: 32px; font-weight: 600; letter-spacing: -0.03em; color: var(--color-text-primary); margin: 0 0 6px; }
.dt-page-header .page-subtitle { font-size: 14px; color: var(--color-text-secondary); letter-spacing: -0.008em; margin: 0; }

.dt-search { margin-bottom: 28px; }
.dt-search-box { display: flex; align-items: center; gap: 8px; background: var(--color-surface); border: 0.5px solid var(--color-border); border-radius: var(--radius-pill); padding: 6px 6px 6px 18px; }
.dt-search-box:focus-within { border-color: var(--color-accent); box-shadow: 0 0 0 3px var(--color-accent-light); }
.dt-search-icon { width: 16px; height: 16px; color: var(--color-text-tertiary); flex-shrink: 0; }
.dt-search-input { flex: 1; border: 0; background: transparent; padding: 12px 4px; font-size: 16px; font-family: inherit; color: var(--color-text-primary); letter-spacing: -0.012em; outline: 0; min-width: 0; }
.dt-search-input::placeholder { color: var(--color-text-quaternary); }
.dt-generate-btn { height: 38px; padding: 0 22px; border-radius: var(--radius-pill); background: var(--color-accent); color: #fff; border: 0; font-size: 13.5px; font-weight: 500; cursor: pointer; font-family: inherit; flex-shrink: 0; transition: background var(--transition-fast); }
.dt-generate-btn:hover { background: var(--color-accent-hover); }

/* Transfer eligibility result */
.dt-result { padding: 22px 26px; border-radius: var(--radius-lg, 14px); margin-bottom: 28px; }
.dt-result.eligible { background: var(--color-green-bg); border: 0.5px solid rgba(48, 209, 88, 0.30); }
.dt-result.ineligible { background: var(--color-red-bg); border: 0.5px solid rgba(255, 59, 48, 0.30); }
.dt-result-head { display: flex; align-items: center; gap: 18px; margin-bottom: 18px; }
.dt-badge { width: 44px; height: 44px; border-radius: 50%; display: flex; align-items: center; justify-content: center; flex-shrink: 0; color: #fff; }
.dt-badge.eligible { background: var(--color-green-text); }
.dt-badge.ineligible { background: var(--color-red-text); }
.dt-badge svg { width: 22px; height: 22px; }
.dt-result-info { flex: 1; min-width: 0; }
.dt-result-title { font-size: 17px; font-weight: 600; color: var(--color-text-primary); letter-spacing: -0.014em; }
.dt-result-sub { font-size: 13px; color: var(--color-text-secondary); margin-top: 4px; }
.dt-epp-form { display: flex; flex-direction: column; gap: 12px; padding-top: 14px; border-top: 0.5px solid rgba(0,0,0,0.06); }
.dt-epp-form label { font-size: 12px; font-weight: 500; color: var(--color-text-secondary); letter-spacing: -0.004em; }
.dt-epp-form input { height: 40px; padding: 0 14px; border: 0.5px solid var(--color-border); border-radius: var(--radius-md); background: var(--color-surface); font-size: 14px; font-family: var(--font-mono, ui-monospace, Menlo, monospace); letter-spacing: 0.04em; color: var(--color-text-primary); }
.dt-epp-form input:focus { outline: 0; border-color: var(--color-accent); box-shadow: 0 0 0 3px var(--color-accent-light); }
.dt-epp-form .dt-actions { display: flex; justify-content: flex-end; gap: 10px; }
.dt-epp-form .btn-primary { height: 40px; padding: 0 22px; border-radius: var(--radius-pill); background: var(--color-accent); color: #fff; border: 0; font-size: 13.5px; font-weight: 500; cursor: pointer; font-family: inherit; text-decoration: none; display: inline-flex; align-items: center; justify-content: center; }
.dt-epp-form .btn-primary:hover { background: var(--color-accent-hover); color: #fff; }

/* "Why transfer to us" 3-up */
.dt-section { margin-bottom: 28px; }
.dt-section-head h2 { font-size: 18px; font-weight: 600; color: var(--color-text-primary); letter-spacing: -0.014em; margin: 0 0 14px; }
.dt-steps { display: grid; grid-template-columns: repeat(3, 1fr); gap: 16px; }
@media (max-width: 720px) { .dt-steps { grid-template-columns: 1fr; } }
.dt-step { padding: 20px 18px; background: var(--color-surface); border: 0.5px solid var(--color-border); border-radius: var(--radius-md); }
.dt-step-ico { width: 36px; height: 36px; border-radius: 10px; display: flex; align-items: center; justify-content: center; margin-bottom: 12px; }
.dt-step-ico.purple { background: rgba(175, 82, 222, 0.10); color: #af52de; }
.dt-step-ico.blue   { background: var(--color-accent-light); color: var(--color-accent); }
.dt-step-ico.green  { background: var(--color-green-bg); color: var(--color-green-text); }
.dt-step-ico svg { width: 18px; height: 18px; }
.dt-step h4 { font-size: 14px; font-weight: 600; color: var(--color-text-primary); letter-spacing: -0.008em; margin: 0 0 4px; }
.dt-step p { font-size: 12.5px; color: var(--color-text-tertiary); margin: 0; line-height: 1.5; }

/* Empty state */
.dt-empty { padding: 64px 24px; text-align: center; background: var(--color-surface); border: 0.5px solid var(--color-border); border-radius: var(--radius-lg, 14px); }
.dt-empty-ico { width: 64px; height: 64px; border-radius: 50%; background: var(--color-surface-secondary); color: var(--color-text-tertiary); display: inline-flex; align-items: center; justify-content: center; margin-bottom: 16px; }
.dt-empty-ico svg { width: 28px; height: 28px; }
.dt-empty-title { font-size: 18px; font-weight: 600; color: var(--color-text-primary); margin: 0 0 6px; }
.dt-empty-desc { font-size: 13.5px; color: var(--color-text-tertiary); max-width: 380px; margin: 0 auto; line-height: 1.5; }
{/literal}</style>

<div class="content-area">
    <header class="dt-page-header">
        <p class="page-eyebrow">ORDER</p>
        <h1>Transfer a Domain</h1>
        <p class="page-subtitle">Bring your domain to us — add a free year, transfer in about 24 hours.</p>
    </header>

    {* Search form *}
    <div class="dt-search">
        <form method="post" action="{$WEB_ROOT}/cart.php?a=add&domain=transfer">
            <input type="hidden" name="checktransfer" value="true">
            <div class="dt-search-box">
                <svg class="dt-search-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M10 13a5 5 0 007.54.54l3-3a5 5 0 00-7.07-7.07l-1.72 1.71"/><path d="M14 11a5 5 0 00-7.54-.54l-3 3a5 5 0 007.07 7.07l1.71-1.71"/></svg>
                <input type="text" name="domain" class="dt-search-input" placeholder="yourdomain.com" value="{$domain|escape}" autocomplete="off" required>
                <button type="submit" class="dt-generate-btn">Check</button>
            </div>
        </form>
    </div>

    {* ─────────────────────────────────────────────────────────
       ELIGIBILITY RESULT — eligible / ineligible card
       ───────────────────────────────────────────────────────── *}
    {if $domain && $transferresult}
        {if $transferresult.eligible}
            <div class="dt-result eligible">
                <div class="dt-result-head">
                    <div class="dt-badge eligible">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"/></svg>
                    </div>
                    <div class="dt-result-info">
                        <div class="dt-result-title">
                            <strong>{$domain|escape}</strong> is eligible for transfer.
                        </div>
                        <div class="dt-result-sub">
                            {if $transferresult.pricing}{$transferresult.pricing|escape} · {/if}Includes 1 extra year of registration
                        </div>
                    </div>
                </div>
                <form class="dt-epp-form" method="post" action="{$WEB_ROOT}/cart.php?a=add">
                    <input type="hidden" name="domain" value="transfer">
                    <input type="hidden" name="sld" value="{$transferresult.sld|escape}">
                    <input type="hidden" name="tld" value="{$transferresult.tld|escape}">
                    <label for="dt-epp">EPP / Auth code <span style="font-weight:400;color:var(--color-text-tertiary);">(optional — we will ask later if needed)</span></label>
                    <input id="dt-epp" type="text" name="eppcode" placeholder="abc123-def456">
                    <div class="dt-actions">
                        <button type="submit" class="btn-primary">
                            Add transfer to cart
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="width:14px;height:14px;margin-left:6px;"><polyline points="9 18 15 12 9 6"/></svg>
                        </button>
                    </div>
                </form>
            </div>
        {else}
            <div class="dt-result ineligible">
                <div class="dt-result-head">
                    <div class="dt-badge ineligible">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round"><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg>
                    </div>
                    <div class="dt-result-info">
                        <div class="dt-result-title">
                            <strong>{$domain|escape}</strong> cannot be transferred right now.
                        </div>
                        <div class="dt-result-sub">
                            {$transferresult.reason|default:'It may be locked at the current registrar, recently registered or expired, or not under one of our supported TLDs.'|escape}
                        </div>
                    </div>
                </div>
            </div>
        {/if}
    {/if}

    {* ─────────────────────────────────────────────────────────
       "Why transfer to us" — 3-up benefits
       ───────────────────────────────────────────────────────── *}
    <div class="dt-section">
        <div class="dt-section-head">
            <h2>Why transfer to us</h2>
        </div>
        <div class="dt-steps">
            <div class="dt-step">
                <div class="dt-step-ico purple">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"/></svg>
                </div>
                <h4>+1 free year</h4>
                <p>Every transfer includes an additional year of registration at no extra cost.</p>
            </div>
            <div class="dt-step">
                <div class="dt-step-ico blue">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg>
                </div>
                <h4>24-hour transfer</h4>
                <p>Most transfers complete within 24 hours — no downtime for your site.</p>
            </div>
            <div class="dt-step">
                <div class="dt-step-ico green">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="11" width="18" height="11" rx="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/></svg>
                </div>
                <h4>Free WHOIS privacy</h4>
                <p>Included with every transfer, on every eligible TLD. Keep your info private.</p>
            </div>
        </div>
    </div>

    {* Empty state — first visit *}
    {if !$domain && !$transferresult}
        <div class="dt-empty">
            <div class="dt-empty-ico">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round"><path d="M3 12h13"/><polyline points="11 7 16 12 11 17"/><path d="M19 5v14a2 2 0 01-2 2"/></svg>
            </div>
            <h3 class="dt-empty-title">Enter a domain to transfer</h3>
            <p class="dt-empty-desc">Type your existing domain above and we will start the transfer flow.</p>
        </div>
    {/if}
</div>
