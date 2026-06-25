{include file="includes/header.tpl"}

<header class="mt-page-header">
    <div class="mt-page-eyebrow">Menu</div>
    <h1 class="mt-page-title">Couldn't load that</h1>
</header>

<div class="mt-panel">
    <section class="mt-section">
        <div class="mt-empty" style="padding: 32px 24px;">
            <p style="font-size: 14px; color: var(--mt-text); margin: 0 0 8px;">{$error|escape}</p>
            <p style="font-size: 12px; color: var(--mt-text-2); margin: 0 0 18px;">
                The menu id in the request didn't match a row in <code>hadrian_menus</code>.
                It may have been deleted, or the form submitted without a valid id.
            </p>
            <a href="?module=Hadrian&action=menu" class="mt-btn mt-btn-primary mt-btn-sm">Back to menus</a>
        </div>
    </section>
</div>

{include file="includes/footer.tpl"}
