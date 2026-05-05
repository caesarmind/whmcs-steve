{* =========================================================================
   viewticket.tpl — ticket detail with reply thread and reply form.
   ========================================================================= *}
{if $invalidTicketId}
    {include file="$template/includes/alert.tpl" type="danger" title="{lang key='thereisaproblem'}" msg="{lang key='supportticketinvalid'}" textcenter=true}
{else}
    {if $closedticket}
        {include file="$template/includes/alert.tpl" type="warning" msg="{lang key='supportticketclosedmsg'}" textcenter=true}
    {/if}
    {if $errormessage}
        {include file="$template/includes/alert.tpl" type="error" errorshtml=$errormessage}
    {/if}
{/if}

{if !$invalidTicketId}
    <div class="card view-ticket">
        <div class="card-header">
            <h3 class="card-title">
                {lang key='supportticketsviewticket'} #{$tid}
                <span class="form-hint">{lang key='supportticketssubject'}: <strong>{$subject}</strong></span>
            </h3>
            <div class="ticket-actions">
                <button type="button" class="btn btn-secondary btn-sm" onclick="smoothScroll('#ticketReplyContainer')">
                    <i class="fas fa-pencil-alt"></i> {lang key='supportticketsreply'}
                </button>
                {if $showCloseButton}
                    {if $closedticket}
                        <button class="btn btn-danger btn-sm" disabled><i class="fas fa-times"></i> {lang key='supportticketsstatusclosed'}</button>
                    {else}
                        <a class="btn btn-danger btn-sm" href="?tid={$tid}&amp;c={$c}&amp;closeticket=true"><i class="fas fa-times"></i> {lang key='supportticketsclose'}</a>
                    {/if}
                {/if}
            </div>
        </div>

        <div class="conversation">
            {foreach $descreplies as $reply}
                <div class="conversation-entry{if $reply.admin} staff{/if}">
                    <div class="conversation-meta">
                        <span class="conversation-author">{$reply.requestor.name}</span>
                        <span class="conversation-date">{$reply.date}</span>
                        <span class="status-pill requestor-type-{$reply.requestor.type_normalised}">{lang key='support.requestor.'|cat:$reply.requestor.type_normalised}</span>
                    </div>
                    <div class="conversation-message markdown-content">
                        {$reply.message}
                        {if $reply.ipaddress}<hr><div class="form-hint">{lang key='support.ipAddress'}: {$reply.ipaddress}</div>{/if}
                    </div>
                    {if $reply.attachments}
                        <div class="conversation-attachments">
                            <strong><i class="far fa-paperclip"></i> {lang key='supportticketsticketattachments'} ({$reply.attachments|count})</strong>
                            {if $reply.attachments_removed} - {lang key='support.attachmentsRemoved'}{/if}
                            <ul class="attachment-list">
                                {foreach $reply.attachments as $num => $attachment}
                                    <li>
                                        {if $reply.attachments_removed}
                                            <span><i class="far fa-file-minus"></i> {$attachment}</span>
                                        {else}
                                            <a href="dl.php?type={if $reply.id}ar&id={$reply.id}{else}a&id={$id}{/if}&i={$num}">
                                                <i class="far fa-paperclip"></i> {$attachment}
                                            </a>
                                        {/if}
                                    </li>
                                {/foreach}
                            </ul>
                        </div>
                    {/if}
                    {if $reply.id && $reply.admin && $ratingenabled}
                        <div class="conversation-rating">
                            {if $reply.rating}
                                <div class="rating-done">
                                    {for $rating=1 to 5}
                                        <span class="star{if (5 - $reply.rating) < $rating} active{/if}"></span>
                                    {/for}
                                    <div class="rated">{lang key='ticketreatinggiven'}</div>
                                </div>
                            {else}
                                <div class="rating" ticketid="{$tid}" ticketkey="{$c}" ticketreplyid="{$reply.id}">
                                    {for $rate=5 to 1 step -1}
                                        <span class="star" rate="{$rate}"></span>
                                    {/for}
                                </div>
                            {/if}
                        </div>
                    {/if}
                </div>
            {/foreach}
        </div>
    </div>

    {if !$closedticket || $showReopenButton}
        <div class="card" id="ticketReplyContainer">
            <div class="card-header"><h3 class="card-title">{lang key='supportticketsreply'}</h3></div>
            <div class="card-body">
                <form method="post" action="{$smarty.server.PHP_SELF}?tid={$tid}&amp;c={$c}" enctype="multipart/form-data">
                    <input type="hidden" name="action" value="reply">
                    <div class="form-group">
                        <label for="inputMessage" class="form-label">{lang key='contactmessage'}</label>
                        <textarea name="message" id="inputMessage" rows="12" class="form-input markdown-editor" required></textarea>
                    </div>
                    <div class="form-group">
                        <label class="form-label">{lang key='supportticketsticketattachments'}</label>
                        <input type="file" class="form-input" name="attachments[]">
                        <div class="form-hint">{lang key='supportticketsallowedextensions'}: {$allowedfiletypes}</div>
                    </div>
                    {include file="$template/includes/captcha.tpl"}
                    <div class="btn-group">
                        <button type="submit" class="btn btn-primary{$captcha->getButtonClass($captchaForm)}">{lang key='supportticketsticketsubmit'}</button>
                        <a href="supporttickets.php" class="btn btn-secondary">{lang key='cancel'}</a>
                    </div>
                </form>
            </div>
        </div>
    {/if}
{/if}
