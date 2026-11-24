{* Sitejet Builder card for a cPanel / Plesk service with Sitejet active.

   Ported from the cPanel and Plesk modules' overview.tpl. Every id, data
   attribute and inline handler below is read by the module's js/client.js
   (preview fallback + load fade-in, ?sitejet_action=publish progress) or by
   the .btn-custom-action handler in scripts.tpl ("Edit Site" opens Sitejet
   through the service's "sitejet" custom action). Keep them verbatim.

   Parameters: panelId = the module's container id (cPanelPackagePanel /
   PleskPackagePanel). *}
{if !empty($isSitejetActive)}
<div class="card" id="{$panelId}">
    <div class="card-header"><h2 class="card-title">{lang key='sitejetBuilder.servicePage.panelTitle'}</h2></div>
    <div class="card-body">
        <div class="hn-mo-split">
            <img class="hn-mo-preview"
                 id="sitejetPublishPreview"
                 alt="Sitejet Preview"
                 data-serviceid="{$serviceId}"
                 data-src="{fqdnRoutePath('clientarea-sitejet-get-preview', $serviceId)}"
                 src="{fqdnRoutePath('clientarea-sitejet-get-preview', $serviceId)}"
                 onerror="fallbackSitejetPreview(event)"
                 onload="sitejetPreviewLoadComplete(event)"
                 data-publish-in-progress="false"
                 style="opacity: 0"
            />
            <div>
                <p class="hn-mo-title">{$product|escape}</p>
                <p class="hn-mo-muted">{$groupname|escape} &middot; {$domain|escape}</p>
                <div class="hn-mo-actions">
                    <a id="sitejetViewLink" href="http://{$domain}" class="btn-secondary" target="_blank" rel="noopener">{lang key='sitejetBuilder.servicePage.visitSite'}</a>
                    {if $domainId}
                        <a href="clientarea.php?action=domaindetails&id={$domainId}" class="btn-secondary" target="_blank" rel="noopener">{lang key='managedomain'}</a>
                    {/if}
                    {if $isSitejetSsoAvailable}
                        <button type="button"
                                id="sitejetEditBtn"
                                class="btn-primary btn-custom-action div-service-item"
                                data-serviceid="{$serviceId}"
                                data-identifier="sitejet"
                                data-active="true"
                                data-ca-target="_self"
                                {if $sitejetPublish}data-do-publish="true"{/if}>
                            {lang key='sitejetBuilder.servicePage.editSite'}
                        </button>
                    {/if}
                </div>
                <div id="sitejetPublishProgressBarWrapper" class="progress" style="margin-top: 14px; display: none;">
                    <div class="progress-bar progress-bar-striped progress-bar-animated" role="progressbar" aria-valuenow="0" aria-valuemin="0" aria-valuemax="100"></div>
                </div>
                <div id="sitejetAlert"
                     class="alert alert-info"
                     role="alert"
                     data-progress-text="{lang key='sitejetBuilder.servicePage.publishProgress'}"
                     data-success-text="{lang key='sitejetBuilder.servicePage.publishSuccess'}"
                     data-error-text="{lang key='clientareaerroroccured'}"
                     style="display: none"></div>
            </div>
        </div>
    </div>
</div>
{/if}
