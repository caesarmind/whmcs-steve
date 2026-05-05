{* =========================================================================
   Confirmation modal — triggers on button click. Parameters:
     modalId       — unique ID suffix
     buttonTitle   — text on the trigger button
     modalTitle    — heading
     modalBody     — body content
     targetUrl     — URL the confirm button navigates to
     saveBtnTitle  / saveBtnIcon  — confirm button
     closeBtnTitle / closeBtnIcon — cancel button
   ========================================================================= *}
<button type="button" class="btn btn-sm btn-secondary" data-toggle="modal" data-target="#confirmModal{$modalId}">
    {$buttonTitle}
</button>

<div class="modal fade apple-modal" id="confirmModal{$modalId}" tabindex="-1" role="dialog" aria-labelledby="confirmModalLabel{$modalId}" aria-hidden="true">
    <div class="modal-backdrop"></div>
    <div class="modal-dialog" role="document">
        <div class="modal-content card">
            <div class="modal-header card-header">
                <h3 class="modal-title card-title" id="confirmModalLabel{$modalId}">{$modalTitle}</h3>
                <button type="button" class="modal-close" data-dismiss="modal" aria-label="{lang key='close'}">&times;</button>
            </div>
            <div class="modal-body card-body">
                {$modalBody}
            </div>
            <div class="modal-footer card-footer">
                <button id="btnConfirmModalConfirmBtn" type="button" class="btn btn-sm btn-primary" data-target-url="{$targetUrl}">
                    {if $saveBtnIcon}<i class="{$saveBtnIcon}"></i>{/if}
                    {$saveBtnTitle}
                </button>
                <button type="button" class="btn btn-sm btn-secondary" data-dismiss="modal">
                    {if $closeBtnIcon}<i class="{$closeBtnIcon}"></i>{/if}
                    {$closeBtnTitle}
                </button>
            </div>
        </div>
    </div>
</div>
