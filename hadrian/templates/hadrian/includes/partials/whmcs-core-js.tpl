{* The WHMCS front-end core, for code that isn't ours but runs in our pages.

   Stock themes load jQuery and WHMCS's JS core (window.WHMCS: http, utils,
   client, ui, authn...) on every page; Hadrian's client area does not. Some
   WHMCS output expects them anyway: server modules' js/client.js (cPanel,
   Plesk) and the Signin Integrations buttons ($linkableProviders[].code,
   which call WHMCS.authn.provider). Include this before such output.

   - jQuery: WHMCS's own bundled copy, only when the page has none yet, so a
     page that already loaded jQuery + plugins (list tables, the order form)
     keeps them.
   - assets/js/whmcs.js + whmcs/<module>.js: each registers itself on
     window.WHMCS once (WHMCS.loadModule skips a module already present) and
     does nothing at load, so including this twice is harmless.
   - csrfToken / whmcsBaseUrl globals, unless the page set them already.

   Parameters: withAuthn = true also loads client.js, ui.js and authn.js. *}
<script>
    var csrfToken    = window.csrfToken || "{$token|default:''|escape:'javascript'}";
    var whmcsBaseUrl = window.whmcsBaseUrl || "{$smarty.server.REQUEST_SCHEME|default:'https'|escape:'javascript'}://{$smarty.server.HTTP_HOST|escape:'javascript'}{$WEB_ROOT|escape:'javascript'}";
    window.jQuery || document.write('<script src="{$WEB_ROOT}/assets/js/jquery.min.js"><\/script>');
</script>
<script src="{$WEB_ROOT}/assets/js/whmcs.js"></script>
<script src="{$WEB_ROOT}/assets/js/whmcs/http.js"></script>
<script src="{$WEB_ROOT}/assets/js/whmcs/utils.js"></script>
{if isset($withAuthn) && $withAuthn}
<script src="{$WEB_ROOT}/assets/js/whmcs/client.js"></script>
<script src="{$WEB_ROOT}/assets/js/whmcs/ui.js"></script>
<script src="{$WEB_ROOT}/assets/js/whmcs/authn.js"></script>
{/if}
