{*
 * mytheme_cart/includes/existing-paymethods.tpl
 *
 * Saved-card / pay-method picker rendered inside checkout's
 * #existingCardsContainer grid. Lists the signed-in client's
 * tokenised payment methods (credit cards + ACH bank accounts that
 * the active gateway has stored on file).
 *
 * Included from mytheme_cart/includes/checkout/payment.tpl.
 *
 * Variables WHMCS hands in:
 *   $selectedAccountId   active payer's account id
 *   $client              the WHMCS client entity ($client->id, ->payMethods)
 *   $LANG.clientareaexpired
 *
 * Contract preserved verbatim:
 *   - Outer grid is 5 sibling .paymethod-info cells per pay-method
 *     row. scripts.min.js's checkout state machine iterates these by
 *     index, NOT by class -- so the COUNT and ORDER of these cells
 *     cannot change:
 *
 *       1. radio (.existing-card)
 *       2. brand icon
 *       3. card number / account number / type
 *       4. description ($payMethod->getDescription())
 *       5. expiry date (+ "Expired" label when applicable)
 *
 *   - <input type="radio" name="ccinfo" class="existing-card">
 *     value=$payMethod->id is what the form actually submits.
 *   - data-paymethod-id, data-payment-type, data-payment-gateway,
 *     data-order-preference attributes on the radio are queried by
 *     scripts.min.js to toggle the right gateway-specific CVV / 3DS
 *     panel after a card is picked.
 *   - "disabled" attribute on expired cards.
 *
 * Apple visual layer:
 *   - We swap the FontAwesome i.fa-cc-* icons for the same Apple
 *     mini-card visual used on /account/paymentmethods. The visual
 *     ALSO needs the brand class (.visa / .mc / .amex / .pp / .bank)
 *     so style.min.css can paint the right gradient.
 *   - The radio is wrapped in a label that covers the entire row
 *     (.pm-row-label) so the click target is the whole row, not just
 *     the 18px radio dot.
 *}

{if $selectedAccountId === $client->id}
    {foreach $client->payMethods->validateGateways()->sortByExpiryDate() as $payMethod}

        {assign "payMethodExpired" 0}
        {assign "expiryDate" ""}
        {assign "brandClass" "bank"}
        {assign "brandLabel" ""}

        {if $payMethod->isCreditCard()}
            {if $payMethod->payment->isExpired()}
                {assign "payMethodExpired" 1}
            {/if}
            {if $payMethod->payment->getExpiryDate()}
                {assign "expiryDate" $payMethod->payment->getExpiryDate()->format('m/Y')}
            {/if}

            {* Best-effort brand detection -- $payMethod->payment->getDisplayName()
               typically starts with "Visa •••• 4242" so we sniff the prefix.
               Falls back to .bank gradient if no match. *}
            {assign "displayName" $payMethod->payment->getDisplayName()}
            {if "Visa"|strpos:$displayName !== false}
                {assign "brandClass" "visa"}
                {assign "brandLabel" "VISA"}
            {elseif "Master"|strpos:$displayName !== false || "MasterCard"|strpos:$displayName !== false}
                {assign "brandClass" "mc"}
                {assign "brandLabel" "MC"}
            {elseif "Amex"|strpos:$displayName !== false || "American Express"|strpos:$displayName !== false}
                {assign "brandClass" "amex"}
                {assign "brandLabel" "AMEX"}
            {elseif "Discover"|strpos:$displayName !== false}
                {assign "brandClass" "disc"}
                {assign "brandLabel" "DISC"}
            {else}
                {assign "brandClass" "cc"}
                {assign "brandLabel" "CARD"}
            {/if}
        {elseif $payMethod->isRemoteBankAccount() || !$payMethod->isCreditCard()}
            {assign "brandClass" "bank"}
            {assign "brandLabel" "BANK"}
        {/if}

        {* Cell 1: radio -- wrapped in a row-spanning label is impossible
                   because the 5 .paymethod-info cells are sibling
                   grid items (scripts.min.js iterates by index). We
                   keep them as siblings and add a click-handler on
                   the brand cell to forward to the radio. *}
        <div class="paymethod-info radio-inline" data-paymethod-id="{$payMethod->id}">
            <input type="radio"
                   name="ccinfo"
                   id="ccinfo-{$payMethod->id}"
                   class="existing-card"
                   {if $payMethodExpired}disabled{/if}
                   data-payment-type="{$payMethod->getType()}"
                   data-payment-gateway="{$payMethod->gateway_name}"
                   data-order-preference="{$payMethod->order_preference}"
                   value="{$payMethod->id}">
        </div>

        {* Cell 2: Apple mini-card visual (was a FontAwesome icon) *}
        <div class="paymethod-info paymethod-info-brand{if $payMethodExpired} is-expired{/if}"
             data-paymethod-id="{$payMethod->id}"
             onclick="var r=document.getElementById('ccinfo-{$payMethod->id}'); if(r && !r.disabled){literal}{{/literal} r.checked=true; r.dispatchEvent(new Event('change',{literal}{{/literal}bubbles:true{literal}}{/literal})); {literal}}{/literal}">
            <div class="pm-card-visual {$brandClass}">{$brandLabel}</div>
        </div>

        {* Cell 3: card / account identifier *}
        <div class="paymethod-info paymethod-info-id" data-paymethod-id="{$payMethod->id}">
            {if $payMethod->isCreditCard() || $payMethod->isRemoteBankAccount()}
                <span class="pm-card-name">{$payMethod->payment->getDisplayName()|escape}</span>
            {else}
                <span class="type pm-card-type">{$payMethod->payment->getAccountType()|escape}</span>
                <span class="pm-card-num">{substr($payMethod->payment->getAccountNumber(), -4)}</span>
            {/if}
        </div>

        {* Cell 4: description (e.g. "Default payment method") *}
        <div class="paymethod-info paymethod-info-desc" data-paymethod-id="{$payMethod->id}">
            {$payMethod->getDescription()}
        </div>

        {* Cell 5: expiry + expired badge *}
        <div class="paymethod-info paymethod-info-exp" data-paymethod-id="{$payMethod->id}">
            <span class="pm-card-exp">{$expiryDate}</span>
            {if $payMethodExpired}
                <span class="pm-expired-pill">{$LANG.clientareaexpired}</span>
            {/if}
        </div>

    {/foreach}
{/if}
