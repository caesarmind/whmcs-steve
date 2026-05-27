{* Hostnodes — Submit a Ticket (Apple-style).

   WHMCS standard variables on /submitticket.php:
     $departments        — array of departments (id, name, description)
     $step               — current step (1=dept picker, 2=form fields)
     $deptid             — chosen department id (when step >= 2); WHMCS has no
                           $deptname, resolve the name from $departments yourself
     $relatedservices    — client's services for the related-service dropdown
     $subject, $message  — submitted form values (preserved across errors)
     $errormessage       — array/string of validation errors (HTML)
     $customfields       — array of custom fields for the dept ($customfield.input)
     $clientsdetails     — for the name/email pre-fill on guest submits
     $loggedin           — bool
     $captcha            — captcha widget if enabled (renders only when set)
*}

{assign var=hasDept value=(isset($deptid) && $deptid) || (isset($step) && $step >= 2)}
{if isset($departments) && $departments|@count > 0}
    {assign var=dashIsEmpty value='full'}
{else}
    {assign var=dashIsEmpty value='empty'}
{/if}

{* WHMCS exposes $deptid + the $departments array on step 2, but no ready-made $deptname.
   Resolve the chosen department's name by matching $deptid against $departments. *}
{assign var=chosenDeptName value=''}
{if isset($deptid) && $deptid && isset($departments)}
    {foreach $departments as $d}
        {if $d.id == $deptid}{assign var=chosenDeptName value=$d.name}{/if}
    {/foreach}
{/if}

<link rel="stylesheet" href="{$WEB_ROOT}/templates/{$template}/assets/css/pages/supportticketsubmit.css?v={$myTheme.version|default:'1.0'}">

<script>
(function () {
    var b = document.body;
    if (!b) return;
    b.setAttribute('data-data',   '{$dashIsEmpty}');
    b.setAttribute('data-subnav', 'on');
})();
</script>

<header class="page-header">
    <h1>{$LANG.opennewticket|default:'Open a ticket'}</h1>
    <p class="page-subtitle">{$LANG.submitticketsub|default:'Tell us what you need help with — our team will reply by email.'}</p>
</header>

<div class="tk-split">

    {* ══ LEFT: Support sub-nav ══ *}
    <aside class="tk-aside">
        <div class="card subnav-card">
            <div class="subnav-heading">{$LANG.supporttab|default:'Support'}</div>
            <a href="{$WEB_ROOT}/supporttickets.php" class="subnav-item">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M21 15a2 2 0 01-2 2H7l-4 4V5a2 2 0 012-2h14a2 2 0 012 2z"/></svg>
                {$LANG.mytickets|default:'My tickets'}
            </a>
            <a href="{$WEB_ROOT}/submitticket.php" class="subnav-item active">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
                {$LANG.opennewticket|default:'Open a ticket'}
            </a>
            <a href="{$WEB_ROOT}/announcements.php" class="subnav-item">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M18 8A6 6 0 006 8c0 7-3 9-3 9h18s-3-2-3-9"/><path d="M13.73 21a2 2 0 01-3.46 0"/></svg>
                {$LANG.announcementstitle|default:'Announcements'}
            </a>
            <a href="{$WEB_ROOT}/knowledgebase.php" class="subnav-item">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M2 3h6a4 4 0 014 4v14a3 3 0 00-3-3H2z"/><path d="M22 3h-6a4 4 0 00-4 4v14a3 3 0 013-3h7z"/></svg>
                {$LANG.knowledgebasetitle|default:'Knowledgebase'}
            </a>
            <a href="{$WEB_ROOT}/serverstatus.php" class="subnav-item">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><rect x="2" y="4" width="20" height="7" rx="1.5"/><rect x="2" y="13" width="20" height="7" rx="1.5"/></svg>
                {$LANG.networkstatus|default:'Network status'}
            </a>
        </div>
    </aside>

    {* ══ RIGHT: form ══ *}
    <div class="tk-main when-full">

        {if isset($errormessage) && $errormessage}
        <div class="tk-error-banner" role="alert">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
            <div>{if is_array($errormessage)}{foreach $errormessage as $err}<div>{$err|strip_tags|escape}</div>{/foreach}{else}{$errormessage}{/if}</div>
        </div>
        {/if}

        {if !$hasDept}
        {* ── STEP 1: Department picker ── *}
        <div class="card">
            <div class="tk-intro">
                <p class="tk-step">{$LANG.step1of2|default:'Step 1 of 2'}</p>
                <h2>{$LANG.choosedepartment|default:'Choose a department'}</h2>
                <p>{$LANG.choosedepartmentsub|default:'Pick the team best suited to help — your message reaches them directly.'}</p>
            </div>
            <form method="post" action="{$WEB_ROOT}/submitticket.php?step=2">
                <input type="hidden" name="step" value="2">
                <div class="dept-grid">
                    {foreach $departments as $dept}
                    {assign var=deptName value=$dept.name|default:''}
                    {assign var=deptLower value=$deptName|lower}
                    {if $deptLower|strstr:'sales' || $deptLower|strstr:'billing'}
                        {assign var=deptKind value='sales'}
                    {elseif $deptLower|strstr:'abuse' || $deptLower|strstr:'security'}
                        {assign var=deptKind value='abuse'}
                    {else}
                        {assign var=deptKind value='tech'}
                    {/if}
                    <label class="dept-card">
                        <input type="radio" name="deptid" value="{$dept.id|escape}" required>
                        <div class="dept-head">
                            <span class="dept-ico {$deptKind}">
                                {if $deptKind == 'sales'}<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><line x1="12" y1="1" x2="12" y2="23"/><path d="M17 5H9.5a3.5 3.5 0 000 7h5a3.5 3.5 0 010 7H6"/></svg>
                                {elseif $deptKind == 'abuse'}<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/></svg>
                                {else}<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="3"/><path d="M19.4 15a1.65 1.65 0 00.33 1.82l.06.06a2 2 0 01-2.83 2.83l-.06-.06a1.65 1.65 0 00-1.82-.33 1.65 1.65 0 00-1 1.51V21a2 2 0 01-4 0v-.09A1.65 1.65 0 009 19.4a1.65 1.65 0 00-1.82.33l-.06.06a2 2 0 01-2.83-2.83l.06-.06a1.65 1.65 0 00.33-1.82 1.65 1.65 0 00-1.51-1H3a2 2 0 010-4h.09A1.65 1.65 0 004.6 9a1.65 1.65 0 00-.33-1.82l-.06-.06a2 2 0 012.83-2.83l.06.06a1.65 1.65 0 001.82.33H9a1.65 1.65 0 001-1.51V3a2 2 0 014 0v.09a1.65 1.65 0 001 1.51 1.65 1.65 0 001.82-.33l.06-.06a2 2 0 012.83 2.83l-.06.06a1.65 1.65 0 00-.33 1.82V9a1.65 1.65 0 001.51 1H21a2 2 0 010 4h-.09a1.65 1.65 0 00-1.51 1z"/></svg>{/if}
                            </span>
                            <span class="dept-name">{$deptName}</span>
                            <span class="dept-check"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"/></svg></span>
                        </div>
                        {if isset($dept.description) && $dept.description}
                        <p class="dept-desc">{$dept.description|strip_tags|truncate:140:"…"}</p>
                        {/if}
                    </label>
                    {/foreach}
                </div>
                <div class="tk-form-foot">
                    <a href="{$WEB_ROOT}/supporttickets.php" class="btn-secondary">{$LANG.cancel|default:'Cancel'}</a>
                    <button type="submit" class="btn-primary">{$LANG.continue|default:'Continue'}</button>
                </div>
            </form>
        </div>
        {else}
        {* ── STEP 2: Subject / message / attachments ── *}
        <div class="card">
            <div class="tk-intro">
                <p class="tk-step">{$LANG.step2of2|default:'Step 2 of 2'}</p>
                <h2>{$LANG.ticketdetails|default:'Ticket details'}</h2>
                {if $chosenDeptName}
                <p>{$LANG.replyingto|default:'Replying via'} <strong>{$chosenDeptName}</strong></p>
                {/if}
            </div>
            <form method="post" action="{$WEB_ROOT}/submitticket.php?step=3" enctype="multipart/form-data" class="tk-submit-form">
                <input type="hidden" name="step" value="3">
                {if isset($deptid) && $deptid}<input type="hidden" name="deptid" value="{$deptid|escape}">{/if}
                {if isset($token) && $token}<input type="hidden" name="token" value="{$token|escape}">{/if}

                {if !$loggedin}
                <div class="form-row">
                    <div class="form-group">
                        <label class="form-label" for="tk-name">{$LANG.clientareafirstname|default:'Your name'}</label>
                        <input type="text" class="form-input" id="tk-name" name="name" value="{$name|default:''|escape}" autocomplete="name" required>
                    </div>
                    <div class="form-group">
                        <label class="form-label" for="tk-email">{$LANG.clientareaemail|default:'Email address'}</label>
                        <input type="email" class="form-input" id="tk-email" name="email" value="{$email|default:''|escape}" autocomplete="email" required>
                    </div>
                </div>
                {/if}

                <div class="form-group">
                    <label class="form-label" for="tk-subject">{$LANG.supportticketssubject|default:'Subject'}</label>
                    <input type="text" class="form-input" id="tk-subject" name="subject" value="{$subject|default:''|escape}" required>
                </div>

                <div class="form-row">
                    <div class="form-group">
                        <label class="form-label" for="tk-priority">{$LANG.supportticketspriority|default:'Priority'}</label>
                        <select class="form-select" id="tk-priority" name="urgency">
                            <option value="Low"{if isset($urgency) && $urgency == 'Low'} selected{/if}>{$LANG.supportticketsticketurgencylow|default:'Low'}</option>
                            <option value="Medium"{if !isset($urgency) || $urgency == 'Medium'} selected{/if}>{$LANG.supportticketsticketurgencymedium|default:'Medium'}</option>
                            <option value="High"{if isset($urgency) && $urgency == 'High'} selected{/if}>{$LANG.supportticketsticketurgencyhigh|default:'High'}</option>
                        </select>
                    </div>
                    {if isset($relatedservices) && $relatedservices|@count > 0}
                    <div class="form-group">
                        <label class="form-label" for="tk-service">{$LANG.relatedservice|default:'Related service'} <span style="opacity:0.5; font-weight:400;">({$LANG.optional|default:'optional'})</span></label>
                        <select class="form-select" id="tk-service" name="relatedservice">
                            <option value="">{$LANG.none|default:'None'}</option>
                            {foreach from=$relatedservices item=relatedservice}
                            <option value="{$relatedservice.id}"{if isset($selectedservice) && $selectedservice == $relatedservice.id} selected{/if}>{if $relatedservice.groupName}{$relatedservice.groupName} - {/if}{$relatedservice.name}{if isset($relatedservice.status) && $relatedservice.status} ({$relatedservice.status}){/if}</option>
                            {/foreach}
                        </select>
                    </div>
                    {/if}
                </div>

                <div class="form-group">
                    <label class="form-label" for="tk-message">{$LANG.contactmessage|default:'Message'}</label>
                    <textarea class="form-input tk-message-area" id="tk-message" name="message" rows="9" required>{$message|default:''|escape}</textarea>
                </div>

                {if isset($customfields) && $customfields|@count > 0}
                {foreach from=$customfields item=customfield}
                <div class="form-group tk-customfield">
                    {if $customfield.type == 'tickbox'}
                    <label class="tk-cf-check" for="customfield{$customfield.id}">
                        {$customfield.input}
                        <span>{$customfield.name|strip_tags}{if $customfield.required} <span class="tk-req">*</span>{/if}</span>
                    </label>
                    {else}
                    <label class="form-label" for="customfield{$customfield.id}">{$customfield.name|strip_tags}{if $customfield.required} <span class="tk-req">*</span>{/if}</label>
                    {$customfield.input}
                    {/if}
                    {if isset($customfield.description) && $customfield.description}<p class="form-help">{$customfield.description|strip_tags}</p>{/if}
                </div>
                {/foreach}
                {/if}

                <div class="form-group tk-attach-group">
                    <span class="form-label">{$LANG.supportticketsticketattachments|default:'Attachments'} <span style="opacity:0.5; font-weight:400;">({$LANG.optional|default:'optional'})</span></span>
                    <div class="tk-attach-rows" id="tk-attach-rows">
                        <div class="tk-attach-row">
                            <label class="tk-drop">
                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M21.44 11.05l-9.19 9.19a6 6 0 01-8.49-8.49l9.19-9.19a4 4 0 015.66 5.66l-9.2 9.19a2 2 0 01-2.83-2.83l8.49-8.48"/></svg>
                                <span class="tk-drop-label">{$LANG.addattachments|default:'Choose a file…'}</span>
                                <input type="file" name="attachments[]">
                            </label>
                            <button type="button" class="tk-attach-remove" aria-label="{$LANG.orderForm.remove|default:'Remove'}" hidden>
                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg>
                            </button>
                        </div>
                    </div>
                    <button type="button" class="tk-attach-add" id="tk-attach-add">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
                        {$LANG.addmore|default:'Add another file'}
                    </button>
                    <div class="tk-drop-hint">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                        {if isset($allowedfiletypes) && $allowedfiletypes}{$LANG.supportticketsallowedextensions|default:'Allowed extensions'}: {$allowedfiletypes}{if isset($uploadMaxFileSize) && $uploadMaxFileSize} &middot; {lang key="maxFileSize" fileSize=$uploadMaxFileSize}{/if}{else}{$LANG.attachmentsallowed|default:'Allowed: .jpg, .gif, .jpeg, .png, .txt, .pdf · Max 64MB'}{/if}
                    </div>
                </div>
                {literal}
                <script>
                (function () {
                    var rows = document.getElementById('tk-attach-rows');
                    var addBtn = document.getElementById('tk-attach-add');
                    if (!rows || !addBtn) return;
                    var firstLabel = rows.querySelector('.tk-drop-label');
                    var defaultLabel = firstLabel ? firstLabel.textContent : '';

                    function allRows() { return rows.querySelectorAll('.tk-attach-row'); }

                    function refreshRemoveButtons() {
                        var list = allRows();
                        for (var i = 0; i < list.length; i++) {
                            var input = list[i].querySelector('input[type=file]');
                            var rm = list[i].querySelector('.tk-attach-remove');
                            if (!rm) continue;
                            var hasFile = input && input.files && input.files.length;
                            rm.hidden = !(hasFile || list.length > 1);
                        }
                    }

                    function resetRow(row) {
                        var input = row.querySelector('input[type=file]');
                        var labelEl = row.querySelector('.tk-drop-label');
                        var drop = row.querySelector('.tk-drop');
                        if (input) input.value = '';
                        if (labelEl) labelEl.textContent = defaultLabel;
                        if (drop) drop.classList.remove('has-file');
                    }

                    function wireRow(row) {
                        var input = row.querySelector('input[type=file]');
                        var labelEl = row.querySelector('.tk-drop-label');
                        var drop = row.querySelector('.tk-drop');
                        var rm = row.querySelector('.tk-attach-remove');
                        if (input) {
                            input.addEventListener('change', function () {
                                if (input.files && input.files.length) {
                                    var f = input.files[0];
                                    var kb = Math.max(1, Math.round(f.size / 1024));
                                    if (labelEl) labelEl.textContent = f.name + ' (' + kb + ' KB)';
                                    if (drop) drop.classList.add('has-file');
                                } else {
                                    resetRow(row);
                                }
                                refreshRemoveButtons();
                            });
                        }
                        if (rm) {
                            rm.addEventListener('click', function () {
                                if (allRows().length > 1) {
                                    row.parentNode.removeChild(row);
                                } else {
                                    resetRow(row);
                                }
                                refreshRemoveButtons();
                            });
                        }
                    }

                    addBtn.addEventListener('click', function () {
                        var clone = rows.querySelector('.tk-attach-row').cloneNode(true);
                        resetRow(clone);
                        rows.appendChild(clone);
                        wireRow(clone);
                        refreshRemoveButtons();
                    });

                    var init = allRows();
                    for (var i = 0; i < init.length; i++) wireRow(init[i]);
                    refreshRemoveButtons();
                })();
                </script>
                {/literal}

                {* Spam/CAPTCHA challenge — WHMCS provides $captcha only when enabled
                   (and typically only for guest submissions); renders nothing otherwise. *}
                {if isset($captcha) && $captcha}
                <div class="form-group tk-captcha">{$captcha}</div>
                {/if}

                <div class="tk-form-foot">
                    <a href="{$WEB_ROOT}/submitticket.php" class="btn-secondary">{$LANG.back|default:'Back'}</a>
                    <button type="submit" class="btn-primary">{$LANG.submitticket|default:'Submit ticket'}</button>
                </div>
            </form>
        </div>
        {/if}

    </div>

    {* Empty state — WHMCS returned no departments at all *}
    <div class="tk-main when-empty">
        <div class="card tk-empty">
            <div class="tk-empty-inner">
                <div class="tk-empty-ico">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
                </div>
                <p class="tk-empty-title">{$LANG.nodepartments|default:'No departments available'}</p>
                <p class="tk-empty-sub">{$LANG.nodepartmentssub|default:'No support departments have been configured. Please contact the site administrator.'}</p>
                <a href="{$WEB_ROOT}/contact.php" class="btn-secondary">{$LANG.contactus|default:'Contact us'}</a>
            </div>
        </div>
    </div>

</div>
