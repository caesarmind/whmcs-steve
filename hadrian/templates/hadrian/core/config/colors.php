<?php
/**
 * Color schema + per-mode defaults — single source of truth for the admin
 * Colors panel (StylesController) and the render-time emitter
 * (Hooks::buildColorsHead).
 *
 * Each token's `light` / `dark` default MUST mirror the :root and
 * [data-theme="dark"] blocks in assets/css/apple-theme.css. The admin form
 * shows the per-style default as the baseline and only persists/emits the
 * tokens the buyer CHANGES — so if you change a default in the CSS, change it
 * here too or the "is this an override?" comparison desyncs.
 *
 * Editing the `default` style edits the light (:root) values; editing the
 * `dark` style edits the [data-theme="dark"] values (resolved by colorMode).
 */
return [
    // Quick accent presets for the scheme chips. Clicking one cascades the
    // brand-token fields in the form (accent + hover + tint + link); JS only.
    'presets' => [
        ['name' => 'Default', 'accent' => '#0071e3'],
        ['name' => 'Emerald', 'accent' => '#14b17d'],
        ['name' => 'Violet',  'accent' => '#8c5cff'],
        ['name' => 'Rose',    'accent' => '#ff2d6b'],
        ['name' => 'Amber',   'accent' => '#f08a00'],
        ['name' => 'Slate',   'accent' => '#64748b'],
    ],

    // Editable tokens, grouped for the form. Each: var, label, light, dark,
    // and an optional `hint` shown under the label.
    //
    // ORDER IS THE ARGUMENT. Groups 1-4 are the PALETTE -- what colours exist.
    // Groups 5-8 are PLACEMENT -- where those colours land. A buyer looking for
    // "why is that thing blue" reads downward; a buyer rebranding reads the top
    // four and stops.
    //
    // Group names are display strings only: the view model keys by name purely
    // to render, and every stored row is keyed by `var`. So regrouping and
    // relabelling are free. Renaming a `var` is NOT -- it silently orphans a
    // buyer's saved override, and buildColorsHead keeps emitting the orphan
    // forever because it validates the name PATTERN, not membership here.
    // Add freely; rename and remove never.
    'groups' => [
        'Brand' => [
            ['var' => '--color-accent',       'label' => 'Accent',       'light' => '#0071e3',              'dark' => '#2997ff',              'hint' => 'Primary buttons, active states, focus rings.'],
            ['var' => '--color-accent-hover', 'label' => 'Accent hover', 'light' => '#0077ed',              'dark' => '#40a3ff',              'hint' => 'Follows the Accent. Set a value only to break that link; the swatch shows stock, not the derived colour.'],
            ['var' => '--color-accent-light', 'label' => 'Accent tint',  'light' => 'rgba(0,113,227,0.08)', 'dark' => 'rgba(41,151,255,0.12)', 'hint' => 'The translucent wash behind selected rows and info badges.'],
            ['var' => '--color-on-accent',    'label' => 'On accent',    'light' => '#ffffff',              'dark' => '#ffffff',              'hint' => 'Text and icons sitting ON a filled accent surface. Stays light in both modes.'],
            ['var' => '--color-link',         'label' => 'Link',         'light' => '#0066cc',              'dark' => '#2997ff',              'hint' => 'Follows the Accent: darker than it in light mode, equal in dark.'],
            ['var' => '--color-link-hover',   'label' => 'Link hover',   'light' => '#0071e3',              'dark' => '#40a3ff',              'hint' => 'Follows the Accent automatically.'],
        ],

        // Renamed from "Backgrounds" to match the word every other panel's
        // dropdowns already use for these (Buttons and Forms label them
        // Surface / Surface 2).
        'Surfaces' => [
            ['var' => '--color-bg',                'label' => 'Page',      'light' => '#fbfbfd', 'dark' => '#1c1c1e', 'hint' => 'Behind everything.'],
            ['var' => '--color-surface',           'label' => 'Surface',   'light' => '#ffffff', 'dark' => '#2c2c2e', 'hint' => 'Cards, panels, tables.'],
            ['var' => '--color-surface-secondary', 'label' => 'Surface 2', 'light' => '#f5f5f7', 'dark' => '#3a3a3c', 'hint' => 'Insets on a card: fields, wells, table headers.'],
            ['var' => '--color-surface-tertiary',  'label' => 'Surface 3', 'light' => '#fafafa', 'dark' => '#252527', 'hint' => 'The ordinal inverts: lighter than Surface 2 in light, darker in dark.'],
        ],

        'Text' => [
            ['var' => '--color-text-primary',    'label' => 'Primary',    'light' => '#1d1d1f', 'dark' => '#f5f5f7', 'hint' => 'Headings and body copy.'],
            ['var' => '--color-text-secondary',  'label' => 'Secondary',  'light' => '#6e6e73', 'dark' => '#a1a1a6'],
            ['var' => '--color-text-tertiary',   'label' => 'Tertiary',   'light' => '#86868b', 'dark' => '#8e8e93', 'hint' => 'Captions and meta. Only ~3.4:1 on a light card -- never for text that matters.'],
            ['var' => '--color-text-quaternary', 'label' => 'Quaternary', 'light' => '#aeaeb2', 'dark' => '#636366', 'hint' => 'Placeholders only.'],
        ],

        'Borders' => [
            ['var' => '--color-border',       'label' => 'Border',       'light' => '#e8e8ed',          'dark' => '#3a3a3c'],
            ['var' => '--color-border-light', 'label' => 'Border light', 'light' => '#f0f0f5',          'dark' => '#2c2c2e'],
            ['var' => '--color-border-card',  'label' => 'Card border',  'light' => 'rgba(0,0,0,0.04)', 'dark' => 'rgba(255,255,255,0.06)', 'hint' => 'Translucent, so it tints whatever is behind the card.'],
        ],

        // Badges merged in. The split was arbitrary: the green/orange/red fills
        // were already filed under Status while only the blue and gray pairs
        // sat in Badges, so the same information was spread across two headings
        // for no reason. One group ordered Success / Warning / Danger / Info /
        // Neutral is how a buyer thinks about it.
        'Status & badges' => [
            ['var' => '--color-green',       'label' => 'Success',      'light' => '#30d158',               'dark' => '#30d158', 'hint' => 'The dot or fill. Pair with Success text for the label.'],
            ['var' => '--color-green-text',  'label' => 'Success text', 'light' => '#248a3d',               'dark' => '#30d158'],
            ['var' => '--color-green-bg',    'label' => 'Success fill', 'light' => 'rgba(48,209,88,0.10)',  'dark' => 'rgba(48,209,88,0.16)'],
            ['var' => '--color-orange',      'label' => 'Warning',      'light' => '#ff9f0a',               'dark' => '#ff9f0a'],
            ['var' => '--color-orange-text', 'label' => 'Warning text', 'light' => '#c27400',               'dark' => '#ff9f0a'],
            ['var' => '--color-orange-bg',   'label' => 'Warning fill', 'light' => 'rgba(255,159,10,0.10)', 'dark' => 'rgba(255,159,10,0.16)'],
            // dark is #ff3b30, NOT #ff453a. apple-theme.css does not redeclare
            // --color-red in the dark block, so dark mode renders the light
            // value. The schema used to claim #ff453a, which made this control
            // silently inert: a buyer typing #ff453a in Dark scope had it
            // compared against a default of #ff453a, judged unchanged, and
            // dropped -- while the page went on rendering #ff3b30.
            //
            // Left as-is rather than "fixed" in the CSS because adding
            // --color-red: #ff453a to the dark block is a VISIBLE change to
            // every danger dot and fill in dark mode. Worth doing (it is what
            // --color-red-text already uses, and Apple's dark systemRed), but
            // it is a design call, not a silent cleanup.
            ['var' => '--color-red',         'label' => 'Danger',       'light' => '#ff3b30',               'dark' => '#ff3b30'],
            ['var' => '--color-red-text',    'label' => 'Danger text',  'light' => '#d70015',               'dark' => '#ff453a'],
            ['var' => '--color-red-bg',      'label' => 'Danger fill',  'light' => 'rgba(255,59,48,0.10)',  'dark' => 'rgba(255,59,48,0.16)'],
            ['var' => '--color-blue-text',   'label' => 'Info',         'light' => '#0071e3',               'dark' => '#2997ff', 'hint' => 'Separate from the Accent on purpose, so info need not follow a rebrand.'],
            ['var' => '--color-blue-bg',     'label' => 'Info fill',    'light' => 'rgba(0,113,227,0.08)',  'dark' => 'rgba(41,151,255,0.14)'],
            ['var' => '--color-gray-text',   'label' => 'Neutral',      'light' => '#6e6e73',               'dark' => '#a1a1a6'],
            ['var' => '--color-gray-bg',     'label' => 'Neutral fill', 'light' => 'rgba(142,142,147,0.12)','dark' => 'rgba(142,142,147,0.18)'],
        ],

        // Topbar merged in -- a whole section heading and hairline for one row
        // was pure noise. This group is also the honest home of the retired
        // Navigation panel: those tokens were always here, the panel would only
        // have been a second place to edit the same rows.
        'Navigation & bars' => [
            // THE SEED. Pick one colour and the eleven rows below all derive
            // from it -- bar, panel, the four text steps, hairline, search
            // field, hover, active, scrollbar and badge -- with black-or-white
            // label ink chosen by exact WCAG luminance, so the menu is legible
            // whatever colour lands here. See the "Sidebar tint" block in
            // apple-theme.css.
            //
            // Its default is EMPTY on purpose, and that is load-bearing:
            // --sidebar-color is never declared in the CSS, so with nothing
            // stored every derived token is invalid-at-computed-value-time and
            // the rows below fall back to the literals that ship. Empty means
            // "off", clearing the field means "back to off", and an existing
            // install renders byte-identically until someone types here.
            //
            // check-color-defaults.mjs skips any token with an empty default
            // for this reason -- it is the one token that MUST NOT appear in
            // apple-theme.css.
            ['var' => '--sidebar-color',          'label' => 'Sidebar colour',     'light' => '',                       'dark' => '',                    'hint' => 'Off keeps the nav neutral. Follow brand tracks the Accent; Custom stays fixed.'],
            ['var' => '--sidebar-bg',             'label' => 'Sidebar background', 'light' => 'rgba(246,246,248,0.80)', 'dark' => 'rgba(28,28,30,0.80)', 'hint' => 'Translucent: it frosts whatever scrolls under it.'],
            ['var' => '--sidebar-panel-bg',       'label' => 'Flyout panel',       'light' => '#ffffff',                'dark' => '#2c2c2e', 'hint' => 'The rail layout only. Not the sidebar itself.'],
            ['var' => '--sidebar-text',           'label' => 'Text',               'light' => '#1d1d1f',                'dark' => '#f5f5f7', 'hint' => 'Set this whenever you darken the background, or the menu goes dark-on-dark.'],
            ['var' => '--sidebar-text-secondary', 'label' => 'Text soft',          'light' => '#6e6e73',                'dark' => '#a1a1a6'],
            ['var' => '--sidebar-text-muted',     'label' => 'Text muted',         'light' => '#86868b',                'dark' => '#8e8e93', 'hint' => 'Section labels and the user email.'],
            ['var' => '--sidebar-text-faint',     'label' => 'Placeholder',        'light' => '#aeaeb2',                'dark' => '#636366'],
            ['var' => '--sidebar-border',         'label' => 'Border',             'light' => '#e8e8ed',                'dark' => '#3a3a3c'],
            ['var' => '--sidebar-field-bg',       'label' => 'Search field',       'light' => '#f5f5f7',                'dark' => '#3a3a3c'],
            ['var' => '--sidebar-item-hover-bg',  'label' => 'Item hover',         'light' => 'rgba(0,0,0,0.04)',       'dark' => 'rgba(255,255,255,0.05)', 'hint' => 'Sidebar only -- the similarly named shared token is not editable here.'],
            ['var' => '--sidebar-item-active-bg', 'label' => 'Item active',        'light' => 'rgba(0,0,0,0.06)',       'dark' => 'rgba(255,255,255,0.08)'],
            ['var' => '--sidebar-scroll-thumb',   'label' => 'Scrollbar',          'light' => 'rgba(0,0,0,0.15)',       'dark' => 'rgba(255,255,255,0.15)'],
            ['var' => '--topbar-bg',              'label' => 'Topbar background',  'light' => 'rgba(251,251,253,0.72)', 'dark' => 'rgba(44,44,46,0.72)', 'hint' => 'Also translucent -- keep some alpha or the frost effect is lost.'],
        ],

        // Avatars joined the icon tiles: both are small painted identity
        // shapes, and neither had anywhere else sensible to live.
        'Icons & avatars' => [
            ['var' => '--color-icon-blue',   'label' => 'Blue',   'light' => '#007aff', 'dark' => '#007aff', 'hint' => 'Same in both modes: they sit on a coloured chip, not the page.'],
            ['var' => '--color-icon-purple', 'label' => 'Purple', 'light' => '#af52de', 'dark' => '#af52de'],
            ['var' => '--color-icon-orange', 'label' => 'Orange', 'light' => '#ff9500', 'dark' => '#ff9500'],
            ['var' => '--color-icon-green',  'label' => 'Green',  'light' => '#34c759', 'dark' => '#34c759'],
            ['var' => '--color-icon-red',    'label' => 'Red',    'light' => '#ff3b30', 'dark' => '#ff3b30'],
            ['var' => '--color-icon-teal',   'label' => 'Teal',   'light' => '#5ac8fa', 'dark' => '#5ac8fa'],
            ['var' => '--color-icon-gray',   'label' => 'Gray',   'light' => '#8e8e93', 'dark' => '#8e8e93'],
            ['var' => '--color-icon-indigo', 'label' => 'Indigo', 'light' => '#5856d6', 'dark' => '#5856d6'],
            ['var' => '--color-icon-pink',   'label' => 'Pink',   'light' => '#ff2d55', 'dark' => '#ff2d55'],
            ['var' => '--color-avatar-from', 'label' => 'Avatar from', 'light' => '#007aff', 'dark' => '#0a84ff', 'hint' => 'The user monogram gradient, sidebar and topbar. Previously hardcoded and uncontrollable.'],
            ['var' => '--color-avatar-to',   'label' => 'Avatar to',   'light' => '#5856d6', 'dark' => '#6e6cff'],
        ],

        // Three free slots a buyer can set to anything, offered alongside the
        // palette when painting a dashboard block. This is what "add a custom
        // colour" means here: the Colors panel cannot invent a token, its group
        // list IS the universe, so a custom colour has to be a slot that exists
        // up front. Each carries its own dark value, which a hex typed into a
        // page option never could.
        //
        // Defaults are distinct hues rather than copies of the accent: a slot
        // that merely duplicates --color-accent only pretends to inherit it and
        // goes stale the moment the accent changes.
        'Block accents' => [
            ['var' => '--color-block-1', 'label' => 'Block accent 1', 'light' => '#5856d6', 'dark' => '#7d7bff', 'hint' => 'Free slots for painting dashboard blocks.'],
            ['var' => '--color-block-2', 'label' => 'Block accent 2', 'light' => '#0f9d58', 'dark' => '#34c759'],
            ['var' => '--color-block-3', 'label' => 'Block accent 3', 'light' => '#d9480f', 'dark' => '#ff9500'],
        ],

    ],
];
