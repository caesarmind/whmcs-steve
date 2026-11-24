<?php
declare(strict_types=1);

namespace HadrianBuilder;

/**
 * The icons a section can show. Line icons on a 24x24 grid, drawn with
 * currentColor so the theme's icon tiles colour them.
 *
 * The set is closed on purpose: an icon is chosen by name, and only markup
 * from this file is ever printed. An admin cannot paste SVG.
 */
final class Icons
{
    /** name => [label, inner SVG markup] */
    private const SET = [
        'globe'    => ['Globe', '<circle cx="12" cy="12" r="9"/><path d="M3 12h18"/><path d="M12 3c2.5 2.6 3.8 5.6 3.8 9s-1.3 6.4-3.8 9c-2.5-2.6-3.8-5.6-3.8-9S9.5 5.6 12 3z"/>'],
        'shield'   => ['Shield', '<path d="M12 3l8 3v6c0 4.5-3.2 7.8-8 9-4.8-1.2-8-4.5-8-9V6z"/>'],
        'lock'     => ['Lock', '<rect x="5" y="11" width="14" height="10" rx="2"/><path d="M8 11V7.5a4 4 0 018 0V11"/>'],
        'bolt'     => ['Bolt', '<path d="M13 2L4 14h7l-1 8 9-12h-7z"/>'],
        'clock'    => ['Clock', '<circle cx="12" cy="12" r="9"/><path d="M12 7v5l3 2"/>'],
        'server'   => ['Server', '<rect x="3" y="4" width="18" height="7" rx="2"/><rect x="3" y="13" width="18" height="7" rx="2"/><path d="M7 7.5h.01M7 16.5h.01"/>'],
        'cloud'    => ['Cloud', '<path d="M7 18a4.5 4.5 0 01-.5-8.970A6 6 0 0118 10.5 3.750 3.750 0 0117.5 18z"/>'],
        'mail'     => ['Mail', '<rect x="3" y="5" width="18" height="14" rx="2"/><path d="M3 7l9 6 9-6"/>'],
        'users'    => ['People', '<circle cx="9" cy="8" r="3.5"/><path d="M2.5 20a6.5 6.5 0 0113 0"/><path d="M16 4.8a3.5 3.5 0 010 6.4"/><path d="M18 14.5a6.5 6.5 0 013.5 5.5"/>'],
        'chart'    => ['Chart', '<path d="M4 20V10"/><path d="M10 20V4"/><path d="M16 20v-7"/><path d="M22 20H2"/>'],
        'activity' => ['Activity', '<path d="M2 12h4l3 8 6-16 3 8h4"/>'],
        'check'    => ['Check', '<circle cx="12" cy="12" r="9"/><path d="M8 12.5l3 3 5-6"/>'],
        'star'     => ['Star', '<path d="M12 3l2.7 5.6 6.1.900-4.4 4.3 1 6.1L12 17l-5.4 2.9 1-6.1L3.2 9.5l6.1-.9z"/>'],
        'heart'    => ['Heart', '<path d="M12 20s-7.5-4.6-7.5-10.2A4.3 4.3 0 0112 7.2a4.3 4.3 0 017.5 2.6C19.5 15.4 12 20 12 20z"/>'],
        'phone'    => ['Device', '<rect x="6" y="2" width="12" height="20" rx="2.5"/><path d="M11 18h2"/>'],
        'calendar' => ['Calendar', '<rect x="3" y="5" width="18" height="16" rx="2"/><path d="M3 10h18M8 3v4M16 3v4"/>'],
        'code'     => ['Code', '<path d="M8 7l-5 5 5 5"/><path d="M16 7l5 5-5 5"/><path d="M13.5 5l-3 14"/>'],
        'database' => ['Database', '<ellipse cx="12" cy="6" rx="8" ry="3"/><path d="M4 6v6c0 1.7 3.6 3 8 3s8-1.3 8-3V6"/><path d="M4 12v6c0 1.7 3.6 3 8 3s8-1.3 8-3v-6"/>'],
        'support'  => ['Support', '<circle cx="12" cy="12" r="9"/><circle cx="12" cy="12" r="3.5"/><path d="M5.6 5.6l4 4M14.4 14.4l4 4M18.4 5.6l-4 4M9.6 14.4l-4 4"/>'],
        'rocket'   => ['Rocket', '<path d="M12 15l-3-3c1-4.5 4-8 9-9 -1 5-4.5 8-9 9z"/><path d="M9 12l-4 1 2 2M12 15l-1 4-2-2"/><circle cx="14.5" cy="9.5" r="1.2"/>'],
    ];

    /** @return array<string,string> name => label, for the editor's picker */
    public static function options(): array
    {
        $out = [];
        foreach (self::SET as $name => $def) {
            $out[$name] = $def[0];
        }
        return $out;
    }

    public static function has(string $name): bool
    {
        return isset(self::SET[$name]);
    }

    /** Complete <svg> markup for one icon, or '' for an unknown name. */
    public static function svg(string $name): string
    {
        if (!isset(self::SET[$name])) {
            return '';
        }
        return '<svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"'
            . ' stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">' . self::SET[$name][1] . '</svg>';
    }

    /** @return array<string,string> name => svg, for the editor's picker */
    public static function all(): array
    {
        $out = [];
        foreach (array_keys(self::SET) as $name) {
            $out[$name] = self::svg($name);
        }
        return $out;
    }
}
