<?php
declare(strict_types=1);

namespace HadrianEmail;

/**
 * Turns a design document into email HTML. Pure string building: no Smarty, no
 * database, no file access. Give it a theme array and a language and it
 * returns markup, which is what lets one renderer serve the send hook, the
 * static fallback, the builder preview and the tests.
 *
 * What the markup is built for, from measuring WHMCS 9.0.8 (not from its docs):
 *   - WHMCS does NOT inline CSS. Every block therefore carries its own inline
 *     styles; the <style> element only adds what inline styles cannot express
 *     (dark mode, the narrow-screen rules, and typography for stock WHMCS
 *     bodies, which are bare <p> tags).
 *   - One layout, one column, table-based, so it survives Outlook's Word
 *     engine. Right-to-left is the same markup with dir="rtl" and mirrored
 *     alignment, not a second set of templates.
 *
 * Output still contains merge fields and the hx-if markers. The static entry
 * points at the bottom decide what happens to those for each destination.
 */
final class Renderer
{
    /** @var array<string,mixed> */
    private array $theme;
    private string $lang;
    private bool $rtl;
    /** @var array<string,string> the palette inline styles are written in */
    private array $p;
    /** @var array<string,string>|null the palette the dark media query switches to */
    private ?array $alt;
    private bool $baseIsDark;
    private string $font;
    private int $width;
    private int $radius;
    private bool $annotate;
    private bool $markSlot;
    private string $start;
    private string $end;
    /** The layout design (Designs): set by layout() from the document. */
    private string $design = Designs::DEFAULT;
    /** Banner header directly above a carded content cell: they draw as one card. */
    private bool $joined = false;

    /**
     * @param array<string,mixed> $theme  Theme::load()
     * @param array{scheme?:string|null, annotate?:bool, slot?:bool} $opts
     *        scheme   force 'light' or 'dark' and emit no media query (preview)
     *        annotate add data-hx-block attributes for the builder canvas
     *        slot     mark the content cell (data-hx-slot) even when this
     *                 document's own blocks are not annotated: the canvas of
     *                 a message design needs to find it to offer a drop
     *                 target while the message has no blocks yet
     */
    public function __construct(array $theme, string $lang, array $opts = [])
    {
        $this->theme    = $theme;
        $this->lang     = strtolower(trim($lang)) ?: (string)($theme['language'] ?? 'english');
        $this->rtl      = Theme::isRtl($this->lang);
        $this->start    = $this->rtl ? 'right' : 'left';
        $this->end      = $this->rtl ? 'left' : 'right';
        $this->font     = (string)$theme['font'];
        $this->width    = (int)$theme['settings']['width'];
        $this->radius   = (int)$theme['settings']['radius'];
        $this->annotate = !empty($opts['annotate']);
        $this->markSlot = $this->annotate || !empty($opts['slot']);

        $mode   = (string)$theme['settings']['mode'];
        $scheme = $opts['scheme'] ?? null;
        $this->baseIsDark = $scheme === 'dark' || ($scheme === null && $mode === 'dark');
        $this->p   = $theme['palette'][$this->baseIsDark ? 'dark' : 'light'];
        $this->alt = ($scheme === null && $mode === 'auto') ? $theme['palette']['dark'] : null;
    }

    // ------------------------------------------------------------- documents

    /**
     * The wrapper, split at the content slot.
     *
     * @param array<string,mixed> $doc  a normalised layout document
     * @return array{0:string,1:string} [everything before the body, everything after]
     */
    public function layout(array $doc): array
    {
        $before = '';
        $after  = '';
        $seen   = false;
        $close  = '</td></tr>';

        $this->design = Designs::valid((string)($doc['settings']['design'] ?? ''));
        // The band and the card join only when nothing sits between them;
        // otherwise each keeps all four rounded corners.
        $this->joined = false;
        $blocks = array_values((array)$doc['blocks']);
        foreach ($blocks as $i => $b) {
            if ($b['type'] === 'header' && isset($blocks[$i + 1]) && $blocks[$i + 1]['type'] === 'content') {
                $this->joined = $this->design === 'banner' && !empty($blocks[$i + 1]['props']['card']);
            }
        }

        foreach ($doc['blocks'] as $b) {
            if ($b['type'] === 'content') {
                $before .= $this->contentOpen($b);
                $seen    = true;
                continue;
            }
            $row = match ($b['type']) {
                'header' => $this->rowHeader($b),
                'footer' => $this->rowFooter($b),
                default  => '<tr' . $this->mark($b) . '><td class="hx-text" style="padding:0 6px;font-family:' . $this->font
                    . ';font-size:15px;line-height:1.6;color:' . $this->p['text'] . ';text-align:' . $this->start . '">'
                    . $this->block($b) . '</td></tr>',
            };
            if ($seen) {
                $after .= $row;
            } else {
                $before .= $row;
            }
        }
        if (!$seen) {
            // normalize() guarantees a slot; this is for a hand-built document.
            $before .= $this->contentOpen(Blocks::make('content'));
        }
        return [$this->documentOpen() . $before, $close . $after . $this->documentClose()];
    }

    /**
     * The body of one email: the blocks only, ready to sit inside the layout's
     * content cell.
     *
     * @param array<string,mixed> $doc  a normalised message document
     */
    public function message(array $doc): string
    {
        $out = '';
        foreach ($doc['blocks'] as $b) {
            $html = $this->block($b);
            $out .= $this->annotate
                ? '<div' . $this->mark($b) . '>' . ($html !== '' ? $html : $this->placeholder($b)) . '</div>'
                : $html;
        }
        return $out;
    }

