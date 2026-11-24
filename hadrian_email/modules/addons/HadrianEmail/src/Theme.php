<?php
declare(strict_types=1);

namespace HadrianEmail;

/**
 * Everything an email inherits from the site: colours, font, logo, company
 * name, social profiles. Read once per request and handed to the Renderer as a
 * plain array, so the Renderer itself never touches the database and can be
 * driven by a test with a hand-built array.
 */
final class Theme
{
    public const SETTINGS_KEY = 'appearance';

    /** File types every mainstream email client renders. SVG and WebP are not among them. */
    private const EMAIL_SAFE = ['png', 'jpg', 'jpeg', 'gif'];

    private const SOCIAL = [
        'x'         => 'X',
        'linkedin'  => 'LinkedIn',
        'facebook'  => 'Facebook',
        'instagram' => 'Instagram',
        'youtube'   => 'YouTube',
        'github'    => 'GitHub',
    ];

    private const SAFE_FONT = "-apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif";

    /** @var array<string,mixed>|null */
    private static ?array $memo = null;

    public static function forget(): void
    {
        self::$memo = null;
    }

    /** @return array<string,mixed> */
    public static function load(): array
    {
        if (self::$memo !== null) {
            return self::$memo;
        }
        $slug     = Bridge::templateSlug();
        $settings = self::settings();
        $origin   = Bridge::origin();
        $logo     = self::logos($settings, $origin);

        $social = [];
        foreach (self::SOCIAL as $key => $label) {
            $url = trim((string)Bridge::setting('footer_social_' . $key, ''));
            if ($url !== '' && preg_match('/^https?:\/\//i', $url)) {
                $social[] = ['label' => $label, 'url' => $url];
            }
        }

        return self::$memo = [
            'palette'   => Palette::resolve($slug),
            'font'      => self::font($slug),
            'company'   => trim((string)Bridge::config('CompanyName')) ?: 'Your company',
            'systemUrl' => Bridge::systemUrl(),
            'origin'    => $origin,
            'logo'      => $logo['urls'],
            'logoIssue' => $logo['issue'],
            'social'    => $social,
            'settings'  => $settings,
            'language'  => Bridge::defaultLanguage(),
        ];
    }

    /**
     * @return array{mode:string,logo:string,logoDark:string,width:int,radius:int,customCss:string}
     */
    public static function settings(): array
    {
        $raw = Store::get(self::SETTINGS_KEY, []);
        return self::normalizeSettings(is_array($raw) ? $raw : [], self::defaultMode());
    }

    /**
     * @param array<string,mixed> $raw
     * @return array{mode:string,logo:string,logoDark:string,width:int,radius:int,customCss:string}
     */
    public static function normalizeSettings(array $raw, string $defaultMode = 'auto'): array
    {
        $mode = (string)($raw['mode'] ?? '');
        $url  = static function (mixed $v): string {
            $v = is_scalar($v) ? trim((string)$v) : '';
            if ($v === '' || strlen($v) > 2000) {
                return '';
            }
            return (preg_match('/^https?:\/\//i', $v) || (str_starts_with($v, '/') && !str_starts_with($v, '//'))) ? $v : '';
        };
        $css = is_scalar($raw['customCss'] ?? null) ? (string)$raw['customCss'] : '';
        // The custom CSS lands inside a <style> element: a closing tag in it
        // would end the element and spill the rest into the email as markup.
        $css = str_ireplace(['</style', '<!--', '-->'], '', $css);

        return [
            'mode'      => in_array($mode, ['auto', 'light', 'dark'], true) ? $mode : $defaultMode,
            'logo'      => $url($raw['logo'] ?? ''),
            'logoDark'  => $url($raw['logoDark'] ?? ''),
            'width'     => max(480, min(720, (int)($raw['width'] ?? 600))),
            'radius'    => max(0, min(28, (int)($raw['radius'] ?? 16))),
            'customCss' => strlen($css) > 8000 ? substr($css, 0, 8000) : $css,
        ];
    }

