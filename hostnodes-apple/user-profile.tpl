{* =========================================================================
   user-profile.tpl — logged-in user's profile (name, timezone, locale).
   ========================================================================= *}
<div class="page-header"><h1 class="page-title">{lang key='userProfile.title'}</h1></div>

{include file="$template/includes/flashmessage.tpl"}
{if $successful}{include file="$template/includes/alert.tpl" type="success" msg="{lang key='clientareaupdatesuccessful'}" textcenter=true}{/if}

<form method="post" action="{$smarty.server.PHP_SELF}">
    <input type="hidden" name="token" value="{$token}">

    <div class="card">
        <div class="card-header"><h3 class="card-title">{lang key='userProfile.personalInformation'}</h3></div>
        <div class="card-body">
            <div class="form-row">
                <div class="form-group">
                    <label for="inputFirstName" class="form-label">{lang key='clientareafirstname'}</label>
                    <input type="text" name="firstname" id="inputFirstName" value="{$user.first_name}" class="form-input" required>
                </div>
                <div class="form-group">
                    <label for="inputLastName" class="form-label">{lang key='clientarealastname'}</label>
                    <input type="text" name="lastname" id="inputLastName" value="{$user.last_name}" class="form-input" required>
                </div>
            </div>
            <div class="form-group">
                <label for="inputEmail" class="form-label">{lang key='loginemail'}</label>
                <input type="email" name="email" id="inputEmail" value="{$user.email}" class="form-input" required>
            </div>
        </div>
    </div>

    <div class="btn-group">
        <button type="submit" class="btn btn-primary">{lang key='clientareasavechanges'}</button>
    </div>
</form>
