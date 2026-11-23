{* One row of WHMCS's "Your Active Products/Services" homepage panel.

   WHMCS core renders this include itself, once per active service, while it
   builds the homepage panels (ClientAreaHomepagePanels) - on every dashboard
   load, whichever dashboard variant then shows the panel. Before this file
   existed WHMCS logged "No template default content for
   'hadrian/includes/active-products-services-item.tpl'" for every service on
   every dashboard view (4,421 times on the local stack) and the panel rows
   came out empty.

   WHMCS data (twenty-one contract):
     $service           WHMCS\Service\Service: ->id, ->domain, ->domainStatus,
                        ->product->name, ->product->productGroup->name
     $statusProperties  status => [translation, modifier]
     $primaryServiceBtn / $secondaryButtons / $accentPrimaryServiceBtns /
     $buttonData        module custom buttons. Their actions run through
                        twenty-one's JS; here the row links to the service
                        page, where the same actions are offered. *}
{assign var=mtSvcStatus value=$service->domainStatus|default:''}
<a class="mt-svc-item" href="{$WEB_ROOT}/clientarea.php?action=productdetails&amp;id={$service->id|escape:'url'}">
    <span class="mt-svc-item-name">
        <strong>{$service->product->productGroup->name|escape} - {$service->product->name|escape}</strong>
        {if $service->domain}<span class="mt-svc-item-domain">{$service->domain|escape}</span>{/if}
    </span>
    <span class="status-pill {$mtSvcStatus|lower|trim|replace:' ':'-'|escape}">{if isset($statusProperties[$mtSvcStatus].translation)}{$statusProperties[$mtSvcStatus].translation|escape}{else}{$mtSvcStatus|escape}{/if}</span>
</a>
