{* Hostnodes — Dev preview chip (layout / palette / data toggles).
   Floating, draggable. Wired by apple-layout.js (state persists to
   localStorage). Hidden from public visitors unless preview mode or an
   admin session is active. *}

{assign var=_showChip value=false}
{if (isset($smarty.get.preview) && $smarty.get.preview == '1') || $adminLoggedIn || $adminMasqueradingAsClient}
    {assign var=_showChip value=true}
{/if}

{if $_showChip}
<div class="state-chip" role="group" aria-label="Preview options">
    <span class="dev-tag" title="Drag to move · double-click to reset">preview</span>

    <div class="chip-group">
        <span class="label">Layout:</span>
        <div class="pill-group">
            <button type="button" data-layout-set="top">Top nav</button>
            <button type="button" data-layout-set="side" class="active">Sidebar</button>
            <button type="button" data-layout-set="rail">Icon rail</button>
        </div>
    </div>

    <div class="chip-group">
        <span class="label">Data:</span>
        <div class="pill-group">
            <button type="button" data-data-set="full" class="active">Full</button>
            <button type="button" data-data-set="empty">Empty</button>
        </div>
    </div>

    <div class="chip-group">
        <span class="label">Align:</span>
        <div class="pill-group">
            <button type="button" data-align-set="center" class="active" title="Center the combined content + sub-nav unit">Center</button>
            <button type="button" data-align-set="content" title="Center the content column only — ignore sub-nav for centering math">Content</button>
            <button type="button" data-align-set="left">Left</button>
        </div>
    </div>

    <div class="chip-group">
        <span class="label">Sub-nav:</span>
        <div class="pill-group">
            <button type="button" data-subnav-set="on" class="active">Show</button>
            <button type="button" data-subnav-set="off">Hide</button>
        </div>
    </div>

    <div class="chip-group">
        <span class="label">Sub-nav side:</span>
        <div class="pill-group">
            <button type="button" data-subnav-side-set="left">Left</button>
            <button type="button" data-subnav-side-set="right" class="active">Right</button>
            <button type="button" data-subnav-side-set="outside-left" title="Float in the left outer gutter">Outside L</button>
            <button type="button" data-subnav-side-set="outside" title="Float in the right outer gutter">Outside R</button>
        </div>
    </div>

    <div class="chip-group">
        <span class="label">Services:</span>
        <div class="pill-group">
            <button type="button" data-svc-layout-set="inside" class="active" title="Search & pagination inside the white card (column titles outside)">Controls inside</button>
            <button type="button" data-svc-layout-set="outside" title="Only service rows in the white card; controls float on the page">Controls outside</button>
        </div>
    </div>

    <div class="chip-group">
        <span class="label">Tiles:</span>
        <div class="pill-group">
            <button type="button" data-tiles-set="all" class="active">All</button>
            <button type="button" data-tiles-set="a" title="Variant A — vertical">A</button>
            <button type="button" data-tiles-set="b" title="Variant B — horizontal">B</button>
            <button type="button" data-tiles-set="c" title="Variant C — tinted">C</button>
            <button type="button" data-tiles-set="d" title="Variant D — list">D</button>
            <button type="button" data-tiles-set="f" title="Variant F — list horizontal">F</button>
            <button type="button" data-tiles-set="e" title="Variant E — rings">E</button>
        </div>
    </div>

    <div class="chip-group">
        <span class="label">Plan:</span>
        <div class="pill-group">
            <button type="button" data-plan-set="all" class="active">All</button>
            <button type="button" data-plan-set="a" title="Variant A — 3 packages, feature list cards">A</button>
            <button type="button" data-plan-set="b" title="Variant B — 4 packages, minimal cards">B</button>
            <button type="button" data-plan-set="c" title="Variant C — 5 packages, horizontal rows">C</button>
            <button type="button" data-plan-set="d" title="Variant D — side-by-side comparison table">D</button>
            <button type="button" data-plan-set="e" title="Variant E — bento (1 hero + 2 minis)">E</button>
            <button type="button" data-plan-set="f" title="Variant F — segmented bar (single card, vertical dividers)">F</button>
            <button type="button" data-plan-set="g" title="Variant G — spec matrix (label/value rows)">G</button>
            <button type="button" data-plan-set="h" title="Variant H — addon cards with radio tiers">H</button>
        </div>
    </div>

    <div class="chip-group">
        <span class="label">Palette:</span>
        <div class="swatch-group" role="group" aria-label="Color palette">
            <button type="button" data-palette="blue"    class="active" title="Apple Blue"></button>
            <button type="button" data-palette="emerald"                title="Emerald"></button>
            <button type="button" data-palette="violet"                 title="Violet"></button>
            <button type="button" data-palette="rose"                   title="Rose"></button>
            <button type="button" data-palette="amber"                  title="Amber"></button>
            <button type="button" data-palette="slate"                  title="Slate"></button>
        </div>
    </div>
</div>
{/if}
