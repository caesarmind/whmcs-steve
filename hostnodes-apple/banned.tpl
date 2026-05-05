{* =========================================================================
   banned.tpl — shown when the client IP is banned.
   ========================================================================= *}
<div class="auth-container">
    <div class="auth-card text-center">
        <div class="auth-logo error-icon"><i class="fas fa-gavel"></i></div>
        <h1 class="auth-title">{lang key='bannedyourip'} {$ip}</h1>
        <p class="auth-subtitle">{lang key='bannedhasbeenbanned'}</p>

        <div class="card mt-3">
            <div class="card-body">
                <div class="product-meta-grid">
                    <div class="product-meta-item">
                        <div class="product-meta-label">{lang key='bannedbanreason'}</div>
                        <div class="product-meta-value">{$reason}</div>
                    </div>
                    <div class="product-meta-item">
                        <div class="product-meta-label">{lang key='bannedbanexpires'}</div>
                        <div class="product-meta-value">{$expires}</div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
