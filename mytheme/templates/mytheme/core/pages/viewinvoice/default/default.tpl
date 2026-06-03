{* Hostnodes — View Invoice (Apple-style).

   WHMCS exposes invoice variables as TOP-LEVEL (no $invoicedata wrapper,
   $invoiceitems not $lineitems — verified against Nexus):

     $invoiceid, $invoicenum, $status, $datecreated, $datedue, $datepaid
     $total, $subtotal, $credit, $totalcredit
     $tax, $taxrate, $taxname, $tax2, $taxrate2, $taxname2, $notes
     $invoiceitems       — each: description, amount
     $transactions       — array of payment transactions
     $companyname, $payto
     $clientsdetails     — firstname, lastname, address1, etc.
     $paymentmethods     — available gateways
     $token              — CSRF token, required on all POST forms
*}

{if !isset($invoiceid) || !$invoiceid}
    {assign var=dashIsEmpty value='empty'}
{else}
    {assign var=dashIsEmpty value='full'}
{/if}
{assign var=invStatusLower value=$status|default:''|lower}
{if isset($invoicenum) && $invoicenum}{assign var=invDisplayNum value=$invoicenum}{else}{assign var=invDisplayNum value=$invoiceid}{/if}

{* Page-specific stylesheet *}
<link rel="stylesheet" href="{$WEB_ROOT}/templates/{$template}/assets/css/pages/viewinvoice.css?v={$myTheme.version|default:'1.0'}">

<script>
(function () {
    var b = document.body;
    if (!b) return;
    b.setAttribute('data-data', '{$dashIsEmpty}');
    b.setAttribute('data-subnav', 'on');
    b.setAttribute('data-svc-layout', 'inside');
})();
</script>
{* touch 2026-06-02: force WHMCS to recompile this template (recover from a poisoned compiled-template cache) *}

<header class="page-header">
    <div class="page-header-row">
        <div style="flex: 1; min-width: 0;">
            <p class="page-eyebrow">{$LANG.invoicestitle}</p>
            <h1>{$LANG.invoicestitle} #{$invDisplayNum|escape}</h1>
            <p class="page-subtitle">
                {if isset($datecreated)}{$hadrianLang.billing.issuedOn} {$datecreated|escape}{/if}
                {if isset($datedue)} · {$hadrianLang.billing.dueOn} {$datedue|escape}{/if}
            </p>
        </div>
        {if $status}<span class="status-pill {$invStatusLower}">{$status|escape}</span>{/if}
    </div>
</header>

