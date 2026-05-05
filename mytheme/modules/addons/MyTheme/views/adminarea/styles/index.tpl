{include file="includes/header.tpl"}

<header class="mt-page-header">
    <h1 class="mt-page-title">Styles</h1>
    <p class="mt-page-subtitle">
        Pick a style preset for <strong>{$template|escape}</strong>. The selection is applied as
        <code>data-theme</code> on <code>&lt;body&gt;</code>.
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
                    </div>
                </label>
            {/foreach}
        </div>
    </form>
</section>

{include file="includes/footer.tpl"}
