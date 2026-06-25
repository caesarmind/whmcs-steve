{* Hostnodes - View quote (Apple-style). Rendered between header.tpl + footer.tpl
   by the viewquote dispatcher (this WHMCS route bypasses client-area chrome).

   WHMCS variables (cross-checked against Lagom viewquote.tpl):
     $invalidQuoteIdRequested - bool: quote not found / not accessible
     $id        - quote number (display)     $quoteid - quote id (URLs)
     $stage     - 'Delivered'|'Accepted'|'On Hold'|'Lost'|'Dead'
     $datecreated, $validuntil
     $clientsdetails - firstname,lastname,companyname,address1,address2,city,state,postcode,country
     $payto     - issuer address (raw HTML)
     $customfields   - each: fieldname, value
     $proposal  - proposal HTML        $notes - notes HTML
     $quoteitems - each: description, taxed, discountpc, discount, amount
     $subtotal, $taxrate,$taxname,$tax, $taxrate2,$taxname2,$tax2, $total
     $agreetosrequired, $tosurl
   Accept: POST viewquote.php?id={quoteid}&action=accept (agreetos checkbox).
   Demo data under ?preview=1.
*}

{assign var=isPreview value=false}
{if isset($smarty.get.preview) && $smarty.get.preview == '1'}{assign var=isPreview value=true}{/if}

{assign var=qInvalid value=false}
{if isset($invalidQuoteIdRequested) && $invalidQuoteIdRequested}{assign var=qInvalid value=true}{/if}

{assign var=qDemo value=false}
{if $isPreview && (!isset($quoteitems) || $quoteitems|@count == 0)}
    {assign var=qDemo value=true}
    {assign var=qInvalid value=false}
    {assign var=id value='QT-1042'}
    {assign var=quoteid value=1042}
    {assign var=stage value='Delivered'}
    {assign var=datecreated value='Apr 10, 2026'}
    {assign var=validuntil value='Apr 24, 2026'}
    {assign var=total value='$149.00'}
    {assign var=subtotal value='$149.00'}
    {assign var=quoteitems value=[
        ['description'=>'Dedicated IP Address - hendersondesign.com','discountpc'=>0,'discount'=>'','amount'=>'$60.00','taxed'=>false],
        ['description'=>'Premium DNS - hendersondesign.com','discountpc'=>0,'discount'=>'','amount'=>'$36.00','taxed'=>false],
        ['description'=>'Site migration service','discountpc'=>0,'discount'=>'','amount'=>'$53.00','taxed'=>false]
    ]}
    {assign var=clientsdetails value=['firstname'=>'Arshile','lastname'=>'Gogia','companyname'=>'Henderson Design Studio','address1'=>'742 Evergreen Terrace','address2'=>'','city'=>'Springfield','state'=>'IL','postcode'=>'62704','country'=>'United States']}
    {assign var=payto value='<strong>Hostnodes</strong><br>One Apple Park Way<br>Cupertino, CA 95014<br>United States'}
{/if}

{assign var=qStage value=$stage|default:''}
{assign var=qStageClass value='other'}
{if $qStage == 'Delivered'}{assign var=qStageClass value='delivered'}
{elseif $qStage == 'Accepted'}{assign var=qStageClass value='accepted'}
{elseif $qStage == 'On Hold'}{assign var=qStageClass value='onhold'}
{elseif $qStage == 'Lost'}{assign var=qStageClass value='lost'}
{elseif $qStage == 'Dead'}{assign var=qStageClass value='dead'}{/if}

{assign var=canAccept value=false}
{if $qStage == 'Delivered' || $qStage == 'On Hold'}{assign var=canAccept value=true}{/if}

{assign var=qDisplayNum value=$id|default:$quoteid|default:''}
{assign var=qFull value=false}
{if !$qInvalid || $qDemo}{assign var=qFull value=true}{/if}
{if $qFull}{assign var=dashIsEmpty value='full'}{else}{assign var=dashIsEmpty value='empty'}{/if}

<link rel="stylesheet" href="{$WEB_ROOT}/templates/{$template}/assets/css/pages/viewquote.css?v={$hadrian.version|default:'1.0'}">

<script>
(function () {
    var b = document.body;
    if (!b) return;
    b.setAttribute('data-data', '{$dashIsEmpty}');
    b.setAttribute('data-subnav', 'on');
    b.setAttribute('data-svc-layout', 'inside');
})();
</script>

