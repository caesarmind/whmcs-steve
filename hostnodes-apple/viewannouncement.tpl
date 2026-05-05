{* =========================================================================
   viewannouncement.tpl — single announcement.
   ========================================================================= *}
<div class="page-header">
    <h1 class="page-title">{$announcement.title}</h1>
    <a href="{routePath('announcement-index')}" class="btn btn-secondary btn-sm"><i class="fas fa-arrow-left"></i> {lang key='back'}</a>
</div>

<div class="card">
    <div class="card-header"><div class="form-hint">{$announcement.date}</div></div>
    <div class="card-body markdown-content">{$announcement.announcement}</div>
</div>
