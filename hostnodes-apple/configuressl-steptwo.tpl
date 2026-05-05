{* =========================================================================
   configuressl-steptwo.tpl — CSR generation / admin contact details.
   ========================================================================= *}
<div class="page-header">
    <h1 class="page-title">{lang key='ssl.configuressl.title'}</h1>
    <p class="page-subtitle">{lang key='ssl.configuressl.steptwo'}</p>
</div>

{if $errormessage}{include file="$template/includes/alert.tpl" type="error" errorshtml=$errormessage}{/if}

<form method="post" action="{$smarty.server.PHP_SELF}">
    <input type="hidden" name="step" value="3">
    <input type="hidden" name="id" value="{$id}">
    <input type="hidden" name="domain" value="{$domain}">

    <div class="card">
        <div class="card-header"><h3 class="card-title">{lang key='ssl.csr'}</h3></div>
        <div class="card-body">
            <div class="form-group">
                <label for="csr" class="form-label">{lang key='ssl.csrLabel'}</label>
                <textarea name="csr" id="csr" rows="12" class="form-input" required>{$csr}</textarea>
                <div class="form-hint">{lang key='ssl.csrHint'}</div>
            </div>
        </div>
    </div>

    <div class="card">
        <div class="card-header"><h3 class="card-title">{lang key='ssl.adminContact'}</h3></div>
        <div class="card-body">
            <div class="form-row">
                <div class="form-group">
                    <label for="adminFirstName" class="form-label">{lang key='clientareafirstname'}</label>
                    <input type="text" name="admin_firstname" id="adminFirstName" value="{$admin.firstname}" class="form-input" required>
                </div>
                <div class="form-group">
                    <label for="adminLastName" class="form-label">{lang key='clientarealastname'}</label>
                    <input type="text" name="admin_lastname" id="adminLastName" value="{$admin.lastname}" class="form-input" required>
                </div>
            </div>
            <div class="form-group">
                <label for="adminEmail" class="form-label">{lang key='clientareaemail'}</label>
                <input type="email" name="admin_email" id="adminEmail" value="{$admin.email}" class="form-input" required>
            </div>
        </div>
    </div>

    <button type="submit" class="btn btn-primary btn-lg">{lang key='continue'} <i class="fas fa-arrow-right"></i></button>
</form>
