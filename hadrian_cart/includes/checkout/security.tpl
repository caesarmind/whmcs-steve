{*
 * Account security (password + security question), only rendered when
 * the user isn't already logged in.
 *
 * Field contract:
 *   - password (#inputNewPassword1) + password2 (#inputNewPassword2)
 *     with the PasswordStrength.js meter (#passwordStrengthMeterBar /
 *     #passwordStrengthTextLabel) wired by scripts.min.js once the
 *     namespace stubs at the top of checkout.tpl have allowed the
 *     ready chain to complete.
 *   - .generate-password button targets both inputs via
 *     data-targetfields. WHMCS's PasswordStrength.js binds the click.
 *   - $securityquestions optional: securityqid + securityqans fields.
 *
 * Container #containerNewUserSecurity is hidden via .w-hidden when an
 * existing-customer mode is active or remote auth pre-linked without
 * security questions.
 *}

{if !$loggedin}

    <div id="containerNewUserSecurity"{if (!$loggedin && $custtype eq "existing") || ($remote_auth_prelinked && !$securityquestions)} class="w-hidden"{/if}>

        <div class="sub-heading">
            <span class="primary-bg-color">{$LANG.orderForm.accountSecurity}</span>
        </div>

        <div id="containerPassword" class="row{if $remote_auth_prelinked && $securityquestions} w-hidden{/if}">
            <div id="passwdFeedback" class="alert alert-info text-center col-sm-12 w-hidden"></div>
            <div class="col-sm-6">
                <div class="form-group prepend-icon">
                    <label for="inputNewPassword1" class="field-icon">
                        <i class="fas fa-lock"></i>
                    </label>
                    <input type="password" name="password" id="inputNewPassword1" data-error-threshold="{$pwStrengthErrorThreshold}" data-warning-threshold="{$pwStrengthWarningThreshold}" class="field form-control" placeholder="{$LANG.clientareapassword}"{if $remote_auth_prelinked} value="{$password}"{/if}>
                </div>
            </div>
            <div class="col-sm-6">
                <div class="form-group prepend-icon">
                    <label for="inputNewPassword2" class="field-icon">
                        <i class="fas fa-lock"></i>
                    </label>
                    <input type="password" name="password2" id="inputNewPassword2" class="field form-control" placeholder="{$LANG.clientareaconfirmpassword}"{if $remote_auth_prelinked} value="{$password}"{/if}>
                </div>
            </div>
            <div class="col-sm-6">
                <button type="button" class="btn btn-default btn-sm generate-password" data-targetfields="inputNewPassword1,inputNewPassword2">
                    {$LANG.generatePassword.btnLabel}
                </button>
            </div>
            <div class="col-sm-6">
                <div class="password-strength-meter">
                    <div class="progress">
                        <div class="progress-bar progress-bar-success progress-bar-striped" role="progressbar" aria-valuenow="0" aria-valuemin="0" aria-valuemax="100" id="passwordStrengthMeterBar">
                        </div>
                    </div>
                    <p class="text-center small text-muted" id="passwordStrengthTextLabel">{$LANG.pwstrength}: {$LANG.pwstrengthenter}</p>
                </div>
            </div>
        </div>
        {if $securityquestions}
            <div class="row">
                <div class="col-sm-6">
                    <select name="securityqid" id="inputSecurityQId" class="field form-control">
                        <option value="">{$LANG.clientareasecurityquestion}</option>
                        {foreach $securityquestions as $question}
                            <option value="{$question.id}"{if $question.id eq $securityqid} selected{/if}>
                                {$question.question}
                            </option>
                        {/foreach}
                    </select>
                </div>
                <div class="col-sm-6">
                    <div class="form-group prepend-icon">
                        <label for="inputSecurityQAns" class="field-icon">
                            <i class="fas fa-lock"></i>
                        </label>
                        <input type="password" name="securityqans" id="inputSecurityQAns" class="field form-control" placeholder="{$LANG.clientareasecurityanswer}">
                    </div>
                </div>
            </div>
        {/if}

    </div>

{/if}
