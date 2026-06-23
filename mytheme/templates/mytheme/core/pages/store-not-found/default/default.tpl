{* Store landing - Not Found (utility page).
   Ported from apple-client-area/store/not-found.html.
   header.tpl/footer.tpl provide the shell + .content-area, so we emit only the
   inner centered message (no full/empty split - this is a single state).

   Data contract: six/store/not-found.tpl assigns $productName (the requested,
   unavailable product slug/name) - we surface it as a reference line when set.
   Everything else is static copy tokenized into the hadrianLang store group
   (nf-prefixed keys); the SVG icon is kept verbatim from the mockup. *}

<script>
(function () {
    var b = document.body;
    if (!b) return;
    b.setAttribute('data-svc-layout', 'inside');
})();
</script>

<div class="store-not-found" style="max-width:1024px;margin:0 auto;">
    <div class="card">
        <div class="card-body">
            <div class="empty-state">
                <div class="empty-state-icon">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/><line x1="8" y1="8" x2="14" y2="14"/><line x1="14" y1="8" x2="8" y2="14"/></svg>
                </div>
                <h2 class="empty-state-title">{$hadrianLang.store.nfTitle}</h2>
                <p class="empty-state-text">{$hadrianLang.store.nfText}</p>
                {if isset($productName) && $productName}
                    <p class="empty-state-text"><em>{$hadrianLang.store.nfRef}: {$productName|escape}</em></p>
                {/if}
                <div style="display:flex;gap:12px;justify-content:center;margin-top:8px">
                    <a href="{$WEB_ROOT}/cart.php" class="btn-primary">{$hadrianLang.store.nfBrowse}</a>
                    <a href="{$WEB_ROOT}/clientarea.php" class="btn-secondary">{$hadrianLang.store.nfDashboard}</a>
                </div>
            </div>
        </div>
    </div>
</div>
