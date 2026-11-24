<?php
/**
 * Two panels side by side. The wide one has an eyebrow, a headline, a
 * paragraph, a link and a picture along its bottom edge. The narrow one has a
 * picture on top, then an icon, a title and a paragraph.
 * Markup and classes: the theme's hp-intel-duo block.
 */
return [
    'label'  => 'Two highlights',
    'hint'   => 'A wide panel beside a narrow one',
    'group'  => 'Features',
    'order'  => 380,
    'fields' => [
        ['key' => 'bigEyebrow', 'type' => 'text', 'label' => 'Wide panel: eyebrow', 'translatable' => true, 'default' => ['_' => 'Control panel']],
        ['key' => 'bigTitle', 'type' => 'text', 'label' => 'Wide panel: headline', 'translatable' => true, 'default' => ['_' => 'Everything in one place']],
        ['key' => 'bigLead', 'type' => 'text', 'label' => 'Wide panel: opening words', 'translatable' => true,
            'default' => ['_' => 'Domains, email, files and databases share one login.'],
            'help' => 'Shown in bold at the start of the paragraph.'],
        ['key' => 'bigText', 'type' => 'textarea', 'label' => 'Wide panel: text', 'translatable' => true,
            'default' => ['_' => 'Add a mailbox, point a domain or restore a backup without opening a ticket. Each job is a short form with a plain explanation beside it.']],
        ['key' => 'bigLinkLabel', 'type' => 'text', 'label' => 'Wide panel: link text', 'translatable' => true, 'default' => ['_' => 'See what is included']],
        ['key' => 'bigLink', 'type' => 'link', 'label' => 'Wide panel: link', 'default' => '#pricing'],
        ['key' => 'bigImage', 'type' => 'image', 'label' => 'Wide panel: image', 'default' => '',
            'help' => 'A wide screenshot works best. Without one the panel shows a plain block.'],
        ['key' => 'bigImageAlt', 'type' => 'text', 'label' => 'Wide panel: image description', 'translatable' => true, 'default' => ['_' => '']],
        ['key' => 'smallImage', 'type' => 'image', 'label' => 'Narrow panel: image', 'default' => ''],
        ['key' => 'smallImageAlt', 'type' => 'text', 'label' => 'Narrow panel: image description', 'translatable' => true, 'default' => ['_' => '']],
        ['key' => 'smallIcon', 'type' => 'icon', 'label' => 'Narrow panel: icon', 'default' => 'lock'],
        ['key' => 'smallTitle', 'type' => 'text', 'label' => 'Narrow panel: title', 'translatable' => true, 'default' => ['_' => 'Your data stays yours']],
        ['key' => 'smallText', 'type' => 'textarea', 'label' => 'Narrow panel: text', 'translatable' => true,
            'default' => ['_' => 'Backups are encrypted and logins can ask for a second step. What you store with us is yours.']],
    ],
];
