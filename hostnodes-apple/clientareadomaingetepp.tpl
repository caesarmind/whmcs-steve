{* =========================================================================
   clientareadomaingetepp.tpl — EPP/auth code retrieval.
   ========================================================================= *}
<div class="card">
    <div class="card-header"><h3 class="card-title">{lang key='domaingeteppcode'}</h3></div>
    <div class="card-body">
        <p>{lang key='domaingeteppcodeexplanation'}</p>

        {if $error}
            {include file="$template/includes/alert.tpl" type="error" msg="<i class='fas fa-exclamation-triangle'></i> {lang key='domaingeteppcodefailure'} $error"}
        {elseif $eppcode}
            {include file="$template/includes/alert.tpl" type="info" msg="<i class='fas fa-info-circle'></i> {lang key='domaingeteppcodeis'} $eppcode"}
        {else}
            {include file="$template/includes/alert.tpl" type="success" msg="<i class='fas fa-check'></i> {lang key='domaingeteppcodeemailconfirmation'}"}
        {/if}
    </div>
</div>
