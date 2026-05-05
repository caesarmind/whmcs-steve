{* =========================================================================
   429 — too many requests.
   ========================================================================= *}
<div class="auth-container">
    <div class="auth-card text-center error-page">
        <div class="error-page-icon"><i class="fas fa-tachometer-alt-slow"></i></div>
        <h1 class="error-page-code">429</h1>
        <h2 class="error-page-title">{lang key='errorPage.rateLimitExceeded.title'}</h2>
        <h3 class="error-page-subtitle">{lang key='errorPage.rateLimitExceeded.subtitle'}</h3>
        <p>{lang key='errorPage.rateLimitExceeded.description'}</p>

        <a href="{$systemurl}" class="btn btn-primary btn-lg btn-full">{lang key='errorPage.rateLimitExceeded.home'}</a>
    </div>
</div>
