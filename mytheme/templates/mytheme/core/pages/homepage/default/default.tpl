{* Hostnodes — Public homepage (Apple portal-style hero + sections).

   Mirrors apple-client-area/portal-home.html. Designed for top-nav layout
   but works in any layout via the universal toggles.

   WHMCS variables expected:
     $loggedin
     $companyname
     $LANG.*
*}

<link rel="stylesheet" href="{$WEB_ROOT}/templates/{$template}/assets/css/pages/homepage.css?v={$myTheme.version|default:'1.0'}">

{* ═══════════ HERO + DOMAIN SEARCH ═══════════ *}
<section class="ph-hero">
    <div class="ph-hero-inner">
        <h1>{$hadrianLang.dashboard.heroTitle}</h1>
        <p>{$hadrianLang.dashboard.heroSubtitle}</p>

        <div class="ph-domain-tabs" role="tablist">
            <button type="button" class="active" data-dtab="search" role="tab" aria-selected="true">{$LANG.search}</button>
            <button type="button" data-dtab="transfer" role="tab" aria-selected="false">{$LANG.transferdomain}</button>
        </div>

        <form class="ph-domain-form" action="{$WEB_ROOT}/domainchecker.php" method="post">
            <div class="ph-domain-box">
                <svg class="search-ico" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
                <input type="text" name="domain" placeholder="{$LANG.exampledomain}" autocapitalize="none" autocomplete="off">
                <button type="submit" id="domainCta" class="{if isset($captcha) && $captcha}{$captcha->getButtonClass($captchaForm)}{/if}">{$LANG.search}</button>
            </div>

            {* Domain-checker CAPTCHA — renders only when enabled for this form in
               admin (typically logged-out visitors). getMarkup() emits the widget;
               reCAPTCHA api.js is auto-injected by {$headoutput}. *}
            {if isset($captcha) && $captcha->isEnabled() && $captcha->isEnabledForForm($captchaForm)}
            <div class="ph-captcha">{include file="`$template`/includes/captcha.tpl"}</div>
            {/if}

            <div class="ph-domain-footer">
                <span>{$hadrianLang.dashboard.heroDomainSubtitle}</span>
                <a href="{$WEB_ROOT}/cart.php?gid=domain">{$LANG.viewallpricing} &rarr;</a>
            </div>
        </form>
    </div>
</section>

{* ═══════════ BROWSE OUR PRODUCTS / SERVICES ═══════════ *}
<section class="ph-section">
    <div class="ph-section-head">
        <div class="eyebrow">{$LANG.clientHomePanels.productsAndServices}</div>
        <h2>{$hadrianLang.dashboard.section1Title}</h2>
    </div>
    <div class="ph-pg-grid">
        <div class="ph-pg-card">
            <div class="pg-icon blue">
                <svg width="26" height="26" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="3" width="18" height="18" rx="3"/><path d="M7 8h10M7 12h10M7 16h6"/></svg>
            </div>
            <h3>{$hadrianLang.dashboard.productCard1Title}</h3>
            <p>{$hadrianLang.dashboard.productCard1Desc}</p>
            <a href="{$WEB_ROOT}/cart.php" class="cta">{$LANG.browseProducts}</a>
        </div>
        <div class="ph-pg-card">
            <div class="pg-icon green">
                <svg width="26" height="26" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="2" y1="12" x2="22" y2="12"/><path d="M12 2a15.3 15.3 0 014 10 15.3 15.3 0 01-4 10 15.3 15.3 0 01-4-10 15.3 15.3 0 014-10z"/></svg>
            </div>
            <h3>{$LANG.orderregisterdomain}</h3>
            <p>{$LANG.secureYourDomain}</p>
            <a href="{$WEB_ROOT}/cart.php?a=add&domain=register" class="cta">{$LANG.navdomainsearch}</a>
        </div>
        <div class="ph-pg-card">
            <div class="pg-icon purple">
                <svg width="26" height="26" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round"><path d="M10 13a5 5 0 007.54.54l3-3a5 5 0 00-7.07-7.07l-1.72 1.71"/><path d="M14 11a5 5 0 00-7.54-.54l-3 3a5 5 0 007.07 7.07l1.71-1.71"/></svg>
            </div>
            <h3>{$LANG.transferYourDomain}</h3>
            <p>{$LANG.transferExtend}</p>
            <a href="{$WEB_ROOT}/cart.php?a=add&domain=transfer" class="cta">{$LANG.transferYourDomain}</a>
        </div>
    </div>
</section>

