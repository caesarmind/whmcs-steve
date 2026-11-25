{*
    Media: the library behind every image field, with room to manage it.

    This template is the frame only. assets/js/media.js fills and drives it
    through the same JSON endpoints the picker uses (MediaController), so
    there is one implementation of list, upload and delete.

    No opening form tag anywhere on this page, the script included: the WHMCS
    admin output filter injects a hidden token field after every one it finds,
    content-blind (see includes/media-picker.tpl). The token comes in the
    boot JSON instead.
*}
{include file="includes/header.tpl"}

<header class="mt-page-header">
    <div class="mt-page-eyebrow">Theme</div>
    <h1 class="mt-page-title">Media {include file="includes/doclink.tpl" article="media"}</h1>
    <p class="mt-page-subtitle">Every image uploaded for your pages, emails and menus. See where each one is used, and clear out what is left over.</p>
</header>

<div class="mt-ml" id="mt-ml">
    <div class="mt-panel pad mt-ml-panel" id="mt-ml-panel">

        <div class="mt-ml-bar">
            <div class="mt-search mt-ml-search">
                <span class="mt-search-icon" aria-hidden="true">
                    <svg viewBox="0 0 16 16" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round"><circle cx="7" cy="7" r="4.5"/><path d="M10.5 10.5L14 14"/></svg>
                </span>
                <input type="text" class="mt-input mt-input-compact" id="mt-ml-q" placeholder="Search images" autocomplete="off" aria-label="Search images">
            </div>
            <div class="mt-ml-seg" id="mt-ml-show" role="group" aria-label="Show">
                <button type="button" class="is-active" data-show="all" aria-pressed="true">All</button>
                <button type="button" data-show="used" aria-pressed="false">In use</button>
                <button type="button" data-show="unused" aria-pressed="false">Unused</button>
            </div>
            <select class="mt-select mt-input-compact mt-ml-sort" id="mt-ml-sort" aria-label="Sort by">
                <option value="new">Newest first</option>
                <option value="old">Oldest first</option>
                <option value="name">Name</option>
                <option value="big">Largest first</option>
            </select>
            <span class="mt-ml-gap"></span>
            {* admin.css hides input[type=file], so the label is the button. *}
            <label class="mt-btn mt-btn-primary mt-btn-sm" for="mt-ml-file" id="mt-ml-upload">Upload images</label>
            <input type="file" id="mt-ml-file" multiple hidden>
        </div>

        <div class="mt-ml-stats" id="mt-ml-stats" role="status" aria-live="polite"></div>

        <div class="mt-ml-bulk" id="mt-ml-bulk" hidden>
            <span class="mt-ml-bulk-count" id="mt-ml-bulk-count"></span>
            <button type="button" class="mt-btn mt-btn-ghost mt-btn-sm" id="mt-ml-bulk-all">Select all shown</button>
            <button type="button" class="mt-btn mt-btn-ghost mt-btn-sm" id="mt-ml-bulk-none">Clear</button>
            <span class="mt-ml-gap"></span>
            {if $mediaOptimizer}<button type="button" class="mt-btn mt-btn-secondary mt-btn-sm" id="mt-ml-bulk-opt">Optimise</button>{/if}
            <button type="button" class="mt-btn mt-btn-danger mt-btn-sm" id="mt-ml-bulk-del">Delete</button>
        </div>

        <div class="mt-media-status" id="mt-ml-status" role="status" aria-live="polite"></div>
        <div class="mt-media-queue mt-ml-queue" id="mt-ml-queue"></div>

        <div class="mt-ml-layout">
            <div class="mt-ml-main">
                <div class="mt-media-grid mt-ml-grid" id="mt-ml-grid" aria-label="Media library"></div>
                <div class="mt-empty" id="mt-ml-empty" hidden>
                    <div class="mt-empty-icon mt-empty-icon-circle" aria-hidden="true">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="3" width="18" height="18" rx="2"/><circle cx="8.5" cy="8.5" r="1.5"/><path d="M21 15l-5-5L5 21"/></svg>
                    </div>
                    <h3 class="mt-empty-title" id="mt-ml-empty-title">No images yet</h3>
                    <p id="mt-ml-empty-sub">Upload one here, or from any image field in Pages, Email or the Page Builder.</p>
                </div>
            </div>

            <aside class="mt-ml-side" id="mt-ml-side" aria-label="Image details">
                <div class="mt-ml-side-empty" id="mt-ml-side-empty">Select an image to see its details and where it is used.</div>
                <div class="mt-ml-detail" id="mt-ml-detail" hidden></div>
            </aside>
        </div>

        <div class="mt-ml-dropnote" aria-hidden="true">Drop images to upload</div>
    </div>

    <div class="mt-panel">
        <section class="mt-section">
            <div class="mt-row">
                <div>
                    <div class="mt-row-label mt-tip-line">Optimise new uploads
                        {include file="includes/tip.tpl" text="Makes each upload smaller as it arrives: an image larger than `$mediaMaxEdge` pixels is scaled down, and JPEG, PNG and WebP files are compressed. The original is kept, so you can put it back from the image's details." article="media" anchor="optimising-images"}
                    </div>
                    <div class="mt-row-help">
                        {if $mediaOptimizer}
                            Smaller images load faster for your visitors. The file keeps its address, so nothing that uses it has to change.
                        {else}
                            Not available: this server's PHP has no GD image library.
                        {/if}
                    </div>
                </div>
                <label class="mt-toggle">
                    <input type="checkbox" id="mt-ml-opt-toggle" aria-label="Optimise new uploads" {if $mediaOptimize && $mediaOptimizer}checked{/if} {if !$mediaOptimizer}disabled{/if}>
                    <span class="mt-toggle-track"><span class="mt-toggle-thumb"></span></span>
                </label>
            </div>
            {if $mediaOptimizer}
            <div class="mt-row">
                <div>
                    <div class="mt-row-label">Optimise the library</div>
                    <div class="mt-row-help" id="mt-ml-optall-help">Run the same pass over every image that has not had it yet.</div>
                </div>
                <button type="button" class="mt-btn mt-btn-secondary" id="mt-ml-optall">Optimise all</button>
            </div>
            {/if}
        </section>
    </div>
</div>

{* The confirm dialog. Moved to document.body by the script, like the picker. *}
<div class="mt-modal mt-ml-dialog" id="mt-ml-dialog" hidden>
    <div class="mt-modal-card" role="alertdialog" aria-modal="true" aria-labelledby="mt-ml-dialog-title">
        <div class="mt-modal-head">
            <div class="mt-modal-title" id="mt-ml-dialog-title"></div>
        </div>
        <div class="mt-modal-body mt-ml-dialog-body" id="mt-ml-dialog-body"></div>
        <div class="mt-modal-foot">
            <button type="button" class="mt-btn mt-btn-secondary mt-btn-sm" id="mt-ml-dialog-no">Cancel</button>
            <button type="button" class="mt-btn mt-btn-danger mt-btn-sm" id="mt-ml-dialog-yes">Delete</button>
        </div>
    </div>
</div>

<script type="application/json" id="mt-ml-data">{$mediaJson nofilter}</script>
<script>{$mediaJs nofilter}</script>

{include file="includes/footer.tpl"}
