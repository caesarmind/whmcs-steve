{* =========================================================================
   upgrade.tpl — pick an upgrade type for a service.
   ========================================================================= *}
<div class="page-header"><h1 class="page-title">{lang key='upgrade'}</h1></div>

{if $errormessage}{include file="$template/includes/alert.tpl" type="error" errorshtml=$errormessage}{/if}

<div class="card">
    <div class="card-header"><h3 class="card-title">{lang key='upgradepickproduct'}</h3></div>
    <div class="card-body">
        <p>{lang key='upgradeexp'}</p>
        <form method="post" action="{$smarty.server.PHP_SELF}">
            <input type="hidden" name="id" value="{$id}">
            <input type="hidden" name="type" value="{$type}">

            <div class="form-group">
                <label for="upgradeProduct" class="form-label">{lang key='upgradepickpackage'}</label>
                <select name="newproductid" id="upgradeProduct" class="form-input">
                    {foreach $packages as $package}
                        <option value="{$package.id}">{$package.name} &mdash; {$package.price}</option>
                    {/foreach}
                </select>
            </div>

            <button type="submit" class="btn btn-primary btn-lg">{lang key='continue'} <i class="fas fa-arrow-right"></i></button>
        </form>
    </div>
</div>
