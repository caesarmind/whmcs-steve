{* Customer-facing license panel (WHMCS client area, service details page). *}
<div class="row">
  <div class="col-sm-12">
    <h3>Hadrian Theme License</h3>
    <p>Use this key in your WHMCS admin under <strong>Addons &rarr; MyTheme &rarr; License</strong>.</p>

    <div class="form-group">
      <label><strong>License Key</strong></label>
      <input type="text" class="form-control" readonly value="{$licenseKey}" onclick="this.select();">
    </div>

    <div class="form-group">
      <label><strong>Bound Domain(s)</strong></label>
      <input type="text" class="form-control" readonly
             value="{if $boundDomains}{$boundDomains}{else}Not yet bound — binds to the first domain that checks in{/if}">
      <small class="text-muted">This license may bind up to {$maxDomains} domain(s).</small>
    </div>
  </div>
</div>
