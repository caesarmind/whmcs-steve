{* Hostnodes — New Backup Codes Display (Apple-style).

   WHMCS standard variables on /clientarea.php?action=twofactor&sub=backup:
     $backupCode  — newly generated backup recovery code (single)
     $backupCodes — alternative array form (multiple codes)
*}

<link rel="stylesheet" href="{$WEB_ROOT}/templates/{$template}/assets/css/pages/two-factor-new-backup-code.css?v={$myTheme.version|default:'1.0'}">

<div class="tfabc-wrap">
    <div class="card tfabc-card">
        <div class="tfabc-ico"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M21 2l-2 2m-7.61 7.61a5.5 5.5 0 11-7.778 7.778 5.5 5.5 0 017.777-7.777zm0 0L15.5 7.5m0 0l3 3L22 7l-3-3m-3.5 3.5L19 4"/></svg></div>
        <h1 class="tfabc-title">{$hadrianLang.auth.backupCodesTitle}</h1>
        <p class="tfabc-sub">{$hadrianLang.auth.backupCodesSub}</p>

        <div class="tfabc-codes" data-copy-source>
            {if isset($backupCodes) && $backupCodes|@count > 0}
                {foreach $backupCodes as $code}
                <div class="tfabc-code">{$code|escape}</div>
                {/foreach}
            {elseif isset($backupCode) && $backupCode}
                <div class="tfabc-code">{$backupCode|escape}</div>
            {/if}
        </div>

        <div class="tfabc-actions">
            <button type="button" class="btn-secondary" data-copy-btn>
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><rect x="9" y="9" width="13" height="13" rx="2"/><path d="M5 15H4a2 2 0 01-2-2V4a2 2 0 012-2h9a2 2 0 012 2v1"/></svg>
                {$LANG.copy}
            </button>
            <a href="{$WEB_ROOT}/clientarea.php?action=security" class="btn-primary">{$hadrianLang.auth.done}</a>
        </div>

        <p class="tfabc-warn">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
            {$hadrianLang.auth.backupCodesWarn}
        </p>
    </div>
</div>

<script>var _localLang = { copied: '{$hadrianLang.auth.copied|escape:"javascript"}' };</script>
<script>
{literal}
document.addEventListener('click', function (e) {
    var btn = e.target.closest('[data-copy-btn]');
    if (!btn) return;
    var src = document.querySelector('[data-copy-source]');
    if (!src) return;
    var text = Array.prototype.map.call(src.querySelectorAll('.tfabc-code'), function (n) { return n.textContent.trim(); }).join('\n');
    if (navigator.clipboard && navigator.clipboard.writeText) {
        navigator.clipboard.writeText(text).then(function () {
            var orig = btn.innerHTML;
            btn.textContent = _localLang.copied;
            setTimeout(function () { btn.innerHTML = orig; }, 1600);
        });
    }
});
{/literal}
</script>
