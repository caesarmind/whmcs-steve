{* Store landing - Order. Configure Your Order.
   Ported from apple-client-area/store/order.html (the single-product order
   configuration screen: product config + addons + order summary + checkout).
   header.tpl/footer.tpl already provide html/head/nav/breadcrumb/footer + the
   .content-area wrapper, so we emit only the inner content (page-header +
   when-full order form + when-empty "nothing to configure" state).

   Real data: the WHMCS cart "cart-order" route assigns $product (with
   ->name / ->description / ->pricing()->allAvailableCycles()), $requireDomain,
   $domains, $configurationFields, $configValidationMessage, $orderFormData,
   $requestedCycle, $loggedin + $inPreview - same contract as six/store/order.tpl.
   We wire the billing-cycle select, domain field, config fields and the
   add-to-cart form to that real data, falling back to the mockup's static
   SSL-certificate example when no $product is assigned (admin preview / demo).
   Static prose is tokenized into the hadrianLang store group (ord-prefixed
   keys); SVG icons are kept verbatim from the mockup. *}

{* Resolve data state: full when we have a real product to configure (or are in
   admin preview), else the graceful "nothing to order" empty state. *}
{if isset($product) || (isset($inPreview) && $inPreview)}
    {assign var=storeIsEmpty value='full'}
{else}
    {assign var=storeIsEmpty value='empty'}
{/if}

<header class="page-header">
    <p class="page-eyebrow">{$hadrianLang.store.ordEyebrow}</p>
    <h1>{if isset($product)}{$product->name}{else}{$hadrianLang.store.ordPageTitle}{/if}</h1>
    <p class="page-subtitle">{$hadrianLang.store.ordPageSubtitle}</p>
</header>

{* Hand the resolved data state to the body - the global rule in
   core-layout.css (body[data-data="empty"] .when-full / .when-empty) keys off
   it; the preview chip can override under ?preview=1. *}
<script>
(function () {
    var b = document.body;
    if (!b) return;
    b.setAttribute('data-data', '{$storeIsEmpty}');
    b.setAttribute('data-svc-layout', 'inside');
})();
</script>

