{* Hostnodes — View Support Ticket (Apple-style).

   WHMCS standard variables expected:
     $ticketid, $tid, $c, $subject, $status, $priority, $department, $service,
     $lastreply, $date
     $replies      — array of replies, each: name, requestor_type, date,
                     message, attachments, attachments_removed, useremail,
                     userid
     $attachments  — ticket-level attachments
     $clientsdetails  — for the author bar (firstname, lastname, email)
*}

{if isset($ticketid) && $ticketid}
    {assign var=dashIsEmpty value='full'}
{else}
    {assign var=dashIsEmpty value='empty'}
{/if}
{assign var=tktStatusLower value=$status|default:''|lower|replace:' ':'-'}
{assign var=tktPriorityLower value=$priority|default:''|lower}

{* Page-specific stylesheet *}
<link rel="stylesheet" href="{$WEB_ROOT}/templates/{$template}/assets/css/pages/viewticket.css?v={$myTheme.version|default:'1.0'}">

<script>
(function () {
    var b = document.body;
    if (!b) return;
    b.setAttribute('data-data', '{$dashIsEmpty}');
})();
</script>

<header class="tk-page-head">
    <div style="flex: 1; min-width: 0;">
        <p class="tk-page-head-id">#{$tid|default:$ticketid|escape}</p>
        <h1>{$subject|escape}</h1>
    </div>
    {if $tktStatusLower != 'closed'}
    <form method="post" action="{$WEB_ROOT}/viewticket.php?tid={$tid|escape}{if isset($c) && $c}&c={$c|escape}{/if}" style="display:inline;">
        <input type="hidden" name="action" value="close">
        <button type="submit" class="tk-close-btn">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="4.93" y1="4.93" x2="19.07" y2="19.07"/></svg>
            {$LANG.supportticketsclose|default:'Close Ticket'}
        </button>
    </form>
    {/if}
</header>

