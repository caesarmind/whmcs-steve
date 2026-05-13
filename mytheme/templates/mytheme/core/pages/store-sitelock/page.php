<?php
/**
 * Page-level metadata for the SiteLock VPN bundle landing.
 *
 * Currently mounted at /store/sitelock (the slug name). Nexus treats
 * SiteLock (plain) and SiteLock-VPN as two distinct routes
 * (store/sitelock vs store/sitelockvpn). When you want Nexus parity,
 * rename this directory to store-sitelockvpn and create a new
 * store-sitelock for the plain SiteLock landing.
 */
return [
    'display_name'   => 'SiteLock VPN',
    'group'          => 'Shop',
    'type'           => 'public',
    'listDisplay'    => true,
    'description'    => 'MarketConnect landing — SiteLock VPN bundle (secure browsing + malware protection, 3 plan tiers).',
    'defaultVariant' => 'default',
    'seoDefaults'    => [
        'indexing'    => 'allow',
        'title'       => 'SiteLock VPN — Secure browsing & malware protection',
        'description' => 'Browse securely on any network with SiteLock VPN — AES-256 encryption, malware protection, global server network and kill switch.',
    ],
];
