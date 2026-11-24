<?php
declare(strict_types=1);

namespace Hadrian\Helpers;

/**
 * Extension modules: separate WHMCS addons that build on Hadrian.
 *
 * Hadrian knows nothing about any particular one. An extension module calls
 * register() from its own hooks.php, and Hadrian's admin then:
 *   - shows a tab for it in the navigation (includes/header.tpl)
 *   - lists it on the Extensions page
 *
 * The registry is per request and holds no state of its own: an extension
 * that is deactivated in WHMCS stops loading its hooks.php, stops
 * registering, and its tab is gone on the next page load.
 *
 * Distinct from Template::getExtensions(), which lists theme extensions
 * shipped inside the theme folder and declared in theme.json.
 */
final class Extensions
{
    /** @var array<string, array<string,string>> */
    private static array $items = [];

    /**
     * @param array<string,mixed> $entry
     *        id          short slug, [a-z0-9-]; becomes the nav key "ext-<id>"
     *        label       the tab text
     *        url         where the tab goes: a same-page query string such as
     *                    "?module=HadrianEmail". Anything else is refused, so
     *                    an extension cannot point Hadrian's nav off-site.
     *        name        full name, for the Extensions page (defaults to label)
     *        description one line, for the Extensions page
     *        version     shown beside the name
     *        tab         false for a module with no screen of its own to open
     *                    (its pages live in Hadrian's Pages, say). It is still
     *                    listed on the Extensions page. Default true.
     */
    public static function register(array $entry): void
    {
        $id  = strtolower(trim((string)($entry['id'] ?? '')));
        $url = trim((string)($entry['url'] ?? ''));
        if (!preg_match('/^[a-z0-9][a-z0-9-]{0,30}$/', $id)) {
            return;
        }
        if (!preg_match('/^\?module=[A-Za-z0-9_]+(&[A-Za-z0-9_=&%.-]*)?$/', $url)) {
            return;
        }
        $label = trim((string)($entry['label'] ?? ''));
        if ($label === '') {
            return;
        }
        $cut = static fn(string $s, int $n): string => function_exists('mb_substr') ? mb_substr($s, 0, $n) : substr($s, 0, $n);

        self::$items[$id] = [
            'id'          => $id,
            'nav'         => 'ext-' . $id,
            'label'       => $cut($label, 24),
            'name'        => $cut(trim((string)($entry['name'] ?? '')) ?: $label, 60),
            'description' => $cut(trim((string)($entry['description'] ?? '')), 200),
            'version'     => $cut(trim((string)($entry['version'] ?? '')), 20),
            'url'         => $url,
            'tab'         => ($entry['tab'] ?? true) === false ? '0' : '1',
        ];
    }

    /** @return list<array<string,string>> in registration order */
    public static function all(): array
    {
        return array_values(self::$items);
    }
}
