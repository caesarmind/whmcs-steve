{* =========================================================================
   viewbillingnote.tpl — render a single billing note.
   ========================================================================= *}
<div class="page-header">
    <h1 class="page-title">{lang key='billingNote.title'} #{$note.id}</h1>
    <a href="{$WEB_ROOT}/clientarea.php?action=invoices" class="btn btn-secondary btn-sm"><i class="fas fa-arrow-left"></i> {lang key='back'}</a>
</div>

<div class="card">
    <div class="card-header">
        <div class="form-hint"><strong>{lang key='date'}:</strong> {$note.date}</div>
    </div>
    <div class="card-body">
        <h3>{$note.subject}</h3>
        <div class="markdown-content">{$note.body}</div>
    </div>
</div>
