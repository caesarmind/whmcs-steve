{* =========================================================================
   Generate-Password modal. Included at the bottom of footer.tpl so it's
   always available when a form needs to invoke it.
   ========================================================================= *}
<form action="#" id="frmGeneratePassword">
    <div class="modal fade apple-modal" id="modalGeneratePassword">
        <div class="modal-backdrop"></div>
        <div class="modal-dialog">
            <div class="modal-content card">
                <div class="modal-header card-header">
                    <h3 class="modal-title card-title">{lang key='generatePassword.title'}</h3>
                    <button type="button" class="modal-close" data-dismiss="modal" aria-label="{lang key='close'}">&times;</button>
                </div>
                <div class="modal-body card-body">
                    <div class="callout danger w-hidden" id="generatePwLengthError">
                        {lang key='generatePassword.lengthValidationError'}
                    </div>
                    <div class="form-group">
                        <label for="inputGeneratePasswordLength" class="form-label">{lang key='generatePassword.pwLength'}</label>
                        <input type="number" min="8" max="64" value="12" step="1" class="form-input" id="inputGeneratePasswordLength">
                    </div>
                    <div class="form-group">
                        <label for="inputGeneratePasswordOutput" class="form-label">{lang key='generatePassword.generatedPw'}</label>
                        <input type="text" class="form-input" id="inputGeneratePasswordOutput">
                    </div>
                    <div class="btn-group">
                        <button type="submit" class="btn btn-secondary btn-sm">
                            <i class="fas fa-plus"></i> {lang key='generatePassword.generateNew'}
                        </button>
                        <button type="button" class="btn btn-secondary btn-sm copy-to-clipboard" data-clipboard-target="#inputGeneratePasswordOutput">
                            <i class="far fa-copy"></i> {lang key='copy'}
                        </button>
                    </div>
                </div>
                <div class="modal-footer card-footer">
                    <button type="button" class="btn btn-secondary" data-dismiss="modal">{lang key='close'}</button>
                    <button type="button" class="btn btn-primary" id="btnGeneratePasswordInsert" data-clipboard-target="#inputGeneratePasswordOutput">
                        {lang key='generatePassword.copyAndInsert'}
                    </button>
                </div>
            </div>
        </div>
    </div>
</form>
