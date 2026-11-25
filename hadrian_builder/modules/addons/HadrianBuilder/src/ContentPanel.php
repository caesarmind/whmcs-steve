<?php
declare(strict_types=1);

namespace HadrianBuilder;

/**
 * A built page's sections as a list, at the top of its settings in Hadrian's
 * Pages screen (the extension point's contentPanel slot).
 *
 * For people who would rather fill in forms than work on the page itself: the
 * sections in order, each opened in place to edit its fields, dragged to
 * reorder, hidden, duplicated or removed, and an "Add section" dialog with the
 * same categories as the visual editor.
 *
 * It edits the same draft the visual editor edits, through the same field
 * controls (views/assets/js/fields.js) and the same schemas, so a change made
 * in either place shows in the other. Saving writes the draft only
 * (AdminController api-content); Publish makes it live, as in the editor.
 *
 * Everything here is drawn by content-list.js from the boot data printed
 * below. Hadrian prints this HTML first in the main column of a page's
 * settings, beside SEO, which puts it inside its settings form. No control
 * here may have a name= attribute, or it would post with Save changes.
 */
final class ContentPanel
{
    public static function render(int $id): string
    {
        if (!Bridge::available()) {
            return '';
        }
        $page = Page::find($id);
        if ($page === null) {
            return '';
        }
        $slug = (string)$page['slug'];
        $boot = AdminController::sectionKit() + [
            'id'          => $id,
            'doc'         => Document::normalize((array)$page['draft'], Bridge::languages()),
            'status'      => (string)$page['status'],
            'changed'     => Page::hasUnpublishedChanges($page),
            'pageUrl'     => $slug !== '' ? Router::urlFor($slug) : '',
            'editUrl'     => AdminController::BASE . '&action=edit&id=' . $id,
            'previewPath' => Router::previewUrlFor($id),
            'api'         => AdminController::BASE,
            'token'       => AdminController::adminToken(),
        ];
        $json = (string)json_encode($boot, JSON_HEX_TAG | JSON_HEX_AMP | JSON_HEX_APOS | JSON_HEX_QUOT | JSON_UNESCAPED_SLASHES | JSON_INVALID_UTF8_SUBSTITUTE);
        $e    = static fn(string $s): string => htmlspecialchars($s, ENT_QUOTES, 'UTF-8');

        return '<style>' . AdminController::asset('css/fields.css') . "\n" . AdminController::asset('css/content-list.css') . '</style>'
            . '<div class="hbx hbc" id="hbc">'
            .   '<div class="hbc-head">'
            .     '<div class="hbc-title">'
            .       '<div class="mt-subhead" style="margin:0">Content</div>'
            .       '<p class="hbc-sub">The sections on this page, top to bottom. Drag to reorder, or open one to edit it.</p>'
            .     '</div>'
            .     '<div class="hbc-tools">'
            .       '<select class="hbc-lang" id="hbc-lang" aria-label="Language"></select>'
            .       '<span class="mt-badge mt-badge-neutral" id="hbc-status"></span>'
            .       '<button type="button" class="mt-btn mt-btn-ghost mt-btn-sm" id="hbc-preview">Preview</button>'
            .       '<a class="mt-btn mt-btn-ghost mt-btn-sm" id="hbc-visual" href="' . $e((string)$boot['editUrl']) . '">Open visual editor</a>'
            .       '<button type="button" class="mt-btn mt-btn-secondary mt-btn-sm" id="hbc-save" disabled>Save draft</button>'
            .       '<button type="button" class="mt-btn mt-btn-primary mt-btn-sm" id="hbc-publish">Publish</button>'
            .     '</div>'
            .   '</div>'
            .   '<div class="hbc-notice" id="hbc-notice" aria-live="polite"></div>'
            .   '<ol class="hbc-list" id="hbc-list"></ol>'
            .   '<button type="button" class="hbx-add-wide" id="hbc-add">'
            .     '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M12 5v14M5 12h14"/></svg>Add section'
            .   '</button>'
            .   '<div class="mt-modal hbc-modal" id="hbc-modal" hidden>'
            .     '<div class="mt-modal-card" role="dialog" aria-modal="true" aria-labelledby="hbc-modal-title">'
            .       '<div class="mt-modal-head">'
            .         '<div><div class="mt-modal-title" id="hbc-modal-title">Add a section</div><div class="mt-modal-sub" id="hbc-modal-sub"></div></div>'
            .         '<button type="button" class="mt-modal-x" id="hbc-modal-x" aria-label="Close">&times;</button>'
            .       '</div>'
            .       '<div class="mt-modal-tools"><label class="hbx-search" style="margin:0;flex:1">'
            .         '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><circle cx="11" cy="11" r="6.5"/><path d="M16 16l4.5 4.5"/></svg>'
            .         '<input type="search" class="mt-input" id="hbc-q" placeholder="Search sections" aria-label="Search sections" autocomplete="off">'
            .       '</label></div>'
            .       '<div class="hbc-pick">'
            .         '<div class="mt-modal-body" id="hbc-modal-body"></div>'
            // What the pointed-at section looks like, drawn by the theme with
            // its default content (Router::sample), before it is added.
            .         '<aside class="hbc-peek is-empty" id="hbc-peek" aria-label="Section preview">'
            .           '<div class="hbc-peek-head" id="hbc-peek-head"><b>Preview</b><small>Point at a section, or press its eye button, to see it as your theme draws it.</small></div>'
            .           '<div class="hbc-peek-box" id="hbc-peek-box"><iframe id="hbc-peek-frame" title="Section preview" tabindex="-1"></iframe></div>'
            .           '<button type="button" class="mt-btn mt-btn-primary mt-btn-sm" id="hbc-peek-add" hidden>Add section</button>'
            .         '</aside>'
            .       '</div>'
            .     '</div>'
            .   '</div>'
            . '</div>'
            . '<script type="application/json" id="hbc-boot">' . $json . '</script>'
            . '<script>' . AdminController::asset('js/fields.js') . "\n" . AdminController::asset('js/content-list.js') . '</script>';
    }
}
