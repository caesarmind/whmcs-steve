{include file="includes/header.tpl"}

<header class="mt-page-header">
    <div class="mt-page-eyebrow">Theme</div>
    <h1 class="mt-page-title">Tools {include file="includes/doclink.tpl" article="addon" anchor="sections"}</h1>
    <p class="mt-page-subtitle">Operational utilities — cache flush, pages discovery, license refresh.</p>
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
        {* "Convert custom links to WHMCS pages" used to sit here. Removed
           because it could only ever report "nothing to do":

           - MenuController::ensureMenuPagesMigration() already runs the same
             conversion on every admin Menu page hit, gated by the
             hadrian_menu_migration_version marker, so it has fired once on
             every install and the marker is never reset.
           - It matches config.url against WhmcsDefaults EXACTLY, and none of
             the 60 custom_link items the presets seed match any of the 37
             convertible URLs -- they are cart.php deeplinks, '#' placeholders
             and off-scope pages. Checked across all 11 tracked revisions of
             Presets.php: the only clientarea.php custom link is Mass Payment's
             '&all=true' entrypoint, which is deliberately excluded.
           - The editor offers WHMCS Page as a first-class type with a page
             picker, so producing a convertible item now takes an admin
             hand-typing a client-area URL into a Custom Link.

           Its origin, for anyone tempted to restore it: the presets seeded
           convertible custom_links for about fourteen hours, between 8200dff
           (2026-05-12 22:08) and the preset rewrite in c57d7ab (2026-05-13
           11:54). The migration was written that same morning to repair installs
           seeded inside that window. Nothing seeded since can match.

           AND ITS ROW LIED. "Safe to re-run" was not true:
           - the conversion destroys config.url and is NOT reversible -- flipping
             the type back in the editor gives an empty URL field and saves a
             dead href="#", while the drawer promises the URL is preserved
             across a type switch;
           - target=_blank keeps working after conversion but its "Open in new
             tab" checkbox is hidden on whmcs_page, leaving an item that opens a
             new tab with no control to stop it;
           - a custom_link pointing at a store/* URL converts to a page the
             picker cannot offer, so it renders as an unknown templatefile and
             can no longer be re-pointed.
           It was also global, unscoped, and had no confirmation or dry-run.

           The tool itself is untouched -- Seeder::migrateCustomLinksToWhmcsPages()
           is what the automatic path calls, and ToolsController still accepts
           tool=migrate_menu_pages, so restoring this row is one <div>. If it is
           ever restored, fix the three items above first. *}
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
