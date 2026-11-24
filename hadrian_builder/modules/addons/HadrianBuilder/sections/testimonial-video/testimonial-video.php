<?php
/**
 * A dark card with a video poster on one side and a customer quote on the
 * other. The play button is a link to the video and opens it in a new tab.
 * Markup and classes: the theme's hp-testi-video block.
 */
return [
    'label'  => 'Quote with video',
    'hint'   => 'A quote beside a link to a video',
    'group'  => 'Testimonials',
    'order'  => 530,
    'fields' => [
        ['key' => 'title', 'type' => 'text', 'label' => 'Heading', 'translatable' => true, 'default' => ['_' => 'In their own words']],
        ['key' => 'quote', 'type' => 'textarea', 'label' => 'Quote', 'translatable' => true,
            'default' => ['_' => 'I put off moving hosts for two years. The move took one evening, and the shop has not gone down since.'],
            'help' => 'Replace this example with words from one of your own customers.'],
        ['key' => 'name', 'type' => 'text', 'label' => 'Who said it', 'translatable' => true, 'default' => ['_' => 'Store owner']],
        ['key' => 'role', 'type' => 'text', 'label' => 'Second line', 'translatable' => true, 'default' => ['_' => 'Hosting customer'],
            'help' => 'A job title, a company or what they use. Leave empty to hide it.'],
        ['key' => 'avatar', 'type' => 'image', 'label' => 'Photo of the customer', 'default' => '',
            'help' => 'Shown as a small circle beside the name.'],
        ['key' => 'link', 'type' => 'link', 'label' => 'Video link', 'default' => '',
            'help' => 'The address of the video. The play button opens it in a new tab. Leave empty for no play button.'],
        ['key' => 'playLabel', 'type' => 'text', 'label' => 'Name of the play button', 'translatable' => true, 'default' => ['_' => 'Play the video'],
            'help' => 'Read aloud by screen readers.'],
        ['key' => 'image', 'type' => 'image', 'label' => 'Poster image', 'default' => '',
            'help' => 'Fills the video side of the card. Without one the side is a plain dark panel.'],
        ['key' => 'imageAlt', 'type' => 'text', 'label' => 'Poster description', 'translatable' => true, 'default' => ['_' => ''],
            'help' => 'Read aloud by screen readers. Leave empty for a purely decorative image.'],
    ],
];
