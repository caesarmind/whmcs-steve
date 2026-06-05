{* Hostnodes - Email history (Apple-style): emails sent to the client.

   WHMCS variables (cross-checked against Lagom clientareaemails.tpl):
     $emails - each: id, date, normalisedDate, subject, attachmentCount
   Rows open viewemail.php?id={id} in a popup window.
   Demo data under ?preview=1.
*}

{assign var=isPreview value=false}
{if isset($smarty.get.preview) && $smarty.get.preview == '1'}{assign var=isPreview value=true}{/if}

{assign var=hasEmails value=false}
{if isset($emails) && $emails|@count > 0}{assign var=hasEmails value=true}{/if}

{assign var=emDemo value=false}
{if !$hasEmails && $isPreview}
    {assign var=emDemo value=true}
    {assign var=emails value=[
        ['id'=>1,'date'=>'May 18, 2026 14:32','subject'=>'Invoice #1042 payment confirmation','attachmentCount'=>1],
        ['id'=>2,'date'=>'May 15, 2026 09:10','subject'=>'Your service has been activated','attachmentCount'=>0],
        ['id'=>3,'date'=>'May 11, 2026 18:45','subject'=>'Domain hendersondesign.com renewal notice','attachmentCount'=>0],
        ['id'=>4,'date'=>'May 02, 2026 08:00','subject'=>'Welcome to Hostnodes','attachmentCount'=>1]
    ]}
    {assign var=hasEmails value=true}
{/if}

{if $hasEmails}{assign var=dashIsEmpty value='full'}{else}{assign var=dashIsEmpty value='empty'}{/if}

{* Dynamic AJAX Loading toggle (admin Settings -> enable_dynamic_ajax). *}
{assign var=mtAjaxTables value=$myTheme.addonSettings.enable_dynamic_ajax|default:false}

<link rel="stylesheet" href="{$WEB_ROOT}/templates/{$template}/assets/css/pages/clientareaemails.css?v={$myTheme.version|default:'1.0'}">
{* Unified list-table engine (client-side + Dynamic AJAX Loading) — loaded once. *}
{include file="`$template`/includes/partials/list-table-assets.tpl"}

<script>
(function () {
    var b = document.body;
    if (!b) return;
    b.setAttribute('data-data',   '{$dashIsEmpty}');
    b.setAttribute('data-subnav', 'on');
})();
</script>

<header class="page-header">
    <p class="eyebrow">{$LANG.accounttab|default:'Account'}</p>
    <h1>{$LANG.emailstitle|default:'Email History'}</h1>
    <p class="page-subtitle">{$hadrianLang.account.emailsIntro}</p>
</header>

<div class="em-split">
    <div class="em-main">
        {if $hasEmails}
        <div class="when-full">
            <div class="em-toolbar">
                <div class="em-search">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="7"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
                    <input type="search" placeholder="{$LANG.search}…" autocomplete="off" aria-label="{$LANG.search}" data-mt-search data-mt-for="emTable">
                </div>
            </div>
            <div class="card" style="padding: 0; overflow: hidden;">
                <table class="em-table" id="emTable" data-mt-type="emails" data-mt-order="0:desc" data-mt-length="10"{if $mtAjaxTables} data-mt-action="tableEmails" data-mt-endpoint="{$WEB_ROOT}/clientarea.php"{/if}>
                    <thead>
                        <tr>
                            <th><button type="button" class="em-sort" data-sort="date" data-dir="">{$LANG.clientareaemailsdate} <span class="em-sort-ico"></span></button></th>
                            <th><button type="button" class="em-sort" data-sort="subject" data-dir="">{$LANG.clientareaemailssubject} <span class="em-sort-ico"></span></button></th>
                        </tr>
                    </thead>
                    <tbody>
                        {if !$mtAjaxTables}
                        {foreach $emails as $email}
                        <tr data-href="{$WEB_ROOT}/viewemail.php?id={$email.id|escape}" data-date="{$email.normalisedDate|default:''|escape}" data-subject="{$email.subject|strip_tags|escape}">
                            <td class="em-date" data-order="{$email.normalisedDate|default:''|escape}">{$email.date|escape}</td>
                            <td>
                                <div class="em-subject">
                                    {if $email.attachmentCount > 0}<svg class="em-clip" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M21.44 11.05l-9.19 9.19a6 6 0 01-8.49-8.49l9.19-9.19a4 4 0 015.66 5.66l-9.2 9.19a2 2 0 01-2.83-2.83l8.49-8.48"/></svg>{/if}
                                    <a href="{$WEB_ROOT}/viewemail.php?id={$email.id|escape}">{$email.subject|escape}</a>
                                </div>
                            </td>
                        </tr>
                        {/foreach}
                        {/if}
                    </tbody>
                </table>
            </div>
            <div class="em-footer">
                <div class="em-page-size">
                    {$hadrianLang.account.showEntries}
                    <select aria-label="{$hadrianLang.account.showEntriesAria}" data-dt-length data-mt-for="emTable">
                        <option>10</option>
                        <option>25</option>
                        <option>50</option>
                    </select>
                    {$hadrianLang.account.entries}
                </div>
                <div class="spacer"></div>
                <span class="em-info" data-dt-info data-mt-for="emTable"></span>
                <div class="em-pages" data-dt-pager data-mt-for="emTable"></div>
            </div>
        </div>
        {/if}

        {if !$hasEmails}
        <div class="when-empty">
            <div class="card">
                <div class="em-empty">
                    <div class="em-empty-ico">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"/><polyline points="22 6 12 13 2 6"/></svg>
                    </div>
                    <p class="em-empty-title">{$hadrianLang.account.emailsEmptyTitle}</p>
                    <p class="em-empty-sub">{$hadrianLang.account.emailsEmptySub}</p>
                    <a href="{$WEB_ROOT}/clientarea.php?action=details" class="btn-primary">{$LANG.accountdetails|default:'Account Details'}</a>
                </div>
            </div>
        </div>
        {/if}
    </div>

    <aside>
        <div class="card subnav-card">
            <div class="subnav-heading">{$LANG.accounttab|default:'Account'}</div>
            <a href="{$WEB_ROOT}/clientarea.php?action=details" class="subnav-item">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M20 21v-2a4 4 0 00-4-4H8a4 4 0 00-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
                {$LANG.accountdetails|default:'Account Details'}
            </a>
            <a href="{routePath('account-contacts')}" class="subnav-item">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M20 21v-2a4 4 0 00-4-4H8a4 4 0 00-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
                {$LANG.contacts|default:'Contacts'}
            </a>
            <a href="{$WEB_ROOT}/clientarea.php?action=emails" class="subnav-item active">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"/><polyline points="22 6 12 13 2 6"/></svg>
                {$LANG.emailstitle|default:'Email History'}
            </a>
            <a href="{$WEB_ROOT}/clientarea.php?action=security" class="subnav-item">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="11" width="18" height="11" rx="2"/><path d="M7 11V7a5 5 0 0110 0v4"/></svg>
                {$LANG.security|default:'Security'}
            </a>
        </div>
    </aside>
</div>

