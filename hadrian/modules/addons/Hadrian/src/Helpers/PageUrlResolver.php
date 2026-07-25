<?php
declare(strict_types=1);

namespace Hadrian\Helpers;

use Hadrian\Menu\WhmcsDefaults;

/**
 * Resolve a theme page name to the public client-area URL that renders it,
 * so the admin can open the real page in a new tab.
 *
 * The guiding rule is NEVER SHOW A BROKEN LINK. Of the theme's 102 pages only
 * about half have a standalone address: the rest either need a record id
 * (clientareaproductdetails without &id= is an error, not a page), are one
 * step inside a multi-step flow (password-reset-security-prompt), or are not
 * routed at all (markdown-guide). For those this returns no URL and a short
 * reason the view can show instead, rather than a link that 404s.
 *
 * Deliberately does NOT reuse Menu\TreeRenderer::resolvePageUrl(). That method
 * is correct for its own caller but returns three different KINDS of string
 * indistinguishably — a verbatim admin value, an install-relative
 * WhmcsDefaults value ('store/sitelock'), and an already-WEB_ROOT-prefixed
 * routePath() value — so no single base-prefixing rule can be applied to its
 * output. Getting that wrong sends 13 store/* pages to /admin/store/... and a
 * subdirectory install to a doubled prefix. This class does its own
 * source-aware lookup and tracks which kind it produced. TreeRenderer is not
 * touched, so client-area menu rendering carries zero risk from this feature.
 */
final class PageUrlResolver
{
    /**
     * Page dirs that are ALSO real WHMCS route names AND render a complete
     * page with no parameters.
     *
     * An allowlist rather than "whatever routePath() resolves": routePath()
     * confirms a route EXISTS, not that a bare GET renders anything useful.
     * 'upgrade' is a registered route whose bare URL has no service to act on.
     * The sentinel check below is then a second net, for names that are not
     * registered on a given install.
     *
     * @var list<string>
     */
    private const ROUTE_PAGES = [
        'account-contacts-new',
        'account-paymentmethods-billing-contacts',
        'domain-pricing',
        'user-profile',
        'user-security',
    ];

    /**
     * Pages that are real but only work with a record id. Rendered as an
     * explanation, NEVER as a link. Braces are placeholders for the admin to
     * read, not Smarty tags.
     *
     * @var array<string,string>
     */
    private const NEEDS_PARAM = [
        'account-paymentmethods-manage'   => 'index.php/account/paymentmethods/{id}',
        'account-user-permissions'        => 'index.php/account/users/{id}/permissions',
        'clientareacancelrequest'         => 'clientarea.php?action=cancel&id={serviceId}',
        'clientareadomainaddons'          => 'clientarea.php?action=domainaddons&id={domainId}',
        'clientareadomaincontactinfo'     => 'clientarea.php?action=domaincontacts&domainid={domainId}',
        'clientareadomaindetails'         => 'clientarea.php?action=domaindetails&id={domainId}',
        'clientareadomaindns'             => 'clientarea.php?action=domaindns&domainid={domainId}',
        'clientareadomainemailforwarding' => 'clientarea.php?action=domainemailforwarding&domainid={domainId}',
        'clientareadomaingetepp'          => 'clientarea.php?action=getepp&id={domainId}',
        'clientareadomainregisterns'      => 'clientarea.php?action=registerns&id={domainId}',
        'clientareaproductdetails'        => 'clientarea.php?action=productdetails&id={serviceId}',
        'downloadscat'                    => 'downloads.php?action=displaycat&catid={catId}',
        'invoice-payment'                 => 'viewinvoice.php?id={invoiceId}',
        'knowledgebasearticle'            => 'knowledgebase.php?action=displayarticle&id={articleId}',
        'knowledgebasecat'                => 'knowledgebase.php?action=displaycat&catid={catId}',
        'subscription-manage'             => 'index.php/account/subscriptions/{id}',
        'viewannouncement'                => 'announcements.php?id={announcementId}',
        'viewemail'                       => 'clientarea.php?action=emails&id={emailId}',
        'viewinvoice'                     => 'viewinvoice.php?id={invoiceId}',
        'viewquote'                       => 'viewquote.php?id={quoteId}',
        'viewticket'                      => 'viewticket.php?tid={ticketId}&c={key}',
    ];

