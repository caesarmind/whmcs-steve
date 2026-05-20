{*
 * mytheme_cart/domainregister.tpl
 *
 * Apple visual shell over standard_cart's exact domainregister contract.
 * Visual source: apple-client-area/cart-domain-register.html.
 *
 * Shell layout matches products.tpl:
 *   .st-page-header (eyebrow + H1 + subtitle)
 *   .st-split (sidebar-categories.tpl  |  .dr-main)
 *   .dr-main:
 *      .dr-search  -- search card with AI/Classic mode tabs + form(s)
 *      .dr-results-full  -- results block (search results, spotlights,
 *                          suggestions, transfer CTA, pricing table)
 *      .dr-results-empty -- empty-state placeholder shown when the
 *                          state-chip flips body[data-data="empty"]
 *
 * Mode tabs: standard_cart only renders ONE search form per page based
 * on the WHMCS admin setting "Use the standard or smart domain search"
 * ($showAdvancedSearchOptions). We render BOTH forms so the user can
 * tab-switch between AI Generator and Classic Search:
 *   - The form matching the WHMCS-chosen mode keeps the canonical
 *     scripts.min.js hooks (#frmDomainChecker, #message OR #inputDomain,
 *     #btnCheckAvailability) so the live AJAX flow works exactly as
 *     standard_cart intends.
 *   - The other-mode form renders with `dr-alt-` prefixed IDs and
 *     submits a regular POST to cart.php?a=checkDomain. WHMCS's
 *     checkDomain handler accepts either `message` or `domain` field,
 *     so the page reloads with results rendered in the chosen mode.
 * Tab click swaps which form is visible via data-search-mode on the
 * .dr-search container.
 *
 * State toggle (full vs empty):
 * Class names .dr-results-full / .dr-results-empty intentionally avoid
 * .when-full / .when-empty because mytheme's global CSS hides
 * .when-full on cart routes (see feedback_cart_class_namespace memory).
 * The toggle is scoped via `body[data-data="empty"] #order-standard_cart
 * .dr-results-full` in style.min.css so it only fires when the state-
 * chip explicitly picks Empty.
 *
 * Element ids preserved verbatim (scripts.min.js + multiselect plugin
 * + recaptcha integration all bind to these):
 *   #frmDomainChecker (one of the two forms), #message OR #inputDomain
 *   (only on the WHMCS-chosen mode), #btnCheckAvailability,
 *   #DomainSearchResults, #primarySuggestionHeading, #primaryExactHeading,
 *   #searchDomainInfo, #primaryLookupSearching, #primaryLookupResult,
 *   #idnLanguageSelector, #spotlightTlds, #suggestionsLoader,
 *   #domainSuggestions, #moreSuggestions, #noMoreSuggestions,
 *   #captchaContainer, #inputCaptchaImage, #inputCaptcha
 *
 * Input names preserved: message, domain, tlds[], maxLength, filter,
 * code (captcha), idnlanguage.
 *
 * Class hooks preserved: .domain-checker-container, .domain-checker-bg,
 * .domain-checker-advanced, .input-group-box, .domain-check-availability,
 * .domain-checker-result-headline, .domain-lookup-loader,
 * .domain-lookup-primary-loader, .domain-searching, .domain-lookup-result,
 * .domain-invalid/.domain-checker-invalid, .domain-unavailable/
 * .domain-checker-unavailable, .domain-tld-unavailable, .domain-available/
 * .domain-checker-available, .domain-contact-support, .domain-price,
 * .price, .btn-add-to-cart, .domain-error, .spotlight-tlds,
 * .spotlight-tld-container, .spotlight-tld, .domain-lookup-spotlight-loader,
 * .suggested-domains, .domain-suggestion, .promo, .sales-group-*,
 * .more-suggestions, .domain-suggestions-warning, .tld-filters, .tld-row,
 * .tld-pricing-header, .tld-column, .featured-tlds-container, .featured-tld,
 * .domain-promo-box, .multiselect, .multiselect-filter, .no-icheck,
 * .recaptcha-container, .default-captcha, .field-error-msg.
 *}

{include file="orderforms/$carttpl/common.tpl"}

<div id="order-standard_cart">

    {* Page header banner -- eyebrow + H1 + subtitle, matches store
       layout's .st-page-header. *}
    <header class="st-page-header">
        <p class="page-eyebrow">{$LANG.cart.order|default:'Order'}</p>
        <h1>{$LANG.registerdomain}</h1>
        <p class="page-subtitle">{if $showAdvancedSearchOptions}{$LANG.orderForm.findNewDomainAi}{else}{$LANG.orderForm.findNewDomain}{/if}</p>
    </header>

    <div class="st-split">

        {* LEFT: Categories + Actions rail *}
        {include file="orderforms/$carttpl/sidebar-categories.tpl"}

        {* RIGHT: search + results *}
        <div class="dr-main" style="min-width: 0;">

            {* sidebar-categories-collapsed.tpl is deliberately NOT included
               here. Its <select>-based output relies on Bootstrap responsive
               utilities (.hidden-md / .visible-xs) to stay invisible on
               desktop, which mytheme does not load -- so the collapsed
               Categories + Actions cards leak into the main column. The
               .st-split grid handles mobile by wrapping the aside under
               the main column at 880px, so the picker is redundant. *}

            {* ---- Search card with AI/Classic mode tabs ---- *}
            <div class="dr-search domain-checker-container{if $showAdvancedSearchOptions} domain-checker-advanced{/if}"
                 data-search-mode="{if $showAdvancedSearchOptions}ai{else}classic{/if}">

                <div class="dr-mode-tabs" role="tablist" aria-label="Search mode">
                    <button type="button" class="dr-mode-tab{if $showAdvancedSearchOptions} active{/if}"
                            role="tab" data-mode="ai"
                            aria-selected="{if $showAdvancedSearchOptions}true{else}false{/if}">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M12 2l2 5 5 2-5 2-2 5-2-5-5-2 5-2z"/></svg>
                        AI Generator
                    </button>
                    <button type="button" class="dr-mode-tab{if !$showAdvancedSearchOptions} active{/if}"
                            role="tab" data-mode="classic"
                            aria-selected="{if !$showAdvancedSearchOptions}true{else}false{/if}">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
                        Classic Search
                    </button>
                </div>

                <div class="domain-checker-bg clearfix">

                    {* ---- AI form (smart / AI Generator mode) ---- *}
                    <form method="post"
                          action="{$WEB_ROOT}/cart.php"
                          class="dr-search-form"
                          data-mode-form="ai"
                          {if $showAdvancedSearchOptions}id="frmDomainChecker"{/if}>
                        <input type="hidden" name="a" value="checkDomain">

                        <div class="dr-search-box input-group input-group-lg input-group-box">
                            <svg class="dr-search-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
                            <textarea name="message"
                                      class="dr-search-input"
                                      {if $showAdvancedSearchOptions}id="message"{else}id="dr-alt-message"{/if}
                                      rows="1"
                                      title="{lang key='domainSearch.domainOrAiPrompt'}"
                                      data-placement="top"
                                      data-trigger="manual"
                                      placeholder="{lang key='domainSearch.domainOrAiInstruction'}">{if $showAdvancedSearchOptions}{$message}{/if}</textarea>
                            <button type="submit"
                                    class="dr-generate-btn{if $showAdvancedSearchOptions} domain-check-availability{$captcha->getButtonClass($captchaForm)}{/if}"
                                    {if $showAdvancedSearchOptions}id="btnCheckAvailability"{else}id="dr-alt-btnAi"{/if}>
                                {lang key='search'}
                            </button>
                        </div>

                        {* TLD multi-select + max length + safe-search --
                           rendered for AI mode regardless of which form is
                           the WHMCS-active one, but multiselect plugin only
                           wires up on the active form (see init JS at the
                           bottom which keys off `data-search-mode`). *}
                        <div class="dr-filters-row">
                            <select name="tlds[]"
                                    class="multiselect multiselect-filter dr-filter-multiselect"
                                    multiple="multiple"
                                    data-placeholder="{lang key='domainSearch.tlds'}"
                                    data-min-selection="1">
                                {foreach $tlds as $tld}
                                    <option{if in_array($tld, $selectedTlds)} selected {if count($selectedTlds) <= 1}disabled="disabled"{/if}{/if} value="{$tld}">{$tld}</option>
                                {/foreach}
                            </select>
                            <select name="maxLength" class="multiselect dr-filter-multiselect" data-placeholder="{lang key='domainSearch.maxLength'}">
                                {foreach $searchLengths as $len}
                                    <option value="{$len}" {if $maxLength === $len}selected{/if}>{$len}</option>
                                {/foreach}
                            </select>
                            <label class="dr-filter-safesearch">
                                <input type="checkbox" class="no-icheck" name="filter" {if $safeSearchSelected}checked{/if}>
                                <span>{lang key="domainSearch.safeSearch"}</span>
                            </label>
                        </div>

                        {* Captcha (only rendered for the WHMCS-active form
                           so the captcha widget JS doesn't get confused) *}
                        {if $showAdvancedSearchOptions && $captcha->isEnabled() && $captcha->isEnabledForForm($captchaForm) && !$captcha->recaptcha->isInvisible()}
                            <div class="captcha-container" id="captchaContainer">
                                {if $captcha->recaptcha->isEnabled()}
                                    <div class="text-center">
                                        <div class="form-group recaptcha-container"></div>
                                    </div>
                                {else}
                                    <div class="default-captcha default-captcha-register-margin">
                                        <p>{lang key="cartSimpleCaptcha"}</p>
                                        <div>
                                            <img id="inputCaptchaImage" src="{$systemurl}includes/verifyimage.php" align="middle" />
                                            <input id="inputCaptcha" type="text" name="code" maxlength="6" class="form-control input-sm" data-toggle="tooltip" data-placement="right" data-trigger="manual" title="{lang key='orderForm.required'}" />
                                        </div>
                                    </div>
                                {/if}
                            </div>
                        {/if}
                    </form>

                    {* ---- Classic form (single-input / Classic Search mode) ---- *}
                    <form method="post"
                          action="{$WEB_ROOT}/cart.php"
                          class="dr-search-form"
                          data-mode-form="classic"
                          {if !$showAdvancedSearchOptions}id="frmDomainChecker"{/if}>
                        <input type="hidden" name="a" value="checkDomain">

                        <div class="dr-search-box input-group input-group-lg input-group-box">
                            <svg class="dr-search-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
                            <input type="text"
                                   name="domain"
                                   class="dr-search-input form-control"
                                   {if !$showAdvancedSearchOptions}id="inputDomain"{else}id="dr-alt-domain"{/if}
                                   placeholder="{$LANG.findyourdomain}"
                                   value="{if !$showAdvancedSearchOptions}{$lookupTerm}{/if}"
                                   data-toggle="tooltip"
                                   data-placement="top"
                                   data-trigger="manual"
                                   title="{lang key='orderForm.domainOrKeyword'}" />
                            <button type="submit"
                                    class="dr-generate-btn{if !$showAdvancedSearchOptions} domain-check-availability{$captcha->getButtonClass($captchaForm)}{/if}"
                                    {if !$showAdvancedSearchOptions}id="btnCheckAvailability"{else}id="dr-alt-btnClassic"{/if}>
                                {$LANG.search}
                            </button>
                        </div>

                        {if !$showAdvancedSearchOptions && $captcha->isEnabled() && $captcha->isEnabledForForm($captchaForm) && !$captcha->recaptcha->isInvisible()}
                            <div class="captcha-container" id="captchaContainer">
                                {if $captcha->recaptcha->isEnabled()}
                                    <div class="text-center">
                                        <div class="form-group recaptcha-container"></div>
                                    </div>
                                {else}
                                    <div class="default-captcha default-captcha-register-margin">
                                        <p>{lang key="cartSimpleCaptcha"}</p>
                                        <div>
                                            <img id="inputCaptchaImage" src="{$systemurl}includes/verifyimage.php" align="middle" />
                                            <input id="inputCaptcha" type="text" name="code" maxlength="6" class="form-control input-sm" data-toggle="tooltip" data-placement="right" data-trigger="manual" title="{lang key='orderForm.required'}" />
                                        </div>
                                    </div>
                                {/if}
                            </div>
                        {/if}
                    </form>

                </div>
            </div>

            {* ---- FULL RESULTS WRAPPER ---- *}
            <div class="dr-results-full">

                {* WHMCS DomainSearchResults block -- starts hidden, AJAX
                   populates and reveals it. We wrap its sub-elements in
                   .dr-result-card for the Apple visual but keep the
                   exact element IDs / class names scripts.min.js binds. *}
                <div id="DomainSearchResults" class="w-hidden">

                    {* Section heading shown above primary result (toggled
                       by JS depending on whether result is exact or
                       suggested-primary). *}
                    <div id="primarySuggestionHeading" class="primary-domain-header dr-results-heading">
                        <i class="fa-regular fa-sparkles"></i> {$LANG.domainSearch.topSuggestion}
                    </div>
                    <div id="primaryExactHeading" class="primary-domain-header dr-results-heading">
                        {$LANG.domainSearch.exactMatch}
                    </div>

                    {* Primary result card. JS toggles which child element
                       is visible based on state (invalid / unavailable /
                       tld-unavailable / available). *}
                    <div id="searchDomainInfo" class="dr-result-card domain-checker-result-headline">
                        <p id="primaryLookupSearching" class="domain-lookup-loader domain-lookup-primary-loader domain-searching">
                            <i class="fas fa-spinner fa-spin"></i> {lang key='orderForm.searching'}...
                        </p>
                        <div id="primaryLookupResult" class="domain-lookup-result w-hidden">
                            <p class="domain-invalid domain-checker-invalid">
                                {lang key='orderForm.domainLetterOrNumber'}<span class="domain-length-restrictions">{lang key='orderForm.domainLengthRequirements'}</span>
                            </p>
                            <p class="domain-unavailable domain-checker-unavailable">{lang key='orderForm.domainIsUnavailable'}</p>
                            <p class="domain-tld-unavailable domain-checker-unavailable">{lang key='orderForm.domainHasUnavailableTld'}</p>
                            <p class="domain-available domain-checker-available">{$LANG.domainavailablemessage}</p>
                            <a class="domain-contact-support btn btn-primary">{$LANG.domainContactUs}</a>
                            <div id="idnLanguageSelector" class="form-group idn-language-selector w-hidden">
                                <div class="margin-10 text-center">
                                    {lang key='cart.idnLanguageDescription'}
                                </div>
                                <select name="idnlanguage" class="form-control">
                                    <option value="">{lang key='cart.idnLanguage'}</option>
                                    {foreach $idnLanguages as $idnLanguageKey => $idnLanguage}
                                        <option value="{$idnLanguageKey}">{lang key='idnLanguage.'|cat:$idnLanguageKey}</option>
                                    {/foreach}
                                </select>
                                <div class="field-error-msg">
                                    {lang key='cart.selectIdnLanguageForRegister'}
                                </div>
                            </div>
                            <p class="domain-price">
                                <span class="price"></span>
                                <button class="btn btn-primary btn-add-to-cart dr-add-btn" data-whois="0" data-domain="">
                                    <span class="to-add">{$LANG.addtocart}</span>
                                    <span class="loading">
                                        <i class="fas fa-spinner fa-spin"></i> {lang key='loading'}
                                    </span>
                                    <span class="added"><i class="far fa-shopping-cart"></i> {lang key='checkout'}</span>
                                    <span class="unavailable">{$LANG.domaincheckertaken}</span>
                                </button>
                            </p>
                            <p class="domain-error domain-checker-unavailable"></p>
                        </div>
                    </div>

                    {* Most popular (spotlight TLDs grid) *}
                    {if $spotlightTlds}
                        <div class="dr-section">
                            <div class="dr-section-head">
                                <h2>{$LANG.orderForm.mostPopular|default:'Most popular'}</h2>
                                <p>{$LANG.orderForm.popularTldsHint|default:'A handful of the best-known extensions for your domain.'}</p>
                            </div>
                            <div id="spotlightTlds" class="spotlight-tlds dr-popular-grid clearfix">
                                {foreach $spotlightTlds as $key => $data}
                                    <div class="spotlight-tld-container spotlight-tld-container-{$spotlightTlds|count} dr-tld-card">
                                        <div id="spotlight{$data.tldNoDots}" class="spotlight-tld">
                                            {if $data.group}
                                                <div class="dr-tld-tag dr-tld-tag-{$data.group} spotlight-tld-{$data.group}">{$data.groupDisplayName}</div>
                                            {/if}
                                            <div class="dr-tld-name">{$data.tld}</div>
                                            <span class="domain-lookup-loader domain-lookup-spotlight-loader">
                                                <i class="fas fa-spinner fa-spin"></i>
                                            </span>
                                            <div class="domain-lookup-result">
                                                <span class="dr-tld-status unavailable w-hidden" data-tld-state="unavailable">{lang key='domainunavailable'}</span>
                                                <span class="available price dr-tld-price w-hidden">{$data.register}</span>
                                                <button type="button" class="btn unavailable dr-tld-btn disabled w-hidden" disabled="disabled">
                                                    {lang key='domainunavailable'}
                                                </button>
                                                <button type="button" class="btn invalid dr-tld-btn disabled w-hidden" disabled="disabled">
                                                    {lang key='domainunavailable'}
                                                </button>
                                                <button type="button" class="btn btn-add-to-cart dr-tld-btn w-hidden" data-whois="0" data-domain="">
                                                    <span class="to-add">{lang key='orderForm.add'}</span>
                                                    <span class="loading">
                                                        <i class="fas fa-spinner fa-spin"></i> {lang key='loading'}
                                                    </span>
                                                    <span class="added"><i class="far fa-shopping-cart"></i> {lang key='checkout'}</span>
                                                    <span class="unavailable">{$LANG.domaincheckertaken}</span>
                                                </button>
                                                <button type="button" class="btn btn-primary domain-contact-support dr-tld-btn w-hidden">
                                                    {lang key='domainChecker.contactSupport'}
                                                </button>
                                            </div>
                                        </div>
                                    </div>
                                {/foreach}
                            </div>
                        </div>
                    {/if}

                    {* Suggested for you (AI / similar names) *}
                    <div class="dr-section suggested-domains{if !$showSuggestionsContainer} w-hidden{/if}">
                        <div class="dr-section-head panel-heading card-header">
                            <h2>{lang key='orderForm.suggestedDomains'}</h2>
                            <p>{$LANG.orderForm.suggestedDomainsHint|default:'Availability is checked in real time when you add to the cart.'}</p>
                        </div>
                        <div id="suggestionsLoader" class="panel-body card-body domain-lookup-loader domain-lookup-suggestions-loader">
                            <i class="fas fa-spinner fa-spin"></i> {lang key='orderForm.generatingSuggestions'}
                        </div>
                        <div class="panel-body card-body domain-lookup-message domain-lookup-suggestions-message">
                            {lang key='domainSearch.errors.noSuggestions'}
                        </div>
                        <div id="domainSuggestions" class="domain-lookup-result list-group dr-suggested-list w-hidden">
                            <div class="domain-suggestion list-group-item dr-sug-row w-hidden">
                                {* CRITICAL: this wrapper MUST be a <span>, not a <div>.
                                   scripts.js (line 3749 + 2809) resets state before every
                                   search via `suggestions.find('div:not(.actions)').hide()`
                                   which catches every <div> descendant -- a <div class="dr-sug-name">
                                   would get inline display:none stamped on it, and the
                                   .domain / .extension spans inside would render with
                                   content but be invisible because their parent is hidden. *}
                                <span class="dr-sug-name">
                                    <span class="domain"></span><span class="extension tld"></span>
                                    <span class="promo dr-sug-chip w-hidden">
                                        <span class="sales-group-hot w-hidden">{lang key='domainCheckerSalesGroup.hot'}</span>
                                        <span class="sales-group-new w-hidden">{lang key='domainCheckerSalesGroup.new'}</span>
                                        <span class="sales-group-sale w-hidden">{lang key='domainCheckerSalesGroup.sale'}</span>
                                    </span>
                                </span>
                                <div class="actions dr-sug-actions">
                                    <span class="price dr-sug-price"></span>
                                    <button type="button" class="btn btn-add-to-cart dr-add-btn outline" data-whois="1" data-domain="">
                                        <span class="to-add">{$LANG.addtocart}</span>
                                        <span class="loading">
                                            <i class="fas fa-spinner fa-spin"></i> {lang key='loading'}
                                        </span>
                                        <span class="added"><i class="far fa-shopping-cart"></i> {lang key='checkout'}</span>
                                        <span class="unavailable">{$LANG.domaincheckertaken}</span>
                                    </button>
                                    <button type="button" class="btn btn-primary domain-contact-support dr-add-btn w-hidden">
                                        {lang key='domainChecker.contactSupport'}
                                    </button>
                                </div>
                            </div>
                        </div>
                        <div class="panel-footer card-footer more-suggestions dr-more-wrap text-center w-hidden">
                            <a id="moreSuggestions" class="dr-more-link" href="#" onclick="loadMoreSuggestions();return false;">{lang key='domainsmoresuggestions'} &rsaquo;</a>
                            <span id="noMoreSuggestions" class="no-more small w-hidden">{lang key='domaincheckernomoresuggestions'}</span>
                        </div>
                        <div class="text-center domain-suggestions-warning">
                            <p>{lang key='domainssuggestionswarnings'}</p>
                        </div>
                    </div>
                </div>

                {* ---- Featured TLDs + TLD-by-category pricing table ---- *}
                <div class="domain-pricing dr-section">

                    {if $featuredTlds}
                        <div class="featured-tlds-container dr-popular-grid">
                            {foreach $featuredTlds as $num => $tldinfo}
                                <div class="featured-tld dr-tld-card">
                                    <div class="img-container">
                                        <img src="{$BASE_PATH_IMG}/tld_logos/{$tldinfo.tldNoDots}.png" alt="{$tldinfo.tld}">
                                    </div>
                                    <div class="dr-tld-name">{$tldinfo.tld}</div>
                                    <div class="price dr-tld-price {$tldinfo.tldNoDots}">
                                        {if is_object($tldinfo.register)}
                                            {$tldinfo.register->toPrefixed()}<span>{if $tldinfo.period > 1}{lang key="orderForm.shortPerYears" years={$tldinfo.period}}{else}{lang key="orderForm.shortPerYear" years=''}{/if}</span>
                                        {else}
                                            {lang key="domainregnotavailable"}
                                        {/if}
                                    </div>
                                </div>
                            {/foreach}
                        </div>
                    {/if}

                    <div class="dr-section-head" style="margin-top: 18px;">
                        <h2>{lang key='pricing.browseExtByCategory'}</h2>
                    </div>

                    <div class="tld-filters dr-tld-filters">
                        {foreach $categoriesWithCounts as $category => $count}
                            <a href="#" data-category="{$category}" class="badge badge-secondary dr-tld-filter">
                                {lang key="domainTldCategory.$category" defaultValue=$category} ({$count})
                            </a>
                        {/foreach}
                    </div>

                    <div class="dr-pricing-table bg-white">
                        <div class="row no-gutters tld-pricing-header dr-pricing-head text-center">
                            <div class="col-md-4 tld-column">{lang key='orderdomain'}</div>
                            <div class="col-md-8">
                                <div class="row no-gutters">
                                    <div class="col-xs-4 col-4">{lang key='pricing.register'}</div>
                                    <div class="col-xs-4 col-4">{lang key='pricing.transfer'}</div>
                                    <div class="col-xs-4 col-4">{lang key='pricing.renewal'}</div>
                                </div>
                            </div>
                        </div>
                        {foreach $pricing['pricing'] as $tld => $price}
                            <div class="row no-gutters tld-row dr-pricing-row" data-category="{foreach $price.categories as $category}|{$category}|{/foreach}">
                                <div class="col-md-4 two-row-center px-4">
                                    <strong>.{$tld}</strong>
                                    {if $price.group}
                                        <span class="tld-sale-group tld-sale-group-{$price.group} dr-sug-chip {$price.group}">
                                            {lang key='domainCheckerSalesGroup.'|cat:$price.group}
                                        </span>
                                    {/if}
                                </div>
                                <div class="col-md-8">
                                    <div class="row">
                                        <div class="col-xs-4 col-4 text-center">
                                            {if isset($price.register) && current($price.register) > 0}
                                                {current($price.register)}<br>
                                                <small>{key($price.register)} {if key($price.register) > 1}{lang key="orderForm.years"}{else}{lang key="orderForm.year"}{/if}</small>
                                            {elseif isset($price.register) && current($price.register) == 0}
                                                <small>{lang key='orderfree'}</small>
                                            {else}
                                                <small>{lang key='na'}</small>
                                            {/if}
                                        </div>
                                        <div class="col-xs-4 col-4 text-center">
                                            {if isset($price.transfer) && current($price.transfer) > 0}
                                                {current($price.transfer)}<br>
                                                <small>{key($price.transfer)} {if key($price.register) > 1}{lang key="orderForm.years"}{else}{lang key="orderForm.year"}{/if}</small>
                                            {elseif isset($price.transfer) && current($price.transfer) == 0}
                                                <small>{lang key='orderfree'}</small>
                                            {else}
                                                <small>{lang key='na'}</small>
                                            {/if}
                                        </div>
                                        <div class="col-xs-4 col-4 text-center">
                                            {if isset($price.renew) && current($price.renew) > 0}
                                                {current($price.renew)}<br>
                                                <small>{key($price.renew)} {if key($price.register) > 1}{lang key="orderForm.years"}{else}{lang key="orderForm.year"}{/if}</small>
                                            {elseif isset($price.renew) && current($price.renew) == 0}
                                                <small>{lang key='orderfree'}</small>
                                            {else}
                                                <small>{lang key='na'}</small>
                                            {/if}
                                        </div>
                                    </div>
                                </div>
                            </div>
                        {/foreach}
                        <div class="row tld-row dr-pricing-row no-tlds">
                            <div class="col-xs-12 col-12 text-center">
                                {lang key='pricing.selectExtCategory'}
                            </div>
                        </div>
                    </div>
                </div>

                {* ---- Transfer / hosting promo CTA strip ---- *}
                {if $domainTransferEnabled}
                    <div class="dr-transfer-cta domain-promo-box">
                        <div>
                            <div class="dr-transfer-eyebrow">{lang key='orderForm.transferToUs'}</div>
                            <h2>{lang key='orderForm.transferExtend'}</h2>
                            <p>{lang key='orderForm.extendExclusions'}</p>
                        </div>
                        <a href="{$WEB_ROOT}/cart.php?a=add&domain=transfer" class="dr-add-btn">
                            {lang key='orderForm.transferDomain'} &rsaquo;
                        </a>
                    </div>
                {/if}

                <div class="dr-transfer-cta domain-promo-box">
                    <div>
                        <div class="dr-transfer-eyebrow">{lang key='orderForm.addHosting'}</div>
                        <h2>{lang key='orderForm.chooseFromRange'}</h2>
                        <p>{lang key='orderForm.packagesForBudget'}</p>
                    </div>
                    <a href="{$WEB_ROOT}/cart.php" class="dr-add-btn">
                        {lang key='orderForm.exploreNow'} &rsaquo;
                    </a>
                </div>

            </div>{* /.dr-results-full *}

            {* ---- EMPTY STATE ---- *}
            <div class="dr-results-empty">
                <div class="dr-empty-ico">
                    <svg viewBox="0 0 24 24" width="22" height="22" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="2" y1="12" x2="22" y2="12"/><path d="M12 2a15.3 15.3 0 0 1 4 10 15.3 15.3 0 0 1-4 10 15.3 15.3 0 0 1-4-10 15.3 15.3 0 0 1 4-10z"/></svg>
                </div>
                <p class="dr-empty-title">{$LANG.orderForm.searchDomain|default:'Search a domain'}</p>
                <p class="dr-empty-desc">{$LANG.orderForm.searchDomainHint|default:'Type a domain name in the search box above to check availability.'}</p>
            </div>

        </div>
    </div>
</div>

<script>
jQuery(document).ready(function() {

    // Pre-click the first TLD-category filter so the pricing table
    // shows something on page load instead of the "select a category"
    // placeholder.
    jQuery('.tld-filters a:first-child, .dr-tld-filters a:first-child').first().click();

    {if $lookupTerm && !$captchaError && !$invalid}
        jQuery('#btnCheckAvailability').click();
    {/if}

    {if $invalid}
        jQuery('#primaryLookupSearching').toggle();
        jQuery('#primaryLookupResult').children().toggle();
        jQuery('#primaryLookupResult').toggle();
        jQuery('#DomainSearchResults').toggle();
        jQuery('.domain-invalid').toggle();
    {/if}

    // --- Flatten the AI search placeholder to a single line ---
    // WHMCS core's domainSearch.domainOrAiInstruction is a 3-line string
    // ("...domain.\nFor example: ..."), but our AI field is a single-line
    // pill (rows="1", fixed height), so lines 2-3 overflow and overlap the
    // box border. Keep only the first line. Classic mode's input has a
    // one-line placeholder, so the newline guard skips it. (We deliberately
    // do NOT touch title -- WHMCS/Bootstrap manage the prompt tooltip there.)
    jQuery('.dr-search-input').each(function () {
        var ph = this.getAttribute('placeholder') || '';
        var nl = ph.search(/\r?\n/);
        if (nl === -1) return;
        this.setAttribute('placeholder', ph.slice(0, nl).trim());
    });

    // --- AI / Classic mode tab switcher ---
    // The .dr-search container carries data-search-mode="ai|classic".
    // Tab click flips it; CSS hides the inactive form.
    jQuery('.dr-mode-tabs .dr-mode-tab').on('click', function () {
        var $btn = jQuery(this);
        var mode = $btn.data('mode');
        var $tabs = $btn.closest('.dr-mode-tabs');
        var $card = $btn.closest('.dr-search');

        $tabs.find('.dr-mode-tab').removeClass('active').attr('aria-selected', 'false');
        $btn.addClass('active').attr('aria-selected', 'true');
        $card.attr('data-search-mode', mode);

        // Focus the visible mode's primary input so typing continues
        // naturally after the user swaps.
        setTimeout(function () {
            $card.find('[data-mode-form="' + mode + '"] .dr-search-input').first().focus();
        }, 60);
    });

    // --- Inactive-mode form submit bridge ---
    // scripts.min.js only AJAX-binds to the form WHMCS chose server-side
    // (the one carrying id="frmDomainChecker" / id="btnCheckAvailability").
    // The other form has dr-alt-* IDs and would submit as a plain HTML
    // POST to cart.php?a=checkDomain -- which returns raw JSON and the
    // browser renders the JSON instead of the search results. Intercept
    // the alt form's submit, copy its query into the WHMCS-active form,
    // and trigger its bound AJAX flow so both tabs share the same
    // result-rendering pipeline.
    jQuery('.dr-search-form').on('submit', function (e) {
        var $form = jQuery(this);
        // The WHMCS-bound form is the one carrying #btnCheckAvailability.
        // If we're submitting it directly, let scripts.min.js handle it.
        if ($form.find('#btnCheckAvailability').length) return;

        e.preventDefault();
        var query = $form.find('.dr-search-input').val();
        if (!query || !query.trim()) {
            $form.find('.dr-search-input').focus();
            return;
        }

        // Find the WHMCS-active form (the one with #btnCheckAvailability)
        // and copy our query into its primary input (#message for AI,
        // #inputDomain for Classic -- whichever WHMCS rendered as active).
        var $activeInput = jQuery('#message, #inputDomain').first();
        if (!$activeInput.length) return;
        $activeInput.val(query);

        // Fire scripts.min.js's bound click handler on the search button.
        jQuery('#btnCheckAvailability').click();
    });
});

{if $showAdvancedSearchOptions}
    // Multi-select TLD picker -- only initialize on the WHMCS-active
    // (#frmDomainChecker) form. The alt-mode form's <select multiple>
    // (if it had one) would stay as the native browser control.
    $(document).ready(function() {
        jQuery('#frmDomainChecker .multiselect').each(function () {
            const enableFiltering = $(this).hasClass('multiselect-filter');
            const minSelection = jQuery(this).data('min-selection');
            $(this).multiselect({
                onChange: function (element) {
                    const closestSelect = element.closest('select');
                    const selectedOptions = closestSelect.find('option:selected');
                    if (minSelection === undefined) {
                        return;
                    }
                    const atMinOptions = selectedOptions.length <= minSelection;
                    const targetOptions = atMinOptions ? selectedOptions : closestSelect.find('option');
                    targetOptions.each(function () {
                        const inputElement = jQuery('input[value="' + jQuery(this).val() + '"]');
                        inputElement.prop('disabled', atMinOptions ? 'disabled' : false);
                    });
                },
                buttonText: function(options, select) {
                    return select.data('placeholder');
                },
                maxHeight: 200,
                includeFilterClearBtn: false,
                enableCaseInsensitiveFiltering: enableFiltering,
            });
        });
    });
{/if}
</script>
