{include file="includes/header.tpl"}

{* Page-local styles. Prefixed mt-em- so nothing here can collide with a shared
   name in Hadrian's admin stylesheet; its shell classes (mt-panel, mt-row,
   mt-table...) are used as they are. *}
<style>{literal}
.mt-em-designs { display: grid; grid-template-columns: repeat(3, minmax(0, 1fr)); gap: 16px; }
@media (max-width: 980px) { .mt-em-designs { grid-template-columns: 1fr; } }
.mt-em-design { display: flex; flex-direction: column; border: 1px solid var(--mt-border); border-radius: var(--mt-radius-card); overflow: hidden; background: var(--mt-surface); transition: border-color 0.15s ease, box-shadow 0.15s ease; }
.mt-em-design.is-active { border-color: var(--mt-primary); box-shadow: 0 0 0 3px var(--mt-primary-ring); }
.mt-em-design-body { padding: 14px 16px 16px; display: flex; flex-direction: column; gap: 6px; flex: 1; }
.mt-em-design-head { display: flex; align-items: center; justify-content: space-between; gap: 8px; }
.mt-em-design-head h3 { margin: 0; font-size: 15px; font-weight: 600; letter-spacing: -0.01em; }
.mt-em-design p { margin: 0; font-size: 12.5px; line-height: 1.5; color: var(--mt-text-3); flex: 1; }
.mt-em-design form { margin: 6px 0 0; }
.mt-em-dgroup { margin: 4px 0 10px; font-size: 12px; font-weight: 600; letter-spacing: 0.04em; text-transform: uppercase; color: var(--mt-text-3); }
.mt-em-designs + .mt-em-dgroup { margin-top: 24px; }
/* A scaled-down live render. 0.5 of a 680px-wide frame fills the card. */
.mt-em-thumb { position: relative; height: 300px; overflow: hidden; border-bottom: 1px solid var(--mt-border); background: var(--mt-surface-2); }
.mt-em-thumb iframe { position: absolute; top: 0; left: 50%; width: 680px; height: 640px; margin-left: -340px; border: 0; transform: scale(0.5); transform-origin: 50% 0; pointer-events: none; }
.mt-em-thumb::after { content: ""; position: absolute; inset: auto 0 0 0; height: 48px; background: linear-gradient(to bottom, transparent, var(--mt-surface-2)); }
.mt-em-state { display: flex; align-items: center; gap: 12px; }
.mt-em-dot { width: 10px; height: 10px; border-radius: 50%; background: var(--mt-text-4); flex-shrink: 0; }
.mt-em-dot.is-on { background: var(--mt-success); box-shadow: 0 0 0 4px rgba(48,209,88,0.16); }
.mt-em-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 0 20px; }
@media (max-width: 720px) { .mt-em-grid { grid-template-columns: 1fr; } }
.mt-em-actions { display: flex; gap: 8px; flex-wrap: wrap; align-items: center; }
.mt-em-actions form { margin: 0; }
.mt-em-group { margin-top: 26px; }
.mt-em-group:first-of-type { margin-top: 6px; }
.mt-em-group-head { display: flex; align-items: baseline; gap: 10px; margin: 0 0 10px; }
.mt-em-group-head h3 { margin: 0; font-size: 15px; font-weight: 600; letter-spacing: -0.01em; }
.mt-em-group-head span { font-size: 12px; color: var(--mt-text-3); }
.mt-em-table-wrap { border: 1px solid var(--mt-border); border-radius: var(--mt-radius); overflow: hidden; }
/* Each group is its own table; fixed columns keep them aligned with each other. */
.mt-em-table-wrap .mt-table { table-layout: fixed; }
.mt-em-table-wrap .mt-table td:nth-child(1) { width: 36%; }
.mt-em-table-wrap .mt-table td:nth-child(3) { width: 170px; }
.mt-em-table-wrap .mt-table td:nth-child(4) { width: 230px; }
.mt-em-subject { color: var(--mt-text-2); max-width: 360px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
.mt-em-name { font-weight: 500; }
.mt-em-starter { display: inline-block; margin-left: 8px; font-size: 11px; color: var(--mt-text-3); font-weight: 400; }
.mt-em-off { color: var(--mt-text-3); font-weight: 400; font-size: 12px; margin-left: 8px; }
.mt-em-tools { display: flex; align-items: center; justify-content: space-between; gap: 16px; flex-wrap: wrap; margin-bottom: 4px; }
.mt-em-code { font-family: ui-monospace, Menlo, Consolas, monospace; font-size: 13px; min-height: 96px; }
.mt-em-linkbtn { background: none; border: 0; padding: 0; font: inherit; font-size: 13px; color: var(--mt-text-3); cursor: pointer; }
.mt-em-linkbtn:hover { color: var(--mt-danger); }
{/literal}</style>

<header class="mt-page-header">
    <div class="mt-page-eyebrow">Communication</div>
    <h1 class="mt-page-title">Email templates</h1>
    <p class="mt-page-subtitle">Give every email WHMCS sends your logo, colours and footer, then redesign the ones your clients see most with blocks.</p>
</header>

{if $flashMsg}<div class="mt-alert mt-alert-success">{$flashMsg|escape}</div>{/if}
{if $flashErr}<div class="mt-alert mt-alert-danger">{$flashErr|escape}</div>{/if}
{foreach $notes as $note}<div class="mt-alert mt-alert-info">{$note|escape}</div>{/foreach}

{if $status.drift}
    <div class="mt-alert mt-alert-warning">
        <strong>WHMCS's mail settings were changed outside Hadrian.</strong>
        Someone edited the global email {foreach $status.drift as $k}{if $k == 'EmailGlobalHeader'}header{elseif $k == 'EmailGlobalFooter'}footer{else}CSS{/if}{if !$k@last}, {/if}{/foreach}
        under General Settings &gt; Mail. Emails are using that edit, not your Hadrian layout.
        <div class="mt-em-actions" style="margin-top:12px;">
            <form method="post" action="{$base}&action=reapply">
                <input type="hidden" name="token" value="{$token|escape}">
                <button type="submit" class="mt-btn mt-btn-primary mt-btn-sm">Use the Hadrian layout again</button>
            </form>
            <form method="post" action="{$base}&action=disable">
                <input type="hidden" name="token" value="{$token|escape}">
                <input type="hidden" name="keep" value="1">
                <button type="submit" class="mt-btn mt-btn-secondary mt-btn-sm">Keep that edit and turn Hadrian email off</button>
            </form>
        </div>
    </div>
{/if}

{if $logoIssue}
    <div class="mt-alert mt-alert-warning">{$logoIssue|escape}</div>
{/if}

<div class="mt-panel">
    <section class="mt-section">
        <div class="mt-row" style="padding:0;border:0;">
            <div class="mt-em-state">
                <span class="mt-em-dot {if $status.enabled}is-on{/if}"></span>
                <div>
                    <div class="mt-row-label">Hadrian email is {if $status.enabled}on{else}off{/if}</div>
                    <div class="mt-row-help">
                        {if $status.enabled}
                            Client emails are wrapped in your layout. Your previous WHMCS header, footer and CSS{if $status.backupAt} (saved {$status.backupAt|escape}){/if} come back when you turn this off.
                        {else}
                            Turning this on replaces WHMCS's global email header, footer and CSS with your layout. The current ones are kept and restored when you turn it off. Admin notifications are not affected.
                        {/if}
                    </div>
                </div>
            </div>
            {if $status.enabled}
                <form method="post" action="{$base}&action=disable" data-mt-em-confirm="Turn Hadrian email off? WHMCS goes back to its own global header, footer and CSS. Published designs stay in their templates.">
                    <input type="hidden" name="token" value="{$token|escape}">
                    <button type="submit" class="mt-btn mt-btn-secondary">Turn off</button>
                </form>
            {else}
                <form method="post" action="{$base}&action=enable">
                    <input type="hidden" name="token" value="{$token|escape}">
                    <button type="submit" class="mt-btn mt-btn-primary">Turn on</button>
                </form>
            {/if}
        </div>
    </section>
</div>

<div class="mt-panel pad">
    <section class="mt-section">
        <header class="mt-section-header">
            <h2 class="mt-section-title">Layout</h2>
            <a class="mt-btn mt-btn-primary mt-btn-sm" href="{$base}&action=builder&layout=1">Edit layout</a>
        </header>
        <p class="mt-row-help" style="margin:0 0 16px;">The header and footer around every email. Pick a design; your logo, links and footer text carry over. An email with no design of its own keeps its WHMCS text and sits inside this.</p>
        {foreach $designGroups as $gid => $glabel}
        <h3 class="mt-em-dgroup">{$glabel|escape}</h3>
        <div class="mt-em-designs" data-mt-em-design-group="{$gid|escape}">
            {foreach $designs as $d}
                {if $d.group != $gid}{continue}{/if}
                <div class="mt-em-design{if $d.active} is-active{/if}" data-mt-em-design="{$d.id|escape}">
                    <div class="mt-em-thumb">
                        {if $d.html}<iframe title="{$d.label|escape} design" sandbox="" loading="lazy" srcdoc="{$d.html|escape}"></iframe>{/if}
                    </div>
                    <div class="mt-em-design-body">
                        <div class="mt-em-design-head">
                            <h3>{$d.label|escape}</h3>
                            {if $d.active}<span class="mt-badge mt-badge-primary">In use</span>{/if}
                        </div>
                        <p>{$d.description|escape}</p>
                        {if !$d.active}
                            <form method="post" action="{$base}&action=design">
                                <input type="hidden" name="token" value="{$token|escape}">
                                <input type="hidden" name="design" value="{$d.id|escape}">
                                <button type="submit" class="mt-btn mt-btn-secondary mt-btn-sm">Use {$d.label|escape}</button>
                            </form>
                        {/if}
                    </div>
                </div>
            {/foreach}
        </div>
        {/foreach}
    </section>
</div>

<div>

    <form method="post" action="{$base}&action=settings" class="mt-panel pad">
        <input type="hidden" name="token" value="{$token|escape}">
        <section class="mt-section">
            <header class="mt-section-header"><h2 class="mt-section-title">Appearance</h2></header>
            <p class="mt-row-help" style="margin:0 0 16px;">Colours and the font come from your active style on the Styles page. These settings are the ones only email needs.</p>

            <div class="mt-field">
                <label class="mt-field-label mt-tip-line" for="em-mode">Light and dark {include file="includes/tip.tpl" text="Match the recipient's device sends one email that is light by default and switches to your dark colours where the mail app is in dark mode. Not every app supports that; those show the light version."}</label>
                <select class="mt-select" id="em-mode" name="mode">
                    {foreach $modes as $value => $label}
                        <option value="{$value|escape}" {if $settings.mode == $value}selected{/if}>{$label|escape}</option>
                    {/foreach}
                </select>
            </div>

            <div class="mt-em-grid">
                <div class="mt-field">
                    <label class="mt-field-label mt-tip-line" for="em-logo">Email logo {include file="includes/tip.tpl" text="PNG, JPG or GIF. Gmail and Outlook do not show SVG or WebP. Leave empty to use your site logo when it is one of those types."}</label>
                    <input type="text" class="mt-input" id="em-logo" name="logo" value="{$settings.logo|escape}"
                           placeholder="{if $hasLogo}Using your site logo{else}Choose an image{/if}"
                           data-mt-media data-mt-media-value="url" data-mt-media-collection="library"
                           data-mt-media-title="Email logo" data-mt-media-hint="PNG at twice its display width looks sharp on phones">
                </div>
                <div class="mt-field">
                    <label class="mt-field-label mt-tip-line" for="em-logo-dark">Logo for dark mode {include file="includes/tip.tpl" text="Shown instead of the email logo where the email is dark. Use a light-coloured version."}</label>
                    <input type="text" class="mt-input" id="em-logo-dark" name="logoDark" value="{$settings.logoDark|escape}"
                           placeholder="Optional"
                           data-mt-media data-mt-media-value="url" data-mt-media-collection="library"
                           data-mt-media-title="Logo for dark mode" data-mt-media-hint="A light-coloured PNG">
                </div>
                <div class="mt-field">
                    <label class="mt-field-label" for="em-width">Width (px)</label>
                    <input type="number" class="mt-input" id="em-width" name="width" min="480" max="720" step="10" value="{$settings.width|escape}">
                </div>
                <div class="mt-field">
                    <label class="mt-field-label" for="em-radius">Corner radius (px)</label>
                    <input type="number" class="mt-input" id="em-radius" name="radius" min="0" max="28" value="{$settings.radius|escape}">
                </div>
            </div>

            <div class="mt-field" style="margin-bottom:0;">
                <label class="mt-field-label mt-tip-line" for="em-css">Custom CSS {include file="includes/tip.tpl" text="Added to the style block in every email. Many mail apps ignore style blocks, so use it for refinements, not for anything the email depends on."}</label>
                <textarea class="mt-textarea mt-em-code" id="em-css" name="customCss" spellcheck="false">{$settings.customCss|escape}</textarea>
            </div>
        </section>
        {include file="includes/savebar.tpl" label="Save appearance"}
    </form>

</div>

<div class="mt-panel pad">
    <section class="mt-section">
        <div class="mt-em-tools">
            <header class="mt-section-header" style="margin:0;">
                <h2 class="mt-section-title">Emails <span class="mt-page-meta" style="font-size:14px;">{$counts.published} published{if $counts.draft}, {$counts.draft} draft{/if}</span></h2>
            </header>
            <div class="mt-search">
                <input type="text" class="mt-input" id="mt-em-filter" placeholder="Filter emails&hellip;" autocomplete="off">
            </div>
        </div>
        <p class="mt-row-help" style="margin:6px 0 0;">Design an email to replace its WHMCS text with blocks. Publishing writes the design into the WHMCS email template; removing the design puts the original back.</p>

        {foreach $groups as $type => $group}
            <div class="mt-em-group" data-mt-em-group>
                <div class="mt-em-group-head"><h3>{$group.label|escape}</h3><span>{$group.items|@count}</span></div>
                <div class="mt-em-table-wrap">
                    <table class="mt-table">
                        <tbody>
                        {foreach $group.items as $item}
                            <tr data-mt-em-row="{$item.name|lower|escape} {$item.subject|lower|escape}">
                                <td class="mt-em-name">
                                    {$item.name|escape}
                                    {if $item.disabled}<span class="mt-em-off">disabled in WHMCS</span>{/if}
                                    {if $item.status == 'stock' && $item.starter}<span class="mt-em-starter">starter design</span>{/if}
                                </td>
                                <td><div class="mt-em-subject">{$item.subject|escape}</div></td>
                                <td style="white-space:nowrap;">
                                    {if $item.status == 'published'}<span class="mt-badge mt-badge-success">Published</span>
                                    {elseif $item.status == 'draft'}<span class="mt-badge mt-badge-warning">Draft</span>
                                    {elseif $item.status == 'edited'}<span class="mt-badge mt-badge-danger">Edited in WHMCS</span>
                                    {else}<span class="mt-badge mt-badge-neutral">WHMCS text</span>{/if}
                                </td>
                                <td class="mt-table-actions">
                                    <div class="mt-em-actions" style="justify-content:flex-end;">
                                        {if $item.designId}
                                            <form method="post" action="{$base}&action=delete" data-mt-em-confirm="Remove the design for &quot;{$item.name|escape}&quot;? Its WHMCS template goes back to how it was before the design was published.">
                                                <input type="hidden" name="token" value="{$token|escape}">
                                                <input type="hidden" name="id" value="{$item.designId}">
                                                <button type="submit" class="mt-em-linkbtn">Remove design</button>
                                            </form>
                                            <a class="mt-btn mt-btn-secondary mt-btn-sm" href="{$base}&action=builder&target={$item.name|escape:'url'}">Edit</a>
                                        {else}
                                            <a class="mt-btn mt-btn-secondary mt-btn-sm" href="{$base}&action=builder&target={$item.name|escape:'url'}">Design</a>
                                        {/if}
                                    </div>
                                </td>
                            </tr>
                        {/foreach}
                        </tbody>
                    </table>
                </div>
            </div>
        {foreachelse}
            <div class="mt-empty"><div class="mt-empty-title">No client email templates found</div></div>
        {/foreach}
    </section>
</div>

<script>{literal}
(function () {
    // Confirm before the actions that change what clients receive.
    document.querySelectorAll('form[data-mt-em-confirm]').forEach(function (form) {
        form.addEventListener('submit', function (e) {
            if (!window.confirm(form.getAttribute('data-mt-em-confirm'))) { e.preventDefault(); }
        });
    });

    var filter = document.getElementById('mt-em-filter');
    if (!filter) { return; }
    filter.addEventListener('input', function () {
        var q = filter.value.trim().toLowerCase();
        document.querySelectorAll('[data-mt-em-group]').forEach(function (group) {
            var shown = 0;
            group.querySelectorAll('[data-mt-em-row]').forEach(function (row) {
                var hit = q === '' || row.getAttribute('data-mt-em-row').indexOf(q) !== -1;
                row.hidden = !hit;
                if (hit) { shown++; }
            });
            group.hidden = shown === 0;
        });
    });
    filter.addEventListener('keydown', function (e) { if (e.key === 'Enter') { e.preventDefault(); } });
})();
{/literal}</script>

{include file="includes/footer.tpl"}
