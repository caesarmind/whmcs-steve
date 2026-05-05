{* =========================================================================
   viewemail.tpl — render a single system email.
   ========================================================================= *}
<div class="page-header">
    <h1 class="page-title">{$subject}</h1>
    <a href="{$WEB_ROOT}/clientarea.php?action=emails" class="btn btn-secondary btn-sm"><i class="fas fa-arrow-left"></i> {lang key='back'}</a>
</div>

<div class="card">
    <div class="card-header">
        <div class="form-hint"><strong>{lang key='clientareaemailsdate'}:</strong> {$date}</div>
    </div>
    <div class="card-body email-body">
        {$message}
    </div>
</div>
