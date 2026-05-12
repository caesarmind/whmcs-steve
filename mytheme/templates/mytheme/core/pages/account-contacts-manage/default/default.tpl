{* Hostnodes — Contacts (Apple-style).

   WHMCS standard variables on /clientarea.php?action=contacts:
     $contacts            — array of contacts; each has id, firstname,
                            lastname, companyname, email, phonenumber,
                            generalemails, productemails, supportemails,
                            invoiceemails, domainemails, affiliateemails
     $errormessage        — array/string of validation errors
     $token               — CSRF token
     $contactdisabled     — bool
*}

{if isset($contacts) && $contacts|@count > 0}
    {assign var=ctCount value=$contacts|@count}
    {assign var=dashIsEmpty value='full'}
{else}
    {assign var=ctCount value=0}
    {assign var=dashIsEmpty value='empty'}
{/if}

<link rel="stylesheet" href="{$WEB_ROOT}/templates/{$template}/assets/css/pages/account-contacts-manage.css?v={$myTheme.version|default:'1.0'}">

<script>
(function () { var b = document.body; if (b) { b.setAttribute('data-data', '{$dashIsEmpty}'); b.setAttribute('data-subnav', 'on'); } })();
</script>

<header class="page-header">
    <div class="page-header-row">
        <div style="flex:1; min-width:0;">
            <h1>{$LANG.contacts|default:'Contacts'}</h1>
            <p class="page-subtitle">{$LANG.contactssub|default:'Additional people authorised to manage parts of this account.'}</p>
        </div>
        <a href="{$WEB_ROOT}/clientarea.php?action=contacts&action=add" class="page-header-action">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
            {$LANG.addnewcontact|default:'Add new contact'}
        </a>
    </div>
</header>

<div class="ct-split">
    <div class="ct-main">

        {if isset($errormessage) && $errormessage}
        <div class="ct-error">{if is_array($errormessage)}{foreach $errormessage as $err}{$err|strip_tags|escape}{/foreach}{else}{$errormessage|strip_tags|escape}{/if}</div>
        {/if}

        <div class="when-full ct-list">
            {if $ctCount > 0}
                {foreach $contacts as $c}
                {assign var=ctName value=$c.firstname|default:''|cat:" "|cat:$c.lastname|default:''}
                {assign var=ctInitial value=$c.firstname|default:'?'|substr:0:1|upper}
                <div class="ct-row">
                    <div class="ct-row-avatar">{$ctInitial|escape}</div>
                    <div class="ct-row-meta">
                        <div class="ct-row-name">{$ctName|escape}</div>
                        <div class="ct-row-sub">{$c.email|escape}{if !empty($c.phonenumber)} · {$c.phonenumber|escape}{/if}</div>
                        {if !empty($c.companyname)}<div class="ct-row-org">{$c.companyname|escape}</div>{/if}
                    </div>
                    <div class="ct-row-tags">
                        {if !empty($c.generalemails)}<span class="ct-tag">{$LANG.generalemails|default:'General'}</span>{/if}
                        {if !empty($c.invoiceemails)}<span class="ct-tag">{$LANG.invoiceemails|default:'Invoices'}</span>{/if}
                        {if !empty($c.supportemails)}<span class="ct-tag">{$LANG.supportemails|default:'Support'}</span>{/if}
                        {if !empty($c.productemails)}<span class="ct-tag">{$LANG.productemails|default:'Products'}</span>{/if}
                        {if !empty($c.domainemails)}<span class="ct-tag">{$LANG.domainemails|default:'Domains'}</span>{/if}
                    </div>
                    <div class="ct-row-actions">
                        <a href="{$WEB_ROOT}/clientarea.php?action=contacts&contactid={$c.id|escape}" class="ct-row-btn">{$LANG.edit|default:'Edit'}</a>
                        <form method="post" action="{$WEB_ROOT}/clientarea.php?action=contacts&contactid={$c.id|escape}" style="display:inline" onsubmit="return confirm('{$LANG.contactdeleteconfirm|default:'Remove this contact?'}');">
                            <input type="hidden" name="token" value="{$token|default:''|escape}">
                            <input type="hidden" name="sub" value="delete">
                            <button type="submit" class="ct-row-btn ct-row-btn-danger">{$LANG.remove|default:'Remove'}</button>
                        </form>
                    </div>
                </div>
                {/foreach}
            {/if}
        </div>

        <div class="when-empty ct-empty">
            <div class="ct-empty-ico"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M17 21v-2a4 4 0 00-4-4H5a4 4 0 00-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 00-3-3.87"/><path d="M16 3.13a4 4 0 010 7.75"/></svg></div>
            <p class="ct-empty-title">{$LANG.nocontacts|default:'No contacts yet'}</p>
            <p class="ct-empty-sub">{$LANG.nocontactssub|default:'Invite a colleague or accountant to receive specific emails or manage parts of this account.'}</p>
            <a href="{$WEB_ROOT}/clientarea.php?action=contacts&action=add" class="btn-primary">{$LANG.addnewcontact|default:'Add new contact'}</a>
        </div>

    </div>

    <aside>
        <div class="card subnav-card">
            <div class="subnav-heading">{$LANG.accounttab|default:'Account'}</div>
            <a href="{$WEB_ROOT}/clientarea.php?action=details" class="subnav-item">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M20 21v-2a4 4 0 00-4-4H8a4 4 0 00-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
                {$LANG.accountdetails|default:'Account Details'}
            </a>
            <a href="{routePath('account-users')}" class="subnav-item">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M17 21v-2a4 4 0 00-4-4H5a4 4 0 00-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 00-3-3.87"/><path d="M16 3.13a4 4 0 010 7.75"/></svg>
                {$LANG.usermanagement|default:'User Management'}
            </a>
            <a href="{routePath('account-paymentmethods')}" class="subnav-item">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><rect x="2" y="5" width="20" height="14" rx="2"/><path d="M2 10h20"/></svg>
                {$LANG.paymentmethods|default:'Payment Methods'}
            </a>
            <a href="{routePath('account-contacts')}" class="subnav-item active">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M20 21v-2a4 4 0 00-4-4H8a4 4 0 00-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
                {$LANG.contacts|default:'Contacts'}
            </a>
            <a href="{$WEB_ROOT}/clientarea.php?action=emails" class="subnav-item">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"/><polyline points="22 6 12 13 2 6"/></svg>
                {$LANG.emailstitle|default:'Email History'}
            </a>
        </div>
    </aside>
</div>
