{include file="includes/header.tpl"}

{* Setup: what is left before Hadrian can go live, with each remaining step
   done from the row that lists it. The rows come from Helpers\SetupChecks and
   are read from the real state on every view; nothing here is a stored flag.

   The styles are page-local on purpose. admin.css is inlined into the <head> of
   every Hadrian admin page, and nothing outside this page draws a checklist. *}
{literal}
<style>
.mt-setup-list { list-style: none; margin: 0; padding: 0; }
.mt-setup-row { display: grid; grid-template-columns: 10px minmax(0, 1fr) auto; column-gap: 14px; align-items: start; padding: 13px 0; border-bottom: 1px solid var(--mt-border); }
.mt-setup-row:last-child { border-bottom: 0; }
.mt-setup-mark { width: 10px; height: 10px; border-radius: 50%; margin-top: 5px; background: var(--mt-text-4); }
.mt-setup-mark.is-ok { background: var(--mt-success); }
.mt-setup-mark.is-warn { background: var(--mt-warning); }
.mt-setup-mark.is-fail { background: var(--mt-danger); }
.mt-setup-label { font-size: 14px; font-weight: 600; color: var(--mt-text); display: flex; align-items: center; gap: 10px; flex-wrap: wrap; }
.mt-setup-label code { font-weight: 400; overflow-wrap: anywhere; }
.mt-setup-detail { font-size: 13px; color: var(--mt-text-2); margin-top: 3px; line-height: 1.5; max-width: 720px; }
.mt-setup-act { display: flex; align-items: center; gap: 10px; flex-wrap: wrap; margin-top: 16px; }
.mt-setup-act form { display: flex; align-items: center; gap: 10px; flex-wrap: wrap; margin: 0; }
.mt-setup-act .mt-input { width: 320px; max-width: 100%; }
.mt-setup-act .mt-btn[disabled] { opacity: 0.45; cursor: not-allowed; }
.mt-setup-help { font-size: 12px; color: var(--mt-text-3); margin: 10px 0 0; line-height: 1.5; max-width: 720px; }
@media (max-width: 640px) {
    .mt-setup-row { grid-template-columns: 10px minmax(0, 1fr); row-gap: 8px; }
    .mt-setup-row .mt-badge { grid-column: 2; justify-self: start; }
    .mt-setup-act .mt-input { width: 100%; }
}
</style>
{/literal}

<header class="mt-page-header">
    <div class="mt-page-eyebrow">Theme</div>
    <h1 class="mt-page-title">Setup {include file="includes/doclink.tpl" article="installation" anchor="finish-on-the-setup-page"}</h1>
    <p class="mt-page-subtitle">
        {if $summary.finished}
            Everything is in place and Hadrian is live.
        {else}
            {$summary.done} of {$summary.total} steps are done. Each open step can be finished from this page.
        {/if}
    </p>
</header>

{if $flash}
    <div class="mt-alert mt-alert-{$flash.type|escape}" role="status">{$flash.text|escape}</div>
{/if}

<div class="mt-panel">
{foreach $groups as $group}
<section class="mt-section" id="mt-setup-{$group.key|escape}">
    <header class="mt-section-header">
        <h2 class="mt-section-title">{$group.title|escape}</h2>
        {if $group.state == 'ok'}<span class="mt-badge mt-badge-success">Ready</span>
        {elseif $group.state == 'warn'}<span class="mt-badge mt-badge-warning">Check</span>
        {elseif $group.state == 'todo'}<span class="mt-badge mt-badge-neutral">To do</span>
        {else}<span class="mt-badge mt-badge-danger">Problem</span>{/if}
    </header>

    <ul class="mt-setup-list">
        {foreach $group.rows as $row}
        <li class="mt-setup-row" data-setup-row="{$row.key|escape}" data-setup-state="{$row.state|escape}">
            <span class="mt-setup-mark is-{$row.state|escape}" aria-hidden="true"></span>
            <div>
                <div class="mt-setup-label">{$row.label|escape}{if $row.path} <code>{$row.path|escape}</code>{/if}</div>
                <div class="mt-setup-detail">{$row.detail|escape}</div>
            </div>
            {if $row.state == 'ok'}<span class="mt-badge mt-badge-success">Ready</span>
            {elseif $row.state == 'warn'}<span class="mt-badge mt-badge-warning">Check</span>
            {elseif $row.state == 'todo'}<span class="mt-badge mt-badge-neutral">To do</span>
            {else}<span class="mt-badge mt-badge-danger">Problem</span>{/if}
        </li>
        {/foreach}
    </ul>

    {if $group.key == 'database' && $group.state != 'ok'}
        <div class="mt-setup-act">
            <form method="post" action="{$viewHelper->url('setup')}">
                <input type="hidden" name="setup_do" value="install">
                <button type="submit" class="mt-btn mt-btn-primary mt-btn-sm">Run now</button>
            </form>
        </div>
        <p class="mt-setup-help">Creates what is missing and leaves everything else as it is. Safe to run more than once.</p>
    {/if}

    {if $group.key == 'license'}
        <div class="mt-setup-act">
            <form method="post" action="{$viewHelper->url('setup')}">
                <input type="hidden" name="setup_do" value="license">
                <label class="mt-field-label" for="mt-setup-license-key">Key</label>
                <input id="mt-setup-license-key" class="mt-input" type="text" name="license_key"
                       value="{$licenseKey|escape}" placeholder="hadrian-XXXXX-XXXXX-XXXXX" autocomplete="off" spellcheck="false">
                <button type="submit" class="mt-btn {if $group.state == 'ok'}mt-btn-secondary{else}mt-btn-primary{/if} mt-btn-sm">Save &amp; check</button>
            </form>
        </div>
    {/if}

    {if $group.key == 'golive'}
        <div class="mt-setup-act">
            {if !$summary.live}
                <form method="post" action="{$viewHelper->url('setup')}">
                    <input type="hidden" name="setup_do" value="golive">
                    <button type="submit" class="mt-btn mt-btn-primary mt-btn-sm"{if $summary.blocked} disabled{/if}>Make Hadrian live</button>
                </form>
                <a class="mt-btn mt-btn-secondary mt-btn-sm" href="{$previewUrl|escape}" target="_blank" rel="noopener">Preview first</a>
            {elseif $summary.cartReady && !$summary.cartLive}
                <form method="post" action="{$viewHelper->url('setup')}">
                    <input type="hidden" name="setup_do" value="golive">
                    <button type="submit" class="mt-btn mt-btn-primary mt-btn-sm"{if $summary.blocked} disabled{/if}>Use Hadrian Cart for orders</button>
                </form>
            {/if}
            {if $summary.canSwitchBack}
                <form method="post" action="{$viewHelper->url('setup')}">
                    <input type="hidden" name="setup_do" value="switchback">
                    <button type="submit" class="mt-btn mt-btn-secondary mt-btn-sm">Switch back to {$live.prev_template|escape}</button>
                </form>
            {/if}
        </div>
        {if !$summary.live}
            <p class="mt-setup-help">
                {if $summary.blocked}
                    Finish the steps marked &ldquo;To do&rdquo; or &ldquo;Problem&rdquo; above, then come back here.
                {else}
                    Sets the client area theme{if $summary.cartReady} and the order form{/if} for the whole site, the same setting General Settings holds. Clients see it on their next page load, and you can switch back from here.
                {/if}
                The preview opens the site in Hadrian for your browser only.
            </p>
        {/if}
    {/if}
</section>
{/foreach}
</div>

{include file="includes/footer.tpl"}
