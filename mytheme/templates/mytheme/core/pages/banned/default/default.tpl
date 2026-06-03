{* Hostnodes - Account banned (Apple-style): ban notification.
   Optional WHMCS variables: $banreason, $banexpires.
*}
{assign var=dashIsEmpty value='full'}

<link rel="stylesheet" href="{$WEB_ROOT}/templates/{$template}/assets/css/pages/banned.css?v={$myTheme.version|default:'1.0'}">

<script>
(function () {
    var b = document.body;
    if (!b) return;
    b.setAttribute('data-data',   '{$dashIsEmpty}');
    b.setAttribute('data-subnav', 'off');
})();
</script>

<header class="page-header">
    <p class="page-eyebrow">{$LANG.error}</p>
    <h1>{$hadrianLang.error.bannedTitle}</h1>
</header>

<div class="card err-card">
    <div class="err-ico">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="4.93" y1="4.93" x2="19.07" y2="19.07"/></svg>
    </div>
    <h2 class="err-title">{$hadrianLang.error.bannedHeading}</h2>
    <p class="err-sub">
        {if isset($banreason) && $banreason}{$LANG.bannedbanreason}: {$banreason|strip_tags}{else}{$hadrianLang.error.bannedSub}{/if}
        {if isset($banexpires) && $banexpires}<br>{$LANG.bannedbanexpires}: {$banexpires|escape}{/if}
    </p>
    <div class="err-actions">
        <a href="{$WEB_ROOT}/contact.php" class="btn-primary">{$LANG.contactus}</a>
    </div>
</div>
