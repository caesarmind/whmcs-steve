{*
 * mytheme_cart/signup.tpl — Standalone client registration form.
 *
 * Rendered URL: /cart.php?a=add&signup=1  (or similar — WHMCS routes
 *                 to this template when the cart bootstrap decides
 *                 the user must create an account before continuing).
 *
 * Visual source: apple-client-area/clientregister.html.
 * Layout: page header → single centered card with the registration
 *         form → "already have an account" footer link.
 *
 * Most checkout flows use the inline create-account tabs inside
 * checkout.tpl; signup.tpl is the fallback when WHMCS sends the
 * user here explicitly.
 *
 * Available Smarty variables:
 *   $clientdetails  — pre-filled values if user came from a session
 *   $countries      — { code => name }
 *   $errormessage   — display if WHMCS rejected the previous submit
 *   $WEB_ROOT, $carttpl
 *}

{include file="orderforms/$carttpl/common.tpl"}

<style>{literal}
.su-page-header { margin-bottom: 28px; text-align: center; }
.su-page-header .page-eyebrow { font-size: 11px; font-weight: 600; color: var(--color-text-tertiary); text-transform: uppercase; letter-spacing: 0.06em; margin: 0 0 6px; }
.su-page-header h1 { font-size: 32px; font-weight: 600; letter-spacing: -0.03em; color: var(--color-text-primary); margin: 0 0 6px; }
.su-page-header .page-subtitle { font-size: 14px; color: var(--color-text-secondary); letter-spacing: -0.008em; margin: 0; }

.su-card-wrap { max-width: 560px; margin: 0 auto; }
.su-card { background: var(--color-surface); border: 0.5px solid var(--color-border); border-radius: var(--radius-lg, 14px); padding: 28px 28px 22px; }
.su-card .su-error { background: var(--color-red-bg); color: var(--color-red-text); padding: 10px 14px; border-radius: var(--radius-md); font-size: 13px; margin-bottom: 16px; line-height: 1.5; letter-spacing: -0.004em; }

.su-form { display: flex; flex-direction: column; gap: 14px; }
.su-form-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 14px; }
@media (max-width: 540px) { .su-form-grid { grid-template-columns: 1fr; } }
.su-row { display: flex; flex-direction: column; gap: 6px; }
.su-label { font-size: 12px; font-weight: 500; color: var(--color-text-secondary); letter-spacing: -0.004em; }
.su-label .optional { color: var(--color-text-tertiary); font-weight: 400; margin-left: 4px; }
.su-input, .su-select { height: 40px; padding: 0 14px; border: 0.5px solid var(--color-border); border-radius: var(--radius-md); background: var(--color-surface); font-size: 14px; letter-spacing: -0.008em; color: var(--color-text-primary); font-family: inherit; width: 100%; box-sizing: border-box; transition: all var(--transition-fast); }
.su-input:focus, .su-select:focus { outline: none; border-color: var(--color-accent); box-shadow: 0 0 0 3px var(--color-accent-light); }
.su-select { appearance: none; background-image: url("data:image/svg+xml;utf8,<svg xmlns='http://www.w3.org/2000/svg' width='12' height='12' viewBox='0 0 24 24' fill='none' stroke='%2386868b' stroke-width='2.5' stroke-linecap='round' stroke-linejoin='round'><polyline points='6 9 12 15 18 9'/></svg>"); background-repeat: no-repeat; background-position: right 12px center; padding-right: 36px; cursor: pointer; }
.su-pw-wrap { position: relative; }
.su-pw-wrap input { padding-right: 38px; }
.su-pw-toggle { position: absolute; right: 8px; top: 50%; transform: translateY(-50%); width: 28px; height: 28px; border-radius: 50%; background: transparent; border: 0; color: var(--color-text-tertiary); cursor: pointer; font-family: inherit; display: inline-flex; align-items: center; justify-content: center; }
.su-pw-toggle:hover { color: var(--color-accent); }
.su-pw-toggle svg { width: 14px; height: 14px; }

.su-terms { display: flex; align-items: flex-start; gap: 9px; font-size: 12.5px; color: var(--color-text-secondary); letter-spacing: -0.004em; line-height: 1.5; }
.su-terms input { accent-color: var(--color-accent); margin-top: 2px; flex-shrink: 0; }
.su-terms a { color: var(--color-accent); text-decoration: none; }
.su-terms a:hover { text-decoration: underline; }

