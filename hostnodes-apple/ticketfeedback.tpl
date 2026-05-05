{* =========================================================================
   ticketfeedback.tpl — rating prompt linked from ticket reply email.
   ========================================================================= *}
<div class="page-header"><h1 class="page-title">{lang key='feedbackSystem.title'}</h1></div>

<div class="card">
    <div class="card-body text-center">
        {if $alreadyrated}
            <div class="auth-logo info-icon"><i class="fas fa-check"></i></div>
            <h2>{lang key='feedbackSystem.alreadyRatedTitle'}</h2>
            <p>{lang key='feedbackSystem.alreadyRatedMsg'}</p>
        {elseif $success}
            <div class="auth-logo success-icon"><i class="fas fa-check"></i></div>
            <h2>{lang key='feedbackSystem.thankyou'}</h2>
        {else}
            <p>{lang key='feedbackSystem.message'}</p>
            <form method="post" action="{$smarty.server.PHP_SELF}">
                <input type="hidden" name="tid" value="{$tid}">
                <input type="hidden" name="c" value="{$c}">
                <div class="rating-input">
                    {for $rate=5 to 1 step -1}
                        <label><input type="radio" name="rating" value="{$rate}"> <span class="star"></span></label>
                    {/for}
                </div>
                <div class="form-group">
                    <label for="inputComments" class="form-label">{lang key='feedbackSystem.comments'}</label>
                    <textarea name="comments" id="inputComments" rows="6" class="form-input"></textarea>
                </div>
                <button type="submit" class="btn btn-primary btn-lg">{lang key='submit'}</button>
            </form>
        {/if}
    </div>
</div>
