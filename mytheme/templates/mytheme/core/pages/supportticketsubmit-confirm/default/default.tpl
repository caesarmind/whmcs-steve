{* Hostnodes - Ticket submitted (Apple-style): post-submit confirmation.
   WHMCS variables (Lagom supportticketsubmit-confirm.tpl): $tid (ticket id/mask), $c (verification hash).
*}
{assign var=tkTid value=$tid|default:''}
{assign var=isPreview value=false}
{if isset($smarty.get.preview) && $smarty.get.preview == '1'}{assign var=isPreview value=true}{/if}
{if !$tkTid && $isPreview}{assign var=tkTid value='HNX-481923'}{/if}
{assign var=dashIsEmpty value='full'}

<link rel="stylesheet" href="{$WEB_ROOT}/templates/{$template}/assets/css/pages/supportticketsubmit-confirm.css?v={$myTheme.version|default:'1.0'}">

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
    <h1>{$LANG.supportticketsticketcreated|default:'Ticket created'}</h1>
</header>

<div class="card tk-wrap" style="margin: 0 auto;">
    <div class="tk-notice">
        <div class="tk-notice-ico ok">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"/></svg>
        </div>
        <p class="tk-notice-title">{$LANG.supportticketsticketcreated|default:'Ticket created'}{if $tkTid} #{$tkTid|escape}{/if}</p>
        <p class="tk-notice-sub">{$LANG.supportticketsticketcreateddesc|default:'Your ticket has been submitted. Our team will reply by email and you can follow the conversation in your client area.'}</p>
        {if $tkTid}
        <a href="{$WEB_ROOT}/viewticket.php?tid={$tkTid|escape}{if isset($c)}&amp;c={$c|escape}{/if}" class="btn-primary">{$LANG.viewticket|default:'View ticket'}</a>
        {else}
        <a href="{$WEB_ROOT}/supporttickets.php" class="btn-primary">{$LANG.mytickets|default:'My tickets'}</a>
        {/if}
    </div>
</div>