<div class="when-full" style="max-width:1024px;margin:0 auto;">

    {* Server-side config validation message (real data only). *}
    {if isset($configValidationMessage) && $configValidationMessage}
        <div class="callout danger" style="margin-bottom:20px;">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="width:20px;height:20px;flex-shrink:0"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
            {$configValidationMessage}
        </div>
    {/if}

    <div class="callout info">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="width:20px;height:20px;flex-shrink:0"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
        {if isset($product)}
            {$hadrianLang.store.ordCalloutLead} {$product->name}. {$hadrianLang.store.ordCalloutTail}
        {else}
            {$hadrianLang.store.ordCalloutDemo}
        {/if}
    </div>

    {if isset($product)}
        {* ---- Real WHMCS add-to-cart form ---- *}
        <form method="post" action="{routePath('cart-order-addtocart')}" id="frmAddToCart">
            <input type="hidden" name="pid" value="{$product->id}">
            <input type="hidden" name="domain_type" value="" id="inputDomainType">

            <div class="card">
                <div class="card-header">
                    <h2 class="card-title">{$hadrianLang.store.ordConfigTitle}</h2>
                </div>
                <div class="card-body">
                    {if $product->description}
                        <p style="color:var(--color-text-secondary);margin:0 0 20px;line-height:1.5;">{$product->description}</p>
                    {/if}

                    <div class="form-group">
                        <label class="form-label">{$hadrianLang.store.ordBillingCycle}</label>
                        <select class="form-select" name="billingcycle">
                            {foreach $product->pricing()->allAvailableCycles() as $pricing}
                                <option value="{$pricing->cycle()}"{if (isset($orderFormData.billingcycle) && $orderFormData.billingcycle == $pricing->cycle()) || (!isset($orderFormData.billingcycle) && isset($requestedCycle) && $requestedCycle == $pricing->cycle())} selected{/if}>
                                    {if $pricing->isRecurring()}
                                        {if $pricing->isYearly()}{$pricing->cycleInYears()} &mdash; {$pricing->yearlyPrice()}{else}{$pricing->cycleInMonths()} &mdash; {$pricing->monthlyPrice()}{/if}
                                    {else}
                                        {$pricing->toFullString()}
                                    {/if}
                                </option>
                            {/foreach}
                        </select>
                    </div>

                    {if isset($requireDomain) && $requireDomain}
                        <div class="form-group">
                            <label class="form-label">{$hadrianLang.store.ordDomainLabel}</label>
                            <input type="text" class="form-input domain-input" name="custom_domain" placeholder="{$hadrianLang.store.ordDomainPlaceholder}" value="{if isset($orderFormData.custom_domain)}{$orderFormData.custom_domain}{elseif isset($customDomain)}{$customDomain}{/if}">
                            <div class="form-hint">{$hadrianLang.store.ordDomainHint}</div>
                        </div>
                    {/if}
                </div>
            </div>

            {* Real product configurable options / config fields. *}
            {if isset($configurationFields) && $configurationFields && count($configurationFields) > 0}
                <div class="card">
                    <div class="card-header">
                        <h2 class="card-title">{$hadrianLang.store.ordOptionsTitle}</h2>
                    </div>
                    <div class="card-body">
                        {foreach $configurationFields as $field}
                            {if $field.type != 'domain'}
                                <div class="form-group">
                                    <label class="form-label" for="config_{$field.name}">
                                        {$field.label}{if $field.required} <span style="color:var(--color-danger,#ff3b30)">*</span>{/if}
                                    </label>
                                    {if $field.type == 'select'}
                                        {include file="$template/store/config-fields/select.tpl" field=$field}
                                    {elseif $field.type == 'textarea'}
                                        {include file="$template/store/config-fields/textarea.tpl" field=$field}
                                    {elseif $field.type == 'boolean'}
                                        {include file="$template/store/config-fields/boolean.tpl" field=$field}
                                    {else}
                                        {include file="$template/store/config-fields/input.tpl" field=$field}
                                    {/if}
                                    {if isset($configFieldErrors) && $configFieldErrors && $configFieldErrors[$field.name]}
                                        <div class="form-hint" style="color:var(--color-danger,#ff3b30)">
                                            {foreach $configFieldErrors[$field.name] as $error}{$error}<br>{/foreach}
                                        </div>
                                    {/if}
                                </div>
                            {/if}
                        {/foreach}
                    </div>
                </div>
            {/if}

            <div style="display:flex;flex-direction:column;gap:12px;margin-top:8px">
                <button type="submit" name="checkout" value="1" class="btn-primary btn-lg" style="width:100%">{$hadrianLang.store.ordCheckout}</button>
                <button type="submit" name="continue" value="1" class="btn-secondary" style="width:100%;text-align:center">{$hadrianLang.store.ordContinue}</button>
            </div>
        </form>
    {else}
        {* ---- Static mockup demo (admin preview / no product assigned) ---- *}
        <div class="card">
            <div class="card-header">
                <h2 class="card-title">{$hadrianLang.store.ordConfigTitle}</h2>
            </div>
            <div class="card-body">
                <div class="form-group">
                    <label class="form-label">{$hadrianLang.store.ordBillingCycle}</label>
                    <select class="form-select">
                        <option>{$hadrianLang.store.ordCycleMonthly}</option>
                        <option selected>{$hadrianLang.store.ordCycleAnnually}</option>
                        <option>{$hadrianLang.store.ordCycleBiennially}</option>
                    </select>
                </div>
                <div class="form-group">
                    <label class="form-label">{$hadrianLang.store.ordDomainLabel}</label>
                    <input type="text" class="form-input" placeholder="{$hadrianLang.store.ordDomainPlaceholder}">
                    <div class="form-hint">{$hadrianLang.store.ordDomainHint}</div>
                </div>
                <div class="form-row">
                    <div class="form-group">
                        <label class="form-label">{$hadrianLang.store.ordServerType}</label>
                        <select class="form-select">
                            <option>Apache + mod_ssl</option>
                            <option>Nginx</option>
                            <option>IIS</option>
                            <option>{$hadrianLang.store.ordServerOther}</option>
                        </select>
                    </div>
                    <div class="form-group">
                        <label class="form-label">{$hadrianLang.store.ordCsrLabel}</label>
                        <textarea class="form-input" placeholder="{$hadrianLang.store.ordCsrPlaceholder}" style="min-height:100px"></textarea>
                    </div>
                </div>
            </div>
        </div>

        <div class="card">
            <div class="card-header">
                <h2 class="card-title">{$hadrianLang.store.ordAddonsTitle}</h2>
            </div>
            <div class="card-body">
                <div class="settings-item">
                    <div class="settings-item-info">
                        <div class="settings-item-label">{$hadrianLang.store.ordAddon1Label}</div>
                        <div class="settings-item-desc">{$hadrianLang.store.ordAddon1Price}</div>
                    </div>
                    <div class="toggle-switch" onclick="this.classList.toggle('active')"></div>
                </div>
                <div class="settings-item">
                    <div class="settings-item-info">
                        <div class="settings-item-label">{$hadrianLang.store.ordAddon2Label}</div>
                        <div class="settings-item-desc">{$hadrianLang.store.ordAddon2Price}</div>
                    </div>
                    <div class="toggle-switch" onclick="this.classList.toggle('active')"></div>
                </div>
                <div class="settings-item">
                    <div class="settings-item-info">
                        <div class="settings-item-label">{$hadrianLang.store.ordAddon3Label}</div>
                        <div class="settings-item-desc">{$hadrianLang.store.ordAddon3Price}</div>
                    </div>
                    <div class="toggle-switch" onclick="this.classList.toggle('active')"></div>
                </div>
            </div>
        </div>

        <div class="card">
            <div class="card-header">
                <h2 class="card-title">{$hadrianLang.store.ordSummaryTitle}</h2>
            </div>
            <div class="card-body">
                <table class="invoice-table">
                    <thead>
                        <tr>
                            <th>{$hadrianLang.store.ordSummaryDesc}</th>
                            <th style="text-align:right">{$hadrianLang.store.ordSummaryAmount}</th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr>
                            <td>{$hadrianLang.store.ordSummaryLine}</td>
                            <td style="text-align:right">$49.99</td>
                        </tr>
                    </tbody>
                </table>
                <div class="invoice-total-row">
                    <span>{$hadrianLang.store.ordSummarySubtotal}</span>
                    <span>$49.99</span>
                </div>
                <div class="invoice-total-row">
                    <span>{$hadrianLang.store.ordSummaryTax}</span>
                    <span>$0.00</span>
                </div>
                <div class="invoice-total-row grand">
                    <span>{$hadrianLang.store.ordSummaryTotal}</span>
                    <span>$49.99</span>
                </div>
                <div class="form-group" style="margin-top:20px">
                    <label class="form-label">{$hadrianLang.store.ordPromoLabel}</label>
                    <div class="form-row">
                        <input type="text" class="form-input" placeholder="{$hadrianLang.store.ordPromoPlaceholder}">
                        <button class="btn-secondary">{$hadrianLang.store.ordPromoApply}</button>
                    </div>
                </div>
            </div>
        </div>

        <div style="display:flex;flex-direction:column;gap:12px;margin-top:8px">
            <button class="btn-primary btn-lg" style="width:100%">{$hadrianLang.store.ordCheckout}</button>
            <a href="{$WEB_ROOT}/cart.php" class="btn-secondary" style="width:100%;text-align:center">{$hadrianLang.store.ordContinue}</a>
        </div>
    {/if}
</div>

<div class="when-empty" style="text-align:center;padding:60px 24px;background:var(--color-surface);border:1px solid var(--color-border);border-radius:14px;">
    <div style="width:56px;height:56px;border-radius:50%;background:var(--color-bg);display:inline-flex;align-items:center;justify-content:center;margin-bottom:16px;color:var(--color-text-tertiary);">
        <svg viewBox="0 0 24 24" width="22" height="22" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="9" cy="21" r="1"/><circle cx="20" cy="21" r="1"/><path d="M1 1h4l2.68 13.39a2 2 0 0 0 2 1.61h9.72a2 2 0 0 0 2-1.61L23 6H6"/></svg>
    </div>
    <p style="font-size:17px;font-weight:600;color:var(--color-text-primary);margin:0 0 6px;">{$hadrianLang.store.ordEmptyTitle}</p>
    <p style="font-size:14px;color:var(--color-text-secondary);margin:0 0 20px;max-width:380px;margin-left:auto;margin-right:auto;line-height:1.5;">{$hadrianLang.store.ordEmptyText}</p>
    <a href="{$WEB_ROOT}/cart.php" class="btn-primary">{$hadrianLang.store.ordEmptyBrowse}</a>
</div>
