<?php
declare(strict_types=1);

namespace HadrianEmail;

use WHMCS\Database\Capsule;

/**
 * Writes a message design into WHMCS's own email template, and takes it back
 * out again.
 *
 * Publishing is the native route on purpose. The compiled design becomes the
 * template's `message` in tblemailtemplates, so WHMCS evaluates the merge
 * fields and conditions itself, under its own mail security policy, and the
 * email keeps working if this addon is later switched off.
 *
 * What makes it safe to do to someone's live templates:
 *   - the rows are copied aside before the first write, and Restore puts them
 *     back exactly (and deletes any language row the publish had to create)
 *   - everything is compiled and linted before anything is written; a body
 *     WHMCS could not parse is never saved, because WHMCS does not send an
 *     email whose template fails to compile
 *   - a hash of each written body is kept, so a later edit in WHMCS's own
 *     editor shows up as "edited outside" instead of being overwritten
 */
final class Publisher
{
    private const TABLE = 'tblemailtemplates';

    /** Template types that never reach a client, so are never offered. */
    private const HIDDEN_TYPES = ['admin', 'admin_invite', 'notification'];

    private const TYPE_LABELS = [
        'general'   => 'General',
        'invoice'   => 'Invoices',
        'product'   => 'Products and services',
        'domain'    => 'Domains',
        'support'   => 'Support',
        'user'      => 'Users',
        'invite'    => 'Invitations',
        'affiliate' => 'Affiliates',
    ];

    /**
     * The client-facing WHMCS email templates, grouped by type.
     *
     * @return array<string, array{label:string, items:list<array{name:string,subject:string,disabled:bool,custom:bool}>}>
     */
    public static function templates(): array
    {
        $rows = Capsule::table(self::TABLE)
            ->where('language', '')
            ->whereNotIn('type', self::HIDDEN_TYPES)
            ->orderBy('name')
            ->get(['type', 'name', 'subject', 'disabled', 'custom']);

        $out = [];
        foreach (self::TYPE_LABELS as $type => $label) {
            $out[$type] = ['label' => $label, 'items' => []];
        }
        foreach ($rows as $r) {
            $type = (string)$r->type;
            $out[$type] ??= ['label' => ucfirst($type), 'items' => []];
            $out[$type]['items'][] = [
                'name'     => (string)$r->name,
                'subject'  => (string)$r->subject,
                'disabled' => (bool)$r->disabled,
                'custom'   => (bool)$r->custom,
            ];
        }
        return array_filter($out, static fn(array $g): bool => $g['items'] !== []);
    }

    /** The default-language row of one template, or null. */
    public static function template(string $name): ?object
    {
        if ($name === '') {
            return null;
        }
        $row = Capsule::table(self::TABLE)->where('name', $name)->where('language', '')
            ->whereNotIn('type', self::HIDDEN_TYPES)->first();
        return $row ?: null;
    }

    /**
     * Publish: the design as last saved goes live, and is kept as the
     * published copy.
     *
     * @return array{ok:bool, errors:list<string>, languages:list<string>}
     */
    public static function publish(int $designId): array
    {
        $design = Design::find($designId);
        if ($design === null || $design['kind'] !== Blocks::KIND_MESSAGE || (string)$design['target'] === '') {
            return self::fail('This design is not a message design.');
        }
        return self::write($design, (array)$design['doc'], true);
    }

