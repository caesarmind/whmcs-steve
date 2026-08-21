{*
 * hadrian_cart/domainoptions.tpl
 *
 * Domain-search result PARTIAL. Rendered by WHMCS as an AJAX fragment
 * inside configureproductdomain.tpl's domain-search container after
 * the user types a domain and clicks "Search". The fragment depends
 * heavily on the search context ($checktype):
 *
 *   - $checktype=="register" + $regenabled    "this domain is available"
 *                                             + register-period chooser
 *   - $checktype=="transfer" + $transferenabled "we can transfer it"
 *   - $checktype=="owndomain" / "subdomain"   already-yours short-circuit
 *                                             (calls domainGotoNextStep())
 *
 * Variables WHMCS hands in:
 *   $domain                full FQDN typed by user
 *   $sld, $tld             pre-split parts
 *   $status                'available' | 'unavailable' | 'error'
 *   $invalid               bool (syntactically invalid)
 *   $alreadyindb           bool (already-in-cart / duplicate)
 *   $reason                string (when invalid)
 *   $checktype             'register' | 'transfer' | 'owndomain' | 'subdomain'
 *   $regenabled            bool
 *   $transferenabled       bool
 *   $transferprice         formatted string
 *   $transferterm          int
 *   $searchResults.domainName             string
 *   $searchResults.shortestPeriod.period  int
 *   $searchResults.shortestPeriod.register formatted string
 *   $searchResults.pricing                map: years -> {register, ...}
 *   $searchResults.suggestions[].domainName, .shortestPeriod, .pricing
 *
 * Contract preserved verbatim (this is THE list of hooks the parent
 * configureproductdomain.tpl + scripts.min.js depend on):
 *   - Hidden inputs:
 *       <input type="hidden" name="domainoption" value="register|transfer|owndomain|subdomain">
 *       <input type="hidden" name="domains[]"          value="{$domain}">
 *       <input type="hidden" name="domainsregperiod[{$domain}]" value="{period}">
 *       <input type="hidden" name="sld" value="{$sld}">
 *       <input type="hidden" name="tld" value="{$tld}">
 *   - selectDomainPricing(domain, price, period, label[, num])
 *     onclick callbacks for the dropdown items (scripts.min.js fn).
 *   - input.suggested-domains checkboxes with id="domainSuggestion{$num}"
 *     and corresponding domainsregperiod[] hidden input alongside.
 *   - domainGotoNextStep() inline call for owndomain/subdomain.
 *   - iCheck restyle of .suggested-domains checkboxes at the bottom
 *     -- this script lives globally so we keep the jQuery init.
 *
 * Visual layer:
 *   - .domain-checker-result-headline gets two state classes,
 *     .domain-checker-available (green) / .domain-checker-unavailable
 *     (red), restyled in style.min.css as soft status banners.
 *   - .dp-pricing wraps the period chooser as a segmented
 *     button group. Single-period stays as a static button.
 *   - .dp-suggestion-list lays the suggestions out as a 2-column
 *     grid on wide viewports.
 *}

{if $invalid}

    <div class="domain-checker-result-headline domain-checker-unavailable">
        <i class="fas fa-times-circle"></i>
        <span>{if $reason}{$reason|escape}{else}{$LANG.cartdomaininvalid}{/if}</span>
    </div>

{elseif $alreadyindb}

    <div class="domain-checker-result-headline domain-checker-unavailable">
        <i class="fas fa-times-circle"></i>
        <span>{$LANG.cartdomainexists}</span>
    </div>

