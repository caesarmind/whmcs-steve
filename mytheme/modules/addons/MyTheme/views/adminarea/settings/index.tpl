{include file="includes/header.tpl"}

<header class="mt-page-header">
    <div class="mt-page-eyebrow">Theme</div>
    <h1 class="mt-page-title">Settings</h1>
    <p class="mt-page-subtitle">Theme-wide options. Save to apply.</p>
</header>

<div class="mt-tabs" role="tablist">
    <a class="mt-tab {if $tab == 'general'}is-active{/if}" href="?module=MyTheme&action=settings&tab=general">General</a>
    <a class="mt-tab {if $tab == 'order'}is-active{/if}" href="?module=MyTheme&action=settings&tab=order">Order Process</a>
</div>

<form method="post" action="" novalidate>
    <section class="mt-section">
        <header class="mt-section-header">
            <h2 class="mt-section-title">General Settings</h2>
            <div class="mt-section-tools">
                <button type="submit" class="mt-btn mt-btn-primary mt-btn-sm">Save changes</button>
            </div>
        </header>

        {foreach $flags as $key => $meta}
            <div class="mt-row">
                <div>
                    <div class="mt-row-label">{$meta[0]|escape}</div>
                    <div class="mt-row-help">{$meta[1]|escape}</div>
                </div>
                <label class="mt-toggle">
                    <input type="checkbox" name="{$key|escape}" {if $values[$key]}checked{/if}>
                    <span class="mt-toggle-track"><span class="mt-toggle-thumb"></span></span>
                </label>
            </div>
        {/foreach}
    </section>

    <div style="margin-top:16px;display:flex;justify-content:flex-end">
        <button type="submit" class="mt-btn mt-btn-primary">Save changes</button>
    </div>
</form>

{include file="includes/footer.tpl"}
