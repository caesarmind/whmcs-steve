{* Password strength meter - the WHMCS shared include, for code that includes
   "$template/includes/pwstrength.tpl" by name. Watches #inputNewPassword1
   like stock Nexus and scores it with the same formula (length, digits,
   symbols, capitals), marking the field is-invalid / is-warning / is-valid.
   Vanilla JS: Hadrian's client area loads no jQuery. Hadrian's own password
   forms have their own meter. Parameters (as stock): maximumPasswordLength,
   pwStrengthErrorThreshold (default 50), pwStrengthWarningThreshold (75). *}
<div class="hn-pwstrength" id="passwordStrengthBar" data-error="{if isset($pwStrengthErrorThreshold)}{$pwStrengthErrorThreshold}{else}50{/if}" data-warning="{if isset($pwStrengthWarningThreshold)}{$pwStrengthWarningThreshold}{else}75{/if}" data-max="{$maximumPasswordLength|default:64}" data-label="{lang key='pwstrengthrating'}">
    <div class="hn-pwstrength-bar" role="progressbar" aria-valuenow="0" aria-valuemin="0" aria-valuemax="100" aria-label="{lang key='pwstrengthrating'}"></div>
</div>
<p class="hn-pwstrength-tip">{lang key='passwordtips' maximum_length=$maximumPasswordLength|default:64}</p>
<style>{literal}
.hn-pwstrength{height:6px;margin:10px 0 6px;border-radius:999px;background:var(--color-surface-secondary);overflow:hidden}
.hn-pwstrength-bar{height:100%;width:0;background:var(--color-red-text);transition:width .2s,background .2s}
.hn-pwstrength-bar.is-warning{background:var(--color-orange-text)}
.hn-pwstrength-bar.is-valid{background:var(--color-green-text)}
.hn-pwstrength-tip{margin:0 0 12px;font-size:var(--text-sm);color:var(--color-text-tertiary)}
{/literal}</style>
<script>{literal}
(function () {
    var meter = document.getElementById('passwordStrengthBar');
    var input = document.getElementById('inputNewPassword1');
    if (!meter || !input) { return; }
    var bar = meter.querySelector('.hn-pwstrength-bar');
    var errorAt = parseInt(meter.getAttribute('data-error'), 10) || 50;
    var warnAt = parseInt(meter.getAttribute('data-warning'), 10) || 75;
    var max = parseInt(meter.getAttribute('data-max'), 10) || 64;
    function count(pw, re, cap) { return Math.min(cap, pw.length - pw.replace(re, '').length); }
    input.addEventListener('input', function () {
        var pw = input.value;
        var score = (Math.min(5, pw.length) * 10 - 20) + count(pw, /[0-9]/g, 3) * 10 + count(pw, /\W/g, 3) * 15 + count(pw, /[A-Z]/g, 3) * 10;
        score = Math.max(0, Math.min(100, score));
        var state = (score < errorAt || pw.length > max) ? 'is-invalid' : (score < warnAt ? 'is-warning' : 'is-valid');
        bar.style.width = score + '%';
        bar.setAttribute('aria-valuenow', score);
        bar.className = 'hn-pwstrength-bar ' + state;
        input.classList.remove('is-invalid', 'is-warning', 'is-valid');
        input.classList.add(state);
    });
})();
{/literal}</script>
