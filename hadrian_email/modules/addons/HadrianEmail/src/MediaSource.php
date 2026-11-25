<?php
declare(strict_types=1);

namespace HadrianEmail;

/**
 * Tells Hadrian's Media screen which library images the emails use.
 *
 * Hadrian does not record a use when an image is picked. It reads the places
 * an image address can be saved in and looks for library file names there
 * (Hadrian\Helpers\MediaUsage). This hands it those places for this module:
 * the appearance settings (the logos) and every design, both the draft and
 * the published copy.
 *
 * A design's backup of the WHMCS template it replaced is not read: that is
 * WHMCS's own content, and it is not being sent.
 */
final class MediaSource
{
    /** @return list<array{where:string,url:string,text:string}> */
    public static function rows(): array
    {
        $db  = '\\WHMCS\\Database\\Capsule';
        $out = [];

        try {
            $text = '';
            foreach ($db::table(Store::TABLE)->get(['value']) as $row) {
                $text .= (string)$row->value . "\n";
            }
            $out[] = ['where' => 'Email appearance settings', 'url' => AdminController::BASE, 'text' => $text];
        } catch (\Throwable $e) {
            // Module files present, never activated.
        }

        try {
            $designs = $db::table(Schema::DESIGNS)->get(['kind', 'name', 'target', 'doc', 'published']);
        } catch (\Throwable $e) {
            return $out;
        }
        foreach ($designs as $d) {
            $layout = (string)$d->kind === Blocks::KIND_LAYOUT;
            $out[] = [
                'where' => $layout ? 'Email layout' : 'Email "' . ((string)$d->name !== '' ? (string)$d->name : (string)$d->target) . '"',
                'url'   => AdminController::BASE . '&action=builder&' . ($layout ? 'layout=1' : 'target=' . rawurlencode((string)$d->target)),
                'text'  => (string)$d->doc . "\n" . (string)$d->published,
            ];
        }
        return $out;
    }
}
