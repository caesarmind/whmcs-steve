{*
 * mytheme_cart/checkout.tpl
 *
 * Apple visual shell over standard_cart's exact checkout contract.
 *
 * Checkout is the most contract-heavy template in the cart flow —
 * every field name and id is wired into scripts.min.js, the gateway
 * integration code, the password strength meter, the VAT validator,
 * the CartTotalUpdater poller, and the cart-checkout server handler.
 * One typo and a payment-method radio stops binding, or the live
 * total stops updating, or 3DS fails to launch.
 *
 * This file therefore PRESERVES THE STANDARD_CART MARKUP VERBATIM
 * for the form body, and ONLY swaps the page-level chrome (header,
 * help banner, .secondary-cart-sidebar trust strip). The Apple visual
 * comes from the CSS shim in apple-layout.css (which already styles
 * #order-standard_cart's .sub-heading, .form-group.prepend-icon,
 * .panel-addon, .alert-*, .radio, .btn-*, etc.).
 *
 * Contract surface kept intact — every element id JS / gateway code
 * binds to is preserved:
 *   form: #frmCheckout name=orderfrm + checkout=true + custtype +
 *         validation_tax_id + isTaxEUTaxExempt + taxType +
 *         isTaxInclusiveDeduct hidden inputs
 *   existing-account: #containerExistingAccountSelect, account{id}
 *         radios, account_id name
 *   existing-login: #containerExistingUserSignin, #inputLoginEmail
 *         loginemail, #inputLoginPassword loginpassword,
 *         #btnExistingLogin, #existingLoginButton,
 *         #existingLoginPleaseWait, #existingLoginMessage
 *   new-signup: #containerNewUserSignup, #inputFirstName firstname,
 *         #inputLastName lastname, #inputEmail email, #inputPhone
 *         phonenumber
 *   billing: #inputCompanyName companyname, #inputAddress1 address1,
 *         #inputAddress2 address2, #inputCity city, #inputState
 *         state, #inputPostcode postcode, #inputCountry country,
 *         #inputTaxId tax_id
 *   domain contact: #inputDomainContact contact +
 *         #domainRegistrantInputFields with #inputDC* fields
 *         (firstname, lastname, email, phone, companyname, address1,
 *         address2, city, state, postcode, country, tax_id with
 *         domaincontactX names)
 *   security: #containerNewUserSecurity, #containerPassword,
 *         #inputNewPassword1 password + #inputNewPassword2 password2,
 *         #passwdFeedback, #passwordStrengthMeterBar,
 *         #passwordStrengthTextLabel, #inputSecurityQId securityqid,
 *         #inputSecurityQAns securityqans, .generate-password
 *   credit-balance: #applyCreditContainer, #useCreditOnCheckout +
 *         #skipCreditOnCheckout applycredit, #spanFullCredit,
 *         #spanUseCredit, data-apply-credit
 *   gateways: #paymentGatewaysContainer, .payment-methods
 *         paymentmethod, .is-credit-card, #paymentGatewayInput
 *   CC fields: #creditCardInputFields, #existingCardsContainer,
 *         #existingCardInfo, #inputCardCVV2, #newCardInfo,
 *         #inputCardNumber ccnumber, #inputCardExpiry ccexpirydate,
 *         #inputCardCVV cccvv, #inputCardStart ccstartdate,
 *         #inputCardIssue ccissuenum, #newCardSaveSettings,
 *         #inputDescription ccdescription, #inputNoStore nostore,
 *         #cardNumberContainer, #inputDescriptionContainer,
 *         #inputNoStoreContainer, #cvv-field-container
 *   notes: notes textarea
 *   TOS: #accepttos accepttos
 *   submit: #btnCompleteOrder .disable-on-click .spinner-on-click
 *   live total: #totalDueToday alert + #totalCartPrice strong
 *   buttons: #btnAlreadyRegistered, #btnNewUserSignup
 *   error feedback classes: .gateway-errors,
 *         .checkout-error-feedback, .vat-error
 *
 * Visual sources used by apple-layout.css to skin this content:
 *   - apple-client-area/cart.html (right-rail summary patterns)
 *   - the broad cart-flow CSS shim (#order-standard_cart .form-group
 *     .prepend-icon, .sub-heading, .alert, .btn, .radio, …)
 *}

<script>
    var statesTab = 10;
    var stateNotRequired = true;
</script>
{* ── WHMCS namespace stubs ──
   scripts.min.js (orderforms/standard_cart/js/scripts.min.js) wraps
   its bootstrap in an IIFE that runs:
       "object" != typeof e.WHMCS && (e.WHMCS = { hasModule, loadModule })
   i.e. if we pre-define `window.WHMCS` at all before scripts.min.js,
   the bootstrap is SKIPPED -- and with it the functional hasModule /
   loadModule that scripts.min.js itself uses to register
   `utils`, `http`, `authn`, `ui`, `form`, `recaptcha`, `client`.
   When those modules never register, the very next top-level call
   `WHMCS.utils.validateBaseUrl()` throws
       Cannot read properties of undefined (reading 'validateBaseUrl')
   and kills every subsequent .ready() handler.

   So our stub must replicate the bootstrap byte-for-byte (same
   hasModule + loadModule shape) before adding the host-specific
   missing pieces (WHMCS.payment.event.*, WHMCS.payment.display.*,
   WHMCS.jqClient). This install's WHMCS app shell doesn't emit those.

   Stubs cover:
   - WHMCS.hasModule / loadModule -> faithful copy of scripts.min.js
     bootstrap (so module registration still works)
   - WHMCS.payment.event.* -> no-op stubs for gatewayInit,
     gatewayOptionInit, gatewayUnselected, gatewaySelected,
     checkoutFormSubmit + previouslySelected.module bag
   - WHMCS.payment.display.errorClear -> no-op
   - WHMCS.jqClient -> live getter that returns window.jQuery once it
     loads (Stripe etc. read this AFTER jQuery is on the page)

   IMPORTANT: this <script> body contains object-literal `{}` braces
   so it must be wrapped in {literal}...{/literal} -- otherwise Smarty
   treats `{ return false; }` etc. as tags and emits broken JS that
   throws SyntaxError: Unexpected token '}' on the page. *}
<script>{literal}
    /* Faithful copy of the bootstrap shape in scripts.min.js so we
       don't break its check `"object" != typeof window.WHMCS`. */
    if (typeof window.WHMCS !== 'object') {
        window.WHMCS = {
            hasModule: function (name) {
                return typeof window.WHMCS[name] !== 'undefined'
                    && Object.getOwnPropertyNames(window.WHMCS[name]).length > 0;
            },
            loadModule: function (name, body) {
                if (this.hasModule(name)) { return; }
                window.WHMCS[name] = {};
                if (typeof body === 'function') {
                    body.apply(window.WHMCS[name]);
                } else {
                    for (var key in body) {
                        if (body.hasOwnProperty(key)) {
                            window.WHMCS[name][key] = {};
                            body[key].apply(window.WHMCS[name][key]);
                        }
                    }
                }
            }
        };
    }

    /* Host-shell pieces this install never emits. scripts.min.js
       calls these inside its document.ready handler that wires up
       .payment-methods radios -- without them the ready chain
       throws and every subsequent handler is silently dropped. */
    window.WHMCS.payment = window.WHMCS.payment || {};
    window.WHMCS.payment.event = window.WHMCS.payment.event || {};
    window.WHMCS.payment.event.previouslySelected =
        window.WHMCS.payment.event.previouslySelected || { module: undefined };
    [
        'gatewayInit',
        'gatewayOptionInit',
        'gatewaySelected',
        'gatewayUnselected',
        'checkoutFormSubmit'
    ].forEach(function (fn) {
        if (typeof window.WHMCS.payment.event[fn] !== 'function') {
            window.WHMCS.payment.event[fn] = function () {};
        }
    });
    window.WHMCS.payment.display = window.WHMCS.payment.display || {};
    if (typeof window.WHMCS.payment.display.errorClear !== 'function') {
        window.WHMCS.payment.display.errorClear = function () {};
    }

    /* jqClient is read by gateway scripts (Stripe etc.) AFTER jQuery
       has loaded via common.tpl. Live getter so each access returns
       the current window.jQuery. */
    if (!Object.getOwnPropertyDescriptor(window.WHMCS, 'jqClient')) {
        Object.defineProperty(window.WHMCS, 'jqClient', {
            configurable: true,
            get: function () { return window.jQuery; },
            set: function (v) {
                Object.defineProperty(window.WHMCS, 'jqClient', {
                    value: v, writable: true, configurable: true, enumerable: true
                });
            }
        });
    }
{/literal}</script>
{include file="orderforms/$carttpl/common.tpl"}
<script type="text/javascript" src="{$BASE_PATH_JS}/StatesDropdown.js"></script>
<script type="text/javascript" src="{$BASE_PATH_JS}/PasswordStrength.js"></script>
<script type="text/javascript" src="{$BASE_PATH_JS}/VatValidator.js"></script>

{* intl-tel-input -- country-code chooser for #inputPhone. Adds a flag
   dropdown next to the phone field that lets the user pick their
   country, prepends the dial code, and formats as they type. Pinned
   to v18 because v19+ removes the auto-bundled utils and would need
   us to host utils.js ourselves. *}
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/intl-tel-input@18.5.3/build/css/intlTelInput.css">
<script src="https://cdn.jsdelivr.net/npm/intl-tel-input@18.5.3/build/js/intlTelInput.min.js"></script>

