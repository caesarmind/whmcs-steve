{* =========================================================================
   oauth/error.tpl — OAuth flow error (invalid client, scope, etc.).
   ========================================================================= *}
<div class="auth-card text-center">
    <div class="auth-logo error-icon"><i class="fas fa-times"></i></div>
    <h1 class="auth-title">{lang key='oauth.error.title'}</h1>
    <p>{$errorMessage|default:{lang key='oauth.error.generic'}}</p>
    <a href="{$WEB_ROOT}" class="btn btn-primary btn-lg mt-3">{lang key='continue'} <i class="fas fa-arrow-right"></i></a>
</div>
