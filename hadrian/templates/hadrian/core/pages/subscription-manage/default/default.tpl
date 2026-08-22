{* Hostnodes - Email subscription management.

   Matches the real WHMCS subscription-manage templatefile (cross-checked against
   Lagom subscription-manage.tpl): an opt-in / opt-out confirmation page.
     $action       - 'optin' | 'optout'
     $errorMessage - error text (if any)
     $infoMessage  - info text (if any)
   Demo data under ?preview=1 shows the opt-out confirmation.
*}

{assign var=isPreview value=false}
{if isset($smarty.get.preview) && $smarty.get.preview == '1'}{assign var=isPreview value=true}{/if}

{assign var=smAction value=$action|default:''}
{assign var=hasError value=false}
{if isset($errorMessage) && $errorMessage}{assign var=hasError value=true}{/if}
{assign var=hasInfo value=false}
{if isset($infoMessage) && $infoMessage}{assign var=hasInfo value=true}{/if}

{if $isPreview && !$hasError && !$hasInfo && !$smAction}{assign var=smAction value='optout'}{/if}

{assign var=dashIsEmpty value='full'}

<link rel="stylesheet" href="{$WEB_ROOT}/templates/{$template}/assets/css/pages/subscription-manage.css?v={$hadrian.version|default:'1.0'}">

<script>
(function () {
    var b = document.body;
    if (!b) return;
    b.setAttribute('data-data',   '{$dashIsEmpty}');
    b.setAttribute('data-subnav', 'off');
})();
</script>

<header class="page-header">
    <p class="page-eyebrow">{$hadrianLang.services.emailSubscriptions}</p>
    <h1>{$hadrianLang.services.subscriptionManage}</h1>
</header>

<div class="card sm-card" style="margin: 0 auto;">
    {if $hasError}
        <div class="sm-ico error">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
        </div>
        <h2 class="sm-title">{$LANG.somethingwentwrong|default:'Something went wrong'}</h2>
        <p class="sm-text">{$errorMessage|strip_tags}</p>
    {elseif $hasInfo}
        <div class="sm-ico">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
        </div>
        <h2 class="sm-title">{$hadrianLang.services.subscriptionUpdated}</h2>
        <p class="sm-text">{$infoMessage|strip_tags}</p>
    {elseif $smAction == 'optin'}
        <div class="sm-ico ok">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M22 11.08V12a10 10 0 11-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg>
        </div>
        <h2 class="sm-title">{$LANG.newslettersubscribed}</h2>
        <p class="sm-text">{$hadrianLang.services.newsletterSubscribedSub}</p>
    {elseif $smAction == 'optout'}
        <div class="sm-ico warn">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"/><polyline points="22,6 12,13 2,6"/></svg>
        </div>
        <h2 class="sm-title">{$LANG.newsletterremoved}</h2>
        <p class="sm-text">{$hadrianLang.services.newsletterResubscribeText} <a href="{$WEB_ROOT}/clientarea.php?action=details">{$hadrianLang.services.newsletterResubscribeLink}</a>.</p>
    {else}
        <div class="sm-ico">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"/><polyline points="22,6 12,13 2,6"/></svg>
        </div>
        <h2 class="sm-title">{$hadrianLang.services.emailSubscriptions}</h2>
        <p class="sm-text">{$hadrianLang.services.subscriptionManageSub} <a href="{$WEB_ROOT}/clientarea.php?action=details">{$hadrianLang.services.accountSettings}</a>.</p>
    {/if}

    <a href="{$WEB_ROOT}/clientarea.php" class="btn-primary">{$LANG.returnhome}</a>
</div>
