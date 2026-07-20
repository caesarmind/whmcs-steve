<?php
declare(strict_types=1);

namespace Hadrian\Menu;

use Hadrian\Template\Template;

/**
 * Which registered pages the menu-item page picker offers.
 *
 * WHY THIS EXISTS
 * The theme registers ~100 pages, but most are not places you would ever send a
 * visitor from a navigation menu: error screens, interstitials, wizard steps and
 * per-record detail views. Offering all of them made the picker long, made most
 * choices have no WHMCS language variable to link to, and buried the ~35 pages
 * an admin actually wants.
 *
 * Lagom solves this the same way: its core/config/routing/routes.json is a
 * curated whitelist of 42 destinations, and it simply never offers the rest.
 * ELIGIBLE below is the Hadrian equivalent, built from Lagom's list intersected
 * with the pages this theme actually registers, plus the destinations Lagom
 * reaches by other means.
 *
 * NOT included from Lagom's list, deliberately: viewcart, products, addons,
 * domainregister, domaintransfer, domain-renewals, service-renewals. Those live
 * in the separate hadrian_cart order form, not in core/pages, so here they are
 * Custom Link items rather than page links.
 *
 * THE FULL LIST IS NOT LOST. all() returns every registered page and is the
 * method to use for anything that legitimately needs the complete set -- the
 * Pages manager, the sitemap generator, per-page settings, or a future picker
 * that wants an "show everything" escape hatch. Curation applies to the MENU
 * picker only.
 */
final class MenuPages
{
    /**
     * Menu-worthy destinations, by slug. Order is irrelevant; grouping and
     * sorting still come from the page meta.
     */
    public const ELIGIBLE = [
        // Public / marketing
        'homepage',
        'contact',
        'announcements',
        'knowledgebase',
        'downloads',
        'serverstatus',
        'domain-pricing',

        // Authentication
        'login',
        'clientregister',
        'password-reset-container',

        // Client area
        'clientareahome',
        'clientareaproducts',
        'clientareadomains',
        'clientareaquotes',
        'bulkdomainmanagement',
        'managessl',

        // Billing
        'clientareainvoices',
        'clientareaaddfunds',
        'masspay',
        'subscription-manage',

        // Account
        'clientareadetails',
        'clientareacontacts',
        'clientareausers',
        'clientareaemails',
        'clientareasecurity',
        'account-contacts-manage',
        'account-contacts-new',
        'account-paymentmethods',
        'account-user-management',
        'user-profile',
        'user-security',
        'user-password',
        'user-switch-account',

        // Support
        'supporttickets',
        'supportticketslist',
        'submitticket',
        'supportticketsubmit',

        // Affiliates
        'affiliates',
        'affiliatessignup',
    ];

    /** True when this slug should appear in the menu-item page picker. */
    public static function isEligible(string $page): bool
    {
        return in_array($page, self::ELIGIBLE, true);
    }

    /**
     * Every page meta the template registers, unfiltered.
     * Kept deliberately -- see the class docblock. Use this, not ELIGIBLE, when
     * a feature genuinely needs the complete set.
     */
    public static function all(Template $template): array
    {
        return $template->getAllPageMeta();
    }

    /**
     * Page meta for the menu picker: the curated set, intersected with what this
     * template actually registers, so a slug listed here but absent from the
     * theme is skipped rather than rendering a dead tile.
     */
    public static function forPicker(Template $template): array
    {
        $out = [];
        foreach (self::all($template) as $meta) {
            if (self::isEligible((string)($meta['name'] ?? ''))) {
                $out[] = $meta;
            }
        }
        return $out;
    }
}
