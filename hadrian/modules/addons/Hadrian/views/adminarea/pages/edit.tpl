{include file="includes/header.tpl"}

<div class="mt-toolbar">
    <a class="mt-back" href="?module=Hadrian&action=pages#tab={$pageGroup|escape:'url'}">
        <svg viewBox="0 0 16 16" fill="none"><path d="M10 13L5 8l5-5" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round"/></svg>
        Back to Pages
    </a>
    <button form="page-edit-form" class="mt-btn mt-btn-primary mt-btn-sm">Save changes</button>
</div>

<header class="mt-page-header">
    <div class="mt-page-eyebrow">{$pageGroup|escape}</div>
    <h1 class="mt-page-title">{$pageLabel|escape} <span class="mt-page-meta">/ Page editor</span></h1>
    {if $pageDescription}
        <p class="mt-page-subtitle">{$pageDescription|escape}</p>
    {/if}
</header>

{if $flashMsg == 'saved'}
    <div class="mt-alert mt-alert-success">Saved.</div>
{/if}

<form id="page-edit-form" method="post" action="?module=Hadrian&action=pages&sub=save">
    <input type="hidden" name="page" value="{$page|escape}">

    <div class="mt-panel pad">
    <section class="mt-section">
        <header class="mt-section-header"><h2 class="mt-section-title">Template variant</h2></header>
        {if $variants|count}
            <div class="mt-variant-grid" data-saved-variant="{$activeVariant|escape}">
                {foreach $variants as $v}
                    <label class="mt-variant {if $v.name == $activeVariant}is-active{/if}">
                        <input type="radio" name="variant" value="{$v.name|escape}" {if $v.name == $activeVariant}checked{/if} hidden>
                        <div>
                            <div class="mt-variant-name">{$v.label|escape}</div>
                            {if $v.description}
                                <div style="font-size:12px;color:var(--mt-text-3);margin-top:2px;">{$v.description|escape}</div>
                            {/if}
                        </div>
                        {if $v.name == $activeVariant}
                            <span class="mt-badge mt-badge-success">Active</span>
                        {else}
                            <span class="mt-badge mt-badge-neutral">Click to activate</span>
                        {/if}
                    </label>
                {/foreach}
            </div>
        {else}
            <div class="mt-empty">
                <p>No variants found under <code>core/pages/{$page|escape}/</code>.</p>
            </div>
        {/if}
    </section>
    </div>

    {if $hasOptions}
        <div class="mt-panel pad">
        <section class="mt-section">
            <header class="mt-section-header"><h2 class="mt-section-title">Page options</h2></header>
            {foreach $optionRows as $opt}
                {* 'checkbox' is the type every pageoption.php in the theme
                   actually declares; only 'bool' was handled here, so 48
                   toggles across the page editor rendered as text inputs an
                   admin could not meaningfully switch off. *}
                {if $opt.type == 'bool' || $opt.type == 'checkbox'}
                    <div class="mt-row">
                        <div>
                            <div class="mt-row-label">{$opt.label|escape}</div>
                            {if $opt.help}<div class="mt-row-help">{$opt.help|escape}</div>{/if}
                        </div>
                        <label class="mt-toggle">
                            <input type="hidden" name="option[{$opt.key|escape}]" value="0">
                            <input type="checkbox" name="option[{$opt.key|escape}]" value="1" {if $opt.value}checked{/if}>
                            <span class="mt-toggle-track"><span class="mt-toggle-thumb"></span></span>
                        </label>
                    </div>
                {elseif $opt.type == 'select' && $opt.options}
                    <div class="mt-field">
                        <label class="mt-field-label" for="opt-{$opt.key|escape}">{$opt.label|escape}</label>
                        {if $opt.help}<div class="mt-row-help">{$opt.help|escape}</div>{/if}
                        <select id="opt-{$opt.key|escape}" class="mt-select" name="option[{$opt.key|escape}]">
                            {foreach $opt.options as $mtChoice}
                                <option value="{$mtChoice|escape}"{if (string)$opt.value == (string)$mtChoice} selected{/if}>{$mtChoice|escape}</option>
                            {/foreach}
                        </select>
                    </div>
                {else}
                    <div class="mt-field">
                        <label class="mt-field-label" for="opt-{$opt.key|escape}">{$opt.label|escape}</label>
                        {if $opt.help}<div class="mt-row-help">{$opt.help|escape}</div>{/if}
                        <input id="opt-{$opt.key|escape}" class="mt-input" type="text"
                               name="option[{$opt.key|escape}]" value="{$opt.value|escape}">
                    </div>
                {/if}
            {/foreach}
        </section>
        </div>
    {/if}

    <div class="mt-panel pad">
    <section class="mt-section">
        <header class="mt-section-header"><h2 class="mt-section-title">SEO</h2></header>

        <div class="mt-inline-row">
            <div class="mt-row-label">Search engine indexing</div>
            <select class="mt-select" name="indexing">
                <option value="inherit"  {if $indexing == 'inherit'}selected{/if}>Inherit from site default</option>
                <option value="allow"    {if $indexing == 'allow'}selected{/if}>Allow</option>
                <option value="disallow" {if $indexing == 'disallow'}selected{/if}>Disallow</option>
            </select>
        </div>

        <div class="mt-field" style="margin-top:16px">
            <label class="mt-field-label" for="seo-url">Public URL</label>
            <div class="mt-row-help">Path relative to your site root, used in the sitemap (e.g. <code>announcements.php</code>). Leave blank to keep this page out of the sitemap.</div>
            <input id="seo-url" class="mt-input" type="text" name="url" maxlength="255" value="{$seoUrl|escape}" placeholder="page.php">
        </div>

        {* Per-language SEO. A single-language install shows one title +
           description; multi-language installs repeat the pair per language.
           Stored + submitted as seo_title[<lang>] / seo_description[<lang>]. *}
        {assign var=titleMap value=$seo.title}
        {assign var=descMap value=$seo.description}
        {foreach $seoLanguages as $lng}
            {assign var=lcode value=$lng.name}
            {if $seoLanguages|count > 1}
                <div style="margin-top:16px;font-size:12px;font-weight:600;color:var(--mt-text-3);text-transform:uppercase;letter-spacing:.04em;">{$lng.label|escape}</div>
            {/if}
            <div class="mt-field"{if $seoLanguages|count <= 1} style="margin-top:16px"{/if}>
                <div class="mt-field-row">
                    <label class="mt-field-label" for="seo-title-{$lcode|escape}">SEO title</label>
                    <div class="mt-field-tools">
                        <span class="mt-charcount">{$titleMap[$lcode]|default:''|strlen}/64</span>
                    </div>
                </div>
                <input id="seo-title-{$lcode|escape}" class="mt-input" type="text" name="seo_title[{$lcode|escape}]" maxlength="64" value="{$titleMap[$lcode]|default:''|escape}" placeholder="{$pageLabel|escape}">
            </div>

            <div class="mt-field">
                <div class="mt-field-row">
                    <label class="mt-field-label" for="seo-desc-{$lcode|escape}">SEO description</label>
                    <div class="mt-field-tools">
                        <span class="mt-charcount">{$descMap[$lcode]|default:''|strlen}/160</span>
                    </div>
                </div>
                <textarea id="seo-desc-{$lcode|escape}" class="mt-textarea" name="seo_description[{$lcode|escape}]" rows="3" maxlength="160">{$descMap[$lcode]|default:''|escape}</textarea>
            </div>
        {/foreach}

        <div class="mt-field">
            <label class="mt-field-label" for="seo-social">Social image URL</label>
            <input id="seo-social" class="mt-input" type="text" name="seo_social_image" maxlength="500" value="{$seo.social_image|escape}" placeholder="/path/to/og-image.jpg (recommended 1200×630)">
        </div>
    </section>
    </div>

    <div class="mt-panel pad">
    <section class="mt-section">
        <header class="mt-section-header"><h2 class="mt-section-title">Layout overrides</h2></header>
        <div class="mt-inline-row">
            <div>
                <div class="mt-row-label">Main menu layout</div>
                <div class="mt-row-help">Override the global main-menu layout for this page only.</div>
            </div>
            <select class="mt-select" name="layout_main_menu">
                {foreach $layoutChoices['main-menu'] as $choice}
                    <option value="{$choice.name|escape}" {if $choice.name == ($layoutOverrides['main-menu']|default:'')}selected{/if}>{$choice.label|escape}</option>
                {/foreach}
            </select>
        </div>
        <div class="mt-inline-row">
            <div>
                <div class="mt-row-label">Footer layout</div>
                <div class="mt-row-help">Override the global footer layout for this page only.</div>
            </div>
            <select class="mt-select" name="layout_footer">
                {foreach $layoutChoices['footer'] as $choice}
                    <option value="{$choice.name|escape}" {if $choice.name == ($layoutOverrides['footer']|default:'')}selected{/if}>{$choice.label|escape}</option>
                {/foreach}
            </select>
        </div>
    </section>
    </div>

    <div class="mt-panel pad">
    <section class="mt-section">
        <header class="mt-section-header"><h2 class="mt-section-title">Sub-navigation</h2></header>
        <div class="mt-inline-row">
            <div>
                <div class="mt-row-label">Section sub-nav</div>
                <div class="mt-row-help">Show or hide this page's sidebar sub-nav. <strong>Inherit</strong> follows the global toggle (Settings → Order / Website Section Sidebar).</div>
            </div>
            <select class="mt-select" name="subnav">
                <option value="inherit" {if $subnav == 'inherit'}selected{/if}>Inherit (global default)</option>
                <option value="on"      {if $subnav == 'on'}selected{/if}>On (always show)</option>
                <option value="off"     {if $subnav == 'off'}selected{/if}>Off (always hide)</option>
            </select>
        </div>
    </section>
    </div>

    {if $svcLayoutApplicable}
    <div class="mt-panel pad">
    <section class="mt-section">
        <header class="mt-section-header"><h2 class="mt-section-title">Service list controls</h2></header>
        <div class="mt-inline-row">
            <div>
                <div class="mt-row-label">Controls placement</div>
                <div class="mt-row-help">Where this page's search &amp; pagination controls sit. <strong>Inside</strong> keeps them in the white card; <strong>Outside</strong> floats them on the page. <strong>Inherit</strong> follows the global toggle (Settings &rarr; Service List Controls).</div>
            </div>
            <select class="mt-select" name="svclayout">
                <option value="inherit" {if $svclayout == 'inherit'}selected{/if}>Inherit (global default)</option>
                <option value="inside"  {if $svclayout == 'inside'}selected{/if}>Inside the card</option>
                <option value="outside" {if $svclayout == 'outside'}selected{/if}>Outside the card</option>
            </select>
        </div>
    </section>
    </div>
    {/if}

    <div class="mt-panel pad">
    <section class="mt-section">
        <header class="mt-section-header"><h2 class="mt-section-title">Visibility</h2></header>
        <div class="mt-inline-row">
            <div>
                <div class="mt-row-label">Who can see this page</div>
                <div class="mt-row-help">Disabled pages return 404. Auth-only pages redirect logged-out visitors to login.</div>
            </div>
            <select class="mt-select" name="visibility">
                <option value="public"   {if $visibility == 'public'}selected{/if}>Public</option>
                <option value="auth"     {if $visibility == 'auth'}selected{/if}>Authenticated only</option>
                <option value="disabled" {if $visibility == 'disabled'}selected{/if}>Disabled (404)</option>
            </select>
        </div>
    </section>
    </div>
