{* =========================================================================
   3dsecure.tpl — auto-submits a 3-D Secure authentication redirect.
   ========================================================================= *}
<div class="auth-container">
    <div class="auth-card text-center">
        <div class="forwardpage-spinner">
            <i class="fas fa-shield-alt fa-3x"></i>
            <h1 class="auth-title">{lang key='threeDSecure.title'}</h1>
            <p class="auth-subtitle">{lang key='threeDSecure.redirecting'}</p>
        </div>

        <div id="threeDSecureContainer">{$threeDSecureForm}</div>
    </div>
</div>

<script>
    setTimeout(function() {
        var form = document.querySelector('#threeDSecureContainer form');
        if (form) form.submit();
    }, 500);
</script>
