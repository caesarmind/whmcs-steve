{* Hostnodes - Download denied: access notice.

   WHMCS renders this when a download is blocked (no active service / wrong role).
   No list data; the page is a single notice card. The empty state is a
   preview-only "no download in progress" variant for the state chip.
*}

{* This page renders on an actual denial, so default to the populated notice. *}
{assign var=ddIsEmpty value='full'}

<link rel="stylesheet" href="{$WEB_ROOT}/templates/{$template}/assets/css/pages/downloaddenied.css?v={$hadrian.version|default:'1.0'}">

<script>
(function () {
    var b = document.body;
    if (!b) return;
    b.setAttribute('data-data',   '{$ddIsEmpty}');
    b.setAttribute('data-subnav', 'off');
})();
</script>

<header class="page-header">
    <div class="eyebrow">{$LANG.downloadstitle}</div>
    <h1>{$hadrianLang.support.downloadDeniedTitle}</h1>
    <p class="page-subtitle">{$hadrianLang.support.downloadDeniedSub}</p>
</header>

<div class="when-full">
    <div class="denied-card">
        <div class="denied-icon">
            <svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round">
                <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/>
                <polyline points="7 10 12 15 17 10"/>
                <line x1="12" y1="15" x2="12" y2="3"/>
                <line x1="4" y1="4" x2="20" y2="20" stroke-width="2"/>
            </svg>
        </div>
        <h2>{$hadrianLang.support.downloadDeniedHeading}</h2>
        <p>{if isset($errormessage) && $errormessage}{$errormessage|strip_tags}{else}{$hadrianLang.support.downloadDeniedBody}{/if}</p>
        <div class="denied-actions">
            <a href="{$WEB_ROOT}/clientarea.php?action=services" class="btn-primary">{$LANG.clientareanavservices|default:'View my services'}</a>
            <a href="{$WEB_ROOT}/supporttickets.php" class="btn-secondary">{$LANG.contactus}</a>
        </div>
    </div>
</div>

<div class="when-empty">
    <div class="denied-empty">
        <div class="denied-empty-ico">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="11" width="18" height="11" rx="2" ry="2"/><path d="M7 11V7a5 5 0 0110 0v4"/></svg>
        </div>
        <p class="denied-empty-title">{$hadrianLang.support.downloadDeniedNoneTitle}</p>
        <p class="denied-empty-sub">{$hadrianLang.support.downloadDeniedNoneSub}</p>
        <a href="{$WEB_ROOT}/downloads.php" class="btn-primary">{$hadrianLang.support.allDownloads}</a>
    </div>
</div>