.su-submit { width: 100%; height: 46px; padding: 0 22px; border-radius: var(--radius-pill); background: var(--color-accent); color: #fff; border: 0; font-size: 14px; font-weight: 500; letter-spacing: -0.008em; cursor: pointer; font-family: inherit; transition: background var(--transition-fast); }
.su-submit:hover { background: var(--color-accent-hover); }

.su-footer { padding-top: 16px; margin-top: 16px; border-top: 0.5px solid var(--color-border); text-align: center; font-size: 13px; color: var(--color-text-tertiary); }
.su-footer a { color: var(--color-accent); text-decoration: none; font-weight: 500; }
.su-footer a:hover { text-decoration: underline; }
{/literal}</style>

<div class="content-area">
    <header class="su-page-header">
        <p class="page-eyebrow">ACCOUNT</p>
        <h1>Create an account</h1>
        <p class="page-subtitle">Set up your account in a minute — we'll use it to manage your services and send invoices.</p>
    </header>

    <div class="su-card-wrap">
        <div class="su-card">
            {if $errormessage}
                <div class="su-error">{$errormessage}</div>
            {/if}

            <form class="su-form" method="post" action="{$WEB_ROOT}/cart.php?a=checkout">
                <input type="hidden" name="register" value="true">

                <div class="su-form-grid">
                    <div class="su-row">
                        <label class="su-label" for="su-first">First name</label>
                        <input id="su-first" type="text" name="firstname" class="su-input" value="{$clientdetails.firstname|escape}" autocomplete="given-name" required>
                    </div>
                    <div class="su-row">
                        <label class="su-label" for="su-last">Last name</label>
                        <input id="su-last" type="text" name="lastname" class="su-input" value="{$clientdetails.lastname|escape}" autocomplete="family-name" required>
                    </div>
                </div>

                <div class="su-row">
                    <label class="su-label" for="su-email">Email address</label>
                    <input id="su-email" type="email" name="email" class="su-input" value="{$clientdetails.email|escape}" autocomplete="email" required>
                </div>

                <div class="su-row">
                    <label class="su-label" for="su-phone">Phone</label>
                    <input id="su-phone" type="tel" name="phonenumber" class="su-input" value="{$clientdetails.phonenumber|escape}" autocomplete="tel">
                </div>

                <div class="su-row">
                    <label class="su-label" for="su-company">
                        Company
                        <span class="optional">(optional)</span>
                    </label>
                    <input id="su-company" type="text" name="companyname" class="su-input" value="{$clientdetails.companyname|escape}" autocomplete="organization">
                </div>

                <div class="su-row">
                    <label class="su-label" for="su-street">Street address</label>
                    <input id="su-street" type="text" name="address1" class="su-input" value="{$clientdetails.address1|escape}" autocomplete="street-address" required>
                </div>

                <div class="su-form-grid">
                    <div class="su-row">
                        <label class="su-label" for="su-city">City</label>
                        <input id="su-city" type="text" name="city" class="su-input" value="{$clientdetails.city|escape}" autocomplete="address-level2" required>
                    </div>
                    <div class="su-row">
                        <label class="su-label" for="su-state">State / region</label>
                        <input id="su-state" type="text" name="state" class="su-input" value="{$clientdetails.state|escape}" autocomplete="address-level1">
                    </div>
                </div>

                <div class="su-form-grid">
                    <div class="su-row">
                        <label class="su-label" for="su-zip">Postcode</label>
                        <input id="su-zip" type="text" name="postcode" class="su-input" value="{$clientdetails.postcode|escape}" autocomplete="postal-code" required>
                    </div>
                    <div class="su-row">
                        <label class="su-label" for="su-country">Country</label>
                        <select id="su-country" name="country" class="su-select" required>
                            <option value="">Select a country</option>
                            {if $countries}
                                {foreach $countries as $cKey => $cName}
                                    <option value="{$cKey|escape}"{if $cKey == $clientdetails.country} selected{/if}>{$cName|escape}</option>
                                {/foreach}
                            {/if}
                        </select>
                    </div>
                </div>

                <div class="su-form-grid">
                    <div class="su-row">
                        <label class="su-label" for="su-pw">Password</label>
                        <div class="su-pw-wrap">
                            <input id="su-pw" type="password" name="password" class="su-input" placeholder="At least 8 characters" autocomplete="new-password" required>
                            <button type="button" class="su-pw-toggle" data-pw-toggle aria-label="Show password">
                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/></svg>
                            </button>
                        </div>
                    </div>
                    <div class="su-row">
                        <label class="su-label" for="su-pw2">Confirm password</label>
                        <div class="su-pw-wrap">
                            <input id="su-pw2" type="password" name="password2" class="su-input" placeholder="Repeat password" autocomplete="new-password" required>
                            <button type="button" class="su-pw-toggle" data-pw-toggle aria-label="Show password">
                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/></svg>
                            </button>
                        </div>
                    </div>
                </div>

                <label class="su-terms">
                    <input type="checkbox" name="accepttos" value="on" required>
                    <span>
                        I agree to the
                        <a href="{$WEB_ROOT}/terms-of-service" target="_blank">Terms of Service</a>
                        and
                        <a href="{$WEB_ROOT}/privacy-policy" target="_blank">Privacy Policy</a>.
                    </span>
                </label>

                <button type="submit" class="su-submit">Create account &amp; continue</button>
            </form>

            <div class="su-footer">
                Already have an account?
                <a href="{$WEB_ROOT}/clientarea.php">Sign in</a>
            </div>
        </div>
    </div>
</div>

<script>
{literal}
(function () {
    // Password show/hide toggle
    document.querySelectorAll('[data-pw-toggle]').forEach(function (btn) {
        btn.addEventListener('click', function () {
            var input = btn.previousElementSibling;
            if (!input) return;
            input.type = input.type === 'password' ? 'text' : 'password';
        });
    });
})();
{/literal}
</script>
