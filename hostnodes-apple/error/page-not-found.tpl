{* =========================================================================
   404 — page not found.
   ========================================================================= *}
<div class="auth-container">
    <div class="auth-card text-center error-page">
        <div class="error-page-icon"><i class="fas fa-exclamation-circle"></i></div>
        <h1 class="error-page-code">404</h1>
        <h2 class="error-page-title">{lang key='errorPage.404.title'}</h2>
        <h3 class="error-page-subtitle">{lang key='errorPage.404.subtitle'}</h3>
        <p>{lang key='errorPage.404.description'}</p>

        <div class="btn-group">
            <a href="{$systemurl}" class="btn btn-primary btn-lg">{lang key='errorPage.404.home'}</a>
            <a href="{$systemurl}contact.php" class="btn btn-secondary btn-lg">{lang key='errorPage.404.submitTicket'}</a>
        </div>
    </div>
</div>