    // ----------------------------------------------------------- the skeleton

    private function documentOpen(): string
    {
        $p    = $this->p;
        // Letter has no card, so the page itself is the surface.
        $page      = $this->design === 'letter' ? $p['surface'] : $p['bg'];
        $pageClass = $this->design === 'letter' ? 'hx-surface' : 'hx-bg';
        $code = Bridge::languageCode($this->lang);
        $dir  = $this->rtl ? 'rtl' : 'ltr';
        $scheme = $this->alt !== null ? 'light dark' : ($this->baseIsDark ? 'dark' : 'light');

        return '<!DOCTYPE html>' . "\n"
            . '<html lang="' . $code . '" dir="' . $dir . '" xmlns="http://www.w3.org/1999/xhtml" xmlns:o="urn:schemas-microsoft-com:office:office">' . "\n"
            . '<head>' . "\n"
            . '<meta http-equiv="Content-Type" content="text/html; charset=utf-8">' . "\n"
            . '<meta name="viewport" content="width=device-width, initial-scale=1">' . "\n"
            . '<meta name="x-apple-disable-message-reformatting">' . "\n"
            . '<meta name="format-detection" content="telephone=no, date=no, address=no, email=no">' . "\n"
            . '<meta name="color-scheme" content="' . $scheme . '">' . "\n"
            . '<meta name="supported-color-schemes" content="' . $scheme . '">' . "\n"
            . '<title>' . $this->e((string)$this->theme['company']) . '</title>' . "\n"
            . '<!--[if mso]><noscript><xml><o:OfficeDocumentSettings><o:PixelsPerInch>96</o:PixelsPerInch></o:OfficeDocumentSettings></xml></noscript><![endif]-->' . "\n"
            . '<style>' . $this->css() . '</style>' . "\n"
            . '</head>' . "\n"
            . '<body class="' . $pageClass . '" style="margin:0;padding:0;width:100%;background-color:' . $page . ';">' . "\n"
            // Preheader: the grey line an inbox shows after the subject.
            . '<div style="display:none;max-height:0;max-width:0;overflow:hidden;opacity:0;mso-hide:all;font-size:1px;line-height:1px;color:' . $page . ';">{$hx_preheader}</div>' . "\n"
            . '<table role="presentation" class="' . $pageClass . '" width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="' . $page . '" style="background-color:' . $page . ';">'
            . '<tr><td class="hx-outer" align="center" style="padding:' . ($this->design === 'letter' ? '36px' : '28px') . ' 12px;">' . "\n"
            . '<!--[if mso]><table role="presentation" align="center" width="' . $this->width . '" cellpadding="0" cellspacing="0" border="0"><tr><td><![endif]-->' . "\n"
            . '<table role="presentation" class="hx-container" width="100%" cellpadding="0" cellspacing="0" border="0" style="width:100%;max-width:' . $this->width . 'px;margin:0 auto;">' . "\n";
    }

    private function documentClose(): string
    {
        return "\n" . '</table>' . "\n"
            . '<!--[if mso]></td></tr></table><![endif]-->' . "\n"
            . '</td></tr></table>' . "\n"
            . '</body>' . "\n" . '</html>';
    }

    public function css(): string
    {
        $p   = $this->p;
        $pad = $this->rtl ? '0 22px 0 0' : '0 0 0 22px';
        $css = 'body{margin:0;padding:0;-webkit-text-size-adjust:100%;-ms-text-size-adjust:100%}'
            . 'table{border-spacing:0;mso-table-lspace:0pt;mso-table-rspace:0pt}'
            . 'img{border:0;outline:none;text-decoration:none;-ms-interpolation-mode:bicubic}'
            // Stock WHMCS bodies are bare tags with no styles of their own.
            . '.hx-content p{margin:0 0 16px}'
            . '.hx-content h1{margin:0 0 14px;font-size:24px;line-height:1.25;font-weight:600}'
            . '.hx-content h2{margin:0 0 12px;font-size:20px;line-height:1.3;font-weight:600}'
            . '.hx-content h3{margin:0 0 10px;font-size:17px;line-height:1.35;font-weight:600}'
            . '.hx-content ul,.hx-content ol{margin:0 0 16px;padding:' . $pad . '}'
            . '.hx-content li{margin:0 0 6px}'
            . '.hx-content a{color:' . $p['link'] . '}'
            . '.hx-content img{max-width:100%;height:auto}'
            . '.hx-content small{font-size:12px;line-height:1.5}'
            . '.hx-content hr{border:0;border-top:1px solid ' . $p['border'] . ';margin:24px 0}'
            . '@media only screen and (max-width:' . ($this->width + 20) . 'px){'
            . '.hx-outer{padding:14px 8px!important}'
            . '.hx-content{padding:22px 20px 8px!important}'
            . '.hx-stack{display:block!important;width:100%!important;text-align:' . $this->start . '!important;padding-left:0!important;padding-right:0!important}'
            . '.hx-stack-gap{padding-top:10px!important}'
            . '.hx-btn-full a{display:block!important}'
            . ($this->design === 'banner' ? '.hx-band{padding:22px 20px 24px!important}' : '')
            . '.hx-title{font-size:22px!important}'
            . '}';

        if ($this->alt !== null) {
            $rules = $this->darkRules($this->alt);
            $css  .= '@media (prefers-color-scheme:dark){' . $rules('') . '}';
            // Outlook.com and the Outlook apps ignore the media query and mark
            // the message with these attributes instead.
            $css  .= $rules('[data-ogsc] ') . $rules('[data-ogsb] ');
        }
        $custom = trim((string)$this->theme['settings']['customCss']);
        return $css . ($custom !== '' ? "\n" . $custom : '');
    }

