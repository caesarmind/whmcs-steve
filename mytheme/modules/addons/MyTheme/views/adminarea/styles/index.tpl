{include file="includes/header.tpl"}

<header class="mt-page-header">
    <h1 class="mt-page-title">Styles</h1>
    <p class="mt-page-subtitle">
        Pick the active style preset for <strong>{$template|escape}</strong>. Light vs dark is a
        <em>mode</em> — set it under <a href="?module=MyTheme&action=settings">Settings &rsaquo; Enable Dark Mode</a>.
        The dark card below just holds the <code>[data-theme="dark"]</code> colors, not a separate activatable style.
    </p>
</header>

<section class="mt-section">
    <header class="mt-section-header">
        <h2 class="mt-section-title">Available styles</h2>
        <span class="mt-section-count">{$styles|count}</span>
    </header>

    <form method="post" action="" class="mt-section-body">
        <div class="mt-grid">
            {foreach $styles as $style}
                {if $style.colorMode == 'dark'}
                    {* Dark colorMode = the dark-MODE color scheme, not an
                       activatable style. It applies automatically when the mode
                       resolves to dark (Settings -> Enable Dark Mode). Customize
                       only — no radio, no Active/activate badge. *}
                    <div class="mt-card mt-card-static">
                        <div class="mt-card-thumb">{$style.displayName|escape|truncate:1:""}</div>
                        <div class="mt-card-body">
                            <h3 class="mt-card-title">{$style.displayName|escape}</h3>
                            <p class="mt-card-meta">Dark-mode colors</p>
                        </div>
                        <div class="mt-card-footer">
                            <a class="mt-card-edit" href="?module=MyTheme&action=editStyle&style={$style.name|escape}&subcat=colors">Customize &rsaquo;</a>
                        </div>
                    </div>
                {else}
                    <label class="mt-card {if $style.isActive}is-active{/if}">
                        <input type="radio" name="style" value="{$style.name|escape}"
                               {if $style.isActive}checked{/if}
                               onchange="this.form.submit()">
                        <div class="mt-card-thumb">{$style.displayName|escape|truncate:1:""}</div>
                        <div class="mt-card-body">
                            <h3 class="mt-card-title">{$style.displayName|escape}</h3>
                            <p class="mt-card-meta">Style preset</p>
                        </div>
                        <div class="mt-card-footer">
                            {if $style.isActive}
                                <span class="mt-badge mt-badge-success">Active</span>
                            {else}
                                <span class="mt-badge mt-badge-primary">Click to activate</span>
                            {/if}
                            {* <a href> is interactive content, so clicking it does NOT
                               toggle the wrapping label's radio — it just navigates. *}
                            <a class="mt-card-edit" href="?module=MyTheme&action=editStyle&style={$style.name|escape}&subcat=typography">Customize &rsaquo;</a>
                        </div>
                    </label>
                {/if}
            {/foreach}
        </div>
    </form>
</section>

{include file="includes/footer.tpl"}
