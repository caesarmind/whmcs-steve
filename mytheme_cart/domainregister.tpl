{*
 * mytheme_cart/domainregister.tpl — Domain registration step.
 *
 * Rendered URL: /cart.php?a=add&domain=register
 *
 * Visual source: apple-client-area/cart-domain-register.html.
 * Layout: page header → search form → primary result → suggested
 *         list (when WHMCS returns suggestions).
 *
 * Available Smarty variables:
 *   $domain         — searched domain (e.g. "mycompany.com")
 *   $domainresult   — result object: .available (bool), .unavailable,
 *                      .invalid, .pricing
 *   $tldList        — array of TLDs WHMCS offers
 *   $suggestions    — array of suggested-domain results
 *   $featured       — popular TLDs grid
 *   $WEB_ROOT, $carttpl
 *}

{include file="orderforms/$carttpl/common.tpl"}

<style>{literal}
/* Domain register/transfer page (.dr-*) — Apple-language port */

.dr-page-header { margin-bottom: 28px; }
.dr-page-header .page-eyebrow { font-size: 11px; font-weight: 600; color: var(--color-text-tertiary); text-transform: uppercase; letter-spacing: 0.06em; margin: 0 0 6px; }
.dr-page-header h1 { font-size: 32px; font-weight: 600; letter-spacing: -0.03em; color: var(--color-text-primary); margin: 0 0 6px; }
.dr-page-header .page-subtitle { font-size: 14px; color: var(--color-text-secondary); letter-spacing: -0.008em; margin: 0; }