    /**
     * Follow the client area's own dark-mode setting until the admin picks
     * something for email: a site locked to dark sends dark email, a site
     * locked to light sends light, and a site with a switcher lets each
     * recipient's device decide.
     */
    private static function defaultMode(): string
    {
        if ((string)Bridge::setting('dark_mode_display', 'switcher') !== 'forced') {
            return 'auto';
        }
        return (string)Bridge::setting('dark_mode_default', 'light') === 'dark' ? 'dark' : 'light';
    }

    /**
     * @param array<string,mixed> $settings
     * @return array{urls: array{light:string,dark:string}, issue:string}
     */
    private static function logos(array $settings, string $origin): array
    {
        $abs = static function (string $url) use ($origin): string {
            if ($url === '' || preg_match('/^https?:\/\//i', $url)) {
                return $url;
            }
            return $origin . $url;
        };
        $safe = static function (string $url): bool {
            $ext = strtolower(pathinfo((string)parse_url($url, PHP_URL_PATH), PATHINFO_EXTENSION));
            return in_array($ext, self::EMAIL_SAFE, true);
        };

        $issue = '';
        $pick  = static function (string $own, string $brandKey) use ($abs, $safe, &$issue): string {
            if ($own !== '') {
                if ($safe($own)) {
                    return $abs($own);
                }
                $issue = 'The email logo must be a PNG, JPG or GIF. Gmail and Outlook do not show SVG or WebP.';
                return '';
            }
            // The logo uploaded on Hadrian's Branding page.
            $url = Bridge::brandLogo($brandKey);
            if ($url === '') {
                return '';
            }
            if ($safe($url)) {
                return $abs($url);
            }
            $issue = 'Your site logo is an SVG or WebP file, which Gmail and Outlook do not show. Emails use your company name as text until you set a PNG email logo.';
            return '';
        };

        $light = $pick((string)$settings['logo'], 'logo_light');
        $dark  = $pick((string)$settings['logoDark'], 'logo_dark');
        return ['urls' => ['light' => $light !== '' ? $light : $dark, 'dark' => $dark], 'issue' => $issue];
    }

    /**
     * The site's font stack, reduced to what is safe inside a double-quoted
     * style attribute. No web font is loaded: most clients drop the request
     * and the ones that honour it tell Google every time the email is opened.
     * The named family still wins wherever the recipient has it installed.
     */
    private static function font(string $slug): string
    {
        $stored = Bridge::setting($slug . '_typography', null);
        $ff     = is_array($stored) && is_array($stored['fontFamily'] ?? null) ? $stored['fontFamily'] : [];
        $stack  = trim((string)preg_replace('/[^A-Za-z0-9 ,\'\-]/', '', (string)($ff['stack'] ?? '')));

        if ($stack === '' && ($ff['mode'] ?? '') === 'google' && !empty($ff['google'])) {
            $name  = trim((string)preg_replace('/[^A-Za-z0-9 ]/', '', (string)$ff['google']));
            $stack = $name !== '' ? "'" . $name . "'" : '';
        }
        if ($stack === '') {
            return self::SAFE_FONT;
        }
        // system-ui is not understood by Outlook, which then falls back to
        // Times New Roman. Always end on the safe stack.
        $stack = trim((string)preg_replace('/\b(system-ui|sans-serif)\b\s*,?/i', '', $stack), " ,");
        return $stack === '' ? self::SAFE_FONT : $stack . ', ' . self::SAFE_FONT;
    }

    /** True for a WHMCS language name that is written right to left. */
    public static function isRtl(string $language): bool
    {
        return in_array(strtolower(trim($language)), ['arabic', 'farsi', 'persian', 'hebrew', 'urdu', 'kurdish', 'pashto', 'sindhi', 'uyghur', 'yiddish', 'dhivehi'], true);
    }
}
