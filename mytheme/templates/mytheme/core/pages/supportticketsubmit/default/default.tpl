{* Hostnodes — Submit a Ticket (Apple-style).

   WHMCS standard variables on /submitticket.php:
     $departments        — array of departments (id, name, description)
     $step               — current step (1=dept picker, 2=form fields)
     $deptid             — chosen department id (when step >= 2)
     $deptname           — name of chosen department
     $subject, $message  — submitted form values (preserved across errors)
     $errormessage       — array/string of validation errors (HTML)
     $customfields       — array of custom fields for the dept
     $clientsdetails     — for the name/email pre-fill on guest submits
     $loggedin           — bool
     $kbarticles         — KB suggestions based on subject (step 2 ajax)
*}

{assign var=hasDept value=(isset($deptid) && $deptid) || (isset($step) && $step >= 2)}
{if isset($departments) && $departments|@count > 0}
    {assign var=dashIsEmpty value='full'}
{else}
    {assign var=dashIsEmpty value='empty'}
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
                            <span class="dept-name">{$deptName|escape}</span>
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
                {if isset($deptname) && $deptname}
                <p>{$LANG.replyingto|default:'Replying via'} <strong>{$deptname|escape}</strong></p>
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
                            <option value="Low"{if isset($urgency) && $urgency == 'Low'} selected{/if}>{$LANG.supportticketspriorityLow|default:'Low'}</option>
                            <option value="Medium"{if !isset($urgency) || $urgency == 'Medium'} selected{/if}>{$LANG.supportticketspriorityMedium|default:'Medium'}</option>
                            <option value="High"{if isset($urgency) && $urgency == 'High'} selected{/if}>{$LANG.supportticketspriorityHigh|default:'High'}</option>
                        </select>
                    </div>
                    {if isset($servicelist) && $servicelist|@count > 0}
                    <div class="form-group">
                        <label class="form-label" for="tk-service">{$LANG.supportticketsrelatedservice|default:'Related service'} <span style="opacity:0.5; font-weight:400;">({$LANG.optional|default:'optional'})</span></label>
                        <select class="form-select" id="tk-service" name="relatedservice">
                            <option value="">{$LANG.none|default:'None'}</option>
                            {foreach $servicelist as $svc}
                            <option value="{$svc.id|escape}"{if isset($relatedservice) && $relatedservice == $svc.id} selected{/if}>{$svc.name|default:$svc.product|escape}{if isset($svc.domain) && $svc.domain} — {$svc.domain|escape}{/if}</option>
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
                {foreach $customfields as $cf}
                <div class="form-group">
                    <label class="form-label" for="tk-cf-{$cf.id|escape}">{$cf.name|escape|strip_tags}{if !empty($cf.required)} <span class="tk-req">*</span>{/if}</label>
                    {if $cf.type == 'textarea'}
                    <textarea class="form-input" id="tk-cf-{$cf.id|escape}" name="customfield[{$cf.id|escape}]" rows="4"{if !empty($cf.required)} required{/if}>{$cf.value|default:''|escape}</textarea>
                    {else}
                    <input type="text" class="form-input" id="tk-cf-{$cf.id|escape}" name="customfield[{$cf.id|escape}]" value="{$cf.value|default:''|escape}"{if !empty($cf.required)} required{/if}>
                    {/if}
                    {if isset($cf.description) && $cf.description}<p class="form-help">{$cf.description|strip_tags|escape}</p>{/if}
                </div>
                {/foreach}
                {/if}

                <div class="form-group">
                    <label class="tk-drop">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M21.44 11.05l-9.19 9.19a6 6 0 01-8.49-8.49l9.19-9.19a4 4 0 015.66 5.66l-9.2 9.19a2 2 0 01-2.83-2.83l8.49-8.48"/></svg>
                        {$LANG.addattachments|default:'Add attachments…'}
                        <input type="file" name="attachments[]" multiple style="display:none;">
                    </label>
                    <div class="tk-drop-hint">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                        {$LANG.attachmentsallowed|default:'Allowed: .jpg, .gif, .jpeg, .png, .txt, .pdf · Max 64MB'}
                    </div>
                </div>

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
