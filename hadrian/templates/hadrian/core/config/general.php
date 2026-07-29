<?php
/**
 * General schema — the SCALE LAYER behind every other panel, for the admin
 * Styles > General panel (StylesController::buildGeneralViewModel) and the
 * render-time emitter (Hooks::buildGeneralHead).
 *
 * Why this panel exists. Elements, Buttons and Forms each ship a `scales`
 * array letting a buyer PICK a step — "Card radius = Large" resolves to
 * var(--radius-lg) — but nothing anywhere let them say what Large is WORTH.
 * The four radius tokens have 410 consumers, the three shadows 34, the two
 * transitions 297, and until now not one of them was reachable from the admin.
 * That is the whole content of this panel: the values the other panels select
 * between. Lagom splits its admin the same way (their General vs Elements),
 * and it is the one split we genuinely lacked.
 *
 * GLOBAL (site-wide); emitted into :root. Every `default` MUST mirror the
 * matching token in assets/css/apple-theme.css — the admin shows the default
 * as the baseline and only persists values that DIFFER, so a drifted default
 * here makes the "is this an override?" test wrong in both directions.
 *
 * Three control types, and the reason each is not just a text box:
 *   px      plain integer pixels.
 *   em      a 2-decimal multiplier; button padding is em so it tracks the
 *           button's own font size rather than fighting it.
 *   ms      an integer; the emitter re-attaches the easing curve, because the
 *           stored token is a composite (`150ms cubic-bezier(...)`) and the
 *           curve is ours to keep consistent, not a buyer's to mistype.
 *   preset  a fixed dropdown over authored `options`. Shadows are composite
 *           multi-layer strings — there is no validator for them short of a
 *           CSS parser, and a malformed one dropped raw into the <style> block
 *           would break the rule it lands in. Offering the three we author is
 *           the honest control.
 */
return [
    'sizeMin' => 0,
    'sizeMax' => 4000,

    'groups' => [
        'Corner radius' => [
            ['var' => '--radius-sm',   'label' => 'Small',  'type' => 'px', 'default' => 8],
            ['var' => '--radius-md',   'label' => 'Medium', 'type' => 'px', 'default' => 12],
            // Ships equal to Medium. That is a real flaw -- two rungs of a
            // four-rung scale are the same number -- but changing it here would
            // repaint every card, panel and modal in the product. Now that the
            // scale is editable, a buyer who wants them distinct can say so.
            ['var' => '--radius-lg',   'label' => 'Large',  'type' => 'px', 'default' => 12],
            ['var' => '--radius-pill', 'label' => 'Pill',   'type' => 'px', 'default' => 980],
        ],

        'Shadow' => [
            ['var' => '--shadow-card',       'label' => 'Card',       'type' => 'preset', 'default' => 'soft'],
            ['var' => '--shadow-card-hover', 'label' => 'Card hover', 'type' => 'preset', 'default' => 'medium'],
            ['var' => '--shadow-dropdown',   'label' => 'Dropdown',   'type' => 'preset', 'default' => 'strong'],
        ],

        'Controls' => [
            ['var' => '--input-height', 'label' => 'Input height',   'type' => 'px', 'default' => 40],
            ['var' => '--input-pad-x',  'label' => 'Input padding',  'type' => 'px', 'default' => 14],
            ['var' => '--btn-pad-y',    'label' => 'Button pad Y',   'type' => 'em', 'default' => 0.65],
            ['var' => '--btn-pad-x',    'label' => 'Button pad X',   'type' => 'em', 'default' => 1.43],
        ],

        'Motion' => [
            ['var' => '--transition-fast',   'label' => 'Fast',   'type' => 'ms', 'default' => 150],
            ['var' => '--transition-medium', 'label' => 'Medium', 'type' => 'ms', 'default' => 250],
        ],
    ],

    // Authored shadow stacks. Values are copied verbatim from apple-theme.css;
    // 'none' is offered because "no shadow at all" is a legitimate flat look
    // and cannot be expressed by picking one of the other three.
    'shadowOptions' => [
        ['key' => 'none',   'label' => 'None',   'css' => 'none'],
        ['key' => 'soft',   'label' => 'Soft',   'css' => '0 0 0 0.5px rgba(0,0,0,0.04), 0 1px 2px rgba(0,0,0,0.03)'],
        ['key' => 'medium', 'label' => 'Medium', 'css' => '0 0 0 0.5px rgba(0,0,0,0.04), 0 2px 12px rgba(0,0,0,0.06)'],
        ['key' => 'strong', 'label' => 'Strong', 'css' => '0 4px 32px rgba(0,0,0,0.12), 0 0 1px rgba(0,0,0,0.08)'],
    ],

    // Re-attached to every motion value at emit time. Keeping the curve out of
    // the buyer's hands is deliberate: an inconsistent easing across 297
    // consumers reads as jank, not as customisation.
    'easing' => 'cubic-bezier(0.25, 0.1, 0.25, 1)',
];
