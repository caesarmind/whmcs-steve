{include file="includes/header.tpl"}

<header class="mt-page-header">
    <h1 class="mt-page-title">Styles</h1>
    <p class="mt-page-subtitle">
        Pick the active style preset for <strong>{$template|escape}</strong>. Each style carries its own
        light <em>and</em> dark colors — edit them with the Light/Dark toggle in a style's
        <strong>Customize &rsaquo; Colors</strong>. Light vs dark is a <em>mode</em>, set under
        <a href="?module=Hadrian&action=settings">Settings &rsaquo; Enable Dark Mode</a>.
    </p>
</header>

<div class="mt-panel pad">
    <section class="mt-section">
        <header class="mt-section-header">
            <h2 class="mt-section-title">Available styles</h2>
            <span class="mt-section-count">{$styles|count}</span>
        </header>

        {* Deliberately NOT .mt-card / .mt-grid: those are shared verbatim with
           templates/index.tpl and extensions/index.tpl, and Extensions does not
           even render a .mt-card-body. A style card needs its own colour band
           and a two-line description, so it gets its own private prefix rather
           than bending a shared component -- the same isolation the Layouts
           page already uses. The form, the radio and the Customize href are
           unchanged: the redesign must not touch the activate contract. *}
        <form method="post" action="" class="mt-section-body">
            <div class="mt-sty-grid">
                {foreach $styles as $style}
                    <label class="mt-sty-card {if $style.isActive}is-active{/if}">
                        <input type="radio" name="style" value="{$style.name|escape}"
                               {if $style.isActive}checked{/if}
                               onchange="this.form.submit()">
                        {* The preset's own colours, not a placeholder. Wide band
                           is its most distinctive surface (a dark nav, a warmed
                           page) or its accent when it repaints no surface;
                           narrow band is the accent it pairs with. Derived in
                           StylesController::buildStyleSwatch, where the choice
                           is explained. *}
                        <span class="mt-sty-swatch" aria-hidden="true">
                            <i style="background:{$style.swatch.primary|escape}"></i>
                            <i style="background:{$style.swatch.accent|escape}"></i>
                        </span>
                        <div class="mt-sty-body">
                            <h3 class="mt-sty-title">{$style.displayName|escape}</h3>
                            <p class="mt-sty-desc">{$style.description|escape}</p>
                        </div>
                        <div class="mt-sty-footer">
                            {if $style.isActive}
                                <span class="mt-badge mt-badge-success">Active</span>
                            {else}
                                <span class="mt-sty-activate">Activate</span>
                            {/if}
                            {* <a href> is interactive content, so clicking it does NOT
                               toggle the wrapping label's radio — it just navigates. *}
                            <a class="mt-sty-edit" href="?module=Hadrian&action=editStyle&style={$style.name|escape}&subcat=typography">Customize &rsaquo;</a>
                        </div>
                    </label>
                {/foreach}
            </div>
        </form>
    </section>
</div>

{include file="includes/footer.tpl"}
