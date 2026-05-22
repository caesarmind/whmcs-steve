{* Hostnodes - Access denied (Apple-style): generic permission-denied notice.
   Optional WHMCS variable: $errormessage (specific reason).
*}
{assign var=dashIsEmpty value='full'}

<link rel="stylesheet" href="{$WEB_ROOT}/templates/{$template}/assets/css/pages/access-denied.css?v={$myTheme.version|default:'1.0'}">

<script>
(function () {
    var b = document.body;
    if (!b) return;
    b.setAttribute('data-data',   '{$dashIsEmpty}');
    b.setAttribute('data-subnav', 'off');
})();
</script>

<header class="page-header">
    <p class="page-eyebrow">{$LANG.error|default:'Error'}</p>
    <h1>{$LANG.accessdenied|default:'Access denied'}</h1>
</header>

<div class="card err-card">
    <div class="err-ico">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="11" width="18" height="11" rx="2"/><path d="M7 11V7a5 5 0 0110 0v4"/><line x1="12" y1="15" x2="12" y2="17"/></svg>
    </div>
    <h2 class="err-title">{$LANG.accessdeniedheading|default:"You don't have access to this page"}</h2>
    <p class="err-sub">{if isset($errormessage) && $errormessage}{$errormessage|strip_tags}{else}{$LANG.accessdeniedsub|default:'Your account may not have permission to view this, or you may need to sign in again. Contact support if you believe this is an error.'}{/if}</p>
    <div class="err-actions">
        <a href="{$WEB_ROOT}/clientarea.php" class="btn-primary">{$LANG.returnclient|default:'Back to dashboard'}</a>
        <a href="{$WEB_ROOT}/supporttickets.php" class="btn-secondary">{$LANG.contactus|default:'Contact support'}</a>
    </div>
</div>
