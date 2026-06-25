{*
 * hadrian_cart/domaintransfer.tpl - Apple-shell rebuild.
 *
 * Rendered URL: cart.php?a=add&domain=transfer
 *
 * Visual source: apple-client-area/cart-domain-transfer.html
 *
 * Shell = .st-page-header (H1 "Transfer a Domain" + subtitle)
 *         + .st-split (240px Categories sidebar + 1fr main)
 *           |- sidebar-categories.tpl (Categories + Actions, hadrian_cart's)
 *           `- main column
 *               |- .dt-when-full (default state)
 *               |   |- .dt-search card  (pill input + auth code + captcha)
 *               |   |- "Transfer in 3 steps" section
 *               |   `- "Why transfer to us" section
 *               `- .dt-when-empty (state-chip Empty preview)
 *
 * State-chip wiring:
 *   - body[data-data="empty|full"] -- stamped pre-paint to "full" by
 *     default (user landed here to transfer). The .dt-when-full /
 *     .dt-when-empty rules below pick that up.
 *   - body[data-subnav="off"] / [data-subnav-side="left"] are already
 *     wired for .st-split in style.min.css (commit 4247045) -- no extra
 *     CSS needed here.
 *
 * WHMCS contract preserved verbatim (scripts.min.js binds these):
 *   - Form id="frmDomainTransfer", POST to cart.php, hidden a=addDomainTransfer
 *   - #inputTransferDomain (name=domain) -- prefilled with $lookupTerm
 *   - #inputAuthCode (name=epp)
 *   - #transferUnavailable (server-side error feedback, .w-hidden by default)
 *   - #captchaContainer + #inputCaptchaImage + #inputCaptcha (name=code) when
 *     $captcha->isEnabled() && !$captcha->recaptcha->isEnabled()
 *   - reCAPTCHA visible variant: #captchaContainer alone
 *   - #btnTransferDomain (.btn-transfer + getButtonClass), #addTransferLoader,
 *     #addToCart span
 *
 * CSS lives inline in the {literal}<style>{/literal} block at the top --
 * same pattern as configureproduct.tpl + viewcart.tpl. No new .dt-* rules
 * in style.min.css.
 *}

{include file="orderforms/$carttpl/common.tpl"}

<style>{literal}
/* ----------------------------------------------------------------
   Page-local layout (.dt-* tokens, domain Transfer).
   Apple primitives (.card, .btn-primary, .btn-secondary, .alert) come
   from style.min.css; only page-unique tokens live here.
   ---------------------------------------------------------------- */

/* Full / empty toggle -- scoped so hadrian's global .when-full hide
   doesn't fight us on cart routes (see CLAUDE.md note in viewcart.tpl). */
body[data-data="empty"] .dt-when-full { display: none; }
body:not([data-data="empty"]) .dt-when-empty { display: none; }

/* ---- Pill-shaped quick-domain search box (top of page) ---- */
.dt-search {
    margin-bottom: 24px;
    padding: 22px;
    background: var(--color-surface);
    border: 0.5px solid var(--color-border);
    border-radius: 14px;
}
.dt-search-box {
    display: flex; align-items: center; gap: 0;
    border: 0.5px solid var(--color-border);
    border-radius: var(--radius-pill);
    background: var(--color-surface);
    padding: 0 4px 0 16px;
    height: 52px;
    transition: border-color var(--transition-fast), box-shadow var(--transition-fast);
}
.dt-search-box:focus-within {
    border-color: var(--color-accent);
    box-shadow: 0 0 0 3px var(--color-accent-light);
}
.dt-search-icon {
    width: 16px; height: 16px;
    color: var(--color-text-tertiary);
    flex-shrink: 0;
}
.dt-search-input {
    flex: 1; min-width: 0;
    border: 0; background: transparent;
    padding: 0 12px; height: 100%;
    font-size: 15px; letter-spacing: -0.012em;
    color: var(--color-text-primary);
    font-family: inherit;
}
.dt-search-input:focus { outline: none; box-shadow: none; }
.dt-search-input::placeholder { color: var(--color-text-quaternary); }
.dt-transfer-btn {
    height: 44px; padding: 0 22px;
    border-radius: var(--radius-pill);
    background: var(--color-accent); color: #fff; border: 0;
    font-size: 13.5px; font-weight: 500;
    font-family: inherit; cursor: pointer;
    letter-spacing: -0.008em; flex-shrink: 0;
    display: inline-flex; align-items: center; justify-content: center; gap: 6px;
}
.dt-transfer-btn:hover { background: var(--color-accent-hover); }
.dt-transfer-btn .loader { display: inline-flex; }
.dt-transfer-btn svg { width: 14px; height: 14px; }

/* Auth code field + captcha sit below the pill bar in the same card. */
.dt-auxiliary { margin-top: 16px; display: flex; flex-direction: column; gap: 14px; }
.dt-field { display: flex; flex-direction: column; gap: 6px; }
.dt-field label {
    display: flex; align-items: center; justify-content: space-between;
    font-size: 12.5px; font-weight: 500;
    color: var(--color-text-secondary);
    letter-spacing: -0.004em;
}
.dt-field-help {
    color: var(--color-accent);
    text-decoration: none;
    font-size: 11.5px; font-weight: 500;
    display: inline-flex; align-items: center; gap: 4px;
}
.dt-field-help:hover { text-decoration: underline; }
.dt-field-help svg { width: 12px; height: 12px; }
.dt-input {
    height: 40px;
    padding: 0 14px;
    border: 0.5px solid var(--color-border);
    border-radius: var(--radius-md);
    background: var(--color-surface);
    font-size: 14px; color: var(--color-text-primary);
    letter-spacing: -0.008em; font-family: inherit;
    transition: border-color var(--transition-fast);
}
.dt-input:focus {
    outline: none;
    border-color: var(--color-accent);
    box-shadow: 0 0 0 3px var(--color-accent-light);
}

/* Captcha container -- the simple-captcha image + 6-char code input. */
.dt-captcha {
    display: flex; align-items: center; gap: 14px;
    padding: 14px;
    border: 0.5px solid var(--color-border);
    border-radius: var(--radius-md);
    background: var(--color-surface-secondary);
}
.dt-captcha p {
    flex: 1; margin: 0;
    font-size: 12.5px;
    color: var(--color-text-secondary);
    letter-spacing: -0.004em;
}
.dt-captcha img {
    height: 36px; border-radius: 4px;
    flex-shrink: 0; background: #fff;
}
.dt-captcha input {
    width: 100px; height: 36px;
    padding: 0 10px;
    border: 0.5px solid var(--color-border);
    border-radius: var(--radius-md);
    background: var(--color-surface);
    font-size: 14px; color: var(--color-text-primary);
    font-variant-numeric: tabular-nums;
    text-align: center;
    font-family: inherit;
}
.dt-captcha input:focus { outline: none; border-color: var(--color-accent); }

/* Server-side error feedback shown by scripts.min.js when transfer fails. */
.dt-search .alert {
    margin: 16px 0 0;
    padding: 10px 14px;
    border-radius: var(--radius-md);
    font-size: 13px;
    line-height: 1.4;
}

/* ---- Section heads (Transfer in 3 steps / Why transfer to us) ---- */
.dt-section { margin-bottom: 28px; }
.dt-section-head { margin-bottom: 16px; }
.dt-section-head h2 {
    font-size: 18px; font-weight: 600;
    color: var(--color-text-primary);
    letter-spacing: -0.018em;
    margin: 0 0 4px;
}
.dt-section-head p {
    font-size: 13px;
    color: var(--color-text-tertiary);
    margin: 0;
    letter-spacing: -0.008em;
}

/* ---- Step cards (3-up grid; one card per step / reason) ---- */
.dt-steps {
    display: grid;
    grid-template-columns: repeat(3, 1fr);
    gap: 14px;
}
@media (max-width: 720px) { .dt-steps { grid-template-columns: 1fr; } }
.dt-step {
    padding: 22px;
    background: var(--color-surface);
    border: 0.5px solid var(--color-border);
    border-radius: 14px;
}
.dt-step-ico {
    width: 40px; height: 40px; border-radius: 10px;
    display: flex; align-items: center; justify-content: center;
    margin-bottom: 14px;
}
.dt-step-ico svg { width: 20px; height: 20px; }
.dt-step-ico.blue   { background: var(--color-accent-light); color: var(--color-accent); }
.dt-step-ico.green  { background: var(--color-green-bg);     color: var(--color-green-text); }
.dt-step-ico.orange { background: rgba(255, 149, 0, 0.12);   color: #ff9500; }
.dt-step-ico.purple { background: rgba(175, 82, 222, 0.12);  color: #af52de; }
.dt-step h4 {
    font-size: 14px; font-weight: 600;
    color: var(--color-text-primary);
    margin: 0 0 4px;
    letter-spacing: -0.01em;
}
.dt-step p {
    font-size: 13px;
    color: var(--color-text-secondary);
    margin: 0;
    line-height: 1.5;
    letter-spacing: -0.004em;
}

/* ---- Footer fine print ---- */
.dt-footnote {
    margin-top: 24px;
    font-size: 11.5px;
    color: var(--color-text-tertiary);
    text-align: center;
    letter-spacing: -0.004em;
}

/* ---- Empty state (state-chip Empty preview only -- the page itself
   is always rendered "full" since the user lands here to transfer). ---- */
.dt-empty {
    padding: 64px 24px;
    text-align: center;
    display: flex; flex-direction: column; align-items: center; gap: 12px;
}
.dt-empty-ico {
    width: 56px; height: 56px; border-radius: 50%;
    background: var(--color-bg);
    color: var(--color-text-tertiary);
    display: inline-flex; align-items: center; justify-content: center;
}
.dt-empty-ico svg { width: 22px; height: 22px; }
.dt-empty h2 {
    font-size: 18px; font-weight: 600;
    color: var(--color-text-primary);
    letter-spacing: -0.014em;
    margin: 0;
}
.dt-empty p {
    font-size: 13.5px;
    color: var(--color-text-tertiary);
    line-height: 1.55;
    letter-spacing: -0.004em;
    max-width: 380px;
    margin: 0;
}
.dt-empty .btn-primary {
    height: 42px; padding: 0 24px; font-size: 14px;
    display: inline-flex; align-items: center; gap: 6px;
    margin-top: 6px;
}
{/literal}</style>

{* Initial body[data-data] state so state-chip's Full/Empty preview lines
   up with the actual page state on first paint. Default = "full" since
   the user always lands here intending to transfer something. *}
<script>{literal}
(function () {
    try { localStorage.removeItem('hn.data'); } catch (e) {}
    var d = document.body && document.body.dataset;
    if (d && !d.data) { d.data = 'full'; }
})();
{/literal}</script>

<div id="order-standard_cart">

    <header class="st-page-header">
        <h1>{$LANG.transferdomain}</h1>
        <p class="page-subtitle">{$LANG.orderForm.transferExtend}*</p>
    </header>

    <div class="st-split">

        {* ── Sidebar: Categories + Actions (hadrian_cart's, not standard_cart's) ── *}
        {include file="orderforms/$carttpl/sidebar-categories.tpl"}

        {* ── Main column ── *}
        <div style="min-width: 0;">

            {* ════════════════════════════════════════════════════════
               FULL: default transfer page with form + step cards
               ════════════════════════════════════════════════════════ *}
            <div class="dt-when-full">

                {* ───── Quick transfer search card ─────
                   Pill-shaped domain input + Transfer button; auth code,
                   captcha, and inline error live underneath inside the
                   same card so a single form submit posts everything. *}
                <form method="post" action="{$WEB_ROOT}/cart.php" id="frmDomainTransfer">
                    <input type="hidden" name="a" value="addDomainTransfer">

                    <div class="dt-search">
                        <div class="dt-search-box">
                            <svg class="dt-search-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M21 15v4a2 2 0 01-2 2H5a2 2 0 01-2-2v-4"/><polyline points="17 8 12 3 7 8"/><line x1="12" y1="3" x2="12" y2="15"/></svg>
                            <input type="text"
                                   class="dt-search-input"
                                   id="inputTransferDomain"
                                   name="domain"
                                   value="{$lookupTerm|escape}"
                                   placeholder="{$LANG.yourdomainplaceholder}.{$LANG.yourtldplaceholder}"
                                   data-toggle="tooltip" data-placement="left" data-trigger="manual"
                                   title="{$LANG.orderForm.enterDomain}"
                                   autocomplete="off" />
                            <button type="submit"
                                    id="btnTransferDomain"
                                    class="dt-transfer-btn btn-transfer{$captcha->getButtonClass($captchaForm)}">
                                <span class="loader w-hidden" id="addTransferLoader" aria-hidden="true">
                                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="12" y1="2" x2="12" y2="6"/><line x1="12" y1="18" x2="12" y2="22"/><line x1="4.93" y1="4.93" x2="7.76" y2="7.76"/><line x1="16.24" y1="16.24" x2="19.07" y2="19.07"/><line x1="2" y1="12" x2="6" y2="12"/><line x1="18" y1="12" x2="22" y2="12"/><line x1="4.93" y1="19.07" x2="7.76" y2="16.24"/><line x1="16.24" y1="7.76" x2="19.07" y2="4.93"/></svg>
                                </span>
                                <span id="addToCart">{$LANG.orderForm.addToCart}</span>
                            </button>
                        </div>

                        <div class="dt-auxiliary">

                            {* Authorization code (EPP) -- required by WHMCS *}
                            <div class="dt-field">
                                <label for="inputAuthCode">
                                    <span>{$LANG.orderForm.authCode}</span>
                                    <a class="dt-field-help"
                                       data-toggle="tooltip" data-placement="left"
                                       title="{$LANG.orderForm.authCodeTooltip}">
                                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><circle cx="12" cy="12" r="10"/><path d="M9.09 9a3 3 0 015.83 1c0 2-3 3-3 3"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg>
                                        {$LANG.orderForm.help}
                                    </a>
                                </label>
                                <input type="text"
                                       class="dt-input"
                                       id="inputAuthCode"
                                       name="epp"
                                       placeholder="{$LANG.orderForm.authCodePlaceholder}"
                                       data-toggle="tooltip" data-placement="left" data-trigger="manual"
                                       title="{$LANG.orderForm.required}"
                                       autocomplete="off" />
                            </div>

                            {* Captcha -- simple-captcha image variant *}
                            {if $captcha->isEnabled() && !$captcha->recaptcha->isEnabled()}
                                <div class="dt-captcha" id="captchaContainer">
                                    <p>{$LANG.cartSimpleCaptcha}</p>
                                    <img id="inputCaptchaImage" src="{$systemurl}includes/verifyimage.php" alt="captcha" />
                                    <input id="inputCaptcha"
                                           type="text" name="code" maxlength="6"
                                           data-toggle="tooltip" data-placement="right" data-trigger="manual"
                                           title="{$LANG.orderForm.required}"
                                           autocomplete="off" />
                                </div>
                            {elseif $captcha->isEnabled() && $captcha->recaptcha->isEnabled() && !$captcha->recaptcha->isInvisible()}
                                {* reCAPTCHA visible variant -- container only, JS renders into it *}
                                <div class="recaptcha-container" id="captchaContainer"></div>
                            {/if}

                            {* Server-side transfer error feedback (.w-hidden by default,
                               unhidden by scripts.min.js on AJAX failure). *}
                            <div id="transferUnavailable" class="alert alert-warning slim-alert w-hidden"></div>

                        </div>
                    </div>{* /.dt-search *}
                </form>

                {* ───── Transfer in 3 steps ───── *}
                <div class="dt-section">
                    <div class="dt-section-head">
                        <h2>{$hadrianLang.domains.transferStepsTitle}</h2>
                        <p>{$hadrianLang.domains.transferStepsDesc}</p>
                    </div>
                    <div class="dt-steps">
                        <div class="dt-step">
                            <div class="dt-step-ico blue" aria-hidden="true">
                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="11" width="18" height="11" rx="2"/><path d="M7 11V7a5 5 0 0110 0v4"/></svg>
                            </div>
                            <h4>{$hadrianLang.domains.transferStep1Title}</h4>
                            <p>{$hadrianLang.domains.transferStep1Desc}</p>
                        </div>
                        <div class="dt-step">
                            <div class="dt-step-ico green" aria-hidden="true">
                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M9 12l2 2 4-4"/><circle cx="12" cy="12" r="10"/></svg>
                            </div>
                            <h4>{$hadrianLang.domains.transferStep2Title}</h4>
                            <p>{$hadrianLang.domains.transferStep2Desc}</p>
                        </div>
                        <div class="dt-step">
                            <div class="dt-step-ico orange" aria-hidden="true">
                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M22 2L11 13"/><path d="M22 2l-7 20-4-9-9-4z"/></svg>
                            </div>
                            <h4>{$hadrianLang.domains.transferStep3Title}</h4>
                            <p>{$hadrianLang.domains.transferStep3Desc}</p>
                        </div>
                    </div>
                </div>

                {* ───── Why transfer to us ───── *}
                <div class="dt-section">
                    <div class="dt-section-head">
                        <h2>{$hadrianLang.domains.transferWhyTitle}</h2>
                    </div>
                    <div class="dt-steps">
                        <div class="dt-step">
                            <div class="dt-step-ico purple" aria-hidden="true">
                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"/></svg>
                            </div>
                            <h4>{$hadrianLang.domains.transferWhyExtendTitle}</h4>
                            <p>{$hadrianLang.domains.transferWhyExtendDesc}</p>
                        </div>
                        <div class="dt-step">
                            <div class="dt-step-ico blue" aria-hidden="true">
                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg>
                            </div>
                            <h4>{$hadrianLang.domains.transferWhy24Title}</h4>
                            <p>{$hadrianLang.domains.transferWhy24Desc}</p>
                        </div>
                        <div class="dt-step">
                            <div class="dt-step-ico green" aria-hidden="true">
                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="11" width="18" height="11" rx="2"/><path d="M7 11V7a5 5 0 0110 0v4"/></svg>
                            </div>
                            <h4>{$hadrianLang.domains.transferWhyPrivacyTitle}</h4>
                            <p>{$hadrianLang.domains.transferWhyPrivacyDesc}</p>
                        </div>
                    </div>
                </div>

                <p class="dt-footnote">* {$LANG.orderForm.extendExclusions}</p>

            </div>{* /.dt-when-full *}

            {* ════════════════════════════════════════════════════════
               EMPTY: state-chip Empty preview only.
               The page is functionally always "full" -- this block lets
               the chip's Data: Empty toggle still render something usable.
               ════════════════════════════════════════════════════════ *}
            <div class="dt-when-empty">
                <div class="card dt-empty">
                    <div class="dt-empty-ico" aria-hidden="true">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M3 12h13"/><polyline points="11 7 16 12 11 17"/><path d="M19 5v14"/></svg>
                    </div>
                    <h2>{$hadrianLang.domains.transferEmptyTitle}</h2>
                    <p>{$hadrianLang.domains.transferEmptyDesc}</p>
                    <a href="{$WEB_ROOT}/cart.php?a=add&domain=transfer" class="btn-primary">
                        {$hadrianLang.domains.transferEmptyCta}
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><polyline points="9 18 15 12 9 6"/></svg>
                    </a>
                </div>
            </div>{* /.dt-when-empty *}

        </div>{* /main column *}
    </div>{* /.st-split *}

</div>{* /#order-standard_cart *}
