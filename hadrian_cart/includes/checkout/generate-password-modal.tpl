{*
 * Generate-Password modal.
 *
 * Replaces standard_cart's "silent prefill" behaviour (which just dumps a
 * random password into the password inputs and slides the section up so
 * the user never sees it). Instead, mirrors hostnodes-apple's pattern --
 * click .generate-password, modal opens, user picks length, sees the
 * generated password, copies it AND inserts it into the target fields.
 *
 * Wired up by the inline IIFE at the bottom of checkout.tpl:
 *   .generate-password click  -> open modal with data-targetfields
 *   form submit              -> fill #inputGeneratePasswordOutput
 *   #btnGeneratePasswordInsert -> copy + insert + close modal
 *
 * Uses WHMCS.utils.generatePassword(length) (defined in scripts.min.js's
 * utils module) and WHMCS.ui.clipboard.copy. Both are present by the
 * time checkout.tpl renders because our WHMCS namespace stub at the
 * top of checkout.tpl replicates the scripts.min.js bootstrap.
 *}
<form action="#" id="frmGeneratePassword">
    <div class="modal fade modal-generate-password" id="modalGeneratePassword" tabindex="-1" role="dialog" aria-hidden="true">
        <div class="modal-dialog" role="document">
            <div class="modal-content">
                <div class="modal-header">
                    <h4 class="modal-title">{lang key='generatePassword.title'}</h4>
                    <button type="button" class="close" data-dismiss="modal" aria-label="{lang key='close'}"><span aria-hidden="true">&times;</span></button>
                </div>
                <div class="modal-body">
                    <div class="alert alert-danger w-hidden" id="generatePwLengthError" role="alert">
                        {lang key='generatePassword.lengthValidationError'}
                    </div>

                    <div class="gp-field">
                        <label for="inputGeneratePasswordLength">{lang key='generatePassword.pwLength'}</label>
                        <input type="number" min="8" max="64" value="12" step="1" class="form-control" id="inputGeneratePasswordLength">
                    </div>

                    <div class="gp-field">
                        <label for="inputGeneratePasswordOutput">{lang key='generatePassword.generatedPw'}</label>
                        <div class="gp-output-row">
                            <input type="text" class="form-control" id="inputGeneratePasswordOutput" readonly placeholder="—">
                            <button type="submit" class="gp-btn gp-btn-ghost" title="{lang key='generatePassword.generateNew'}">
                                <i class="fas fa-sync-alt"></i>
                                <span>{lang key='generatePassword.generateNew'}</span>
                            </button>
                        </div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="gp-btn gp-btn-secondary" data-dismiss="modal">{lang key='close'}</button>
                    <button type="button" class="gp-btn gp-btn-primary" id="btnGeneratePasswordInsert" data-clipboard-target="#inputGeneratePasswordOutput">
                        {lang key='generatePassword.copyAndInsert'}
                    </button>
                </div>
            </div>
        </div>
    </div>
</form>
