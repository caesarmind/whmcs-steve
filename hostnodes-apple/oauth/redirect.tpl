{* =========================================================================
   oauth/redirect.tpl — auto-redirects back to the requesting client with
   authorization code or token.
   ========================================================================= *}
<div class="auth-card text-center">
    <div class="forwardpage-spinner">
        <i class="fas fa-circle-notch fa-spin fa-3x"></i>
        <h1 class="auth-title">{lang key='oauth.redirect.title'}</h1>
        <p class="auth-subtitle">{lang key='oauth.redirect.message'}</p>
    </div>
</div>

<script>
    window.location.replace({$redirectUrl|escape:'html':'UTF-8'|escape:'javascript'});
</script>