    /**
     * @param array<string,string> $d
     * @return callable(string):string  rules with every selector prefixed
     */
    private function darkRules(array $d): callable
    {
        $rules = [
            ['.hx-bg', 'background-color:' . $d['bg']],
            ['.hx-surface', 'background-color:' . $d['surface']],
            ['.hx-surface2', 'background-color:' . $d['surface2']],
            ['.hx-text,.hx-content,.hx-content p,.hx-content li,.hx-content h1,.hx-content h2,.hx-content h3,.hx-content td', 'color:' . $d['text']],
            ['.hx-content a,.hx-link', 'color:' . $d['link']],
            ['.hx-muted,.hx-muted a,.hx-content .hx-muted', 'color:' . $d['muted']],
            ['.hx-border', 'border-color:' . $d['border']],
            ['.hx-btn', 'background-color:' . $d['accent']],
            ['.hx-btn a', 'color:' . $d['onAccent']],
            ['.hx-btn2', 'background-color:' . $d['accentTint']],
            ['.hx-btn2 a', 'color:' . $d['link']],
            ['.hx-tint-info', 'background-color:' . $d['accentTint'] . ';border-color:' . $d['link']],
            ['.hx-tint-success', 'background-color:' . $d['successTint'] . ';border-color:' . $d['success']],
            ['.hx-tint-warning', 'background-color:' . $d['warningTint'] . ';border-color:' . $d['warning']],
            ['.hx-tint-danger', 'background-color:' . $d['dangerTint'] . ';border-color:' . $d['danger']],
            ['.hx-logo-l', 'display:none'],
            ['.hx-logo-d', 'display:block;max-height:none;overflow:visible'],
        ];
        if ($this->design === 'banner') {
            $rules[] = ['.hx-band', 'background-color:' . $this->bandColor($d)];
            $rules[] = ['.hx-on-band,.hx-on-band a', 'color:' . $d['onAccent']];
            $rules[] = ['.hx-on-band2,.hx-on-band2 a', 'color:' . $this->onBandMuted($d)];
        }
        $hasDarkLogo = $this->hasDarkLogo();

        return static function (string $prefix) use ($rules, $hasDarkLogo): string {
            $out = '';
            foreach ($rules as [$selectors, $decls]) {
                if (!$hasDarkLogo && str_starts_with($selectors, '.hx-logo')) {
                    continue;
                }
                $sel = implode(',', array_map(static fn(string $s): string => $prefix . trim($s), explode(',', $selectors)));
                $important = implode(';', array_map(static fn(string $d): string => $d . '!important', explode(';', $decls)));
                $out .= $sel . '{' . $important . '}';
            }
            return $out;
        };
    }

    private function hasDarkLogo(): bool
    {
        $l = (string)$this->theme['logo']['light'];
        $d = (string)$this->theme['logo']['dark'];
        return $this->alt !== null && $d !== '' && $d !== $l;
    }

    // ------------------------------------------------------------ layout rows

    /** @param array<string,mixed> $b */
    private function rowHeader(array $b): string
    {
        $pr     = $b['props'];
        $p      = $this->p;
        $center = $pr['align'] === 'center';
        $band   = $this->design === 'banner';
        $align  = $center ? 'center' : $this->start;

        // On the band everything is drawn in the on-accent colour; elsewhere
        // in the page's own text colours.
        $ink   = $band ? $p['onAccent'] : $p['text'];
        $ink2  = $band ? $this->onBandMuted($p) : $p['muted'];
        $cls   = $band ? 'hx-on-band' : 'hx-text';
        $cls2  = $band ? 'hx-on-band2' : 'hx-muted';

        $brand = '';
        if ($pr['logo']) {
            $brand = $band ? $this->bandLogo((int)$pr['logoWidth']) : $this->logo((int)$pr['logoWidth']);
        }
        $tagline = trim(Merge::pick($pr['tagline'], $this->lang));
        if ($tagline !== '') {
            $brand .= '<div class="' . $cls2 . '" style="margin-top:6px;font-size:13px;line-height:1.4;color:' . $ink2 . ';">'
                . Merge::escape($tagline) . '</div>';
        }

        $nav = $this->linkList($pr['nav'], 'font-weight:500;text-decoration:none;', $cls2, $ink2);

        if ($center || $nav === '' || $brand === '') {
            $inner = $brand;
            if ($nav !== '') {
                $inner .= '<div class="' . $cls2 . '" style="' . ($brand !== '' ? 'margin-top:12px;' : '') . 'font-size:13px;line-height:1.5;color:' . $ink2 . ';">' . $nav . '</div>';
            }
            $cell = '<td align="' . $align . '" style="text-align:' . $align . ';">' . $inner . '</td>';
        } else {
            $cell = '<td class="hx-stack" align="' . $this->start . '" valign="middle" style="text-align:' . $this->start . ';">' . $brand . '</td>'
                . '<td class="hx-stack hx-stack-gap ' . $cls2 . '" align="' . $this->end . '" valign="middle" style="text-align:' . $this->end
                . ';font-size:13px;line-height:1.5;color:' . $ink2 . ';padding-' . $this->start . ':16px;">' . $nav . '</td>';
        }
        $rows = $this->table() . '<tr>' . $cell . '</tr></table>';

        // The email's subject as a title. A marker, not a value: it is filled
        // per email at send time, and dropped wherever there is no subject.
        if ($pr['subject']) {
            $size = $band ? 26 : 24;
            $rows .= '<!--hx-if:hx_subject--><div class="hx-title ' . $cls . '" style="margin-top:' . ($band ? 26 : 18) . 'px;font-size:' . $size
                . 'px;line-height:1.2;font-weight:600;letter-spacing:-0.015em;color:' . $ink . ';text-align:' . $align . ';">{$hx_subject}</div><!--/hx-if-->';
        }

        if ($band) {
            $r      = $this->radius;
            $corner = $this->joined ? $r . 'px ' . $r . 'px 0 0' : $r . 'px';
            return '<tr' . $this->mark($b) . '><td style="padding:0 0 ' . ($this->joined ? 0 : 20) . 'px;font-family:' . $this->font . ';">'
                . $this->table() . '<tr><td class="hx-band" bgcolor="' . $this->bandColor($p) . '" align="' . $align . '" style="background-color:' . $this->bandColor($p)
                . ';border-radius:' . $corner . ';padding:26px 32px 28px;text-align:' . $align . ';">' . $rows . '</td></tr></table></td></tr>' . "\n";
        }

        $rule = $this->design === 'letter'
            ? 'padding:4px 6px 26px;border-bottom:1px solid ' . $p['border'] . ';'
            : 'padding:4px 6px 20px;';
        return '<tr' . $this->mark($b) . '><td' . ($this->design === 'letter' ? ' class="hx-border"' : '') . ' style="' . $rule . 'font-family:' . $this->font . ';">'
            . $rows . '</td></tr>' . "\n";
    }