<header class="page-header">
    <div class="page-header-row">
        <div style="flex: 1; min-width: 0;">
            <p class="page-eyebrow">{$LANG.quotenumber}</p>
            <h1>{$LANG.quotenumber}{$qDisplayNum|escape}</h1>
            {if $qFull}
            <p class="page-subtitle">
                {if isset($datecreated)}{$LANG.quotedatecreated} {$datecreated|escape}{/if}
                {if isset($validuntil)} &middot; {$LANG.quotevaliduntil} {$validuntil|escape}{/if}
            </p>
            {/if}
        </div>
        {if $qFull && $qStage}<span class="status-pill {$qStageClass}">{$qStage|escape}</span>{/if}
    </div>
</header>

<div class="vq-split">
    {* ==== MAIN ==== *}
    <div class="vq-main">
        <div class="svc-table-card" aria-hidden="true"></div>

        {* ---- FULL ---- *}
        {if $qFull}
        <div class="when-full" style="display: flex; flex-direction: column; gap: 16px;">

            {if isset($agreetosrequired) && $agreetosrequired}
            <div style="background: var(--color-orange-bg); color: var(--color-orange-text); display:flex; gap:10px; padding:12px 16px; border-radius: var(--radius-md); font-size:13px; margin-bottom:16px;">
                {$LANG.ordererroraccepttos}
            </div>
            {/if}

            {* Summary head *}
            <div class="card">
                <div class="vq-head">
                    <div class="vq-head-block">
                        <div class="label">{$LANG.invoicestotal}</div>
                        <div class="value big">{$total|default:''|escape}</div>
                    </div>
                    <div class="vq-head-block">
                        <div class="label">{$LANG.quotevaliduntil}</div>
                        <div class="value">{$validuntil|default:'-'|escape}</div>
                    </div>
                    <div class="vq-head-block">
                        <div class="label">{$LANG.quotedatecreated}</div>
                        <div class="value">{$datecreated|default:'-'|escape}</div>
                        <div class="sub">{$LANG.quotenumber}{$qDisplayNum|escape}</div>
                    </div>
                </div>
            </div>

            {* Addresses *}
            <div class="card">
                <div class="vq-addr">
                    <div>
                        <div class="vq-addr-label">{$LANG.invoicespayto}</div>
                        <div class="vq-addr-text">{if isset($payto) && $payto}{$payto}{else}{$companyname|default:''|escape}{/if}</div>
                    </div>
                    <div>
                        <div class="vq-addr-label">{$LANG.quoterecipient}</div>
                        <div class="vq-addr-text">
                            {if isset($clientsdetails)}
                                {if $clientsdetails.companyname}<strong>{$clientsdetails.companyname|escape}</strong><br>{/if}
                                {$clientsdetails.firstname|default:''|escape} {$clientsdetails.lastname|default:''|escape}<br>
                                {if $clientsdetails.address1}{$clientsdetails.address1|escape}<br>{/if}
                                {if $clientsdetails.address2}{$clientsdetails.address2|escape}<br>{/if}
                                {$clientsdetails.city|default:''|escape}{if $clientsdetails.state}, {$clientsdetails.state|escape}{/if} {$clientsdetails.postcode|default:''|escape}<br>
                                {$clientsdetails.country|default:''|escape}
                            {/if}
                            {if isset($customfields) && $customfields}
                                <br><br>
                                {foreach $customfields as $customfield}{$customfield.fieldname|escape}: {$customfield.value|escape}<br>{/foreach}
                            {/if}
                        </div>
                    </div>
                </div>
            </div>

            {* Proposal *}
            {if isset($proposal) && $proposal}
            <div class="card">
                <div class="vq-prose">
                    <div class="vq-addr-label">{$LANG.quoteproposal}</div>
                    {$proposal}
                </div>
            </div>
            {/if}

            {* Line items + totals + actions *}
            <div class="card vq-lines-card">
                <div class="card-header"><h2>{$LANG.quotelineitems}</h2></div>
                <table class="vq-lines">
                    <thead>
                        <tr>
                            <th scope="col" style="width: 60%;">{$LANG.invoicesdescription}</th>
                            <th scope="col">{$LANG.quotediscountheading}</th>
                            <th scope="col" style="text-align: right;">{$LANG.invoicesamount}</th>
                        </tr>
                    </thead>
                    <tbody>
                        {if isset($quoteitems)}{foreach $quoteitems as $item}
                        <tr>
                            <td class="desc">{$item.description|escape}{if $item.taxed} *{/if}</td>
                            <td class="disc">{if $item.discountpc > 0}{$item.discount|escape} ({$item.discountpc|escape}%){else}-{/if}</td>
                            <td class="amount">{$item.amount|escape}</td>
                        </tr>
                        {/foreach}{/if}
                    </tbody>
                </table>

                <div class="vq-totals">
                    <div class="vq-total-row muted"><span>{$LANG.invoicessubtotal}</span><span>{$subtotal|default:''|escape}</span></div>
                    {if isset($taxrate) && $taxrate}<div class="vq-total-row muted"><span>{$taxrate|escape}% {$taxname|default:''|escape}</span><span>{$tax|default:''|escape}</span></div>{/if}
                    {if isset($taxrate2) && $taxrate2}<div class="vq-total-row muted"><span>{$taxrate2|escape}% {$taxname2|default:''|escape}</span><span>{$tax2|default:''|escape}</span></div>{/if}
                    <div class="vq-total-row grand"><span>{$LANG.quotelinetotal}</span><span>{$total|default:''|escape}</span></div>
                </div>
                {if isset($taxrate) && $taxrate}<p style="padding: 0 24px 14px; margin: 0; font-size: 12px; color: var(--color-text-tertiary);">* {$LANG.invoicestaxindicator}</p>{/if}

                <div class="vq-actions">
                    {if isset($quoteid)}<a href="{$WEB_ROOT}/dl.php?type=q&amp;id={$quoteid|escape}" class="btn-secondary">{$LANG.invoicesdownload}</a>{/if}
                    <span class="spacer"></span>
                </div>

                {if $canAccept}
                <form method="post" action="{$WEB_ROOT}/viewquote.php?id={$quoteid|default:''|escape}&amp;action=accept">
                    <div class="vq-accept">
                        {if isset($tosurl) && $tosurl}
                        <label class="vq-tos">
                            <input type="checkbox" name="agreetos" value="1"{if isset($agreetosrequired) && $agreetosrequired} required{/if}>
                            <span>{$LANG.ordertosagreement} <a href="{$tosurl|escape}" target="_blank" rel="noopener">{$LANG.ordertos}</a></span>
                        </label>
                        {else}<span class="spacer"></span>{/if}
                        <button type="submit" class="btn-primary">{$LANG.quoteacceptbtn}</button>
                    </div>
                </form>
                {/if}
            </div>

            {* Notes *}
            {if isset($notes) && $notes}
            <div class="card">
                <div class="vq-prose">
                    <div class="vq-addr-label">{$LANG.invoicesnotes}</div>
                    {$notes}
                </div>
            </div>
            {/if}

        </div>
        {/if}

        {* ---- EMPTY ---- *}
        {if !$qFull}
        <div class="when-empty">
            <div class="card vq-empty">
                <div class="vq-empty-ico">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M14 2H6a2 2 0 00-2 2v16a2 2 0 002 2h12a2 2 0 002-2V8z"/><polyline points="14 2 14 8 20 8"/><line x1="9" y1="13" x2="15" y2="13"/><line x1="9" y1="17" x2="15" y2="17"/></svg>
                </div>
                <h2 class="vq-empty-title">{$hadrianLang.billing.quoteUnavailableTitle}</h2>
                <p class="vq-empty-sub">{$hadrianLang.billing.quoteUnavailableSub}</p>
                <a href="{$WEB_ROOT}/clientarea.php?action=quotes" class="btn-secondary">{$hadrianLang.billing.backToQuotes}</a>
            </div>
        </div>
        {/if}
    </div>

    {* ==== ASIDE ==== *}
    <aside class="vq-aside">
        {if $qFull}
        <div class="card vq-aside-card">
            <div class="vq-aside-heading">{$hadrianLang.billing.summary}</div>
            <div class="vq-aside-summary-row">
                <div class="vq-aside-summary-label">{$LANG.invoicesstatus}</div>
                <div class="vq-aside-summary-value">{if $qStage}<span class="status-pill {$qStageClass}">{$qStage|escape}</span>{/if}</div>
            </div>
            <div class="vq-aside-summary-row">
                <div class="vq-aside-summary-label">{$LANG.invoicestotal}</div>
                <div class="vq-aside-summary-value">{$total|default:''|escape}</div>
            </div>
            <div class="vq-aside-summary-row">
                <div class="vq-aside-summary-label">{$LANG.quotevaliduntil}</div>
                <div class="vq-aside-summary-value">{$validuntil|default:'-'|escape}</div>
            </div>
        </div>
        {/if}

        <div class="card subnav-card">
            <div class="subnav-heading">{$hadrianLang.billing.sidebarHeading}</div>
            <a href="{$WEB_ROOT}/clientarea.php?action=invoices" class="subnav-item">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><rect x="1" y="4" width="22" height="16" rx="2"/><line x1="1" y1="10" x2="23" y2="10"/></svg>
                {$LANG.navinvoices}
            </a>
            <a href="{$WEB_ROOT}/clientarea.php?action=quotes" class="subnav-item active">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M14 2H6a2 2 0 00-2 2v16a2 2 0 002 2h12a2 2 0 002-2V8z"/><polyline points="14 2 14 8 20 8"/></svg>
                {$LANG.navquotes|default:'Quotes'}
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
</div>
