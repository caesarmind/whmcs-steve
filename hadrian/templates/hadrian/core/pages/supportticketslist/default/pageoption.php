<?php
/**
 * Per-variant settings for supportticketslist/default.
 *
 * Read at runtime as $hadrian.pages.supportticketslist.config.<key>
 *
 * The variant just forwards to supporttickets/default/default.tpl, so the
 * actual rendering settings live on that page (this file exists only to
 * satisfy the PageController's variant-discovery contract).
 */
return [
    'display_name' => 'Default',
    'description'  => 'Forwarder to supporttickets/default — same Apple-style rows + filter sidebar.',
    'preview'      => 'thumb.png',
    'settings'     => [],
];
