{* Hostnodes — View Support Ticket.

   WHMCS standard variables on viewticket.php:
     $tid, $c, $id, $subject, $status, $priority, $department, $service,
     $lastreply, $date
     $invalidTicketId  — bool; true when the ticket isn't accessible
     $closedticket     — bool; true if the ticket is closed
     $descreplies      — the WHOLE conversation (opening post + every reply),
                         newest first. Each item: id, name, admin (bool),
                         date, message, attachments (filename strings),
                         attachments_removed (bool), email, requestor.
                         The opening post is the last element (id empty).
                         There is NO separate $message / top-level $attachments.
     $id               — numeric ticket id, used for opening-post downloads
                         (dl.php?type=a&id={$id}); replies use type=ar&id={$reply.id}
     $clientsdetails   — author bar (firstname, lastname, email)
*}

{* Trap: earlier version of this tpl gated on $ticketid which WHMCS doesn't
   set — page always rendered "Ticket not available". Gate on $tid existing
   AND $invalidTicketId not being truthy. *}
{if !isset($invalidTicketId) || !$invalidTicketId}
    {if (isset($tid) && $tid) || (isset($replies) && $replies|@count > 0)}
        {assign var=dashIsEmpty value='full'}
    {else}
        {assign var=dashIsEmpty value='empty'}
    {/if}
{else}
    {assign var=dashIsEmpty value='empty'}
{/if}
{* WHMCS wraps $status in <span style="color:#XXX">Status</span> markup.
   Strip the HTML before piping into a class attribute (per §10 trap)
   AND before using as visible text. *}
{assign var=tktStatusText value=$status|default:''|strip_tags}
{assign var=tktStatusLower value=$tktStatusText|lower|replace:' ':'-'}
{assign var=tktPriorityLower value=$priority|default:''|lower}

{* Page-specific stylesheet *}
<link rel="stylesheet" href="{$WEB_ROOT}/templates/{$template}/assets/css/pages/viewticket.css?v={$hadrian.version|default:'1.0'}">

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
    {* WHMCS expects closeticket=true as a URL parameter on a simple GET
       (verified against Nexus). Not a POST with name="action" value="close" —
       that path triggers "An invalid request was made". *}
    <a href="{$WEB_ROOT}/viewticket.php?tid={$tid|escape}{if isset($c) && $c}&c={$c|escape}{/if}&closeticket=true"
       class="tk-close-btn"
       onclick="return confirm('{$LANG.confirmcloseticket|default:'Close this ticket?'}');">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="4.93" y1="4.93" x2="19.07" y2="19.07"/></svg>
        {$LANG.supportticketsclose}
    </a>
    {/if}
</header>

