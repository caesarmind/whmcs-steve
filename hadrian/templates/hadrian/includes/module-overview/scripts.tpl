{* Scripts a server module's overview is written against.

   The cPanel and Plesk modules ship js/client.js (Sitejet preview + publish,
   WordPress Toolkit, email accounts). It is jQuery code that calls the WHMCS
   front-end core (WHMCS.http.jqClient, WHMCS.utils.getRouteUrl) and the
   csrfToken global - all of which stock themes load on every page and
   Hadrian's client area does not. Loaded here, so only a service page whose
   module renders an overview pays for them:
     - jQuery: WHMCS's own bundled copy, only when the page has none yet
     - assets/js/whmcs.js + whmcs/http.js + whmcs/utils.js: the core modules
       (each registers itself on window.WHMCS once)
     - the module's client.js, when clientJs is passed (cpanel / plesk)
   Plus the stock ".btn-custom-action" handler (twenty-one scripts.js
   customActionAjaxCall) that Sitejet's "Edit Site" button relies on.

   Parameters: clientJs = module folder name whose js/client.js to load. *}
{include file="$template/includes/partials/whmcs-core-js.tpl"}
{if $clientJs}
<script src="{$WEB_ROOT}/modules/servers/{$clientJs}/js/client.js?v={$versionHash|default:''}"></script>
{/if}
<script>{literal}
(function () {
    if (window.hnCustomActionBound) return;
    window.hnCustomActionBound = true;
    document.addEventListener('click', function (e) {
        var btn = e.target.closest ? e.target.closest('.hn-module-overview .btn-custom-action') : null;
        if (!btn || btn.getAttribute('data-active') !== 'true' || btn.disabled) return;
        e.preventDefault();
        var id = btn.getAttribute('data-serviceid');
        var self = btn.getAttribute('data-ca-target') === '_self';
        var go = function (url) { if (self) { window.location.href = url; } else { window.open(url); } };
        var fallback = 'clientarea.php?action=productdetails&id=' + encodeURIComponent(id) + '&customaction_error=1';
        btn.disabled = true;
        WHMCS.http.jqClient.jsonPost({
            url: WHMCS.utils.getRouteUrl('/clientarea/service/' + id + '/custom-action/' + btn.getAttribute('data-identifier')),
            data: { token: csrfToken },
            success: function (r) { go(r && r.success ? r.redirectTo : fallback); },
            error: function () { go(fallback); },
            fail: function () { go(fallback); },
            always: function () { btn.disabled = false; }
        });
    });
})();
{/literal}</script>
