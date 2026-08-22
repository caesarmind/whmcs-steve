{* Hostnodes — Domain Contact Info / WHOIS.

   WHMCS variables:
     $domain, $domainid
     $contactdetails (assoc map: 'Registrant' => {firstname:..., lastname:..., ...}, 'Admin' => {...}, 'Tech' => {...}, 'Billing' => {...})
     $contactdetailstranslations (assoc map: 'firstname' => 'First Name', ...)
     $contacts (array of saved contacts on the account)
     $clientsdetails.userid
     $successful (bool), $error (string), $pending (bool), $pendingMessage
*}

<link rel="stylesheet" href="{$WEB_ROOT}/templates/{$template}/assets/css/pages/clientareadomaincontactinfo.css?v={$hadrian.version|default:'1.0'}">

<header class="page-header">
    <p class="page-eyebrow">{$domain|default:''|escape}</p>
    <h1>{$LANG.domaincontactinfo}</h1>
    <p class="page-subtitle">{$LANG.whoisContactWarning}</p>
</header>

{if !empty($successful)}
<div class="ci-alert ci-alert-success">
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"/></svg>
    <div>{$LANG.changessavedsuccessfully}</div>
</div>
{/if}

{if !empty($pending)}
<div class="ci-alert ci-alert-info">
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
    <div>{$pendingMessage|default:$hadrianLang.domains.contactPending}</div>
</div>
{/if}

{if !empty($error)}
<div class="ci-alert ci-alert-error">
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/></svg>
    <div>{$error|escape}</div>
</div>
{/if}

<div class="ci-split">
    <div class="ci-main">

        <form method="post" action="{$smarty.server.PHP_SELF}?action=domaincontacts" id="frmDomainContactModification" class="card ci-card">
            <input type="hidden" name="token" value="{$token|default:''|escape}">
            <input type="hidden" name="sub" value="save">
            <input type="hidden" name="domainid" value="{$domainid|escape}">

            {if isset($contactdetails) && $contactdetails|@count > 0}
            <div class="ci-tabs" role="tablist">
                {foreach $contactdetails as $category => $values}
                    <button type="button" class="ci-tab{if $values@first} active{/if}" data-ci-tab="{$category|escape}">{$category|escape}</button>
                {/foreach}
            </div>

            {foreach $contactdetails as $category => $values}
                <div class="ci-panel{if $values@first} active{/if}" data-ci-panel="{$category|escape}">

                    <div class="ci-source-row">
                        <label class="ci-radio">
                            <input type="radio" name="wc[{$category|escape}]" value="contact" data-ci-source="contact" data-ci-cat="{$category|escape}">
                            <span>{$LANG.domaincontactusexisting}</span>
                        </label>
                        <label class="ci-radio">
                            <input type="radio" name="wc[{$category|escape}]" value="custom" data-ci-source="custom" data-ci-cat="{$category|escape}" checked>
                            <span>{$LANG.domaincontactusecustom}</span>
                        </label>
                    </div>

                    <div class="ci-contact-select" data-ci-cat-select="{$category|escape}" hidden>
                        <label class="ci-label">{$LANG.domaincontactchoose}</label>
                        <select name="sel[{$category|escape}]" class="ci-input">
                            <option value="u{$clientsdetails.userid|escape}">{$LANG.domaincontactprimary}</option>
                            {if isset($contacts) && $contacts|@count > 0}
                                {foreach $contacts as $contact}
                                    <option value="c{$contact.id|escape}">{$contact.name|default:''|escape}</option>
                                {/foreach}
                            {/if}
                        </select>
                    </div>

                    <div class="ci-fields" data-ci-cat-fields="{$category|escape}">
                        <div class="ci-fields-grid">
                            {foreach $values as $fieldName => $fieldValue}
                                <div class="ci-field {if $fieldName eq 'address1' or $fieldName eq 'address2' or $fieldName eq 'fullphonenumber'}ci-field-wide{/if}">
                                    <label class="ci-label">{$contactdetailstranslations[$fieldName]|default:$fieldName|escape}</label>
                                    <input type="text" name="contactdetails[{$category|escape}][{$fieldName|escape}]" value="{$fieldValue|default:''|escape}" class="ci-input">
                                </div>
                            {/foreach}
                        </div>
                    </div>
                </div>
            {/foreach}

            <div class="ci-actions">
                <button type="submit" class="btn-primary">{$LANG.clientareasavechanges}</button>
                <a href="{$WEB_ROOT}/clientarea.php?action=domaindetails&id={$domainid|escape}" class="btn-secondary">{$LANG.clientareacancel}</a>
            </div>
            {else}
                <p class="ci-empty">{$hadrianLang.domains.noContactDetails}</p>
            {/if}
        </form>

    </div>

    <aside class="ci-aside">
        <div class="card subnav-card">
            <div class="subnav-heading">{$LANG.domain|default:'Domain'}</div>
            <a href="{$WEB_ROOT}/clientarea.php?action=domaindetails&id={$domainid|escape}" class="subnav-item">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><polyline points="15 18 9 12 15 6"/></svg>
                {$hadrianLang.domains.domainDetails}
            </a>
            <a href="{$WEB_ROOT}/clientarea.php?action=domaincontacts&domainid={$domainid|escape}" class="subnav-item active">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M20 21v-2a4 4 0 00-4-4H8a4 4 0 00-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
                {$hadrianLang.domains.whoisContact}
            </a>
        </div>
    </aside>
</div>

<script>{literal}
(function(){
    // Tab switching
    var tabs = document.querySelectorAll('[data-ci-tab]');
    var panels = document.querySelectorAll('[data-ci-panel]');
    tabs.forEach(function(t){
        t.addEventListener('click', function(){
            var name = t.getAttribute('data-ci-tab');
            tabs.forEach(function(x){ x.classList.toggle('active', x.getAttribute('data-ci-tab') === name); });
            panels.forEach(function(p){ p.classList.toggle('active', p.getAttribute('data-ci-panel') === name); });
        });
    });
    // Toggle existing-contact vs custom fields per category
    document.querySelectorAll('[data-ci-source]').forEach(function(r){
        r.addEventListener('change', function(){
            var cat = r.getAttribute('data-ci-cat');
            var src = r.getAttribute('data-ci-source');
            var sel = document.querySelector('[data-ci-cat-select="' + cat + '"]');
            var fields = document.querySelector('[data-ci-cat-fields="' + cat + '"]');
            if (sel) sel.hidden = (src !== 'contact');
            if (fields) fields.style.opacity = (src === 'contact') ? '0.5' : '1';
            if (fields) fields.querySelectorAll('input').forEach(function(i){ i.disabled = (src === 'contact'); });
        });
    });
})();
{/literal}</script>
