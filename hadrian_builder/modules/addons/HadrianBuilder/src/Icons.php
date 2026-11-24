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
        'star'     => ['Star', '<path d="M12 3l2.7 5.6 6.1.9-4.4 4.3 1 6.1L12 17l-5.4 2.9 1-6.1L3.2 9.5l6.1-.9z"/>'],
        'heart'    => ['Heart', '<path d="M12 20s-7.5-4.6-7.5-10.2A4.3 4.3 0 0112 7.2a4.3 4.3 0 017.5 2.6C19.5 15.4 12 20 12 20z"/>'],
        'phone'    => ['Device', '<rect x="6" y="2" width="12" height="20" rx="2.5"/><path d="M11 18h2"/>'],
        'calendar' => ['Calendar', '<rect x="3" y="5" width="18" height="16" rx="2"/><path d="M3 10h18M8 3v4M16 3v4"/>'],
        'code'     => ['Code', '<path d="M8 7l-5 5 5 5"/><path d="M16 7l5 5-5 5"/><path d="M13.5 5l-3 14"/>'],
        'database' => ['Database', '<ellipse cx="12" cy="6" rx="8" ry="3"/><path d="M4 6v6c0 1.7 3.6 3 8 3s8-1.3 8-3V6"/><path d="M4 12v6c0 1.7 3.6 3 8 3s8-1.3 8-3v-6"/>'],
        'support'  => ['Support', '<circle cx="12" cy="12" r="9"/><circle cx="12" cy="12" r="3.5"/><path d="M5.6 5.6l4 4M14.4 14.4l4 4M18.4 5.6l-4 4M9.6 14.4l-4 4"/>'],
        'rocket'   => ['Rocket', '<path d="M12 15l-3-3c1-4.5 4-8 9-9 -1 5-4.5 8-9 9z"/><path d="M9 12l-4 1 2 2M12 15l-1 4-2-2"/><circle cx="14.5" cy="9.5" r="1.2"/>'],
        'cpu'      => ['Processor', '<rect x="6" y="6" width="12" height="12" rx="2"/><rect x="9.5" y="9.5" width="5" height="5" rx="1"/><path d="M9 3v3M15 3v3M9 18v3M15 18v3M3 9h3M3 15h3M18 9h3M18 15h3"/>'],
        'drive'    => ['Storage', '<rect x="3" y="13" width="18" height="7" rx="2"/><path d="M5 13l2.5-8h9L19 13"/><path d="M7 16.5h.01M11 16.5h6"/>'],
        'network'  => ['Network', '<circle cx="12" cy="5" r="2"/><circle cx="5" cy="19" r="2"/><circle cx="19" cy="19" r="2"/><path d="M12 7v5M12 12l-6 5.5M12 12l6 5.5"/>'],
        'pin'      => ['Location', '<path d="M12 21s7-6.2 7-11.5a7 7 0 10-14 0C5 14.8 12 21 12 21z"/><circle cx="12" cy="9.5" r="2.5"/>'],
        'card'     => ['Payment', '<rect x="3" y="5" width="18" height="14" rx="2"/><path d="M3 10h18M7 15h4"/>'],
        'gift'     => ['Gift', '<rect x="4" y="11" width="16" height="9" rx="1"/><rect x="3" y="7" width="18" height="4" rx="1"/><path d="M12 7v13M12 7c-1.5-4-6-3.5-5-1 .6 1.3 3 1 5 1zM12 7c1.5-4 6-3.5 5-1-.6 1.3-3 1-5 1z"/>'],
        'award'    => ['Award', '<circle cx="12" cy="9" r="5.5"/><path d="M8.5 13.5L7 21l5-2.5 5 2.5-1.5-7.5"/>'],
        'leaf'     => ['Leaf', '<path d="M5 19c0-9 5-14 15-14 0 10-5 15-14 14"/><path d="M5 19c3-5 6-8 10-10"/>'],
        'key'      => ['Key', '<circle cx="8" cy="15" r="4"/><path d="M11 12l9-9M16 7l3 3M14 9l2 2"/>'],
        'eye'      => ['Eye', '<path d="M2 12s3.6-6.5 10-6.5S22 12 22 12s-3.6 6.5-10 6.5S2 12 2 12z"/><circle cx="12" cy="12" r="3"/>'],
        'refresh'  => ['Refresh', '<path d="M20 11a8 8 0 00-14.5-4M4 4v4h4"/><path d="M4 13a8 8 0 0014.5 4M20 20v-4h-4"/>'],
        'download' => ['Download', '<path d="M12 4v11M7 11l5 5 5-5M4 20h16"/>'],
        'upload'   => ['Upload', '<path d="M12 16V5M7 9l5-5 5 5M4 20h16"/>'],
        'layers'   => ['Layers', '<path d="M12 3l9 5-9 5-9-5z"/><path d="M3 12l9 5 9-5"/><path d="M3 16l9 5 9-5"/>'],
        'box'      => ['Package', '<path d="M12 3l8 4.5v9L12 21l-8-4.5v-9z"/><path d="M4 7.5l8 4.5 8-4.5M12 12v9"/>'],
        'tag'      => ['Tag', '<path d="M3 12V4h8l10 10-8 8z"/><circle cx="7.5" cy="8.5" r="1.2"/>'],
        'bell'     => ['Bell', '<path d="M6 16V11a6 6 0 0112 0v5l2 2H4z"/><path d="M10 20a2 2 0 004 0"/>'],
        'chat'     => ['Chat', '<path d="M4 5h16v11H9l-5 4z"/><path d="M8 9h8M8 12h5"/>'],
        'play'     => ['Play', '<circle cx="12" cy="12" r="9"/><path d="M10 8.5l5.5 3.5L10 15.5z"/>'],
        'sliders'  => ['Controls', '<path d="M4 6h10M18 6h2M4 12h4M12 12h8M4 18h12M20 18h0"/><circle cx="16" cy="6" r="2"/><circle cx="10" cy="12" r="2"/><circle cx="18" cy="18" r="2"/>'],
        'terminal' => ['Terminal', '<rect x="3" y="4" width="18" height="16" rx="2"/><path d="M7 9l3 3-3 3M13 15h4"/>'],
        'link'     => ['Link', '<path d="M10 14a4 4 0 005.7 0l3-3a4 4 0 00-5.7-5.7l-1 1"/><path d="M14 10a4 4 0 00-5.7 0l-3 3a4 4 0 005.7 5.7l1-1"/>'],
        'trend'    => ['Growth', '<path d="M3 17l6-6 4 4 8-8"/><path d="M15 7h6v6"/>'],
        'wallet'   => ['Wallet', '<path d="M4 7a2 2 0 012-2h11v3"/><rect x="3" y="8" width="18" height="12" rx="2"/><path d="M16 14h2"/>'],
        'home'     => ['Home', '<path d="M4 11l8-7 8 7v9h-5v-6h-6v6H4z"/>'],
        'search'   => ['Search', '<circle cx="11" cy="11" r="6.5"/><path d="M16 16l4.5 4.5"/>'],
        'settings' => ['Settings', '<circle cx="12" cy="12" r="3"/><path d="M12 3v3M12 18v3M3 12h3M18 12h3M5.6 5.6l2.1 2.1M16.3 16.3l2.1 2.1M18.4 5.6l-2.1 2.1M7.7 16.3l-2.1 2.1"/>'],
        'flag'     => ['Flag', '<path d="M5 21V4M5 4h11l-2 4 2 4H5"/>'],
        'compass'  => ['Compass', '<circle cx="12" cy="12" r="9"/><path d="M15.5 8.5l-2 5-5 2 2-5z"/>'],
        'wordpress' => ['Website', '<rect x="3" y="4" width="18" height="16" rx="2"/><path d="M3 9h18M7 6.5h.01M10 6.5h.01"/>'],
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
