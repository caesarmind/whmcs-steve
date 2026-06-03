{* Hostnodes - 3D Secure verification (Apple-style).
   WHMCS variable (Lagom 3dsecure.tpl): $code - the gateway's 3DS form HTML, which is
   auto-submitted into the iframe so the bank's challenge loads inline.
*}
{assign var=isPreview value=false}
{if isset($smarty.get.preview) && $smarty.get.preview == '1'}{assign var=isPreview value=true}{/if}
{assign var=hasCode value=false}
{if isset($code) && $code}{assign var=hasCode value=true}{/if}
{assign var=dashIsEmpty value='full'}

<link rel="stylesheet" href="{$WEB_ROOT}/templates/{$template}/assets/css/pages/3dsecure.css?v={$myTheme.version|default:'1.0'}">

<script>
(function () {
    var b = document.body;
    if (!b) return;
    b.setAttribute('data-data',   '{$dashIsEmpty}');
    b.setAttribute('data-subnav', 'off');
})();
</script>

<header class="page-header">
    <p class="page-eyebrow">{$hadrianLang.billing.paymentEyebrow}</p>
    <h1>{$hadrianLang.billing.verifyPaymentTitle}</h1>
</header>

<div class="tds-wrap">
    <div class="tds-info">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="11" width="18" height="11" rx="2"/><path d="M7 11V7a5 5 0 0110 0v4"/></svg>
        <div>{$LANG.creditcard3dsecure}</div>
    </div>

    <div class="card tds-frame-card">
        {if $hasCode}
            <div id="frmThreeDAuth" class="tds-hidden">{$code}</div>
            <iframe name="3dauth" class="tds-iframe" scrolling="auto" src="about:blank" title="3D Secure"></iframe>
        {else}
            <div class="tds-spinner">
                <span class="dot"></span>
                <span>{$hadrianLang.billing.verifyLoading}</span>
            </div>
        {/if}
    </div>
</div>

{if $hasCode}
<script>
{literal}
(function () {
    var container = document.getElementById('frmThreeDAuth');
    if (!container) return;
    var form = container.querySelector('form');
    if (!form) return;
    form.setAttribute('target', '3dauth');
    setTimeout(function () { try { form.submit(); } catch (e) {} }, 800);
})();
{/literal}
</script>
{/if}
