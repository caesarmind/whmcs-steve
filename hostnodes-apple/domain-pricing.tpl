{* =========================================================================
   domain-pricing.tpl — TLD pricing table.
   ========================================================================= *}
<div class="page-header"><h1 class="page-title">{lang key='domainPricing.title'}</h1></div>

<div class="card">
    <div class="card-body">
        <div class="table-container">
            <table class="table">
                <thead>
                    <tr>
                        <th>{lang key='orderdomain'}</th>
                        <th class="text-right">{lang key='register'}</th>
                        <th class="text-right">{lang key='transfer'}</th>
                        <th class="text-right">{lang key='renew'}</th>
                    </tr>
                </thead>
                <tbody>
                    {foreach $pricing as $tld => $data}
                        <tr>
                            <td>{$tld}</td>
                            <td class="text-right">{if is_object($data.register)}{$data.register->toFull()}{else}{lang key='domainregnotavailable'}{/if}</td>
                            <td class="text-right">{if is_object($data.transfer)}{$data.transfer->toFull()}{else}{lang key='domaintransfernotavailable'}{/if}</td>
                            <td class="text-right">{if is_object($data.renew)}{$data.renew->toFull()}{else}{lang key='domainrenewnotavailable'}{/if}</td>
                        </tr>
                    {/foreach}
                </tbody>
            </table>
        </div>
    </div>
</div>