</form>

{literal}
<script>
// Variant picker: the cards are <label>s around hidden radios, so selection
// works natively — but nothing highlights on click. Wire live feedback and
// explicitly set the radio so the choice is reliable, then Save persists it.
(function () {
    var grid = document.querySelector('.mt-variant-grid');
    if (!grid) return;
    var cards = Array.prototype.slice.call(grid.querySelectorAll('.mt-variant'));
    if (cards.length < 2) return;
    var saved = grid.getAttribute('data-saved-variant') || '';

    function render() {
        var checked = grid.querySelector('input[name="variant"]:checked');
        var sel = checked ? checked.value : '';
        cards.forEach(function (card) {
            var radio = card.querySelector('input[name="variant"]');
            var isSel = !!(radio && radio.value === sel);
            card.classList.toggle('is-active', isSel);
            var badge = card.querySelector('.mt-badge');
            if (!badge) return;
            badge.textContent = isSel
                ? (radio.value === saved ? 'Active' : 'Selected — Save to apply')
                : 'Click to activate';
            badge.classList.remove('mt-badge-success', 'mt-badge-neutral');
            badge.classList.add(isSel ? 'mt-badge-success' : 'mt-badge-neutral');
        });
    }

    cards.forEach(function (card) {
        card.addEventListener('click', function () {
            var radio = card.querySelector('input[name="variant"]');
            if (radio) radio.checked = true;
            render();
        });
    });
})();
</script>
{/literal}

{include file="includes/footer.tpl"}
