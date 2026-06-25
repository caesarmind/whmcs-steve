{* Hostnodes - Ticket feedback (Apple-style): rate a resolved ticket.

   WHMCS variables (cross-checked against Lagom ticketfeedback.tpl):
     $stillopen / $feedbackdone / $success - state flags
     $errormessage  - validation error HTML
     $tid, $c       - ticket id + verification hash
     $opened, $lastreply, $staffinvolvedtext, $duration - ticket meta
     $staffinvolved - staffid => staff name        $ratings - list of rating values
     $rate          - staffid => selected rating    $comments - staffid => text (+ 'generic')
   Form posts to ticketfeedback.php?tid=&c=&feedback=1 (validate=true). Demo under ?preview=1.
*}
{assign var=isPreview value=false}
{if isset($smarty.get.preview) && $smarty.get.preview == '1'}{assign var=isPreview value=true}{/if}

{assign var=fbState value='form'}
{if isset($stillopen) && $stillopen}{assign var=fbState value='stillopen'}
{elseif isset($feedbackdone) && $feedbackdone}{assign var=fbState value='done'}
{elseif isset($success) && $success}{assign var=fbState value='success'}{/if}

{assign var=hasStaff value=false}
{if isset($staffinvolved) && $staffinvolved|@count > 0}{assign var=hasStaff value=true}{/if}

{assign var=fbDemo value=false}
{if $isPreview && $fbState == 'form' && !$hasStaff}
    {assign var=fbDemo value=true}
    {assign var=opened value='May 10, 2026 09:14'}
    {assign var=lastreply value='May 12, 2026 16:40'}
    {assign var=staffinvolvedtext value='Sarah K., Mike R.'}
    {assign var=duration value='2 days, 7 hours'}
    {assign var=staffinvolved value=[1=>'Sarah K.', 2=>'Mike R.']}
    {assign var=ratings value=[1,2,3,4,5]}
    {assign var=hasStaff value=true}
{/if}

{assign var=dashIsEmpty value='full'}

<link rel="stylesheet" href="{$WEB_ROOT}/templates/{$template}/assets/css/pages/ticketfeedback.css?v={$hadrian.version|default:'1.0'}">

<script>
(function () {
    var b = document.body;
    if (!b) return;
    b.setAttribute('data-data',   '{$dashIsEmpty}');
    b.setAttribute('data-subnav', 'off');
})();
</script>

<header class="page-header">
    <p class="page-eyebrow">{$LANG.supporttab|default:'Support'}</p>
    <h1>{$hadrianLang.support.feedbackTitle}</h1>
</header>

<div class="tk-wrap">
{if $fbState == 'stillopen'}
    <div class="card">
        <div class="tk-notice">
            <div class="tk-notice-ico warn"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M10.29 3.86L1.82 18a2 2 0 001.71 3h16.94a2 2 0 001.71-3L13.71 3.86a2 2 0 00-3.42 0z"/><line x1="12" y1="9" x2="12" y2="13"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg></div>
            <p class="tk-notice-title">{$hadrianLang.support.feedbackClosedTitle}</p>
            <p class="tk-notice-sub">{$LANG.feedbackclosed}</p>
            <a href="{$WEB_ROOT}/clientarea.php" class="btn-primary">{$LANG.returnclient}</a>
        </div>
    </div>
{elseif $fbState == 'done' || $fbState == 'success'}
    <div class="card">
        <div class="tk-notice">
            <div class="tk-notice-ico ok"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"/></svg></div>
            <p class="tk-notice-title">{if $fbState == 'done'}{$LANG.feedbackprovided}{else}{$LANG.feedbackreceived}{/if}</p>
            <p class="tk-notice-sub">{$LANG.feedbackthankyou}</p>
            <a href="{$WEB_ROOT}/clientarea.php" class="btn-primary">{$LANG.returnclient}</a>
        </div>
    </div>
{else}
    {if isset($errormessage) && $errormessage}
    <div style="display:flex;gap:10px;padding:13px 16px;border-radius:12px;background:var(--color-red-bg);color:var(--color-red-text);font-size:13px;margin-bottom:16px;">
        <svg viewBox="0 0 24 24" width="17" height="17" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
        <div>{$errormessage|strip_tags}</div>
    </div>
    {/if}

    <div class="card" style="margin-bottom:16px;">
        <div class="card-body">
            <dl class="tk-info">
                <div class="tk-info-row"><span class="tk-info-label">{$LANG.feedbackopenedat}</span><span class="tk-info-val">{$opened|default:'-'|escape}</span></div>
                <div class="tk-info-row"><span class="tk-info-label">{$LANG.feedbacklastreplied}</span><span class="tk-info-val">{$lastreply|default:'-'|escape}</span></div>
                <div class="tk-info-row"><span class="tk-info-label">{$LANG.feedbackstaffinvolved}</span><span class="tk-info-val">{if isset($staffinvolvedtext) && $staffinvolvedtext}{$staffinvolvedtext|escape}{else}{$LANG.none}{/if}</span></div>
                <div class="tk-info-row"><span class="tk-info-label">{$LANG.feedbacktotalduration}</span><span class="tk-info-val">{$duration|default:'-'|escape}</span></div>
            </dl>
        </div>
    </div>

    <form method="post" action="{$WEB_ROOT}/ticketfeedback.php?tid={$tid|default:''|escape}&amp;c={$c|default:''|escape}&amp;feedback=1">
        <input type="hidden" name="validate" value="true">
        <div class="card">
            <div class="card-body">
                {if $hasStaff}
                    {foreach $staffinvolved as $staffid => $staff}
                    <div class="tk-staff-block">
                        <p class="tk-rate-q">{$LANG.feedbackpleaserate1} <strong>{$staff|escape}</strong> {$LANG.feedbackhandled}</p>
                        <div class="tk-rate-group">
                            {foreach $ratings as $rating}
                            <label class="tk-rate-btn">
                                <input type="radio" name="rate[{$staffid|escape}]" value="{$rating|escape}"{if isset($rate[$staffid]) && $rate[$staffid] == $rating} checked{/if}>
                                <span>{$rating|escape}</span>
                            </label>
                            {/foreach}
                        </div>
                        <textarea name="comments[{$staffid|escape}]" rows="3" class="form-textarea" placeholder="{$LANG.feedbackpleasecomment1} {$staff|escape}?">{if isset($comments[$staffid])}{$comments[$staffid]|escape}{/if}</textarea>
                    </div>
                    {/foreach}
                {/if}
                <div class="tk-staff-block">
                    <p class="tk-rate-q">{$LANG.feedbackimprove}</p>
                    <textarea name="comments[generic]" rows="3" class="form-textarea" placeholder="{$hadrianLang.support.feedbackCommentsPlaceholder}">{if isset($comments.generic)}{$comments.generic|escape}{/if}</textarea>
                </div>

                <div class="page-actions" style="margin-top:18px;display:flex;gap:10px;">
                    <button type="submit" name="save" value="1" class="btn-primary">{$LANG.clientareasavechanges}</button>
                    <a href="{$WEB_ROOT}/viewticket.php?tid={$tid|default:''|escape}{if isset($c)}&amp;c={$c|escape}{/if}" class="btn-secondary">{$LANG.feedbackclickreview}</a>
                </div>
            </div>
        </div>
    </form>
{/if}
</div>
