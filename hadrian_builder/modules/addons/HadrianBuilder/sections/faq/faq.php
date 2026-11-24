<?php
/**
 * Questions that open to show their answers.
 * Markup and classes: the theme's hp-faq-section block.
 */
return [
    'label'  => 'Questions and answers',
    'hint'   => 'A list of questions that open on click',
    'group'  => 'Questions',
    'order'  => 600,
    'fields' => [
        ['key' => 'title', 'type' => 'text', 'label' => 'Heading', 'translatable' => true, 'default' => ['_' => 'Questions, answered']],
        ['key' => 'subtitle', 'type' => 'text', 'label' => 'Subheading', 'translatable' => true, 'default' => ['_' => '']],
        ['key' => 'openFirst', 'type' => 'toggle', 'label' => 'Show the first answer open', 'default' => true],
        ['key' => 'items', 'type' => 'list', 'label' => 'Questions', 'max' => 30, 'itemLabel' => 'question', 'addLabel' => 'Add question',
            'fields' => [
                ['key' => 'question', 'type' => 'text', 'label' => 'Question', 'translatable' => true, 'default' => ['_' => 'New question']],
                ['key' => 'answer', 'type' => 'rich', 'label' => 'Answer', 'translatable' => true, 'default' => ['_' => '']],
            ],
            'default' => [
                ['question' => ['_' => 'Can I change plans later?'], 'answer' => ['_' => '<p>Yes. Upgrade or downgrade from your client area at any time and we adjust the bill for the days left.</p>']],
                ['question' => ['_' => 'Do you move my existing site?'], 'answer' => ['_' => '<p>Open a ticket after you order and we will move it for you.</p>']],
                ['question' => ['_' => 'Is there a contract?'], 'answer' => ['_' => '<p>No. You pay for the period you choose and can cancel before it renews.</p>']],
            ]],
    ],
];
