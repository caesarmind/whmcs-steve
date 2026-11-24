<?php
/**
 * Questions sorted into categories. A row of tabs picks the category, and the
 * questions under it open on click.
 * Markup and classes: the theme's hp-faq-tabs-section block. The theme script
 * switches the tabs.
 */
return [
    'label'  => 'Questions by category',
    'hint'   => 'Tabs that sort questions by topic',
    'group'  => 'Questions',
    'order'  => 620,
    'fields' => [
        ['key' => 'title', 'type' => 'text', 'label' => 'Heading', 'translatable' => true, 'default' => ['_' => 'Answers by topic']],
        ['key' => 'subtitle', 'type' => 'text', 'label' => 'Subheading', 'translatable' => true, 'default' => ['_' => 'Choose a topic and open the question you came with.']],
        ['key' => 'items', 'type' => 'list', 'label' => 'Questions', 'max' => 40, 'itemLabel' => 'question', 'addLabel' => 'Add question',
            'help' => 'Questions that share a category appear under one tab. Tabs are shown in the order their names first appear.',
            'fields' => [
                ['key' => 'category', 'type' => 'text', 'label' => 'Category', 'translatable' => true, 'default' => ['_' => ''],
                    'help' => 'The name of the tab, typed the same way for every question in it. Leave empty to show the question under every tab.'],
                ['key' => 'question', 'type' => 'text', 'label' => 'Question', 'translatable' => true, 'default' => ['_' => 'New question']],
                ['key' => 'answer', 'type' => 'rich', 'label' => 'Answer', 'translatable' => true, 'default' => ['_' => '']],
            ],
            'default' => [
                ['category' => ['_' => 'Billing'], 'question' => ['_' => 'When am I charged?'],
                    'answer' => ['_' => '<p>On the day you order, then on the same date each period. The invoice reaches you by email a few days before it is due.</p>']],
                ['category' => ['_' => 'Billing'], 'question' => ['_' => 'Can I switch between monthly and yearly?'],
                    'answer' => ['_' => '<p>Yes. Change the billing cycle from your client area and the next invoice follows it.</p>']],
                ['category' => ['_' => 'Billing'], 'question' => ['_' => 'What if I want to cancel?'],
                    'answer' => ['_' => '<p>Send a cancellation request from your client area before the renewal date and you are not billed again.</p>']],
                ['category' => ['_' => 'Setup'], 'question' => ['_' => 'How soon is my account ready?'],
                    'answer' => ['_' => '<p>Usually a few minutes after payment. The login details arrive by email.</p>']],
                ['category' => ['_' => 'Setup'], 'question' => ['_' => 'Will you move my current site?'],
                    'answer' => ['_' => '<p>Yes. Open a ticket with the details of your old host and we copy the site across.</p>']],
                ['category' => ['_' => 'Domains'], 'question' => ['_' => 'Can I use a domain I already own?'],
                    'answer' => ['_' => '<p>Yes. Point its nameservers at us, or transfer it here and keep everything on one bill.</p>']],
                ['category' => ['_' => 'Domains'], 'question' => ['_' => 'How long does a transfer take?'],
                    'answer' => ['_' => '<p>Most finish within a week. Your site and email keep working while the domain moves.</p>']],
                ['category' => ['_' => 'Security'], 'question' => ['_' => 'Is an SSL certificate included?'],
                    'answer' => ['_' => '<p>Every site gets one at no charge, and it renews on its own.</p>']],
                ['category' => ['_' => 'Security'], 'question' => ['_' => 'How often do you take backups?'],
                    'answer' => ['_' => '<p>Every night. You can restore a copy yourself from the control panel.</p>']],
            ]],
    ],
];
