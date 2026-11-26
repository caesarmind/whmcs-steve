<?php
declare(strict_types=1);

namespace HadrianEmail;

/**
 * EmailPreSend: supplies the header and footer for one outgoing email.
 *
 * Runs on every templated email, including the hundreds a billing cron sends
 * in one process, so it does the least it can: the layout is built once per
 * language and reused; per email there is one design lookup and a string
 * replacement.
 *
 * It must never be the reason an email is not sent. Anything that goes wrong
 * is logged and answered with an empty array, which makes the guarded
 * placeholder fall through to its static header and footer.
 */
final class SendHook
{
    /** @var array<string, array{0:string,1:string}> layout parts by language */
    private static array $parts = [];

    /** @var array<string,mixed>|null */
    private static ?array $layout = null;

    /** @var array<string, array{0:string,1:string}> [subject, type] by template name and language */
    private static array $subjects = [];

    /**
     * @param array<string,mixed> $vars  messagename, relid, mergefields
     * @return array<string,string>
     */
    public static function handle(array $vars): array
    {
        try {
            // Off, or Hadrian has gone away: answer nothing, and the guarded
            // placeholder falls through to the static layout that was built
            // while the brand was still readable.
            if (!Takeover::isEnabled() || !Bridge::available()) {
                return [];
            }
            $fields = is_array($vars['mergefields'] ?? null) ? $vars['mergefields'] : [];

            // Empty for a client on the default language; absent on admin
            // notifications, which WHMCS does not wrap in the global header
            // anyway (measured), so what is returned for those goes unused.
            $lang = strtolower(trim((string)($fields['client_language'] ?? '')));
            if ($lang === '' || !preg_match('/^[a-z][a-z0-9_-]*$/', $lang)) {
                $lang = Bridge::defaultLanguage();
            }

            self::$layout ??= Takeover::layoutDoc();
            self::$parts[$lang] ??= (new Renderer(Theme::load(), $lang))->layout(self::$layout);

            $name = (string)($vars['messagename'] ?? '');
            if (self::showsSubject()) {
                [$subject, $type] = self::template($name, $lang);
                $fields['hx_subject'] = Renderer::subjectText($subject, $fields);
                // The client-area designs head the title with its section and
                // status. Set for every design; only those draw the markers.
                $fields = Status::fields($name, $type, $lang) + $fields;
            }

            [$header, $footer] = Renderer::fill(self::$parts[$lang], $fields, self::preheader($name, $lang, $fields));

            return [Takeover::HEADER_FIELD => $header, Takeover::FOOTER_FIELD => $footer];
        } catch (\Throwable $e) {
            error_log('Hadrian email: send hook failed, using the static layout: ' . $e->getMessage()
                . ' at ' . $e->getFile() . ':' . $e->getLine());
            return [];
        }
    }

    /**
     * The inbox preview line, from the design published for this email.
     *
     * @param array<string,mixed> $fields
     */
    private static function preheader(string $messageName, string $lang, array $fields): string
    {
        $design = Design::forTarget($messageName);
        if ($design === null || ($design['status'] ?? '') !== 'published') {
            return '';
        }
        // The published copy, not the saved document: a saved edit is a draft
        // until it is published. A design published before the copy was kept
        // has only its saved document.
        $doc  = is_array($design['published_doc'] ?? null) && $design['published_doc'] !== [] ? $design['published_doc'] : $design['doc'];
        $text = Merge::pick($doc['settings']['preheader'] ?? '', $lang);
        if (trim($text) === '') {
            return '';
        }
        // Some merge fields are HTML (a link, a signature). A preheader is
        // plain text, so whatever was substituted in is flattened.
        $text = Merge::substitute(Merge::stripLogic($text), $fields, false);
        return trim(html_entity_decode(strip_tags($text), ENT_QUOTES, 'UTF-8'));
    }

    /** Does the layout in use put the subject in its header? */
    private static function showsSubject(): bool
    {
        foreach ((array)(self::$layout['blocks'] ?? []) as $b) {
            if (($b['type'] ?? '') === 'header' && !empty($b['props']['subject'])) {
                return true;
            }
        }
        return false;
    }

    /**
     * The subject WHMCS is sending this email with: the template's row for the
     * recipient's language, else the default row. Merge fields are filled in
     * by the caller. An ad-hoc message has no subject here (its template row
     * is a generic one), so its header has no title rather than a wrong one.
     */
    /** @return array{0:string,1:string} [subject, template type] */
    private static function template(string $messageName, string $lang): array
    {
        if ($messageName === '' || $messageName === 'Mass Mail Template') {
            return ['', ''];
        }
        $key = $messageName . "\0" . $lang;
        if (!array_key_exists($key, self::$subjects)) {
            $q = static fn(string $l) => \WHMCS\Database\Capsule::table('tblemailtemplates')
                ->where('name', $messageName)->where('language', $l)->first(['subject', 'type']);
            $own  = $lang !== Bridge::defaultLanguage() ? $q($lang) : null;
            $base = $q('');
            $subject = trim((string)(($own->subject ?? '') ?: ($base->subject ?? '')));
            self::$subjects[$key] = [$subject, (string)($base->type ?? $own->type ?? '')];
        }
        return self::$subjects[$key];
    }

    /** For tests and for a save in the same request: forget the built layout. */
    public static function reset(): void
    {
        self::$parts    = [];
        self::$layout   = null;
        self::$subjects = [];
    }
}
