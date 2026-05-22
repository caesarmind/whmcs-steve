{* Hostnodes - Bulk domain management (Apple-style).

   WHMCS variables (cross-checked against Lagom bulkdomainmanagement.tpl):
     $update    - 'nameservers' | 'autorenew' | 'reglock' | 'contactinfo'
     $domainids - selected domain ids (carried as domids[])
     $domains   - selected domain names (display)
     $defaultns - bool (nameservers mode)   $ns1..$ns5 - nameserver values
     $save      - bool (a save just happened)   $errors - array of error strings
   Form posts to clientarea.php?action=bulkdomain. The contactinfo mode (per-contact
   whois) is directed to per-domain editing. Demo data under ?preview=1.
*}

{assign var=isPreview value=false}
{if isset($smarty.get.preview) && $smarty.get.preview == '1'}{assign var=isPreview value=true}{/if}

{assign var=bdmUpdate value=$update|default:''}
{assign var=hasDomains value=false}
{if isset($domains) && $domains|@count > 0}{assign var=hasDomains value=true}{/if}

{assign var=bdmDemo value=false}
{if !$hasDomains && $isPreview}
    {assign var=bdmDemo value=true}
    {assign var=bdmUpdate value='nameservers'}
    {assign var=domains value=['hendersondesign.com','alexhenderson.io','myportfolio.dev']}
    {assign var=defaultns value=false}
    {assign var=hasDomains value=true}
{/if}

{if $hasDomains}{assign var=dashIsEmpty value='full'}{else}{assign var=dashIsEmpty value='empty'}{/if}

<link rel="stylesheet" href="{$WEB_ROOT}/templates/{$template}/assets/css/pages/bulkdomainmanagement.css?v={$myTheme.version|default:'1.0'}">

<script>
(function () {
    var b = document.body;
    if (!b) return;
    b.setAttribute('data-data',   '{$dashIsEmpty}');
    b.setAttribute('data-subnav', 'off');
})();
</script>

<header class="page-header">
    <p class="page-eyebrow">{$LANG.domains|default:'Domains'}</p>
    <h1>{$LANG.domainbulkmanagement|default:'Bulk domain management'}</h1>
    <p class="page-subtitle">{$LANG.domainbulkmanagementintro|default:'Apply a change to all the domains you selected at once.'}</p>
</header>