{else}

    {if $checktype == "register" && $regenabled}

        <input type="hidden" name="domainoption" value="register" />

        {if $status eq "available" || $status eq "error"}

            <div class="domain-checker-result-headline domain-checker-available">
                <i class="fas fa-check-circle"></i>
                <span>{$LANG.cartcongratsdomainavailable|sprintf2:$domain}</span>
            </div>

            <input type="hidden" name="domains[]" value="{$searchResults.domainName|escape}" />
            <input type="hidden" name="domainsregperiod[{$domain|escape}]" value="{$searchResults.shortestPeriod.period}" />

            <div class="text-center dp-period-chooser">
                {if count($searchResults.pricing) == 1}
                    <p class="margin-bottom">{$LANG.orderForm.domainAddedToCart}</p>
                    <button type="button" class="btn btn-default btn-lg margin-bottom">
                        <span class="far fa-shopping-cart"></span>
                        &nbsp;{$searchResults.shortestPeriod.register}
                    </button>
                {else}
                    <p class="margin-bottom">{$LANG.orderForm.registerLongerAndSave}</p>
                    <div class="btn-group btn-group-lg margin-bottom dp-pricing">
                        <button type="button" class="btn btn-default btn-sm">
                            <span name="{$searchResults.domainName|escape}-selected-price">
                                <b class="far fa-shopping-cart"></b>
                                &nbsp;{$searchResults.shortestPeriod.period} {$LANG.orderyears} @ {$searchResults.shortestPeriod.register}
                            </span>
                        </button>
                        <button type="button"
                                class="btn btn-default btn-sm dropdown-toggle additional-options"
                                data-toggle="dropdown"
                                aria-haspopup="true"
                                aria-expanded="false">
                            <b class="caret"></b>
                            <span class="sr-only">
                                {lang key="domainChecker.additionalPricingOptions" domain=$searchResults.domainName}
                            </span>
                        </button>
                        <ul class="dropdown-menu" role="menu">
                            {foreach $searchResults.pricing as $years => $price}
                                <li>
                                    <a href="#" onclick="selectDomainPricing('{$searchResults.domainName|escape}', '{$price.register|escape}', {$years}, '{$LANG.orderyears|escape}');return false;">
                                        <b class="far fa-shopping-cart"></b>
                                        &nbsp;{$years} {$LANG.orderyears} @ {$price.register}
                                    </a>
                                </li>
                            {/foreach}
                        </ul>
                    </div>
                {/if}
            </div>

            {assign var='continueok' value=true}

        {elseif $status eq "unavailable"}

            <div class="domain-checker-result-headline domain-checker-unavailable">
                <i class="fas fa-times-circle"></i>
                <span>{$LANG.cartdomaintaken|sprintf2:$domain}</span>
            </div>

        {/if}

    {elseif $checktype == "transfer" && $transferenabled}

        <input type="hidden" name="domainoption" value="transfer" />

        {if $status eq "available"}

            <div class="domain-checker-result-headline domain-checker-unavailable">
                <i class="fas fa-times-circle"></i>
                <span>{$LANG.carttransfernotregistered|sprintf2:$domain}</span>
            </div>
            <p class="text-center dp-fallback-hint">
                {$LANG.orderForm.tryRegisteringInstead}
            </p>

        {elseif $status eq "unavailable" || $status eq "error"}

            <div class="domain-checker-result-headline domain-checker-available">
                <i class="fas fa-check-circle"></i>
                <span>{$LANG.carttransferpossible|sprintf2:$domain:$transferprice}</span>
            </div>

            <input type="hidden" name="domains[]" value="{$domain|escape}" />
            <input type="hidden" name="domainsregperiod[{$domain|escape}]" value="{$transferterm}" />

            {assign var='continueok' value=true}

        {/if}

    {elseif $checktype == "owndomain" || $checktype == "subdomain"}

        {* The own-domain / subdomain path just stamps hidden values
           and tells the parent form to advance immediately. *}
        <input type="hidden" name="domainoption" value="{$checktype|escape}" />
        <input type="hidden" name="sld" value="{$sld|escape}" />
        <input type="hidden" name="tld" value="{$tld|escape}" />
        <script>domainGotoNextStep();</script>

    {/if}

    {* ─── Suggestions ─── *}
    {if $searchResults.suggestions}

        <div class="sub-heading dp-suggestion-heading">
            <span class="primary-bg-color">{$LANG.cartotherdomainsuggestions}</span>
        </div>

        <div class="row domain-suggestions dp-suggestion-list">
            {foreach $searchResults.suggestions as $num => $result}
                <div class="col-sm-6 margin-bottom-5 dp-suggestion">
                    <input type="hidden" name="domainsregperiod[{$result.domainName|escape}]" value="{$result.shortestPeriod.period}" />
                    <label class="dp-suggestion-label">
                        <input type="checkbox"
                               name="domains[]"
                               value="{$result.domainName|escape}"
                               id="domainSuggestion{$num}"
                               class="suggested-domains" />
                        <span class="dp-suggestion-name">{$result.domainName|escape}</span>
                    </label>

                    <div class="pull-right float-right dp-suggestion-pricing-wrap">
                        {if count($result.pricing) > 1}
                            <div class="btn-group domain-suggestion-pricing">
                        {/if}

                        <button type="button"
                                class="btn btn-default btn-sm"
                                onclick="selectDomainPricing('{$result.domainName|escape}', '{$result.shortestPeriod.register|escape}', {$result.shortestPeriod.period}, '{$LANG.orderyears|escape}', '{$num}')">
                            <span name="{$result.domainName|escape}-selected-price">
                                <b class="far fa-shopping-cart"></b>
                                &nbsp;{$result.shortestPeriod.period} {$LANG.orderyears} @ {$result.shortestPeriod.register}
                            </span>
                        </button>

                        {if count($result.pricing) > 1}
                            <button type="button"
                                    class="btn btn-default btn-sm dropdown-toggle additional-options"
                                    data-toggle="dropdown"
                                    aria-haspopup="true"
                                    aria-expanded="false">
                                <b class="caret"></b>
                                <span class="sr-only">
                                    {lang key="domainChecker.additionalPricingOptions" domain=$result.domainName}
                                </span>
                            </button>
                            <ul class="dropdown-menu" role="menu">
                                {foreach $result.pricing as $years => $price}
                                    <li>
                                        <a href="#" onclick="selectDomainPricing('{$result.domainName|escape}', '{$price.register|escape}', {$years}, '{$LANG.orderyears|escape}', '{$num}');return false;">
                                            <b class="far fa-shopping-cart"></b>
                                            &nbsp;{$years} {$LANG.orderyears} @ {$price.register}
                                        </a>
                                    </li>
                                {/foreach}
                            </ul>
                            </div>
                        {/if}
                    </div>
                </div>
            {/foreach}
        </div>

        {assign var='continueok' value=true}
    {/if}

    {if $continueok}
        <div class="alert alert-info info-text-sm dp-cache-note">
            <i class="fas fa-info-circle"></i>
            <span>{$LANG.orderForm.domainAvailabilityCached}</span>
        </div>

        <div class="text-center dp-continue-actions">
            <button type="submit" class="btn btn-primary btn-lg">
                {$LANG.continue}
                &nbsp;<i class="fas fa-arrow-circle-right"></i>
            </button>
        </div>
    {/if}

{/if}

<script>
    jQuery('input.suggested-domains').iCheck({
        checkboxClass: 'icheckbox_square-green',
        radioClass:    'iradio_square-green',
        increaseArea:  '20%'
    });
</script>
