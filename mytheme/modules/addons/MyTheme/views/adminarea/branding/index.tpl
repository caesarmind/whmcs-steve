{include file="includes/header.tpl"}

<header class="mt-page-header">
    <div class="mt-page-eyebrow">Theme</div>
    <h1 class="mt-page-title">Branding</h1>
    <p class="mt-page-subtitle">Upload your logo and favicon. Two variants are supported per logo (light + dark surfaces).</p>
</header>

<form method="post" action="" enctype="multipart/form-data">

    <section class="mt-section">
        <header class="mt-section-header"><h2 class="mt-section-title">Full Logo</h2></header>
        <div class="mt-upload-pair">
            <div>
                <label class="mt-upload" for="upload-logo-light">
                    <svg class="mt-upload-icon" width="32" height="32" viewBox="0 0 40 40" fill="none"><path d="M20 6v22M11 15l9-9 9 9M6 28v3a3 3 0 003 3h22a3 3 0 003-3v-3" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/></svg>
                    <div class="mt-upload-text">{if $logoLight}Replace file{else}Click to upload{/if}</div>
                    <div class="mt-upload-hint">Suggested: at least 40px height</div>
                    <input id="upload-logo-light" type="file" name="logo_light" accept="image/*" hidden>
                </label>
                <div class="mt-upload-caption">Light backgrounds</div>
            </div>
            <div>
                <label class="mt-upload" for="upload-logo-dark" style="background:#1D1D1F;border-color:#3A3A3C">
                    <svg class="mt-upload-icon" width="32" height="32" viewBox="0 0 40 40" fill="none" style="color:#86868B"><path d="M20 6v22M11 15l9-9 9 9M6 28v3a3 3 0 003 3h22a3 3 0 003-3v-3" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/></svg>
                    <div class="mt-upload-text" style="color:#F5F5F7">{if $logoDark}Replace file{else}Click to upload{/if}</div>
                    <div class="mt-upload-hint" style="color:#86868B">Suggested: at least 40px height</div>
                    <input id="upload-logo-dark" type="file" name="logo_dark" accept="image/*" hidden>
                </label>
                <div class="mt-upload-caption">Dark backgrounds</div>
            </div>
        </div>
    </section>

    <section class="mt-section">
        <header class="mt-section-header"><h2 class="mt-section-title">Square Logo</h2></header>
        <div class="mt-upload-pair">
            <div>
                <label class="mt-upload" for="upload-logo-square-light">
                    <svg class="mt-upload-icon" width="32" height="32" viewBox="0 0 40 40" fill="none"><path d="M20 6v22M11 15l9-9 9 9M6 28v3a3 3 0 003 3h22a3 3 0 003-3v-3" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/></svg>
                    <div class="mt-upload-text">{if $logoSquareLight}Replace file{else}Click to upload{/if}</div>
                    <input id="upload-logo-square-light" type="file" name="logo_square_light" accept="image/*" hidden>
                </label>
                <div class="mt-upload-caption">Light backgrounds</div>
            </div>
            <div>
                <label class="mt-upload" for="upload-logo-square-dark" style="background:#1D1D1F;border-color:#3A3A3C">
                    <svg class="mt-upload-icon" width="32" height="32" viewBox="0 0 40 40" fill="none" style="color:#86868B"><path d="M20 6v22M11 15l9-9 9 9M6 28v3a3 3 0 003 3h22a3 3 0 003-3v-3" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/></svg>
                    <div class="mt-upload-text" style="color:#F5F5F7">{if $logoSquareDark}Replace file{else}Click to upload{/if}</div>
                    <input id="upload-logo-square-dark" type="file" name="logo_square_dark" accept="image/*" hidden>
                </label>
                <div class="mt-upload-caption">Dark backgrounds</div>
            </div>
        </div>
    </section>

    <section class="mt-section">
        <header class="mt-section-header"><h2 class="mt-section-title">Favicon</h2></header>
        <div style="max-width:300px">
            <label class="mt-upload" for="upload-favicon">
                <svg class="mt-upload-icon" width="32" height="32" viewBox="0 0 40 40" fill="none"><path d="M20 6v22M11 15l9-9 9 9M6 28v3a3 3 0 003 3h22a3 3 0 003-3v-3" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/></svg>
                <div class="mt-upload-text">{if $favicon}Replace file{else}Click to upload{/if}</div>
                <div class="mt-upload-hint">.ico, .png or .svg — square preferred</div>
                <input id="upload-favicon" type="file" name="favicon" accept="image/*" hidden>
            </label>
            <div class="mt-upload-caption">Browser tab icon</div>
        </div>
    </section>

    <div style="display:flex;justify-content:flex-end;margin-top:8px">
        <button type="submit" class="mt-btn mt-btn-primary">Save changes</button>
    </div>
</form>

{include file="includes/footer.tpl"}