    /**
     * Compile $source and write it into the WHMCS template.
     *
     * $saved: $source is the saved document (Publish), which is stored back
     * normalised. A recompile passes the published copy instead and leaves
     * the saved document, and any edit in it not yet published, as it is.
     *
     * @param array<string,mixed> $design
     * @param array<string,mixed> $source
     * @return array{ok:bool, errors:list<string>, languages:list<string>}
     */
    private static function write(array $design, array $source, bool $saved): array
    {
        $designId = (int)$design['id'];
        $target   = (string)$design['target'];
        $default  = self::template($target);
        if ($default === null) {
            return self::fail('WHMCS has no email template called "' . $target . '".');
        }

        $installed = Bridge::languages();
        $doc       = Blocks::normalize($source, Blocks::KIND_MESSAGE, $installed);
        if ($doc['blocks'] === []) {
            return self::fail('Add at least one block before publishing.');
        }
        $theme       = Theme::load();
        $defaultLang = Bridge::defaultLanguage();

        // '' is WHMCS's own key for the default-language row.
        $languages = array_merge([''], array_values(array_diff(self::languagesUsed($doc), [$defaultLang])));

        // 1. Compile everything. Nothing is written until all of it is clean.
        $compiled = [];
        foreach ($languages as $lang) {
            $html   = Renderer::compileMessage($theme, $doc, $lang === '' ? $defaultLang : $lang);
            $errors = Merge::lint($html);
            if ($errors !== []) {
                return ['ok' => false, 'languages' => [], 'errors' => array_map(
                    static fn(string $e): string => ($lang === '' ? '' : ucfirst($lang) . ': ') . $e,
                    $errors
                )];
            }
            $subject = trim(Merge::pick($doc['settings']['subject'], $lang === '' ? $defaultLang : $lang));
            if ($lang !== '' && !isset($doc['settings']['subject'][$lang])) {
                $subject = '';      // no translated subject: leave that row's own
            }
            $compiled[$lang] = ['message' => $html, 'subject' => $subject !== '' ? Merge::protect($subject) : ''];
        }

        // 2. Write, all or nothing.
        $backup    = is_array($design['backup']) ? $design['backup'] : [];
        $previous  = is_array($design['published']) ? $design['published'] : [];
        $published = [];
        $now       = date('Y-m-d H:i:s');

        Capsule::connection()->transaction(function () use ($target, $default, $compiled, &$backup, &$published, $previous, $now): void {
            foreach ($compiled as $lang => $c) {
                $row = Capsule::table(self::TABLE)->where('name', $target)->where('language', $lang)->first();

                if (!array_key_exists($lang, $backup)) {
                    $backup[$lang] = $row
                        ? ['created' => false, 'subject' => (string)$row->subject, 'message' => (string)$row->message, 'plaintext' => (int)$row->plaintext]
                        : ['created' => true];
                }

                $data = ['message' => $c['message'], 'plaintext' => 0, 'updated_at' => $now];
                if ($c['subject'] !== '') {
                    $data['subject'] = $c['subject'];
                }
                if ($row) {
                    Capsule::table(self::TABLE)->where('id', $row->id)->update($data);
                    $rowId = (int)$row->id;
                } else {
                    // A language WHMCS has no row for yet: copy the default
                    // row's settings so it sends from the same address.
                    $rowId = (int)Capsule::table(self::TABLE)->insertGetId($data + [
                        'type'          => (string)$default->type,
                        'name'          => $target,
                        'subject'       => (string)$default->subject,
                        'attachments'   => (string)$default->attachments,
                        'fromname'      => (string)$default->fromname,
                        'fromemail'     => (string)$default->fromemail,
                        'disabled'      => (int)$default->disabled,
                        'custom'        => (int)$default->custom,
                        'language'      => $lang,
                        'copyto'        => (string)$default->copyto,
                        'blind_copy_to' => (string)$default->blind_copy_to,
                        'created_at'    => $now,
                    ]);
                }
                $published[$lang] = ['rowId' => $rowId, 'hash' => sha1($c['message'])];
            }

            // A language that was published before and has since lost its
            // translations goes back to how it was.
            foreach (array_diff(array_keys($previous), array_keys($compiled)) as $gone) {
                self::restoreRow($target, (string)$gone, $backup[$gone] ?? null);
                unset($backup[$gone]);
            }
        });

        Design::update($designId, ($saved ? ['doc' => $doc] : []) + [
            'published_doc' => $doc,
            'status'        => 'published',
            'published'     => $published,
            'backup'        => $backup,
            'published_at'  => $now,
        ]);

        return ['ok' => true, 'errors' => [], 'languages' => array_map(
            static fn(string $l): string => $l === '' ? $defaultLang : $l,
            array_keys($published)
        )];
    }

