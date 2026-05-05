{* =========================================================================
   managessl.tpl — manage an issued SSL certificate.
   ========================================================================= *}
<div class="page-header">
    <h1 class="page-title">{lang key='ssl.manage.title'}</h1>
    <a href="clientarea.php" class="btn btn-secondary btn-sm"><i class="fas fa-arrow-left"></i> {lang key='back'}</a>
</div>

<div class="card">
    <div class="card-header">
        <h3 class="card-title">{$domain}</h3>
        <span class="status-pill {$certificate.status|strtolower}">{$certificate.status}</span>
    </div>
    <div class="card-body">
        <div class="product-meta-grid">
            <div class="product-meta-item"><div class="product-meta-label">{lang key='sslState.issuerName'}</div><div class="product-meta-value">{$certificate.issuer}</div></div>
            <div class="product-meta-item"><div class="product-meta-label">{lang key='sslState.startDate'}</div><div class="product-meta-value">{$certificate.validFrom}</div></div>
            <div class="product-meta-item"><div class="product-meta-label">{lang key='sslState.expiryDate'}</div><div class="product-meta-value">{$certificate.expiryDate}</div></div>
        </div>

        <div class="btn-group mt-3">
            {if $certificate.canReissue}<a href="?action=reissue&id={$id}" class="btn btn-primary">{lang key='ssl.reissue'}</a>{/if}
            {if $certificate.canRenew}<a href="?action=renew&id={$id}" class="btn btn-primary">{lang key='ssl.renew'}</a>{/if}
            <a href="?action=downloadCert&id={$id}" class="btn btn-secondary"><i class="fas fa-download"></i> {lang key='ssl.downloadCert'}</a>
        </div>
    </div>
</div>
