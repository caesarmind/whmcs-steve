{* =========================================================================
   access-denied.tpl — sub-account permission denial page.
   ========================================================================= *}
<div class="auth-container">
    <div class="auth-card text-center">
        <div class="auth-logo warning-icon"><i class="fas fa-exclamation-triangle"></i></div>
        <h1 class="auth-title">{lang key='oops'}</h1>
        <p class="auth-subtitle">{lang key='subaccountpermissiondenied'}</p>

        {if !empty($allowedpermissions)}
            <div class="card mt-3">
                <div class="card-header"><h3 class="card-title">{lang key='subaccountallowedperms'}</h3></div>
                <div class="card-body">
                    <ul class="permission-list">
                        {foreach $allowedpermissions as $permission}
                            <li><i class="fas fa-check text-success"></i> {$permission}</li>
                        {/foreach}
                    </ul>
                </div>
            </div>
        {/if}

        <p class="form-hint">{lang key='subaccountcontactmaster'}</p>

        <div class="btn-group mt-3">
            <a href="javascript:history.go(-1)" class="btn btn-primary"><i class="fas fa-arrow-left"></i> {lang key='goback'}</a>
            <a href="{$WEB_ROOT}/index.php" class="btn btn-secondary"><i class="fas fa-home"></i> {lang key='returnhome'}</a>
        </div>
    </div>
</div>