<script>
    window.langPasswordStrength = "{$LANG.pwstrength}";
    window.langPasswordWeak = "{$LANG.pwstrengthweak}";
    window.langPasswordModerate = "{$LANG.pwstrengthmoderate}";
    window.langPasswordStrong = "{$LANG.pwstrengthstrong}";
    window.langVatErrorInvalidFormat = "{$LANG.tax.errorVatInvalidFormat}";
</script>

<style>{literal}
/* Page-local checkout frame spacing */
.content-area { padding-top: 10px; padding-bottom: 10px; }

/* ── Apple checkout chrome (.co-*) ──
   Page-level wrapper around standard_cart's checkout form. Form body
   classes (.form-group prepend-icon, .sub-heading, .alert, .btn etc)
   are styled separately by apple-layout.css's cart-flow CSS shim --
   we only own the OUTER layout (page header, 5-step strip, 2-col
   split, sticky summary card on the right). Mirrors
   apple-client-area/checkout.html. */
.co-page-header { margin-bottom: 24px; display: flex; justify-content: space-between; align-items: flex-end; gap: 16px; flex-wrap: wrap; }
.co-page-header h1 { font-size: 32px; font-weight: 600; letter-spacing: -0.03em; color: var(--color-text-primary); margin: 0 0 6px; }
.co-page-header .co-sub { font-size: 14px; color: var(--color-text-tertiary); letter-spacing: -0.008em; margin: 0; }
.co-page-header .co-back-cart { height: 36px; padding: 0 16px; font-size: 13px; font-weight: 500; color: var(--color-text-primary); background: transparent; border: 0.5px solid var(--color-border); border-radius: 999px; text-decoration: none; display: inline-flex; align-items: center; gap: 6px; letter-spacing: -0.008em; transition: all 0.15s; }
.co-page-header .co-back-cart:hover { border-color: var(--color-accent); color: var(--color-accent); }

