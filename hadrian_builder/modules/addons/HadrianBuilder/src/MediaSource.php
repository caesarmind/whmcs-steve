<?php
declare(strict_types=1);

namespace HadrianBuilder;

/**
 * Tells Hadrian's Media screen which library images built pages use.
 *
 * Hadrian does not record a use when an image is picked. It reads the places
 * an image address can be saved in and looks for library file names there
 * (Hadrian\Helpers\MediaUsage). This hands it those places for this module:
 * each page's draft, its published copy and its meta, as stored.
 *
 * A page counts whether the image is in its draft or in what visitors see.
 * Deleting an image that only a draft uses would still leave a hole in the
 * page the next time it is published.
 */
final class MediaSource
{
    /** @return list<array{where:string,url:string,text:string}> */
    public static function rows(): array
    {
        $out = [];
        try {
            $pages = \WHMCS\Database\Capsule::table(Schema::PAGES)->get(['id', 'name', 'draft', 'published', 'meta']);
        } catch (\Throwable $e) {
            return [];                           // module files present, table not made yet
        }
        foreach ($pages as $page) {
            $out[] = [
                'where' => 'Built page "' . (string)$page->name . '"',
                'url'   => AdminController::BASE . '&action=edit&id=' . (int)$page->id,
                'text'  => (string)$page->draft . "\n" . (string)$page->published . "\n" . (string)$page->meta,
            ];
        }
        return $out;
    }
}