    /** Secondary text on the band: the on-accent colour, softened toward the accent. */
    /**
     * Secondary text on the band (tagline, links). Full on-accent colour, not
     * a softened one: the band is only deepened as far as 4.5:1 against that
     * colour, so any tint of it would fall below the minimum at 13px. The
     * hierarchy on the band comes from size and weight instead.
     */
    private function onBandMuted(array $p): string
    {
        return $p['onAccent'];
    }

    /**
     * The band's fill: the accent, deepened only as far as needed for the
     * on-accent text to reach 4.5:1. The stock light accent already does; the
     * stock dark one (white on #2997ff is about 3:1) does not.
     */
    private function bandColor(array $p): string
    {
        return Palette::readableUnder($p['accent'], $p['onAccent']);
    }

    /**
     * The logo on the accent band. The normal logo is usually dark and would
     * vanish there, so only the light-coloured one (set for dark mode) is
     * used; without it, the company name is set in the on-accent colour.
     */
    private function bandLogo(int $width): string
    {
        $src  = (string)$this->theme['logo']['dark'];
        $name = $this->e((string)$this->theme['company']);
        $href = $this->e((string)$this->theme['systemUrl']);
        if ($src === '') {
            return '<a class="hx-on-band" href="' . $href . '" style="font-size:20px;line-height:1.2;font-weight:600;letter-spacing:-0.01em;color:'
                . $this->p['onAccent'] . ';text-decoration:none;">' . $name . '</a>';
        }
        return '<a href="' . $href . '" style="display:inline-block;text-decoration:none;"><img src="' . $this->e($src) . '" width="' . $width
            . '" alt="' . $name . '" style="display:block;width:' . $width . 'px;max-width:100%;height:auto;border:0;"></a>';
    }

    /** @param array<string,mixed> $b */
    private function contentOpen(array $b): string
    {
        $pr  = $b['props'];
        $p   = $this->p;
        $pad = ['compact' => 20, 'regular' => 32, 'roomy' => 44][$pr['padding']] ?? 32;
        // Every block ends in 16px of its own bottom spacing, so the cell's
        // bottom padding gives that back.
        $bottom = max(8, $pad - 16);
        $base   = 'font-family:' . $this->font . ';font-size:15px;line-height:1.6;color:' . $p['text'] . ';text-align:' . $this->start . ';';
        $slot   = $this->markSlot ? ' data-hx-slot="1"' : '';

        if ($pr['card']) {
            $r = $this->radius;
            // Joined to the band above: square top corners and no top border,
            // so the two read as one card with a coloured cap.
            $frame = $this->joined
                ? 'border:1px solid ' . $p['border'] . ';border-top:0;border-radius:0 0 ' . $r . 'px ' . $r . 'px;'
                : 'border:1px solid ' . $p['border'] . ';border-radius:' . $r . 'px;';
            return '<tr' . $this->mark($b) . '><td class="hx-content hx-surface hx-border hx-text"' . $slot . ' dir="' . ($this->rtl ? 'rtl' : 'ltr')
                . '" bgcolor="' . $p['surface'] . '" style="' . $base . 'padding:' . $pad . 'px ' . $pad . 'px ' . $bottom . 'px;'
                . 'background-color:' . $p['surface'] . ';' . $frame . '">';
        }
        $top = $this->design === 'letter' ? 28 : max(8, $pad - 16);
        return '<tr' . $this->mark($b) . '><td class="hx-content hx-text"' . $slot . ' dir="' . ($this->rtl ? 'rtl' : 'ltr')
            . '" style="' . $base . 'padding:' . $top . 'px 6px ' . max(0, $bottom - 16) . 'px;">';
    }

