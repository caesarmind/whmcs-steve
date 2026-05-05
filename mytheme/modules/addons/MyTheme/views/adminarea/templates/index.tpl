{include file="includes/header.tpl"}

<header class="mt-page-header">
    <h1 class="mt-page-title">Templates</h1>
    <p class="mt-page-subtitle">Manage installed themes. Pick one to configure styles, layouts and pages.</p>
</header>

<section class="mt-section">
    <header class="mt-section-header">
        <h2 class="mt-section-title">Installed</h2>
        <span class="mt-section-count">{$templates|count} found</span>
    </header>

    <div class="mt-section-body">
        {if $templates|count > 0}
            <div class="mt-grid">
                {foreach $templates as $tpl}
                    <article class="mt-card {if $tpl.isActive}is-active{/if}">
                        <div class="mt-card-thumb">{$tpl.displayName|escape|truncate:1:""}</div>
                        <div class="mt-card-body">
                            <h3 class="mt-card-title">{$tpl.displayName|escape}</h3>
                            <p class="mt-card-meta">Version {$tpl.version|escape}</p>
                        </div>
                        <div class="mt-card-footer">
                            {if $tpl.canActivate}
                                {if $tpl.isActive}
                                    <span class="mt-badge mt-badge-success">Active</span>
                                {else}
                                    <span class="mt-badge mt-badge-primary">Ready</span>
                                {/if}
                                <a href="{$viewHelper->url('template', ['templateName' => $tpl.slug])}" class="mt-btn mt-btn-primary mt-btn-sm">Configure</a>
                            {else}
                                <span class="mt-badge mt-badge-warning">License invalid</span>
                                <a href="{$viewHelper->url('license')}" class="mt-btn mt-btn-secondary mt-btn-sm">Set key</a>
                            {/if}
                        </div>
                    </article>
                {/foreach}
            </div>
        {else}
            <div class="mt-empty">
                <svg class="mt-empty-icon" viewBox="0 0 48 48" fill="none">
                    <rect x="8" y="10" width="32" height="28" rx="3" stroke="currentColor" stroke-width="2"/>
                    <path d="M8 18h32" stroke="currentColor" stroke-width="2"/>
                </svg>
                <h3 class="mt-empty-title">No templates installed</h3>
                <p class="mt-empty-body">Drop a template directory into <code>templates/</code> and refresh this page.</p>
            </div>
        {/if}
    </div>
</section>

{include file="includes/footer.tpl"}
