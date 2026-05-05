{* =========================================================================
   upgrade-configure.tpl — configure options for an upgrade order.
   ========================================================================= *}
<div class="page-header"><h1 class="page-title">{lang key='upgradeconfigure'}</h1></div>

<form method="post" action="{$smarty.server.PHP_SELF}">
    <input type="hidden" name="id" value="{$id}">
    <input type="hidden" name="newproductid" value="{$newproductid}">

    <div class="card">
        <div class="card-header"><h3 class="card-title">{$newproduct.name}</h3></div>
        <div class="card-body">
            {if $configurableoptions}
                {foreach $configurableoptions as $option}
                    <div class="form-group">
                        <label class="form-label">{$option.name}</label>
                        {$option.input}
                    </div>
                {/foreach}
            {/if}

            <div class="form-group">
                <label for="upgradeCycle" class="form-label">{lang key='orderbillingcycle'}</label>
                <select name="paymentterm" id="upgradeCycle" class="form-input">
                    {foreach $cycles as $cycle}
                        <option value="{$cycle.value}">{$cycle.label} &mdash; {$cycle.price}</option>
                    {/foreach}
                </select>
            </div>
        </div>
    </div>

    <div class="btn-group">
        <button type="submit" class="btn btn-primary btn-lg">{lang key='continue'}</button>
        <a href="clientarea.php?action=productdetails&id={$id}" class="btn btn-secondary">{lang key='cancel'}</a>
    </div>
</form>
