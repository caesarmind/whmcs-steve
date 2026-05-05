{* =========================================================================
   downloaddenied.tpl — shown when download requires login/owning the service.
   ========================================================================= *}
<div class="card">
    <div class="card-body text-center">
        <div class="auth-logo error-icon"><i class="fas fa-lock"></i></div>
        <h2>{lang key='downloaddenied'}</h2>
        <p>{lang key='downloaddeniedmsg'}</p>
        <a href="{routePath('downloads-index')}" class="btn btn-primary">{lang key='back'}</a>
    </div>
</div>
