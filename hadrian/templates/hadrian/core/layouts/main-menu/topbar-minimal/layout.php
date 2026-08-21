<?php
/**
 * Topbar Minimal — the SHIPPED EXAMPLE of a custom main-menu layout, and the
 * repo's end-to-end test fixture for the discovery path.
 *
 * Deliberately NOT listed in theme.json provides.layouts: it exists to prove
 * that a folder dropped into core/layouts/main-menu/ is discovered by
 * LayoutsCache, appears as an admin card (badged "Custom"), activates per
 * audience, previews via ?preview=1&layout=topbar-minimal, and renders through
 * header.tpl's generic dispatch — with zero edits to theme.json, header.tpl or
 * core-layout.css. Copy this folder to start your own layout.
 *
 * The contract (see docs/EXTENDING.md):
 *   - variables.dataLayout: lowercase token, /^[a-z][a-z0-9-]{1,30}$/. Becomes
 *     body[data-layout] and the .only-<token> gate class.
 *   - default.tpl: the markup. Root element carries class "only-<token>";
 *     renders as a body-level sibling before .ph-main-wrap.
 *   - layout.css (optional): the layout's own chrome, loaded automatically.
 *   - css block (optional): the generated structural minimum. This layout is a
 *     top bar, so it declares no contentOffset — its own layout.css pads the
 *     page top instead. A pinned side column would declare
 *     'css' => ['contentOffset' => 240] and get the margin + mobile collapse
 *     generated for it.
 */
return [
    'displayName' => 'Topbar Minimal',
    'description' => 'Example custom layout: a slim fixed top bar. Copy this folder to build your own.',
    'variables'   => [
        'dataLayout' => 'topbar-minimal',
    ],
    // No 'css' block: a top bar needs no content margin. See the header
    // comment for what a side-column layout would declare here.
    //
    /* 'sizes' is the other half of the discovery contract worth demonstrating:
       naming a NAVIGATION token from core/config/navigation.php here captions
       its field in Styles > Navigation with the layouts that claim it, and
       Hooks::buildNavigationHead emits it -- with no controller or view edit.
       (Naming a token from core/config/layout.php instead renders a whole new
       field in the Layouts page's Containers section, same contract, different
       schema. Page structure there, navigation here.)
       --tbm-bar-height is this layout's alone (the bar and the page's top
       padding read it together); the logo height is shared with all four. */
    'sizes' => ['--tbm-bar-height', '--nav-logo-height'],
];
