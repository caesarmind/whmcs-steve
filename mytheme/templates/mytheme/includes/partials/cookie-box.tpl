{*
 * Cookie consent bar — Lagom-parity ("Cookie Box").
 *
 * Included once from footer.tpl, OUTSIDE the full-bleed gate, so it renders
 * theme-wide: client area, the mytheme_cart order form (which uses this same
 * footer shell), and full-bleed pages (login). Gated on the admin "Cookie Box"
 * toggle ($myTheme.addonSettings.cookie_box) — emits nothing when off, so an
 * unconfigured install has zero overhead.
 *
 * Settings (admin → Settings → General → Cookie Box):
 *   cookie_box           bool    master toggle
 *   cookie_box_message   per-language map ({english:..,spanish:..}); Hooks
 *                        resolves it to the active language's string before
 *                        render (active → system-default-language → '', which
 *                        falls back to $hadrianLang.common.cookieMessage below).
 *                        HTML allowed (privacy link etc.).
 *   cookie_box_position  enum    bottom-left | bottom-right | bottom
 *   cookie_box_button    string  dismiss label (default "Continue")
 *
 * Behaviour mirrors Lagom's data-driven bar: shown after a short delay if the
 * consent cookie isn't set; the dismiss button sets a ~365-day cookie so it
 * never shows again. Self-contained markup + CSS + JS (no asset cache-bust).
 *}
{if $myTheme.addonSettings.cookie_box}
    {assign var=mtCookiePos value=$myTheme.addonSettings.cookie_box_position|default:'bottom-left'}
    {assign var=mtCookieMsg value=$myTheme.addonSettings.cookie_box_message|default:''}
    {assign var=mtCookieBtn value=$myTheme.addonSettings.cookie_box_button|default:$LANG.continue}
    <div class="mt-cookie-bar mt-cookie-bar--{$mtCookiePos}" id="mtCookieBar" role="dialog" aria-label="{$hadrianLang.common.cookieNotice}" data-cookie-name="mt_cookie_consent" data-exp-days="365" data-delay="1500" hidden>
        <div class="mt-cookie-bar__inner">
            <span class="mt-cookie-bar__icon" aria-hidden="true">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round"><path d="M12 2a10 10 0 1 0 10 10 4 4 0 0 1-5-5 4 4 0 0 1-5-5"/><path d="M8.5 8.5v.01"/><path d="M16 15.5v.01"/><path d="M12 12v.01"/><path d="M11 17v.01"/><path d="M7 14v.01"/></svg>
            </span>
            <div class="mt-cookie-bar__msg">{if $mtCookieMsg != ''}{$mtCookieMsg}{else}{$hadrianLang.common.cookieMessage}{/if}</div>
            <button type="button" class="mt-cookie-bar__btn" data-cookie-accept>{$mtCookieBtn|escape}</button>
        </div>
    </div>
    {literal}
    <style>
    .mt-cookie-bar { position: fixed; z-index: 1200; max-width: 380px; opacity: 0; transform: translateY(14px); transition: opacity .3s ease, transform .3s ease; pointer-events: none; }
    .mt-cookie-bar[hidden] { display: none; }
    .mt-cookie-bar.is-visible { opacity: 1; transform: none; pointer-events: auto; }
    .mt-cookie-bar--bottom-left { left: 20px; bottom: 20px; }
    .mt-cookie-bar--bottom-right { right: 20px; bottom: 20px; }
    .mt-cookie-bar--bottom { left: 20px; right: 20px; bottom: 20px; max-width: none; }
    .mt-cookie-bar__inner { display: flex; align-items: center; gap: 13px; padding: 14px 16px; background: var(--color-surface, #fff); border: 0.5px solid var(--color-border, rgba(0,0,0,0.1)); border-radius: 14px; box-shadow: 0 10px 34px rgba(0,0,0,0.14); }
    .mt-cookie-bar--bottom .mt-cookie-bar__inner { max-width: 760px; margin: 0 auto; }
    .mt-cookie-bar__icon { flex: 0 0 auto; width: 22px; height: 22px; color: var(--color-accent, #0071e3); }
    .mt-cookie-bar__icon svg { display: block; width: 100%; height: 100%; }
    .mt-cookie-bar__msg { flex: 1 1 auto; font-size: 12.5px; line-height: 1.45; color: var(--color-text-secondary, #6e6e73); }
    .mt-cookie-bar__msg a { color: var(--color-accent, #0071e3); text-decoration: none; }
    .mt-cookie-bar__msg a:hover { text-decoration: underline; }
    .mt-cookie-bar__btn { flex: 0 0 auto; appearance: none; -webkit-appearance: none; border: 0; cursor: pointer; padding: 8px 16px; border-radius: 980px; font: inherit; font-size: 12.5px; font-weight: 500; background: var(--color-accent, #0071e3); color: #fff; transition: filter .15s ease; }
    .mt-cookie-bar__btn:hover { filter: brightness(1.06); }
    @media (max-width: 520px) {
        .mt-cookie-bar { left: 12px !important; right: 12px !important; bottom: 12px; max-width: none; }
        .mt-cookie-bar__inner { flex-wrap: wrap; }
        .mt-cookie-bar__btn { width: 100%; }
    }
    </style>
    <script>
    (function () {
        var bar = document.getElementById('mtCookieBar');
        if (!bar) return;
        var name = bar.getAttribute('data-cookie-name') || 'mt_cookie_consent';
        var expDays = parseInt(bar.getAttribute('data-exp-days'), 10) || 365;
        var delay = parseInt(bar.getAttribute('data-delay'), 10) || 1500;
        function hasConsent() { return document.cookie.indexOf(name + '=1') !== -1; }
        function setConsent() {
            var d = new Date();
            d.setTime(d.getTime() + expDays * 86400000);
            document.cookie = name + '=1; expires=' + d.toUTCString() + '; path=/; SameSite=Lax';
        }
        if (hasConsent()) return;
        setTimeout(function () {
            bar.hidden = false;
            requestAnimationFrame(function () { bar.classList.add('is-visible'); });
        }, delay);
        var btn = bar.querySelector('[data-cookie-accept]');
        if (btn) btn.addEventListener('click', function () {
            setConsent();
            bar.classList.remove('is-visible');
            setTimeout(function () { bar.hidden = true; }, 320);
        });
    })();
    </script>
    {/literal}
{/if}
