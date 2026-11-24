<?php
/**
 * Hero with a domain search box under the headline, beside an optional
 * image. The box sends the visitor to the WHMCS domain search.
 * Markup and classes: the theme's hp-hero-split block and its ds-search-form.
 */
return [
    'label'  => 'Hero with domain search',
    'hint'   => 'Headline with a domain search box',
    'group'  => 'Hero',
    'order'  => 115,
    'fields' => [
        ['key' => 'eyebrow', 'type' => 'text', 'label' => 'Eyebrow', 'translatable' => true, 'default' => ['_' => 'Domains'],
            'help' => 'The short line above the headline. Leave empty to hide it.'],
        ['key' => 'title', 'type' => 'text', 'label' => 'Headline', 'translatable' => true, 'default' => ['_' => 'Find a name for your next project']],
        ['key' => 'text', 'type' => 'textarea', 'label' => 'Text', 'translatable' => true,
            'default' => ['_' => 'Type the name you have in mind and see straight away whether it is free.']],
        ['key' => 'placeholder', 'type' => 'text', 'label' => 'Hint inside the search box', 'translatable' => true, 'default' => ['_' => 'yourname.com']],
        ['key' => 'buttonLabel', 'type' => 'text', 'label' => 'Button text', 'translatable' => true, 'default' => ['_' => 'Search']],
        ['key' => 'searchLabel', 'type' => 'text', 'label' => 'Search box name', 'translatable' => true, 'default' => ['_' => 'Domain name'],
            'help' => 'Read aloud by screen readers. It is not shown on the page.'],
        ['key' => 'image', 'type' => 'image', 'label' => 'Image', 'default' => ''],
        ['key' => 'imageAlt', 'type' => 'text', 'label' => 'Image description', 'translatable' => true, 'default' => ['_' => ''],
            'help' => 'Read aloud by screen readers. Leave empty for a purely decorative image.'],
        ['key' => 'flip', 'type' => 'toggle', 'label' => 'Image on the left', 'default' => false],
    ],
];