.dr-search { margin-bottom: 28px; }
.dr-search-box { position: relative; display: flex; align-items: center; gap: 8px; background: var(--color-surface); border: 0.5px solid var(--color-border); border-radius: var(--radius-pill); padding: 6px 6px 6px 18px; }
.dr-search-box:focus-within { border-color: var(--color-accent); box-shadow: 0 0 0 3px var(--color-accent-light); }
.dr-search-icon { width: 16px; height: 16px; color: var(--color-text-tertiary); flex-shrink: 0; }
.dr-search-input { flex: 1; border: 0; background: transparent; padding: 12px 4px; font-size: 16px; font-family: inherit; color: var(--color-text-primary); letter-spacing: -0.012em; outline: 0; min-width: 0; }
.dr-search-input::placeholder { color: var(--color-text-quaternary); }
.dr-generate-btn { height: 38px; padding: 0 22px; border-radius: var(--radius-pill); background: var(--color-accent); color: #fff; border: 0; font-size: 13.5px; font-weight: 500; letter-spacing: -0.008em; cursor: pointer; font-family: inherit; flex-shrink: 0; transition: background var(--transition-fast); }
.dr-generate-btn:hover { background: var(--color-accent-hover); }

/* Primary result */
.dr-result-card { display: flex; align-items: center; gap: 18px; padding: 22px 26px; border-radius: var(--radius-lg, 14px); margin-bottom: 28px; }
.dr-result-card.available { background: var(--color-green-bg); border: 0.5px solid rgba(48, 209, 88, 0.30); }
.dr-result-card.unavailable { background: var(--color-red-bg); border: 0.5px solid rgba(255, 59, 48, 0.30); }
.dr-result-left { display: flex; align-items: center; gap: 18px; flex: 1; min-width: 0; }
.dr-check-badge { width: 44px; height: 44px; border-radius: 50%; background: var(--color-green-text); color: #fff; display: flex; align-items: center; justify-content: center; flex-shrink: 0; }
.dr-check-badge.unavailable { background: var(--color-red-text); }
.dr-check-badge svg { width: 22px; height: 22px; }
.dr-result-info { min-width: 0; }
.dr-result-name { font-size: 18px; color: var(--color-text-primary); letter-spacing: -0.014em; }
.dr-result-name strong { font-weight: 600; }
.dr-available-text { color: var(--color-green-text); font-weight: 500; }
.dr-unavailable-text { color: var(--color-red-text); font-weight: 500; }
.dr-result-meta { display: inline-flex; align-items: center; gap: 8px; margin-top: 4px; font-size: 13px; color: var(--color-text-secondary); }
.dr-result-price { font-weight: 600; color: var(--color-text-primary); font-variant-numeric: tabular-nums; }
.dr-result-price .per { font-weight: 400; color: var(--color-text-tertiary); font-size: 11.5px; }
.dr-result-dot { color: var(--color-text-quaternary); }
.dr-add-btn { height: 42px; padding: 0 22px; border-radius: var(--radius-pill); background: var(--color-accent); color: #fff; border: 0; font-size: 13.5px; font-weight: 500; letter-spacing: -0.008em; cursor: pointer; font-family: inherit; text-decoration: none; display: inline-flex; align-items: center; justify-content: center; gap: 6px; transition: background var(--transition-fast); flex-shrink: 0; }
.dr-add-btn:hover { background: var(--color-accent-hover); color: #fff; }
.dr-add-btn.outline { background: transparent; color: var(--color-text-primary); border: 0.5px solid var(--color-border); height: 36px; padding: 0 16px; font-size: 12.5px; }
.dr-add-btn.outline:hover { background: var(--color-accent); border-color: var(--color-accent); color: #fff; }

/* Sections */
.dr-section { margin-bottom: 28px; }
.dr-section-head { margin-bottom: 14px; }
.dr-section-head h2 { font-size: 18px; font-weight: 600; letter-spacing: -0.014em; color: var(--color-text-primary); margin: 0 0 4px; }
.dr-section-head p { font-size: 13px; color: var(--color-text-tertiary); margin: 0; letter-spacing: -0.004em; }

/* Popular TLDs grid */
.dr-popular-grid { display: grid; grid-template-columns: repeat(4, 1fr); gap: 12px; }
@media (max-width: 720px) { .dr-popular-grid { grid-template-columns: repeat(2, 1fr); } }
.dr-tld-card { position: relative; padding: 18px 16px; background: var(--color-surface); border: 0.5px solid var(--color-border); border-radius: var(--radius-md); display: flex; flex-direction: column; gap: 8px; align-items: flex-start; }
.dr-tld-name { font-size: 22px; font-weight: 600; color: var(--color-text-primary); letter-spacing: -0.022em; font-variant-numeric: tabular-nums; }
.dr-tld-price { font-size: 13.5px; font-weight: 600; color: var(--color-text-primary); font-variant-numeric: tabular-nums; }
.dr-tld-price span { color: var(--color-text-tertiary); font-weight: 400; font-size: 11.5px; }
.dr-tld-status.unavailable { font-size: 12px; color: var(--color-red-text); font-weight: 500; }
.dr-tld-btn { width: 100%; height: 32px; padding: 0 14px; border-radius: var(--radius-pill); background: var(--color-accent); color: #fff; border: 0; font-size: 12.5px; font-weight: 500; letter-spacing: -0.008em; cursor: pointer; font-family: inherit; text-decoration: none; display: inline-flex; align-items: center; justify-content: center; transition: background var(--transition-fast); }
.dr-tld-btn:hover { background: var(--color-accent-hover); color: #fff; }
.dr-tld-btn.disabled { background: var(--color-surface-secondary); color: var(--color-text-tertiary); cursor: not-allowed; }

/* Suggested list */
.dr-suggested-list { display: flex; flex-direction: column; }
.dr-sug-row { display: flex; align-items: center; justify-content: space-between; gap: 14px; padding: 14px 0; border-bottom: 0.5px solid var(--color-border); }
.dr-sug-row:last-child { border-bottom: 0; }
.dr-sug-name { font-size: 15px; font-weight: 500; color: var(--color-text-primary); letter-spacing: -0.008em; font-variant-numeric: tabular-nums; display: inline-flex; align-items: center; gap: 8px; }
.dr-sug-name .tld { font-weight: 600; color: var(--color-accent); }
.dr-sug-chip { padding: 2px 8px; border-radius: var(--radius-pill); font-size: 9.5px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.04em; }
.dr-sug-chip.sale { background: var(--color-orange-bg); color: var(--color-orange-text); }
.dr-sug-chip.new  { background: var(--color-green-bg);  color: var(--color-green-text); }
.dr-sug-actions { display: flex; gap: 8px; align-items: center; flex-shrink: 0; }
.dr-sug-term { appearance: none; height: 32px; padding: 0 30px 0 12px; border: 0.5px solid var(--color-border); border-radius: var(--radius-pill); background: var(--color-surface); font-size: 12.5px; font-family: inherit; color: var(--color-text-primary); font-variant-numeric: tabular-nums; cursor: pointer; background-image: url("data:image/svg+xml;utf8,<svg xmlns='http://www.w3.org/2000/svg' width='10' height='10' viewBox='0 0 24 24' fill='none' stroke='%2386868b' stroke-width='2.5' stroke-linecap='round' stroke-linejoin='round'><polyline points='6 9 12 15 18 9'/></svg>"); background-repeat: no-repeat; background-position: right 10px center; }
.dr-sug-term:focus { outline: 0; border-color: var(--color-accent); }

/* Transfer / "Already own" panel */
.dr-transfer-panel { padding: 22px 24px; background: var(--color-surface-tertiary); border-radius: var(--radius-lg, 14px); }
.dr-transfer-panel h2 { font-size: 17px; font-weight: 600; color: var(--color-text-primary); letter-spacing: -0.014em; margin: 0 0 6px; }
.dr-transfer-panel p { font-size: 13.5px; color: var(--color-text-tertiary); margin: 0 0 14px; line-height: 1.5; }
.dr-transfer-form { display: flex; gap: 8px; align-items: stretch; flex-wrap: wrap; }
.dr-transfer-form input { flex: 1; min-width: 200px; height: 40px; padding: 0 16px; border: 0.5px solid var(--color-border); border-radius: var(--radius-pill); background: var(--color-surface); font-size: 14px; font-family: inherit; color: var(--color-text-primary); letter-spacing: -0.008em; }
.dr-transfer-form input:focus { outline: 0; border-color: var(--color-accent); box-shadow: 0 0 0 3px var(--color-accent-light); }
.dr-transfer-form button { height: 40px; padding: 0 22px; border-radius: var(--radius-pill); background: var(--color-accent); color: #fff; border: 0; font-size: 13.5px; font-weight: 500; cursor: pointer; font-family: inherit; transition: background var(--transition-fast); }
.dr-transfer-form button:hover { background: var(--color-accent-hover); }

/* Empty state — no search yet */
.dr-empty { padding: 64px 24px; text-align: center; background: var(--color-surface); border: 0.5px solid var(--color-border); border-radius: var(--radius-lg, 14px); }
.dr-empty-ico { width: 64px; height: 64px; border-radius: 50%; background: var(--color-surface-secondary); color: var(--color-text-tertiary); display: inline-flex; align-items: center; justify-content: center; margin-bottom: 16px; }
.dr-empty-ico svg { width: 28px; height: 28px; }
.dr-empty-title { font-size: 18px; font-weight: 600; color: var(--color-text-primary); letter-spacing: -0.014em; margin: 0 0 6px; }
.dr-empty-desc { font-size: 13.5px; color: var(--color-text-tertiary); max-width: 380px; margin: 0 auto; line-height: 1.5; }
{/literal}</style>

<div class="content-area">
    <header class="dr-page-header">
        <p class="page-eyebrow">ORDER</p>
        <h1>Register a Domain</h1>
        <p class="page-subtitle">Search availability and add it to your cart.</p>
    </header>

    {* Search form *}
    <div class="dr-search">
        <form class="dr-search-form" method="post" action="{$WEB_ROOT}/cart.php?a=add&domain=register">
            <input type="hidden" name="checkavailability" value="true">
            <div class="dr-search-box">
                <svg class="dr-search-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
                <input type="text" name="domain" class="dr-search-input" placeholder="yourdomain.com" value="{$domain|escape}" aria-label="Search for a domain" autocomplete="off" required>
                <button type="submit" class="dr-generate-btn">Search</button>
            </div>
        </form>
    </div>

    {* ─────────────────────────────────────────────────────────
       PRIMARY RESULT — only when user searched
       ───────────────────────────────────────────────────────── *}
    {if $domain && $domainresult}
        {if $domainresult.available}
            <div class="dr-result-card available">
                <div class="dr-result-left">
                    <div class="dr-check-badge" aria-label="Available">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"/></svg>
                    </div>
                    <div class="dr-result-info">
                        <div class="dr-result-name">
                            <strong>{$domain|escape}</strong>
                            <span class="dr-available-text">is available.</span>
                        </div>
                        {if $domainresult.pricing}
                            <div class="dr-result-meta">
                                <span class="dr-result-price">{$domainresult.pricing}<span class="per">/yr</span></span>
                                <span class="dr-result-dot" aria-hidden="true">·</span>
                                <span>Free WHOIS privacy included</span>
                            </div>
                        {/if}
                    </div>
                </div>
                <form method="post" action="{$WEB_ROOT}/cart.php?a=add" style="margin:0;">
                    <input type="hidden" name="domain" value="register">
                    <input type="hidden" name="sld" value="{$domainresult.sld|escape}">
                    <input type="hidden" name="tld" value="{$domainresult.tld|escape}">
                    <button type="submit" class="dr-add-btn">Add to Cart</button>
                </form>
            </div>
        {else}
            <div class="dr-result-card unavailable">
                <div class="dr-result-left">
                    <div class="dr-check-badge unavailable" aria-label="Unavailable">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round"><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg>
                    </div>
                    <div class="dr-result-info">
                        <div class="dr-result-name">
                            <strong>{$domain|escape}</strong>
                            <span class="dr-unavailable-text">is already taken.</span>
                        </div>
                        <div class="dr-result-meta">Try a different spelling, or pick a TLD below.</div>
                    </div>
                </div>
            </div>
        {/if}
    {/if}

    {* ─────────────────────────────────────────────────────────
       FEATURED TLDS — pre-populated for fresh searches
       ───────────────────────────────────────────────────────── *}
    {if $featured && count($featured) > 0}
        <div class="dr-section">
            <div class="dr-section-head">
                <h2>Most popular</h2>
                <p>A handful of the best-known extensions for your domain.</p>
            </div>
            <div class="dr-popular-grid">
                {foreach $featured as $tld}
                    <div class="dr-tld-card">
                        <div class="dr-tld-name">{$tld.name|escape}</div>
                        {if $tld.available === false}
                            <div class="dr-tld-status unavailable">Unavailable</div>
                            <button class="dr-tld-btn disabled" disabled>Unavailable</button>
                        {else}
                            {if $tld.price}<div class="dr-tld-price">{$tld.price|escape}<span>/yr</span></div>{/if}
                            <form method="post" action="{$WEB_ROOT}/cart.php?a=add" style="width:100%; margin:0;">
                                <input type="hidden" name="domain" value="register">
                                <input type="hidden" name="sld" value="{$tld.sld|escape}">
                                <input type="hidden" name="tld" value="{$tld.tld|escape}">
                                <button type="submit" class="dr-tld-btn">Add</button>
                            </form>
                        {/if}
                    </div>
                {/foreach}
            </div>
        </div>
    {/if}

    {* ─────────────────────────────────────────────────────────
       SUGGESTIONS — WHMCS-provided alternative spellings + TLDs
       ───────────────────────────────────────────────────────── *}
    {if $suggestions && count($suggestions) > 0}
        <div class="dr-section">
            <div class="dr-section-head">
                <h2>Suggested for you</h2>
                <p>Availability is checked in real time when you add to the cart.</p>
            </div>
            <div class="dr-suggested-list">
                {foreach $suggestions as $sug}
                    <div class="dr-sug-row">
                        <div class="dr-sug-name">
                            {$sug.sld|escape}<span class="tld">.{$sug.tld|escape}</span>
                            {if $sug.onsale}<span class="dr-sug-chip sale">Sale</span>{/if}
                            {if $sug.isnew}<span class="dr-sug-chip new">New</span>{/if}
                        </div>
                        <form method="post" action="{$WEB_ROOT}/cart.php?a=add" class="dr-sug-actions" style="margin:0;">
                            <input type="hidden" name="domain" value="register">
                            <input type="hidden" name="sld" value="{$sug.sld|escape}">
                            <input type="hidden" name="tld" value="{$sug.tld|escape}">
                            {if $sug.terms && count($sug.terms) > 0}
                                <select name="regperiod" class="dr-sug-term" aria-label="Registration term">
                                    {foreach $sug.terms as $tKey => $tPrice}
                                        <option value="{$tKey|escape}">{$tPrice|escape} / {$tKey|escape}yr</option>
                                    {/foreach}
                                </select>
                            {/if}
                            <button type="submit" class="dr-add-btn outline">Add to Cart</button>
                        </form>
                    </div>
                {/foreach}
            </div>
        </div>
    {/if}

    {* ─────────────────────────────────────────────────────────
       "Already own" — link to transfer page
       ───────────────────────────────────────────────────────── *}
    <div class="dr-transfer-panel">
        <h2>Already own a domain?</h2>
        <p>Transfer it in — your registration term is extended by an extra year and we keep WHOIS privacy on for free.</p>
        <form class="dr-transfer-form" method="post" action="{$WEB_ROOT}/cart.php?a=add&domain=transfer">
            <input type="text" name="domain" placeholder="yourdomain.com" autocomplete="off">
            <button type="submit">Transfer in a domain</button>
        </form>
    </div>

    {* Empty state — first visit before any search *}
    {if !$domain && !$domainresult && !$suggestions}
        <div class="dr-empty">
            <div class="dr-empty-ico">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="2" y1="12" x2="22" y2="12"/><path d="M12 2a15.3 15.3 0 014 10 15.3 15.3 0 01-4 10 15.3 15.3 0 01-4-10 15.3 15.3 0 014-10z"/></svg>
            </div>
            <h3 class="dr-empty-title">Find the perfect domain</h3>
            <p class="dr-empty-desc">Type a name above to check availability across all our supported TLDs.</p>
        </div>
    {/if}
</div>
