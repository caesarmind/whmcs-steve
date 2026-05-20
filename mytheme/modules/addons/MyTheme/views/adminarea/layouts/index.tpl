{include file="includes/header.tpl"}

<header class="mt-page-header">
    <h1 class="mt-page-title">Layouts</h1>
    <p class="mt-page-subtitle">
        Pick the navigation and footer arrangement for <strong>{$template|escape}</strong>.
        Each layout has two independent activations &mdash; one for guests (unauthenticated visitors) and one for existing clients (logged in).
    </p>
</header>

<style>
    .mt-lay-cards{display:grid;grid-template-columns:repeat(auto-fill,minmax(280px,1fr));gap:16px}
    .mt-lay-card{border:1.5px solid var(--mt-line2,#d2d2d7);border-radius:14px;background:#fff;display:flex;flex-direction:column;overflow:hidden}
    .mt-lay-card.is-on{border-color:var(--mt-primary,#0071e3);box-shadow:0 0 0 3px rgba(0,113,227,.10)}
    .mt-lay-thumb{height:96px;background:var(--mt-surface-2,#f5f5f7);border-bottom:1px solid var(--mt-border,#e5e5ea);display:flex;align-items:center;justify-content:center}
    .mt-lay-thumb svg{width:122px;height:78px;display:block}
    .mt-lay-b{padding:14px 15px;display:flex;flex-direction:column;gap:11px;flex:1}
    .mt-lay-title{font-weight:600;font-size:14.5px}
    .mt-lay-desc{font-size:12.5px;color:var(--mt-text-3,#86868b);margin-top:-6px;min-height:34px}
    .mt-lay-acts{display:flex;flex-direction:column;gap:7px;border-top:1px solid var(--mt-border,#e5e5ea);padding-top:11px}
    .mt-lay-act{display:flex;align-items:center;justify-content:space-between;font-size:12.5px;color:var(--mt-text-2,#6e6e73)}
    .mt-lay-opt{border-top:1px solid var(--mt-border,#e5e5ea);padding-top:11px}
    .mt-lay-opt-lbl{font-size:11.5px;font-weight:600;color:var(--mt-text-2,#6e6e73);display:block;margin-bottom:6px}
    .mt-seg{display:inline-flex;background:var(--mt-surface-2,#f2f2f4);border-radius:9px;padding:3px;gap:2px;width:100%;border:0;margin:0}
    .mt-seg button{flex:1;border:0;background:transparent;font:inherit;font-size:12px;font-weight:500;color:var(--mt-text-2,#6e6e73);padding:6px 0;border-radius:7px;cursor:pointer}
    .mt-seg button.on{background:#fff;color:var(--mt-text,#1d1d1f);box-shadow:0 1px 2px rgba(0,0,0,.12)}
    .mt-lay-optnone{border-top:1px dashed var(--mt-border,#e5e5ea);padding-top:11px;font-size:11.5px;color:var(--mt-text-3,#86868b);font-style:italic}
</style>

<div class="mt-tabs" role="tablist">
    <a href="{$viewHelper->url('layouts', ['kind' => 'main-menu'])}"
       class="mt-tab {if $activeKind == 'main-menu'}is-active{/if}" data-kind-tab="main-menu">Main menu</a>
    <a href="{$viewHelper->url('layouts', ['kind' => 'footer'])}"
       class="mt-tab {if $activeKind == 'footer'}is-active{/if}" data-kind-tab="footer">Footer</a>
</div>

{foreach $groups as $k => $list}
    <section class="mt-section" data-kind-panel="{$k}"{if $k != $activeKind} hidden{/if}>
        <header class="mt-section-header">
            <h2 class="mt-section-title">{if $k == 'main-menu'}Main menu layouts{else}Footer layouts{/if}</h2>
            <span class="mt-section-count">{$list|count}</span>
        </header>

        <div class="mt-lay-cards">
            {foreach $list as $layout}
                <div class="mt-lay-card{if $layout.isActiveGuest || $layout.isActiveClient} is-on{/if}">
                    <div class="mt-lay-thumb">
                        {if $layout.name == 'top'}
                            <svg viewBox="0 0 122 78"><rect x=".5" y=".5" width="121" height="77" rx="7" fill="#fff" stroke="#e5e5ea"/><rect x="9" y="9" width="104" height="14" rx="3" fill="#9cc2f5"/><rect x="9" y="31" width="58" height="6" rx="3" fill="#dfe1e6"/><rect x="9" y="43" width="104" height="26" rx="4" fill="#f0f1f4"/></svg>
                        {elseif $layout.name == 'sidebar'}
                            <svg viewBox="0 0 122 78"><rect x=".5" y=".5" width="121" height="77" rx="7" fill="#fff" stroke="#e5e5ea"/><rect x="9" y="9" width="32" height="60" rx="4" fill="#9cc2f5"/><rect x="49" y="13" width="48" height="6" rx="3" fill="#dfe1e6"/><rect x="49" y="27" width="64" height="42" rx="4" fill="#f0f1f4"/></svg>
                        {elseif $layout.name == 'rail'}
                            <svg viewBox="0 0 122 78"><rect x=".5" y=".5" width="121" height="77" rx="7" fill="#fff" stroke="#e5e5ea"/><rect x="9" y="9" width="14" height="60" rx="4" fill="#9cc2f5"/><rect x="31" y="13" width="48" height="6" rx="3" fill="#dfe1e6"/><rect x="31" y="27" width="82" height="42" rx="4" fill="#f0f1f4"/></svg>
                        {elseif $layout.name == 'extended'}
                            <svg viewBox="0 0 122 78"><rect x=".5" y=".5" width="121" height="77" rx="7" fill="#fff" stroke="#e5e5ea"/><rect x="9" y="9" width="104" height="30" rx="4" fill="#f0f1f4"/><rect x="9" y="45" width="22" height="24" rx="3" fill="#9cc2f5"/><rect x="36" y="45" width="22" height="24" rx="3" fill="#9cc2f5"/><rect x="63" y="45" width="22" height="24" rx="3" fill="#9cc2f5"/><rect x="90" y="45" width="22" height="24" rx="3" fill="#9cc2f5"/></svg>
                        {elseif $layout.name == 'extended-info'}
                            <svg viewBox="0 0 122 78"><rect x=".5" y=".5" width="121" height="77" rx="7" fill="#fff" stroke="#e5e5ea"/><rect x="9" y="9" width="104" height="26" rx="4" fill="#f0f1f4"/><rect x="9" y="41" width="42" height="28" rx="3" fill="#bcd5f8"/><rect x="56" y="41" width="26" height="28" rx="3" fill="#9cc2f5"/><rect x="87" y="41" width="26" height="28" rx="3" fill="#9cc2f5"/></svg>
                        {else}
                            {* default footer / fallback *}
                            <svg viewBox="0 0 122 78"><rect x=".5" y=".5" width="121" height="77" rx="7" fill="#fff" stroke="#e5e5ea"/><rect x="9" y="11" width="104" height="40" rx="4" fill="#f0f1f4"/><rect x="9" y="58" width="104" height="11" rx="3" fill="#9cc2f5"/></svg>
                        {/if}
                    </div>

                    <div class="mt-lay-b">
                        <div class="mt-lay-title">{$layout.displayName|escape}</div>
                        {if $layout.description}<div class="mt-lay-desc">{$layout.description|escape}</div>{/if}

                        <div class="mt-lay-acts">
                            <div class="mt-lay-act">
                                <span>Guest client</span>
                                {if $layout.isActiveGuest}
                                    <span class="mt-badge mt-badge-success">Active</span>
                                {else}
                                    <form method="post" action="" style="display:inline">
                                        <input type="hidden" name="kind"     value="{$k|escape}">
                                        <input type="hidden" name="layout"   value="{$layout.name|escape}">
                                        <input type="hidden" name="audience" value="guest">
                                        <button type="submit" class="mt-btn mt-btn-ghost mt-btn-sm">Activate</button>
                                    </form>
                                {/if}
                            </div>
                            <div class="mt-lay-act">
                                <span>Existing client</span>
                                {if $layout.isActiveClient}
                                    <span class="mt-badge mt-badge-success">Active</span>
                                {else}
                                    <form method="post" action="" style="display:inline">
                                        <input type="hidden" name="kind"     value="{$k|escape}">
                                        <input type="hidden" name="layout"   value="{$layout.name|escape}">
                                        <input type="hidden" name="audience" value="client">
                                        <button type="submit" class="mt-btn mt-btn-ghost mt-btn-sm">Activate</button>
                                    </form>
                                {/if}
                            </div>
                        </div>

                        {if isset($layout.options.align)}
                            <div class="mt-lay-opt">
                                <span class="mt-lay-opt-lbl">{$layout.options.align.label|escape}</span>
                                <form method="post" action="" class="mt-seg">
                                    <input type="hidden" name="kind"   value="{$k|escape}">
                                    <input type="hidden" name="layout" value="{$layout.name|escape}">
                                    <input type="hidden" name="option" value="align">
                                    {foreach $layout.options.align.choices as $cval => $clabel}
                                        <button type="submit" name="value" value="{$cval|escape}"{if $cval == $layout.options.align.value} class="on"{/if}>{$clabel|escape}</button>
                                    {/foreach}
                                </form>
                            </div>
                        {elseif $k == 'main-menu'}
                            <div class="mt-lay-optnone">No alignment option &mdash; content is always centered.</div>
                        {/if}
                    </div>
                </div>
            {/foreach}
        </div>
    </section>
{/foreach}

<script>
(function () {
    // Client-side tab switch (no reload). The links keep real ?kind= hrefs as a
    // no-JS fallback; the server already renders the active tab from ?kind.
    var tabs   = document.querySelectorAll('[data-kind-tab]');
    var panels = document.querySelectorAll('[data-kind-panel]');
    function show(kind){
        panels.forEach(function (p) { p.hidden = p.getAttribute('data-kind-panel') !== kind; });
        tabs.forEach(function (t) { t.classList.toggle('is-active', t.getAttribute('data-kind-tab') === kind); });
    }
    tabs.forEach(function (t) {
        t.addEventListener('click', function (e) { e.preventDefault(); show(t.getAttribute('data-kind-tab')); });
    });
})();
</script>

{include file="includes/footer.tpl"}
