{* =========================================================================
   includes/sitejet/homepagepanel.tpl — Sitejet Builder promo panel shown on
   the client-area home page when a user has at least one Sitejet-enabled
   service.
   ========================================================================= *}
<div class="sitejet-panel card">
    <div class="card-body">
        <div class="sitejet-preview">
            <img src="{routePath('clientarea-sitejet-get-preview', $sitejetServices[0]->id)}"
                 onerror="this.src = whmcsBaseUrl + '/assets/img/sitejet/preview_placeholder.png';"
                 alt="Sitejet Preview"
                 onload="this.style.opacity = 1"
                 id="sitejetPromoImage"
                 class="sitejet-preview-img"
                 style="opacity:0">
        </div>
        <div class="sitejet-actions">
            <p class="sitejet-label">{lang key='sitejetBuilder.chooseWebsite'}</p>
            <div class="btn-group">
                <select id="sitejetServiceSelect" class="form-input">
                    {foreach $sitejetServices as $service}
                        <option value="{$service->id}">{$service->domain}</option>
                    {/foreach}
                </select>
                <button class="btn btn-primary btn-custom-action div-service-item"
                        id="sitejetSsoButton"
                        data-serviceid="{$sitejetServices[0]->id}"
                        data-identifier="sitejet"
                        data-active="true">
                    {lang key="sitejetBuilder.editWebsite"}
                </button>
            </div>
            <div class="callout danger mt-2" id="sitejetAlert" style="display:none">{lang key="errorButTryAgain"}</div>
        </div>
    </div>
</div>

<script>
    jQuery(document).ready(function() {
        var sitejetPreviewImage = jQuery('#sitejetPromoImage');
        jQuery('#sitejetServiceSelect').on('change', function(e) {
            var serviceId = jQuery(e.target).val();
            if (serviceId) {
                jQuery('#sitejetSsoButton').data('serviceid', serviceId);
                sitejetPreviewImage
                    .attr('src', WHMCS.utils.getRouteUrl('/clientarea/sitejet/service/' + serviceId + '/preview'))
                    .css('opacity', 0.3);
                sitejetPreviewImage.data('is-placeholder', false);
            }
        });
        sitejetPreviewImage.removeAttr('onerror').error(function() {
            if (!sitejetPreviewImage.data('is-placeholder')) {
                sitejetPreviewImage.attr('src', whmcsBaseUrl + '/assets/img/sitejet/preview_placeholder.png');
                sitejetPreviewImage.data('is-placeholder', true);
            }
        });
    });
</script>
