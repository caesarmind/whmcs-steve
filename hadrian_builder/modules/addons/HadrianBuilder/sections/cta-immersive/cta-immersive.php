<?php
/**
 * A call to action on a green-to-accent gradient that runs the full width
 * of the page: a headline, a line of text and one button.
 * Markup and classes: the theme's hp-cta-immersive block.
 */
return [
    'label'  => 'Call to action, full width',
    'hint'   => 'A colour gradient band with one button',
    'group'  => 'Call to action',
    'order'  => 820,
    'fields' => [
        ['key' => 'title', 'type' => 'text', 'label' => 'Headline', 'translatable' => true, 'default' => ['_' => 'Put your site online today']],
        ['key' => 'text', 'type' => 'textarea', 'label' => 'Text', 'translatable' => true,
            'default' => ['_' => 'Order in a few minutes and we will help you move in.']],
        ['key' => 'primaryLabel', 'type' => 'text', 'label' => 'Button text', 'translatable' => true, 'default' => ['_' => 'Get started']],
        ['key' => 'primaryLink', 'type' => 'link', 'label' => 'Button link', 'default' => 'cart.php',
            'help' => 'A web address, "#pricing" for a section on this page, or a WHMCS path such as cart.php?gid=1.'],
    ],
];
