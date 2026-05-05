{* =========================================================================
   affiliatessignup.tpl — opt-in to the affiliate program.
   ========================================================================= *}
<div class="page-header"><h1 class="page-title">{lang key='affiliatestitle'}</h1></div>

<div class="card">
    <div class="card-body text-center">
        <div class="auth-logo info-icon"><i class="fas fa-handshake"></i></div>
        <h2>{lang key='affiliatessignup'}</h2>
        <p>{lang key='affiliatessignupinfo'}</p>

        <form method="post" action="{$smarty.server.PHP_SELF}">
            <input type="hidden" name="signup" value="true">
            <button type="submit" class="btn btn-primary btn-lg">{lang key='affiliatessignupbtn'}</button>
        </form>
    </div>
</div>
