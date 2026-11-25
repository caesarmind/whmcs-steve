<?php
declare(strict_types=1);

namespace Hadrian\Controller\Admin;

use Hadrian\Controller\AbstractController;
use Hadrian\Helpers\MediaLibrary;
use Hadrian\Helpers\MediaOptimizer;

/**
 * Admin: the Media screen (?module=Hadrian&action=media).
 *
 * The page for looking after the library that the picker fills: find an
 * image, see where it is used, rename it, make it smaller, delete what is
 * left over. It draws the frame only. Everything in it is loaded and changed
 * through MediaController's JSON endpoints, the same ones the picker uses, so
 * there is one implementation of upload, list and delete.
 *
 * Separate from MediaController on purpose: that one answers JSON and must
 * not build a Smarty instance or be able to redirect (see its header).
 */
final class MediaScreenController extends AbstractController
{
    public function indexAction(): string
    {
        $cfg = MediaLibrary::config(MediaLibrary::DEFAULT_COLLECTION);

        // Inlined like the customizer's script, so the page does not depend
        // on the addon's assets folder being reachable from the web.
        $script = (string)@file_get_contents(dirname(__DIR__, 3) . '/views/adminarea/assets/js/media.js');

        $boot = [
            'collection' => MediaLibrary::DEFAULT_COLLECTION,
            'endpoint'   => '?module=Hadrian&action=media&sub=',
            // WHMCS only prints its token into pages that have a POST form.
            // This page has none, so the script gets it here.
            'token'      => \Hadrian\Helpers\AdminCsrf::token(),
            'maxFiles'   => MediaController::MAX_FILES,
            'maxBytes'   => (int)$cfg['maxBytes'],
            'accept'     => (string)$cfg['accept'],
            'maxEdge'    => MediaOptimizer::MAX_EDGE,
        ];

        return $this->view('media/index', [
            'mediaJson'      => json_encode($boot, JSON_HEX_TAG | JSON_HEX_AMP | JSON_HEX_APOS | JSON_HEX_QUOT | JSON_UNESCAPED_SLASHES),
            'mediaJs'        => $script,
            'mediaOptimizer' => MediaOptimizer::available(),
            'mediaOptimize'  => MediaLibrary::optimizesUploads(),
            'mediaQuality'   => MediaLibrary::quality(),
            'mediaQualities' => MediaLibrary::QUALITIES,
            'mediaMaxEdge'   => MediaLibrary::maxEdge(),
            'mediaMaxEdges'  => MediaLibrary::MAX_EDGES,
            'mediaMaxFiles'  => MediaController::MAX_FILES,
        ]);
    }
}
