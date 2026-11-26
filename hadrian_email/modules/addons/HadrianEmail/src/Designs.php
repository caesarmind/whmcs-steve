<?php
declare(strict_types=1);

namespace HadrianEmail;

/**
 * The layout designs an admin can pick: the same idea as Lagom's "templates"
 * (pick a look, keep your content), drawn in Hadrian's own visual language.
 *
 * A design is two things:
 *   - a structural treatment the Renderer applies (page colour, how the
 *     header is drawn, whether the message sits on a card, rules between
 *     parts). Stored as the layout document's settings.design.
 *   - starting values for a few block options, applied when the design is
 *     picked. They are ordinary options afterwards: the admin can still
 *     change them in the builder.
 *
 * Picking a design never touches what the admin wrote: tagline, links,
 * footer text, social and unsubscribe settings all carry over.
 *
 * The builder applies the same presets client-side (it receives all() in its
 * boot data), so there is one list, here.
 */
final class Designs
{
    public const DEFAULT = 'card';

    private const ALL = [
        'card' => [
            'label'       => 'Card',
            'description' => 'Your logo above the message, which sits on a white card on a soft grey page.',
            'presets'     => [
                'header'  => ['align' => 'start', 'subject' => false],
                'content' => ['card' => true, 'padding' => 'regular'],
                'footer'  => ['align' => 'center'],
            ],
        ],
        'banner' => [
            'label'       => 'Banner',
            'description' => 'A band in your accent colour with your logo and the email\'s subject, joined to the card below.',
            'presets'     => [
                'header'  => ['align' => 'start', 'subject' => true],
                'content' => ['card' => true, 'padding' => 'regular'],
                'footer'  => ['align' => 'center'],
            ],
        ],
        'letter' => [
            'label'       => 'Letter',
            'description' => 'No card: a centred logo, the message on a plain page and fine rules, like a receipt.',
            'presets'     => [
                'header'  => ['align' => 'center', 'subject' => false],
                'content' => ['card' => false, 'padding' => 'regular'],
                'footer'  => ['align' => 'center'],
            ],
        ],

        // The client-area designs: each is drawn from a screen of Hadrian's
        // client area, and heads the message the way that screen heads a
        // page: the section in small capitals, the title, a status pill
        // (Status). All three turn the subject on.
        'page' => [
            'label'       => 'Page',
            'description' => 'Like a client area page: your logo on a bar with a fine rule, then the section, title and status above the message card.',
            'group'       => 'client',
            'presets'     => [
                'header'  => ['align' => 'start', 'subject' => true],
                'content' => ['card' => true, 'padding' => 'regular'],
                'footer'  => ['align' => 'center'],
            ],
        ],
        'panel' => [
            'label'       => 'Panel',
            'description' => "Like the client area's summary panels: logo, title, status and message all in one card, the logo set off by a fine rule.",
            'group'       => 'client',
            'presets'     => [
                'header'  => ['align' => 'start', 'subject' => true],
                'content' => ['card' => true, 'padding' => 'regular'],
                'footer'  => ['align' => 'center'],
            ],
        ],
        'notice' => [
            'label'       => 'Notice',
            'description' => "Like the client area's notice bar: the title and status on a tinted bar, with the message on a card below it.",
            'group'       => 'client',
            'presets'     => [
                'header'  => ['align' => 'start', 'subject' => true],
                'content' => ['card' => true, 'padding' => 'regular'],
                'footer'  => ['align' => 'center'],
            ],
        ],
    ];

    /** Gallery groups, in order. */
    public const GROUPS = [
        'classic' => 'Classic',
        'client'  => 'Client area',
    ];

    /** @return array<string, array{label:string, description:string, group?:string, presets:array<string,array<string,mixed>>}> */
    public static function all(): array
    {
        return self::ALL;
    }

    /** A design drawn from the client area: heads the message with section, title and status. */
    public static function isClientArea(string $id): bool
    {
        return (self::ALL[$id]['group'] ?? 'classic') === 'client';
    }

    public static function group(string $id): string
    {
        return (string)(self::ALL[$id]['group'] ?? 'classic');
    }

    public static function valid(string $id): string
    {
        return isset(self::ALL[$id]) ? $id : self::DEFAULT;
    }

    /**
     * Switch a layout document to another design, keeping its content.
     *
     * @param array<string,mixed> $doc  a layout document (normalised or not)
     * @return array<string,mixed>  the same document, not yet normalised
     */
    public static function apply(array $doc, string $id): array
    {
        $id = self::valid($id);
        $doc['settings'] = is_array($doc['settings'] ?? null) ? $doc['settings'] : [];
        $doc['settings']['design'] = $id;
        foreach ((array)($doc['blocks'] ?? []) as $i => $block) {
            $type = (string)($block['type'] ?? '');
            $set  = self::ALL[$id]['presets'][$type] ?? null;
            if ($set === null) {
                continue;
            }
            $props = is_array($block['props'] ?? null) ? $block['props'] : [];
            $doc['blocks'][$i]['props'] = $set + $props;
        }
        return $doc;
    }
}
