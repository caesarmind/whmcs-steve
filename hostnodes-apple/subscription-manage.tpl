{* =========================================================================
   subscription-manage.tpl — pause, resume, or cancel a recurring subscription.
   ========================================================================= *}
<div class="page-header"><h1 class="page-title">{lang key='subscription.manage'}</h1></div>

{include file="$template/includes/flashmessage.tpl"}

<div class="card">
    <div class="card-header"><h3 class="card-title">{$subscription.description}</h3></div>
    <div class="card-body">
        <div class="product-meta-grid">
            <div class="product-meta-item"><div class="product-meta-label">{lang key='status'}</div><div class="product-meta-value"><span class="status-pill {$subscription.status|strtolower}">{$subscription.status}</span></div></div>
            <div class="product-meta-item"><div class="product-meta-label">{lang key='recurringamount'}</div><div class="product-meta-value">{$subscription.amount}</div></div>
            <div class="product-meta-item"><div class="product-meta-label">{lang key='billingcycle'}</div><div class="product-meta-value">{$subscription.cycle}</div></div>
            <div class="product-meta-item"><div class="product-meta-label">{lang key='nextPayment'}</div><div class="product-meta-value">{$subscription.nextpayment}</div></div>
        </div>

        <form method="post" action="{$smarty.server.PHP_SELF}" class="mt-3">
            <input type="hidden" name="token" value="{$token}">
            <input type="hidden" name="subid" value="{$subscription.id}">
            <div class="btn-group">
                {if $subscription.status eq 'Active'}
                    <button type="submit" name="action" value="pause" class="btn btn-secondary">{lang key='subscription.pause'}</button>
                {elseif $subscription.status eq 'Paused'}
                    <button type="submit" name="action" value="resume" class="btn btn-primary">{lang key='subscription.resume'}</button>
                {/if}
                <button type="submit" name="action" value="cancel" class="btn btn-danger">{lang key='subscription.cancel'}</button>
            </div>
        </form>
    </div>
</div>
