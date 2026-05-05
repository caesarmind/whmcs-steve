{* =========================================================================
   account-contacts-new.tpl — create a new sub-account contact.
   ========================================================================= *}
<div class="page-header"><h1 class="page-title">{lang key='contacts.addNew'}</h1></div>

{if $errormessage}{include file="$template/includes/alert.tpl" type="error" errorshtml=$errormessage}{/if}

<form method="post" action="{$smarty.server.PHP_SELF}">
    <input type="hidden" name="token" value="{$token}">
    <input type="hidden" name="sub" value="save">

    <div class="card">
        <div class="card-header"><h3 class="card-title">{lang key='contacts.details'}</h3></div>
        <div class="card-body">
            <div class="form-row">
                <div class="form-group">
                    <label for="inputFirstName" class="form-label">{lang key='clientareafirstname'}</label>
                    <input type="text" name="firstname" id="inputFirstName" class="form-input" required>
                </div>
                <div class="form-group">
                    <label for="inputLastName" class="form-label">{lang key='clientarealastname'}</label>
                    <input type="text" name="lastname" id="inputLastName" class="form-input" required>
                </div>
            </div>
            <div class="form-row">
                <div class="form-group">
                    <label for="inputEmail" class="form-label">{lang key='clientareaemail'}</label>
                    <input type="email" name="email" id="inputEmail" class="form-input" required>
                </div>
                <div class="form-group">
                    <label for="inputPhone" class="form-label">{lang key='clientareaphonenumber'}</label>
                    <input type="tel" name="phonenumber" id="inputPhone" class="form-input">
                </div>
            </div>
            <div class="form-group">
                <label for="inputCompanyName" class="form-label">{lang key='clientareacompanyname'}</label>
                <input type="text" name="companyname" id="inputCompanyName" class="form-input">
            </div>
        </div>
    </div>

    <div class="btn-group">
        <button type="submit" class="btn btn-primary">{lang key='contacts.save'}</button>
        <a href="{routePath('account-contacts')}" class="btn btn-secondary">{lang key='cancel'}</a>
    </div>
</form>