{* ═══════════ HOW CAN WE HELP TODAY ═══════════ *}
<section class="ph-section">
    <div class="ph-section-head">
        <div class="eyebrow">{$hadrianLang.dashboard.selfService}</div>
        <h2>{$LANG.howCanWeHelp}</h2>
    </div>
    <div class="ph-action-grid">
        <a href="{$WEB_ROOT}/announcements.php" class="ph-action">
            <div class="ico teal">
                <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round"><path d="M3 11l18-8v18L3 13v-2z"/><path d="M7 13v5l4 1v-4"/></svg>
            </div>
            <div class="lbl">{$LANG.announcementstitle}</div>
        </a>
        <a href="{$WEB_ROOT}/serverstatus.php" class="ph-action">
            <div class="ico red">
                <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round"><rect x="2" y="4" width="20" height="7" rx="1.5"/><rect x="2" y="13" width="20" height="7" rx="1.5"/><line x1="6" y1="7.5" x2="6.01" y2="7.5"/><line x1="6" y1="16.5" x2="6.01" y2="16.5"/></svg>
            </div>
            <div class="lbl">{$LANG.networkstatustitle}</div>
        </a>
        <a href="{$WEB_ROOT}/knowledgebase.php" class="ph-action">
            <div class="ico yellow">
                <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round"><path d="M4 4.5A2.5 2.5 0 016.5 2H20v18H6.5A2.5 2.5 0 014 17.5v-13z"/><path d="M4 17.5A2.5 2.5 0 016.5 15H20"/></svg>
            </div>
            <div class="lbl">{$LANG.knowledgebasetitle}</div>
        </a>
        <a href="{$WEB_ROOT}/downloads.php" class="ph-action">
            <div class="ico gray">
                <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round"><path d="M21 15v4a2 2 0 01-2 2H5a2 2 0 01-2-2v-4"/><polyline points="7 10 12 15 17 10"/><line x1="12" y1="15" x2="12" y2="3"/></svg>
            </div>
            <div class="lbl">{$LANG.downloadstitle}</div>
        </a>
        <a href="{$WEB_ROOT}/submitticket.php" class="ph-action">
            <div class="ico green">
                <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><circle cx="12" cy="12" r="4"/><line x1="4.93" y1="4.93" x2="9.17" y2="9.17"/><line x1="14.83" y1="14.83" x2="19.07" y2="19.07"/><line x1="14.83" y1="9.17" x2="19.07" y2="4.93"/><line x1="4.93" y1="19.07" x2="9.17" y2="14.83"/></svg>
            </div>
            <div class="lbl">{$LANG.homepage.submitTicket}</div>
        </a>
    </div>
</section>

{* ═══════════ YOUR ACCOUNT ═══════════ *}
<section class="ph-section" style="padding-bottom: 72px;">
    <div class="ph-section-head">
        <div class="eyebrow">{$LANG.accounttab}</div>
        <h2>{$LANG.homepage.yourAccount}</h2>
    </div>
    <div class="ph-action-grid">
        <a href="{$WEB_ROOT}/clientarea.php" class="ph-action">
            <div class="ico blue">
                <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round"><path d="M3 12l9-9 9 9M5 10v10h14V10"/></svg>
            </div>
            <div class="lbl">{$LANG.homepage.yourAccount}</div>
        </a>
        <a href="{$WEB_ROOT}/clientarea.php?action=services" class="ph-action">
            <div class="ico indigo">
                <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round"><polyline points="21 8 12 13 3 8"/><path d="M3 8v11a1 1 0 001 1h16a1 1 0 001-1V8M12 3L3 8l9 5 9-5-9-5z"/></svg>
            </div>
            <div class="lbl">{$LANG.homepage.manageServices}</div>
        </a>
        <a href="{$WEB_ROOT}/clientarea.php?action=domains" class="ph-action">
            <div class="ico teal">
                <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="2" y1="12" x2="22" y2="12"/><path d="M12 2a15.3 15.3 0 014 10 15.3 15.3 0 01-4 10 15.3 15.3 0 01-4-10 15.3 15.3 0 014-10z"/></svg>
            </div>
            <div class="lbl">{$LANG.homepage.manageDomains}</div>
        </a>
        <a href="{$WEB_ROOT}/supporttickets.php" class="ph-action">
            <div class="ico purple">
                <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round"><path d="M21 15a2 2 0 01-2 2H7l-4 4V5a2 2 0 012-2h14a2 2 0 012 2z"/></svg>
            </div>
            <div class="lbl">{$LANG.homepage.supportRequests}</div>
        </a>
        <a href="{$WEB_ROOT}/clientarea.php?action=masspay&all=true" class="ph-action">
            <div class="ico green">
                <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round"><rect x="2" y="5" width="20" height="14" rx="2"/><line x1="2" y1="10" x2="22" y2="10"/></svg>
            </div>
            <div class="lbl">{$LANG.homepage.makeAPayment}</div>
        </a>
    </div>
</section>

{* Domain tab toggle — search vs transfer affects form action *}
<script>
(function () {
    var form = document.querySelector('.ph-domain-form');
    if (!form) return;
    document.querySelectorAll('.ph-domain-tabs button').forEach(function (btn) {
        btn.addEventListener('click', function () {
            document.querySelectorAll('.ph-domain-tabs button').forEach(function (b) {
                b.classList.toggle('active', b === btn);
                b.setAttribute('aria-selected', b === btn ? 'true' : 'false');
            });
            var mode = btn.dataset.dtab;
            if (mode === 'transfer') {
                form.action = '{$WEB_ROOT}/cart.php?a=add&domain=transfer';
            } else {
                form.action = '{$WEB_ROOT}/domainchecker.php';
            }
        });
    });
})();
</script>
