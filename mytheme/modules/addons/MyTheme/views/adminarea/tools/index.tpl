{include file="includes/header.tpl"}

<header class="mt-page-header">
    <div class="mt-page-eyebrow">Theme</div>
    <h1 class="mt-page-title">Tools</h1>
    <p class="mt-page-subtitle">Operational utilities — cache flush, license refresh, htaccess generation.</p>
</header>

{if $message}
    <div class="mt-alert mt-alert-success">
        <strong>{$message|escape}</strong>
    </div>
{/if}

<section class="mt-section">
    <form method="post" action="">
        <div class="mt-row">
            <div>
                <div class="mt-row-label">Clear template cache</div>
                <div class="mt-row-help">Recompile all Smarty templates on the next request.</div>
            </div>
            <button type="submit" name="tool" value="clear_template_cache" class="mt-btn mt-btn-secondary">Clear</button>
        </div>
        <div class="mt-row">
            <div>
                <div class="mt-row-label">Refresh menu cache</div>
                <div class="mt-row-help">Force the menu builder to re-read configuration.</div>
            </div>
            <button type="submit" name="tool" value="refresh_menu_cache" class="mt-btn mt-btn-secondary">Refresh</button>
        </div>
        <div class="mt-row">
            <div>
                <div class="mt-row-label">Refresh license</div>
                <div class="mt-row-help">Force a callback to the license server now.</div>
            </div>
            <button type="submit" name="tool" value="refresh_license" class="mt-btn mt-btn-secondary">Refresh</button>
        </div>
        <div class="mt-row">
            <div>
                <div class="mt-row-label">Generate Nginx / .htaccess rules</div>
                <div class="mt-row-help">Build SEO redirect rules for your hosting platform.</div>
            </div>
            <button type="submit" name="tool" value="generate_htaccess" class="mt-btn mt-btn-secondary">Generate</button>
        </div>
    </form>
</section>

{include file="includes/footer.tpl"}