    /** @param array<string,mixed> $b */
    private function rowFooter(array $b): string
    {
        $pr    = $b['props'];
        $p     = $this->p;
        $align = $pr['align'] === 'center' ? 'center' : $this->start;
        $parts = [];

        if ($pr['social'] && !empty($this->theme['social'])) {
            $social = array_map(
                static fn(array $s): array => ['label' => ['_' => $s['label']], 'url' => $s['url']],
                (array)$this->theme['social']
            );
            $parts[] = $this->linkList($social, 'font-weight:500;text-decoration:none;');
        }
        $links = $this->linkList($pr['links'], 'text-decoration:underline;');
        if ($links !== '') {
            $parts[] = $links;
        }
        $text = trim(Merge::pick($pr['text'], $this->lang));
        if ($text !== '') {
            $parts[] = strtr($this->rich($text), ['margin:0 0 16px' => 'margin:0 0 6px']);
        }
        if ($pr['unsubscribe']) {
            $label = trim(Merge::pick($pr['unsubscribeLabel'], $this->lang)) ?: 'Unsubscribe';
            $parts[] = '<!--hx-if:unsubscribe_url--><a class="hx-muted" href="{$unsubscribe_url}" style="color:' . $p['muted']
                . ';text-decoration:underline;">' . Merge::escape($label) . '</a><!--/hx-if-->';
        }

        $html = '';
        foreach ($parts as $i => $part) {
            $html .= '<div' . ($i > 0 ? ' style="margin-top:8px;"' : '') . '>' . $part . '</div>';
        }
        // Letter separates the footer with a fine rule instead of a card edge.
        $rule = $this->design === 'letter' ? 'border-top:1px solid ' . $p['border'] . ';' : '';
        return '<tr' . $this->mark($b) . '><td class="hx-muted' . ($rule !== '' ? ' hx-border' : '') . '" align="' . $align . '" style="padding:22px 12px 6px;' . $rule . 'font-family:' . $this->font
            . ';font-size:12px;line-height:1.7;color:' . $p['muted'] . ';text-align:' . $align . ';">' . $html . '</td></tr>' . "\n";
    }

    // ---------------------------------------------------------------- blocks

    /** @param array<string,mixed> $b */
    private function block(array $b): string
    {
        $pr = $b['props'];
        return match ($b['type']) {
            'heading' => $this->bHeading($pr),
            'text'    => $this->bText($pr),
            'button'  => $this->bButton($pr),
            'details' => $this->bDetails($pr),
            'callout' => $this->bCallout($pr),
            'image'   => $this->bImage($pr),
            'divider' => $this->bDivider($pr),
            'spacer'  => $this->bSpacer($pr),
            'html'    => (string)$pr['code'],
            default   => '',
        };
    }

    /** @param array<string,mixed> $pr */
    private function bHeading(array $pr): string
    {
        $text = trim(Merge::pick($pr['text'], $this->lang));
        if ($text === '') {
            return '';
        }
        [$tag, $size, $lh, $mb] = [
            '1' => ['h1', 24, '1.25', 14],
            '2' => ['h2', 20, '1.3', 12],
            '3' => ['h3', 17, '1.35', 10],
        ][(string)$pr['level']] ?? ['h1', 24, '1.25', 14];

        return '<' . $tag . ' class="hx-text" style="margin:0 0 ' . $mb . 'px;font-family:' . $this->font . ';font-size:' . $size . 'px;line-height:' . $lh
            . ';font-weight:600;letter-spacing:-0.01em;text-align:' . $this->align((string)$pr['align']) . ';">' . Merge::escape($text) . '</' . $tag . '>';
    }

    /** @param array<string,mixed> $pr */
    private function bText(array $pr): string
    {
        $html = trim(Merge::pick($pr['html'], $this->lang));
        if ($html === '') {
            return '';
        }
        $size  = ['small' => 13, 'normal' => 15, 'large' => 17][$pr['size']] ?? 15;
        $muted = $pr['muted'] ? 'color:' . $this->p['muted'] . ';' : '';
        return '<div' . ($pr['muted'] ? ' class="hx-muted"' : '') . ' style="font-size:' . $size . 'px;line-height:1.6;' . $muted
            . 'text-align:' . $this->align((string)$pr['align']) . ';">' . $this->rich($html) . '</div>';
    }

    /** @param array<string,mixed> $pr */
    private function bButton(array $pr): string
    {
        $label = trim(Merge::pick($pr['label'], $this->lang));
        if ($label === '') {
            return '';
        }
        $p       = $this->p;
        $primary = $pr['style'] !== 'secondary';
        $bg      = $primary ? $p['accent'] : $p['accentTint'];
        $fg      = $primary ? $p['onAccent'] : $p['link'];
        $full    = (bool)$pr['full'];
        $url     = (string)$pr['url'] !== '' ? (string)$pr['url'] : '{$whmcs_url}';

        // Padding lives on the anchor so the whole button is clickable, and
        // again on the cell as mso-padding-alt because Outlook ignores it there.
        $inner = '<table role="presentation" cellpadding="0" cellspacing="0" border="0"' . ($full ? ' width="100%"' : '') . ' style="border-collapse:separate;">'
            . '<tr><td class="' . ($primary ? 'hx-btn' : 'hx-btn2') . ($full ? ' hx-btn-full' : '') . '" align="center" bgcolor="' . $bg
            . '" style="background-color:' . $bg . ';border-radius:10px;mso-padding-alt:12px 22px;">'
            . '<a href="' . Merge::escape($url) . '" target="_blank" style="display:' . ($full ? 'block' : 'inline-block') . ';padding:12px 22px;font-family:' . $this->font
            . ';font-size:15px;line-height:20px;font-weight:600;color:' . $fg . ';text-decoration:none;border-radius:10px;">' . Merge::escape($label) . '</a>'
            . '</td></tr></table>';

        return $this->table() . '<tr><td align="' . $this->align((string)$pr['align']) . '" style="padding:4px 0 20px;">' . $inner . '</td></tr></table>';
    }

