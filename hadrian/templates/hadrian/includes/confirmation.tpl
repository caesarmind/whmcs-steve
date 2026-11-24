{* Confirmation button + modal - the WHMCS shared include, for code that
   includes "$template/includes/confirmation.tpl" by name. Stock Bootstrap 4
   markup and ids (#confirmModal<modalId>, #btnConfirmModalConfirmBtn with
   data-target-url) so the caller's JS keeps working. Same parameters as
   stock: modalId, buttonTitle, modalTitle, modalBody, targetUrl,
   saveBtnTitle, saveBtnIcon, closeBtnTitle, closeBtnIcon (icons are
   FontAwesome classes, which Hadrian doesn't load, so they are skipped). *}
<button type="button" class="btn-secondary" data-toggle="modal" data-target="#confirmModal{$modalId}">{$buttonTitle}</button>

<div class="modal fade" id="confirmModal{$modalId}" tabindex="-1" role="dialog" aria-labelledby="confirmModalLabel{$modalId}" aria-hidden="true">
    <div class="modal-dialog" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="confirmModalLabel{$modalId}">{$modalTitle}</h5>
                <button type="button" class="close" data-dismiss="modal" aria-label="{lang key='close'}"><span aria-hidden="true">&times;</span></button>
            </div>
            <div class="modal-body">{$modalBody}</div>
            <div class="modal-footer">
                <button id="btnConfirmModalConfirmBtn" type="button" class="btn-primary" data-target-url="{$targetUrl}">{$saveBtnTitle}</button>
                <button type="button" class="btn-secondary" data-dismiss="modal">{$closeBtnTitle}</button>
            </div>
        </div>
    </div>
</div>