<div class="when-full"><div class="tk-view-split">

    {* ══ MAIN ══ *}
    <div class="tk-view-main">

        {* Conversation thread *}
        <div>
            <h2 class="tk-section-title">{$LANG.conversation|default:'Conversation'}</h2>
            <div class="card tk-thread-card">
                <div class="thread">
                    {if isset($replies) && $replies|count > 0}
                        {foreach $replies as $reply}
                        {if isset($reply.requestor_type) && $reply.requestor_type == 'admin'}
                            {assign var=msgClass value='staff'}
                        {else}
                            {assign var=msgClass value='client'}
                        {/if}
                        <div class="thread-message {$msgClass}">
                            <div class="thread-sender">{$reply.name|default:''|escape}</div>
                            <div class="thread-bubble">
                                {$reply.message}
                                {if isset($reply.attachments) && $reply.attachments|count > 0}
                                <div class="thread-attachments">
                                    {foreach $reply.attachments as $att}
                                    <a href="{$WEB_ROOT}/dl.php?type=ar&id={$reply.id|default:0}&i={$att@index}" class="thread-att">
                                        <div class="thread-att-ico">{$att|default:''|substr:-3|upper|escape}</div>
                                        <div class="thread-att-meta">
                                            <div class="thread-att-name">{$att|escape}</div>
                                        </div>
                                        <div class="thread-att-dl" aria-label="{$LANG.download|default:'Download'}">
                                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M21 15v4a2 2 0 01-2 2H5a2 2 0 01-2-2v-4"/><polyline points="7 10 12 15 17 10"/><line x1="12" y1="15" x2="12" y2="3"/></svg>
                                        </div>
                                    </a>
                                    {/foreach}
                                </div>
                                {/if}
                            </div>
                            <div class="thread-time">{$reply.date|default:''|escape}</div>
                        </div>
                        {/foreach}
                    {/if}
                </div>
            </div>
        </div>

        {* Ticket Settings card with tabs *}
        {if $tktStatusLower != 'closed'}
        <div>
            <h2 class="tk-section-title">{$LANG.ticketsettings|default:'Ticket Settings'}</h2>
            <div class="card" style="padding: 0;">
                <div class="tk-tabs" role="tablist">
                    <button type="button" class="tk-tab active" data-tab="reply" role="tab" aria-selected="true">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" style="width:13px;height:13px;"><polyline points="9 17 4 12 9 7"/><path d="M20 18v-2a4 4 0 00-4-4H4"/></svg>
                        {$LANG.supportticketsreply|default:'Reply'}
                    </button>
                </div>

                <div class="tk-tab-panel active" data-panel="reply" role="tabpanel">
                    <div class="tk-author">
                        <div class="tk-author-avatar">{$clientsdetails.firstname|default:'?'|escape|substr:0:1|upper}</div>
                        <div>
                            <div class="tk-author-name">{$clientsdetails.firstname|default:''|escape} {$clientsdetails.lastname|default:''|escape}</div>
                            <div class="tk-author-email">{$clientsdetails.email|default:''|escape}</div>
                        </div>
                    </div>

                    <form method="post" action="{$WEB_ROOT}/viewticket.php?tid={$tid|escape}{if isset($c) && $c}&c={$c|escape}{/if}" enctype="multipart/form-data">
                        <input type="hidden" name="action" value="reply">
                        <div class="tk-editor">
                            <textarea class="tk-editor-area" name="message" placeholder="{$LANG.writeyourreply|default:'Write your reply…'}" required></textarea>
                        </div>

                        <label class="tk-drop">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M21.44 11.05l-9.19 9.19a6 6 0 01-8.49-8.49l9.19-9.19a4 4 0 015.66 5.66l-9.2 9.19a2 2 0 01-2.83-2.83l8.49-8.48"/></svg>
                            {$LANG.addattachments|default:'Add Attachments…'}
                            <input type="file" name="attachments[]" multiple style="display:none;">
                        </label>
                        <div class="tk-drop-hint">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                            {$LANG.attachmentsallowed|default:'Allowed extensions: .jpg, .gif, .jpeg, .png, .txt, .pdf · Max file size: 64MB'}
                        </div>

                        <div class="tk-reply-foot">
                            <button type="submit" class="btn-primary">{$LANG.sendmessage|default:'Send Message'}</button>
                            <a href="{$WEB_ROOT}/supporttickets.php" class="btn-secondary">{$LANG.cancel|default:'Cancel'}</a>
                        </div>
                    </form>
                </div>
            </div>
        </div>
        {/if}

    </div>

    {* ══ RIGHT: Ticket information ══ *}
    <aside class="tk-view-aside">
        <div>
            <h2 class="tk-section-title">{$LANG.ticketinformation|default:'Ticket Information'}</h2>
            <div class="card tk-info-card">
                <div class="tk-info-row">
                    <div class="tk-info-ico"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M4 15s1-1 4-1 5 2 8 2 4-1 4-1V3s-1 1-4 1-5-2-8-2-4 1-4 1z"/><line x1="4" y1="22" x2="4" y2="15"/></svg></div>
                    <div class="tk-info-body">
                        <div class="tk-info-label">{$LANG.supportticketsstatus|default:'Status'}</div>
                        <div class="tk-info-value"><span class="status-pill {$tktStatusLower}">{$status|escape}</span></div>
                    </div>
                </div>
                {if isset($clientsdetails)}
                <div class="tk-info-row">
                    <div class="tk-info-ico"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M20 21v-2a4 4 0 00-4-4H8a4 4 0 00-4 4v2"/><circle cx="12" cy="7" r="4"/></svg></div>
                    <div class="tk-info-body">
                        <div class="tk-info-label">{$LANG.requestor|default:'Requestor'}</div>
                        <div class="tk-info-value">
                            <div class="tk-info-user">
                                <div class="tk-info-avatar">{$clientsdetails.firstname|default:'?'|escape|substr:0:1|upper}</div>
                                <div>
                                    <div style="font-size:13px; font-weight:500; color:var(--color-text-primary);">{$clientsdetails.firstname|default:''|escape} {$clientsdetails.lastname|default:''|escape}</div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                {/if}
                {if $department}
                <div class="tk-info-row">
                    <div class="tk-info-ico"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M4 15s1-1 4-1 5 2 8 2 4-1 4-1V3s-1 1-4 1-5-2-8-2-4 1-4 1z"/><line x1="4" y1="22" x2="4" y2="15"/></svg></div>
                    <div class="tk-info-body">
                        <div class="tk-info-label">{$LANG.supportticketsdepartment|default:'Department'}</div>
                        <div class="tk-info-value">{$department|escape}</div>
                    </div>
                </div>
                {/if}
                {if isset($date) && $date}
                <div class="tk-info-row">
                    <div class="tk-info-ico"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg></div>
                    <div class="tk-info-body">
                        <div class="tk-info-label">{$LANG.supportticketssubmitted|default:'Submitted'}</div>
                        <div class="tk-info-value">{$date|escape}</div>
                    </div>
                </div>
                {/if}
                {if isset($lastreply) && $lastreply}
                <div class="tk-info-row">
                    <div class="tk-info-ico"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg></div>
                    <div class="tk-info-body">
                        <div class="tk-info-label">{$LANG.supportticketslastupdated|default:'Last Updated'}</div>
                        <div class="tk-info-value">{$lastreply|escape}</div>
                    </div>
                </div>
                {/if}
                {if isset($priority) && $priority}
                <div class="tk-info-row">
                    <div class="tk-info-ico"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg></div>
                    <div class="tk-info-body">
                        <div class="tk-info-label">{$LANG.supportticketspriority|default:'Priority'}</div>
                        <div class="tk-info-value"><span class="tk-prio-pill {$tktPriorityLower}">{$priority|escape}</span></div>
                    </div>
                </div>
                {/if}
            </div>
        </div>
    </aside>
</div></div>

<div class="when-empty" style="text-align:center;padding:60px 24px;background:var(--color-surface);border:1px solid var(--color-border);border-radius:14px;">
    <div style="width:56px;height:56px;border-radius:50%;background:var(--color-bg);display:inline-flex;align-items:center;justify-content:center;margin-bottom:16px;color:var(--color-text-tertiary);">
        <svg viewBox="0 0 24 24" width="22" height="22" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round">
            <path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"/>
        </svg>
    </div>
    <p style="font-size:17px;font-weight:600;color:var(--color-text-primary);margin:0 0 6px;">{$LANG.ticketnotavailable|default:'Ticket not available'}</p>
    <p style="font-size:14px;color:var(--color-text-secondary);margin:0 0 20px;max-width:380px;margin-left:auto;margin-right:auto;line-height:1.5;">{$LANG.ticketnotavailablesub|default:'This ticket may be closed, archived, or no longer accessible.'}</p>
    <a href="{$WEB_ROOT}/supporttickets.php" class="btn-primary">{$LANG.alltickets|default:'All tickets'}</a>
</div>
