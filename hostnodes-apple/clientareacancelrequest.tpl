{* =========================================================================
   clientareacancelrequest.tpl — submit a service cancellation request.
   ========================================================================= *}
<div class="page-header"><h1 class="page-title">{lang key='clientareacancelrequestbutton'}</h1></div>

{include file="$template/includes/flashmessage.tpl"}

<div class="card">
    <div class="card-body">
        <p>{lang key='clientareacancelrequest'}</p>

        <form method="post" action="{$smarty.server.PHP_SELF}?action=cancel&amp;id={$id}">
            <input type="hidden" name="cancelsub" value="true">

            <div class="form-group">
                <label for="cancellationType" class="form-label">{lang key='clientareacancelconfirmation'}</label>
                <select name="type" id="cancellationType" class="form-input">
                    <option value="Immediate">{lang key='clientareacancelimmediate'}</option>
                    <option value="End of Billing Period" selected>{lang key='clientareacancelendofbillingperiod'}</option>
                </select>
            </div>

            <div class="form-group">
                <label for="cancellationReason" class="form-label">{lang key='clientareacancelreason'}</label>
                <textarea name="reason" id="cancellationReason" class="form-input" rows="6" required></textarea>
            </div>

            <div class="btn-group">
                <button type="submit" class="btn btn-danger">{lang key='clientareacancelrequestbutton'}</button>
                <a href="clientarea.php?action=productdetails&id={$id}" class="btn btn-secondary">{lang key='cancel'}</a>
            </div>
        </form>
    </div>
</div>
