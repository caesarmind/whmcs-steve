<?php
/**
 * Questions that open on click, with a panel beside them that points to
 * support: an icon, a heading, a line of text and up to two buttons.
 * Markup and classes: the theme's hp-faq-contact block.
 */
return [
    'label'  => 'Questions with contact panel',
    'hint'   => 'Questions beside a way to get in touch',
    'group'  => 'Questions',
    'order'  => 630,
    'fields' => [
        ['key' => 'title', 'type' => 'text', 'label' => 'Heading', 'translatable' => true, 'default' => ['_' => 'Good to know']],
        ['key' => 'openFirst', 'type' => 'toggle', 'label' => 'Show the first answer open', 'default' => false],
        ['key' => 'items', 'type' => 'list', 'label' => 'Questions', 'max' => 30, 'itemLabel' => 'question', 'addLabel' => 'Add question',
            'fields' => [
                ['key' => 'question', 'type' => 'text', 'label' => 'Question', 'translatable' => true, 'default' => ['_' => 'New question']],
                ['key' => 'answer', 'type' => 'rich', 'label' => 'Answer', 'translatable' => true, 'default' => ['_' => '']],
            ],
            'default' => [
                ['question' => ['_' => 'How soon can I start?'], 'answer' => ['_' => '<p>Most accounts are ready a few minutes after payment. A domain transfer takes longer, usually up to a week.</p>']],
                ['question' => ['_' => 'Can I move to a bigger plan?'], 'answer' => ['_' => '<p>Yes, at any time from your client area. You pay only the difference for the days that are left.</p>']],
                ['question' => ['_' => 'What if it is not for me?'], 'answer' => ['_' => '<p>Tell us within the first 30 days and we refund the hosting fee.</p>']],
                ['question' => ['_' => 'Where are the servers?'], 'answer' => ['_' => '<p>You choose a location when you order. Pick the one closest to your visitors.</p>']],
            ]],
        ['key' => 'panelIcon', 'type' => 'icon', 'label' => 'Panel: icon', 'default' => 'chat'],
        ['key' => 'panelTitle', 'type' => 'text', 'label' => 'Panel: heading', 'translatable' => true, 'default' => ['_' => 'Not on the list?']],
        ['key' => 'panelText', 'type' => 'textarea', 'label' => 'Panel: text', 'translatable' => true, 'default' => ['_' => 'Write to us and someone from support will reply, usually within the hour.']],
        ['key' => 'primaryLabel', 'type' => 'text', 'label' => 'Panel: button text', 'translatable' => true, 'default' => ['_' => 'Open a ticket']],
        ['key' => 'primaryLink', 'type' => 'link', 'label' => 'Panel: button link', 'default' => 'submitticket.php'],
        ['key' => 'secondaryLabel', 'type' => 'text', 'label' => 'Panel: second link text', 'translatable' => true, 'default' => ['_' => 'Read the help articles']],
        ['key' => 'secondaryLink', 'type' => 'link', 'label' => 'Panel: second link', 'default' => 'knowledgebase.php'],
    ],
];
