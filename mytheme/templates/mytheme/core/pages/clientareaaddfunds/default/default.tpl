{* Hostnodes — Add Funds (Apple-style).

   WHMCS standard variables on /clientarea.php?action=addfunds:
     $minimumamount   — minimum top-up
     $maximumamount   — maximum top-up
     $maximumbalance  — credit balance cap
     $clientcurrency  — currency object: prefix, suffix, code, format
     $paymentmethods  — array of gateway: name (module), displayname
     $errormessage    — array/string of validation errors
     $clientsdetails  — client (use .credit for current balance)
     $token           — CSRF token, required on POST
*}

{assign var=afCurPrefix value=$clientcurrency.prefix|default:'$'}
{assign var=afBalance   value=$clientsdetails.credit|default:'0.00'}

<link rel="stylesheet" href="{$WEB_ROOT}/templates/{$template}/assets/css/pages/clientareaaddfunds.css?v={$myTheme.version|default:'1.0'}">

<script>
(function () { var b = document.body; if (b) { b.setAttribute('data-data', 'full'); b.setAttribute('data-subnav', 'on'); b.setAttribute('data-svc-layout', 'inside'); } })();
</script>

<header class="page-header">
    <h1>{$LANG.addfunds}</h1>
    <p class="page-subtitle">{$hadrianLang.billing.addFundsSubtitle}</p>
</header>

<div class="af-split">
    <div class="af-main">
        <div class="svc-table-card" aria-hidden="true"></div>

        {if isset($errormessage) && $errormessage}
        <div class="af-error">{if is_array($errormessage)}{foreach $errormessage as $err}{$err|strip_tags|escape}{/foreach}{else}{$errormessage|strip_tags|escape}{/if}</div>
        {/if}

        {* Balance + deposit-rules card *}
        <div class="card af-balance-card">
            <div>
                <div class="af-balance-label">{$hadrianLang.billing.creditBalanceLabel}</div>
                <div class="af-balance-value">{$afCurPrefix|escape}{$afBalance|escape}</div>
                <div class="af-balance-sub">{$hadrianLang.billing.creditAppliesNext}</div>
            </div>
            <div class="af-rules">
                {* $minimumamount / $maximumamount / $maximumbalance arrive ALREADY
                   currency-formatted by WHMCS (e.g. "$10.00 USD") - output raw, do
                   NOT prepend $afCurPrefix or you get a double "$$". *}
                {if !empty($minimumamount)}
                <div>
                    <div class="af-rule-label">{$LANG.addfundsminimum}</div>
                    <div class="af-rule-value">{$minimumamount|escape}</div>
                </div>
                {/if}
                {if !empty($maximumamount)}
                <div>
                    <div class="af-rule-label">{$LANG.addfundsmaximum}</div>
                    <div class="af-rule-value">{$maximumamount|escape}</div>
                </div>
                {/if}
                {if !empty($maximumbalance)}
                <div>
                    <div class="af-rule-label">{$LANG.addfundsmaximumbalance}</div>
                    <div class="af-rule-value">{$maximumbalance|escape}</div>
                </div>
                {/if}
            </div>
        </div>

        {* Intro + non-refundable notice *}
        <div class="card af-intro">
            <p>{$LANG.addfundsdescription}</p>
            <div class="af-notice">
                <span class="af-notice-icon"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg></span>
                <span>{$LANG.addfundsnonrefundable}</span>
            </div>
        </div>

        {* Deposit form *}
        <div class="card af-form-card">
            <div class="card-header"><h2>{$hadrianLang.billing.makeDeposit}</h2></div>
            <form method="post" action="{$WEB_ROOT}/clientarea.php?action=addfunds" class="af-form">
                <input type="hidden" name="token" value="{$token|default:''|escape}">

                {if isset($paymentmethods) && $paymentmethods|@count > 0}
                <div class="af-form-row">
                    <label class="af-form-label" for="af-method">{$LANG.orderpaymentmethod}</label>
                    <select id="af-method" name="paymentmethod" class="af-select">
                        {foreach $paymentmethods as $pm}
                        <option value="{$pm.module|default:$pm.name|escape}">{$pm.displayname|default:$pm.name|escape}</option>
                        {/foreach}
                    </select>
                </div>
                {/if}

                <div class="af-form-row">
                    <label class="af-form-label" for="af-amount">{$LANG.addfundsamount}</label>
                    <div class="af-amount">
                        <span class="af-amount-prefix">{$afCurPrefix|escape}</span>
                        <input id="af-amount" name="amount" type="number" step="0.01" min="0"
                               value="{if $amount > 0}{$amount|escape}{else}10.00{/if}"
                               class="af-input" inputmode="decimal" required>
                    </div>
                    <div class="af-presets" role="group" aria-label="{$hadrianLang.billing.presetAmounts}" data-af-presets>
                        <button type="button" class="af-preset active" data-amt="10.00">{$afCurPrefix|escape}10</button>
                        <button type="button" class="af-preset" data-amt="25.00">{$afCurPrefix|escape}25</button>
                        <button type="button" class="af-preset" data-amt="50.00">{$afCurPrefix|escape}50</button>
                        <button type="button" class="af-preset" data-amt="100.00">{$afCurPrefix|escape}100</button>
                    </div>
                </div>

                <div class="af-summary">
                    <div class="af-summary-row">
                        <span class="lbl">{$hadrianLang.billing.currentBalance}</span>
                        <span class="amt">{$afCurPrefix|escape}{$afBalance|escape}</span>
                    </div>
                    <div class="af-summary-row">
                        <span class="lbl">{$hadrianLang.billing.deposit}</span>
                        <span class="amt" data-af-deposit>{$afCurPrefix|escape}10.00</span>
                    </div>
                    <div class="af-summary-row af-summary-total">
                        <span class="lbl">{$hadrianLang.billing.newBalance}</span>
                        <span class="amt" data-af-total>{$afCurPrefix|escape}—</span>
                    </div>
                </div>

                <div class="af-submit">
                    <button type="submit" class="btn-primary">{$LANG.addfunds}</button>
                </div>
            </form>
        </div>
    </div>

    {* Billing sub-nav aside *}
    <aside>
        <div class="card subnav-card">
            <div class="subnav-heading">{$hadrianLang.billing.sidebarHeading}</div>
            <a href="{$WEB_ROOT}/clientarea.php?action=invoices" class="subnav-item">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><rect x="1" y="4" width="22" height="16" rx="2"/><line x1="1" y1="10" x2="23" y2="10"/></svg>
                {$LANG.navinvoices}
            </a>
            <a href="{$WEB_ROOT}/clientarea.php?action=quotes" class="subnav-item">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M14 2H6a2 2 0 00-2 2v16a2 2 0 002 2h12a2 2 0 002-2V8z"/><polyline points="14 2 14 8 20 8"/></svg>
                {$LANG.navquotes}
            </a>
            <a href="{$WEB_ROOT}/clientarea.php?action=masspay&all=true" class="subnav-item">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><rect x="2" y="5" width="20" height="14" rx="2"/><path d="M2 10h20"/><path d="M6 15h4"/></svg>
                {$LANG.masspaytitle}
            </a>
            <a href="{$WEB_ROOT}/clientarea.php?action=addfunds" class="subnav-item active">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="16"/><line x1="8" y1="12" x2="16" y2="12"/></svg>
                {$LANG.addfunds}
            </a>
            <a href="{routePath('account-paymentmethods')}" class="subnav-item">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><rect x="2" y="5" width="20" height="14" rx="2"/><path d="M2 10h20"/></svg>
                {$LANG.paymentMethods.title}
            </a>
        </div>
    </aside>
