<?php
/**
 * Many customer quotes packed into columns, like notes on a wall. A tile can
 * be coloured or given larger text to break up the pattern.
 * Markup and classes: the theme's hp-testi-masonry block.
 */
return [
    'label'  => 'Quote wall',
    'hint'   => 'Many quotes packed into columns',
    'group'  => 'Testimonials',
    'order'  => 550,
    'fields' => [
        ['key' => 'title', 'type' => 'text', 'label' => 'Heading', 'translatable' => true, 'default' => ['_' => 'What our customers tell us']],
        ['key' => 'subtitle', 'type' => 'text', 'label' => 'Subheading', 'translatable' => true, 'default' => ['_' => 'From people who host with us.']],
        ['key' => 'items', 'type' => 'list', 'label' => 'Quotes', 'max' => 16, 'itemLabel' => 'name', 'addLabel' => 'Add quote',
            'help' => 'Replace these examples with words from your own customers.',
            'fields' => [
                ['key' => 'quote', 'type' => 'textarea', 'label' => 'Quote', 'translatable' => true, 'default' => ['_' => '']],
                ['key' => 'name', 'type' => 'text', 'label' => 'Who said it', 'translatable' => true, 'default' => ['_' => 'Customer']],
                ['key' => 'role', 'type' => 'text', 'label' => 'Second line', 'translatable' => true, 'default' => ['_' => ''],
                    'help' => 'A job title, a company or what they use.'],
                ['key' => 'image', 'type' => 'image', 'label' => 'Photo', 'default' => '',
                    'help' => 'Shown as a small circle beside the name.'],
                ['key' => 'rating', 'type' => 'number', 'label' => 'Stars', 'min' => 0, 'max' => 5, 'default' => 5,
                    'help' => '0 hides the stars.'],
                ['key' => 'tone', 'type' => 'select', 'label' => 'Colour', 'default' => 'plain',
                    'options' => ['plain' => 'Light', 'accent' => 'Blue', 'dark' => 'Dark', 'cream' => 'Cream']],
                ['key' => 'tall', 'type' => 'toggle', 'label' => 'Larger text', 'default' => false],
            ],
            'default' => [
                ['quote' => ['_' => 'Support read my whole ticket before replying. That alone was worth the switch.'],
                    'name' => ['_' => 'Technical lead'], 'role' => ['_' => 'VPS customer'], 'image' => '', 'rating' => 5, 'tone' => 'plain', 'tall' => false],
                ['quote' => ['_' => 'I have used a few hosts over the years. This is the first one where the control panel, the invoices and the emails all make sense without a manual.'],
                    'name' => ['_' => 'Freelance developer'], 'role' => ['_' => 'Hosting customer'], 'image' => '', 'rating' => 5, 'tone' => 'accent', 'tall' => true],
                ['quote' => ['_' => 'A plugin update broke my shop. I restored the backup from the night before and was selling again in ten minutes.'],
                    'name' => ['_' => 'Store owner'], 'role' => ['_' => 'Hosting customer'], 'image' => '', 'rating' => 5, 'tone' => 'plain', 'tall' => false],
                ['quote' => ['_' => 'Sale week tripled our traffic and the site stayed up the whole time.'],
                    'name' => ['_' => 'Operations manager'], 'role' => ['_' => 'VPS customer'], 'image' => '', 'rating' => 5, 'tone' => 'dark', 'tall' => false],
                ['quote' => ['_' => 'Renewal reminders arrive early and the price is the one I was quoted.'],
                    'name' => ['_' => 'Web designer'], 'role' => ['_' => 'Domain customer'], 'image' => '', 'rating' => 5, 'tone' => 'plain', 'tall' => false],
                ['quote' => ['_' => 'I asked support to move my site and expected a week of emails. They did it overnight and sent a short note when it was done.'],
                    'name' => ['_' => 'Agency owner'], 'role' => ['_' => 'Hosting customer'], 'image' => '', 'rating' => 5, 'tone' => 'cream', 'tall' => true],
                ['quote' => ['_' => 'Transferring my domain in took one form and a confirmation email.'],
                    'name' => ['_' => 'Blogger'], 'role' => ['_' => 'Domain customer'], 'image' => '', 'rating' => 5, 'tone' => 'plain', 'tall' => false],
                ['quote' => ['_' => 'My server was ready before I had finished reading the welcome email.'],
                    'name' => ['_' => 'Developer'], 'role' => ['_' => 'VPS customer'], 'image' => '', 'rating' => 5, 'tone' => 'plain', 'tall' => false],
            ]],
    ],
];
