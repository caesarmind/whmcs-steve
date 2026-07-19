{include file="includes/header.tpl"}

<header class="mt-page-header">
    <div class="mt-page-eyebrow">Theme</div>
    <h1 class="mt-page-title">Layouts</h1>
    <p class="mt-page-subtitle">
        Pick the navigation and footer arrangement for <strong>{$template|escape}</strong>.
        Each layout has two independent activations &mdash; one for guests (unauthenticated visitors) and one for existing clients (logged in).
    </p>
</header>

<style>
{literal}
    .mt-lay-cards{display:grid;grid-template-columns:repeat(auto-fill,minmax(250px,1fr));gap:14px}
    .mt-lay-card{border:1px solid var(--mt-border);border-radius:14px;background:var(--mt-surface);display:flex;flex-direction:column;overflow:hidden;transition:border-color .15s ease,box-shadow .15s ease}
    .mt-lay-card.is-on{border-color:var(--mt-primary);box-shadow:0 0 0 3px var(--mt-primary-ring)}

    /* The wireframe inherits `color`, so one rule recolors the whole drawing on
       activation and both themes work without a second set of hex values. The
       marks sitting ON the accent bar stay white in both themes by design. */
    .mt-lay-thumb{background:var(--mt-surface-2);border-bottom:1px solid var(--mt-border);color:var(--mt-text-4);transition:background .15s ease,color .15s ease}
    .mt-lay-card.is-on .mt-lay-thumb{background:var(--mt-primary-tint);color:var(--mt-primary)}
    .mt-lay-thumb svg{width:100%;height:auto;display:block}

    .mt-lay-b{padding:13px 14px;display:flex;flex-direction:column;gap:10px;flex:1}
    .mt-lay-title{font-weight:600;font-size:14.5px;color:var(--mt-text)}
    .mt-lay-desc{font-size:12.5px;color:var(--mt-text-3);margin-top:-5px;min-height:32px;line-height:1.45}

    /* Guest / client activation. Two independent switches, not a radio group --
       a layout can be live for one audience and not the other. */
    .mt-lay-auds{display:flex;gap:7px;border-top:1px solid var(--mt-border);padding-top:11px;margin-top:auto}
    .mt-lay-auds form{flex:1;display:flex;margin:0}
    .mt-lay-aud{flex:1;display:inline-flex;align-items:center;gap:7px;padding:7px 9px;border-radius:9px;border:1px solid var(--mt-border);background:var(--mt-surface);font:inherit;font-size:12.5px;color:var(--mt-text-2);cursor:pointer;text-align:left;transition:background .15s ease,border-color .15s ease,color .15s ease}
    .mt-lay-aud:hover{background:var(--mt-surface-2);color:var(--mt-text)}
    .mt-lay-aud:focus-visible{outline:2px solid var(--mt-primary);outline-offset:1px}
    .mt-lay-aud.is-on{border-color:var(--mt-primary);background:var(--mt-primary-tint);color:var(--mt-primary);font-weight:600;cursor:default}
    .mt-lay-radio{width:15px;height:15px;border-radius:50%;border:1.5px solid var(--mt-text-4);display:inline-flex;align-items:center;justify-content:center;flex-shrink:0;transition:background .15s ease,border-color .15s ease}
    .mt-lay-aud.is-on .mt-lay-radio{border-color:var(--mt-primary);background:var(--mt-primary)}
    .mt-lay-radio svg{width:9px;height:9px;display:none}
    .mt-lay-aud.is-on .mt-lay-radio svg{display:block;color:#fff}

    .mt-lay-opt{border-top:1px solid var(--mt-border);padding-top:11px}
    .mt-lay-opt-lbl{font-size:11.5px;font-weight:600;color:var(--mt-text-2);display:block;margin-bottom:6px}
    .mt-seg{display:inline-flex;background:var(--mt-surface-2);border-radius:9px;padding:3px;gap:2px;width:100%;border:0;margin:0}
    .mt-seg button{flex:1;border:0;background:transparent;font:inherit;font-size:12px;font-weight:500;color:var(--mt-text-2);padding:6px 0;border-radius:7px;cursor:pointer}
    .mt-seg button:hover{color:var(--mt-text)}
    .mt-seg button.on{background:var(--mt-surface);color:var(--mt-text);box-shadow:0 1px 2px rgba(0,0,0,.12)}
    .mt-lay-optnone{border-top:1px dashed var(--mt-border);padding-top:11px;font-size:11.5px;color:var(--mt-text-3);font-style:italic}
{/literal}
</style>

<div class="mt-tabs" role="tablist">
    <a href="{$viewHelper->url('layouts', ['kind' => 'main-menu'])}"
       class="mt-tab {if $activeKind == 'main-menu'}is-active{/if}" data-kind-tab="main-menu">Main menu</a>
    <a href="{$viewHelper->url('layouts', ['kind' => 'footer'])}"
       class="mt-tab {if $activeKind == 'footer'}is-active{/if}" data-kind-tab="footer">Footer</a>
</div>

<div class="mt-panel pad">
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
                            <svg viewBox="0 0 150 86" role="img" aria-label="Top navigation wireframe">
                                <rect x="0" y="0" width="150" height="16" fill="currentColor"/>
                                <rect x="8" y="6" width="20" height="4" rx="2" fill="#fff" opacity=".9"/>
                                <rect x="66" y="6" width="12" height="4" rx="2" fill="#fff" opacity=".55"/>
                                <rect x="82" y="6" width="12" height="4" rx="2" fill="#fff" opacity=".55"/>
                                <rect x="14" y="28" width="64" height="6" rx="3" fill="currentColor" opacity=".45"/>
                                <rect x="14" y="42" width="122" height="32" rx="5" fill="currentColor" opacity=".13"/>
                            </svg>
                        {elseif $layout.name == 'sidebar'}
                            <svg viewBox="0 0 150 86" role="img" aria-label="Sidebar wireframe">
                                <rect x="0" y="0" width="40" height="86" fill="currentColor"/>
                                <rect x="8" y="10" width="24" height="5" rx="2" fill="#fff" opacity=".9"/>
                                <rect x="8" y="26" width="24" height="4" rx="2" fill="#fff" opacity=".5"/>
                                <rect x="8" y="36" width="24" height="4" rx="2" fill="#fff" opacity=".5"/>
                                <rect x="8" y="46" width="24" height="4" rx="2" fill="#fff" opacity=".5"/>
                                <rect x="52" y="16" width="56" height="6" rx="3" fill="currentColor" opacity=".45"/>
                                <rect x="52" y="30" width="86" height="44" rx="5" fill="currentColor" opacity=".13"/>
                            </svg>
                        {elseif $layout.name == 'rail'}
                            <svg viewBox="0 0 150 86" role="img" aria-label="Icon rail wireframe">
                                <rect x="0" y="0" width="19" height="86" fill="currentColor"/>
                                <circle cx="9.5" cy="14" r="4" fill="#fff" opacity=".9"/>
                                <circle cx="9.5" cy="31" r="3" fill="#fff" opacity=".5"/>
                                <circle cx="9.5" cy="44" r="3" fill="#fff" opacity=".5"/>
                                <circle cx="9.5" cy="57" r="3" fill="#fff" opacity=".5"/>
                                <rect x="31" y="16" width="56" height="6" rx="3" fill="currentColor" opacity=".45"/>
                                <rect x="31" y="30" width="106" height="44" rx="5" fill="currentColor" opacity=".13"/>
                            </svg>
                        {elseif $layout.name == 'extended'}
                            <svg viewBox="0 0 150 86" role="img" aria-label="Extended footer wireframe">
                                <rect x="16" y="10" width="118" height="22" rx="5" fill="currentColor" opacity=".11"/>
                                <rect x="0" y="40" width="150" height="46" fill="currentColor"/>
                                <g fill="#fff">
                                    <rect x="12" y="49" width="18" height="3" rx="1.5" opacity=".8"/>
                                    <rect x="12" y="57" width="16" height="2.5" rx="1" opacity=".4"/>
                                    <rect x="12" y="63" width="16" height="2.5" rx="1" opacity=".4"/>
                                    <rect x="46" y="49" width="18" height="3" rx="1.5" opacity=".8"/>
                                    <rect x="46" y="57" width="16" height="2.5" rx="1" opacity=".4"/>
                                    <rect x="46" y="63" width="16" height="2.5" rx="1" opacity=".4"/>
                                    <rect x="80" y="49" width="18" height="3" rx="1.5" opacity=".8"/>
                                    <rect x="80" y="57" width="16" height="2.5" rx="1" opacity=".4"/>
                                    <rect x="80" y="63" width="16" height="2.5" rx="1" opacity=".4"/>
                                    <rect x="114" y="49" width="18" height="3" rx="1.5" opacity=".8"/>
                                    <rect x="114" y="57" width="16" height="2.5" rx="1" opacity=".4"/>
                                    <rect x="114" y="63" width="16" height="2.5" rx="1" opacity=".4"/>
                                </g>
                            </svg>
                        {elseif $layout.name == 'extended-info'}
                            <svg viewBox="0 0 150 86" role="img" aria-label="Extended footer with info band wireframe">
                                <rect x="16" y="8" width="118" height="18" rx="5" fill="currentColor" opacity=".11"/>
                                <rect x="0" y="34" width="150" height="34" fill="currentColor"/>
                                <g fill="#fff">
                                    <rect x="12" y="42" width="18" height="3" rx="1.5" opacity=".8"/>
                                    <rect x="12" y="50" width="16" height="2.5" rx="1" opacity=".4"/>
                                    <rect x="12" y="56" width="16" height="2.5" rx="1" opacity=".4"/>
                                    <rect x="52" y="42" width="18" height="3" rx="1.5" opacity=".8"/>
                                    <rect x="52" y="50" width="16" height="2.5" rx="1" opacity=".4"/>
                                    <rect x="92" y="42" width="18" height="3" rx="1.5" opacity=".8"/>
                                    <rect x="92" y="50" width="16" height="2.5" rx="1" opacity=".4"/>
                                </g>
                                <rect x="0" y="70" width="150" height="16" fill="currentColor" opacity=".5"/>
                                <rect x="12" y="76" width="30" height="4" rx="2" fill="#fff" opacity=".65"/>
                                <rect x="108" y="76" width="30" height="4" rx="2" fill="#fff" opacity=".45"/>
                            </svg>
                        {else}
                            {* Default / single-row footer, and the fallback for any
                               layout that ships without its own wireframe. *}
                            <svg viewBox="0 0 150 86" role="img" aria-label="Default footer wireframe">
                                <rect x="16" y="12" width="118" height="46" rx="5" fill="currentColor" opacity=".11"/>
                                <rect x="0" y="66" width="150" height="20" fill="currentColor"/>
                                <rect x="12" y="73" width="26" height="5" rx="2.5" fill="#fff" opacity=".85"/>
                                <rect x="104" y="73" width="34" height="5" rx="2.5" fill="#fff" opacity=".45"/>
                            </svg>
                        {/if}
                    </div>

                    <div class="mt-lay-b">
                        <div class="mt-lay-title">{$layout.displayName|escape}</div>
                        {if $layout.description}<div class="mt-lay-desc">{$layout.description|escape}</div>{/if}

                        <div class="mt-lay-auds">
                            {if $layout.isActiveGuest}
                                <span class="mt-lay-aud is-on">
                                    <span class="mt-lay-radio"><svg viewBox="0 0 10 10" fill="none" aria-hidden="true"><path d="M1.5 5.2l2.2 2.2L8.5 2.6" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/></svg></span>
                                    Guest
                                </span>
                            {else}
                                <form method="post" action="">
                                    <input type="hidden" name="kind"     value="{$k|escape}">
                                    <input type="hidden" name="layout"   value="{$layout.name|escape}">
                                    <input type="hidden" name="audience" value="guest">
                                    <button type="submit" class="mt-lay-aud" title="Activate {$layout.displayName|escape} for guests">
                                        <span class="mt-lay-radio"></span> Guest
                                    </button>
                                </form>
                            {/if}

                            {if $layout.isActiveClient}
                                <span class="mt-lay-aud is-on">
                                    <span class="mt-lay-radio"><svg viewBox="0 0 10 10" fill="none" aria-hidden="true"><path d="M1.5 5.2l2.2 2.2L8.5 2.6" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/></svg></span>
                                    Client
                                </span>
                            {else}
                                <form method="post" action="">
                                    <input type="hidden" name="kind"     value="{$k|escape}">
                                    <input type="hidden" name="layout"   value="{$layout.name|escape}">
                                    <input type="hidden" name="audience" value="client">
                                    <button type="submit" class="mt-lay-aud" title="Activate {$layout.displayName|escape} for logged-in clients">
                                        <span class="mt-lay-radio"></span> Client
                                    </button>
                                </form>
                            {/if}
                        </div>

                        {* Loop every declared option, don't hardcode 'align'.
                           The controller and Hooks::buildLayoutMeta are already
                           generic over supportedOptions, so a layout declaring a
                           second option rendered NOTHING here while remaining
                           settable by POST — the same shape as the page-editor
                           bug where 55 of 60 options fell through to a text box.
                           Only 'align' exists today, so this changes no output. *}
                        {if $layout.options}
                            {foreach $layout.options as $optKey => $opt}
                            <div class="mt-lay-opt">
                                <span class="mt-lay-opt-lbl">{$opt.label|escape}</span>
                                <form method="post" action="" class="mt-seg">
                                    <input type="hidden" name="kind"   value="{$k|escape}">
                                    <input type="hidden" name="layout" value="{$layout.name|escape}">
                                    <input type="hidden" name="option" value="{$optKey|escape}">
                                    {foreach $opt.choices as $cval => $clabel}
                                        <button type="submit" name="value" value="{$cval|escape}"{if $cval == $opt.value} class="on"{/if}>{$clabel|escape}</button>
                                    {/foreach}
                                </form>
                            </div>
                            {/foreach}
                        {elseif $k == 'main-menu'}
                            <div class="mt-lay-optnone">No alignment option &mdash; content is always centered.</div>
                        {/if}
                    </div>
                </div>
            {/foreach}
        </div>
    </section>
{/foreach}
</div>

<script>
{literal}
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
{/literal}
</script>

{include file="includes/footer.tpl"}
