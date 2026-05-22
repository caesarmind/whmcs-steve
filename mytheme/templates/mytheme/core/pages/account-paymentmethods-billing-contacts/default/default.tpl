{* Hostnodes - Billing contacts (Apple-style): recipients copied on billing emails.

   WHMCS exposes billing contacts through the account contacts system. We iterate
   $contacts (id, name, email) defensively and fall back to the empty state.
   VERIFY the exact collection variable on the live site. Demo data under ?preview=1.
*}

{assign var=isPreview value=false}
{if isset($smarty.get.preview) && $smarty.get.preview == '1'}{assign var=isPreview value=true}{/if}

{assign var=hasContacts value=false}
{if isset($contacts) && $contacts|@count > 0}{assign var=hasContacts value=true}{/if}

{assign var=bcDemo value=false}
{if !$hasContacts && $isPreview}
    {assign var=bcDemo value=true}
    {assign var=contacts value=[
        ['id'=>1,'name'=>'Arshile Gogia','email'=>'arshileg@gmail.com','primary'=>true],
        ['id'=>2,'name'=>'Finance Department','email'=>'finance@hendersondesign.com','primary'=>false]
    ]}
    {assign var=hasContacts value=true}
{/if}

{if $hasContacts}{assign var=dashIsEmpty value='full'}{else}{assign var=dashIsEmpty value='empty'}{/if}

<link rel="stylesheet" href="{$WEB_ROOT}/templates/{$template}/assets/css/pages/account-paymentmethods-billing-contacts.css?v={$myTheme.version|default:'1.0'}">

<script>
(function () {
    var b = document.body;
    if (!b) return;
    b.setAttribute('data-data',   '{$dashIsEmpty}');
    b.setAttribute('data-subnav', 'on');
})();
</script>

<header class="page-header">
    <div class="page-header-row">
        <div class="page-header-text">
            <h1>{$LANG.paymentMethods.billingContacts|default:'Billing contacts'}</h1>
            <p class="page-subtitle">{$LANG.paymentMethods.billingContactsIntro|default:'Recipients copied on invoice and payment receipt emails.'}</p>
        </div>
        <a href="{routePath('account-contacts')}" class="btn-primary">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
            {$LANG.clientareanavaddcontact|default:'Add billing contact'}
        </a>
    </div>
</header>

<div class="pm-split">
    <div class="pm-main">
        {if $hasContacts}
        <div class="when-full">
            <div class="bc-list">
                {foreach $contacts as $c}
                <div class="card bc-row">
                    <div class="bc-avatar">{$c.name|default:'?'|truncate:2:""|escape}</div>
                    <div class="bc-meta">
                        <div class="bc-name"><span>{$c.name|default:''|escape}</span>{if isset($c.primary) && $c.primary}<span class="bc-pill">{$LANG.primary|default:'Primary'}</span>{/if}</div>
                        <div class="bc-email">{$c.email|default:''|escape}</div>
                    </div>
                    <div class="bc-actions">
                        <a href="{routePath('account-contacts')}" class="bc-action-btn" title="{$LANG.edit|default:'Edit'}"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M11 4H4a2 2 0 00-2 2v14a2 2 0 002 2h14a2 2 0 002-2v-7"/><path d="M18.5 2.5a2.121 2.121 0 013 3L12 15l-4 1 1-4 9.5-9.5z"/></svg></a>
                    </div>
                </div>
                {/foreach}
            </div>
        </div>
        {/if}

        {if !$hasContacts}
        <div class="when-empty">
            <div class="card bc-empty">
                <div class="bc-empty-ico">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M20 21v-2a4 4 0 00-4-4H8a4 4 0 00-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
                </div>
                <p class="bc-empty-title">{$LANG.paymentMethods.noBillingContacts|default:'No billing contacts'}</p>
                <p class="bc-empty-sub">{$LANG.paymentMethods.noBillingContactsSub|default:'Add a contact to copy them on invoice and receipt emails.'}</p>
                <a href="{routePath('account-contacts')}" class="btn-primary">{$LANG.clientareanavaddcontact|default:'Add billing contact'}</a>
            </div>
        </div>
        {/if}
    </div>

    <aside>
        <div class="card subnav-card">
            <div class="subnav-heading">{$LANG.accounttab|default:'Account'}</div>
            <a href="{routePath('account-paymentmethods')}" class="subnav-item">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><rect x="2" y="5" width="20" height="14" rx="2"/><path d="M2 10h20"/></svg>
                {$LANG.paymentmethods|default:'Payment Methods'}
            </a>
            <a href="{routePath('account-paymentmethods-billing-contacts')}" class="subnav-item active">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M20 21v-2a4 4 0 00-4-4H8a4 4 0 00-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
                {$LANG.paymentMethods.billingContacts|default:'Billing Contacts'}
            </a>
            <a href="{routePath('account-contacts')}" class="subnav-item">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M20 21v-2a4 4 0 00-4-4H8a4 4 0 00-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
                {$LANG.contacts|default:'Contacts'}
            </a>
            <a href="{$WEB_ROOT}/clientarea.php?action=details" class="subnav-item">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M20 21v-2a4 4 0 00-4-4H8a4 4 0 00-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
                {$LANG.accountdetails|default:'Account Details'}
            </a>
        </div>
    </aside>
</div>