<div class="when-full"><div class="tk-view-split">

    {* ══ MAIN ══ *}
    <div class="tk-view-main">

        {* Conversation thread — initial ticket message + every reply.
           WHMCS keeps the original post in $message (separate from $replies),
           so we render it as the first client bubble before iterating replies. *}
        <div>
            <h2 class="tk-section-title">{$hadrianLang.support.conversation}</h2>
            <div class="card tk-thread-card">
                <div class="thread">
                    {* The whole conversation — the opening post AND every reply —
                       comes from $descreplies (newest first). All stock WHMCS themes
                       (nexus, lagom, hadrian) iterate this single collection;
                       there is no separate $message or top-level $attachments, which
                       is why opening-post attachments were previously invisible.
                       .thread is column-reverse (viewticket.css) so the opening post
                       stays at the top. Use |@count for Collection-safe length. *}
                    {if isset($descreplies) && $descreplies|@count > 0}
                        {foreach from=$descreplies key=rnum item=reply}
                        {if isset($reply.admin) && $reply.admin}
                            {assign var=msgClass value='staff'}
                        {else}
                            {assign var=msgClass value='client'}
                        {/if}
                        <div class="thread-message {$msgClass}">
                            <div class="thread-sender">{$reply.name|default:'Client'|escape}</div>
                            <div class="thread-bubble">
                                {$reply.message}
                                {if isset($reply.attachments) && $reply.attachments|@count > 0}
                                <div class="thread-attachments">
                                    {if isset($reply.attachments_removed) && $reply.attachments_removed}
                                    <p class="thread-att-removed">{$LANG.support.attachmentsRemoved}</p>
                                    {/if}
                                    {foreach from=$reply.attachments key=anum item=attachment}
                                    {if isset($reply.attachments_removed) && $reply.attachments_removed}
                                    <span class="thread-att is-removed">
                                        <div class="thread-att-ico">{$attachment|default:''|substr:-3|upper|escape}</div>
                                        <div class="thread-att-meta"><div class="thread-att-name">{$attachment|escape}</div></div>
                                    </span>
                                    {else}
                                    <a href="{$WEB_ROOT}/dl.php?type={if $reply.id}ar&id={$reply.id|escape}{else}a&id={$id|escape}{/if}&i={$anum}" class="thread-att">
                                        <div class="thread-att-ico">{$attachment|default:''|substr:-3|upper|escape}</div>
                                        <div class="thread-att-meta"><div class="thread-att-name">{$attachment|escape}</div></div>
                                        <div class="thread-att-dl" aria-label="{$LANG.download|default:'Download'}">
                                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M21 15v4a2 2 0 01-2 2H5a2 2 0 01-2-2v-4"/><polyline points="7 10 12 15 17 10"/><line x1="12" y1="15" x2="12" y2="3"/></svg>
                                        </div>
                                    </a>
                                    {/if}
                                    {/foreach}
                                </div>
                                {/if}
                            </div>
                            <div class="thread-time">{$reply.date|default:''|escape}</div>
                        </div>
                        {/foreach}
                    {else}
                    <div class="thread-empty">{$hadrianLang.support.noTicketReplies}</div>
                    {/if}
                </div>
            </div>
        </div>

        {* Ticket Settings card with tabs *}
        {if $tktStatusLower != 'closed'}
        <div>
            <h2 class="tk-section-title">{$hadrianLang.support.ticketSettings}</h2>
            <div class="card" style="padding: 0;">
                <div class="tk-tabs" role="tablist">
                    <button type="button" class="tk-tab active" data-tab="reply" role="tab" aria-selected="true">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" style="width:13px;height:13px;"><polyline points="9 17 4 12 9 7"/><path d="M20 18v-2a4 4 0 00-4-4H4"/></svg>
                        {$LANG.supportticketsreply}
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

                    {* WHMCS expects postreply=true as a URL parameter (verified against
                       Nexus and Lagom). Not a POST with name="action" value="reply" —
                       that path triggers "An invalid request was made". *}
                    <form method="post" action="{$WEB_ROOT}/viewticket.php?tid={$tid|escape}{if isset($c) && $c}&c={$c|escape}{/if}&postreply=true" enctype="multipart/form-data">
                        <input type="hidden" name="token" value="{$token|default:''|escape}">
                        <div class="tk-editor">
                            <textarea class="tk-editor-area" name="replymessage" placeholder="{$hadrianLang.support.writeYourReply}" required></textarea>
                        </div>

                        <div class="tk-attach-group">
                            <div class="tk-attach-rows" id="tk-attach-rows">
                                <div class="tk-attach-row">
                                    <label class="tk-drop">
                                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M21.44 11.05l-9.19 9.19a6 6 0 01-8.49-8.49l9.19-9.19a4 4 0 015.66 5.66l-9.2 9.19a2 2 0 01-2.83-2.83l8.49-8.48"/></svg>
                                        <span class="tk-drop-label">{$LANG.chooseFile}</span>
                                        <input type="file" name="attachments[]">
                                    </label>
                                    <button type="button" class="tk-attach-remove" aria-label="{$LANG.orderForm.remove}" hidden>
                                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg>
                                    </button>
                                </div>
                            </div>
                            <button type="button" class="tk-attach-add" id="tk-attach-add">
                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
                                {$LANG.addmore}
                            </button>
                            <div class="tk-drop-hint">
                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                                {if isset($allowedfiletypes) && $allowedfiletypes}{$LANG.supportticketsallowedextensions}: {$allowedfiletypes}{if isset($uploadMaxFileSize) && $uploadMaxFileSize} &middot; {lang key="maxFileSize" fileSize=$uploadMaxFileSize}{/if}{else}{$hadrianLang.support.attachmentsAllowedFallback}{/if}
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
                                        } else { resetRow(row); }
                                        refreshRemoveButtons();
                                    });
                                }
                                if (rm) {
                                    rm.addEventListener('click', function () {
                                        if (allRows().length > 1) { row.parentNode.removeChild(row); }
                                        else { resetRow(row); }
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

                        <div class="tk-reply-foot">
                            <button type="submit" name="save" value="1" class="btn-primary">{$hadrianLang.support.sendMessage}</button>
                            <a href="{$WEB_ROOT}/supporttickets.php" class="btn-secondary">{$LANG.cancel}</a>
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
            <h2 class="tk-section-title">{$LANG.ticketinfo}</h2>
            <div class="card tk-info-card">
                <div class="tk-info-row">
                    <div class="tk-info-ico"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M4 15s1-1 4-1 5 2 8 2 4-1 4-1V3s-1 1-4 1-5-2-8-2-4 1-4 1z"/><line x1="4" y1="22" x2="4" y2="15"/></svg></div>
                    <div class="tk-info-body">
                        <div class="tk-info-label">{$LANG.supportticketsstatus}</div>
                        <div class="tk-info-value"><span class="status-pill {$tktStatusLower}">{$tktStatusText|escape}</span></div>
                    </div>
                </div>
                {if isset($clientsdetails)}
                <div class="tk-info-row">
                    <div class="tk-info-ico"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M20 21v-2a4 4 0 00-4-4H8a4 4 0 00-4 4v2"/><circle cx="12" cy="7" r="4"/></svg></div>
                    <div class="tk-info-body">
                        <div class="tk-info-label">{$hadrianLang.support.requestor}</div>
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
                        <div class="tk-info-label">{$LANG.supportticketsdepartment}</div>
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
                        <div class="tk-info-label">{$LANG.supportticketsticketlastupdated}</div>
                        <div class="tk-info-value">{$lastreply|escape}</div>
                    </div>
                </div>
                {/if}
                {if isset($priority) && $priority}
                <div class="tk-info-row">
                    <div class="tk-info-ico"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg></div>
                    <div class="tk-info-body">
                        <div class="tk-info-label">{$LANG.supportticketspriority}</div>
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
    <p style="font-size:17px;font-weight:600;color:var(--color-text-primary);margin:0 0 6px;">{$hadrianLang.support.ticketNotAvailableTitle}</p>
    <p style="font-size:14px;color:var(--color-text-secondary);margin:0 0 20px;max-width:380px;margin-left:auto;margin-right:auto;line-height:1.5;">{$hadrianLang.support.ticketNotAvailableSub}</p>
    <a href="{$WEB_ROOT}/supporttickets.php" class="btn-primary">{$hadrianLang.support.allTickets}</a>
</div>
