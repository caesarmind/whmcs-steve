{* =========================================================================
   supportticketsubmit-confirm.tpl — confirmation after ticket submission.
   ========================================================================= *}
<div class="card">
    <div class="card-body text-center">
        <div class="auth-logo success-icon"><i class="fas fa-check"></i></div>
        <h1 class="auth-title">{lang key='supportticketsticketopened'}</h1>
        <p>{lang key='supportticketsreceived'}</p>
        <p><strong>{lang key='supportticketsreceivednum'}:</strong> #{$tid}</p>

        <div class="btn-group mt-3">
            <a href="viewticket.php?tid={$tid}&amp;c={$c}" class="btn btn-primary">{lang key='supportticketsviewticket'}</a>
            <a href="supporttickets.php" class="btn btn-secondary">{lang key='supportticketsbacktolist'}</a>
        </div>
    </div>
</div>
