<?php
/**
 * A comparison table: WHMCS products across the top, feature rows down the
 * side. The name, price and order link of each column come from the product;
 * the rows are written here, one value per column.
 * Markup and classes: the theme's hp-pricing-compare-table block. The theme
 * script folds a group of rows when its heading is clicked.
 */
return [
    'label'  => 'Plan comparison table',
    'hint'   => 'Products as columns, features as rows',
    'group'  => 'Pricing',
    'order'  => 250,
    'fields' => [
        ['key' => 'title', 'type' => 'text', 'label' => 'Heading', 'translatable' => true, 'default' => ['_' => 'Compare the plans']],
        ['key' => 'subtitle', 'type' => 'text', 'label' => 'Subheading', 'translatable' => true,
            'default' => ['_' => 'See what each plan includes before you choose.']],
        ['key' => 'plans', 'type' => 'list', 'label' => 'Columns', 'max' => 4, 'itemLabel' => 'product', 'addLabel' => 'Add column',
            'fields' => [
                ['key' => 'product', 'type' => 'product', 'label' => 'Product', 'default' => 0,
                    'help' => 'The column takes its name, price and order link from this product.'],
                ['key' => 'highlight', 'type' => 'toggle', 'label' => 'Highlight this column', 'default' => false],
                ['key' => 'badge', 'type' => 'text', 'label' => 'Ribbon', 'translatable' => true, 'default' => ['_' => ''],
                    'help' => 'A short label above the plan name, for example "Most popular".'],
            ],
            'default' => []],
        ['key' => 'buttonLabel', 'type' => 'text', 'label' => 'Button text', 'translatable' => true, 'default' => ['_' => 'Order now']],
        ['key' => 'freeLabel', 'type' => 'text', 'label' => 'Shown for a free product', 'translatable' => true, 'default' => ['_' => 'Free']],
        ['key' => 'rows', 'type' => 'list', 'label' => 'Rows', 'max' => 40, 'itemLabel' => 'label', 'addLabel' => 'Add row',
            'fields' => [
                ['key' => 'label', 'type' => 'text', 'label' => 'Feature', 'translatable' => true, 'default' => ['_' => 'New feature']],
                ['key' => 'group', 'type' => 'text', 'label' => 'Group', 'translatable' => true, 'default' => ['_' => ''],
                    'help' => 'Rows that follow each other with the same group sit under one heading a visitor can fold. Leave empty for no heading.'],
                ['key' => 'values', 'type' => 'lines', 'label' => 'Values', 'translatable' => true, 'default' => ['_' => ''],
                    'help' => 'One line per column, in column order. Write yes for a check mark, no or - for a dash; anything else shows as text.'],
                ['key' => 'tip', 'type' => 'text', 'label' => 'Explanation', 'translatable' => true, 'default' => ['_' => ''],
                    'help' => 'Optional. Shown when a visitor points at the small "i" beside the feature.'],
            ],
            'default' => [
                ['label' => ['_' => 'Storage'], 'group' => ['_' => 'Resources'], 'values' => ['_' => "10 GB\n50 GB\n100 GB"],
                    'tip' => ['_' => 'Space for your files, mail and databases.']],
                ['label' => ['_' => 'Websites'], 'group' => ['_' => 'Resources'], 'values' => ['_' => "1\n10\nUnlimited"], 'tip' => ['_' => '']],
                ['label' => ['_' => 'Email accounts'], 'group' => ['_' => 'Resources'], 'values' => ['_' => "5\n50\nUnlimited"], 'tip' => ['_' => '']],
                ['label' => ['_' => 'Free SSL certificate'], 'group' => ['_' => 'Security'], 'values' => ['_' => "yes\nyes\nyes"], 'tip' => ['_' => '']],
                ['label' => ['_' => 'Daily backups'], 'group' => ['_' => 'Security'], 'values' => ['_' => "no\nyes\nyes"],
                    'tip' => ['_' => 'A copy of your site is saved every night.']],
                ['label' => ['_' => 'Malware scanning'], 'group' => ['_' => 'Security'], 'values' => ['_' => "no\nyes\nyes"], 'tip' => ['_' => '']],
                ['label' => ['_' => 'Ticket support'], 'group' => ['_' => 'Support'], 'values' => ['_' => "yes\nyes\nyes"], 'tip' => ['_' => '']],
                ['label' => ['_' => 'Live chat'], 'group' => ['_' => 'Support'], 'values' => ['_' => "no\nyes\nyes"], 'tip' => ['_' => '']],
                ['label' => ['_' => 'Phone support'], 'group' => ['_' => 'Support'], 'values' => ['_' => "no\nno\nyes"], 'tip' => ['_' => '']],
            ]],
        ['key' => 'featuresLabel', 'type' => 'text', 'label' => 'Name of the first column', 'translatable' => true, 'default' => ['_' => 'Features'],
            'help' => 'Not shown on the page. Read aloud by screen readers.'],
        ['key' => 'yesLabel', 'type' => 'text', 'label' => 'Meaning of the check mark', 'translatable' => true, 'default' => ['_' => 'Included'],
            'help' => 'Not shown on the page. Read aloud by screen readers.'],
        ['key' => 'noLabel', 'type' => 'text', 'label' => 'Meaning of the dash', 'translatable' => true, 'default' => ['_' => 'Not included'],
            'help' => 'Not shown on the page. Read aloud by screen readers.'],
    ],
];