    /**
     * Resolve one page.
     *
     * @param string $page    theme page dir name
     * @param string $stored  the admin's "Public URL" field for this page
     * @param string $visibility  public | auth | disabled
     * @return array{url:string, source:string, reason:string}
     *         url    '' when nothing safe could be resolved
     *         source custom | whmcs | route | ''
     *         reason short human explanation when url is '' (else '')
     */
    public static function resolve(string $page, string $stored = '', string $visibility = 'public'): array
    {
        // Beats every other step, including the admin's own field: the editor
        // labels this option "Disabled (404)", so a link is by definition a
        // link to an error page.
        if ($visibility === 'disabled') {
            return self::none('Not linked - visibility is set to Disabled (404).');
        }

        // 1. The admin's own Public URL. It wins because it is the only
        //    possible answer for custom pages, and because it is ALREADY the
        //    published contract - SitemapGenerator emits this exact value.
        $custom = self::sanitize($stored);
        if ($custom !== '') {
            return ['url' => self::absolutise($custom), 'source' => 'custom', 'reason' => ''];
        }

        // 2. The WhmcsDefaults table - code-verified, the documented single
        //    source of truth for templatefile -> URL.
        $def = WhmcsDefaults::lookup($page);
        $defUrl = is_array($def) ? trim((string)($def['url'] ?? '')) : '';
        if ($defUrl !== '') {
            return ['url' => self::absolutise($defUrl), 'source' => 'whmcs', 'reason' => ''];
        }

        // 3. Allowlisted named routes. routePath() output is already
        //    root-absolute and subdirectory-correct, so it must NOT be passed
        //    through absolutise() or the prefix is written twice.
        if (in_array($page, self::ROUTE_PAGES, true) && function_exists('routePath')) {
            try {
                $resolved = (string)routePath($page);
                if ($resolved !== '' && !str_contains($resolved, 'route-not-defined')) {
                    return ['url' => $resolved, 'source' => 'route', 'reason' => ''];
                }
            } catch (\Throwable $e) {
                // fall through to "no link" - never a guessed href
            }
        }

        // 4. Nothing certain. Explain why rather than guessing a path.
        $shape = self::NEEDS_PARAM[$page] ?? '';
        if ($shape !== '') {
            return self::none('Needs a record in the URL (' . $shape . '), so there is no single address for it.');
        }
        return self::none('No public URL - this template is reached from inside another page, not by its own address.');
    }

    /** @return array{url:string, source:string, reason:string} */
    private static function none(string $reason): array
    {
        return ['url' => '', 'source' => '', 'reason' => $reason];
    }

    /**
     * Prefix WEB_ROOT. Applies ONLY to install-relative values (the admin
     * field and the WhmcsDefaults table) - 13 of those are 'store/...', which
     * without this resolve against /admin/addonmodules.php and 404.
     * ltrim also normalises the table's lone 'homepage' => '/' entry, which
     * would otherwise concatenate into '//'.
     */
    private static function absolutise(string $url): string
    {
        if (preg_match('~^https?://~i', $url)) {
            return $url;
        }
        $base = defined('WEB_ROOT') ? rtrim((string)WEB_ROOT, '/') : '';
        return $base . '/' . ltrim($url, '/');
    }

    /**
     * The stored value is admin-typed free text saved with no scheme check
     * (PagesController::saveAction only trims, caps at 255 and strips a
     * leading slash), and it is about to land in an href. Smarty's |escape is
     * htmlspecialchars: it neutralises quotes but does nothing to a
     * javascript: or data: scheme. So whitelist here, and return '' on
     * anything suspicious so resolution falls through to the next step.
     */
    private static function sanitize(string $raw): string
    {
        $u = trim($raw);
        if ($u === '') {
            return '';
        }
        if (str_starts_with($u, '//')) {
            return '';                                  // protocol-relative
        }
        if (preg_match('~[\s<>"\'\\\\]~', $u)) {
            return '';                                  // whitespace or markup
        }
        if (preg_match('~^[a-z][a-z0-9+.\-]*:~i', $u)) {
            return preg_match('~^https?://~i', $u) ? $u : '';   // scheme: http(s) only
        }
        return $u;                                      // plain relative path
    }
}