    /** @param array<string,mixed> $pr */
    private function bDetails(array $pr): string
    {
        $p    = $this->p;
        $rows = array_values(array_filter(
            (array)$pr['rows'],
            fn(array $r): bool => trim(Merge::pick($r['label'], $this->lang)) !== '' || trim((string)$r['value']) !== ''
        ));
        if ($rows === []) {
            return '';
        }
        $html = '';
        $last = count($rows) - 1;
        foreach ($rows as $i => $r) {
            $line = $i < $last ? 'border-bottom:1px solid ' . $p['border'] . ';' : '';
            $html .= '<tr>'
                . '<td class="hx-muted hx-border" valign="top" style="padding:10px 0;font-size:13px;line-height:1.5;color:' . $p['muted'] . ';text-align:' . $this->start . ';' . $line . '">'
                . Merge::escape(Merge::pick($r['label'], $this->lang)) . '</td>'
                // The value is not escaped: {$invoice_link} and friends are HTML.
                . '<td class="hx-text hx-border" valign="top" style="padding:10px 0;padding-' . $this->start . ':16px;font-size:14px;line-height:1.5;font-weight:600;text-align:' . $this->end . ';' . $line . '">'
                . Merge::escape((string)$r['value']) . '</td>'
                . '</tr>';
        }
        $table = $this->table() . $html . '</table>';
        if ($pr['boxed']) {
            $table = $this->table() . '<tr><td class="hx-surface2" bgcolor="' . $p['surface2'] . '" style="background-color:' . $p['surface2']
                . ';border-radius:12px;padding:4px 18px;">' . $table . '</td></tr></table>';
        }
        return $this->table() . '<tr><td style="padding:2px 0 20px;">' . $table . '</td></tr></table>';
    }

    /** @param array<string,mixed> $pr */
    private function bCallout(array $pr): string
    {
        $html = trim(Merge::pick($pr['html'], $this->lang));
        if ($html === '') {
            return '';
        }
        $p    = $this->p;
        $tone = (string)$pr['tone'];
        [$bg, $ink] = [
            'info'    => [$p['accentTint'], $p['link']],
            'success' => [$p['successTint'], $p['success']],
            'warning' => [$p['warningTint'], $p['warning']],
            'danger'  => [$p['dangerTint'], $p['danger']],
        ][$tone] ?? [$p['accentTint'], $p['link']];

        $body = strtr($this->rich($html), ['margin:0 0 16px' => 'margin:0 0 6px']);
        return $this->table() . '<tr><td style="padding:2px 0 20px;">'
            . $this->table() . '<tr><td class="hx-tint-' . $tone . '" bgcolor="' . $bg . '" style="background-color:' . $bg
            . ';border-radius:12px;border-' . $this->start . ':3px solid ' . $ink . ';padding:14px 16px 8px;font-size:14px;line-height:1.55;text-align:' . $this->start . ';">'
            . $body . '</td></tr></table></td></tr></table>';
    }

    /** @param array<string,mixed> $pr */
    private function bImage(array $pr): string
    {
        $src = $this->absolute((string)$pr['src']);
        if ($src === '') {
            return '';
        }
        $w   = min((int)$pr['width'], $this->width);
        $img = '<img src="' . $this->e($src) . '" width="' . $w . '" alt="' . Merge::escape(Merge::pick($pr['alt'], $this->lang))
            . '" style="display:block;width:' . $w . 'px;max-width:100%;height:auto;border:0;' . ($pr['rounded'] ? 'border-radius:12px;' : '') . '">';
        if ((string)$pr['href'] !== '') {
            $img = '<a href="' . Merge::escape((string)$pr['href']) . '" target="_blank" style="text-decoration:none;">' . $img . '</a>';
        }
        $align = $this->align((string)$pr['align']);
        // An image is centred by its table, not by text-align, in Outlook.
        return $this->table() . '<tr><td align="' . $align . '" style="padding:2px 0 20px;">'
            . '<table role="presentation" cellpadding="0" cellspacing="0" border="0" align="' . $align . '"><tr><td>' . $img . '</td></tr></table>'
            . '</td></tr></table>';
    }

    /** @param array<string,mixed> $pr */
    private function bDivider(array $pr): string
    {
        [$top, $bottom] = ['small' => [4, 16], 'medium' => [8, 24], 'large' => [16, 32]][$pr['space']] ?? [8, 24];
        return $this->table() . '<tr><td style="padding:' . $top . 'px 0 ' . $bottom . 'px;">'
            . '<div class="hx-border" style="height:0;border-top:1px solid ' . $this->p['border'] . ';font-size:0;line-height:0;">&nbsp;</div>'
            . '</td></tr></table>';
    }

    /** @param array<string,mixed> $pr */
    private function bSpacer(array $pr): string
    {
        $h = (int)$pr['height'];
        return '<div style="height:' . $h . 'px;line-height:' . $h . 'px;font-size:0;mso-line-height-rule:exactly;">&nbsp;</div>';
    }

    // ---------------------------------------------------------------- helpers