{if $hasDomains}
<div class="when-full">
<div class="bdm-wrap">

    {if isset($save) && $save}
        {if isset($errors) && $errors|@count > 0}
        <div class="bdm-alert error">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
            <div>{$LANG.clientareaerrors|default:'Please fix the following:'}<ul>{foreach $errors as $error}<li>{$error|strip_tags}</li>{/foreach}</ul></div>
        </div>
        {else}
        <div class="bdm-alert success">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M22 11.08V12a10 10 0 11-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg>
            <div>{$LANG.changessavedsuccessfully|default:'Changes saved successfully.'}</div>
        </div>
        {/if}
    {/if}

    <p class="bdm-domains-label">{$LANG.domainbulkmanagementchangesaffect|default:'These changes will affect'}:</p>
    <div class="bdm-domains">
        {foreach $domains as $domain}
        <span class="bdm-domain-item">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"/></svg>
            {$domain|escape}
        </span>
        {/foreach}
    </div>

    <form method="post" action="{$WEB_ROOT}/clientarea.php?action=bulkdomain">
        <input type="hidden" name="update" value="{$bdmUpdate|escape}">
        <input type="hidden" name="save" value="1">
        {if isset($domainids)}{foreach $domainids as $domainid}<input type="hidden" name="domids[]" value="{$domainid|escape}">{/foreach}{/if}

        <div class="card">
            <div class="card-body">
            {if $bdmUpdate == 'nameservers'}
                <h2 class="card-title" style="font-size:16px;margin-bottom:14px;">{$LANG.changenameservers|default:'Change nameservers'}</h2>
                <div class="bdm-choice">
                    <label class="bdm-radio{if isset($defaultns) && $defaultns} checked{/if}">
                        <input type="radio" name="nschoice" value="default"{if isset($defaultns) && $defaultns} checked{/if} data-ns="default">
                        <span class="bdm-radio-title">{$LANG.nschoicedefault|default:'Use default nameservers'}</span>
                    </label>
                    <label class="bdm-radio{if !(isset($defaultns) && $defaultns)} checked{/if}">
                        <input type="radio" name="nschoice" value="custom"{if !(isset($defaultns) && $defaultns)} checked{/if} data-ns="custom">
                        <span class="bdm-radio-title">{$LANG.nschoicecustom|default:'Use custom nameservers'}</span>
                    </label>
                </div>
                <div class="bdm-ns-fields{if !(isset($defaultns) && $defaultns)} show{/if}" id="bdmNsFields">
                    <div class="form-group"><label class="form-label" for="ns1">{$LANG.clientareanameserver|default:'Nameserver'} 1</label><input type="text" class="form-input" id="ns1" name="ns1" value="{$ns1|default:''|escape}"></div>
                    <div class="form-group"><label class="form-label" for="ns2">{$LANG.clientareanameserver|default:'Nameserver'} 2</label><input type="text" class="form-input" id="ns2" name="ns2" value="{$ns2|default:''|escape}"></div>
                    <div class="form-group"><label class="form-label" for="ns3">{$LANG.clientareanameserver|default:'Nameserver'} 3</label><input type="text" class="form-input" id="ns3" name="ns3" value="{$ns3|default:''|escape}"></div>
                    <div class="form-group"><label class="form-label" for="ns4">{$LANG.clientareanameserver|default:'Nameserver'} 4</label><input type="text" class="form-input" id="ns4" name="ns4" value="{$ns4|default:''|escape}"></div>
                    <div class="form-group"><label class="form-label" for="ns5">{$LANG.clientareanameserver|default:'Nameserver'} 5</label><input type="text" class="form-input" id="ns5" name="ns5" value="{$ns5|default:''|escape}"></div>
                </div>
                <div class="bdm-actions">
                    <button type="submit" class="btn-primary">{$LANG.changenameservers|default:'Change nameservers'}</button>
                    <a href="{$WEB_ROOT}/clientarea.php?action=domains" class="btn-secondary">{$LANG.cancel|default:'Cancel'}</a>
                </div>

            {elseif $bdmUpdate == 'autorenew'}
                <h2 class="card-title" style="font-size:16px;margin-bottom:8px;">{$LANG.domainsautorenew|default:'Auto-renew'}</h2>
                <div class="bdm-alert info"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg><div>{$LANG.domainautorenewrecommend|default:'We recommend keeping auto-renew enabled so your domains never expire.'}</div></div>
                <div class="bdm-actions">
                    <button type="submit" name="enable" value="1" class="btn-primary">{$LANG.domainsautorenewenable|default:'Enable auto-renew'}</button>
                    <span class="bdm-or">{$LANG.or|default:'or'}</span>
                    <button type="submit" name="disable" value="1" class="btn-secondary">{$LANG.domainsautorenewdisable|default:'Disable auto-renew'}</button>
                </div>

            {elseif $bdmUpdate == 'reglock'}
                <h2 class="card-title" style="font-size:16px;margin-bottom:8px;">{$LANG.domainregistrarlock|default:'Registrar lock'}</h2>
                <div class="bdm-alert info"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="11" width="18" height="11" rx="2"/><path d="M7 11V7a5 5 0 0110 0v4"/></svg><div>{$LANG.domainreglockrecommend|default:'Registrar lock helps prevent unauthorized domain transfers.'}</div></div>
                <div class="bdm-actions">
                    <button type="submit" name="enable" value="1" class="btn-primary">{$LANG.domainreglockenable|default:'Enable registrar lock'}</button>
                    <span class="bdm-or">{$LANG.or|default:'or'}</span>
                    <button type="submit" name="disable" value="1" class="btn-secondary">{$LANG.domainreglockdisable|default:'Disable registrar lock'}</button>
                </div>

            {else}
                <h2 class="card-title" style="font-size:16px;margin-bottom:8px;">{$LANG.domaincontactinfo|default:'Contact information'}</h2>
                <div class="bdm-alert info"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg><div>{$LANG.domainbulkcontactinfo|default:'WHOIS contact details are managed per domain. Open a domain to update its registrant, admin, tech and billing contacts.'}</div></div>
                <div class="bdm-actions">
                    <a href="{$WEB_ROOT}/clientarea.php?action=domains" class="btn-primary">{$LANG.clientareanavdomains|default:'Go to my domains'}</a>
                </div>
            {/if}
            </div>
        </div>
    </form>
</div>
</div>
{/if}

{if !$hasDomains}
<div class="when-empty">
    <div class="card">
        <div class="bdm-empty">
            <div class="bdm-empty-ico">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="2" y1="12" x2="22" y2="12"/><path d="M12 2a15.3 15.3 0 014 10 15.3 15.3 0 01-4 10 15.3 15.3 0 01-4-10 15.3 15.3 0 014-10z"/></svg>
            </div>
            <p class="bdm-empty-title">{$LANG.domainbulkmanagementnodomains|default:'No domains selected'}</p>
            <p class="bdm-empty-sub">{$LANG.domainbulkmanagementnodomainssub|default:'Select one or more domains from your domains list, then choose a bulk action.'}</p>
            <a href="{$WEB_ROOT}/clientarea.php?action=domains" class="btn-primary">{$LANG.clientareanavdomains|default:'My domains'}</a>
        </div>
    </div>
</div>
{/if}

{if $hasDomains && $bdmUpdate == 'nameservers'}
<script>
{literal}
(function () {
    var radios = document.querySelectorAll('input[name="nschoice"]');
    var fields = document.getElementById('bdmNsFields');
    function sync() {
        var val = '';
        radios.forEach(function (r) {
            r.closest('.bdm-radio').classList.toggle('checked', r.checked);
            if (r.checked) val = r.value;
        });
        if (fields) { fields.classList.toggle('show', val === 'custom'); }
    }
    radios.forEach(function (r) { r.addEventListener('change', sync); });
    sync();
})();
{/literal}
</script>
{/if}
