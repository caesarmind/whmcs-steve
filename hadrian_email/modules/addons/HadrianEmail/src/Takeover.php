<?php
declare(strict_types=1);

namespace HadrianEmail;

/**
 * Owns the three WHMCS mail settings while Hadrian email is on:
 *   EmailGlobalHeader, EmailGlobalFooter, EmailCSS (General Settings > Mail).
 *
 * WHMCS has no hook that can rewrite an outgoing body. What it does offer is
 * a global header and footer that are compiled together with the body, and an
 * EmailPreSend hook that can add merge fields. So the header and footer are
 * replaced with a placeholder for a merge field the hook fills in.
 *
 * The placeholder is GUARDED:
 *
 *   {if $hadrian_email_header}{$hadrian_email_header}{else} ...static header... {/if}
 *
 * If the hook does not answer -- the addon is deactivated, its files are
 * mid-upload, the renderer throws -- the {else} branch is a complete header in
 * the default language. A bare {$placeholder} would send the email with no
 * header, no footer and no styles at all.
 *
 * The originals are kept in this module's own settings table (not Hadrian's:
 * see Store), and a hash of what was written is kept beside them, so an edit made in WHMCS's own Mail tab is noticed
 * rather than silently overwritten.
 */
final class Takeover
{
    public const ENABLED_KEY   = 'enabled';
    public const BACKUP_KEY    = 'whmcs_backup';
    public const WRITTEN_KEY   = 'whmcs_written';
    public const SIGNATURE_KEY = 'signature';

    public const HEADER_FIELD = 'hadrian_email_header';
    public const FOOTER_FIELD = 'hadrian_email_footer';

    private const KEYS = ['EmailGlobalHeader', 'EmailGlobalFooter', 'EmailCSS'];

    private const CSS_NOTE = '/* Managed by Hadrian Email Templates. Edit the design under Addons > Hadrian Email Templates. */';

    public static function isEnabled(): bool
    {
        try {
            return (bool)Store::get(self::ENABLED_KEY, false);
        } catch (\Throwable $e) {
            return false;
        }
    }

    /** The layout in use, normalised; the built-in default when none is saved. */
    public static function layoutDoc(): array
    {
        $row = Design::layout();
        return Blocks::normalize(
            $row !== null ? (array)$row['doc'] : Presets::layout(),
            Blocks::KIND_LAYOUT,
            Bridge::languages()
        );
    }

    /**
     * Turn Hadrian email on: keep the originals, then write the placeholders.
     */
    public static function enable(): void
    {
        $backup = Store::get(self::BACKUP_KEY, null);
        if (!is_array($backup) || $backup === []) {
            // First enable, or first since a disable. Never overwrite a held
            // backup: on a second enable WHMCS holds OUR values, and backing
            // those up would lose the admin's originals for good.
            $backup = ['at' => date('Y-m-d H:i:s')];
            foreach (self::KEYS as $k) {
                $backup[$k] = self::read($k);
            }
            Store::set(self::BACKUP_KEY, $backup);
        }
        Store::set(self::ENABLED_KEY, true);
        self::refresh(true);
    }

    /**
     * Turn it off and put the originals back.
     *
     * $keepEdited leaves any setting that was changed in WHMCS after we wrote
     * it: that edit is newer than the backup, and restoring over it would
     * undo something the admin did on purpose.
     */
    public static function disable(bool $keepEdited = false): void
    {
        $backup  = Store::get(self::BACKUP_KEY, null);
        $drifted = $keepEdited ? self::drift() : [];
        if (is_array($backup)) {
            foreach (self::KEYS as $k) {
                if (in_array($k, $drifted, true) || !array_key_exists($k, $backup)) {
                    continue;
                }
                self::write($k, $backup[$k] === null ? '' : (string)$backup[$k]);
            }
        }
        Store::set(self::ENABLED_KEY, false);
        Store::forget(self::BACKUP_KEY);
        Store::forget(self::WRITTEN_KEY);
    }

