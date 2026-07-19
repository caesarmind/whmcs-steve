{include file="includes/header.tpl"}

<header class="mt-page-header">
    <div class="mt-page-eyebrow">Theme</div>
    <h1 class="mt-page-title">Tools</h1>
    <p class="mt-page-subtitle">Operational utilities — cache flush, pages discovery, menu migration, license refresh.</p>
</header>

{if $message}
    {* Was always mt-alert-success, so "No active template" and "Unknown tool"
       both rendered as wins. ToolsController now returns [ok, message]. *}
    <div class="mt-alert {if $messageOk}mt-alert-success{else}mt-alert-error{/if}">
        <strong>{$message|escape}</strong>
    </div>
{/if}

<div class="mt-panel">
<section class="mt-section">
    <form method="post" action="">
        <div class="mt-row">
            <div>
                <div class="mt-row-label">Clear template cache</div>
                <div class="mt-row-help">Clear the Hadrian <em>admin panel</em>'s compiled templates. Client-area templates are compiled by WHMCS itself and are not affected.</div>
            </div>
            <button type="submit" name="tool" value="clear_template_cache" class="mt-btn mt-btn-secondary">Clear</button>
        </div>
        <div class="mt-row">
            <div>
                <div class="mt-row-label">Rebuild pages discovery</div>
                <div class="mt-row-help">Re-scan <code>core/pages/</code> for new page directories so the Pages tab surfaces them. Runs automatically on activation and theme version bump.</div>
            </div>
            <button type="submit" name="tool" value="rebuild_pages_cache" class="mt-btn mt-btn-secondary">Rebuild</button>
        </div>
        <div class="mt-row">
            <div>
                <div class="mt-row-label">Convert custom links to WHMCS pages</div>
                <div class="mt-row-help">Walk every menu and re-type <code>custom_link</code> items whose URL matches a known WHMCS page (Home, My Services, Tickets, etc.) → <code>whmcs_page</code>. Cart deeplinks and external URLs are skipped. Safe to re-run.</div>
            </div>
            <button type="submit" name="tool" value="migrate_menu_pages" class="mt-btn mt-btn-secondary">Convert</button>
        </div>
        <div class="mt-row">
            <div>
                <div class="mt-row-label">Refresh license</div>
                <div class="mt-row-help">Force a callback to the license server now.</div>
            </div>
            <button type="submit" name="tool" value="refresh_license" class="mt-btn mt-btn-secondary">Refresh</button>
        </div>
    </form>
</section>
</div>

{include file="includes/footer.tpl"}
