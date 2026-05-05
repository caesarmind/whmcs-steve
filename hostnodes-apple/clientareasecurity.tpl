{* =========================================================================
   clientareasecurity.tpl — password, security question, 2FA, sessions.
   ========================================================================= *}
<div class="page-header"><h1 class="page-title">{lang key='clientareanavsecurity'}</h1></div>

{include file="$template/includes/flashmessage.tpl"}
{if $successful}{include file="$template/includes/alert.tpl" type="success" msg="{lang key='clientareaupdatesuccessful'}" textcenter=true}{/if}
{if $errormessage}{include file="$template/includes/alert.tpl" type="error" errorshtml=$errormessage}{/if}

<div class="card">
    <div class="card-header"><h3 class="card-title">{lang key='clientareachangepassword'}</h3></div>
    <div class="card-body">
        <form class="using-password-strength" method="post" action="{$smarty.server.PHP_SELF}">
            <input type="hidden" name="token" value="{$token}">
            <input type="hidden" name="sub" value="password">

            <div class="form-group">
                <label for="inputCurrentPassword" class="form-label">{lang key='existingpw'}</label>
                <input type="password" name="existingpw" id="inputCurrentPassword" class="form-input" autocomplete="current-password">
            </div>
            <div class="form-group" id="newPassword1">
                <label for="inputNewPassword1" class="form-label">{lang key='newpassword'}</label>
                <input type="password" name="newpw" id="inputNewPassword1" class="form-input" autocomplete="new-password">
                {include file="$template/includes/pwstrength.tpl"}
            </div>
            <div class="form-group" id="newPassword2">
                <label for="inputNewPassword2" class="form-label">{lang key='confirmnewpassword'}</label>
                <input type="password" name="confirmpw" id="inputNewPassword2" class="form-input" autocomplete="new-password">
                <div id="inputNewPassword2Msg"></div>
            </div>
            <div class="btn-group">
                <button type="button" class="btn btn-secondary generate-password" data-targetfields="inputNewPassword1,inputNewPassword2">{lang key='generatePassword.btnLabel'}</button>
                <button type="submit" class="btn btn-primary">{lang key='clientareasavechanges'}</button>
            </div>
        </form>
    </div>
</div>

{if $twoFactorEnabled}
    <div class="card">
        <div class="card-header"><h3 class="card-title">{lang key='twofactorauth'}</h3></div>
        <div class="card-body">
            {if $twoFactorEnabledForUser}
                {include file="$template/includes/alert.tpl" type="success" msg="{lang key='twofaEnabled'}"}
                <a href="{routePath('user-two-factor-disable')}" class="btn btn-danger">{lang key='disable'}</a>
            {else}
                <p>{lang key='twofaExp'}</p>
                <a href="{routePath('user-two-factor-enable')}" class="btn btn-primary">{lang key='enable'}</a>
            {/if}
        </div>
    </div>
{/if}

{if $securityquestions}
    <div class="card">
        <div class="card-header"><h3 class="card-title">{lang key='clientareasecurityquestion'}</h3></div>
        <div class="card-body">
            <form method="post" action="{$smarty.server.PHP_SELF}">
                <input type="hidden" name="token" value="{$token}">
                <input type="hidden" name="sub" value="securityquestion">

                <div class="form-group">
                    <label for="securityqid" class="form-label">{lang key='clientareasecurityquestion'}</label>
                    <select name="securityqid" id="securityqid" class="form-input">
                        {foreach $securityquestions as $question}
                            <option value="{$question.id}"{if $question.id eq $securityqid} selected{/if}>{$question.question}</option>
                        {/foreach}
                    </select>
                </div>
                <div class="form-group">
                    <label for="securityqans" class="form-label">{lang key='clientareasecurityanswer'}</label>
                    <input type="password" name="securityqans" id="securityqans" class="form-input">
                </div>
                <div class="form-group">
                    <label for="securityqexistingpw" class="form-label">{lang key='existingpw'}</label>
                    <input type="password" name="securityqexistingpw" id="securityqexistingpw" class="form-input">
                </div>
                <button type="submit" class="btn btn-primary">{lang key='clientareasavechanges'}</button>
            </form>
        </div>
    </div>
{/if}