    private function logo(int $width): string
    {
        $light = (string)$this->theme['logo']['light'];
        $dark  = (string)$this->theme['logo']['dark'];
        $src   = $this->baseIsDark && $dark !== '' ? $dark : $light;
        $name  = $this->e((string)$this->theme['company']);
        $href  = $this->e((string)$this->theme['systemUrl']);

        if ($src === '') {
            // No logo an email client can show: set the company name in type.
            return '<a class="hx-text" href="' . $href . '" style="font-size:20px;line-height:1.2;font-weight:600;letter-spacing:-0.01em;color:'
                . $this->p['text'] . ';text-decoration:none;">' . $name . '</a>';
        }
        $style = 'width:' . $width . 'px;max-width:100%;height:auto;border:0;';
        $img   = '<img class="hx-logo-l" src="' . $this->e($src) . '" width="' . $width . '" alt="' . $name . '" style="display:block;' . $style . '">';
        if ($this->hasDarkLogo()) {
            // Hidden until the dark rules reveal it. Outlook's Word engine
            // cannot hide it, so it never sees it.
            $img .= '<!--[if !mso]><!--><img class="hx-logo-d" src="' . $this->e($dark) . '" width="' . $width . '" alt="' . $name
                . '" style="display:none;max-height:0;overflow:hidden;' . $style . '"><!--<![endif]-->';
        }
        return '<a href="' . $href . '" style="display:inline-block;text-decoration:none;">' . $img . '</a>';
    }

    /**
     * @param array<int, array<string,mixed>> $links
     */
    private function linkList(array $links, string $linkStyle, string $class = 'hx-muted', ?string $color = null): string
    {
        $color ??= $this->p['muted'];
        $out = [];
        foreach ($links as $l) {
            $label = trim(Merge::pick($l['label'] ?? '', $this->lang));
            $url   = trim((string)($l['url'] ?? ''));
            if ($label === '' || $url === '') {
                continue;
            }
            $out[] = '<a class="' . $class . '" href="' . Merge::escape($url) . '" style="color:' . $color . ';' . $linkStyle . '">'
                . Merge::escape($label) . '</a>';
        }
        // The separator is the link colour itself on the band, where the
        // page's faint grey would not read; elsewhere the faint grey.
        $sep = $class === 'hx-muted' ? $this->p['faint'] : $color;
        return implode('<span class="' . $class . '" style="color:' . $sep . ';">&nbsp;&nbsp;&middot;&nbsp;&nbsp;</span>', $out);
    }

    /** Inline styles for sanitised rich text. The tags have no attributes of their own. */
    private function rich(string $html): string
    {
        $p   = $this->p;
        $pad = $this->rtl ? '0 22px 0 0' : '0 0 0 22px';
        return strtr($html, [
            '<p>'          => '<p style="margin:0 0 16px;">',
            '<ul>'         => '<ul style="margin:0 0 16px;padding:' . $pad . ';">',
            '<ol>'         => '<ol style="margin:0 0 16px;padding:' . $pad . ';">',
            '<li>'         => '<li style="margin:0 0 6px;">',
            '<h2>'         => '<h2 style="margin:0 0 12px;font-size:20px;line-height:1.3;font-weight:600;">',
            '<h3>'         => '<h3 style="margin:0 0 10px;font-size:17px;line-height:1.35;font-weight:600;">',
            '<small>'      => '<small style="font-size:12px;line-height:1.5;">',
            '<blockquote>' => '<blockquote class="hx-border" style="margin:0 0 16px;padding:0 14px;border-' . $this->start . ':3px solid ' . $p['border'] . ';">',
            '<code>'       => '<code style="font-family:Menlo,Consolas,monospace;font-size:13px;">',
            '<a href='     => '<a class="hx-link" style="color:' . $p['link'] . ';text-decoration:underline;" href=',
        ]);
    }

    private function align(string $logical): string
    {
        return match ($logical) {
            'center' => 'center',
            'end'    => $this->end,
            default  => $this->start,
        };
    }

    private function table(): string
    {
        return '<table role="presentation" width="100%" cellpadding="0" cellspacing="0" border="0">';
    }

    /** @param array<string,mixed> $b */
    private function mark(array $b): string
    {
        return $this->annotate ? ' data-hx-block="' . $this->e((string)$b['id']) . '" data-hx-type="' . $this->e((string)$b['type']) . '"' : '';
    }

    /** What the canvas shows for a block that renders nothing yet. */
    private function placeholder(array $b): string
    {
        $label = Blocks::types()[$b['type']]['label'] ?? 'Block';
        return '<div style="margin:0 0 16px;padding:18px;border:1px dashed ' . $this->p['border'] . ';border-radius:12px;text-align:center;font-size:13px;color:'
            . $this->p['faint'] . ';">' . $this->e($label) . ' is empty</div>';
    }

    private function absolute(string $url): string
    {
        if ($url === '' || preg_match('/^https?:\/\//i', $url)) {
            return $url;
        }
        return str_starts_with($url, '/') ? (string)$this->theme['origin'] . $url : '';
    }

    private function e(string $s): string
    {
        return htmlspecialchars($s, ENT_QUOTES, 'UTF-8');
    }

    // =========================================================================
    // Entry points: one per destination. Each decides what becomes of the merge
    // fields and conditional markers the instance methods leave in place.
    // =========================================================================

    /**
     * Header and footer for one outgoing email, as merge-field values.
     * WHMCS inserts these raw and does not evaluate them, so every field is
     * substituted here, by string replacement.
     *
     * @param array<string,mixed> $theme
     * @param array<string,mixed> $layoutDoc
     * @param array<string,mixed> $fields    the email's merge fields
     * @return array{0:string,1:string}
     */
    public static function forSend(array $theme, array $layoutDoc, string $lang, array $fields, string $preheader = ''): array
    {
        return self::fill((new self($theme, $lang))->layout($layoutDoc), $fields, $preheader);
    }