</div>

<script>
{literal}
document.addEventListener('DOMContentLoaded', function () {
    var amountInput = document.getElementById('af-amount');
    var presetWrap = document.querySelector('[data-af-presets]');
    var depositOut = document.querySelector('[data-af-deposit]');
    var totalOut = document.querySelector('[data-af-total]');
    var balanceEl = document.querySelector('.af-balance-value');
    var balanceText = balanceEl ? balanceEl.textContent : '';
    var currentBalance = parseFloat((balanceText.match(/[\d.]+/) || ['0'])[0]) || 0;
    var prefix = (balanceText.match(/^[^\d]+/) || ['$'])[0];

    function updateSummary() {
        var amt = parseFloat(amountInput.value || '0') || 0;
        if (depositOut) depositOut.textContent = prefix + amt.toFixed(2);
        if (totalOut) totalOut.textContent = prefix + (currentBalance + amt).toFixed(2);
    }

    if (amountInput) amountInput.addEventListener('input', updateSummary);

    if (presetWrap) {
        presetWrap.querySelectorAll('.af-preset').forEach(function (btn) {
            btn.addEventListener('click', function () {
                if (amountInput) amountInput.value = btn.getAttribute('data-amt');
                presetWrap.querySelectorAll('.af-preset').forEach(function (b) { b.classList.toggle('active', b === btn); });
                updateSummary();
            });
        });
    }

    updateSummary();
});
{/literal}
</script>
