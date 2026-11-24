<?php
/**
 * Questions and their answers as a two-column grid of cards, all in view at
 * once.
 * Markup and classes: the theme's hp-faq-grid block.
 */
return [
    'label'  => 'Questions, card grid',
    'hint'   => 'Short answers in a grid of cards',
    'group'  => 'Questions',
    'order'  => 610,
    'fields' => [
        ['key' => 'title', 'type' => 'text', 'label' => 'Heading', 'translatable' => true, 'default' => ['_' => 'Before you order']],
        ['key' => 'items', 'type' => 'list', 'label' => 'Questions', 'max' => 12, 'itemLabel' => 'question', 'addLabel' => 'Add question',
            'help' => 'Two to a row. Short answers keep the cards level.',
            'fields' => [
                ['key' => 'question', 'type' => 'text', 'label' => 'Question', 'translatable' => true, 'default' => ['_' => 'New question']],
                ['key' => 'answer', 'type' => 'rich', 'label' => 'Answer', 'translatable' => true, 'default' => ['_' => '']],
            ],
            'default' => [
                ['question' => ['_' => 'Which control panel do I get?'], 'answer' => ['_' => '<p>Every plan comes with one panel for files, email, databases and domains.</p>']],
                ['question' => ['_' => 'Can I host more than one site?'], 'answer' => ['_' => '<p>Yes, on every plan above the smallest. Add a domain and it is ready.</p>']],
                ['question' => ['_' => 'Do you keep backups?'], 'answer' => ['_' => '<p>We take one every night and keep two weeks of them.</p>']],
                ['question' => ['_' => 'How do I reach support?'], 'answer' => ['_' => '<p>Open a ticket from your client area at any hour. A person answers.</p>']],
            ]],
    ],
];
