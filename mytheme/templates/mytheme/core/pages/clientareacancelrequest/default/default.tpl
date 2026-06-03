{* Hostnodes - Cancel service request (Apple-style).

   WHMCS variables (cross-checked against Lagom clientareacancelrequest.tpl):
     $invalid    - bool: invalid product
     $requested  - bool: cancellation submitted (confirmation)
     $error      - bool: reason required validation error
     $id         - service id
     $groupname, $productname, $domain
     $domainid, $domainnextduedate, $domainprice, $domainregperiod (if a domain is attached)
   Form: POST clientarea.php?action=cancel&id={id}, sub=submit, cancellationreason,
         type (Immediate | End of Billing Period), canceldomain.
   Demo data under ?preview=1.
*}

{assign var=isPreview value=false}
{if isset($smarty.get.preview) && $smarty.get.preview == '1'}{assign var=isPreview value=true}{/if}

{assign var=crInvalid value=false}
{if isset($invalid) && $invalid}{assign var=crInvalid value=true}{/if}
{assign var=crRequested value=false}
{if isset($requested) && $requested}{assign var=crRequested value=true}{/if}

{assign var=crDemo value=false}
{if $isPreview && !$crInvalid && !$crRequested && !isset($productname)}
    {assign var=crDemo value=true}
    {assign var=id value=1}
    {assign var=groupname value='Cloud Hosting'}
    {assign var=productname value='Business Cloud Pro'}
    {assign var=domain value='hendersondesign.com'}
{/if}

{if $crInvalid}{assign var=dashIsEmpty value='empty'}{else}{assign var=dashIsEmpty value='full'}{/if}

<link rel="stylesheet" href="{$WEB_ROOT}/templates/{$template}/assets/css/pages/clientareacancelrequest.css?v={$myTheme.version|default:'1.0'}">

<script>
(function () {
    var b = document.body;
    if (!b) return;
    b.setAttribute('data-data',   '{$dashIsEmpty}');
    b.setAttribute('data-subnav', 'off');
})();
</script>

<header class="page-header">
    <p class="page-eyebrow">{$LANG.clientareacancelproduct}</p>
    <h1>{$hadrianLang.billing.cancelRequestTitle}</h1>
    <p class="page-subtitle">{$hadrianLang.billing.cancelRequestSubtitle}</p>
</header>

{if $crRequested}
<div class="cr-wrap">
    <div class="cr-notice">
        <div class="cr-notice-ico ok">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M22 11.08V12a10 10 0 11-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg>
        </div>
        <p class="cr-notice-title">{$LANG.clientareacancelconfirmation}</p>
        <p class="cr-notice-sub">{$hadrianLang.billing.cancelConfirmationSub}</p>
        <a href="{$WEB_ROOT}/clientarea.php?action=productdetails&amp;id={$id|default:''|escape}" class="btn-primary">{$LANG.clientareabacklink}</a>
    </div>
</div>

{elseif $crInvalid}
<div class="cr-wrap">
    <div class="cr-notice">
        <div class="cr-notice-ico">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="15" y1="9" x2="9" y2="15"/><line x1="9" y1="9" x2="15" y2="15"/></svg>
        </div>
        <p class="cr-notice-title">{$hadrianLang.billing.cancelInvalidTitle}</p>
        <p class="cr-notice-sub">{$LANG.clientareacancelinvalid}</p>
        <a href="{$WEB_ROOT}/clientarea.php?action=services" class="btn-primary">{$LANG.clientareanavservices}</a>
    </div>
</div>

{else}
<div class="when-full">
<div class="cr-wrap">

    <div class="cr-callout">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M10.29 3.86L1.82 18a2 2 0 001.71 3h16.94a2 2 0 001.71-3L13.71 3.86a2 2 0 00-3.42 0z"/><line x1="12" y1="9" x2="12" y2="13"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg>
        <div class="cr-callout-text">{$hadrianLang.billing.cancelWarning}</div>
    </div>

    {if isset($error) && $error}
    <div class="cr-callout" style="background: var(--color-red-bg); color: var(--color-red-text);">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
        <div class="cr-callout-text">{$LANG.clientareacancelreasonrequired}</div>
    </div>
    {/if}

    <div class="card">
        <div class="card-body">
            <form method="post" action="{$WEB_ROOT}/clientarea.php?action=cancel&amp;id={$id|default:''|escape}">
                <input type="hidden" name="sub" value="submit">

                <div class="form-group">
                    <label class="form-label">{$LANG.clientareacancelproduct}</label>
                    <div class="cr-service">
                        <div class="cr-service-ico">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round"><rect x="2" y="2" width="20" height="8" rx="2"/><rect x="2" y="14" width="20" height="8" rx="2"/><line x1="6" y1="6" x2="6.01" y2="6"/><line x1="6" y1="18" x2="6.01" y2="18"/></svg>
                        </div>
                        <div>
                            <div class="cr-service-name">{$groupname|default:''|escape}{if isset($productname)} - {$productname|escape}{/if}</div>
                            {if isset($domain) && $domain}<div class="cr-service-domain">{$domain|escape}</div>{/if}
                        </div>
                    </div>
                </div>

                {if isset($domainid) && $domainid}
                <div class="form-group">
                    <label class="form-label">{$LANG.cancelrequestdomain}</label>
                    <label class="cr-check">
                        <input type="checkbox" name="canceldomain" id="canceldomain" value="1">
                        <span>{$LANG.cancelrequestdomainconfirm}{if isset($domainnextduedate)} <span style="color:var(--color-text-tertiary);">({$domainnextduedate|escape})</span>{/if}</span>
                    </label>
                </div>
                {/if}

                <div class="form-group">
                    <label class="form-label" for="type">{$LANG.clientareacancellationtype}</label>
                    <select name="type" id="type" class="form-select">
                        <option value="End of Billing Period">{$LANG.clientareacancellationendofbillingperiod}</option>
                        <option value="Immediate">{$LANG.clientareacancellationimmediate}</option>
                    </select>
                </div>

                <div class="form-group">
                    <label class="form-label" for="cancellationreason">{$LANG.clientareacancelreason}</label>
                    <textarea name="cancellationreason" id="cancellationreason" class="form-textarea" rows="5" placeholder="{$hadrianLang.billing.cancelReasonPlaceholder}"></textarea>
                </div>

                <div class="btn-group">
                    <button type="submit" class="btn-danger">{$LANG.clientareacancelrequestbutton}</button>
                    <a href="{$WEB_ROOT}/clientarea.php?action=productdetails&amp;id={$id|default:''|escape}" class="btn-secondary">{$hadrianLang.billing.keepService}</a>
                </div>
            </form>
        </div>
    </div>
</div>
</div>
{/if}
