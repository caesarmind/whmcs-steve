{* =========================================================================
   password-reset-container.tpl — outer shell for the reset flow.
   Renders one of: email-prompt, security-prompt, change-prompt
   based on $innerTemplate.
   ========================================================================= *}
<div class="auth-container">
    <div class="auth-card">
        {if $loggedin && $innerTemplate}
            {include file="$template/includes/alert.tpl" type="error" msg="{lang key='noPasswordResetWhenLoggedIn'}" textcenter=true}
        {else}
            {if $successMessage}
                {include file="$template/includes/alert.tpl" type="success" msg=$successTitle textcenter=true}
                <p class="text-center">{$successMessage}</p>
            {else}
                {if $errorMessage}
                    {include file="$template/includes/alert.tpl" type="error" msg=$errorMessage textcenter=true}
                {/if}
                {if $innerTemplate}
                    {include file="$template/password-reset-$innerTemplate.tpl"}
                {/if}
            {/if}
        {/if}

        <div class="auth-footer">
            <small>{lang key='rememberyourpw'}</small>
            <a href="{$WEB_ROOT}/login.php" class="auth-link">{lang key='loginbutton'}</a>
        </div>
    </div>
</div>
