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
{include file="orderforms/$carttpl/common.tpl"}
<script type="text/javascript" src="{$BASE_PATH_JS}/StatesDropdown.js"></script>
<script type="text/javascript" src="{$BASE_PATH_JS}/PasswordStrength.js"></script>
<script type="text/javascript" src="{$BASE_PATH_JS}/VatValidator.js"></script>
<script>
    window.langPasswordStrength = "{$LANG.pwstrength}";
    window.langPasswordWeak = "{$LANG.pwstrengthweak}";
    window.langPasswordModerate = "{$LANG.pwstrengthmoderate}";
    window.langPasswordStrong = "{$LANG.pwstrengthstrong}";
    window.langVatErrorInvalidFormat = "{$LANG.tax.errorVatInvalidFormat}";
</script>

<style>{literal}
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

.co-split { display: grid; grid-template-columns: 1fr 360px; gap: 24px; align-items: start; }
@media (max-width: 960px) { .co-split { grid-template-columns: 1fr; } }
.co-left { min-width: 0; display: flex; flex-direction: column; gap: 16px; }

/* Right summary card */
.co-summary-card { position: sticky; top: 72px; padding: 0; background: var(--color-surface); border: 0.5px solid var(--color-border); border-radius: 14px; }
.co-summary-head { padding: 18px 20px 14px; border-bottom: 0.5px solid var(--color-border); }
.co-summary-head h2 { font-size: 14px; font-weight: 600; color: var(--color-text-primary); letter-spacing: -0.01em; margin: 0; }
.co-summary-list { padding: 8px 20px; }
.co-summary-line { display: flex; justify-content: space-between; align-items: baseline; gap: 10px; padding: 8px 0; font-size: 12.5px; font-variant-numeric: tabular-nums; letter-spacing: -0.004em; }
.co-summary-line .label { color: var(--color-text-secondary); flex: 1; min-width: 0; }
.co-summary-line .value { color: var(--color-text-primary); font-weight: 500; white-space: nowrap; }
.co-summary-line .value.muted { color: var(--color-text-tertiary); font-weight: 400; }
.co-summary-line .value.good { color: var(--color-green-text, #34c759); font-weight: 500; }
.co-summary-line.divider { border-top: 0.5px solid var(--color-border); padding-top: 12px; margin-top: 4px; }
.co-summary-total { display: flex; justify-content: space-between; align-items: center; gap: 10px; padding: 18px 24px; border-top: 0.5px solid var(--color-border); background: var(--color-surface-tertiary); font-variant-numeric: tabular-nums; }
.co-summary-total .label { font-size: 15px; font-weight: 600; color: var(--color-text-primary); letter-spacing: -0.01em; }
.co-summary-total .value { font-size: 24px; font-weight: 600; color: var(--color-text-primary); letter-spacing: -0.025em; white-space: nowrap; }
.co-summary-cycle { font-size: 11px; color: var(--color-text-tertiary); padding: 10px 20px 14px; letter-spacing: -0.004em; margin: 0; }
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
.co-mailing-toggle { position: relative; cursor: pointer; user-select: none; flex-shrink: 0; display: inline-flex; align-items: center; }
.co-mailing-toggle input { position: absolute; opacity: 0; pointer-events: none; width: 0; height: 0; margin: 0; }
.co-mailing-switch { width: 40px; height: 22px; background: var(--color-surface-secondary); border-radius: 999px; position: relative; transition: background 0.15s; border: 0.5px solid var(--color-border); display: block; }
.co-mailing-switch::after { content: ""; position: absolute; top: 1px; left: 1px; width: 18px; height: 18px; border-radius: 50%; background: #fff; box-shadow: 0 1px 3px rgba(0,0,0,0.18); transition: transform 0.15s; }
.co-mailing-toggle input:checked + .co-mailing-switch { background: var(--color-green-text, #34c759); border-color: var(--color-green-text, #34c759); }
.co-mailing-toggle input:checked + .co-mailing-switch::after { transform: translateX(18px); }

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
   The TPL is structured as a long series of (.sub-heading + .row)
   pairs with no per-section wrapper, so we use CSS to draw the card
   chrome around the two known containers (#containerNewUserSignup
   for Personal Info + Billing, #containerNewUserSecurity for
   Password + Security) and around the Payment Details block we
   wrap below. */
#containerNewUserSignup,
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
#containerNewUserSignup > .sub-heading:first-child,
#containerNewUserSecurity > .sub-heading:first-child,
.co-payment-card > .sub-heading:first-child { margin-top: 18px; }

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

/* Already-registered + Create-account buttons -- pill secondary */
.already-registered .btn,
#btnAlreadyRegistered,
#btnNewUserSignup,
.generate-password,
.btn-default,
.btn-info,
.btn-warning {
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

/* Payment method radios -- Apple-style cards */
#paymentGatewaysContainer { margin: 0 0 12px; }
#paymentGatewaysContainer p.small.text-muted { font-size: 12px; color: var(--color-text-tertiary); margin: 0 0 10px; letter-spacing: -0.004em; }
#paymentGatewaysContainer .text-center { display: flex; flex-wrap: wrap; gap: 8px; justify-content: flex-start; }
#paymentGatewaysContainer .radio-inline {
    display: inline-flex; align-items: center; gap: 8px;
    padding: 10px 16px;
    border: 0.5px solid var(--color-border);
    border-radius: 999px;
    background: var(--color-surface);
    font-size: 13px;
    color: var(--color-text-primary);
    cursor: pointer;
    transition: all 0.15s;
    margin: 0;
    letter-spacing: -0.008em;
}
#paymentGatewaysContainer .radio-inline:hover { border-color: var(--color-text-primary); }
#paymentGatewaysContainer .radio-inline:has(input:checked) {
    border-color: var(--color-accent);
    background: var(--color-accent-light);
    color: var(--color-accent);
    font-weight: 500;
}
#paymentGatewaysContainer .radio-inline input { accent-color: var(--color-accent); margin: 0; }

/* Credit-card input fields card */
#creditCardInputFields .form-group { margin-bottom: 12px; }
#creditCardInputFields .control-label { font-size: 12px; color: var(--color-text-tertiary); margin: 0 0 4px; display: block; }

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

/* Validation-error banner */
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

/* Captcha block */
.co-captcha-card { padding: 18px 22px; text-align: center; }

/* ─── Last-chance inner ($hookOutput grid) ──────────────────────
   The hookOutput is opaque marketing HTML from WHMCS hooks (logos
   + bullets + Add to Cart) -- without intervention each item
   stacks vertically full-width. Force a responsive grid with
   bounded image sizes so it reads as a card row rather than a
   billboard wall. */
.co-lastchance-body { padding: 16px 18px 18px; display: grid; grid-template-columns: repeat(auto-fill, minmax(220px, 1fr)); gap: 12px; }
.co-lastchance-body > div + div { margin-top: 0; }
.co-lastchance-body > div {
    padding: 14px;
    border: 0.5px solid var(--color-border);
    border-radius: 12px;
    background: var(--color-surface-tertiary, var(--color-surface));
    display: flex; flex-direction: column;
    font-size: 12.5px;
    line-height: 1.45;
    color: var(--color-text-secondary);
    letter-spacing: -0.004em;
    min-height: 200px;
    overflow: hidden;
}
.co-lastchance-body > div img { max-width: 100%; max-height: 56px; object-fit: contain; align-self: flex-start; margin-bottom: 8px; }
.co-lastchance-body > div ul { margin: 6px 0 8px; padding-left: 18px; font-size: 11.5px; color: var(--color-text-tertiary); }
.co-lastchance-body > div h2,
.co-lastchance-body > div h3,
.co-lastchance-body > div h4,
.co-lastchance-body > div strong { font-size: 13px; font-weight: 600; color: var(--color-text-primary); margin: 0 0 4px; letter-spacing: -0.008em; }
.co-lastchance-body > div .btn,
.co-lastchance-body > div button,
.co-lastchance-body > div a.btn,
.co-lastchance-body > div input[type="submit"],
.co-lastchance-body > div input[type="button"] {
    margin-top: auto;
    align-self: flex-start;
    height: 32px;
    padding: 0 14px;
    border: 0.5px solid var(--color-border);
    border-radius: 999px;
    background: transparent;
    color: var(--color-text-primary);
    font-size: 12px;
    font-weight: 500;
    cursor: pointer;
    text-decoration: none;
    display: inline-flex; align-items: center;
    transition: all 0.15s;
}
.co-lastchance-body > div .btn:hover,
.co-lastchance-body > div button:hover,
.co-lastchance-body > div a.btn:hover {
    border-color: var(--color-accent);
    color: var(--color-accent);
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

                {* ─── Existing account picker (logged-in client) ─── *}
                {if $custtype neq "new" && $loggedin}
                    <div class="sub-heading">
                        <span class="primary-bg-color">
                            {lang key='switchAccount.title'}
                        </span>
                    </div>
                    <div id="containerExistingAccountSelect" class="row account-select-container">
                        {foreach $accounts as $account}
                            <div class="col-sm-{if $accounts->count() == 1}12{else}6{/if}">
                                <div class="account{if $selectedAccountId == $account->id} active{/if}">
                                    <label class="radio-inline" for="account{$account->id}">
                                        <input id="account{$account->id}" class="account-select{if $account->isClosed || $account->noPermission || $inExpressCheckout} disabled{/if}" type="radio" name="account_id" value="{$account->id}"{if $account->isClosed || $account->noPermission || $inExpressCheckout} disabled="disabled"{/if}{if $selectedAccountId == $account->id} checked="checked"{/if}>
                                        <span class="address">
                                            <strong>
                                                {if $account->company}{$account->company}{else}{$account->fullName}{/if}
                                            </strong>
                                            {if $account->isClosed || $account->noPermission}
                                                <span class="label label-default">
                                                    {if $account->isClosed}
                                                        {lang key='closed'}
                                                    {else}
                                                        {lang key='noPermission'}
                                                    {/if}
                                                </span>
                                            {elseif $account->currencyCode}
                                                <span class="label label-info">
                                                    {$account->currencyCode}
                                                </span>
                                            {/if}
                                            <br>
                                            <span class="small">
                                                {$account->address1}{if $account->address2}, {$account->address2}{/if}<br>
                                                {if $account->city}{$account->city},{/if}
                                                {if $account->state} {$account->state},{/if}
                                                {if $account->postcode} {$account->postcode},{/if}
                                                {$account->countryName}
                                            </span>
                                        </span>
                                    </label>
                                </div>
                            </div>
                        {/foreach}
                        <div class="col-sm-12">
                            <div class="account border-bottom{if !$selectedAccountId || !is_numeric($selectedAccountId)} active{/if}">
                                <label class="radio-inline">
                                    <input class="account-select" type="radio" name="account_id" value="new"{if !$selectedAccountId || !is_numeric($selectedAccountId)} checked="checked"{/if}{if $inExpressCheckout} disabled="disabled" class="disabled"{/if}>
                                    {lang key='orderForm.createAccount'}
                                </label>
                            </div>
                        </div>
                    </div>
                {/if}

                {* ─── Existing customer login ─── *}
                <div id="containerExistingUserSignin"{if $loggedin || $custtype neq "existing"} class="w-hidden{/if}">
                    <div class="sub-heading">
                        <span class="primary-bg-color">{$LANG.orderForm.existingCustomerLogin}</span>
                    </div>

                    <div class="alert alert-danger w-hidden" id="existingLoginMessage">
                    </div>

                    <div class="row">
                        <div class="col-sm-6">
                            <div class="form-group prepend-icon">
                                <label for="inputLoginEmail" class="field-icon">
                                    <i class="fas fa-envelope"></i>
                                </label>
                                <input type="text" name="loginemail" id="inputLoginEmail" class="field form-control" placeholder="{$LANG.orderForm.emailAddress}" value="{$loginemail}">
                            </div>
                        </div>
                        <div class="col-sm-6">
                            <div class="form-group prepend-icon">
                                <label for="inputLoginPassword" class="field-icon">
                                    <i class="fas fa-lock"></i>
                                </label>
                                <input type="password" name="loginpassword" id="inputLoginPassword" class="field form-control" placeholder="{$LANG.clientareapassword}">
                            </div>
                        </div>
                    </div>

                    <div class="text-center">
                        <button type="button" id="btnExistingLogin" class="btn btn-primary btn-md">
                            <span id="existingLoginButton">{lang key='login'}</span>
                            <span id="existingLoginPleaseWait" class="w-hidden">{lang key='pleasewait'}</span>
                        </button>
                    </div>

                    {include file="orderforms/standard_cart/linkedaccounts.tpl" linkContext="checkout-existing"}
                </div>

                {* ─── New-user signup (personal info + billing) ─── *}
                <div id="containerNewUserSignup"
                    {if
                        $custtype === 'existing'
                        || (is_numeric($selectedAccountId) && $selectedAccountId > 0)
                        || (
                            $loggedin
                            && $selectedAccountId !== 'new'
                            && $custtype !== 'add'
                        )
                    }
                        class="w-hidden"
                    {/if}
                >

                    <div{if $loggedin} class="w-hidden"{/if}>
                        {include file="orderforms/standard_cart/linkedaccounts.tpl" linkContext="checkout-new"}
                    </div>

                    <div class="sub-heading">
                        <span class="primary-bg-color">{$LANG.orderForm.personalInformation}</span>
                    </div>

                    <div class="row">
                        <div class="col-sm-6">
                            <div class="form-group prepend-icon">
                                <label for="inputFirstName" class="field-icon">
                                    <i class="fas fa-user"></i>
                                </label>
                                <input type="text" name="firstname" id="inputFirstName" class="field form-control" placeholder="{$LANG.orderForm.firstName}" value="{$clientsdetails.firstname}" autofocus>
                            </div>
                        </div>
                        <div class="col-sm-6">
                            <div class="form-group prepend-icon">
                                <label for="inputLastName" class="field-icon">
                                    <i class="fas fa-user"></i>
                                </label>
                                <input type="text" name="lastname" id="inputLastName" class="field form-control" placeholder="{$LANG.orderForm.lastName}" value="{$clientsdetails.lastname}">
                            </div>
                        </div>
                        <div class="col-sm-6">
                            <div class="form-group prepend-icon">
                                <label for="inputEmail" class="field-icon">
                                    <i class="fas fa-envelope"></i>
                                </label>
                                <input type="email" name="email" id="inputEmail" class="field form-control" placeholder="{$LANG.orderForm.emailAddress}" value="{$clientsdetails.email}">
                            </div>
                        </div>
                        <div class="col-sm-6">
                            <div class="form-group prepend-icon">
                                <label for="inputPhone" class="field-icon">
                                    <i class="fas fa-phone"></i>
                                </label>
                                <input type="tel" name="phonenumber" id="inputPhone" class="field form-control" placeholder="{$LANG.orderForm.phoneNumber}" value="{$clientsdetails.phonenumber}">
                            </div>
                        </div>
                    </div>

                    <div class="sub-heading">
                        <span class="primary-bg-color">{$LANG.orderForm.billingAddress}</span>
                    </div>

                    <div class="row">
                        <div class="col-sm-12">
                            <div class="form-group prepend-icon">
                                <label for="inputCompanyName" class="field-icon">
                                    <i class="fas fa-building"></i>
                                </label>
                                <input type="text" name="companyname" id="inputCompanyName" class="field form-control" placeholder="{$LANG.orderForm.companyName} ({$LANG.orderForm.optional})" value="{$clientsdetails.companyname}">
                            </div>
                        </div>
                        <div class="col-sm-12">
                            <div class="form-group prepend-icon">
                                <label for="inputAddress1" class="field-icon">
                                    <i class="far fa-building"></i>
                                </label>
                                <input type="text" name="address1" id="inputAddress1" class="field form-control" placeholder="{$LANG.orderForm.streetAddress}" value="{$clientsdetails.address1}">
                            </div>
                        </div>
                        <div class="col-sm-12">
                            <div class="form-group prepend-icon">
                                <label for="inputAddress2" class="field-icon">
                                    <i class="fas fa-map-marker-alt"></i>
                                </label>
                                <input type="text" name="address2" id="inputAddress2" class="field form-control" placeholder="{$LANG.orderForm.streetAddress2}" value="{$clientsdetails.address2}">
                            </div>
                        </div>
                        <div class="col-sm-4">
                            <div class="form-group prepend-icon">
                                <label for="inputCity" class="field-icon">
                                    <i class="far fa-building"></i>
                                </label>
                                <input type="text" name="city" id="inputCity" class="field form-control" placeholder="{$LANG.orderForm.city}" value="{$clientsdetails.city}">
                            </div>
                        </div>
                        <div class="col-sm-5">
                            <div class="form-group prepend-icon">
                                <label for="state" class="field-icon" id="inputStateIcon">
                                    <i class="fas fa-map-signs"></i>
                                </label>
                                <label for="stateinput" class="field-icon" id="inputStateIcon">
                                    <i class="fas fa-map-signs"></i>
                                </label>
                                <input type="text" name="state" id="inputState" class="field form-control" placeholder="{$LANG.orderForm.state}" value="{$clientsdetails.state}">
                            </div>
                        </div>
                        <div class="col-sm-3">
                            <div class="form-group prepend-icon">
                                <label for="inputPostcode" class="field-icon">
                                    <i class="fas fa-certificate"></i>
                                </label>
                                <input type="text" name="postcode" id="inputPostcode" class="field form-control" placeholder="{$LANG.orderForm.postcode}" value="{$clientsdetails.postcode}">
                            </div>
                        </div>
                        <div class="col-sm-12">
                            <div class="form-group prepend-icon">
                                <label for="inputCountry" class="field-icon" id="inputCountryIcon">
                                    <i class="fas fa-globe"></i>
                                </label>
                                <select name="country" id="inputCountry" class="field form-control">
                                    {foreach $countries as $countrycode => $countrylabel}
                                        <option value="{$countrycode}"{if (!$country && $countrycode == $defaultcountry) || $countrycode eq $country} selected{/if}>
                                            {$countrylabel}
                                        </option>
                                    {/foreach}
                                </select>
                            </div>
                        </div>
                        {if $showTaxIdField}
                            <div class="col-sm-12">
                                <div class="form-group prepend-icon">
                                    <label for="inputTaxId" class="field-icon">
                                        <i class="fas fa-building"></i>
                                    </label>
                                    <input type="text" name="tax_id" id="inputTaxId" class="field form-control" placeholder="{$taxLabel}" value="{$clientsdetails.tax_id}" autocomplete="off">
                                </div>
                            </div>
                        {/if}
                    </div>

                    {if $customfields}
                        <div class="sub-heading">
                            <span class="primary-bg-color">{$LANG.orderadditionalrequiredinfo}<br><i><small>{lang key='orderForm.requiredField'}</small></i></span>
                        </div>
                        <div class="field-container">
                            <div class="row">
                                {foreach $customfields as $customfield}
                                    <div class="col-sm-6">
                                        <div class="form-group">
                                            <label for="customfield{$customfield.id}">{$customfield.name} {$customfield.required}</label>
                                            {$customfield.input}
                                            {if $customfield.description}
                                                <span class="field-help-text">
                                                    {$customfield.description}
                                                </span>
                                            {/if}
                                        </div>
                                    </div>
                                {/foreach}
                            </div>
                        </div>
                    {/if}

                </div>

                {if isset($checkoutExtraFields) && !empty($checkoutExtraFields)}
                    <div class="sub-heading">
                        <span class="primary-bg-color">{lang key='orderForm.additionalInformation'}</span>
                    </div>
                    <div class="row">
                        {foreach $checkoutExtraFields as $field}
                            <div class="col-sm-6">
                                <div class="form-group">
                                    <label for="{$field.name}">
                                        {$field.label|escape}
                                        {if $field.required}<span class="text-danger">*</span>{/if}
                                    </label>
                                    {$field.input}
                                    {if $field.description}
                                        <span class="field-help-text">{$field.description}</span>
                                    {/if}
                                </div>
                            </div>
                        {/foreach}
                    </div>
                {/if}

                {* ─── Domain registrant contact (when domains in cart) ─── *}
                {if $domainsinorder}

                    <div class="sub-heading">
                        <span class="primary-bg-color">{$LANG.domainregistrantinfo}</span>
                    </div>

                    <p class="small text-muted">{$LANG.orderForm.domainAlternativeContact}</p>

                    <div class="row margin-bottom">
                        <div class="col-sm-6 col-sm-offset-3 offset-sm-3">
                            <select name="contact" id="inputDomainContact" class="field form-control">
                                <option value="">{$LANG.usedefaultcontact}</option>
                                {foreach $domaincontacts as $domcontact}
                                    <option value="{$domcontact.id}"{if $contact == $domcontact.id} selected{/if}>
                                        {$domcontact.name}
                                    </option>
                                {/foreach}
                                <option value="addingnew"{if $contact == "addingnew"} selected{/if}>
                                    {$LANG.clientareanavaddcontact}...
                                </option>
                            </select>
                        </div>
                    </div>

                    <div{if $contact neq "addingnew"} class="w-hidden"{/if}>
                        <div class="row" id="domainRegistrantInputFields">
                            <div class="col-sm-6">
                                <div class="form-group prepend-icon">
                                    <label for="inputDCFirstName" class="field-icon">
                                        <i class="fas fa-user"></i>
                                    </label>
                                    <input type="text" name="domaincontactfirstname" id="inputDCFirstName" class="field form-control" placeholder="{$LANG.orderForm.firstName}" value="{$domaincontact.firstname}">
                                </div>
                            </div>
                            <div class="col-sm-6">
                                <div class="form-group prepend-icon">
                                    <label for="inputDCLastName" class="field-icon">
                                        <i class="fas fa-user"></i>
                                    </label>
                                    <input type="text" name="domaincontactlastname" id="inputDCLastName" class="field form-control" placeholder="{$LANG.orderForm.lastName}" value="{$domaincontact.lastname}">
                                </div>
                            </div>
                            <div class="col-sm-6">
                                <div class="form-group prepend-icon">
                                    <label for="inputDCEmail" class="field-icon">
                                        <i class="fas fa-envelope"></i>
                                    </label>
                                    <input type="email" name="domaincontactemail" id="inputDCEmail" class="field form-control" placeholder="{$LANG.orderForm.emailAddress}" value="{$domaincontact.email}">
                                </div>
                            </div>
                            <div class="col-sm-6">
                                <div class="form-group prepend-icon">
                                    <label for="inputDCPhone" class="field-icon">
                                        <i class="fas fa-phone"></i>
                                    </label>
                                    <input type="tel" name="domaincontactphonenumber" id="inputDCPhone" class="field form-control" placeholder="{$LANG.orderForm.phoneNumber}" value="{$domaincontact.phonenumber}">
                                </div>
                            </div>
                            <div class="col-sm-12">
                                <div class="form-group prepend-icon">
                                    <label for="inputDCCompanyName" class="field-icon">
                                        <i class="fas fa-building"></i>
                                    </label>
                                    <input type="text" name="domaincontactcompanyname" id="inputDCCompanyName" class="field form-control" placeholder="{$LANG.orderForm.companyName} ({$LANG.orderForm.optional})" value="{$domaincontact.companyname}">
                                </div>
                            </div>
                            <div class="col-sm-12">
                                <div class="form-group prepend-icon">
                                    <label for="inputDCAddress1" class="field-icon">
                                        <i class="far fa-building"></i>
                                    </label>
                                    <input type="text" name="domaincontactaddress1" id="inputDCAddress1" class="field form-control" placeholder="{$LANG.orderForm.streetAddress}" value="{$domaincontact.address1}">
                                </div>
                            </div>
                            <div class="col-sm-12">
                                <div class="form-group prepend-icon">
                                    <label for="inputDCAddress2" class="field-icon">
                                        <i class="fas fa-map-marker-alt"></i>
                                    </label>
                                    <input type="text" name="domaincontactaddress2" id="inputDCAddress2" class="field form-control" placeholder="{$LANG.orderForm.streetAddress2}" value="{$domaincontact.address2}">
                                </div>
                            </div>
                            <div class="col-sm-4">
                                <div class="form-group prepend-icon">
                                    <label for="inputDCCity" class="field-icon">
                                        <i class="far fa-building"></i>
                                    </label>
                                    <input type="text" name="domaincontactcity" id="inputDCCity" class="field form-control" placeholder="{$LANG.orderForm.city}" value="{$domaincontact.city}">
                                </div>
                            </div>
                            <div class="col-sm-5">
                                <div class="form-group prepend-icon">
                                    <label for="inputDCState" class="field-icon">
                                        <i class="fas fa-map-signs"></i>
                                    </label>
                                    <input type="text" name="domaincontactstate" id="inputDCState" class="field form-control" placeholder="{$LANG.orderForm.state}" value="{$domaincontact.state}">
                                </div>
                            </div>
                            <div class="col-sm-3">
                                <div class="form-group prepend-icon">
                                    <label for="inputDCPostcode" class="field-icon">
                                        <i class="fas fa-certificate"></i>
                                    </label>
                                    <input type="text" name="domaincontactpostcode" id="inputDCPostcode" class="field form-control" placeholder="{$LANG.orderForm.postcode}" value="{$domaincontact.postcode}">
                                </div>
                            </div>
                            <div class="col-sm-12">
                                <div class="form-group prepend-icon">
                                    <label for="inputDCCountry" class="field-icon" id="inputCountryIcon">
                                        <i class="fas fa-globe"></i>
                                    </label>
                                    <select name="domaincontactcountry" id="inputDCCountry" class="field form-control">
                                        {foreach $countries as $countrycode => $countrylabel}
                                            <option value="{$countrycode}"{if (!$domaincontact.country && $countrycode == $defaultcountry) || $countrycode eq $domaincontact.country} selected{/if}>
                                                {$countrylabel}
                                            </option>
                                        {/foreach}
                                    </select>
                                </div>
                            </div>
                            <div class="col-sm-12">
                                <div class="form-group prepend-icon">
                                    <label for="inputDCTaxId" class="field-icon">
                                        <i class="fas fa-building"></i>
                                    </label>
                                    <input type="text" name="domaincontacttax_id" id="inputDCTaxId" class="field form-control" placeholder="{$taxLabel}" value="{$domaincontact.tax_id}" autocomplete="off">
                                </div>
                            </div>
                        </div>
                    </div>

                {/if}

                {* ─── Account-security (password + security question, new users) ─── *}
                {if !$loggedin}

                    <div id="containerNewUserSecurity"{if (!$loggedin && $custtype eq "existing") || ($remote_auth_prelinked && !$securityquestions)} class="w-hidden"{/if}>

                        <div class="sub-heading">
                            <span class="primary-bg-color">{$LANG.orderForm.accountSecurity}</span>
                        </div>

                        <div id="containerPassword" class="row{if $remote_auth_prelinked && $securityquestions} w-hidden{/if}">
                            <div id="passwdFeedback" class="alert alert-info text-center col-sm-12 w-hidden"></div>
                            <div class="col-sm-6">
                                <div class="form-group prepend-icon">
                                    <label for="inputNewPassword1" class="field-icon">
                                        <i class="fas fa-lock"></i>
                                    </label>
                                    <input type="password" name="password" id="inputNewPassword1" data-error-threshold="{$pwStrengthErrorThreshold}" data-warning-threshold="{$pwStrengthWarningThreshold}" class="field form-control" placeholder="{$LANG.clientareapassword}"{if $remote_auth_prelinked} value="{$password}"{/if}>
                                </div>
                            </div>
                            <div class="col-sm-6">
                                <div class="form-group prepend-icon">
                                    <label for="inputNewPassword2" class="field-icon">
                                        <i class="fas fa-lock"></i>
                                    </label>
                                    <input type="password" name="password2" id="inputNewPassword2" class="field form-control" placeholder="{$LANG.clientareaconfirmpassword}"{if $remote_auth_prelinked} value="{$password}"{/if}>
                                </div>
                            </div>
                            <div class="col-sm-6">
                                <button type="button" class="btn btn-default btn-sm generate-password" data-targetfields="inputNewPassword1,inputNewPassword2">
                                    {$LANG.generatePassword.btnLabel}
                                </button>
                            </div>
                            <div class="col-sm-6">
                                <div class="password-strength-meter">
                                    <div class="progress">
                                        <div class="progress-bar progress-bar-success progress-bar-striped" role="progressbar" aria-valuenow="0" aria-valuemin="0" aria-valuemax="100" id="passwordStrengthMeterBar">
                                        </div>
                                    </div>
                                    <p class="text-center small text-muted" id="passwordStrengthTextLabel">{$LANG.pwstrength}: {$LANG.pwstrengthenter}</p>
                                </div>
                            </div>
                        </div>
                        {if $securityquestions}
                            <div class="row">
                                <div class="col-sm-6">
                                    <select name="securityqid" id="inputSecurityQId" class="field form-control">
                                        <option value="">{$LANG.clientareasecurityquestion}</option>
                                        {foreach $securityquestions as $question}
                                            <option value="{$question.id}"{if $question.id eq $securityqid} selected{/if}>
                                                {$question.question}
                                            </option>
                                        {/foreach}
                                    </select>
                                </div>
                                <div class="col-sm-6">
                                    <div class="form-group prepend-icon">
                                        <label for="inputSecurityQAns" class="field-icon">
                                            <i class="fas fa-lock"></i>
                                        </label>
                                        <input type="password" name="securityqans" id="inputSecurityQAns" class="field form-control" placeholder="{$LANG.clientareasecurityanswer}">
                                    </div>
                                </div>
                            </div>
                        {/if}

                    </div>

                {/if}

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

                {* ─── Payment details + total ───
                   Wrapped in .co-payment-card so the section reads as
                   a single Apple card (sub-heading + total banner +
                   apply-credit + gateway radios + CC fields). *}
                <div class="co-payment-card">
                <div class="sub-heading">
                    <span class="primary-bg-color">{$LANG.orderForm.paymentDetails}</span>
                </div>

                <div class="alert alert-success text-center large-text" role="alert" id="totalDueToday">
                    {$LANG.ordertotalduetoday}: &nbsp; <strong id="totalCartPrice">{$total}</strong>
                </div>

                <div id="applyCreditContainer" class="apply-credit-container{if !$canUseCreditOnCheckout} w-hidden{/if}" data-apply-credit="{$applyCredit}">
                    <p>{lang key='cart.availableCreditBalance' amount=$creditBalance}</p>

                    <label class="radio">
                        <input id="useCreditOnCheckout" type="radio" name="applycredit" value="1"{if $applyCredit} checked{/if}>
                        <span id="spanFullCredit"{if !($creditBalance->toNumeric() >= $total->toNumeric())} class="w-hidden"{/if}>
                            {lang key='cart.applyCreditAmountNoFurtherPayment' amount=$total}
                        </span>
                        <span id="spanUseCredit"{if $creditBalance->toNumeric() >= $total->toNumeric()} class="w-hidden"{/if}>
                            {lang key='cart.applyCreditAmount' amount=$creditBalance}
                        </span>
                    </label>
                    <label class="radio">
                        <input id="skipCreditOnCheckout" type="radio" name="applycredit" value="0"{if !$applyCredit} checked{/if}>
                        {lang key='cart.applyCreditSkip' amount=$creditBalance}
                    </label>
                </div>

                {if !$inExpressCheckout}
                    <div id="paymentGatewaysContainer" class="form-group">
                        <p class="small text-muted">{$LANG.orderForm.preferredPaymentMethod}</p>

                        <div class="text-center">
                            {foreach $gateways as $gateway}
                                <label class="radio-inline">
                                    <input type="radio"
                                           name="paymentmethod"
                                           value="{$gateway.sysname}"
                                           data-payment-type="{$gateway.payment_type}"
                                           data-show-local="{$gateway.show_local_cards}"
                                           data-remote-inputs="{$gateway.uses_remote_inputs}"
                                           class="payment-methods{if $gateway.type eq "CC"} is-credit-card{/if}"
                                            {if $selectedgateway eq $gateway.sysname} checked{/if}
                                    />
                                    {$gateway.name}
                                </label>
                            {/foreach}
                        </div>
                    </div>

                    <div class="alert alert-danger text-center gateway-errors w-hidden"></div>

                    <div class="clearfix"></div>

                    <div id="paymentGatewayInput"></div>

                    <div class="cc-input-container{if $selectedgatewaytype neq "CC"} w-hidden{/if}" id="creditCardInputFields">
                        {if $client}
                            <div id="existingCardsContainer" class="existing-cc-grid">
                                {include file="orderforms/standard_cart/includes/existing-paymethods.tpl"}
                            </div>
                        {/if}
                        <div class="row cvv-input" id="existingCardInfo">
                            <div class="col-lg-3 col-sm-4">
                                <div class="form-group prepend-icon">
                                    <label for="inputCardCVV2" class="field-icon">
                                        <i class="fas fa-barcode"></i>
                                    </label>
                                    <div class="input-group">
                                        <input type="tel" name="cccvv" id="inputCardCVV2" class="field form-control" placeholder="{$LANG.creditcardcvvnumbershort}" autocomplete="cc-cvc">
                                        <span class="input-group-btn input-group-append">
                                            <button type="button" class="btn btn-default" data-toggle="popover" data-placement="bottom" data-content="<img src='{$BASE_PATH_IMG}/ccv.gif' width='210' />">
                                                ?
                                            </button>
                                        </span>
                                    </div>
                                    <span class="field-error-msg">{lang key="paymentMethodsManage.cvcNumberNotValid"}</span>
                                </div>
                            </div>
                        </div>

                        <ul>
                            <li>
                                <label class="radio-inline">
                                    <input type="radio" name="ccinfo" value="new" id="new" {if !$client || $client->payMethods->count() === 0} checked="checked"{/if} />
                                    &nbsp;
                                    {lang key='creditcardenternewcard'}
                                </label>
                            </li>
                        </ul>

                        <div class="row" id="newCardInfo">
                            <div id="cardNumberContainer" class="col-sm-6 new-card-container">
                                <div class="form-group prepend-icon">
                                    <label for="inputCardNumber" class="field-icon">
                                        <i class="fas fa-credit-card"></i>
                                    </label>
                                    <input type="tel" name="ccnumber" id="inputCardNumber" class="field form-control cc-number-field" placeholder="{$LANG.orderForm.cardNumber}" autocomplete="cc-number" data-message-unsupported="{lang key='paymentMethodsManage.unsupportedCardType'}" data-message-invalid="{lang key='paymentMethodsManage.cardNumberNotValid'}" data-supported-cards="{$supportedCardTypes}" />
                                    <span class="field-error-msg"></span>
                                </div>
                            </div>
                            <div class="col-sm-3 new-card-container">
                                <div class="form-group prepend-icon">
                                    <label for="inputCardExpiry" class="field-icon">
                                        <i class="fas fa-calendar-alt"></i>
                                    </label>
                                    <input type="tel" name="ccexpirydate" id="inputCardExpiry" class="field form-control" placeholder="MM / YY{if $showccissuestart} ({$LANG.creditcardcardexpires}){/if}" autocomplete="cc-exp">
                                    <span class="field-error-msg">{lang key="paymentMethodsManage.expiryDateNotValid"}</span>
                                </div>
                            </div>
                            <div class="col-sm-3" id="cvv-field-container">
                                <div class="form-group prepend-icon">
                                    <label for="inputCardCVV" class="field-icon">
                                        <i class="fas fa-barcode"></i>
                                    </label>
                                    <div class="input-group">
                                        <input type="tel" name="cccvv" id="inputCardCVV" class="field form-control" placeholder="{$LANG.creditcardcvvnumbershort}" autocomplete="cc-cvc">
                                        <span class="input-group-btn input-group-append">
                                            <button type="button" class="btn btn-default" data-toggle="popover" data-placement="bottom" data-content="<img src='{$BASE_PATH_IMG}/ccv.gif' width='210' />">
                                                ?
                                            </button>
                                        </span><br>
                                    </div>
                                    <span class="field-error-msg">{lang key="paymentMethodsManage.cvcNumberNotValid"}</span>
                                </div>
                            </div>
                            {if $showccissuestart}
                                <div class="col-sm-3 col-sm-offset-6 new-card-container offset-sm-6">
                                    <div class="form-group prepend-icon">
                                        <label for="inputCardStart" class="field-icon">
                                            <i class="far fa-calendar-check"></i>
                                        </label>
                                        <input type="tel" name="ccstartdate" id="inputCardStart" class="field form-control" placeholder="MM / YY ({$LANG.creditcardcardstart})" autocomplete="cc-exp">
                                    </div>
                                </div>
                                <div class="col-sm-3 new-card-container">
                                    <div class="form-group prepend-icon">
                                        <label for="inputCardIssue" class="field-icon">
                                            <i class="fas fa-asterisk"></i>
                                        </label>
                                        <input type="tel" name="ccissuenum" id="inputCardIssue" class="field form-control" placeholder="{$LANG.creditcardcardissuenum}">
                                    </div>
                                </div>
                            {/if}
                        </div>
                        <div id="newCardSaveSettings">
                            <div class="row form-group new-card-container">
                                <div id="inputDescriptionContainer" class="col-md-6">
                                    <div class="prepend-icon">
                                        <label for="inputDescription" class="field-icon">
                                            <i class="fas fa-pencil"></i>
                                        </label>
                                        <input type="text" class="field form-control" id="inputDescription" name="ccdescription" autocomplete="off" value="" placeholder="{$LANG.paymentMethods.descriptionInput} {$LANG.paymentMethodsManage.optional}" />
                                    </div>
                                </div>
                                {if $allowClientsToRemoveCards}
                                    <div id="inputNoStoreContainer" class="col-md-6" style="line-height: 32px;">
                                        <input type="hidden" name="nostore" value="1">
                                        <input type="checkbox" class="toggle-switch-success no-icheck" data-size="mini" checked="checked" name="nostore" id="inputNoStore" value="0" data-on-text="{lang key='yes'}" data-off-text="{lang key='no'}">
                                        <label for="inputNoStore" class="checkbox-inline no-padding">
                                            &nbsp;&nbsp;
                                            {$LANG.creditCardStore}
                                        </label>
                                    </div>
                                {/if}
                            </div>
                        </div>
                    </div>
                {else}
                    {if $expressCheckoutOutput}
                        {$expressCheckoutOutput}
                    {else}
                        <p align="center">
                            {lang key='paymentPreApproved' gateway=$expressCheckoutGateway}
                        </p>
                    {/if}
                {/if}
                </div>{* /.co-payment-card *}

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
                            <span class="co-mailing-switch" aria-hidden="true"></span>
                        </label>
                    </div>
                {/if}

                {* ─── TOS + complete order ─── *}
                <div class="text-center checkout-footer">
                    {if $accepttos}
                        <p>
                            <label class="checkbox-inline">
                                <input type="checkbox" name="accepttos" id="accepttos" />
                                &nbsp;
                                {$LANG.ordertosagreement}
                                <a href="{$tosurl}" target="_blank">{$LANG.ordertos}</a>
                            </label>
                        </p>
                    {/if}

                    <button type="submit"
                            id="btnCompleteOrder"
                            class="btn btn-primary btn-lg disable-on-click spinner-on-click{if $captcha}{$captcha->getButtonClass($captchaForm)}{/if}"
                            {if $cartitems==0}disabled="disabled"{/if}
                    >
                        {if $inExpressCheckout}{$LANG.confirmAndPay}{else}{$LANG.completeorder}{/if}
                        &nbsp;<i class="fas fa-arrow-circle-right"></i>
                    </button>

                    {* ─── Apple trust strip ─── *}
                    <div class="ct-trust ct-trust-checkout">
                        <span class="ct-trust-item">
                            <i class="fas fa-lock"></i> 256-bit SSL · PCI-DSS Level 1
                        </span>
                        <span class="ct-trust-item">
                            <i class="fas fa-check"></i> 30-day money-back guarantee
                        </span>
                    </div>
                </div>
            </form>

            {if $servedOverSsl}
                <div class="alert alert-warning checkout-security-msg">
                    <i class="fas fa-lock"></i>
                    {$LANG.ordersecure} (<strong>{$ipaddress}</strong>) {$LANG.ordersecure2}
                    <div class="clearfix"></div>
                </div>
            {/if}

        </div>{* /.co-left *}

        {* ── RIGHT: sticky order summary ── *}
        <aside>
            <div class="co-summary-card">
                <div class="co-summary-head">
                    <h2>{$LANG.ordersummary|default:'Order summary'}</h2>
                </div>
                <div class="co-summary-list">
                    {foreach $products as $num => $product}
                        <div class="co-summary-line">
                            <span class="label">{$product.productinfo.name}{if $product.billingcyclefriendly} &middot; {$product.billingcyclefriendly}{/if}</span>
                            <span class="value">{$product.pricing.totalTodayExcludingTaxSetup}</span>
                        </div>
                    {/foreach}
                    {foreach $domains as $num => $domain}
                        <div class="co-summary-line">
                            <span class="label">{if $domain.type eq "register"}{$LANG.orderdomainregistration}{else}{$LANG.orderdomaintransfer}{/if} &middot; {$domain.domain}</span>
                            <span class="value">{$domain.price}</span>
                        </div>
                    {/foreach}
                    {foreach $addons as $num => $addon}
                        <div class="co-summary-line">
                            <span class="label">+ {$addon.name}</span>
                            <span class="value">{$addon.totaltoday}</span>
                        </div>
                    {/foreach}

                    <div class="co-summary-line divider">
                        <span class="label">{$LANG.ordersubtotal}</span>
                        <span class="value" id="subtotal">{$subtotal}</span>
                    </div>
                    {if $promotioncode}
                        <div class="co-summary-line">
                            <span class="label">{$promotiondescription}</span>
                            <span class="value good" id="discount">{$discount}</span>
                        </div>
                    {/if}
                    {if $taxrate}
                        <div class="co-summary-line">
                            <span class="label">{$taxname} @ {$taxrate}%</span>
                            <span class="value muted" id="taxTotal1">{$taxtotal}</span>
                        </div>
                    {/if}
                    {if $taxrate2}
                        <div class="co-summary-line">
                            <span class="label">{$taxname2} @ {$taxrate2}%</span>
                            <span class="value muted" id="taxTotal2">{$taxtotal2}</span>
                        </div>
                    {/if}
                </div>

                <div class="co-summary-total">
                    <span class="label">{$LANG.ordertotalduetoday|default:'Total due today'}</span>
                    <span class="value" id="totalDueToday">{$total}</span>
                </div>

                {if $totalrecurring}
                    <p class="co-summary-cycle">{$LANG.orderForm.recurringTotal|default:'Recurring'}: <strong id="totalCartPrice">{$totalrecurring}</strong></p>
                {/if}

                <div class="co-trust-strip">
                    <span class="item"><i class="fas fa-lock"></i> {$LANG.cartsecured|default:'256-bit SSL &middot; PCI-DSS Level 1'}</span>
                    <span class="item"><i class="fas fa-check"></i> {$LANG.cartmoneyback|default:'30-day money-back guarantee'}</span>
                </div>
            </div>
        </aside>

        </div>{* /.co-split *}
    </div>{* /.content-area *}
</div>

<script type="text/javascript" src="{$BASE_PATH_JS}/jquery.payment.js"></script>
<script>
    var hideCvcOnCheckoutForExistingCard = '{if $canUseCreditOnCheckout && $applyCredit && ($creditBalance->toNumeric() >= $total->toNumeric())}1{else}0{/if}';
</script>
<script type="text/javascript" src="{$BASE_PATH_JS}/CartTotalUpdater.js"></script>
{include file="orderforms/standard_cart/recommendations-modal.tpl"}
