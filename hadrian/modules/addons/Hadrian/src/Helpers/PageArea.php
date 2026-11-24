<?php
declare(strict_types=1);

namespace Hadrian\Helpers;

/**
 * Which part of the site a page belongs to.
 *
 *   website  what a visitor sees before signing in: the homepage, store
 *            landing pages, custom and built pages, sign-in and registration,
 *            the knowledgebase and announcements
 *   order    the order process: product listings, configuration, cart and
 *            checkout
 *   client   everything else: the portal a client signs in to, with its
 *            billing, support and account pages
 *
 * A layout can be chosen per area (see LayoutPointers), so a site can run a
 * top bar on its website, a sidebar in the client area and a quieter frame
 * around checkout.
 *
 * An admin can place a page in an area from the page editor. Failing that a
 * page states its area with an `area` key in its page.php, and failing that
 * the area follows from what the page is, in the order forPage() checks.
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
        self::WEBSITE => 'Homepage, store landing pages, built pages, sign-in, knowledgebase and announcements',
        self::CLIENT  => 'The portal: dashboard, billing, support, account',
        self::ORDER   => 'Product listings, configuration, cart and checkout',
    ];

    /**
     * Page groups (page.php `group`) a visitor meets before signing in:
     * marketing pages, and the sign-in, registration and password-reset
     * pages. A guest on the login page is still on the website; giving them
     * the portal's frame there is what choosing layouts by area is meant to
     * avoid.
     */
    private const WEBSITE_GROUPS = ['Public', 'Shop', 'Authentication'];

    /**
     * Templates with no page.php of their own that still belong to the
     * website: a page body built by an extension module, and WHMCS's two
     * "no such address" pages, which a visitor reaches from a mistyped link.
     */
    private const WEBSITE_TEMPLATES = ['module-page', 'error/page-not-found', 'error/unknown-routepath'];

    /**
     * @param string $templatefile what WHMCS is rendering ("clientareahome", "store/ox/index")
     * @param bool   $inCart       WHMCS says this request is part of an order
     *                             (its `inShoppingCart` template variable)
     * @param array<string,mixed> $pageMeta the page's page.php, [] when it has none
     * @param string $override     the area an admin picked for this page, '' for none
     */
    public static function forPage(string $templatefile, bool $inCart, array $pageMeta, string $override = ''): string
    {
        // 1. What the admin decided for this page.
        if (isset(self::LABELS[$override])) {
            return $override;
        }
        // 2. What the page says about itself.
        $declared = is_string($pageMeta['area'] ?? null) ? $pageMeta['area'] : '';
        if (isset(self::LABELS[$declared])) {
            return $declared;
        }
        // 3. A theme page in a group visitors meet before signing in. Checked
        //    before the cart flag because WHMCS can raise that flag on a
        //    store landing page too, and a landing page is the website, not
        //    the checkout.
        if (in_array((string)($pageMeta['group'] ?? ''), self::WEBSITE_GROUPS, true)) {
            return self::WEBSITE;
        }
        // 4. The order form. Its steps (products, configureproduct, viewcart,
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
