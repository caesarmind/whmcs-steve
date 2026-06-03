{* Hostnodes - Affiliate dashboard (Apple-style).

   Combines the WHMCS standard "six" theme + Lagom data model, rendered in the
   Hostnodes Apple visual language.

   WHMCS standard variables expected:
     $inactive             - affiliate program disabled
     $withdrawrequestsent  - a withdrawal request was just submitted
     $visitors             - referred visitors / clicks
     $signups              - referred signups
     $conversionrate       - conversion percentage (number)
     $referrallink         - the affiliate referral URL
     $pendingcommissions   - pending commission (formatted)
     $balance              - available/withdrawable commission (formatted)
     $withdrawn            - total withdrawn (formatted)
     $withdrawlevel        - bool: balance meets the payout minimum
     $affiliatePayoutMinimum - formatted minimum payout
     $referrals[]          - each: date, datets, service, amountdesc, commission, status, rawstatus
     $affiliatelinkscode   - banner / link-to-us HTML
*}

{* ---- Resolve real-data presence ---- *}
{assign var=hasReferrals value=false}
{if isset($referrals) && $referrals|@count > 0}{assign var=hasReferrals value=true}{/if}

{assign var=isPreview value=false}
{if isset($smarty.get.preview) && $smarty.get.preview == '1'}{assign var=isPreview value=true}{/if}

{* Stat values (WHMCS-native, with safe fallbacks) *}
{assign var=affVisitors value=$visitors|default:0}
{assign var=affSignups value=$signups|default:0}
{assign var=affConv value=$conversionrate|default:0}
{assign var=affBalance value=$balance|default:'0.00'}
{assign var=affPending value=$pendingcommissions|default:'0.00'}
{assign var=affWithdrawn value=$withdrawn|default:'0.00'}
{assign var=affLink value=$referrallink|default:''}
{assign var=affMin value=$affiliatePayoutMinimum|default:''}
{assign var=affCanWithdraw value=$withdrawlevel|default:false}

{* ---- Preview demo fallback: only when there is no live data AND ?preview=1 ---- *}
{assign var=affDemo value=false}
{if !$hasReferrals && $isPreview}
    {assign var=affDemo value=true}
    {assign var=affVisitors value=1240}
    {assign var=affSignups value=38}
    {assign var=affConv value='3.1'}
    {assign var=affBalance value='$214.50'}
    {assign var=affPending value='$48.00'}
    {assign var=affWithdrawn value='$560.00'}
    {assign var=affLink value='https://hostnodes.com/?aff=1042'}
    {assign var=affMin value='$50.00'}
    {assign var=affCanWithdraw value=true}
    {assign var=referrals value=[
        ['date' => 'May 18, 2026', 'service' => 'Cloud VPS - Standard 4GB', 'amountdesc' => '$24.00', 'commission' => '$2.40', 'status' => 'Confirmed', 'rawstatus' => 'Confirmed'],
        ['date' => 'May 14, 2026', 'service' => 'Managed WordPress - Pro', 'amountdesc' => '$59.00', 'commission' => '$5.90', 'status' => 'Confirmed', 'rawstatus' => 'Confirmed'],
        ['date' => 'May 11, 2026', 'service' => 'Dedicated Server - E-2388G', 'amountdesc' => '$189.00', 'commission' => '$18.90', 'status' => 'Pending', 'rawstatus' => 'Pending'],
        ['date' => 'May 03, 2026', 'service' => 'Cloud VPS - Standard 2GB', 'amountdesc' => '$12.00', 'commission' => '$1.20', 'status' => 'Cancelled', 'rawstatus' => 'Cancelled']
    ]}
    {assign var=hasReferrals value=true}
{/if}

{if $hasReferrals}{assign var=dashIsEmpty value='full'}{else}{assign var=dashIsEmpty value='empty'}{/if}

{* Page-specific stylesheet *}
<link rel="stylesheet" href="{$WEB_ROOT}/templates/{$template}/assets/css/pages/affiliates.css?v={$myTheme.version|default:'1.0'}">

<script>
(function () {
    var b = document.body;
    if (!b) return;
    b.setAttribute('data-data', '{$dashIsEmpty}');
})();
</script>

<header class="page-header">
    <h1>{$LANG.affiliatestitle|default:'Affiliates'}</h1>
    <p class="page-subtitle">{$hadrianLang.account.affiliatesSub}</p>
