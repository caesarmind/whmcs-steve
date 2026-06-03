{* Hostnodes - Configure upgrade (Apple-style): pick target plan + see proration.

   NOTE: 'upgrade-configure' is not a standard WHMCS templatefile (WHMCS drives the
   upgrade flow through 'upgrade' + 'upgradesummary'). This page renders the design
   from demo data under ?preview=1 and otherwise points the user into the real flow.
   If the install does route a plan list here, $upgradepackages is honored.
*}

{assign var=isPreview value=false}
{if isset($smarty.get.preview) && $smarty.get.preview == '1'}{assign var=isPreview value=true}{/if}

{assign var=hasPkgs value=false}
{if isset($upgradepackages) && $upgradepackages|@count > 0}{assign var=hasPkgs value=true}{/if}

{assign var=ucDemo value=false}
{if !$hasPkgs && $isPreview}{assign var=ucDemo value=true}{/if}

{assign var=ucFull value=false}
{if $hasPkgs || $ucDemo}{assign var=ucFull value=true}{/if}
{if $ucFull}{assign var=dashIsEmpty value='full'}{else}{assign var=dashIsEmpty value='empty'}{/if}

<link rel="stylesheet" href="{$WEB_ROOT}/templates/{$template}/assets/css/pages/upgrade-configure.css?v={$myTheme.version|default:'1.0'}">

<script>
(function () {
    var b = document.body;
    if (!b) return;
    b.setAttribute('data-data',   '{$dashIsEmpty}');
    b.setAttribute('data-subnav', 'off');
})();
</script>

<header class="page-header">
    <p class="page-eyebrow">{$LANG.clientareaservices|default:'Services'}</p>
    <h1>{$LANG.upgradeconfigure|default:'Configure upgrade'}</h1>
    <p class="page-subtitle">{$hadrianLang.services.upgradeConfigureIntro}</p>
</header>

{if $ucFull}
<div class="when-full">

    <div class="card">
        <div class="card-header"><h2 class="card-title">{$LANG.upgradenewconfig}</h2></div>
        <div class="card-body">
            <div class="plan-cards">
                {if $ucDemo}
                    <label class="plan-card current" data-selectable>
                        <input type="radio" name="uc_plan" value="pro" hidden>
                        <span class="plan-radio"></span>
                        <span class="plan-info"><span class="plan-name">Pro <span class="plan-badge">{$LANG.upgradecurrentconfig}</span></span><span class="plan-features">100 GB SSD, 2 TB bandwidth</span></span>
                        <span class="plan-price">$20.33<span class="plan-price-period">/mo</span></span>
                    </label>
                    <label class="plan-card selected" data-selectable>
                        <input type="radio" name="uc_plan" value="business" checked hidden>
                        <span class="plan-radio"></span>
                        <span class="plan-info"><span class="plan-name">Business</span><span class="plan-features">500 GB SSD, unmetered bandwidth</span></span>
                        <span class="plan-price">$41.58<span class="plan-price-period">/mo</span></span>
                    </label>
                    <label class="plan-card" data-selectable>
                        <input type="radio" name="uc_plan" value="enterprise" hidden>
                        <span class="plan-radio"></span>
                        <span class="plan-info"><span class="plan-name">Enterprise</span><span class="plan-features">1 TB SSD, unmetered, dedicated IP</span></span>
                        <span class="plan-price">$79.99<span class="plan-price-period">/mo</span></span>
                    </label>
                {else}
                    {foreach $upgradepackages as $pkg}
                    <label class="plan-card{if $pkg@first} selected{/if}" data-selectable>
                        <input type="radio" name="uc_plan" value="{$pkg.pid|escape}"{if $pkg@first} checked{/if} hidden>
                        <span class="plan-radio"></span>
                        <span class="plan-info"><span class="plan-name">{$pkg.name|escape}</span></span>
                        <span class="plan-price">{if isset($pkg.pricing.monthly)}{$pkg.pricing.monthly}{/if}</span>
                    </label>
                    {/foreach}
                {/if}
            </div>
        </div>
    </div>

    {if $ucDemo}
    <div class="card">
        <div class="card-header"><h2 class="card-title">{$LANG.ordersummary}</h2></div>
        <div class="card-body">
            <div class="summary-row"><span>{$LANG.upgradecurrentconfig}</span><span>Pro ($20.33/mo)</span></div>
            <div class="summary-row"><span>{$LANG.upgradenewconfig}</span><span>Business ($41.58/mo)</span></div>
            <div class="summary-row"><span>{$hadrianLang.services.proratedCredit}</span><span class="summary-credit">-$12.50</span></div>
            <div class="summary-row total"><span>{$LANG.ordertotalduetoday}</span><span>$29.08</span></div>
        </div>
    </div>
    {/if}

    <div class="page-actions">
        <a href="{$WEB_ROOT}/upgrade.php" class="btn-primary">{$LANG.ordercontinuebutton}</a>
        <a href="{$WEB_ROOT}/clientarea.php?action=services" class="btn-secondary">{$LANG.cancel}</a>
    </div>

</div>
{/if}

{if !$ucFull}
<div class="when-empty">
    <div class="card">
        <div class="up-empty">
            <div class="up-empty-ico">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="3"/><path d="M19.4 15a1.65 1.65 0 00.33 1.82l.06.06a2 2 0 11-2.83 2.83l-.06-.06a1.65 1.65 0 00-1.82-.33 1.65 1.65 0 00-1 1.51V21a2 2 0 01-4 0v-.09A1.65 1.65 0 009 19.4a1.65 1.65 0 00-1.82.33l-.06.06a2 2 0 11-2.83-2.83l.06-.06a1.65 1.65 0 00.33-1.82 1.65 1.65 0 00-1.51-1H3a2 2 0 010-4h.09A1.65 1.65 0 004.6 9a1.65 1.65 0 00-.33-1.82l-.06-.06a2 2 0 112.83-2.83l.06.06a1.65 1.65 0 001.82.33H9a1.65 1.65 0 001-1.51V3a2 2 0 014 0v.09a1.65 1.65 0 001 1.51 1.65 1.65 0 001.82-.33l.06-.06a2 2 0 112.83 2.83l-.06.06a1.65 1.65 0 00-.33 1.82V9a1.65 1.65 0 001.51 1H21a2 2 0 010 4h-.09a1.65 1.65 0 00-1.51 1z"/></svg>
            </div>
            <p class="up-empty-title">{$hadrianLang.services.upgradePickFirstTitle}</p>
            <p class="up-empty-sub">{$hadrianLang.services.upgradePickFirstSub}</p>
            <a href="{$WEB_ROOT}/clientarea.php?action=services" class="btn-primary">{$LANG.clientareanavservices|default:'View my services'}</a>
        </div>
    </div>
</div>
{/if}

{if $ucFull}
<script>
{literal}
(function () {
    var cards = document.querySelectorAll('.plan-card[data-selectable]');
    cards.forEach(function (c) {
        c.addEventListener('click', function () {
            cards.forEach(function (x) { x.classList.remove('selected'); });
            c.classList.add('selected');
            var r = c.querySelector('input[type=radio]');
            if (r) { r.checked = true; }
        });
    });
})();
{/literal}
</script>
{/if}
