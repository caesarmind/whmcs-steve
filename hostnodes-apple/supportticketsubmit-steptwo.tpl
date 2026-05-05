{* =========================================================================
   supportticketsubmit-steptwo.tpl — ticket submission form (subject, message,
   attachments, custom fields).
   ========================================================================= *}
<div class="page-header">
    <h1 class="page-title">{lang key='createNewSupportRequest'}</h1>
</div>

<form method="post" action="{$smarty.server.PHP_SELF}?step=3" enctype="multipart/form-data">

<div class="card">
    <div class="card-body">
        {if $errormessage}
            {include file="$template/includes/alert.tpl" type="error" errorshtml=$errormessage}
        {/if}

        <div class="form-row">
            <div class="form-group">
                <label for="inputName" class="form-label">{lang key='supportticketsclientname'}</label>
                <input type="text" name="name" id="inputName" value="{$name}" class="form-input{if $loggedin} disabled{/if}"{if $loggedin} disabled{/if}>
            </div>
            <div class="form-group">
                <label for="inputEmail" class="form-label">{lang key='supportticketsclientemail'}</label>
                <input type="email" name="email" id="inputEmail" value="{$email}" class="form-input{if $loggedin} disabled{/if}"{if $loggedin} disabled{/if}>
            </div>
        </div>

        <div class="form-group">
            <label for="inputSubject" class="form-label">{lang key='supportticketsticketsubject'}</label>
            <input type="text" name="subject" id="inputSubject" value="{$subject}" class="form-input" required>
        </div>

        <div class="form-row">
            <div class="form-group">
                <label for="inputDepartment" class="form-label">{lang key='supportticketsdepartment'}</label>
                <select name="deptid" id="inputDepartment" class="form-input" onchange="refreshCustomFields(this)">
                    {foreach $departments as $department}
                        <option value="{$department.id}"{if $department.id eq $deptid} selected{/if}>{$department.name}</option>
                    {/foreach}
                </select>
            </div>
            {if $relatedservices}
                <div class="form-group">
                    <label for="inputRelatedService" class="form-label">{lang key='relatedservice'}</label>
                    <select name="relatedservice" id="inputRelatedService" class="form-input">
                        <option value="">{lang key='none'}</option>
                        {foreach $relatedservices as $relatedservice}
                            <option value="{$relatedservice.id}"{if $relatedservice.id eq $selectedservice} selected{/if}>{$relatedservice.name} ({$relatedservice.status})</option>
                        {/foreach}
                    </select>
                </div>
            {/if}
            <div class="form-group">
                <label for="inputPriority" class="form-label">{lang key='supportticketspriority'}</label>
                <select name="urgency" id="inputPriority" class="form-input">
                    <option value="High"{if $urgency eq "High"} selected{/if}>{lang key='supportticketsticketurgencyhigh'}</option>
                    <option value="Medium"{if $urgency eq "Medium" || !$urgency} selected{/if}>{lang key='supportticketsticketurgencymedium'}</option>
                    <option value="Low"{if $urgency eq "Low"} selected{/if}>{lang key='supportticketsticketurgencylow'}</option>
                </select>
            </div>
        </div>

        <div class="form-group">
            <label for="inputMessage" class="form-label">{lang key='contactmessage'}</label>
            <textarea name="message" id="inputMessage" rows="12" class="form-input markdown-editor" data-auto-save-name="client_ticket_open" required>{$message}</textarea>
        </div>

        <div class="form-group">
            <label for="inputAttachment1" class="form-label">{lang key='supportticketsticketattachments'}</label>
            <div class="attachment-group">
                <input type="file" class="form-input" name="attachments[]" id="inputAttachment1">
                <button class="btn btn-secondary btn-sm" type="button" id="btnTicketAttachmentsAdd"><i class="fas fa-plus"></i> {lang key='addmore'}</button>
            </div>
            <div class="file-upload w-hidden">
                <div class="attachment-group"><input type="file" class="form-input" name="attachments[]"></div>
            </div>
            <div id="fileUploadsContainer"></div>
            <div class="form-hint">{lang key='supportticketsallowedextensions'}: {$allowedfiletypes} ({lang key="maxFileSize" fileSize="$uploadMaxFileSize"})</div>
        </div>

        <div id="customFieldsContainer">
            {include file="$template/supportticketsubmit-customfields.tpl"}
        </div>

        <div id="autoAnswerSuggestions" class="w-hidden"></div>

        {include file="$template/includes/captcha.tpl"}

        <div class="btn-group">
            <button type="submit" id="openTicketSubmit" class="btn btn-primary disable-on-click{$captcha->getButtonClass($captchaForm)}">{lang key='supportticketsticketsubmit'}</button>
            <a href="supporttickets.php" class="btn btn-secondary">{lang key='cancel'}</a>
        </div>
    </div>
</div>

</form>

{if $kbsuggestions}
    <script>jQuery(document).ready(function() { getTicketSuggestions(); });</script>
{/if}
