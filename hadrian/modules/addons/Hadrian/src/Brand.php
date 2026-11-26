<?php
declare(strict_types=1);

namespace Hadrian;

/**
 * Who makes Hadrian and where its links point. Change a value here and every
 * place that shows it follows:
 *
 *   - System Settings -> Addon Modules: author and "Learn more" (Hadrian.php),
 *     and the author of Hadrian Email Templates and Hadrian Page Builder
 *   - the admin header: vendor name, Docs and Report bug links
 *     (views/adminarea/includes/header.tpl, as {$mtBrand.*})
 *   - the license banner's Renew button (license/banner.tpl)
 *   - "author" in templates/hadrian/theme.json, written by
 *     hadrian/scripts/package.mjs when it builds a release
 *
 * Not covered: includes/doclink.tpl and includes/tip.tpl keep the docs URL as
 * a literal on purpose (the .dashbuild harnesses render them without
 * controller variables; their header comments say why).
 */
final class Brand
{
    public const VENDOR      = 'Caesarthemes';
    public const VENDOR_URL  = 'https://caesarthemes.com/';
    public const PRODUCT_URL = 'https://caesarthemes.com/hadrian/';
    public const DOCS_URL    = 'https://docs.hadrianthegreat.com/';
    public const ACCOUNT_URL = 'https://your-domain.com/my-account/';
    public const BUGS_URL    = 'https://github.com/hostnodes/issues';

    /** For Smarty: assigned as $mtBrand on every admin view. */
    public static function toArray(): array
    {
        return [
            'vendor'     => self::VENDOR,
            'vendorUrl'  => self::VENDOR_URL,
            'productUrl' => self::PRODUCT_URL,
            'docsUrl'    => self::DOCS_URL,
            'accountUrl' => self::ACCOUNT_URL,
            'bugsUrl'    => self::BUGS_URL,
        ];
    }

    /** The author cell on System Settings -> Addon Modules (HTML). */
    public static function authorHtml(): string
    {
        return '<a href="' . htmlspecialchars(self::VENDOR_URL) . '" target="_blank" rel="noopener">'
            . htmlspecialchars(self::VENDOR) . '</a>';
    }
}
