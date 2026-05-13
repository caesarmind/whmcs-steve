{include file="includes/header.tpl"}

<header class="mt-page-header">
    <div class="mt-page-eyebrow">Theme</div>
    <h1 class="mt-page-title">Pages</h1>
    <p class="mt-page-subtitle">Configure template variant, SEO, options and layout overrides for each WHMCS page.</p>
</header>

{if $flashMsg == 'saved'}
    <div class="mt-alert mt-alert-success">Page settings saved.</div>
{/if}

<div class="mt-tabs" id="mt-pages-tabs" role="tablist">
    <a class="mt-tab is-active" href="#tab=all" data-tab="all" role="tab">
        All <span class="mt-tab-pill" data-tab-pill>{$totalCount}</span>
    </a>
    {foreach $groups as $g}
        <a class="mt-tab" href="#tab={$g|escape:'url'}" data-tab="{$g|escape}" role="tab">
            {$g|escape} <span class="mt-tab-pill" data-tab-pill>{$pagesByGroup[$g]|count}</span>
        </a>
    {/foreach}
</div>

<style>
.mt-tab-pill { display:inline-block; margin-left:6px; padding:1px 7px; border-radius:999px; background:var(--mt-border); color:var(--mt-text-3); font-size:11px; font-weight:500; line-height:1.6; min-width:18px; text-align:center; }
.mt-tab.is-active .mt-tab-pill { background:var(--mt-primary-tint); color:var(--mt-primary); }
.mt-pages-section[hidden] { display:none !important; }
</style>

{foreach $groups as $g}
    {assign var=groupRows value=$pagesByGroup[$g]}
    <section class="mt-section mt-pages-section" data-group-section="{$g|escape}">
        <header class="mt-section-header">
            <h2 class="mt-section-title">{$g|escape} pages</h2>
            <span class="mt-section-count">{$groupRows|count}</span>
        </header>

        {if $groupRows|count}
            <div class="mt-table-wrap">
                <table class="mt-table">
                    <thead>
                        <tr>
                            <th>Name</th>
                            <th>Variant</th>
                            <th>SEO</th>
                            <th>Indexing</th>
                            <th>Visibility</th>
                            <th></th>
                        </tr>
                    </thead>
                    <tbody>
                        {foreach $groupRows as $page}
                            <tr>
                                <td class="mt-table-name">
                                    <div>{$page.label|escape}</div>
                                    {if $page.description}
                                        <div style="font-size:12px;color:var(--mt-text-3);margin-top:2px;">{$page.description|escape}</div>
                                    {/if}
                                </td>
                                <td>{$page.variantLabel|escape}</td>
                                <td>
                                    {if $page.hasSeo}
                                        <span class="mt-badge mt-badge-success">SEO</span>
                                    {else}
                                        <span class="mt-badge mt-badge-neutral">—</span>
                                    {/if}
                                </td>
                                <td>
                                    {if $page.indexing == 'allow'}
                                        <span class="mt-badge mt-badge-success">Allow</span>
                                    {elseif $page.indexing == 'disallow'}
                                        <span class="mt-badge mt-badge-warning">Disallow</span>
                                    {else}
                                        <span class="mt-badge mt-badge-neutral">Inherit</span>
                                    {/if}
                                </td>
                                <td>
                                    {if $page.visibility == 'disabled'}
                                        <span class="mt-badge mt-badge-warning">Disabled</span>
                                    {elseif $page.visibility == 'auth'}
                                        <span class="mt-badge mt-badge-primary">Auth only</span>
                                    {else}
                                        <span class="mt-badge mt-badge-neutral">Public</span>
                                    {/if}
                                </td>
                                <td class="mt-table-actions">
                                    <a href="?module=MyTheme&action=pages&sub=edit&page={$page.name|escape:'url'}" class="mt-btn mt-btn-ghost mt-btn-sm">Edit</a>
                                </td>
                            </tr>
                        {/foreach}
                    </tbody>
                </table>
            </div>
        {else}
            <div class="mt-empty">
                <h3 class="mt-empty-title">No pages in this group</h3>
                <p>Add a <code>core/pages/&lt;page&gt;/page.php</code> with <code>'group' =&gt; '{$g|escape}'</code> and rebuild discovery from the Tools tab.</p>
            </div>
        {/if}
    </section>
{/foreach}

<script>
(function() {
    var tabs = document.querySelectorAll('#mt-pages-tabs .mt-tab');
    var sections = document.querySelectorAll('.mt-pages-section');
    if (!tabs.length || !sections.length) return;

    var validTabs = {};
    Array.prototype.forEach.call(tabs, function(t) { validTabs[t.getAttribute('data-tab')] = true; });

    function activate(name) {
        if (!validTabs[name]) name = 'all';
        Array.prototype.forEach.call(tabs, function(t) {
            t.classList.toggle('is-active', t.getAttribute('data-tab') === name);
        });
        Array.prototype.forEach.call(sections, function(s) {
            var visible = (name === 'all') || (s.getAttribute('data-group-section') === name);
            if (visible) { s.removeAttribute('hidden'); } else { s.setAttribute('hidden', ''); }
        });
        try { history.replaceState(null, '', '#tab=' + encodeURIComponent(name)); } catch (e) {}
        try { localStorage.setItem('mt-pages-tab', name); } catch (e) {}
    }

    Array.prototype.forEach.call(tabs, function(t) {
        t.addEventListener('click', function(e) {
            e.preventDefault();
            activate(t.getAttribute('data-tab'));
        });
    });

    // Resolve initial tab: URL hash > localStorage > default 'all'.
    var initial = null;
    var m = window.location.hash.match(/tab=([^&]+)/);
    if (m) { try { initial = decodeURIComponent(m[1]); } catch (e) {} }
    if (!initial) { try { initial = localStorage.getItem('mt-pages-tab'); } catch (e) {} }
    if (!initial) initial = 'all';
    activate(initial);

    // React to back/forward navigation that changes the hash.
    window.addEventListener('hashchange', function() {
        var mm = window.location.hash.match(/tab=([^&]+)/);
        if (mm) { try { activate(decodeURIComponent(mm[1])); } catch (e) {} }
    });
})();
</script>

{include file="includes/footer.tpl"}
