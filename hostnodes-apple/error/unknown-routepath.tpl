{* =========================================================================
   Fallback when the previous page yielded a broken route. Re-uses the 404
   body and appends the referrer detail.
   ========================================================================= *}
{include file="$template/error/page-not-found.tpl"}

<div class="auth-container">
    <div class="auth-card">
        {include file="$template/includes/alert.tpl" type="info" textcenter=true msg="Sorry, but the previous page (<a href='"|cat:$referrer|escape|cat:"'>"|cat:$referrer|escape|cat:"</a>) provided an invalid page link."}
    </div>
</div>