    /**
     * Put the WHMCS template back the way it was before the first publish.
     *
     * @return array{ok:bool, errors:list<string>, languages:list<string>}
     */
    public static function restore(int $designId): array
    {
        $design = Design::find($designId);
        if ($design === null || $design['kind'] !== Blocks::KIND_MESSAGE) {
            return self::fail('This design is not a message design.');
        }
        $target = (string)$design['target'];
        $backup = is_array($design['backup']) ? $design['backup'] : [];

        Capsule::connection()->transaction(function () use ($target, $backup): void {
            foreach ($backup as $lang => $b) {
                self::restoreRow($target, (string)$lang, is_array($b) ? $b : null);
            }
        });

        Design::update($designId, ['status' => 'draft', 'published_doc' => null, 'published' => null, 'backup' => null, 'published_at' => null]);
        return ['ok' => true, 'errors' => [], 'languages' => array_map('strval', array_keys($backup))];
    }

    /** @param array<string,mixed>|null $b */
    private static function restoreRow(string $target, string $lang, ?array $b): void
    {
        if ($b === null) {
            return;
        }
        $q = Capsule::table(self::TABLE)->where('name', $target)->where('language', $lang);
        if (!empty($b['created'])) {
            // Never the default row: WHMCS needs it to send the email at all.
            if ($lang !== '') {
                $q->delete();
            }
            return;
        }
        $q->update([
            'subject'    => (string)($b['subject'] ?? ''),
            'message'    => (string)($b['message'] ?? ''),
            'plaintext'  => (int)($b['plaintext'] ?? 0),
            'updated_at' => date('Y-m-d H:i:s'),
        ]);
    }

    /**
     * Languages whose published body is no longer the one we wrote: someone
     * saved the template in WHMCS's own editor.
     *
     * @param array<string,mixed> $design
     * @return list<string>
     */
    public static function drift(array $design): array
    {
        $published = is_array($design['published'] ?? null) ? $design['published'] : [];
        if ($published === [] || ($design['status'] ?? '') !== 'published') {
            return [];
        }
        $rows = Capsule::table(self::TABLE)->where('name', (string)$design['target'])->get(['language', 'message']);
        $now  = [];
        foreach ($rows as $r) {
            $now[(string)$r->language] = sha1((string)$r->message);
        }
        $out = [];
        foreach ($published as $lang => $p) {
            if (($now[(string)$lang] ?? null) !== ($p['hash'] ?? '')) {
                $out[] = (string)$lang === '' ? Bridge::defaultLanguage() : (string)$lang;
            }
        }
        return $out;
    }

    /**
     * Recompile every published design, after the theme's colours or the
     * email appearance changed: a button's colour is written into the body.
     *
     * Each is recompiled from its published copy, never from the saved
     * document: an edit saved but not published stays a draft. Left alone:
     * designs edited outside, and designs published before the copy was kept
     * (their saved document may hold such an edit; publishing them once keeps
     * a copy, and the builder shows them as having unpublished changes).
     */
    public static function republishAll(): int
    {
        $count = 0;
        foreach (Design::published() as $design) {
            $live = $design['published_doc'] ?? [];
            if (!is_array($live) || $live === [] || self::drift($design) !== []) {
                continue;
            }
            if (self::write($design, $live, false)['ok']) {
                $count++;
            }
        }
        return $count;
    }

    /**
     * Every language a document carries a translation for.
     *
     * @param array<string,mixed> $doc
     * @return list<string>
     */
    public static function languagesUsed(array $doc): array
    {
        $found = [];
        $walk  = static function (mixed $v) use (&$walk, &$found): void {
            if (!is_array($v)) {
                return;
            }
            if (array_key_exists('_', $v)) {
                foreach ($v as $lang => $text) {
                    if ($lang !== '_' && is_string($text) && trim($text) !== '') {
                        $found[(string)$lang] = true;
                    }
                }
                return;
            }
            foreach ($v as $child) {
                $walk($child);
            }
        };
        $walk($doc['blocks'] ?? []);
        $walk($doc['settings'] ?? []);
        $langs = array_keys($found);
        sort($langs);
        return $langs;
    }

    /** @return array{ok:bool, errors:list<string>, languages:list<string>} */
    private static function fail(string $message): array
    {
        return ['ok' => false, 'errors' => [$message], 'languages' => []];
    }
}
