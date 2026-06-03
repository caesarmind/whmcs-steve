{* Hostnodes - Affiliate program activation / opt-in (Apple-style).

   WHMCS standard variables expected:
     $affiliatesystemenabled - bool: the affiliate program is enabled
   Activation: POST affiliates.php with activate=true
*}

{assign var=affEnabled value=true}
{if isset($affiliatesystemenabled)}{assign var=affEnabled value=$affiliatesystemenabled}{/if}

<link rel="stylesheet" href="{$WEB_ROOT}/templates/{$template}/assets/css/pages/affiliates.css?v={$myTheme.version|default:'1.0'}">

<script>
(function () {
    var b = document.body;
    if (!b) return;
    b.setAttribute('data-data', 'full');
})();
</script>

<header class="page-header">
    <h1>{$LANG.affiliatestitle}</h1>
    <p class="page-subtitle">{$hadrianLang.account.affiliatesSub}</p>
</header>

{if $affEnabled}
<div class="card aff-signup-card">
    <div class="aff-signup-ico">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round"><path d="M20.42 4.58a5.4 5.4 0 00-7.65 0l-.77.78-.77-.78a5.4 5.4 0 00-7.65 7.65l.77.78L12 21l7.65-8.99.77-.78a5.4 5.4 0 000-7.65z"/></svg>
    </div>
    <h2 class="aff-signup-title">{$LANG.affiliatesignuptitle}</h2>
    <p class="aff-signup-intro">{$LANG.affiliatesignupintro}</p>

    <ul class="aff-benefits">
        <li>
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"/></svg>
            <span>{$LANG.affiliatesignupinfo1}</span>
        </li>
        <li>
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"/></svg>
            <span>{$LANG.affiliatesignupinfo2}</span>
        </li>
        <li>
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"/></svg>
            <span>{$LANG.affiliatesignupinfo3}</span>
        </li>
    </ul>

    <form method="post" action="{$WEB_ROOT}/affiliates.php" class="aff-signup-form">
        <input type="hidden" name="activate" value="true">
        <button type="submit" class="btn-primary aff-signup-btn">{$LANG.affiliatesactivate}</button>
    </form>
</div>
{else}
<div class="card">
    <div class="aff-disabled">
        <div class="aff-disabled-ico">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
        </div>
        <p class="aff-disabled-title">{$LANG.affiliatesdisabled}</p>
        <p class="aff-disabled-sub">{$hadrianLang.account.affiliatesDisabledSub}</p>
    </div>
</div>
{/if}
