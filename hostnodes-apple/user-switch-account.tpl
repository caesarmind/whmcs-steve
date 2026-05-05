{* =========================================================================
   user-switch-account.tpl — picker for users with access to multiple
   client accounts.
   ========================================================================= *}
<div class="auth-container auth-container-wide">
    <div class="auth-card auth-card-wide">
        <h1 class="auth-title">{lang key='userSwitch.switchAccount'}</h1>
        <p class="auth-subtitle">{lang key='userSwitch.accountsAvailable'}</p>

        <div class="switch-account-list">
            {foreach $accounts as $account}
                <a href="{routePath('user-switch-account-validate', $account.id)}" class="service-item">
                    <div class="service-icon"><i class="fas fa-building"></i></div>
                    <div class="service-info">
                        <div class="service-name">{if $account.companyname}{$account.companyname}{else}{$account.full_name}{/if}</div>
                        <div class="service-domain">{$account.email}</div>
                    </div>
                    <span class="service-chevron"><i class="fas fa-chevron-right"></i></span>
                </a>
            {/foreach}
        </div>
    </div>
</div>