.co-steps { display: flex; align-items: center; gap: 10px; flex-wrap: wrap; margin-bottom: 18px; font-size: 12.5px; color: var(--color-text-tertiary); letter-spacing: -0.008em; }
.co-step { display: inline-flex; align-items: center; gap: 8px; }
.co-step-num { width: 22px; height: 22px; border-radius: 50%; background: var(--color-surface-secondary); color: var(--color-text-tertiary); display: inline-flex; align-items: center; justify-content: center; font-size: 11px; font-weight: 600; flex-shrink: 0; }
.co-step.done .co-step-num { background: var(--color-green-bg, #e8f5e8); color: var(--color-green-text, #34c759); }
.co-step.active .co-step-num { background: var(--color-accent); color: #fff; }
.co-step.active { color: var(--color-text-primary); font-weight: 500; }
.co-step-sep { color: var(--color-text-quaternary, #c7c7cc); }

.co-split { display: grid; grid-template-columns: 1fr 360px; gap: 24px; align-items: stretch; }
@media (max-width: 960px) { .co-split { grid-template-columns: 1fr; } }
.co-left { min-width: 0; display: flex; flex-direction: column; gap: 20px; }
.co-split > aside { min-height: 100%; }

/* Right summary card */
.co-summary-card { position: sticky; top: 72px; padding: 0; background: var(--color-surface); border: 0.5px solid var(--color-border); border-radius: 14px; }
.co-summary-head { padding: 18px 20px 14px; border-bottom: 0.5px solid var(--color-border); }
.co-summary-head h2 { font-size: 14px; font-weight: 600; color: var(--color-text-primary); letter-spacing: -0.01em; margin: 0; }
.co-summary-list { padding: 8px 20px; }
.co-summary-line { display: flex; justify-content: space-between; align-items: baseline; gap: 10px; padding: 8px 0; font-size: 12.5px; font-variant-numeric: tabular-nums; letter-spacing: -0.004em; background: transparent; border: 0; border-radius: 0; }
/* Explicit resets -- .label and .value are also Bootstrap badge class
   names, so without these the global Bootstrap shim from WHMCS paints
   each row's text with a white/grey pill behind it. */
.co-summary-line .label { color: var(--color-text-secondary); flex: 1; min-width: 0; background: transparent !important; padding: 0 !important; border: 0 !important; border-radius: 0 !important; font-size: inherit; font-weight: inherit; line-height: inherit; text-align: left; display: inline; white-space: normal; vertical-align: baseline; color: var(--color-text-secondary) !important; }
.co-summary-line .value { color: var(--color-text-primary); font-weight: 500; white-space: nowrap; background: transparent !important; padding: 0 !important; border: 0 !important; border-radius: 0 !important; }
.co-summary-line .value.muted { color: var(--color-text-tertiary); font-weight: 400; }
.co-summary-line .value.good { color: var(--color-green-text, #34c759) !important; font-weight: 500; }
.co-summary-line.divider { border-top: 0.5px solid var(--color-border); padding-top: 12px; margin-top: 4px; }
.co-summary-total { display: flex; justify-content: space-between; align-items: center; gap: 10px; padding: 18px 24px; border-top: 0.5px solid var(--color-border); background: var(--color-surface-tertiary); font-variant-numeric: tabular-nums; }
.co-summary-total .label { font-size: 15px; font-weight: 600; color: var(--color-text-primary) !important; letter-spacing: -0.01em; background: transparent !important; padding: 0 !important; border: 0 !important; border-radius: 0 !important; line-height: 1.2; display: inline; white-space: normal; vertical-align: baseline; }
.co-summary-total .value { font-size: 24px; font-weight: 600; color: var(--color-text-primary); letter-spacing: -0.025em; white-space: nowrap; background: transparent !important; padding: 0 !important; border: 0 !important; border-radius: 0 !important; }
.co-summary-cycle { font-size: 11px; color: var(--color-text-tertiary); padding: 10px 20px 14px; letter-spacing: -0.004em; margin: 0; }
.co-summary-footer {
    padding: 12px 18px 14px;
    border-top: 0.5px solid var(--color-border);
    display: flex; flex-direction: column; gap: 8px; align-items: stretch;
}
.co-summary-footer #btnCompleteOrder {
    width: 100%;
    height: 44px;
    padding: 0 18px;
    background: var(--color-accent);
    color: #fff;
    border: 0;
    border-radius: 999px;
    font-size: 14px;
    font-weight: 600;
    letter-spacing: -0.012em;
    cursor: pointer;
    transition: filter 0.15s;
    display: inline-flex; align-items: center; justify-content: center;
}
.co-summary-footer #btnCompleteOrder:hover:not(:disabled) { filter: brightness(0.95); }
.co-summary-footer #btnCompleteOrder:disabled { opacity: 0.7; cursor: not-allowed; }
.co-summary-footer .co-back-link {
    align-self: center;
    font-size: 12px;
    color: var(--color-text-tertiary);
    text-decoration: none;
    display: inline-flex; align-items: center; gap: 4px;
    letter-spacing: -0.008em;
    margin-top: 2px;
}
.co-summary-footer .co-back-link:hover { color: var(--color-accent); }
.co-trust-strip { padding: 14px 20px 16px; border-top: 0.5px solid var(--color-border); display: flex; flex-direction: column; gap: 6px; font-size: 11px; color: var(--color-text-tertiary); letter-spacing: -0.004em; }
.co-trust-strip .item { display: inline-flex; align-items: center; gap: 6px; }
.co-trust-strip .item i { color: var(--color-green-text, #34c759); width: 12px; flex-shrink: 0; }

/* Already-registered toggle row, restyled minimally so it fits the Apple chrome */
.already-registered { padding: 10px 0 14px; }
.already-registered p { color: var(--color-text-secondary); font-size: 13px; margin: 0; }

/* Additional Notes card */
.co-notes { padding: 18px 22px; background: var(--color-surface); border: 0.5px solid var(--color-border); border-radius: 14px; }
.co-notes-label { display: flex; align-items: center; gap: 6px; font-size: 13px; font-weight: 600; color: var(--color-text-primary); letter-spacing: -0.008em; margin: 0 0 8px; flex-wrap: wrap; }
.co-notes-label .hint { font-size: 11.5px; font-weight: 400; color: var(--color-text-tertiary); letter-spacing: -0.004em; }
.co-notes-area { width: 100%; min-height: 84px; padding: 10px 14px; border: 0.5px solid var(--color-border); border-radius: 10px; background: var(--color-surface); font-family: inherit; font-size: 13px; color: var(--color-text-primary); letter-spacing: -0.008em; line-height: 1.5; resize: vertical; transition: all 0.15s; box-sizing: border-box; }
.co-notes-area::placeholder { color: var(--color-text-quaternary, #c7c7cc); }
.co-notes-area:focus { outline: none; border-color: var(--color-accent); box-shadow: 0 0 0 3px var(--color-accent-light); }

/* Marketing-email-optin card */
.co-mailing { padding: 16px 20px; display: flex; align-items: center; gap: 14px; background: var(--color-surface); border: 0.5px solid var(--color-border); border-radius: 14px; }
.co-mailing-icon { width: 38px; height: 38px; border-radius: 10px; background: var(--color-accent-light); color: var(--color-accent); display: inline-flex; align-items: center; justify-content: center; flex-shrink: 0; }
.co-mailing-icon svg { width: 18px; height: 18px; }
.co-mailing-meta { flex: 1; min-width: 0; }
.co-mailing-title { font-size: 13.5px; font-weight: 600; color: var(--color-text-primary); letter-spacing: -0.008em; margin: 0 0 3px; }
.co-mailing-desc { font-size: 12px; color: var(--color-text-tertiary); margin: 0; letter-spacing: -0.004em; line-height: 1.5; }
/* Switch (ported from lagom2's switch__/switch__container/switch__handle
   pattern -- real <span> handle inside a real <span> track instead of a
   ::after pseudo. The hidden checkbox is sized to overlay the track
   with cursor:pointer so any click anywhere on the visible widget
   toggles state. No pointer-events tricks. */
.co-mailing-toggle {
    position: relative;
    width: 40px; height: 22px;
    flex-shrink: 0;
    cursor: pointer;
    user-select: none;
    display: inline-block;
}
.co-mailing-toggle input {
    position: absolute; inset: 0;
    width: 100%; height: 100%;
    margin: 0; padding: 0;
    opacity: 0;
    cursor: pointer;
    z-index: 2;
}
.co-mailing-switch {
    position: absolute; inset: 0;
    background: var(--color-surface-secondary);
    border: 0.5px solid var(--color-border);
    border-radius: 999px;
    transition: background 0.15s, border-color 0.15s;
    z-index: 1;
}
.co-mailing-handle {
    position: absolute;
    top: 1px; left: 1px;
    width: 18px; height: 18px;
    border-radius: 50%;
    background: #fff;
    box-shadow: 0 1px 3px rgba(0,0,0,0.18);
    transition: transform 0.15s;
}
.co-mailing-toggle input:checked ~ .co-mailing-switch {
    background: var(--color-green-text, #34c759);
    border-color: var(--color-green-text, #34c759);
}
.co-mailing-toggle input:checked ~ .co-mailing-switch .co-mailing-handle {
    transform: translateX(18px);
}

/* Last-chance offers card (wraps $hookOutput on checkout) */
.co-lastchance { padding: 0; background: var(--color-surface); border: 0.5px solid var(--color-border); border-radius: 14px; }
.co-lastchance-head { padding: 16px 22px; border-bottom: 0.5px solid var(--color-border); display: flex; align-items: center; gap: 10px; flex-wrap: wrap; }
.co-lastchance-badge { padding: 3px 10px; border-radius: 999px; background: var(--color-orange-bg, #fff7e6); color: var(--color-orange-text, #b25c00); font-size: 10px; font-weight: 600; letter-spacing: 0.06em; text-transform: uppercase; }
.co-lastchance-title { font-size: 14px; font-weight: 600; color: var(--color-text-primary); letter-spacing: -0.012em; }
.co-lastchance-sub { font-size: 11.5px; color: var(--color-text-tertiary); margin-left: auto; letter-spacing: -0.004em; }
.co-lastchance-body { padding: 14px 22px 18px; }
.co-lastchance-body > div + div { margin-top: 10px; }
.co-lastchance-body img { max-width: 100%; height: auto; }

/* Override standard_cart wrapper artefacts so the .content-area frame is clean */
#order-standard_cart { padding: 0 !important; background: transparent !important; }

/* ─── Form section cards ──────────────────────────────────────────
   Single-section containers (Existing Signin/Account, Security,
   Payment, Captcha) keep their one-card chrome. The multi-section
   container #containerNewUserSignup (Personal Info + Billing Address
   + optional Custom Fields) gets its chrome stripped and each
   .sub-heading + following .row pair becomes its own independent
   card via direct-child selectors. */
#containerNewUserSecurity,
#containerExistingUserSignin,
#containerExistingAccountSelect,
.co-payment-card,
.co-captcha-card {
    padding: 4px 22px 18px;
    background: var(--color-surface);
    border: 0.5px solid var(--color-border);
    border-radius: 14px;
}
#containerNewUserSecurity > .sub-heading:first-child,
.co-payment-card > .sub-heading:first-child { margin-top: 18px; }

/* Multi-section: each .sub-heading + .row pair = independent card.
   Uses #order-standard_cart prefix to bump specificity to (2,1,0) so
   we win the cascade against .co-left .sub-heading (which earlier in
   this file resets sub-heading typography/spacing to flat eyebrow text). */
#order-standard_cart #containerNewUserSignup {
    padding: 0;
    background: transparent;
    border: 0;
    border-radius: 0;
}
#order-standard_cart #containerNewUserSignup > .sub-heading {
    background: var(--color-surface);
    border: 0.5px solid var(--color-border);
    border-bottom: 0;
    border-radius: 14px 14px 0 0;
    margin: 12px 0 0;
    padding: 18px 22px 8px;
}
#order-standard_cart #containerNewUserSignup > .sub-heading:first-of-type { margin-top: 0; }
#order-standard_cart #containerNewUserSignup > .sub-heading + .row,
#order-standard_cart #containerNewUserSignup > .sub-heading + .field-container {
    background: var(--color-surface);
    border: 0.5px solid var(--color-border);
    border-top: 0;
    border-radius: 0 0 14px 14px;
    margin: 0;
    padding: 0 22px 12px;
}

.co-left .sub-heading {
    margin: 22px 0 12px;
    padding: 0;
    border: 0;
    background: transparent;
    font-size: 11px;
    font-weight: 600;
    letter-spacing: 0.08em;
    text-transform: uppercase;
    color: var(--color-text-tertiary);
}
.co-left .sub-heading .primary-bg-color,
.co-left .sub-heading > span {
    background: transparent !important;
    color: inherit !important;
    padding: 0 !important;
    border: 0 !important;
    font: inherit;
}

/* Bootstrap-era form rows -- compact Apple-style inputs */
.co-left .row { margin: 0 -7px; }
.co-left .row > [class*="col-"] { padding: 0 7px; margin-bottom: 12px; }
.co-left .form-group { margin: 0; }
.co-left .form-group.prepend-icon { position: relative; }
.co-left .form-group.prepend-icon .field-icon {
    position: absolute;
    left: 14px; top: 50%;
    transform: translateY(-50%);
    z-index: 2;
    color: var(--color-text-tertiary);
    font-size: 13px;
    pointer-events: none;
    margin: 0;
}
.co-left .form-group.prepend-icon .field-icon i { line-height: 1; }
.co-left .form-control,
.co-left .field {
    width: 100%;
    height: 42px;
    padding: 0 14px 0 38px;
    border: 0.5px solid var(--color-border);
    border-radius: 10px;
    background: var(--color-surface);
    font-size: 13.5px;
    color: var(--color-text-primary);
    font-family: inherit;
    letter-spacing: -0.008em;
    box-sizing: border-box;
    transition: all 0.15s;
}
.co-left textarea.form-control { height: auto; padding: 10px 14px; }
.co-left select.form-control { appearance: none; -webkit-appearance: none; background-image: url("data:image/svg+xml;utf8,<svg xmlns='http://www.w3.org/2000/svg' width='12' height='12' viewBox='0 0 24 24' fill='none' stroke='%238e8e93' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'><polyline points='6 9 12 15 18 9'/></svg>"); background-repeat: no-repeat; background-position: right 14px center; padding-right: 32px; }
.co-left .form-control:focus,
.co-left .field:focus {
    outline: none;
    border-color: var(--color-accent);
    box-shadow: 0 0 0 3px var(--color-accent-light);
}
.co-left .form-control::placeholder { color: var(--color-text-quaternary, #c7c7cc); }

/* Already-registered + Create-account buttons -- pill secondary.
   Qualify with :not(.w-hidden) so the `display: inline-flex` rule
   doesn't outrank `.w-hidden { display: none }` (ID specificity 1,0,0
   would otherwise beat the class). Without this, Smarty correctly
   emits `.w-hidden` on the inactive button (default custtype=new
   hides #btnNewUserSignup) but it stays visible in the DOM. */
.already-registered .btn:not(.w-hidden),
#btnAlreadyRegistered:not(.w-hidden),
#btnNewUserSignup:not(.w-hidden),
.generate-password:not(.w-hidden),
.btn-default:not(.w-hidden),
.btn-info:not(.w-hidden),
.btn-warning:not(.w-hidden) {
    height: 36px;
    padding: 0 16px;
    border-radius: 999px;
    border: 0.5px solid var(--color-border);
    background: transparent;
    color: var(--color-text-primary);
    font-size: 13px;
    font-weight: 500;
    letter-spacing: -0.008em;
    cursor: pointer;
    transition: all 0.15s;
    display: inline-flex; align-items: center; gap: 6px;
}
.already-registered .btn:hover,
#btnAlreadyRegistered:hover,
#btnNewUserSignup:hover,
.generate-password:hover,
.btn-default:hover,
.btn-info:hover,
.btn-warning:hover {
    border-color: var(--color-accent);
    color: var(--color-accent);
}

/* Existing-user signin form */
#containerExistingUserSignin .sub-heading { margin-top: 18px; }
/* Bad-credentials error banner -- WHMCS scripts.js removes
   .w-hidden and injects the message text here on failure. Style
   so when it shows it actually looks like an alert. */
#existingLoginMessage,
#existingLoginMessage.alert.alert-danger {
    margin: 0 0 12px;
    padding: 12px 16px;
    background: var(--color-red-bg, rgba(255,59,48,0.08));
    color: var(--color-red-text, #d70015);
    border: 0.5px solid var(--color-red-text, #d70015);
    border-radius: 12px;
    font-size: 13px;
    line-height: 1.5;
    letter-spacing: -0.004em;
}
#existingLoginMessage.w-hidden { display: none; }
#existingLoginMessage:empty { display: none; }
#btnExistingLogin {
    margin-top: 8px;
    height: 42px;
    padding: 0 22px;
    background: var(--color-accent);
    color: #fff;
    border: 0;
    border-radius: 999px;
    font-size: 14px;
    font-weight: 500;
    cursor: pointer;
    transition: filter 0.15s;
}
#btnExistingLogin:hover { filter: brightness(0.95); }

/* Password-strength meter */
.password-strength-meter { margin-top: 4px; }
.password-strength-meter .progress {
    height: 6px;
    background: var(--color-surface-secondary);
    border-radius: 999px;
    overflow: hidden;
    margin: 0;
}
.password-strength-meter .progress-bar {
    height: 100%;
    transition: width 0.2s ease, background 0.2s ease;
}
#passwordStrengthTextLabel { font-size: 11px; color: var(--color-text-tertiary); margin: 6px 0 0; text-align: left; letter-spacing: -0.004em; }

/* "Total Due Today" banner above payment radios */
#totalDueToday.alert-success {
    background: var(--color-accent-light);
    color: var(--color-accent);
    border: 0;
    border-radius: 12px;
    padding: 14px 18px;
    font-size: 14px;
    font-weight: 500;
    letter-spacing: -0.008em;
    margin: 4px 0 14px;
}
#totalDueToday.alert-success #totalCartPrice { font-size: 18px; font-weight: 600; letter-spacing: -0.012em; }

/* Apply-credit radio group */
#applyCreditContainer { padding: 12px 0 4px; }
#applyCreditContainer p { font-size: 12px; color: var(--color-text-tertiary); margin: 0 0 8px; }
#applyCreditContainer .radio { display: flex; align-items: flex-start; gap: 8px; padding: 6px 0; font-size: 13px; color: var(--color-text-primary); cursor: pointer; margin: 0; }
#applyCreditContainer .radio input { margin-top: 3px; accent-color: var(--color-accent); }

/* Payment method radios -- matches apple-client-area/checkout.html while
   preserving WHMCS's native paymentmethod radio contract. */
#paymentGatewaysContainer.co-pay-gateways { margin: 0 0 14px; }
#paymentGatewaysContainer .co-pay-list { display: flex; flex-direction: column; gap: 10px; }
#paymentGatewaysContainer .co-pay {
    display: flex;
    align-items: center;
    gap: 14px;
    padding: 14px 16px;
    border: 0.5px solid var(--color-border);
    border-radius: 12px;
    background: var(--color-surface);
    color: var(--color-text-primary);
    cursor: pointer;
    transition: border-color 0.15s, background 0.15s, box-shadow 0.15s;
    position: relative;
    margin: 0;
    text-align: left;
    min-height: 64px;
}
#paymentGatewaysContainer .co-pay input.payment-methods {
    position: absolute;
    opacity: 0;
    pointer-events: none;
}
#paymentGatewaysContainer .co-pay:hover,
#paymentGatewaysContainer .co-pay:focus-within { border-color: var(--color-accent); }
#paymentGatewaysContainer .co-pay:has(input:checked),
#paymentGatewaysContainer .co-pay.checked,
#paymentGatewaysContainer .co-pay.is-selected {
    border-color: var(--color-accent);
    background: var(--color-accent-light);
}
#paymentGatewaysContainer .co-pay-radio {
    width: 20px;
    height: 20px;
    border-radius: 50%;
    border: 1.5px solid var(--color-border);
    background: var(--color-surface);
    display: inline-flex;
    align-items: center;
    justify-content: center;
    flex-shrink: 0;
}
#paymentGatewaysContainer .co-pay-radio::after {
    content: "";
    width: 8px;
    height: 8px;
    border-radius: 50%;
    background: #fff;
    transform: scale(0);
    transition: transform 0.15s;
}
#paymentGatewaysContainer .co-pay:has(input:checked) .co-pay-radio,
#paymentGatewaysContainer .co-pay.checked .co-pay-radio,
#paymentGatewaysContainer .co-pay.is-selected .co-pay-radio {
    border-color: var(--color-accent);
    background: var(--color-accent);
}
#paymentGatewaysContainer .co-pay:has(input:checked) .co-pay-radio::after,
#paymentGatewaysContainer .co-pay.checked .co-pay-radio::after,
#paymentGatewaysContainer .co-pay.is-selected .co-pay-radio::after { transform: scale(1); }
#paymentGatewaysContainer .co-pay-logo {
    width: 40px;
    height: 26px;
    border-radius: 4px;
    display: inline-flex;
    align-items: center;
    justify-content: center;
    font-size: 9px;
    font-weight: 700;
    letter-spacing: 0.04em;
    color: #fff;
    flex-shrink: 0;
}
#paymentGatewaysContainer .co-pay-logo.card { background: #1a1f71; }
#paymentGatewaysContainer .co-pay-logo.pp { background: #003087; }
#paymentGatewaysContainer .co-pay-logo.stripe { background: #635bff; font-size: 10px; letter-spacing: 0; text-transform: lowercase; }
#paymentGatewaysContainer .co-pay-logo.bank { background: var(--color-surface-secondary); color: var(--color-text-primary); }
#paymentGatewaysContainer .co-pay-logo.gateway { background: #635bff; }
#paymentGatewaysContainer .co-pay-meta { flex: 1; min-width: 0; display: flex; flex-direction: column; gap: 2px; }
#paymentGatewaysContainer .co-pay-name {
    font-size: 13.5px;
    font-weight: 600;
    color: var(--color-text-primary);
    letter-spacing: -0.008em;
}
#paymentGatewaysContainer .co-pay-sub {
    font-size: 11.5px;
    color: var(--color-text-tertiary);
    letter-spacing: -0.004em;
    line-height: 1.35;
}

/* Credit-card input fields card */
#creditCardInputFields.co-card-input-panel {
    margin-top: 6px;
    padding: 16px;
    border: 0.5px dashed var(--color-border);
    border-radius: 12px;
    background: var(--color-surface-tertiary, var(--color-surface));
}
#creditCardInputFields .form-group { margin-bottom: 12px; }
#creditCardInputFields .control-label { font-size: 12px; color: var(--color-text-tertiary); margin: 0 0 4px; display: block; }
#creditCardInputFields > ul {
    margin: 0 0 14px;
    padding: 0;
    list-style: none;
}
#creditCardInputFields > ul .radio-inline {
    display: inline-flex;
    align-items: center;
    gap: 8px;
    padding: 8px 12px;
    border-radius: 999px;
    background: var(--color-surface);
    border: 0.5px solid var(--color-border);
    font-size: 12.5px;
    color: var(--color-text-primary);
    margin: 0;
}
#creditCardInputFields > ul .radio-inline input { margin: 0; accent-color: var(--color-accent); }

