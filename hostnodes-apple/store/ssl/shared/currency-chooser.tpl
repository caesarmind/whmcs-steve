{* =========================================================================
   Currency selector for public (not-logged-in) store pages.
   ========================================================================= *}
{if !$loggedin && $currencies}
    <form method="post" action="" class="currency-chooser">
        <select name="currency" class="form-input form-input-sm" onchange="submit()">
            <option>{lang key="changeCurrency"} ({$activeCurrency.prefix} {$activeCurrency.code})</option>
            {foreach $currencies as $currency}
                <option value="{$currency.id}">{$currency.prefix} {$currency.code}</option>
            {/foreach}
        </select>
    </form>
{/if}
