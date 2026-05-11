{include file="includes/header.tpl"}

<header class="mt-page-header">
    <h1 class="mt-page-title">Layouts</h1>
    <p class="mt-page-subtitle">
        Pick the navigation and footer arrangement for <strong>{$template|escape}</strong>.
    </p>
</header>

<div class="mt-tabs" role="tablist">
    <a href="{$viewHelper->url('layouts', ['kind' => 'main-menu'])}"
       class="mt-tab {if $kind == 'main-menu'}is-active{/if}">Main menu</a>
    <a href="{$viewHelper->url('layouts', ['kind' => 'footer'])}"
       class="mt-tab {if $kind == 'footer'}is-active{/if}">Footer</a>
</div>

<section class="mt-section">
    <header class="mt-section-header">
        <h2 class="mt-section-title">{if $kind == 'main-menu'}Main menu layouts{else}Footer layouts{/if}</h2>
        <span class="mt-section-count">{$layouts|count}</span>
    </header>

    <form method="post" action="" class="mt-section-body">
        <div class="mt-grid">
            {foreach $layouts as $layout}
                <label class="mt-card {if $layout.isActive}is-active{/if}">
                    <input type="radio" name="layout" value="{$layout.name|escape}"
                           {if $layout.isActive}checked{/if}
                           onchange="this.form.submit()">
                    <div class="mt-card-thumb">{$layout.displayName|escape|truncate:1:""}</div>
                    <div class="mt-card-body">
                        <h3 class="mt-card-title">{$layout.displayName|escape}</h3>
                        <p class="mt-card-meta">Layout variant</p>
                    </div>
                    <div class="mt-card-footer">
                        {if $layout.isActive}
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