/* TOS + complete-order footer */
.checkout-footer { margin: 22px 0 16px; padding: 0; }
.checkout-footer label,
.checkout-footer .checkbox { display: flex; align-items: flex-start; gap: 10px; font-size: 13px; color: var(--color-text-secondary); margin: 0 0 16px; cursor: pointer; letter-spacing: -0.008em; }
.checkout-footer label input,
.checkout-footer .checkbox input { margin-top: 3px; accent-color: var(--color-accent); flex-shrink: 0; }
#btnCompleteOrder {
    width: 100%;
    height: 48px;
    padding: 0 22px;
    background: var(--color-accent);
    color: #fff;
    border: 0;
    border-radius: 999px;
    font-size: 15px;
    font-weight: 600;
    letter-spacing: -0.012em;
    cursor: pointer;
    transition: filter 0.15s;
    display: inline-flex; align-items: center; justify-content: center; gap: 8px;
}
#btnCompleteOrder:hover:not(:disabled) { filter: brightness(0.95); }
#btnCompleteOrder:disabled { opacity: 0.7; cursor: not-allowed; }
.checkout-footer .ct-trust,
.checkout-footer .ct-trust-checkout { display: none; }

/* SSL security alert */
.checkout-security-msg {
    background: var(--color-yellow-bg, #fff7e6);
    color: var(--color-yellow-text, #b25c00);
    border: 0.5px solid var(--color-yellow-text, #b25c00);
    border-radius: 12px;
    padding: 12px 16px;
    font-size: 12.5px;
    line-height: 1.5;
    letter-spacing: -0.004em;
    margin: 12px 0 0;
}

/* Validation-error banner (server-side, top of form) */
.checkout-error-feedback {
    background: var(--color-red-bg, rgba(255,59,48,0.08));
    color: var(--color-red-text, #d70015);
    border: 0.5px solid var(--color-red-text, #d70015);
    border-radius: 12px;
    padding: 12px 16px;
    margin: 0 0 14px;
    font-size: 13px;
    line-height: 1.5;
}
.checkout-error-feedback p { margin: 0 0 4px; font-weight: 600; }
.checkout-error-feedback ul { margin: 0; padding-left: 18px; }

/* Gateway-error banner (client-side -- Stripe iframe validation, payment
   intent validation_feedback). Lives inside .co-payment-card via
   includes/checkout/payment.tpl, between the gateway radios and the
   CC input fields (same position as lagom2's includes/viewcart/form-
   payment-gateway.tpl:67). Default Bootstrap .alert-danger styling
   reads as a stray red pill -- restyle to match #existingLoginMessage
   and .checkout-error-feedback so it feels like a member of the card.
   Strip the .text-center markup quirk by left-aligning so multi-line
   feedback wraps naturally. */
.co-payment-card .gateway-errors,
.co-payment-card .assisted-cc-input-feedback,
.gateway-errors.alert,
.gateway-errors.alert-danger {
    text-align: left;
    background: var(--color-red-bg, rgba(255,59,48,0.08));
    color: var(--color-red-text, #d70015);
    border: 0.5px solid var(--color-red-text, #d70015);
    border-radius: 12px;
    padding: 11px 14px 11px 36px;
    margin: 4px 0 12px;
    font-size: 13px;
    line-height: 1.5;
    letter-spacing: -0.004em;
    position: relative;
}
/* Inline warning glyph -- pure CSS so we don't depend on FontAwesome
   being loaded at first paint. */
.co-payment-card .gateway-errors::before,
.gateway-errors.alert::before {
    content: "";
    position: absolute;
    left: 14px;
    top: 13px;
    width: 14px;
    height: 14px;
    border-radius: 50%;
    background: var(--color-red-text, #d70015);
    color: #fff;
    font-size: 10px;
    font-weight: 700;
    line-height: 14px;
    text-align: center;
    box-shadow: inset 0 0 0 2px var(--color-red-text, #d70015);
}
.co-payment-card .gateway-errors::after,
.gateway-errors.alert::after {
    content: "!";
    position: absolute;
    left: 14px;
    top: 13px;
    width: 14px;
    height: 14px;
    color: #fff;
    font-size: 11px;
    font-weight: 700;
    line-height: 14px;
    text-align: center;
}
/* Validation feedback can come back as a bare <li> (no enclosing <ul>)
   from WHMCS's payment-intent response -- reset the bullet so it
   reads as plain text. */
.co-payment-card .gateway-errors li,
.gateway-errors li { list-style: none; }
.co-payment-card .gateway-errors ul,
.gateway-errors ul { margin: 0; padding: 0; }

/* Captcha block */
.co-captcha-card { padding: 18px 22px; text-align: center; }

/* ─── intl-tel-input override -- Apple-style ─────────────────────
   intl-tel-input ships with its own greyish chrome that clashes
   with the Apple look. Restyle the flag/dial-code button + dropdown
   so it reads as a real Apple-style segment of the phone field.
   .has-iti hides the absolute .field-icon (the FA phone glyph) on
   the phone form-group so we don't double-decorate the input. */
.form-group.prepend-icon.has-iti .field-icon { display: none; }
.form-group.prepend-icon.has-iti .iti { width: 100%; }
.form-group.prepend-icon.has-iti .iti__tel-input,
.form-group.prepend-icon.has-iti input.iti__tel-input.form-control {
    padding-left: 16px; /* iti's separateDialCode mode reserves left space already */
    box-sizing: border-box;
    width: 100%;
}

/* Selected-flag pill (the click target on the left) */
.iti--separate-dial-code .iti__selected-flag {
    background: var(--color-surface-secondary);
    border-right: 0.5px solid var(--color-border);
    border-radius: 10px 0 0 10px;
    padding: 0 10px 0 12px;
}
.iti--separate-dial-code .iti__selected-flag:hover,
.iti--separate-dial-code .iti__selected-flag:focus {
    background: var(--color-surface-tertiary);
}
.iti--separate-dial-code .iti__selected-dial-code {
    font-size: 13px;
    color: var(--color-text-secondary);
    letter-spacing: -0.008em;
    margin-left: 6px;
    font-variant-numeric: tabular-nums;
}
.iti__arrow {
    border-top-color: var(--color-text-tertiary);
    margin-left: 6px;
}

/* Dropdown panel */
.iti__country-list {
    background: var(--color-surface);
    border: 0.5px solid var(--color-border);
    border-radius: 12px;
    box-shadow: 0 16px 40px -8px rgba(0,0,0,0.18);
    padding: 6px 0;
    max-height: 260px;
    margin-top: 6px;
}
.iti__country {
    padding: 7px 14px;
    font-size: 13px;
    color: var(--color-text-primary);
    letter-spacing: -0.008em;
    display: flex;
    align-items: center;
    gap: 10px;
}
.iti__country:hover,
.iti__country.iti__highlight {
    background: var(--color-surface-secondary);
}
.iti__dial-code {
    color: var(--color-text-tertiary);
    font-variant-numeric: tabular-nums;
    margin-left: auto;
    font-size: 12px;
}
.iti__divider {
    border-bottom: 0.5px solid var(--color-border);
    margin: 4px 0;
}

/* Make the whole input row visually one unit */
.form-group.prepend-icon.has-iti {
    position: relative;
}
.form-group.prepend-icon.has-iti .iti__flag-container {
    z-index: 2;
}

/* ─── Generate-Password modal (.modal-generate-password) ─────────
   Apple-language modal that opens when the user clicks
   .generate-password (security.tpl). Bootstrap modal scaffolding
   (.modal / .modal-dialog / .modal-content) handles show/hide; the
   visual chrome (rounded card, header + body + footer, pill buttons,
   readonly password field with refresh icon) is owned here. */
.modal-generate-password .modal-dialog {
    margin: 8vh auto;
    max-width: 440px;
}
.modal-generate-password .modal-content {
    background: var(--color-surface);
    border: 0.5px solid var(--color-border);
    border-radius: 16px;
    box-shadow: 0 24px 60px -16px rgba(0,0,0,0.18);
    overflow: hidden;
}
.modal-generate-password .modal-header {
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 16px 22px 14px;
    border-bottom: 0.5px solid var(--color-border);
    background: var(--color-surface);
}
.modal-generate-password .modal-title {
    font-size: 15px;
    font-weight: 600;
    color: var(--color-text-primary);
    letter-spacing: -0.012em;
    margin: 0;
}
.modal-generate-password .modal-header .close {
    background: transparent;
    border: 0;
    width: 28px;
    height: 28px;
    border-radius: 50%;
    color: var(--color-text-tertiary);
    font-size: 22px;
    line-height: 26px;
    text-align: center;
    cursor: pointer;
    transition: background 0.15s, color 0.15s;
    padding: 0;
}
.modal-generate-password .modal-header .close:hover {
    background: var(--color-surface-secondary);
    color: var(--color-text-primary);
}
.modal-generate-password .modal-body { padding: 18px 22px 8px; }
.modal-generate-password .gp-field { margin: 0 0 14px; }
.modal-generate-password .gp-field label {
    display: block;
    font-size: 12px;
    font-weight: 500;
    color: var(--color-text-secondary);
    margin: 0 0 6px;
    letter-spacing: -0.004em;
}
.modal-generate-password .form-control {
    width: 100%;
    height: 38px;
    padding: 0 14px;
    border: 0.5px solid var(--color-border);
    border-radius: 10px;
    background: var(--color-surface);
    color: var(--color-text-primary);
    font-size: 13.5px;
    letter-spacing: -0.008em;
    font-variant-numeric: tabular-nums;
    transition: border-color 0.15s, box-shadow 0.15s;
    box-sizing: border-box;
}
.modal-generate-password .form-control:focus {
    outline: none;
    border-color: var(--color-accent);
    box-shadow: 0 0 0 3px var(--color-accent-light);
}
.modal-generate-password #inputGeneratePasswordOutput {
    font-family: ui-monospace, SFMono-Regular, "SF Mono", Menlo, Consolas, monospace;
    font-size: 14px;
    letter-spacing: 0;
}
/* Number-input spinner trim for the length field */
.modal-generate-password #inputGeneratePasswordLength {
    max-width: 110px;
}

.modal-generate-password .gp-output-row {
    display: flex;
    align-items: stretch;
    gap: 8px;
}
.modal-generate-password .gp-output-row .form-control { flex: 1; min-width: 0; }
.modal-generate-password .gp-btn {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    gap: 6px;
    height: 38px;
    padding: 0 16px;
    border-radius: 999px;
    font-size: 12.5px;
    font-weight: 500;
    letter-spacing: -0.008em;
    cursor: pointer;
    border: 0;
    transition: filter 0.15s, background 0.15s, color 0.15s, border-color 0.15s;
    white-space: nowrap;
}
.modal-generate-password .gp-btn-ghost {
    background: var(--color-surface-secondary);
    color: var(--color-text-primary);
    border: 0.5px solid var(--color-border);
}
.modal-generate-password .gp-btn-ghost:hover {
    border-color: var(--color-accent);
    color: var(--color-accent);
}
.modal-generate-password .gp-btn-ghost i {
    font-size: 11px;
    opacity: 0.8;
}
.modal-generate-password .gp-btn-secondary {
    background: var(--color-surface-secondary);
    color: var(--color-text-primary);
    border: 0.5px solid var(--color-border);
}
.modal-generate-password .gp-btn-secondary:hover {
    border-color: var(--color-text-secondary);
}
.modal-generate-password .gp-btn-primary {
    background: var(--color-accent);
    color: #fff;
}
.modal-generate-password .gp-btn-primary:hover { filter: brightness(0.95); }

.modal-generate-password #generatePwLengthError {
    background: var(--color-red-bg, rgba(255,59,48,0.08));
    color: var(--color-red-text, #d70015);
    border: 0.5px solid var(--color-red-text, #d70015);
    border-radius: 10px;
    padding: 9px 12px;
    margin: 0 0 12px;
    font-size: 12.5px;
    line-height: 1.5;
}

.modal-generate-password .modal-footer {
    display: flex;
    justify-content: flex-end;
    align-items: center;
    gap: 8px;
    padding: 14px 22px 18px;
    border-top: 0.5px solid var(--color-border);
    background: var(--color-surface-tertiary);
}

/* Generate-password trigger button in security.tpl is the standard_cart
   .btn-default.generate-password. Restyle to match the Apple pill so it
   doesn't read as a stray grey rectangle next to the password meter. */
.generate-password.btn-default,
button.generate-password {
    height: 36px;
    padding: 0 14px;
    background: var(--color-surface-secondary);
    color: var(--color-text-primary);
    border: 0.5px solid var(--color-border);
    border-radius: 999px;
    font-size: 12.5px;
    font-weight: 500;
    letter-spacing: -0.008em;
    cursor: pointer;
    transition: border-color 0.15s, color 0.15s;
    display: inline-flex;
    align-items: center;
    gap: 6px;
}
.generate-password.btn-default:hover,
button.generate-password:hover {
    border-color: var(--color-accent);
    color: var(--color-accent);
}

/* ─── Last-chance inner ($hookOutput grid) ──────────────────────
   WHMCS marketconnect hookOutput emits .mc-promos.checkout with N
   .mc-promo cards. Compact 1-per-row layout: icon | headline+tagline
   | price+Add button | expander. Body (features) hidden by default
   -- click the expander chevron to reveal. Defensive fallbacks for
   hooks that emit a simpler "one tile per outer div" structure. */
.co-lastchance-body { padding: 12px 16px 16px; }
.co-lastchance-body > div { margin: 0; padding: 0; }
.co-lastchance-body > div + div { margin-top: 6px; }

/* Grid container -- 1 card per row (compact list). */
.co-lastchance-body .mc-promos,
.co-lastchance-body .mc-promos.checkout {
    display: grid;
    grid-template-columns: 1fr;
    gap: 6px;
    padding: 0;
    margin: 0;
    list-style: none;
}
/* Per-card grid: icon | content | cta | expander on row 1, body
   underneath spans all. .header uses display:contents so its
   children flatten into the .mc-promo grid. */
.co-lastchance-body .mc-promo,
.co-lastchance-body > div:not(:has(.mc-promos)):not(.sub-heading) {
    position: relative;
    display: grid;
    grid-template-columns: 32px minmax(0, 1fr) auto 22px;
    grid-template-areas: "icon content cta expander" "body body body body";
    column-gap: 12px;
    align-items: center;
    padding: 8px 12px;
    border: 0.5px solid var(--color-border);
    border-radius: 10px;
    background: var(--color-surface);
    font-size: 12px;
    line-height: 1.45;
    color: var(--color-text-secondary);
    letter-spacing: -0.004em;
    max-height: none;
    overflow: visible;
    transition: border-color 0.15s, box-shadow 0.15s;
}
.co-lastchance-body .mc-promo:hover { border-color: var(--color-accent); box-shadow: 0 1px 6px rgba(0,0,0,0.05); }
.co-lastchance-body .mc-promo .header { display: contents; }
.co-lastchance-body .mc-promo .icon {
    grid-area: icon;
    width: 32px; height: 32px; border-radius: 8px;
    background: var(--color-surface-secondary);
    display: flex; align-items: center; justify-content: center;
    overflow: hidden; flex-shrink: 0;
    padding: 0; margin: 0;
}
.co-lastchance-body .mc-promo .icon img,
.co-lastchance-body .mc-promo > img,
.co-lastchance-body > div:not(:has(.mc-promos)) img {
    max-width: 22px; max-height: 22px; object-fit: contain;
    margin: 0; align-self: center; display: block;
}
/* Brand-tinted icons (matches native .mc-promo brand modifier classes) */
.co-lastchance-body .mc-promo.threesixtymonitoring .icon,
.co-lastchance-body .mc-promo.codeguard .icon,
.co-lastchance-body .mc-promo.marketgoo .icon { background: var(--color-orange-bg); }
.co-lastchance-body .mc-promo.symantec .icon,
.co-lastchance-body .mc-promo.nordvpn .icon,
.co-lastchance-body .mc-promo.sitelock .icon { background: var(--color-green-bg); }
.co-lastchance-body .mc-promo.spamexperts .icon { background: var(--color-red-bg, rgba(255,69,58,0.10)); }
.co-lastchance-body .mc-promo.appsuite .icon,
.co-lastchance-body .mc-promo.sitebuilder .icon,
.co-lastchance-body .mc-promo.weebly .icon { background: var(--color-accent-light); }
.co-lastchance-body .mc-promo .content {
    grid-area: content; min-width: 0; align-self: center;
    padding: 0; max-width: none;
}
.co-lastchance-body .mc-promo .headline,
.co-lastchance-body .mc-promo .headline.truncate {
    font-size: 13px; font-weight: 600; color: var(--color-text-primary);
    letter-spacing: -0.008em; line-height: 1.3;
    white-space: nowrap; overflow: hidden; text-overflow: ellipsis;
    margin: 0;
}
.co-lastchance-body .mc-promo .tagline,
.co-lastchance-body .mc-promo .tagline.truncate {
    font-size: 11px; color: var(--color-text-tertiary);
    margin: 1px 0 0; letter-spacing: -0.004em; line-height: 1.35;
    white-space: nowrap; overflow: hidden; text-overflow: ellipsis;
}
.co-lastchance-body .mc-promo .cta {
    grid-area: cta;
    display: flex; align-items: center; gap: 10px;
    flex-shrink: 0; padding: 0; margin: 0;
}
.co-lastchance-body .mc-promo .price {
    font-size: 12.5px; font-weight: 600; color: var(--color-text-primary);
    font-variant-numeric: tabular-nums; letter-spacing: -0.008em;
    white-space: nowrap; margin: 0;
}
.co-lastchance-body .mc-promo .btn-add,
.co-lastchance-body .mc-promo .btn.btn-add,
.co-lastchance-body .mc-promo button.btn-add,
.co-lastchance-body .mc-promo a.btn-add {
    height: 26px; padding: 0 12px;
    border-radius: 999px;
    background: var(--color-accent); color: #fff; border: 0;
    font-size: 11.5px; font-weight: 500; letter-spacing: -0.008em;
    cursor: pointer; font-family: inherit; text-decoration: none;
    display: inline-flex; align-items: center; gap: 4px;
    transition: background 0.15s;
    flex-shrink: 0; margin: 0; align-self: auto;
}
.co-lastchance-body .mc-promo .btn-add:hover { background: var(--color-accent-hover, #0066cc); color: #fff; border-color: transparent; }
.co-lastchance-body .mc-promo .btn-add .arrow { display: inline-flex; align-items: center; }
.co-lastchance-body .mc-promo .btn-add .arrow i { font-style: normal; font-size: 11px; }
.co-lastchance-body .mc-promo .btn-add .arrow i.fa-chevron-right::before { content: "\203A"; font-weight: 600; }
.co-lastchance-body .mc-promo .expander {
    grid-area: expander; align-self: center;
    width: 22px; height: 22px; border-radius: 50%;
    display: inline-flex; align-items: center; justify-content: center;
    color: var(--color-text-tertiary); cursor: pointer;
    transition: all 0.15s; padding: 0; margin: 0;
}
.co-lastchance-body .mc-promo .expander:hover { background: var(--color-surface-secondary); color: var(--color-text-primary); }
.co-lastchance-body .mc-promo .expander i {
    font-style: normal; font-size: 11px; display: inline-block;
    transform: rotate(0deg); transition: transform 0.15s;
}
.co-lastchance-body .mc-promo .expander i.fa-chevron-right::before { content: "\203A"; font-weight: 600; }
.co-lastchance-body .mc-promo.is-open .expander i { transform: rotate(90deg); }
.co-lastchance-body .mc-promo .body {
    grid-area: body;
    margin: 8px 0 0;
    padding: 8px 0 0;
    border-top: 0.5px solid var(--color-border);
    display: none;
}
.co-lastchance-body .mc-promo.is-open .body { display: block; }
.co-lastchance-body .mc-promo .body ul {
    margin: 0; padding: 0; list-style: none;
    display: grid; grid-template-columns: 1fr 1fr; gap: 3px 14px;
}
.co-lastchance-body .mc-promo .body li {
    font-size: 11px; color: var(--color-text-secondary);
    letter-spacing: -0.004em; line-height: 1.4;
    display: flex; align-items: center; gap: 5px;
    margin: 0; padding: 0;
}
.co-lastchance-body .mc-promo .body li i { font-style: normal; flex-shrink: 0; }
.co-lastchance-body .mc-promo .body li i.fa-check {
    width: 10px; height: 10px; color: var(--color-green-text);
    font-size: 9px; font-weight: 700;
    display: inline-flex; align-items: center; justify-content: center;
}
.co-lastchance-body .mc-promo .body li i.fa-check::before { content: "\2713"; }
.co-lastchance-body br + br { display: none; }
.co-lastchance-body p { margin: 0; }
/* Hide WHMCS's inner "Last Chance" heading -- already shown in
   .co-lastchance-head above the grid. */
.co-lastchance-body > div > .sub-heading,
.co-lastchance-body .mc-promo .sub-heading { display: none; }
/* Mobile: stack header into 2 rows so price+btn drop below */
@media (max-width: 640px) {
    .co-lastchance-body .mc-promo {
        grid-template-columns: 32px minmax(0, 1fr) 22px;
        grid-template-areas: "icon content expander" "body body body" "cta cta cta";
    }
    .co-lastchance-body .mc-promo .cta {
        margin-top: 8px; padding-top: 8px;
        border-top: 0.5px solid var(--color-border);
        justify-content: space-between;
    }
}
{/literal}</style>

<div id="order-standard_cart">
    <div class="content-area">

        <header class="co-page-header">
            <div>
                <h1>{$LANG.orderForm.checkout|default:'Your cart'}</h1>
                <p class="co-sub">{$LANG.orderForm.almostDone|default:'Almost there. Enter your details, choose how you\'d like to pay, and complete your order.'}</p>
            </div>
            <a href="{$WEB_ROOT}/cart.php?a=view" class="co-back-cart">
                <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="15 18 9 12 15 6"/></svg>
                {$LANG.orderForm.backToCart|default:'Back to cart'}
            </a>
        </header>

        <div class="co-steps" aria-label="Checkout progress">
            <span class="co-step done"><span class="co-step-num"><svg width="10" height="10" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3.2" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"/></svg></span>{$LANG.orderForm.chooseProduct|default:'Choose plan'}</span>
            <span class="co-step-sep">&rsaquo;</span>
            <span class="co-step done"><span class="co-step-num"><svg width="10" height="10" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3.2" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"/></svg></span>{$LANG.cartdomain|default:'Domain'}</span>
            <span class="co-step-sep">&rsaquo;</span>
            <span class="co-step done"><span class="co-step-num"><svg width="10" height="10" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3.2" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"/></svg></span>{$LANG.cartconfigure|default:'Configure'}</span>
            <span class="co-step-sep">&rsaquo;</span>
            <span class="co-step done"><span class="co-step-num"><svg width="10" height="10" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3.2" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"/></svg></span>Cart</span>
            <span class="co-step-sep">&rsaquo;</span>
            <span class="co-step active"><span class="co-step-num">5</span>{$LANG.checkout|default:'Checkout'}</span>
        </div>

        <div class="co-split">
        <div class="co-left">

            <div class="already-registered clearfix">
                <div class="pull-right float-right">
                    <button type="button" class="btn btn-info{if $loggedin || !$loggedin && $custtype eq "existing"} w-hidden{/if}" id="btnAlreadyRegistered">
                        {$LANG.orderForm.alreadyRegistered}
                    </button>
                    <button type="button" class="btn btn-warning{if $loggedin || $custtype neq "existing"} w-hidden{/if}" id="btnNewUserSignup">
                        {$LANG.orderForm.createAccount}
                    </button>
                </div>

                <p class="text-sm-left overflow-hidden">{lang key='orderForm.enterPersonalDetails'}</p>
            </div>

            <div class="alert alert-danger checkout-error-feedback {if !$errormessage}d-none{/if}" role="alert">
                <p>{$LANG.orderForm.correctErrors}:</p>
                <ul>
                    {if $errormessage}
                        {$errormessage}
                    {/if}
                    <li class="vat-error d-none"></li>
                </ul>
            </div>

            <form method="post" action="{$smarty.server.PHP_SELF}?a=checkout" name="orderfrm" id="frmCheckout">
                <input type="hidden" name="checkout" value="true" />
                <input type="hidden" name="custtype" id="inputCustType" value="{$custtype}" />
                {if $taxIdValidationEnabled}
                    <input type="hidden" id="validation_tax_id" value="true">
                {/if}
                {if $isTaxEUTaxExempt}
                    <input type="hidden" id="isTaxEUTaxExempt" value="true">
                {/if}
                {if $taxType !== ''}
                    <input type="hidden" id="taxType" value="{$taxType}">
                {/if}
                {if $isTaxInclusiveDeduct}
                    <input type="hidden" id="isTaxInclusiveDeduct" value="true">
                {/if}

                {* ─── Account (existing-account picker + existing-login + new signup + extra fields) ─── *}
                {include file="orderforms/$carttpl/includes/checkout/account.tpl"}

                {* ─── Domain registrant contact (when domains in cart) ─── *}
                {include file="orderforms/$carttpl/includes/checkout/domain-registrant.tpl"}

                {* ─── Account security (password + security question, new users) ─── *}
                {include file="orderforms/$carttpl/includes/checkout/security.tpl"}

                {* ─── Last-chance offers (3rd-party hookOutput) ───
                   Wrap whatever the merchant's checkout-hook integrations
                   render in an Apple .co-lastchance card so it doesn't
                   bleed raw markup into the page. *}
                {if $hookOutput}
                    <div class="co-lastchance" style="margin-bottom: 16px;">
                        <div class="co-lastchance-head">
                            <span class="co-lastchance-badge">{$LANG.lastchance|default:'Last chance'}</span>
                            <span class="co-lastchance-title">{$LANG.lastchancetitle|default:'Protect your services and add value'}</span>
                            <span class="co-lastchance-sub">{$LANG.oneclickadd|default:'One-click add. Remove anytime.'}</span>
                        </div>
                        <div class="co-lastchance-body">
                            {foreach $hookOutput as $output}
                                {* Inner <div class="sub-heading"> is hidden
                                   via the `.co-lastchance-body .mc-promo
                                   .sub-heading { display: none }` CSS rule
                                   above. Earlier attempts to strip it with
                                   Smarty's regex_replace broke inline
                                   scripts in $hookOutput on this install. *}
                                <div>{$output}</div>
                            {/foreach}
                        </div>
                    </div>
                {/if}

                {* ─── Captcha ─── *}
                {if $captcha && $captcha->isEnabled() && $captcha->isEnabledForForm($captchaForm)}
                    <div class="co-captcha-card">
                        {if !$captcha->isInvisible()}
                            <div class="sub-heading">
                                <span class="primary-bg-color">{$LANG.captchatitle}</span>
                            </div>
                        {/if}
                        <div class="text-center margin-bottom">
                            {include file="$template/includes/captcha.tpl"}
                        </div>
                    </div>
                {/if}

                {* ─── Payment details (Total Due Today banner, apply-credit, gateway radios, CC fields) ─── *}
                {include file="orderforms/$carttpl/includes/checkout/payment.tpl"}

                {* ─── Order notes (Apple .co-notes card) ───
                   Keeps the textarea name="notes" field so WHMCS still
                   captures order notes server-side. *}
                {if $shownotesfield}
                    <div class="co-notes" style="margin-bottom: 16px;">
                        <label class="co-notes-label" for="orderNotesTextarea">
                            {$LANG.orderForm.additionalNotes}
                            <span class="hint">{$LANG.orderForm.optional|default:'Optional'} &mdash; {$LANG.includedwithyourorder|default:'included with your order'}</span>
                        </label>
                        <textarea id="orderNotesTextarea" name="notes" class="co-notes-area" rows="3" placeholder="{$LANG.ordernotesdescription}">{$orderNotes}</textarea>
                    </div>
                {/if}

                {* ─── Marketing opt-in (Apple .co-mailing card with toggle switch) ───
                   Keeps the checkbox name="marketingoptin" so the WHMCS
                   server still receives the opt-in flag. The toggle UI is
                   pure CSS over the underlying checkbox -- no scripts.js
                   bootstrap-switch widget here, which means we don't need
                   the .toggle-switch-success / no-icheck classes. *}
                {if $showMarketingEmailOptIn}
                    <div class="co-mailing" style="margin-bottom: 16px;">
                        <div class="co-mailing-icon" aria-hidden="true">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"/><polyline points="22 6 12 13 2 6"/></svg>
                        </div>
                        <div class="co-mailing-meta">
                            <h4 class="co-mailing-title">{lang key='emailMarketing.joinOurMailingList'}</h4>
                            <p class="co-mailing-desc">{$marketingEmailOptInMessage}</p>
                        </div>
                        <label class="co-mailing-toggle">
                            <input type="checkbox" name="marketingoptin" value="1"{if $marketingEmailOptIn} checked{/if}>
                            <span class="co-mailing-switch" aria-hidden="true">
                                <span class="co-mailing-handle"></span>
                            </span>
                        </label>
                    </div>
                {/if}

                {* ─── TOS only ───
                   The Complete Order button has been moved into the
                   summary aside (mirrors apple-client-area/checkout.html).
                   This footer keeps only the TOS checkbox so users
                   tick it inline with the form before navigating up
                   to the sticky aside button. *}
                {if $accepttos}
                    <div class="checkout-footer">
                        <label class="checkbox-inline">
                            <input type="checkbox" name="accepttos" id="accepttos" />
                            {$LANG.ordertosagreement}
                            <a href="{$tosurl}" target="_blank">{$LANG.ordertos}</a>
                        </label>
                    </div>
                {/if}
            </form>

            {if $servedOverSsl}
                <div class="alert alert-warning checkout-security-msg">
                    <i class="fas fa-lock"></i>
                    {$LANG.ordersecure} (<strong>{$ipaddress}</strong>) {$LANG.ordersecure2}
                    <div class="clearfix"></div>
                </div>
            {/if}

        </div>{* /.co-left *}

        {* ── RIGHT: sticky order summary (extracted partial) ── *}
        {include file="orderforms/$carttpl/includes/checkout/summary-aside.tpl"}

        </div>{* /.co-split *}
    </div>{* /.content-area *}
</div>

<script type="text/javascript" src="{$BASE_PATH_JS}/jquery.payment.js"></script>
<script>
    var hideCvcOnCheckoutForExistingCard = '{if $canUseCreditOnCheckout && $applyCredit && ($creditBalance->toNumeric() >= $total->toNumeric())}1{else}0{/if}';
</script>
<script type="text/javascript" src="{$BASE_PATH_JS}/CartTotalUpdater.js"></script>
<script>{literal}
/* Already-registered / Create-account toggle hardening.
   scripts.min.js's default handler uses jQuery.show()/hide(), which
   sets inline display but doesn't touch the .w-hidden class. Since
   #containerExistingUserSignin starts with class="w-hidden" applying
   display: none from the global mytheme stylesheet, .show() can't
   reveal it. Add a sibling handler that removes/adds the class on
   the relevant containers and toggles the button visibility so the
   correct one shows in each mode.

   Also watch #existingLoginMessage for content injected by WHMCS's
   login handler -- on bad credentials the message text gets set but
   sometimes the .w-hidden class isn't cleared, which makes the
   failure look silent. The observer ensures any non-empty content
   immediately removes the hidden state. */
(function () {
    function init() {
        var $ = window.jQuery; if (!$) return;
        var login = $('#containerExistingUserSignin');
        var signup = $('#containerNewUserSignup');
        var btnExisting = $('#btnAlreadyRegistered');
        var btnNew = $('#btnNewUserSignup');
        var custType = $('#inputCustType');

        function showLogin() {
            login.removeClass('w-hidden').show();
            signup.addClass('w-hidden').hide();
            btnExisting.addClass('w-hidden');
            btnNew.removeClass('w-hidden');
            if (custType.length) custType.val('existing');
        }
        function showSignup() {
            signup.removeClass('w-hidden').show();
            login.addClass('w-hidden').hide();
            btnNew.addClass('w-hidden');
            btnExisting.removeClass('w-hidden');
            if (custType.length) custType.val('new');
        }
        btnExisting.on('click', showLogin);
        btnNew.on('click', showSignup);

        var msg = document.getElementById('existingLoginMessage');
        if (msg && typeof MutationObserver === 'function') {
            new MutationObserver(function () {
                if (msg.textContent.trim() && msg.classList.contains('w-hidden')) {
                    msg.classList.remove('w-hidden');
                }
            }).observe(msg, { childList: true, subtree: true, characterData: true });
        }

        /* Generate-Password modal wiring.
           standard_cart's default behaviour is "silent prefill" -- it
           sets a random password into both inputs and slides the
           container up so the user never sees what was generated. That
           leaves the user without a copy of their own password. Mirror
           the hostnodes-apple flow instead: clicking .generate-password
           opens a modal that lets the user pick a length, see the
           generated password, copy it, and only then insert it into
           the password fields. */
        var genBtn = document.querySelector('.generate-password');
        var modal = document.getElementById('modalGeneratePassword');
        if (genBtn && modal && window.WHMCS && WHMCS.utils && typeof WHMCS.utils.generatePassword === 'function') {
            /* Replace the default WHMCS handler that hides the password
               container. We bind via $(document).on so this wins over
               whatever PasswordStrength.js / scripts.min.js bound on
               the same selector. */
            $(document).off('click.gpmodal', '.generate-password');
            $(document).on('click.gpmodal', '.generate-password', function (e) {
                e.preventDefault();
                e.stopImmediatePropagation();
                var $modal = $('#modalGeneratePassword');
                $modal.data('targetfields', $(this).data('targetfields') || '');
                $('#inputGeneratePasswordLength').val(12);
                $('#inputGeneratePasswordOutput').val('');
                $('#generatePwLengthError').addClass('w-hidden').hide();
                /* Generate one immediately so the field isn't empty when the modal opens. */
                $('#frmGeneratePassword').trigger('submit');
                $modal.modal('show');
            });
            $('#frmGeneratePassword').on('submit', function (e) {
                e.preventDefault();
                var length = parseInt($('#inputGeneratePasswordLength').val(), 10);
                if (isNaN(length) || length < 8 || length > 64) {
                    $('#generatePwLengthError').removeClass('w-hidden').show();
                    return;
                }
                $('#generatePwLengthError').addClass('w-hidden').hide();
                $('#inputGeneratePasswordOutput').val(WHMCS.utils.generatePassword(length));
            });
            $('#btnGeneratePasswordInsert').on('click', function () {
                var $modal = $(this).closest('.modal');
                var $out = $('#inputGeneratePasswordOutput');
                var pwd = $out.val();
                if (!pwd) return;
                var fields = ($modal.data('targetfields') || '').split(',');
                for (var i = 0; i < fields.length; i++) {
                    var id = fields[i] && fields[i].trim();
                    if (id) $('#' + id).val(pwd).trigger('keyup');
                }
                /* Copy via WHMCS.ui.clipboard if available, else fall back
                   to the Async Clipboard API (modern HTTPS-only contexts). */
                if (window.WHMCS && WHMCS.ui && WHMCS.ui.clipboard && typeof WHMCS.ui.clipboard.copy === 'function') {
                    try { WHMCS.ui.clipboard.copy.call(this); } catch (e) {}
                } else if (navigator.clipboard && navigator.clipboard.writeText) {
                    navigator.clipboard.writeText(pwd);
                }
                $modal.modal('hide');
                $out.val('');
            });
        }

        /* Phone country-code chooser via intl-tel-input.
           Adds a flag + dial-code dropdown next to #inputPhone so the
           user picks a country instead of typing the prefix. On submit
           we replace the input value with the canonical E.164 number
           (+15551234567) so WHMCS receives a normalised phone. The
           library auto-detects the initial country from the address
           country field if present, otherwise falls back to US. */
        var phoneEl = document.getElementById('inputPhone');
        if (phoneEl && typeof window.intlTelInput === 'function') {
            /* Adjust the prepend-icon wrapper -- intl-tel-input injects
               its flag dropdown on the left of the input and our
               .prepend-icon label puts an absolute-positioned phone
               icon there too. Hide the icon when iti owns the slot. */
            var phoneGroup = phoneEl.closest('.form-group.prepend-icon');
            if (phoneGroup) phoneGroup.classList.add('has-iti');

            var iti = window.intlTelInput(phoneEl, {
                separateDialCode: true,
                preferredCountries: ['us', 'gb', 'ca', 'au', 'de', 'fr', 'nl', 'es', 'it'],
                /* Sync initial country to the billing country field once
                   the user picks one -- and pre-seed from $clientsdetails
                   country if WHMCS already provided one. */
                initialCountry: (function () {
                    var c = (document.getElementById('inputCountry') || {}).value;
                    return (c && c.length === 2) ? c.toLowerCase() : 'us';
                })(),
                utilsScript: 'https://cdn.jsdelivr.net/npm/intl-tel-input@18.5.3/build/js/utils.js?onlyCountries=false'
            });

            /* Keep the country in sync if the user changes the billing
               country -- only nudge, don't overwrite a country they
               picked deliberately in the iti dropdown. */
            var lastSyncedCountry = '';
            $('#inputCountry').on('change', function () {
                var c = (this.value || '').toLowerCase();
                if (!c || c.length !== 2) return;
                var current = iti.getSelectedCountryData().iso2;
                /* If they haven't touched the iti dropdown OR the iti
                   country matches the previous billing country, sync. */
                if (current === lastSyncedCountry || lastSyncedCountry === '') {
                    iti.setCountry(c);
                    lastSyncedCountry = c;
                }
            });

            /* On form submit, replace the input value with the
               canonical E.164 number so WHMCS stores a normalised
               phone. Bind in the capture phase so we beat the form's
               submit handlers. */
            var form = document.getElementById('frmCheckout');
            if (form) {
                form.addEventListener('submit', function () {
                    if (typeof iti.isValidNumber === 'function' && iti.isValidNumber()) {
                        phoneEl.value = iti.getNumber();
                    } else if (typeof iti.getNumber === 'function') {
                        var n = iti.getNumber();
                        if (n) phoneEl.value = n;
                    }
                }, true);
            }
        }

        /* Complete Order lives in the right-rail summary aside, bound
           to the form only via the HTML5 form="frmCheckout" attribute.
           DOM-wise it's NOT a descendant of the form, so scripts.min.js's
           re-enable selector
               t.closest("form").find('button[type="submit"]').prop("disabled", !1)
           (called by scrollToGatewayInputError + the Stripe / gateway
           fail handlers) never matches our button. After a failed
           submit, the .disable-on-click handler has added .disabled
           and nothing removes it, so the button stays grayed out and
           the user thinks "Complete Order doesn't work."

           Wrap scrollToGatewayInputError so it also clears our button's
           disabled state -- and as a belt-and-suspenders fallback,
           watch .gateway-errors for slideDown (inline display:block
           appearing) and clear state then too. */
        function reEnableCompleteOrder() {
            var btn = document.getElementById('btnCompleteOrder');
            if (!btn) return;
            btn.disabled = false;
            btn.classList.remove('disabled');
            var spinner = btn.querySelector('i.fas, i.far, i.fal, i.fab');
            if (spinner) {
                spinner.className = '';
                spinner.classList.add('fas', 'fa-arrow-circle-right');
            }
        }
        if (typeof window.scrollToGatewayInputError === 'function') {
            var _origScroll = window.scrollToGatewayInputError;
            window.scrollToGatewayInputError = function () {
                var r = _origScroll.apply(this, arguments);
                reEnableCompleteOrder();
                return r;
            };
        }
        var gwErr = document.querySelector('.gateway-errors');
        if (gwErr && typeof MutationObserver === 'function') {
            new MutationObserver(function () {
                if (gwErr.style.display === 'block' || (gwErr.offsetHeight > 0 && gwErr.textContent.trim())) {
                    reEnableCompleteOrder();
                }
            }).observe(gwErr, { attributes: true, attributeFilter: ['style', 'class'] });
        }
    }
    if (window.jQuery) { window.jQuery(init); }
    else if (document.readyState === 'loading') { document.addEventListener('DOMContentLoaded', init); }
    else { init(); }

    // MarketConnect promo expander: toggle .is-open on the .mc-promo card
    // to reveal/hide its .body (feature list). Bound via delegation so it
    // catches hookOutput markup injected after our init.
    document.addEventListener('click', function (e) {
        var exp = e.target.closest('.co-lastchance-body .mc-promo .expander');
        if (!exp) return;
        e.preventDefault();
        e.stopPropagation();
        var card = exp.closest('.mc-promo');
        if (card) card.classList.toggle('is-open');
    });
})();
{/literal}</script>
{include file="orderforms/standard_cart/recommendations-modal.tpl"}
{include file="orderforms/$carttpl/includes/checkout/generate-password-modal.tpl"}