</header>

{if $inactive}
    <div class="card">
        <div class="aff-disabled">
            <div class="aff-disabled-ico">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
            </div>
            <p class="aff-disabled-title">{$LANG.affiliatesdisabled}</p>
            <p class="aff-disabled-sub">{$hadrianLang.account.affiliatesDisabledSub}</p>
        </div>
    </div>
{else}

    {* Sentinel so the state-chip "Controls inside / outside" option appears in preview
       (apple-layout.js reveals the Services pill-group when this element is present). *}
    <div class="svc-table-card" aria-hidden="true"></div>

    {if $withdrawrequestsent}
    <div class="aff-flash">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"><path d="M22 11.08V12a10 10 0 11-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg>
        <span>{$LANG.affiliateswithdrawalrequestsuccessful}</span>
    </div>
    {/if}

    {* ---- Summary tiles ---- *}
    <div class="summary-tiles aff-tiles">
        <div class="tile">
            <div class="tile-icon blue">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/></svg>
            </div>
            <div class="tile-value">{$affVisitors}</div>
            <div class="tile-label">{$LANG.affiliatesclicks}</div>
        </div>
        <div class="tile">
            <div class="tile-icon green">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M17 21v-2a4 4 0 00-4-4H5a4 4 0 00-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 00-3-3.87"/><path d="M16 3.13a4 4 0 010 7.75"/></svg>
            </div>
            <div class="tile-value">{$affSignups}</div>
            <div class="tile-label">{$LANG.affiliatessignups}</div>
        </div>
        <div class="tile">
            <div class="tile-icon orange">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><polyline points="23 6 13.5 15.5 8.5 10.5 1 18"/><polyline points="17 6 23 6 23 12"/></svg>
            </div>
            <div class="tile-value">{$affConv}%</div>
            <div class="tile-label">{$LANG.affiliatesconversionrate}</div>
        </div>
        <div class="tile">
            <div class="tile-icon violet">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><line x1="12" y1="1" x2="12" y2="23"/><path d="M17 5H9.5a3.5 3.5 0 000 7h5a3.5 3.5 0 010 7H6"/></svg>
            </div>
            <div class="tile-value">{$affBalance}</div>
            <div class="tile-label">{$LANG.affiliatesbalance|default:'Available balance'}</div>
        </div>
    </div>

    {* ---- Referral link ---- *}
    <div class="card aff-card">
        <div class="aff-card-head">
            <h2 class="aff-card-title">{$LANG.affiliatesreferallink}</h2>
            <p class="aff-card-desc">{$LANG.affiliateslinktousexplanation|default:'Share this link anywhere. When someone signs up through it, the referral is credited to you.'}</p>
        </div>
        <div class="aff-link-row">
            <input type="text" id="affRefLink" class="aff-link-input" readonly value="{$affLink|escape}" onclick="this.select();">
            <button type="button" class="btn-primary aff-copy-btn" onclick="affCopyLink(this)">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="9" y="9" width="13" height="13" rx="2" ry="2"/><path d="M5 15H4a2 2 0 01-2-2V4a2 2 0 012-2h9a2 2 0 012 2v1"/></svg>
                <span class="aff-copy-label">{$LANG.copy}</span>
            </button>
        </div>
    </div>

    {* ---- Commissions / payout ---- *}
    <div class="card aff-card">
        <div class="aff-card-head">
            <h2 class="aff-card-title">{$LANG.affiliatescommissions|default:'Commissions'}</h2>
        </div>
        <div class="aff-payout">
            <div class="aff-figures">
                <div class="aff-figure">
                    <span class="aff-figure-label">{$LANG.affiliatescommissionspending}</span>
                    <span class="aff-figure-value">{$affPending}</span>
                </div>
                <div class="aff-figure">
                    <span class="aff-figure-label">{$LANG.affiliatescommissionsavailable}</span>
                    <span class="aff-figure-value accent">{$affBalance}</span>
                </div>
                <div class="aff-figure">
                    <span class="aff-figure-label">{$LANG.affiliateswithdrawn}</span>
                    <span class="aff-figure-value">{$affWithdrawn}</span>
                </div>
            </div>
            {if !$withdrawrequestsent}
            <div class="aff-payout-footer">
                {if !$affCanWithdraw && $affMin}
                <p class="aff-min-hint">{lang key="affiliateWithdrawalSummary" amountForWithdrawal=$affMin}</p>
                {/if}
                <form method="post" action="{$WEB_ROOT}/affiliates.php">
                    <input type="hidden" name="action" value="withdrawrequest">
                    <button type="submit" class="btn-primary aff-withdraw-btn"{if !$affCanWithdraw} disabled{/if}>
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="2" y="5" width="20" height="14" rx="2"/><line x1="2" y1="10" x2="22" y2="10"/></svg>
                        {$LANG.affiliatesrequestwithdrawal}
                    </button>
                </form>
            </div>
            {/if}
        </div>
    </div>

    {* ---- Referrals ---- *}
    <section class="aff-section">
        <h2 class="aff-section-title">{$LANG.affiliatesreferals}</h2>

        {* Empty state *}
        <div class="card when-empty">
            <div class="aff-empty">
                <div class="aff-empty-ico">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M17 21v-2a4 4 0 00-4-4H5a4 4 0 00-4 4v2"/><circle cx="9" cy="7" r="4"/><line x1="19" y1="8" x2="19" y2="14"/><line x1="22" y1="11" x2="16" y2="11"/></svg>
                </div>
                <p class="aff-empty-title">{$hadrianLang.account.affiliatesNoReferrals}</p>
                <p class="aff-empty-sub">{$hadrianLang.account.affiliatesNoReferralsSub}</p>
            </div>
        </div>

        {if $hasReferrals}
        <div class="card aff-table-card when-full">
            <table class="aff-table">
                <thead>
                    <tr>
                        <th>{$LANG.affiliatessignupdate}</th>
                        <th>{$LANG.orderproduct}</th>
                        <th class="aff-num">{$LANG.affiliatesamount}</th>
                        <th class="aff-num">{$LANG.affiliatescommission}</th>
                        <th class="aff-status-col">{$LANG.affiliatesstatus}</th>
                    </tr>
                </thead>
                <tbody>
                    {foreach $referrals as $ref}
                        {assign var=rst value=$ref.rawstatus|default:$ref.status|lower}
                        {if $rst == 'pending'}{assign var=rcls value='pending'}
                        {elseif $rst == 'cancelled' || $rst == 'fraud' || $rst == 'reversed'}{assign var=rcls value='cancelled'}
                        {else}{assign var=rcls value='active'}{/if}
                        <tr>
                            <td class="aff-date">{$ref.date|escape}</td>
                            <td>{$ref.service|escape}</td>
                            <td class="aff-num">{$ref.amountdesc|default:$ref.amount|escape}</td>
                            <td class="aff-num aff-commission">{$ref.commission|escape}</td>
                            <td class="aff-status-col"><span class="status-pill {$rcls}">{$ref.status|escape}</span></td>
                        </tr>
                    {/foreach}
                </tbody>
            </table>
        </div>
        {/if}
    </section>

    {* ---- Link-to-us banner code ---- *}
    {if $affiliatelinkscode}
    <div class="card aff-card">
        <div class="aff-card-head">
            <h2 class="aff-card-title">{$LANG.affiliateslinktous}</h2>
            <p class="aff-card-desc">{$LANG.affiliateslinktoussub|default:'Paste one of these snippets on your site to link back with your referral code embedded.'}</p>
        </div>
        <div class="aff-banner-code">{$affiliatelinkscode}</div>
    </div>
    {/if}

{/if}

<script>var _localLang = {'copied': '{$hadrianLang.common.copied|escape:"javascript"}'};</script>
<script>
{literal}
function affCopyLink(btn) {
    var input = document.getElementById('affRefLink');
    if (!input) return;
    var label = btn.querySelector('.aff-copy-label');
    var done = function () {
        btn.classList.add('copied');
        if (label) { var t = label.textContent; label.textContent = _localLang.copied; setTimeout(function () { label.textContent = t; btn.classList.remove('copied'); }, 1600); }
    };
    try {
        if (navigator.clipboard && navigator.clipboard.writeText) {
            navigator.clipboard.writeText(input.value).then(done, function () { input.select(); document.execCommand('copy'); done(); });
        } else {
            input.select(); document.execCommand('copy'); done();
        }
    } catch (e) {
        input.select();
        try { document.execCommand('copy'); done(); } catch (e2) {}
    }
}
{/literal}
</script>
