{* =========================================================================
   User validation banner — shown when further identity validation is needed.
   Opens a modal containing an iframe to the validator service.
   ========================================================================= *}
{if $showUserValidationBanner}
    <div class="verification-banner callout info user-validation">
        <div class="verification-banner-inner">
            <span class="verification-banner-text">
                <i class="fal fa-passport"></i>
                {lang key='fraud.furtherValShort'}
            </span>
            <a href="#" class="btn btn-sm btn-secondary btn-action" data-url="{$userValidationUrl}" onclick="openValidationSubmitModal(this); return false;">
                {lang key='fraud.submitDocs'}
            </a>
            <button id="btnUserValidationClose" type="button" class="verification-banner-close"
                    data-uri="{routePath('dismiss-user-validation')}"
                    aria-label="{lang key='close'}">&times;</button>
        </div>
    </div>

    <div id="validationSubmitModal" class="modal fade apple-modal" role="dialog">
        <div class="modal-backdrop"></div>
        <div class="modal-dialog modal-lg">
            <div class="modal-content card">
                <div class="modal-body card-body">
                    <iframe id="validationContent" allow="camera {$userValidationHost}" width="100%" height="700" frameborder="0" src=""></iframe>
                </div>
                <div class="modal-footer card-footer">
                    <button type="button" class="btn btn-secondary" data-dismiss="modal">{lang key='close'}</button>
                </div>
            </div>
        </div>
    </div>
{/if}
