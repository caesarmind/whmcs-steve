{* =========================================================================
   account-paymentmethods.tpl — stored cards and bank accounts.
   ========================================================================= *}
<div class="page-header">
    <h1 class="page-title">{lang key='paymentMethods.title'}</h1>
    <a href="{routePath('account-payment-methods-manage')}" class="btn btn-primary"><i class="fas fa-plus"></i> {lang key='paymentMethods.add'}</a>
</div>

{include file="$template/includes/flashmessage.tpl"}

<div class="card">
    <div class="card-header"><h3 class="card-title">{lang key='paymentMethods.yourSavedMethods'}</h3></div>
    <div class="card-body">
        {if $paymethods && count($paymethods) > 0}
            <div class="table-container">
                <table class="table table-hover">
                    <thead>
                        <tr>
                            <th>{lang key='paymentMethods.description'}</th>
                            <th>{lang key='paymentMethods.type'}</th>
                            <th>{lang key='paymentMethods.default'}</th>
                            <th class="text-right">{lang key='actions'}</th>
                        </tr>
                    </thead>
                    <tbody>
                        {foreach $paymethods as $paymethod}
                            <tr>
                                <td>{$paymethod.description}</td>
                                <td>{$paymethod.type_description}</td>
                                <td>{if $paymethod.default}<span class="status-pill active">{lang key='yes'}</span>{else}<span class="status-pill">{lang key='no'}</span>{/if}</td>
                                <td class="text-right">
                                    <a href="{routePath('account-payment-methods-manage', $paymethod.id)}" class="btn btn-secondary btn-sm"><i class="fas fa-edit"></i> {lang key='edit'}</a>
                                </td>
                            </tr>
                        {/foreach}
                    </tbody>
                </table>
            </div>
        {else}
            {include file="$template/includes/alert.tpl" type="info" msg="{lang key='paymentMethods.noneFound'}" textcenter=true}
        {/if}
    </div>
</div>
