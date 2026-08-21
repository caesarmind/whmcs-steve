<?php
/**
 * Elements schema — component SHAPE controls (radius / shadow / padding) for
 * the admin Styles > Elements panel (StylesController::buildElementsViewModel)
 * and the emitter (Hooks::buildElementsHead). Colours live in the Colors panel,
 * so Elements deliberately owns only shape, not colour — no overlap.
 *
 * Structurally a px/scale size panel (like the Sizes half of Forms): px fields
 * or SCALE references resolved through `scales`. GLOBAL; emitted into :root.
 * Every `default` MUST mirror the matching token in assets/css/core-theme.css.
 */
return [
    'sizeMin' => 0,
    'sizeMax' => 999,
    'scales'  => [
        'radius' => [
            ['key' => 'none', 'label' => 'None',   'css' => '0'],
            ['key' => 'sm',   'label' => 'Small',  'css' => 'var(--radius-sm)'],
            ['key' => 'md',   'label' => 'Medium', 'css' => 'var(--radius-md)'],
            ['key' => 'lg',   'label' => 'Large',  'css' => 'var(--radius-lg)'],
            ['key' => 'pill', 'label' => 'Pill',   'css' => 'var(--radius-pill)'],
        ],
        'shadow' => [
            ['key' => 'none',   'label' => 'None',   'css' => 'none'],
            ['key' => 'soft',   'label' => 'Soft',   'css' => 'var(--shadow-card)'],
            ['key' => 'medium', 'label' => 'Medium', 'css' => 'var(--shadow-card-hover)'],
            ['key' => 'strong', 'label' => 'Strong', 'css' => 'var(--shadow-dropdown)'],
        ],
    ],
    'sizeGroups' => [
        'Card' => [
            ['var' => '--card-radius', 'label' => 'Radius',  'type' => 'scale', 'scale' => 'radius', 'default' => 'lg'],
            ['var' => '--card-shadow', 'label' => 'Shadow',  'type' => 'scale', 'scale' => 'shadow', 'default' => 'soft'],
            ['var' => '--card-pad',    'label' => 'Padding', 'type' => 'px',                          'default' => 24],
        ],
        'Pagination' => [
            ['var' => '--pagination-radius', 'label' => 'Button radius', 'type' => 'scale', 'scale' => 'radius', 'default' => 'sm'],
        ],
    ],
];
