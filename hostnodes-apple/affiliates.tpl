{* =========================================================================
   affiliates.tpl — affiliate dashboard (stats, link, payout).
   ========================================================================= *}
<div class="page-header"><h1 class="page-title">{lang key='affiliatestitle'}</h1></div>

<div class="summary-tiles">
    <div class="tile">
        <div class="tile-icon blue"><i class="fas fa-eye"></i></div>
        <div class="tile-value">{$visitors}</div>
        <div class="tile-label">{lang key='affiliatesvisitors'}</div>
    </div>
    <div class="tile">
        <div class="tile-icon green"><i class="fas fa-users"></i></div>
        <div class="tile-value">{$signups}</div>
        <div class="tile-label">{lang key='affiliatessignups'}</div>
    </div>
    <div class="tile">
        <div class="tile-icon orange"><i class="fas fa-shopping-cart"></i></div>
        <div class="tile-value">{$conversions}</div>
        <div class="tile-label">{lang key='affiliatesconversions'}</div>
    </div>
    <div class="tile">
        <div class="tile-icon purple"><i class="fas fa-dollar-sign"></i></div>
        <div class="tile-value">{$balance}</div>
        <div class="tile-label">{lang key='affiliatesbalance'}</div>
    </div>
</div>

<div class="card">
    <div class="card-header"><h3 class="card-title">{lang key='affiliateslinktous'}</h3></div>
    <div class="card-body">
        <p>{lang key='affiliateslinktousexplanation'}</p>
        <div class="form-group">
            <label class="form-label">{lang key='affiliatesreferallink'}</label>
            <input type="text" value="{$affiliatelink}" class="form-input" readonly onclick="this.select();">
        </div>
    </div>
</div>

{if $referrals}
    <div class="card">
        <div class="card-header"><h3 class="card-title">{lang key='affiliatesreferrallist'}</h3></div>
        <div class="card-body">
            <div class="table-container">
                <table class="table">
                    <thead>
                        <tr>
                            <th>{lang key='date'}</th>
                            <th>{lang key='affiliatesamount'}</th>
                            <th>{lang key='status'}</th>
                        </tr>
                    </thead>
                    <tbody>
                        {foreach $referrals as $ref}
                            <tr>
                                <td>{$ref.date}</td>
                                <td>{$ref.amount}</td>
                                <td><span class="status-pill {$ref.status|strtolower}">{$ref.status}</span></td>
                            </tr>
                        {/foreach}
                    </tbody>
                </table>
            </div>
        </div>
    </div>
{/if}

{if $canWithdraw}
    <form method="post" action="{$smarty.server.PHP_SELF}">
        <input type="hidden" name="action" value="withdraw">
        <button type="submit" class="btn btn-primary btn-lg">{lang key='affiliateswithdraw'}</button>
    </form>
{/if}
