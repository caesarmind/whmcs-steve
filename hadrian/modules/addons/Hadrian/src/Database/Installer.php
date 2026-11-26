<?php
declare(strict_types=1);

namespace Hadrian\Database;

use Hadrian\Helpers\Uploader;
use Hadrian\Menu\Seeder;
use Hadrian\Template\LayoutsCache;
use Hadrian\Template\PagesCache;
use Hadrian\Template\Template;

/**
 * Everything the addon needs in the database and on disk before it can run:
 * its tables, the preset menus, the page and layout discovery caches, and the
 * branding upload folder.
 *
 * One place, because three callers need exactly this and used to carry their
 * own copy: activation, a version upgrade, and the "Run now" button on the
 * Setup page.
 *
 * Safe to run any number of times. The Migrator records what it has run, the
 * Seeder skips a menu that already exists, the caches are rebuilt from disk,
 * and the Uploader only writes its .htaccess when there is none.
 */
final class Installer
{
    /**
     * @return list<string> things that did not work but do not stop the addon
     *                      from running, in words an admin can act on
     * @throws \Throwable when the tables or the preset menus could not be
     *                    created; nothing works without those
     */
    public static function run(string $addonRoot): array
    {
        (new Migrator($addonRoot))->migrate();
        (new Seeder())->run();

        $notes = [];

        // The Pages and Layouts screens read these caches. The filesystem scan
        // happens here, never during a client-area request.
        foreach (Template::getAll() as $tpl) {
            try {
                PagesCache::rebuild($tpl);
                LayoutsCache::rebuild($tpl);
            } catch (\Throwable $e) {
                error_log('Hadrian: discovery rebuild failed for ' . $tpl->getName() . ': ' . $e->getMessage());
                $notes[] = 'The page list for ' . $tpl->getName() . ' could not be rebuilt: ' . $e->getMessage();
            }
        }

        // Not fatal: the Uploader tries again on the first upload. Doing it
        // here surfaces a permissions problem now instead of at upload time.
        try {
            if (!(new Uploader())->prepareStorage()) {
                error_log('Hadrian: branding storage dir not writable. '
                    . 'Check filesystem permissions on templates/hadrian/assets/img/branding/');
                $notes[] = 'templates/hadrian/assets/img/branding is not writable, so logo uploads will fail.';
            }
        } catch (\Throwable $e) {
            error_log('Hadrian: branding storage prep failed: ' . $e->getMessage());
            $notes[] = 'The branding upload folder could not be prepared: ' . $e->getMessage();
        }

        return $notes;
    }
}
