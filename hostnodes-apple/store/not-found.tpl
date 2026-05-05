{* =========================================================================
   store/not-found.tpl — rendered when a store product slug doesn't match.
   ========================================================================= *}
<div class="page-header"><h1 class="page-title">{lang key='productNotFound.title'}</h1></div>

<div class="card">
    <div class="card-body text-center">
        <div class="auth-logo warning-icon"><i class="fas fa-search"></i></div>
        <h2>{lang key='productNotFound.heading'}</h2>
        <p>{lang key='productNotFound.description'}</p>
        <a href="{$WEB_ROOT}/cart.php" class="btn btn-primary btn-lg mt-3">{lang key='orderForm.continueShopping'} <i class="fas fa-arrow-right"></i></a>
    </div>
</div>