    /**
     * The per-email half of forSend(), split out so a cron run that sends five
     * hundred invoices builds the layout once per language and only does this
     * string replacement per message.
     *
     * @param array{0:string,1:string} $parts  Renderer::layout() output
     * @param array<string,mixed> $fields
     * @return array{0:string,1:string}
     */
    public static function fill(array $parts, array $fields, string $preheader = ''): array
    {
        $all = ['hx_year' => date('Y'), 'hx_preheader' => htmlspecialchars($preheader, ENT_QUOTES, 'UTF-8')] + $fields;
        $run = static fn(string $html): string => Merge::substitute(Merge::stripLogic(Merge::conditionals($html, $all)), $all, false);
        return [$run($parts[0]), $run($parts[1])];
    }

    /**
     * Header and footer as Smarty source, for the {else} branch of the guarded
     * placeholder. WHMCS evaluates this one itself, so merge fields stay,
     * markers become {if}, and everything else with a brace is neutralised.
     *
     * @param array<string,mixed> $theme
     * @param array<string,mixed> $layoutDoc
     * @return array{0:string,1:string}
     */
    public static function fallback(array $theme, array $layoutDoc): array
    {
        $r = new self($theme, (string)$theme['language']);
        [$header, $footer] = $r->layout($layoutDoc);
        $own = ['hx_year' => date('Y'), 'hx_preheader' => ''];
        $run = static function (string $html) use ($own): string {
            // Parts that show one of our own per-email values (the subject
            // title) are dropped: WHMCS has no such field to fill them with.
            $html = (string)preg_replace('/<!--hx-if:hx_[a-z0-9_]+-->.*?<!--\/hx-if-->/s', '', $html);
            $html = Merge::stripLogic($html);
            foreach ($own as $k => $v) {
                $html = str_replace('{$' . $k . '}', $v, $html);
            }
            $html = (string)preg_replace_callback('/<style>(.*?)<\/style>/s', static function (array $m): string {
                return '<style>{literal}' . str_replace(['{literal}', '{/literal}'], '', $m[1]) . '{/literal}</style>';
            }, $html);
            return Merge::protect(Merge::conditionals($html, null));
        };
        return [$run($header), $run($footer)];
    }

    /**
     * A published body: Smarty source for tblemailtemplates.message.
     *
     * @param array<string,mixed> $theme
     * @param array<string,mixed> $messageDoc
     */
    public static function compileMessage(array $theme, array $messageDoc, string $lang): string
    {
        return Merge::protect((new self($theme, $lang))->message($messageDoc));
    }

    /**
     * A whole email for the builder: layout around a message (or around a
     * sample body), with sample data in the merge fields.
     *
     * @param array<string,mixed> $theme
     * @param array<string,mixed> $layoutDoc
     * @param array<string,mixed>|null $messageDoc
     * @param array{lang?:string, scheme?:string|null, annotate?:string|null, body?:string, fields?:array<string,mixed>, subject?:string} $opts
     *        annotate 'layout' or 'message': which document's blocks get markers
     *        subject  plain text for the header's subject title (sample data
     *                 is substituted into it)
     */
    public static function preview(array $theme, array $layoutDoc, ?array $messageDoc, array $opts = []): string
    {
        $lang     = (string)($opts['lang'] ?? $theme['language']);
        $scheme   = $opts['scheme'] ?? null;
        $annotate = $opts['annotate'] ?? null;
        $fields   = ($opts['fields'] ?? []) + Samples::fields($theme);
        $subject  = (string)($opts['subject'] ?? Samples::SUBJECT);
        $fields  += [
            'hx_year'      => date('Y'),
            'hx_preheader' => '',
            'hx_subject'   => self::subjectText($subject, $fields),
        ];

        $outer = new self($theme, $lang, ['scheme' => $scheme, 'annotate' => $annotate === 'layout', 'slot' => $annotate !== null]);
        [$header, $footer] = $outer->layout($layoutDoc);

        if ($messageDoc !== null && $messageDoc['blocks'] !== []) {
            $body = (new self($theme, $lang, ['scheme' => $scheme, 'annotate' => $annotate === 'message']))->message($messageDoc);
        } else {
            $body = (string)($opts['body'] ?? Samples::body());
        }

        $run = static fn(string $html): string => Merge::substitute(Merge::stripLogic(Merge::conditionals($html, $fields)), $fields, true);
        return $run($header) . $run($body) . $run($footer);
    }

    /**
     * An email subject as it should appear in the header: merge fields filled
     * in, Smarty logic and tags removed, then escaped once. Subjects are plain
     * text in WHMCS, but a merge field can return HTML (a link), and the
     * stored subject may carry entities.
     *
     * @param array<string,mixed> $fields
     */
    public static function subjectText(string $subject, array $fields): string
    {
        $text = Merge::substitute(Merge::stripLogic(html_entity_decode($subject, ENT_QUOTES, 'UTF-8')), $fields, false);
        $text = trim((string)preg_replace('/\s+/', ' ', html_entity_decode(strip_tags($text), ENT_QUOTES, 'UTF-8')));
        if (function_exists('mb_substr') && mb_strlen($text) > 160) {
            $text = rtrim(mb_substr($text, 0, 157)) . '...';
        }
        return htmlspecialchars($text, ENT_QUOTES, 'UTF-8');
    }
}