    /**
     * Rewrite the placeholders from the current layout and theme.
     *
     * A setting someone edited in WHMCS is skipped unless $force, so a
     * background refresh never tramples that edit; status() reports it and the
     * admin chooses.
     *
     * @return list<string> the settings that were written
     */
    public static function refresh(bool $force = false): array
    {
        if (!self::isEnabled()) {
            return [];
        }
        $theme = Theme::load();
        [$header, $footer] = Renderer::fallback($theme, self::layoutDoc());

        // WHMCS stores these two entity-encoded and decodes them once on use
        // (measured). Matching that keeps a round trip through its own Mail
        // tab byte-identical, so the drift check does not fire on a no-op save.
        $values = [
            'EmailGlobalHeader' => htmlspecialchars(
                '{if $' . self::HEADER_FIELD . '}{$' . self::HEADER_FIELD . '}{else}' . $header . '{/if}',
                ENT_QUOTES,
                'UTF-8'
            ),
            'EmailGlobalFooter' => htmlspecialchars(
                '{if $' . self::FOOTER_FIELD . '}{$' . self::FOOTER_FIELD . '}{else}' . $footer . '{/if}',
                ENT_QUOTES,
                'UTF-8'
            ),
            'EmailCSS' => self::CSS_NOTE,
        ];

        $drifted = $force ? [] : self::drift();
        $written = Store::get(self::WRITTEN_KEY, []);
        $written = is_array($written) ? $written : [];
        $changed = [];
        foreach ($values as $k => $v) {
            if (in_array($k, $drifted, true)) {
                continue;
            }
            if (self::read($k) !== $v) {
                self::write($k, $v);
                $changed[] = $k;
            }
            $written[$k] = sha1($v);
        }
        Store::set(self::WRITTEN_KEY, $written);
        return $changed;
    }

    /**
     * Settings whose value in WHMCS is no longer what we wrote.
     *
     * @return list<string>
     */
    public static function drift(): array
    {
        if (!self::isEnabled()) {
            return [];
        }
        $written = Store::get(self::WRITTEN_KEY, []);
        if (!is_array($written) || $written === []) {
            return [];
        }
        $out = [];
        foreach (self::KEYS as $k) {
            if (isset($written[$k]) && sha1((string)self::read($k)) !== $written[$k]) {
                $out[] = $k;
            }
        }
        return $out;
    }

    /**
     * True when the brand or the layout changed since everything compiled from
     * them was last brought up to date. Independent of whether the takeover is
     * on: a design published while it is off still has the old button colour
     * written into its body.
     */
    public static function isStale(): bool
    {
        return (string)Store::get(self::SIGNATURE_KEY, '') !== self::signature(Theme::load());
    }

    /** Record that the placeholders and every published body match the current brand. */
    public static function markFresh(): void
    {
        Store::set(self::SIGNATURE_KEY, self::signature(Theme::load()));
    }

    /**
     * One hash over everything the static fallback is built from.
     *
     * @param array<string,mixed> $theme
     */
    public static function signature(array $theme): string
    {
        return sha1((string)json_encode([$theme, self::layoutDoc(), date('Y')]));
    }

    /** @return array{enabled:bool, drift:list<string>, hasBackup:bool, backupAt:string} */
    public static function status(): array
    {
        $backup = Store::get(self::BACKUP_KEY, null);
        return [
            'enabled'   => self::isEnabled(),
            'drift'     => self::drift(),
            'hasBackup' => is_array($backup) && $backup !== [],
            'backupAt'  => is_array($backup) ? (string)($backup['at'] ?? '') : '',
        ];
    }

    // ---------------------------------------------------- WHMCS settings I/O

    private static function read(string $key): ?string
    {
        // Straight from the table: WHMCS's Setting cache is per-process and
        // this must see what another request (the Mail tab) just saved.
        return Bridge::config($key);
    }

    private static function write(string $key, string $value): void
    {
        Bridge::setConfig($key, $value);
    }
}