<div class="when-full"><div class="inv-split">

    {* ══ MAIN ══ *}
    <div class="inv-main">

        <div class="svc-table-card" aria-hidden="true"></div>

        {* Invoice summary (Total / Due date / Issued) *}
        <div class="card">
            <div class="inv-head">
                <div class="inv-head-block">
                    <div class="label">{if $invStatusLower == 'paid'}{$LANG.invoicestotal}{else}{$hadrianLang.billing.amountDue}{/if}</div>
                    <div class="value big{if $invStatusLower == 'unpaid' || $invStatusLower == 'overdue'} due{/if}">{if isset($total)}{$total|escape}{/if}</div>
                </div>
                <div class="inv-head-block">
                    <div class="label">{$LANG.invoicesdatedue}</div>
                    <div class="value">{$datedue|default:'-'|escape}</div>
                </div>
                <div class="inv-head-block">
                    <div class="label">{$LANG.invoicesdatecreated}</div>
                    <div class="value">{$datecreated|default:'-'|escape}</div>
                    <div class="sub">#{$invDisplayNum|escape}</div>
                </div>
            </div>
        </div>

        {* Apply account credit - accent-highlighted and placed near the top so the
           credit option is prominent. $manualapplycredit is set by WHMCS only when
           "Clients Choose Credit Use" is enabled and credit is available; posts
           applycredit=true + creditamount, like stock nexus. *}
        {if $manualapplycredit}
        <div class="card inv-lines-card" style="background:var(--color-accent-light);border:1px solid var(--color-accent);">
            <div class="card-header" style="border-bottom-color:var(--color-accent);"><h2 style="color:var(--color-accent);">{$LANG.invoiceaddcreditapply}</h2></div>
            <div class="inv-pay">
                <p style="margin:0 0 14px;font-size:var(--text-base);color:var(--color-text-secondary);letter-spacing:-0.008em;line-height:1.5;">{$LANG.invoiceaddcreditdesc1} <strong style="color:var(--color-text-primary);font-weight:var(--fw-semibold);">{$totalcredit}</strong>. {$LANG.invoiceaddcreditdesc2}.</p>
                <form method="post" action="{$WEB_ROOT}/viewinvoice.php?id={$invoiceid}">
                    <input type="hidden" name="applycredit" value="true">
                    <input type="hidden" name="token" value="{$token|default:''|escape}">
                    <div style="display:flex;gap:10px;align-items:center;">
                        <input type="text" name="creditamount" value="{$creditamount|default:''|escape}" inputmode="decimal" aria-label="{$LANG.invoiceaddcreditamount}" style="flex:1;min-width:0;height:44px;padding:0 14px;font-family:inherit;font-size:var(--text-base);color:var(--color-text-primary);background:var(--color-surface);border:0.5px solid var(--color-border);border-radius:var(--radius-md);letter-spacing:-0.008em;">
                        <button type="submit" class="btn-primary inv-pay-btn" style="width:auto;">{$LANG.invoiceaddcreditapply}</button>
                    </div>
                </form>
            </div>
        </div>
        {/if}

        {* Addresses *}
        <div class="card">
            <div class="inv-addr">
                <div>
                    <div class="inv-addr-label">{$LANG.invoicespayto}</div>
                    <div class="inv-addr-text">
                        <strong>{$companyname|default:''|escape}</strong>
                    </div>
                </div>
                <div>
                    <div class="inv-addr-label">{$LANG.invoicesinvoicedto}</div>
                    <div class="inv-addr-text">
                        {if isset($clientsdetails.firstname)}<strong>{$clientsdetails.firstname|escape} {$clientsdetails.lastname|escape}</strong><br>{/if}
                        {if isset($clientsdetails.companyname) && $clientsdetails.companyname}{$clientsdetails.companyname|escape}<br>{/if}
                        {if isset($clientsdetails.address1)}{$clientsdetails.address1|escape}<br>{/if}
                        {if isset($clientsdetails.address2) && $clientsdetails.address2}{$clientsdetails.address2|escape}<br>{/if}
                        {if isset($clientsdetails.city)}{$clientsdetails.city|escape}, {$clientsdetails.state|escape} {$clientsdetails.postcode|escape}<br>{/if}
                        {if isset($clientsdetails.country)}{$clientsdetails.country|escape}{/if}
                    </div>
                </div>
            </div>
        </div>

        {* Line items *}
        <div class="card inv-lines-card">
            <div class="card-header"><h2>{$LANG.invoicelineitems}</h2></div>
            <table class="inv-lines">
                <thead>
                    <tr>
                        <th scope="col" style="width: 70%;">{$LANG.invoicesdescription}</th>
                        <th scope="col" style="text-align: right;">{$LANG.invoicesamount}</th>
                    </tr>
                </thead>
                <tbody>
                    {if isset($invoiceitems) && $invoiceitems|@count > 0}
                        {foreach $invoiceitems as $item}
                        <tr>
                            <td class="desc">{$item.description|escape}</td>
                            <td class="amount">{$item.amount|escape}</td>
                        </tr>
                        {/foreach}
                    {/if}
                </tbody>
            </table>

            <div class="inv-totals">
                {if isset($subtotal)}
                <div class="inv-total-row muted"><span>{$LANG.invoicessubtotal}</span><span>{$subtotal|escape}</span></div>
                {/if}
                {if isset($taxrate) && $taxrate}
                <div class="inv-total-row muted"><span>{$LANG.invoicestax} ({$taxrate|escape}%)</span><span>{$tax|escape}</span></div>
                {/if}
                {if isset($taxrate2) && $taxrate2}
                <div class="inv-total-row muted"><span>{$LANG.invoicestax} 2 ({$taxrate2|escape}%)</span><span>{$tax2|escape}</span></div>
                {/if}
                {if isset($credit) && $credit}
                <div class="inv-total-row muted"><span>{$LANG.invoicescredit}</span><span>−{$credit|escape}</span></div>
                {/if}
                <div class="inv-total-row grand"><span>{if $invStatusLower == 'paid'}{$LANG.invoicestotal}{else}{$LANG.invoicestotaldue}{/if}</span><span class="amt">{if isset($total)}{$total|escape}{/if}</span></div>
            </div>
        </div>

        {* Ledger - transactions, adjustments and credit/debit notes with the
           closing balance. Mirrors stock nexus: $transactions carries .typeLabel,
           .referenceId/.referenceHref and .isCreditNote/.isDebitNote; $balance is
           the closing balance. Output raw (not |escape) to match nexus and avoid
           double-escaping the prebuilt reference links. *}
        <div class="card inv-lines-card">
            <div class="card-header"><h2>{$LANG.billing.ledger.title}</h2></div>
            <table class="inv-lines">
                <thead>
                    <tr>
                        <th scope="col">{$LANG.billing.ledger.date}</th>
                        <th scope="col">{$LANG.billing.ledger.type}</th>
                        <th scope="col">{$LANG.billing.ledger.reference}</th>
                        <th scope="col" style="text-align: right;">{$LANG.invoicestransamount}</th>
                    </tr>
                </thead>
                <tbody>
                    {foreach $transactions as $tx}
                    <tr>
                        <td class="period">{$tx.date}</td>
                        <td class="period">{if $tx.gateway}{$tx.gateway} &mdash; {/if}{$tx.typeLabel}</td>
                        <td class="period">{if $tx.referenceHref}<a href="{$tx.referenceHref}" target="_blank" rel="noopener">{/if}{if $tx.isCreditNote}{$LANG.billing.creditnote} {elseif $tx.isDebitNote}{$LANG.billing.debitnote} {/if}{$tx.referenceId|truncate:24:"...":false:true}{if $tx.referenceHref}</a>{/if}</td>
                        <td class="amount">{$tx.amount}</td>
                    </tr>
                    {foreachelse}
                    <tr>
                        <td colspan="4" style="text-align:center;color:var(--color-text-tertiary);">{$LANG.invoicestransnonefound}</td>
                    </tr>
                    {/foreach}
                    <tr>
                        <td colspan="3" style="text-align:right;font-weight:var(--fw-semibold);color:var(--color-text-primary);border-top:0.5px solid var(--color-border);">{$LANG.invoicesbalance}</td>
                        <td class="amount" style="font-weight:var(--fw-semibold);border-top:0.5px solid var(--color-border);">{$balance}</td>
                    </tr>
                </tbody>
            </table>
        </div>

        {* Payment *}
        {if $invStatusLower == 'unpaid' || $invStatusLower == 'overdue'}
        <div class="card inv-lines-card">
            <div class="card-header"><h2>{$LANG.invoicemakepayment}</h2></div>
            <form method="post" action="{$WEB_ROOT}/viewinvoice.php?id={$invoiceid}">
                <input type="hidden" name="token" value="{$token|default:''|escape}">
                <input type="hidden" name="paynow" value="true">
                <div class="inv-pay">
                    <div class="inv-pay-method-list">
                        {if isset($paymentmethods) && $paymentmethods|@count > 0}
                            {foreach $paymentmethods as $pm}
                            <label class="inv-pay-method">
                                <input type="radio" name="paymentmethod" value="{$pm.module|default:''|escape}"{if $pm@first} checked{/if}>
                                <span class="inv-pay-method-logo">{$pm.shortname|default:'PAY'|escape|truncate:4:""}</span>
                                <div class="inv-pay-method-meta">
                                    <div class="inv-pay-method-name">{$pm.displayname|default:$pm.module|escape}</div>
                                </div>
                            </label>
                            {/foreach}
                        {/if}
                    </div>
                    <button type="submit" class="btn-primary inv-pay-btn">{$LANG.invoicepay} {if isset($total)}{$total|escape}{/if}</button>
                </div>
            </form>
        </div>
        {/if}
    </div>

    {* ══ RIGHT: Actions sidebar ══ *}
    <aside class="inv-aside">
        <div class="card inv-aside-card">
            <div class="inv-aside-heading">{$hadrianLang.billing.summary}</div>
            <div class="inv-aside-summary-row">
                <div class="inv-aside-summary-label">{$LANG.invoicesstatus}</div>
                <div class="inv-aside-summary-value"><span class="status-pill {$invStatusLower}">{$status|escape}</span></div>
            </div>
            <div class="inv-aside-summary-row">
                <div class="inv-aside-summary-label">{if $invStatusLower == 'paid'}{$LANG.invoicestotal}{else}{$hadrianLang.billing.amountDue}{/if}</div>
                <div class="inv-aside-summary-value{if $invStatusLower == 'unpaid' || $invStatusLower == 'overdue'} due{/if}">{if isset($total)}{$total|escape}{/if}</div>
            </div>
            <div class="inv-aside-summary-row">
                <div class="inv-aside-summary-label">{$LANG.invoicesdatedue}</div>
                <div class="inv-aside-summary-value">{$datedue|default:'-'|escape}</div>
            </div>
        </div>

        <div class="card inv-aside-card">
            <div class="inv-aside-heading">{$LANG.actions}</div>
            <div class="inv-actions-card-inner">
                <a href="{$WEB_ROOT}/dl.php?type=i&id={$invoiceid}" class="inv-action" download>
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M21 15v4a2 2 0 01-2 2H5a2 2 0 01-2-2v-4"/><polyline points="7 10 12 15 17 10"/><line x1="12" y1="15" x2="12" y2="3"/></svg>
                    {$LANG.invoicesdownload}
                </a>
            </div>
        </div>

        {* Billing sub-nav *}
        <div class="card subnav-card">
            <div class="subnav-heading">{$hadrianLang.billing.sidebarHeading}</div>
            <a href="{$WEB_ROOT}/clientarea.php?action=invoices" class="subnav-item active">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><rect x="1" y="4" width="22" height="16" rx="2"/><line x1="1" y1="10" x2="23" y2="10"/></svg>
                {$LANG.navinvoices}
            </a>
            <a href="{$WEB_ROOT}/clientarea.php?action=quotes" class="subnav-item">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M14 2H6a2 2 0 00-2 2v16a2 2 0 002 2h12a2 2 0 002-2V8z"/><polyline points="14 2 14 8 20 8"/><line x1="9" y1="13" x2="15" y2="13"/><line x1="9" y1="17" x2="15" y2="17"/></svg>
                {$LANG.navquotes}
            </a>
            <a href="{$WEB_ROOT}/clientarea.php?action=masspay&all=true" class="subnav-item">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><rect x="2" y="5" width="20" height="14" rx="2"/><path d="M2 10h20"/><path d="M6 15h4"/></svg>
                {$LANG.masspaytitle}
            </a>
            <a href="{$WEB_ROOT}/clientarea.php?action=addfunds" class="subnav-item">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="16"/><line x1="8" y1="12" x2="16" y2="12"/></svg>
                {$LANG.addfunds}
            </a>
            <a href="{routePath('account-paymentmethods')}" class="subnav-item">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><rect x="2" y="5" width="20" height="14" rx="2"/><path d="M2 10h20"/></svg>
                {$LANG.paymentMethods.title}
            </a>
        </div>
    </aside>
</div></div>

<div class="when-empty" style="text-align:center;padding:60px 24px;background:var(--color-surface);border:1px solid var(--color-border);border-radius:14px;">
    <div style="width:56px;height:56px;border-radius:50%;background:var(--color-bg);display:inline-flex;align-items:center;justify-content:center;margin-bottom:16px;color:var(--color-text-tertiary);">
        <svg viewBox="0 0 24 24" width="22" height="22" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round">
            <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/><line x1="16" y1="13" x2="8" y2="13"/><line x1="16" y1="17" x2="8" y2="17"/><polyline points="10 9 9 9 8 9"/>
        </svg>
    </div>
    <p style="font-size:17px;font-weight:600;color:var(--color-text-primary);margin:0 0 6px;">{$hadrianLang.billing.invoiceNotFoundTitle}</p>
    <p style="font-size:14px;color:var(--color-text-secondary);margin:0 0 20px;max-width:380px;margin-left:auto;margin-right:auto;line-height:1.5;">{$hadrianLang.billing.invoiceNotFoundSub}</p>
    <a href="{$WEB_ROOT}/clientarea.php?action=invoices" class="btn-primary">{$LANG.navinvoices}</a>
</div>
