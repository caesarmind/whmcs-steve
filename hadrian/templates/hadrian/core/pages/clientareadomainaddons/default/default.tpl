{* Hostnodes — Domain Addons confirmation.

   This page is the buy / disable confirmation step. WHMCS provides:
     $domain, $domainid
     $action  ('buy' | 'disable')
     $addon   ('dnsmanagement' | 'emailfwd' | 'idprotect')
     $addonspricing.{dnsmanagement,emailforwarding,idprotection}
     $success, $error
     $token
*}

{assign var=addonName value=''}
{assign var=addonDesc value=''}
{assign var=addonPrice value=''}
{assign var=addonIcon value='shield'}
{if $addon eq 'dnsmanagement'}
    {assign var=addonName  value=$LANG.domainaddonsdnsmanagement}
    {assign var=addonDesc  value=$LANG.domainaddonsdnsmanagementinfo}
    {assign var=addonPrice value=$addonspricing.dnsmanagement|default:''}
    {assign var=addonIcon  value='globe'}
{elseif $addon eq 'emailfwd'}
    {assign var=addonName  value=$LANG.domainemailforwarding}
    {assign var=addonDesc  value=$LANG.domainaddonsemailforwardinginfo}
    {assign var=addonPrice value=$addonspricing.emailforwarding|default:''}
    {assign var=addonIcon  value='envelope'}
{elseif $addon eq 'idprotect'}
    {assign var=addonName  value=$LANG.domainidprotection}
    {assign var=addonDesc  value=$LANG.domainaddonsidprotectioninfo}
    {assign var=addonPrice value=$addonspricing.idprotection|default:''}
    {assign var=addonIcon  value='shield'}
{/if}

<link rel="stylesheet" href="{$WEB_ROOT}/templates/{$template}/assets/css/pages/clientareadomainaddons.css?v={$hadrian.version|default:'1.0'}">

<header class="page-header">
    <p class="page-eyebrow">{$domain|default:''|escape}</p>
    <h1>{$addonName|escape}</h1>
</header>

<div class="da-wrap">
    <div class="card da-card">
        <div class="da-icon">
            {if $addonIcon eq 'globe'}
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="2" y1="12" x2="22" y2="12"/><path d="M12 2a15.3 15.3 0 0 1 4 10 15.3 15.3 0 0 1-4 10 15.3 15.3 0 0 1-4-10 15.3 15.3 0 0 1 4-10z"/></svg>
            {elseif $addonIcon eq 'envelope'}
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round"><path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"/><polyline points="22,6 12,13 2,6"/></svg>
            {else}
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/></svg>
            {/if}
        </div>

        <p class="da-desc">{$addonDesc|escape}</p>

        {if !empty($addonPrice) && $action eq 'buy'}
            <div class="da-price-row">
                <span class="da-price-label">{$LANG.domainaddonsbuynow}</span>
                <span class="da-price-value">{$addonPrice|escape} <span class="da-price-cycle">{$LANG.domainaddonsperyear}</span></span>
            </div>
        {/if}

        {if !empty($success)}
            <div class="da-alert da-alert-success">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"/></svg>
                <div>{$LANG.domainaddonscancelsuccess}</div>
            </div>
        {elseif !empty($error)}
            <div class="da-alert da-alert-error">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/></svg>
                <div>{$LANG.domainaddonscancelfailed}</div>
            </div>
        {else}
            <form method="post" action="{$smarty.server.PHP_SELF}?action=domainaddons" class="da-form">
                <input type="hidden" name="token" value="{$token|default:''|escape}">
                <input type="hidden" name="id" value="{$domainid|escape}">
                <input type="hidden" name="confirm" value="1">
                {if $action eq 'buy'}
                    <input type="hidden" name="buy" value="{$addon|escape}">
                    <button type="submit" name="enable" value="1" class="btn-primary da-cta">{$LANG.domainaddonsbuynow}</button>
                {elseif $action eq 'disable'}
                    <input type="hidden" name="disable" value="{$addon|escape}">
                    <p class="da-confirm">{$LANG.domainaddonscancelareyousure}</p>
                    <button type="submit" name="enable" value="1" class="btn-secondary da-cta da-danger-btn">{$LANG.domainaddonsconfirm}</button>
                {/if}
                <a href="{$WEB_ROOT}/clientarea.php?action=domaindetails&id={$domainid|escape}" class="da-back">{$LANG.clientareabacklink}</a>
            </form>
        {/if}
    </div>
</div>
