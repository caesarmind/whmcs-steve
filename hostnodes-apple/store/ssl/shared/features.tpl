{* =========================================================================
   SSL features showcase. Parameters: $type (dv | wildcard | ov | ev).
   ========================================================================= *}
<div class="ssl-standout">
    <div class="kb-grid">
        {if $type == 'ev'}
            <div class="card ssl-feature"><div class="card-body text-center"><h4>{lang key='store.ssl.shared.ev.visualVerification'}</h4><p>{lang key='store.ssl.shared.ev.visualVerificationDescription'}</p></div></div>
        {elseif $type == 'ov'}
            <div class="card ssl-feature"><div class="card-body text-center"><h4>{lang key='store.ssl.shared.ov.ov'}</h4><p>{lang key='store.ssl.shared.ov.ovDescription'}</p></div></div>
        {else}
            <div class="card ssl-feature"><div class="card-body text-center"><h4>{lang key='store.ssl.shared.delivery'}</h4><p>{lang key='store.ssl.shared.deliveryDescription'}</p></div></div>
        {/if}
        <div class="card ssl-feature"><div class="card-body text-center"><h4>{lang key='store.ssl.shared.siteSeal'}</h4><p>{lang key='store.ssl.shared.siteSealDescription'}</p></div></div>
        {if $type == 'ev'}
            <div class="card ssl-feature"><div class="card-body text-center"><h4>{lang key='store.ssl.shared.ev.warranty'}</h4><p>{lang key='store.ssl.shared.ev.warrantyDescription'}</p></div></div>
        {elseif $type == 'ov'}
            <div class="card ssl-feature"><div class="card-body text-center"><h4>{lang key='store.ssl.shared.ov.warranty'}</h4><p>{lang key='store.ssl.shared.ov.warrantyDescription'}</p></div></div>
        {else}
            <div class="card ssl-feature"><div class="card-body text-center"><h4>{lang key='store.ssl.shared.googleRanking'}</h4><p>{lang key='store.ssl.shared.googleRankingDescription'}</p></div></div>
        {/if}
    </div>
</div>

<div class="ssl-feature-grid card">
    <div class="card-header"><h3 class="card-title">{lang key='store.ssl.shared.features'}</h3></div>
    <div class="card-body">
        <div class="ssl-features-icons">
            <div class="ssl-feature-item"><i class="fas fa-lock"></i><h5>{lang key='store.ssl.shared.encryptData'}</h5></div>
            <div class="ssl-feature-item"><i class="fas fa-credit-card"></i><h5>{lang key='store.ssl.shared.secureTransactions'}</h5></div>
            <div class="ssl-feature-item"><i class="fas fa-trophy"></i><h5>{lang key='store.ssl.shared.legitimacy'}</h5></div>
            <div class="ssl-feature-item"><i class="fas fa-certificate"></i><h5>{lang key='store.ssl.shared.fastestSsl'}</h5></div>
            <div class="ssl-feature-item"><i class="fas fa-window-maximize"></i><h5>{lang key='store.ssl.shared.browserCompatability'}</h5></div>
            <div class="ssl-feature-item"><i class="fas fa-search"></i><h5>{lang key='store.ssl.shared.seoRank'}</h5></div>
            <div class="ssl-feature-item">
                <i class="far fa-clock"></i>
                {if $type == 'ev'}<h5>{lang key='store.ssl.shared.ev.issuance'}</h5>
                {elseif $type == 'ov'}<h5>{lang key='store.ssl.shared.ov.issuance'}</h5>
                {else}<h5>{lang key='store.ssl.shared.issuance'}</h5>{/if}
            </div>
            <div class="ssl-feature-item"><i class="fas fa-sync"></i><h5>{lang key='store.ssl.shared.freeReissues'}</h5></div>
        </div>
    </div>
</div>
