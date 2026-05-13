<?php
/**
 * Page-level metadata for the /submitticket.php URL.
 *
 * Forwards to the canonical supportticketsubmit implementation but exposes a
 * separate Pages-tab entry so admins can set variant, SEO and layout
 * overrides for this WHMCS templatefile independently.
 */
return [
    'display_name'   => 'Submit ticket (URL alias)',
    'group'          => 'Support',
    'type'           => 'public',
    'listDisplay'    => true,
    'description'    => 'WHMCS /submitticket.php — same multi-step form as supportticketsubmit.',
    'defaultVariant' => 'default',
];
