{include file="includes/header.tpl"}

<header class="mt-page-header">
    <div class="mt-page-eyebrow">Theme</div>
    <h1 class="mt-page-title">Settings</h1>
    <p class="mt-page-subtitle">Theme-wide options. Save to apply.</p>
</header>

<div class="mt-tabs" role="tablist">
    <a class="mt-tab {if $tab == 'general'}is-active{/if}" href="?module=MyTheme&action=settings&tab=general">General</a>
    <a class="mt-tab {if $tab == 'order'}is-active{/if}" href="?module=MyTheme&action=settings&tab=order">Order Process</a>
</div>

<style>
    .mt-tab-off { display: none !important; }
    .mt-row-with-sub { border-bottom: 0; }
    .mt-subnav-checks { display: grid; grid-template-columns: repeat(auto-fill, minmax(190px, 1fr)); gap: 6px 18px; margin-top: 6px; }
    .mt-subnav-check { display: flex; align-items: center; gap: 8px; font-size: 13px; color: var(--mt-text); padding: 3px 0; cursor: pointer; }
    .mt-subnav-check input { margin: 0; flex-shrink: 0; }
    .mt-row-sub { padding: 4px 0 18px; border-bottom: 1px solid var(--mt-border); }
    .mt-row-sub[hidden] { display: none; }
    .mt-row-sub-head { display: flex; align-items: baseline; justify-content: space-between; gap: 16px; margin-bottom: 4px; }
    .mt-row-sub-title { font-size: 14px; font-weight: 500; margin: 0; }
    .mt-row-sub-help { font-size: 12px; color: var(--mt-text-3); margin: 0 0 14px; }
    .mt-row-sub-count { font-size: 13px; color: var(--mt-text-3); }

    /* Plain dropdown sub-field (dark-mode Display Type / Default Mode). */
    .mt-field { max-width: 520px; margin-bottom: 16px; }
    .mt-field:last-child { margin-bottom: 0; }
    .mt-field-label { display: block; font-size: 13px; font-weight: 500; color: var(--mt-text); margin-bottom: 6px; }
    .mt-field-help { font-size: 12px; color: var(--mt-text-3); margin: 6px 0 0; }
    .mt-select { width: 100%; padding: 9px 10px; font: inherit; font-size: 13px; border: 1px solid var(--mt-input-border); border-radius: 8px; background: var(--mt-surface); color: var(--mt-text); cursor: pointer; }
    .mt-select:focus { outline: none; border-color: var(--mt-primary, #0071e3); box-shadow: 0 0 0 3px rgba(0,113,227,0.15); }

    /* Chip multi-select — single field with removable chips + dropdown picker.
       Replaces the previous grid of checkbox-chips. The real form fields
       live in a hidden .mt-multi-inputs container; the visible widget is
       just a view onto their state. */
    .mt-multi-wrap { position: relative; max-width: 520px; }
    .mt-multi {
        width: 100%;
        min-height: 40px;
        padding: 5px 32px 5px 8px;
        border: 1px solid var(--mt-input-border);
        border-radius: 8px;
        background: var(--mt-surface);
        display: flex;
        flex-wrap: wrap;
        align-items: center;
        gap: 4px;
        cursor: pointer;
        position: relative;
        transition: border-color .15s, box-shadow .15s;
    }
    .mt-multi:hover { border-color: var(--mt-text-3); }
    .mt-multi.is-focused { border-color: var(--mt-primary, #0071e3); box-shadow: 0 0 0 3px rgba(0,113,227,0.15); }
    .mt-multi-caret {
        position: absolute;
        right: 12px;
        top: 50%;
        transform: translateY(-50%);
        color: var(--mt-text-4);
        pointer-events: none;
    }
    .mt-multi-caret svg { width: 12px; height: 12px; display: block; }
    .mt-multi-placeholder { color: var(--mt-text-3); font-size: 13px; padding: 6px 4px; }
    .mt-multi-placeholder[hidden] { display: none; }
    .mt-multi-chip {
        display: inline-flex;
        align-items: center;
        gap: 4px;
        height: 26px;
        padding: 0 4px 0 9px;
        background: var(--mt-surface-2, #f5f5f7);
        border: 1px solid var(--mt-border);
        border-radius: 6px;
        font-size: 12.5px;
        color: var(--mt-text);
    }
    .mt-multi-chip-x {
        color: var(--mt-primary, #0071e3);
        cursor: pointer;
        padding: 0 4px;
        line-height: 1;
        font-size: 14px;
        font-weight: 500;
        border-radius: 3px;
        user-select: none;
    }
    .mt-multi-chip-x:hover { background: rgba(0,113,227,0.10); }

    .mt-multi-panel {
        position: absolute;
        left: 0; right: 0; top: calc(100% + 4px);
        background: var(--mt-surface);
        border: 1px solid var(--mt-border);
        border-radius: 8px;
        box-shadow: 0 8px 24px rgba(0,0,0,0.08);
        z-index: 30;
        max-height: 300px;
        display: flex;
        flex-direction: column;
        overflow: hidden;
    }
    .mt-multi-panel[hidden] { display: none; }
    .mt-multi-panel--up { top: auto; bottom: calc(100% + 4px); }
    .mt-multi-search-wrap { padding: 8px; border-bottom: 1px solid var(--mt-border); }
    .mt-multi-search-wrap input { width: 100%; padding: 6px 10px; font-size: 13px; border: 1px solid var(--mt-input-border); border-radius: 6px; background: var(--mt-surface); font: inherit; }
    .mt-multi-search-wrap input:focus { outline: none; border-color: var(--mt-primary, #0071e3); box-shadow: 0 0 0 2px rgba(0,113,227,0.15); }
    .mt-multi-options { padding: 4px; overflow-y: auto; flex: 1; }
    .mt-multi-option {
        display: flex;
        align-items: center;
        gap: 9px;
        width: 100%;
        padding: 7px 10px;
        border: 0;
        background: transparent;
        border-radius: 4px;
        font: inherit;
        font-size: 13px;
        color: var(--mt-text);
        cursor: pointer;
        text-align: left;
    }
    .mt-multi-option:hover { background: var(--mt-surface-2, #f5f5f7); }
    .mt-multi-option .mt-multi-check {
        width: 14px;
        height: 14px;
        border: 1.5px solid var(--mt-input-border);
        border-radius: 3px;
        display: inline-flex;
        align-items: center;
        justify-content: center;
        flex-shrink: 0;
        background: var(--mt-surface);
    }
    .mt-multi-option.is-checked .mt-multi-check { background: var(--mt-primary, #0071e3); border-color: var(--mt-primary, #0071e3); }
    .mt-multi-option .mt-multi-check svg { width: 10px; height: 10px; opacity: 0; }
    .mt-multi-option.is-checked .mt-multi-check svg { opacity: 1; }
    .mt-multi-empty { padding: 14px; text-align: center; color: var(--mt-text-3); font-size: 12px; }

    /* "All" pseudo-option — separated from the language list with a divider,
       and visually disabled when a specific language is checked. */
    .mt-multi-option.is-all {
        font-weight: 600;
        border-bottom: 1px solid var(--mt-border);
        border-radius: 4px 4px 0 0;
        padding-bottom: 9px;
        margin-bottom: 4px;
    }
    .mt-multi-option .mt-multi-globe { color: var(--mt-text-3); display: inline-flex; align-items: center; }
    .mt-multi-option .mt-multi-globe svg { width: 14px; height: 14px; display: block; }
    .mt-multi-option.is-all.is-checked .mt-multi-globe { color: var(--mt-primary, #0071e3); }
    .mt-multi-option.is-disabled {
        opacity: 0.4;
        cursor: not-allowed;
        pointer-events: none;
    }
    .mt-multi-option.is-disabled .mt-multi-globe { color: var(--mt-text-4); }

    /* "All" chip — distinguished from regular chips with the primary tint + globe icon */
    .mt-multi-chip.is-all {
        background: rgba(0, 113, 227, 0.08);
        border-color: rgba(0, 113, 227, 0.20);
        color: var(--mt-primary, #0071e3);
        font-weight: 500;
    }
    .mt-multi-chip-icon { display: inline-flex; align-items: center; color: currentColor; }
    .mt-multi-chip-icon svg { width: 12px; height: 12px; display: block; }
</style>

<form method="post" action="" novalidate>
    <div class="mt-panel">
    <section class="mt-section">
        <header class="mt-section-header">
            <h2 class="mt-section-title">{if $tab == 'order'}Order Process{else}General{/if} Settings</h2>
            <div class="mt-section-tools">
                <button type="submit" class="mt-btn mt-btn-primary mt-btn-sm">Save changes</button>
            </div>
        </header>

        {foreach $flags as $key => $meta}
            {assign var=mtIsLangToggle value=($key == 'custom_language_list')}
            {assign var=mtFlagTab value=$flagTabs[$key]|default:'general'}
            {assign var=mtHasSub value=($mtIsLangToggle || $key == 'cart_subnav' || $key == 'website_subnav' || $key == 'service_controls_outside' || $key == 'enable_dark_mode' || $key == 'cookie_box')}
            <div class="mt-row{if $mtHasSub} mt-row-with-sub{/if}{if $mtFlagTab != $tab} mt-tab-off{/if}">
                <div>
                    <div class="mt-row-label">{$meta[0]|escape}</div>
                    <div class="mt-row-help">{$meta[1]|escape}</div>
                </div>
                <label class="mt-toggle">
                    <input type="checkbox" name="{$key|escape}" {if $mtIsLangToggle}data-toggle-target="mt-language-picker" {/if}{if $key == 'enable_dark_mode'}data-toggle-target="mt-darkmode-sub" {/if}{if $key == 'cookie_box'}data-toggle-target="mt-cookiebox-sub" {/if}{if $values[$key]}checked{/if}>
                    <span class="mt-toggle-track"><span class="mt-toggle-thumb"></span></span>
                </label>
            </div>

            {* Lagom-style sub-field: the language picker lives directly below
               the toggle row it belongs to, with no border separating them.
               Always renders so the form can submit; hidden by default when
               the toggle is off — JS reveals it on toggle change. *}
            {if $mtIsLangToggle}
                <div class="mt-row-sub{if $mtFlagTab != $tab} mt-tab-off{/if}" id="mt-language-picker"{if !$values[$key]} hidden{/if}>
                    <header class="mt-row-sub-head">
                        <h3 class="mt-row-sub-title">Languages shown to clients</h3>
                        <span class="mt-row-sub-count" id="mt-lang-count"></span>
                    </header>
                    <p class="mt-row-sub-help">
                        Pick which languages appear in the locale chooser. Only languages installed in <code>/lang/</code> are shown.
                        {if !$installedLanguages}<strong>No language files found.</strong>{/if}
                    </p>

                    {if $installedLanguages}
                        <div class="mt-multi-wrap" id="mt-lang-wrap">
                            {* Hidden form fields — the source of truth for submission. The
                               visible widget below just mirrors their checked state. *}
                            <div class="mt-multi-inputs" hidden id="mt-lang-inputs">
                                {foreach $installedLanguages as $code}
                                    <input type="checkbox" name="{$langListKey|escape}[]" value="{$code|escape}"{if in_array($code, $selectedLanguages)} checked{/if}>
                                {/foreach}
                            </div>

                            {* Visible chip field *}
                            <div class="mt-multi" id="mt-lang-multi" tabindex="0" role="combobox" aria-haspopup="listbox" aria-expanded="false">
                                <div class="mt-multi-chips" id="mt-lang-chips"></div>
                                <span class="mt-multi-placeholder" id="mt-lang-placeholder">Click to add languages…</span>
                                <span class="mt-multi-caret" aria-hidden="true">
                                    <svg viewBox="0 0 16 16" fill="none"><path d="M4 6l4 4 4-4" stroke="currentColor" stroke-width="1.5" stroke-linecap="round"/></svg>
                                </span>
                            </div>

                            {* Dropdown panel *}
                            <div class="mt-multi-panel" id="mt-lang-panel" hidden role="listbox" aria-multiselectable="true">
                                <div class="mt-multi-search-wrap">
                                    <input type="search" id="mt-lang-search" placeholder="Search languages…" autocomplete="off" aria-label="Search languages">
                                </div>
                                <div class="mt-multi-options" id="mt-lang-options">
                                    {* "All" is a pseudo-option: it represents the "no restriction"
                                       state (all installed languages checked). It auto-disables
                                       when any specific language is checked — to re-enable it,
                                       remove the specific selections first. *}
                                    <button type="button" class="mt-multi-option is-all" data-code="__all__" role="option" aria-selected="false">
                                        <span class="mt-multi-check" aria-hidden="true">
                                            <svg viewBox="0 0 16 16" fill="none" stroke="#fff" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><polyline points="3 8 7 12 13 4"/></svg>
                                        </span>
                                        <span class="mt-multi-globe" aria-hidden="true">
                                            <svg viewBox="0 0 14 14" fill="none"><circle cx="7" cy="7" r="5.5" stroke="currentColor" stroke-width="1.2"/><path d="M1.5 7h11M7 1.5c2 1.5 2 9.5 0 11M7 1.5c-2 1.5-2 9.5 0 11" stroke="currentColor" stroke-width="1.2"/></svg>
                                        </span>
                                        <span>All</span>
                                    </button>
                                    {foreach $installedLanguages as $code}
                                        <button type="button" class="mt-multi-option" data-code="{$code|escape}" role="option" aria-selected="false">
                                            <span class="mt-multi-check" aria-hidden="true">
                                                <svg viewBox="0 0 16 16" fill="none" stroke="#fff" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><polyline points="3 8 7 12 13 4"/></svg>
                                            </span>
                                            <span>{$code|escape|capitalize}</span>
                                        </button>
                                    {/foreach}
                                </div>
                                <div class="mt-multi-empty" id="mt-lang-empty" hidden>No languages match.</div>
                            </div>
                        </div>
                    {/if}
                </div>
            {/if}

            {* Dark-mode options — Lagom-style sub-field revealed under the
               "Enable Dark Mode" toggle. Display Type chooses Switcher vs
               Forced; Default Mode chooses the mode the site loads in. *}
            {if $key == 'enable_dark_mode'}
                <div class="mt-row-sub{if $mtFlagTab != $tab} mt-tab-off{/if}" id="mt-darkmode-sub"{if !$values[$key]} hidden{/if}>
                    <div class="mt-field">
                        <label class="mt-field-label" for="mt-dark-display">Choose Display Type</label>
                        <select class="mt-select" id="mt-dark-display" name="dark_mode_display">
                            <option value="switcher"{if $darkModeDisplay != 'forced'} selected{/if}>Switcher (Light/Dark)</option>
                            <option value="forced"{if $darkModeDisplay == 'forced'} selected{/if}>Forced</option>
                        </select>
                        <p class="mt-field-help">Switcher gives visitors a light/dark toggle. Forced locks the site to the default mode (no toggle).</p>
                    </div>
                    <div class="mt-field">
                        <label class="mt-field-label" for="mt-dark-default">Choose Default Mode</label>
                        <select class="mt-select" id="mt-dark-default" name="dark_mode_default">
                            <option value="light"{if $darkModeDefault != 'dark'} selected{/if}>Light</option>
                            <option value="dark"{if $darkModeDefault == 'dark'} selected{/if}>Dark</option>
                        </select>
                        <p class="mt-field-help">The mode the site loads in (no OS auto-detect).</p>
                    </div>
                </div>
            {/if}

            {* Cookie Box options — Lagom-style sub-field revealed under the
               "Cookie Box" toggle. Message (HTML allowed), screen position,
               and the dismiss button label. *}
            {if $key == 'cookie_box'}
                <div class="mt-row-sub{if $mtFlagTab != $tab} mt-tab-off{/if}" id="mt-cookiebox-sub"{if !$values[$key]} hidden{/if}>
                    <div class="mt-field">
                        <label class="mt-field-label" for="mt-cookie-lang">Message</label>
                        {if $installedLanguages}
                            {* Per-language ("translate") control, Lagom-parity. The
                               switcher picks which language's textarea is visible;
                               every language's textarea stays in the DOM so they all
                               submit together as cookie_box_message[<code>] on save. *}
                            <div class="mt-cookie-msg-i18n" data-cookie-msg-i18n>
                                <select class="mt-select" id="mt-cookie-lang" data-cookie-msg-switch style="max-width:240px;margin-bottom:10px;">
                                    {foreach $installedLanguages as $code}
                                        <option value="{$code|escape}"{if $code == $defaultLanguage} selected{/if}>{$code|escape|capitalize}{if $code == $defaultLanguage} (default){/if}{if isset($cookieBoxMessages[$code]) && $cookieBoxMessages[$code] != ''} &bull;{/if}</option>
                                    {/foreach}
                                </select>
                                {foreach $installedLanguages as $code}
                                    <textarea class="mt-input mt-cookie-msg-pane" data-cookie-msg-pane="{$code|escape}" name="cookie_box_message[{$code|escape}]" rows="3" placeholder="We use cookies to improve your experience..."{if $code != $defaultLanguage} hidden{/if}>{if isset($cookieBoxMessages[$code])}{$cookieBoxMessages[$code]|escape}{/if}</textarea>
                                {/foreach}
                            </div>
                            <p class="mt-field-help">Shown in the cookie bar, per language. Visitors see their active language; if it has no message, the site default language is used, then a built-in fallback. Basic HTML (e.g. a privacy-policy link) is allowed. A <strong>&bull;</strong> marks languages that already have a message.</p>
                        {else}
                            {* No language files detected under /lang/ — fall back to a single English box. *}
                            <textarea class="mt-input" id="mt-cookie-msg" name="cookie_box_message[english]" rows="3" placeholder="We use cookies to improve your experience...">{if isset($cookieBoxMessages['english'])}{$cookieBoxMessages['english']|escape}{/if}</textarea>
                            <p class="mt-field-help">Shown in the cookie bar. Basic HTML (e.g. a privacy-policy link) is allowed.</p>
                        {/if}
                    </div>
                    <div class="mt-field">
                        <label class="mt-field-label" for="mt-cookie-pos">Position</label>
                        <select class="mt-select" id="mt-cookie-pos" name="cookie_box_position">
                            <option value="bottom-left"{if $cookieBoxPosition == 'bottom-left'} selected{/if}>Bottom left</option>
                            <option value="bottom-right"{if $cookieBoxPosition == 'bottom-right'} selected{/if}>Bottom right</option>
                            <option value="bottom"{if $cookieBoxPosition == 'bottom'} selected{/if}>Bottom (full width)</option>
                        </select>
                    </div>
                    <div class="mt-field" style="margin-bottom:0;">
                        <label class="mt-field-label" for="mt-cookie-btn">Button label</label>
                        <input class="mt-input" type="text" id="mt-cookie-btn" name="cookie_box_button" value="{$cookieBoxButton|escape}" placeholder="Continue" style="max-width:200px;">
                    </div>
                </div>
            {/if}

            {* Order sub-nav exception picker — renders under the
               "Order Category Sidebar" toggle (Order Process tab). *}
            {if $key == 'cart_subnav'}
                <div class="mt-row-sub{if $mtFlagTab != $tab} mt-tab-off{/if}">
                    <header class="mt-row-sub-head">
                        <h3 class="mt-row-sub-title">Per-page exceptions</h3>
                    </header>
                    <p class="mt-row-sub-help">Pages added here are <strong>exceptions</strong> — the order sub-nav is flipped on them (hidden when the toggle above is On, shown when Off). A page's own setting in the Pages editor still wins.</p>
                    <div class="mt-multi-wrap" data-chip-picker>
                        <div class="mt-multi-inputs" hidden>
                            {foreach $orderPages as $oTf => $oLabel}
                                <input type="checkbox" name="subnav_pages_order[]" value="{$oTf|escape}"{if in_array($oTf, $subnavOrderList)} checked{/if}>
                            {/foreach}
                        </div>
                        <div class="mt-multi" tabindex="0" role="combobox" aria-haspopup="listbox" aria-expanded="false">
                            <div class="mt-multi-chips"></div>
                            <span class="mt-multi-placeholder">Click to add pages…</span>
                            <span class="mt-multi-caret" aria-hidden="true"><svg viewBox="0 0 16 16" fill="none"><path d="M4 6l4 4 4-4" stroke="currentColor" stroke-width="1.5" stroke-linecap="round"/></svg></span>
                        </div>
                        <div class="mt-multi-panel" hidden role="listbox" aria-multiselectable="true">
                            <div class="mt-multi-search-wrap"><input type="search" placeholder="Search pages…" autocomplete="off" aria-label="Search pages"></div>
                            <div class="mt-multi-options">
                                {foreach $orderPages as $oTf => $oLabel}
                                    <button type="button" class="mt-multi-option" data-code="{$oTf|escape}" data-label="{$oLabel|escape}" role="option" aria-selected="false">
                                        <span class="mt-multi-check" aria-hidden="true"><svg viewBox="0 0 16 16" fill="none" stroke="#fff" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><polyline points="3 8 7 12 13 4"/></svg></span>
                                        <span>{$oLabel|escape}</span>
                                    </button>
                                {/foreach}
                            </div>
                            <div class="mt-multi-empty" hidden>No pages match.</div>
                        </div>
                    </div>
                </div>
            {/if}

            {* Website sub-nav exception picker — renders under the
               "Website Section Sidebar" toggle (General tab). *}
            {if $key == 'website_subnav'}
                <div class="mt-row-sub{if $mtFlagTab != $tab} mt-tab-off{/if}">
                    <header class="mt-row-sub-head">
                        <h3 class="mt-row-sub-title">Per-page exceptions</h3>
                    </header>
                    <p class="mt-row-sub-help">Pages added here are <strong>exceptions</strong> — the section sub-nav is flipped on them (hidden when the toggle above is On, shown when Off). A page's own setting in the Pages editor still wins.</p>
                    <div class="mt-multi-wrap" data-chip-picker>
                        <div class="mt-multi-inputs" hidden>
                            {foreach $websitePages as $wTf => $wLabel}
                                <input type="checkbox" name="subnav_pages_website[]" value="{$wTf|escape}"{if in_array($wTf, $subnavWebsiteList)} checked{/if}>
                            {/foreach}
                        </div>
                        <div class="mt-multi" tabindex="0" role="combobox" aria-haspopup="listbox" aria-expanded="false">
                            <div class="mt-multi-chips"></div>
                            <span class="mt-multi-placeholder">Click to add pages…</span>
                            <span class="mt-multi-caret" aria-hidden="true"><svg viewBox="0 0 16 16" fill="none"><path d="M4 6l4 4 4-4" stroke="currentColor" stroke-width="1.5" stroke-linecap="round"/></svg></span>
                        </div>
                        <div class="mt-multi-panel" hidden role="listbox" aria-multiselectable="true">
                            <div class="mt-multi-search-wrap"><input type="search" placeholder="Search pages…" autocomplete="off" aria-label="Search pages"></div>
                            <div class="mt-multi-options">
                                {foreach $websitePages as $wTf => $wLabel}
                                    <button type="button" class="mt-multi-option" data-code="{$wTf|escape}" data-label="{$wLabel|escape}" role="option" aria-selected="false">
                                        <span class="mt-multi-check" aria-hidden="true"><svg viewBox="0 0 16 16" fill="none" stroke="#fff" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><polyline points="3 8 7 12 13 4"/></svg></span>
                                        <span>{$wLabel|escape}</span>
                                    </button>
                                {/foreach}
                            </div>
                            <div class="mt-multi-empty" hidden>No pages match.</div>
                        </div>
                    </div>
                </div>
            {/if}

            {* Service-list-controls exception picker — renders under the
               "Service List Controls" toggle (General tab). *}
            {if $key == 'service_controls_outside'}
                <div class="mt-row-sub{if $mtFlagTab != $tab} mt-tab-off{/if}">
                    <header class="mt-row-sub-head">
                        <h3 class="mt-row-sub-title">Per-page exceptions</h3>
                    </header>
                    <p class="mt-row-sub-help">Pages added here are <strong>exceptions</strong> — the controls layout is flipped on them (inside when the toggle above is On, outside when Off). A page's own setting in the Pages editor still wins.</p>
                    <div class="mt-multi-wrap" data-chip-picker>
                        <div class="mt-multi-inputs" hidden>
                            {foreach $svcPages as $sTf => $sLabel}
                                <input type="checkbox" name="svc_layout_pages[]" value="{$sTf|escape}"{if in_array($sTf, $svcLayoutList)} checked{/if}>
                            {/foreach}
                        </div>
                        <div class="mt-multi" tabindex="0" role="combobox" aria-haspopup="listbox" aria-expanded="false">
                            <div class="mt-multi-chips"></div>
                            <span class="mt-multi-placeholder">Click to add pages…</span>
                            <span class="mt-multi-caret" aria-hidden="true"><svg viewBox="0 0 16 16" fill="none"><path d="M4 6l4 4 4-4" stroke="currentColor" stroke-width="1.5" stroke-linecap="round"/></svg></span>
                        </div>
                        <div class="mt-multi-panel" hidden role="listbox" aria-multiselectable="true">
                            <div class="mt-multi-search-wrap"><input type="search" placeholder="Search pages…" autocomplete="off" aria-label="Search pages"></div>
                            <div class="mt-multi-options">
                                {foreach $svcPages as $sTf => $sLabel}
                                    <button type="button" class="mt-multi-option" data-code="{$sTf|escape}" data-label="{$sLabel|escape}" role="option" aria-selected="false">
                                        <span class="mt-multi-check" aria-hidden="true"><svg viewBox="0 0 16 16" fill="none" stroke="#fff" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><polyline points="3 8 7 12 13 4"/></svg></span>
                                        <span>{$sLabel|escape}</span>
                                    </button>
                                {/foreach}
                            </div>
                            <div class="mt-multi-empty" hidden>No pages match.</div>
                        </div>
                    </div>
                </div>
            {/if}
        {/foreach}

        {* ════════════════════════════════════════════════════════════════
           ORDER PROCESS (Lagom-parity) — Configure Server step controls.
           These render on the 'order' tab only (CSS-hidden elsewhere) but
           their inputs are always present, so a Save from any tab preserves
           them. $myTheme.addonSettings carries the values to the cart at
           runtime (mytheme_cart/configureproduct.tpl).
           ════════════════════════════════════════════════════════════════ *}
        {literal}<style>
        .mt-input { width: 100%; padding: 9px 10px; font: inherit; font-size: 13px; border: 1px solid var(--mt-input-border); border-radius: 8px; background: var(--mt-surface); color: var(--mt-text); }
        .mt-input:focus { outline: none; border-color: var(--mt-primary, #0071e3); box-shadow: 0 0 0 3px rgba(0,113,227,0.15); }
        .mt-input--sm { max-width: 140px; }
        /* .mt-field resolves to display:flex from the admin stylesheet, which
           overrides the UA [hidden]{display:none}; re-assert it so the group
           picker actually hides in "All Products" mode (and when off). */
        .mt-field[hidden] { display: none !important; }
        .mt-hostname-grid { display: grid; grid-template-columns: 1fr 140px 1fr; gap: 12px; max-width: 520px; }
        @media (max-width: 640px) { .mt-hostname-grid { grid-template-columns: 1fr; } }
        </style>{/literal}

        {* ── 1. Hide Product Nameservers ─────────────────────────────── *}
        <div class="mt-row mt-row-with-sub{if $tab != 'order'} mt-tab-off{/if}">
            <div>
                <div class="mt-row-label">Hide Product Nameservers</div>
                <div class="mt-row-help">Hide the NS1 Prefix and NS2 Prefix fields shown in the Configure Server section during the product configuration step.</div>
            </div>
            <label class="mt-toggle">
                <input type="checkbox" name="op_hide_nameservers_enabled" data-toggle-target="op-ns-sub"{if $opHideNs != 'off'} checked{/if}>
                <span class="mt-toggle-track"><span class="mt-toggle-thumb"></span></span>
            </label>
        </div>
        <div class="mt-row-sub{if $tab != 'order'} mt-tab-off{/if}" id="op-ns-sub"{if $opHideNs == 'off'} hidden{/if}>
            <div class="mt-field">
                <label class="mt-field-label" for="op-ns-mode">Apply to</label>
                <select class="mt-select" id="op-ns-mode" name="op_hide_nameservers_mode" data-reveal-when="selected" data-reveal-when-target="op-ns-groups">
                    <option value="all"{if $opHideNs != 'selected'} selected{/if}>All Products</option>
                    <option value="selected"{if $opHideNs == 'selected'} selected{/if}>Selected Product Groups</option>
                </select>
            </div>
            <div class="mt-field" id="op-ns-groups"{if $opHideNs != 'selected'} hidden{/if}>
                <label class="mt-field-label">Product groups</label>
                <div class="mt-multi-wrap" data-chip-picker>
                    <div class="mt-multi-inputs" hidden>
                        {foreach $productGroups as $pg}
                            <input type="checkbox" name="op_hide_nameservers_groups[]" value="{$pg.id}"{if in_array($pg.id, $opHideNsGroups)} checked{/if}>
                        {/foreach}
                    </div>
                    <div class="mt-multi" tabindex="0" role="combobox" aria-haspopup="listbox" aria-expanded="false">
                        <div class="mt-multi-chips"></div>
                        <span class="mt-multi-placeholder">Click to add product groups…</span>
                        <span class="mt-multi-caret" aria-hidden="true"><svg viewBox="0 0 16 16" fill="none"><path d="M4 6l4 4 4-4" stroke="currentColor" stroke-width="1.5" stroke-linecap="round"/></svg></span>
                    </div>
                    <div class="mt-multi-panel" hidden role="listbox" aria-multiselectable="true">
                        <div class="mt-multi-search-wrap"><input type="search" placeholder="Search groups…" autocomplete="off" aria-label="Search product groups"></div>
                        <div class="mt-multi-options">
                            {foreach $productGroups as $pg}
                                <button type="button" class="mt-multi-option" data-code="{$pg.id}" data-label="{$pg.name|escape}" role="option" aria-selected="false">
                                    <span class="mt-multi-check" aria-hidden="true"><svg viewBox="0 0 16 16" fill="none" stroke="#fff" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><polyline points="3 8 7 12 13 4"/></svg></span>
                                    <span>{$pg.name|escape}</span>
                                </button>
                            {/foreach}
                        </div>
                        <div class="mt-multi-empty" hidden>No groups match.</div>
                    </div>
                </div>
            </div>
        </div>

        {* ── 2. Hide Product Hostname (+ custom hostname + hide-on-checkout) ── *}
        <div class="mt-row mt-row-with-sub{if $tab != 'order'} mt-tab-off{/if}">
            <div>
                <div class="mt-row-label">Hide Product Hostname</div>
                <div class="mt-row-help">Hide the Hostname and Root Password fields shown in the Configure Server section during the product configuration step.</div>
            </div>
            <label class="mt-toggle">
                <input type="checkbox" name="op_hide_hostname_enabled" data-toggle-target="op-host-sub"{if $opHideHost != 'off'} checked{/if}>
                <span class="mt-toggle-track"><span class="mt-toggle-thumb"></span></span>
            </label>
        </div>
        <div class="mt-row-sub{if $tab != 'order'} mt-tab-off{/if}" id="op-host-sub"{if $opHideHost == 'off'} hidden{/if}>
            <div class="mt-field">
                <label class="mt-field-label" for="op-host-mode">Apply to</label>
                <select class="mt-select" id="op-host-mode" name="op_hide_hostname_mode" data-reveal-when="selected" data-reveal-when-target="op-host-groups">
                    <option value="all"{if $opHideHost != 'selected'} selected{/if}>All Products</option>
                    <option value="selected"{if $opHideHost == 'selected'} selected{/if}>Selected Product Groups</option>
                </select>
            </div>
            <div class="mt-field" id="op-host-groups"{if $opHideHost != 'selected'} hidden{/if}>
                <label class="mt-field-label">Product groups</label>
                <div class="mt-multi-wrap" data-chip-picker>
                    <div class="mt-multi-inputs" hidden>
                        {foreach $productGroups as $pg}
                            <input type="checkbox" name="op_hide_hostname_groups[]" value="{$pg.id}"{if in_array($pg.id, $opHideHostGroups)} checked{/if}>
                        {/foreach}
                    </div>
                    <div class="mt-multi" tabindex="0" role="combobox" aria-haspopup="listbox" aria-expanded="false">
                        <div class="mt-multi-chips"></div>
                        <span class="mt-multi-placeholder">Click to add product groups…</span>
                        <span class="mt-multi-caret" aria-hidden="true"><svg viewBox="0 0 16 16" fill="none"><path d="M4 6l4 4 4-4" stroke="currentColor" stroke-width="1.5" stroke-linecap="round"/></svg></span>
                    </div>
                    <div class="mt-multi-panel" hidden role="listbox" aria-multiselectable="true">
                        <div class="mt-multi-search-wrap"><input type="search" placeholder="Search groups…" autocomplete="off" aria-label="Search product groups"></div>
                        <div class="mt-multi-options">
                            {foreach $productGroups as $pg}
                                <button type="button" class="mt-multi-option" data-code="{$pg.id}" data-label="{$pg.name|escape}" role="option" aria-selected="false">
                                    <span class="mt-multi-check" aria-hidden="true"><svg viewBox="0 0 16 16" fill="none" stroke="#fff" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><polyline points="3 8 7 12 13 4"/></svg></span>
                                    <span>{$pg.name|escape}</span>
                                </button>
                            {/foreach}
                        </div>
                        <div class="mt-multi-empty" hidden>No groups match.</div>
                    </div>
                </div>
            </div>

            {* Use Custom Hostname — nested toggle revealing the pattern fields. *}
            <div class="mt-row mt-row-with-sub" style="border-top:1px solid var(--mt-border); padding-top:14px; margin-top:6px;">
                <div>
                    <div class="mt-row-label">Use Custom Hostname</div>
                    <div class="mt-row-help">The hostname is required by WHMCS even when hidden. Off: a random string is used. On: build it from the fields below — <code>&lt;random&gt;&lt;prefix&gt;&lt;suffix&gt;</code> (e.g. <code>a1b2c3.example.com</code>).</div>
                </div>
                <label class="mt-toggle">
                    <input type="checkbox" name="op_custom_hostname" data-toggle-target="op-customhost-fields"{if $opCustomHostname} checked{/if}>
                    <span class="mt-toggle-track"><span class="mt-toggle-thumb"></span></span>
                </label>
            </div>
            <div class="mt-row-sub" id="op-customhost-fields"{if !$opCustomHostname} hidden{/if}>
                <div class="mt-hostname-grid">
                    <div>
                        <label class="mt-field-label" for="op-host-prefix">Prefix</label>
                        <input class="mt-input" type="text" id="op-host-prefix" name="op_custom_hostname_prefix" value="{$opCustomHostnamePrefix|escape}" placeholder="(none)">
                    </div>
                    <div>
                        <label class="mt-field-label" for="op-host-interfix">Random length</label>
                        <input class="mt-input mt-input--sm" type="number" id="op-host-interfix" name="op_custom_hostname_interfix" min="8" max="50" value="{$opCustomHostnameInterfix}">
                    </div>
                    <div>
                        <label class="mt-field-label" for="op-host-suffix">Suffix</label>
                        <input class="mt-input" type="text" id="op-host-suffix" name="op_custom_hostname_suffix" value="{$opCustomHostnameSuffix|escape}" placeholder=".example.com">
                    </div>
                </div>
                <p class="mt-field-help" style="margin:8px 0 14px;">Random length is the count of random characters at the start (8–50).</p>
                <div class="mt-field" style="margin-bottom:0;">
                    <label class="mt-field-label">Random character set</label>
                    <div class="mt-subnav-checks">
                        <label class="mt-subnav-check"><input type="checkbox" name="op_custom_hostname_chars[]" value="upper"{if in_array('upper', $opCustomHostnameChars)} checked{/if}> Uppercase (A–Z)</label>
                        <label class="mt-subnav-check"><input type="checkbox" name="op_custom_hostname_chars[]" value="lower"{if in_array('lower', $opCustomHostnameChars)} checked{/if}> Lowercase (a–z)</label>
                        <label class="mt-subnav-check"><input type="checkbox" name="op_custom_hostname_chars[]" value="numbers"{if in_array('numbers', $opCustomHostnameChars)} checked{/if}> Numbers (0–9)</label>
                    </div>
                </div>
            </div>

            {* Hide on Checkout — nested toggle, no sub-fields. *}
            <div class="mt-row" style="border-top:1px solid var(--mt-border); padding-top:14px; margin-top:6px;">
                <div>
                    <div class="mt-row-label">Hide on Checkout page</div>
                    <div class="mt-row-help">Also hide the hostname shown under each product in the cart summary on the checkout step.</div>
                </div>
                <label class="mt-toggle">
                    <input type="checkbox" name="op_hide_hostname_checkout"{if $opHideHostnameCheckout} checked{/if}>
                    <span class="mt-toggle-track"><span class="mt-toggle-thumb"></span></span>
                </label>
            </div>
        </div>

        {* ── 3. Enable Password Strength for Root Password Field ──────── *}
        <div class="mt-row{if $tab != 'order'} mt-tab-off{/if}">
            <div>
                <div class="mt-row-label">Enable Password Strength For Root Password Field</div>
                <div class="mt-row-help">Show a password-strength meter on the Root Password field during the product configuration step. Weak passwords are rejected server-side.</div>
            </div>
            <label class="mt-toggle">
                <input type="checkbox" name="op_root_pw_strength"{if $opRootPwStrength} checked{/if}>
                <span class="mt-toggle-track"><span class="mt-toggle-thumb"></span></span>
            </label>
        </div>
    </section>
    </div>

    <div style="margin-top:16px;display:flex;justify-content:flex-end">
        <button type="submit" class="mt-btn mt-btn-primary">Save changes</button>
    </div>
</form>

<script>
(function () {
    // ── Toggle reveal (parent row toggle ↔ sub-section) ──
    // Generalized: any checkbox with [data-toggle-target] shows/hides the
    // element with that id (language picker, dark-mode options, …).
    document.querySelectorAll('[data-toggle-target]').forEach(function (toggle) {
        var section = document.getElementById(toggle.getAttribute('data-toggle-target'));
        if (!section) return;
        toggle.addEventListener('change', function () {
            section.hidden = !toggle.checked;
        });
    });

    // ── Chip multi-select ──
    var inputs      = document.getElementById('mt-lang-inputs');
    var multi       = document.getElementById('mt-lang-multi');
    var chips       = document.getElementById('mt-lang-chips');
    var placeholder = document.getElementById('mt-lang-placeholder');
    var panel       = document.getElementById('mt-lang-panel');
    var options     = document.getElementById('mt-lang-options');
    var search      = document.getElementById('mt-lang-search');
    var empty       = document.getElementById('mt-lang-empty');
    var counter     = document.getElementById('mt-lang-count');
    if (!inputs || !multi) return;

    function capitalize(s) { return s.charAt(0).toUpperCase() + s.slice(1); }

    function checkboxFor(code) {
        // Defensive value selector — language codes are ASCII so CSS.escape
        // isn't strictly needed, but use it when available for safety.
        var esc = (window.CSS && CSS.escape) ? CSS.escape(code) : code.replace(/[^a-zA-Z0-9_-]/g, '\\$&');
        return inputs.querySelector('input[value="' + esc + '"]');
    }

    function selectedCodes() {
        return Array.prototype.map.call(inputs.querySelectorAll('input:checked'), function (cb) { return cb.value; });
    }

    function allInputs() { return inputs.querySelectorAll('input'); }

    function render() {
        var allCbs = allInputs();
        var total = allCbs.length;
        var selected = selectedCodes();
        var n = selected.length;
        // Tri-state: empty | partial | all. "All" means every installed
        // language checkbox is checked — UI collapses to a single "All" chip.
        var state = (n === 0) ? 'empty' : (n === total ? 'all' : 'partial');

        // Chip row
        chips.innerHTML = '';
        if (state === 'all') {
            var allChip = document.createElement('span');
            allChip.className = 'mt-multi-chip is-all';
            allChip.innerHTML =
                '<span class="mt-multi-chip-icon" aria-hidden="true"><svg viewBox="0 0 14 14" fill="none"><circle cx="7" cy="7" r="5.5" stroke="currentColor" stroke-width="1.2"/><path d="M1.5 7h11M7 1.5c2 1.5 2 9.5 0 11M7 1.5c-2 1.5-2 9.5 0 11" stroke="currentColor" stroke-width="1.2"/></svg></span>' +
                '<span>All</span>' +
                '<span class="mt-multi-chip-x" data-remove="__all__" role="button" aria-label="Remove All">&times;</span>';
            chips.appendChild(allChip);
        } else if (state === 'partial') {
            selected.forEach(function (code) {
                var chip = document.createElement('span');
                chip.className = 'mt-multi-chip';
                var label = document.createElement('span');
                label.textContent = capitalize(code);
                var x = document.createElement('span');
                x.className = 'mt-multi-chip-x';
                x.setAttribute('data-remove', code);
                x.setAttribute('role', 'button');
                x.setAttribute('aria-label', 'Remove ' + code);
                x.innerHTML = '&times;';
                chip.appendChild(label);
                chip.appendChild(x);
                chips.appendChild(chip);
            });
        }
        placeholder.hidden = state !== 'empty';

        // Option states
        var selectedSet = {};
        selected.forEach(function (c) { selectedSet[c] = true; });
        Array.prototype.forEach.call(options.querySelectorAll('.mt-multi-option'), function (opt) {
            if (opt.classList.contains('is-all')) {
                opt.classList.toggle('is-checked', state === 'all');
                // "Unavailable" when the user has selected something other
                // than "All" — clear specifics first to re-enable.
                opt.classList.toggle('is-disabled', state === 'partial');
                opt.setAttribute('aria-selected', state === 'all' ? 'true' : 'false');
                opt.setAttribute('aria-disabled', state === 'partial' ? 'true' : 'false');
            } else {
                var on = !!selectedSet[opt.getAttribute('data-code')];
                opt.classList.toggle('is-checked', on);
                opt.setAttribute('aria-selected', on ? 'true' : 'false');
            }
        });

        // Sub-header counter
        if (counter) {
            counter.textContent = state === 'all'
                ? 'All ' + total + ' languages'
                : (n + ' of ' + total + ' selected');
        }
    }

    function setSelection(code, on) {
        var cb = checkboxFor(code);
        if (!cb) return;
        cb.checked = on;
        render();
    }

    function openPanel() {
        panel.hidden = false;
        multi.classList.add('is-focused');
        multi.setAttribute('aria-expanded', 'true');
        if (search) {
            search.value = '';
            filter('');
            setTimeout(function () { search.focus(); }, 0);
        }
    }
    function closePanel() {
        panel.hidden = true;
        multi.classList.remove('is-focused');
        multi.setAttribute('aria-expanded', 'false');
    }

    function filter(q) {
        q = (q || '').toLowerCase().trim();
        var anyVisible = false;
        Array.prototype.forEach.call(options.querySelectorAll('.mt-multi-option'), function (opt) {
            // "All" is a pseudo-option — always visible regardless of query.
            if (opt.classList.contains('is-all')) return;
            var code = (opt.getAttribute('data-code') || '').toLowerCase();
            var match = !q || code.indexOf(q) >= 0;
            opt.style.display = match ? '' : 'none';
            if (match) anyVisible = true;
        });
        if (empty) empty.hidden = anyVisible;
    }

    function setAll(checked) {
        Array.prototype.forEach.call(allInputs(), function (cb) { cb.checked = checked; });
    }

    // Open the panel on field click OR keyboard activation. Chip × is
    // handled here too so a click on × removes the chip but doesn't bubble
    // up to open the panel.
    multi.addEventListener('click', function (e) {
        var rm = e.target.closest('[data-remove]');
        if (rm) {
            e.stopPropagation();
            var code = rm.getAttribute('data-remove');
            if (code === '__all__') {
                // Removing the "All" chip means dropping back to no selection.
                setAll(false);
                render();
            } else {
                setSelection(code, false);
            }
            return;
        }
        if (panel.hidden) openPanel();
    });
    multi.addEventListener('keydown', function (e) {
        if (e.key === 'Enter' || e.key === ' ' || e.key === 'ArrowDown') {
            e.preventDefault();
            if (panel.hidden) openPanel();
        }
        if (e.key === 'Escape') closePanel();
    });

    // Outside click closes
    document.addEventListener('click', function (e) {
        if (multi.contains(e.target) || panel.contains(e.target)) return;
        closePanel();
    });

    // Option pick — toggle selection. The "All" pseudo-option is special:
    // disabled when a specific language is already checked, and clicking
    // it toggles every checkbox at once.
    options.addEventListener('click', function (e) {
        var opt = e.target.closest('.mt-multi-option');
        if (!opt || opt.classList.contains('is-disabled')) return;
        e.preventDefault();
        if (opt.classList.contains('is-all')) {
            // Toggle: if every checkbox is checked, clear; else select all.
            var allOn = !Array.prototype.some.call(allInputs(), function (cb) { return !cb.checked; });
            setAll(!allOn);
            render();
            return;
        }
        var code = opt.getAttribute('data-code');
        var cb = checkboxFor(code);
        if (!cb) return;
        setSelection(code, !cb.checked);
    });

    // Search filter
    if (search) {
        search.addEventListener('input', function () { filter(search.value); });
        search.addEventListener('keydown', function (e) { if (e.key === 'Escape') closePanel(); });
    }

    render();
})();
</script>

<script>
// Generalized chip multi-select for the sub-nav exception pickers. Mirrors the
// language picker above (minus the "All" option). Each [data-chip-picker] wires
// a hidden checkbox group to a visible chip field + searchable dropdown. Scoped
// by [data-chip-picker] so it never touches the language widget.
(function () {
    document.querySelectorAll('[data-chip-picker]').forEach(function (wrap) {
        var inputs      = wrap.querySelector('.mt-multi-inputs');
        var multi       = wrap.querySelector('.mt-multi');
        var chips       = wrap.querySelector('.mt-multi-chips');
        var placeholder = wrap.querySelector('.mt-multi-placeholder');
        var panel       = wrap.querySelector('.mt-multi-panel');
        var options     = wrap.querySelector('.mt-multi-options');
        var search      = wrap.querySelector('.mt-multi-search-wrap input');
        var empty       = wrap.querySelector('.mt-multi-empty');
        if (!inputs || !multi || !panel || !options) { return; }

        function optionFor(val) {
            return Array.prototype.filter.call(options.querySelectorAll('.mt-multi-option'),
                function (o) { return o.getAttribute('data-code') === val; })[0] || null;
        }
        function checkboxFor(val) {
            return Array.prototype.filter.call(inputs.querySelectorAll('input'),
                function (cb) { return cb.value === val; })[0] || null;
        }
        function labelFor(val) {
            var o = optionFor(val);
            return o ? (o.getAttribute('data-label') || o.textContent.trim()) : val;
        }
        function selected() {
            return Array.prototype.map.call(inputs.querySelectorAll('input:checked'),
                function (cb) { return cb.value; });
        }
        function render() {
            var sel = selected();
            chips.innerHTML = '';
            sel.forEach(function (val) {
                var chip = document.createElement('span');
                chip.className = 'mt-multi-chip';
                var lbl = document.createElement('span');
                lbl.textContent = labelFor(val);
                var x = document.createElement('span');
                x.className = 'mt-multi-chip-x';
                x.setAttribute('data-remove', val);
                x.setAttribute('role', 'button');
                x.setAttribute('aria-label', 'Remove');
                x.innerHTML = '&times;';
                chip.appendChild(lbl);
                chip.appendChild(x);
                chips.appendChild(chip);
            });
            placeholder.hidden = sel.length > 0;
            var set = {};
            sel.forEach(function (v) { set[v] = true; });
            Array.prototype.forEach.call(options.querySelectorAll('.mt-multi-option'), function (o) {
                var on = !!set[o.getAttribute('data-code')];
                o.classList.toggle('is-checked', on);
                o.setAttribute('aria-selected', on ? 'true' : 'false');
            });
        }
        function setSelection(val, on) {
            var cb = checkboxFor(val);
            if (cb) { cb.checked = on; render(); }
        }
        function openPanel() {
            panel.hidden = false;
            multi.classList.add('is-focused');
            multi.setAttribute('aria-expanded', 'true');
            // Open upward when there isn't ~room below (e.g. the last picker on
            // the page) so the dropdown isn't clipped by the card edge.
            var rect = multi.getBoundingClientRect();
            panel.classList.toggle('mt-multi-panel--up', (window.innerHeight - rect.bottom) < 300);
            if (search) { search.value = ''; filter(''); setTimeout(function () { search.focus(); }, 0); }
        }
        function closePanel() {
            panel.hidden = true;
            multi.classList.remove('is-focused');
            multi.setAttribute('aria-expanded', 'false');
        }
        function filter(q) {
            q = (q || '').toLowerCase().trim();
            var any = false;
            Array.prototype.forEach.call(options.querySelectorAll('.mt-multi-option'), function (o) {
                var t = (o.getAttribute('data-label') || o.textContent || '').toLowerCase();
                var m = !q || t.indexOf(q) >= 0;
                o.style.display = m ? '' : 'none';
                if (m) { any = true; }
            });
            if (empty) { empty.hidden = any; }
        }
        multi.addEventListener('click', function (e) {
            var rm = e.target.closest('[data-remove]');
            if (rm) { e.stopPropagation(); setSelection(rm.getAttribute('data-remove'), false); return; }
            if (panel.hidden) { openPanel(); }
        });
        multi.addEventListener('keydown', function (e) {
            if (e.key === 'Enter' || e.key === ' ' || e.key === 'ArrowDown') { e.preventDefault(); if (panel.hidden) { openPanel(); } }
            if (e.key === 'Escape') { closePanel(); }
        });
        document.addEventListener('click', function (e) {
            if (multi.contains(e.target) || panel.contains(e.target)) { return; }
            closePanel();
        });
        options.addEventListener('click', function (e) {
            var o = e.target.closest('.mt-multi-option');
            if (!o) { return; }
            e.preventDefault();
            var val = o.getAttribute('data-code');
            var cb = checkboxFor(val);
            if (cb) { setSelection(val, !cb.checked); }
        });
        if (search) {
            search.addEventListener('input', function () { filter(search.value); });
            search.addEventListener('keydown', function (e) { if (e.key === 'Escape') { closePanel(); } });
        }
        render();
    });
})();
</script>

{literal}
<script>
// Order Process: a [data-reveal-when] <select> shows its target element only
// when its value matches (e.g. the product-group picker appears only when the
// "Apply to" select is "Selected Product Groups"). Complements the checkbox
// [data-toggle-target] reveal handler above.
(function () {
    document.querySelectorAll('[data-reveal-when]').forEach(function (sel) {
        var target = document.getElementById(sel.getAttribute('data-reveal-when-target'));
        if (!target) return;
        var match = sel.getAttribute('data-reveal-when');
        function sync() { target.hidden = (sel.value !== match); }
        sel.addEventListener('change', sync);
        sync();
    });
})();
</script>
{/literal}

{literal}
<script>
// Cookie Box message: per-language ("translate") switcher. The <select> picks
// which language's textarea is visible; all textareas stay in the DOM so every
// language submits together. Hidden panes still post, so a cleared box deletes
// that translation server-side.
(function () {
    var wraps = document.querySelectorAll('[data-cookie-msg-i18n]');
    Array.prototype.forEach.call(wraps, function (wrap) {
        var select = wrap.querySelector('[data-cookie-msg-switch]');
        var panes  = wrap.querySelectorAll('[data-cookie-msg-pane]');
        if (!select) { return; }
        function show(code) {
            Array.prototype.forEach.call(panes, function (pane) {
                pane.hidden = (pane.getAttribute('data-cookie-msg-pane') !== code);
            });
        }
        select.addEventListener('change', function () { show(select.value); });
        show(select.value);
    });
})();
</script>
{/literal}

{include file="includes/footer.tpl"}
