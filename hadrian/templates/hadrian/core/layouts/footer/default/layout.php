<?php
/**
 * Footer layout manifest. See main-menu/sidebar/layout.php for what is and is
 * not read at runtime.
 *
 * Footer dispatch is by directory NAME (footer.tpl builds the include path from
 * it), so no 'type' variable is needed; the templates hardcode their own
 * classes, so no 'footerClass' either. Both were dead, as were 'preview' and
 * 'order'.
 */
return [
    'displayName' => 'Default Footer',
    'description' => 'Single-row footer with copyright and basic links.',
];
