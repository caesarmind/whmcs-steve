{include file="includes/header.tpl"}

<header class="mt-page-header">
    <h1 class="mt-page-title">
        {$template.name|escape}
        <span class="mt-page-meta">v{$template.version|escape}</span>
    </h1>
    <p class="mt-page-subtitle">Configure styles, layouts, and pages for this template.</p>
</header>

<div class="mt-detail-grid">
    <section class="mt-section">
        <header class="mt-section-header">
            <h2 class="mt-section-title">Styles</h2>
            <span class="mt-section-count">{$template.styles|count}</span>
        </header>
        <div class="mt-section-body">
            <ul class="mt-detail-list">
                {foreach $template.styles as $s}
                    <li>
                        <span>{$s|escape|capitalize}</span>
                    </li>
                {/foreach}
            </ul>
            <div style="margin-top:16px">
                <a href="{$viewHelper->url('styles')}" class="mt-btn mt-btn-secondary mt-btn-sm">Manage styles</a>
            </div>
        </div>
    </section>

    <section class="mt-section">
        <header class="mt-section-header">
            <h2 class="mt-section-title">Layouts</h2>
        </header>
        <div class="mt-section-body">
            <div class="mt-detail-kicker">Main menu</div>
            <ul class="mt-detail-list">
                {foreach $template.layouts['main-menu'] as $l}
                    <li><span>{$l|escape|capitalize}</span></li>
                {/foreach}
            </ul>
            <div class="mt-detail-kicker">Footer</div>
            <ul class="mt-detail-list">
                {foreach $template.layouts.footer as $l}
                    <li><span>{$l|escape|capitalize}</span></li>
                {/foreach}
            </ul>
            <div style="margin-top:16px">
                <a href="{$viewHelper->url('layouts')}" class="mt-btn mt-btn-secondary mt-btn-sm">Manage layouts</a>
            </div>
        </div>
    </section>
</div>

<section class="mt-section">
    <header class="mt-section-header">
        <h2 class="mt-section-title">Pages</h2>
        <span class="mt-section-count">{$template.pages|count} declared</span>
    </header>
    <div class="mt-section-body">
        <ul class="mt-detail-list">
            {foreach $template.pages as $p}
                <li><span>{$p|escape}</span></li>
            {/foreach}
        </ul>
    </div>
</section>

{include file="includes/footer.tpl"}
