{* =========================================================================
   Inner partial (step 2 — security question).
   ========================================================================= *}
<h1 class="auth-title">{lang key='pwreset'}</h1>
<p class="auth-subtitle">{lang key='pwresetsecurityquestionrequired'}</p>

{if $errorMessage}
    {include file="$template/includes/alert.tpl" type="error" msg=$errorMessage textcenter=true}
{/if}

<form method="post" action="{routePath('password-reset-security-verify')}" class="auth-form">
    <div class="form-group">
        <label for="inputAnswer" class="form-label">{$securityQuestion}</label>
        <input type="text" name="answer" class="form-input" id="inputAnswer" autofocus required>
    </div>

    <button type="submit" class="btn btn-primary btn-lg btn-full">{lang key='pwresetsubmit'}</button>
</form>
