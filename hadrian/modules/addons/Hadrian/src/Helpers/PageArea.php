<?php
declare(strict_types=1);

namespace Hadrian\Helpers;

/**
 * Which part of the site a page belongs to.
 *
 *   website  the marketing pages: homepage, store landing pages, custom pages
 *            and pages an extension module draws through the theme
 *   order    the order process: product listings, configuration, cart and
 *            checkout
 *   client   everything else: the portal a client signs in to, with its
 *            support and account pages
 *
 * A layout can be chosen per area (see LayoutPointers), so a site can run a
 * top bar on its website, a sidebar in the client area and a quieter frame
 * around checkout.
 *
 * A page states its area with an `area` key in its page.php. Without one the
 * area follows from what the page is, in the order forPage() checks.
 */
final class PageArea
{
    public const WEBSITE = 'website';
    public const CLIENT  = 'client';
    public const ORDER   = 'order';

    /** Area => label, in the order the admin shows them. */
    public const LABELS = [
        self::WEBSITE => 'Website',
        self::CLIENT  => 'Client area',
        self::ORDER   => 'Order process',
    ];

    /** One line each, for the admin. */
    public const HELP = [
        self::WEBSITE => 'Homepage, store landing pages, custom and built pages',
        self::CLIENT  => 'The portal: dashboard, billing, support, account',
        self::ORDER   => 'Product listings, configuration, cart and checkout',
    ];

    /** Page groups (page.php `group`) that are marketing pages. */
    private const WEBSITE_GROUPS = ['Public', 'Shop'];

    /**
     * Templates with no page.php of their own that still belong to the
     * website: a page body built by an extension module.
     */
    private const WEBSITE_TEMPLATES = ['module-page'];

    /**
     * @param string $templatefile what WHMCS is rendering ("clientareahome", "store/ox/index")
     * @param bool   $inCart       WHMCS says this request is part of an order
     *                             (its `inShoppingCart` template variable)
     * @param array<string,mixed> $pageMeta the page's page.php, [] when it has none
     */
    public static function forPage(string $templatefile, bool $inCart, array $pageMeta): string
    {
        // 1. What the page says about itself.
        $declared = is_string($pageMeta['area'] ?? null) ? $pageMeta['area'] : '';
        if (isset(self::LABELS[$declared])) {
            return $declared;
        }
        // 2. A theme page in a marketing group. Checked before the cart flag
        //    because WHMCS can raise that flag on a store landing page too,
        //    and a landing page is the website, not the checkout.
        if (in_array((string)($pageMeta['group'] ?? ''), self::WEBSITE_GROUPS, true)) {
            return self::WEBSITE;
        }
        // 3. The order form. Its steps (products, configureproduct, viewcart,
        //    checkout) are order-form templates with no page.php, served by
        //    cart.php or by /store/<group> routes, so neither a template name
        //    nor the script name covers them all. WHMCS's own flag does.
        if ($inCart) {
            return self::ORDER;
        }
        if (in_array($templatefile, self::WEBSITE_TEMPLATES, true)) {
            return self::WEBSITE;
        }
        return self::CLIENT;
    }

    public static function valid(string $area): bool
    {
        return isset(self::LABELS[$area]);
    }
}
