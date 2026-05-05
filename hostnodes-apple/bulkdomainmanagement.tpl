{* =========================================================================
   bulkdomainmanagement.tpl — apply an action across multiple domains.
   ========================================================================= *}
<div class="page-header"><h1 class="page-title">{lang key='bulkdomainmanagement'}</h1></div>

{if $successful}{include file="$template/includes/alert.tpl" type="success" msg="{lang key='changessavedsuccessfully'}" textcenter=true}{/if}
{if $errormessage}{include file="$template/includes/alert.tpl" type="error" errorshtml=$errormessage}{/if}

<form method="post" action="{$smarty.server.PHP_SELF}">
    <input type="hidden" name="update" value="{$update}">
    {foreach $domids as $domid}<input type="hidden" name="domids[]" value="{$domid}">{/foreach}

    <div class="card">
        <div class="card-header"><h3 class="card-title">{lang key="bulkdomain.{$update}"}</h3></div>
        <div class="card-body">
            <p>{lang key='bulkdomainfollowingdomains'}:</p>
            <ul>{foreach $domains as $domain}<li>{$domain.domain}</li>{/foreach}</ul>

            {$formContent}

            <div class="btn-group mt-3">
                <button type="submit" class="btn btn-primary">{lang key='clientareasavechanges'}</button>
                <a href="clientarea.php?action=domains" class="btn btn-secondary">{lang key='cancel'}</a>
            </div>
        </div>
    </div>
</form>
