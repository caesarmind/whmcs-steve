<?php
/**
 * A slim bar of links that jump to sections of the same page, with the
 * page's name on the left and one button on the right. The theme's script
 * marks the link of the section being read.
 * Markup and classes: the theme's homepage-subnav block.
 */
return [
    'label'  => 'In-page navigation',
    'hint'   => 'A bar of links to sections of this page',
    'group'  => 'Hero',
    'order'  => 190,
    'fields' => [
        ['key' => 'title', 'type' => 'text', 'label' => 'Title', 'translatable' => true, 'default' => ['_' => 'Web hosting'],
            'help' => 'Usually the name of the page or the product.'],
        ['key' => 'links', 'type' => 'list', 'label' => 'Links', 'max' => 8, 'itemLabel' => 'label', 'addLabel' => 'Add link',
            'fields' => [
                ['key' => 'label', 'type' => 'text', 'label' => 'Text', 'translatable' => true, 'default' => ['_' => 'New link']],
                ['key' => 'link', 'type' => 'link', 'label' => 'Link', 'default' => '',
                    'help' => 'A "#" followed by the anchor of a section on this page, for example #pricing. Set a section\'s anchor in its own settings.'],
            ],
            'default' => [
                ['label' => ['_' => 'Overview'], 'link' => '#overview'],
                ['label' => ['_' => 'Features'], 'link' => '#features'],
                ['label' => ['_' => 'Pricing'], 'link' => '#pricing'],
                ['label' => ['_' => 'Questions'], 'link' => '#faq'],
            ]],
        ['key' => 'buttonLabel', 'type' => 'text', 'label' => 'Button text', 'translatable' => true, 'default' => ['_' => 'Order now']],
        ['key' => 'buttonLink', 'type' => 'link', 'label' => 'Button link', 'default' => 'cart.php'],
        ['key' => 'navLabel', 'type' => 'text', 'label' => 'Name of the bar', 'translatable' => true, 'default' => ['_' => 'On this page'],
            'help' => 'Read aloud by screen readers. It is not shown on the page.'],
    ],
];
