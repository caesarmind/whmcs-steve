{include file="includes/header.tpl"}

<header class="mt-page-header">
    <h1 class="mt-page-title">Layouts</h1>
    <p class="mt-page-subtitle">
        Pick the navigation and footer arrangement for <strong>{$template|escape}</strong>.
        Each layout has two independent activations &mdash; one for guests (unauthenticated visitors) and one for existing clients (logged in).
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

    {* Lagom-style per-row activation. Each (layout, audience) cell is its
       own <form><button> — clicking is unambiguously a server round-trip,
       so the "click did nothing" failure mode of an onchange-driven radio
       can't happen here. The button's name+value get POSTed because only
       the clicked submit button's name=value pair is included. *}
    <div class="mt-table-wrap">
        <table class="mt-table">
            <thead>
                <tr>
                    <th>Layout</th>
                    <th>Guest client</th>
                    <th>Existing client</th>
                </tr>
            </thead>
            <tbody>
                {foreach $layouts as $layout}
                    <tr>
                        <td class="mt-table-name">
                            <strong>{$layout.displayName|escape}</strong>
                            {if $layout.description}
                                <div class="mt-table-muted">{$layout.description|escape}</div>
                            {/if}
                        </td>
                        <td>
                            {if $layout.isActiveGuest}
                                <span class="mt-badge mt-badge-success">Active</span>
                            {else}
                                <form method="post" action="" style="display:inline">
                                    <input type="hidden" name="layout"   value="{$layout.name|escape}">
                                    <input type="hidden" name="audience" value="guest">
                                    <button type="submit" class="mt-btn mt-btn-ghost mt-btn-sm">Activate for Guest</button>
                                </form>
                            {/if}
                        </td>
                        <td>
                            {if $layout.isActiveClient}
                                <span class="mt-badge mt-badge-success">Active</span>
                            {else}
                                <form method="post" action="" style="display:inline">
                                    <input type="hidden" name="layout"   value="{$layout.name|escape}">
                                    <input type="hidden" name="audience" value="client">
                                    <button type="submit" class="mt-btn mt-btn-ghost mt-btn-sm">Activate for Existing</button>
                                </form>
                            {/if}
                        </td>
                    </tr>
                {/foreach}
            </tbody>
        </table>
    </div>
</section>

{include file="includes/footer.tpl"}
