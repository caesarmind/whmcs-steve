{* =========================================================================
   account-paymentmethods-billing-contacts.tpl — assign billing contacts.
   ========================================================================= *}
<div class="page-header"><h1 class="page-title">{lang key='paymentMethods.billingContacts'}</h1></div>

<div class="card">
    <div class="card-header"><h3 class="card-title">{lang key='paymentMethods.billingContactsList'}</h3></div>
    <div class="card-body">
        {if $billingContacts && count($billingContacts) > 0}
            <div class="table-container">
                <table class="table table-hover">
                    <thead>
                        <tr>
                            <th>{lang key='name'}</th>
                            <th>{lang key='email'}</th>
                            <th class="text-right">{lang key='actions'}</th>
                        </tr>
                    </thead>
                    <tbody>
                        {foreach $billingContacts as $contact}
                            <tr>
                                <td>{$contact.firstname} {$contact.lastname}</td>
                                <td>{$contact.email}</td>
                                <td class="text-right">
                                    <a href="{routePath('account-contacts-manage', $contact.id)}" class="btn btn-secondary btn-sm">{lang key='edit'}</a>
                                </td>
                            </tr>
                        {/foreach}
                    </tbody>
                </table>
            </div>
        {else}
            {include file="$template/includes/alert.tpl" type="info" msg="{lang key='paymentMethods.noBillingContacts'}" textcenter=true}
        {/if}
    </div>
</div>
