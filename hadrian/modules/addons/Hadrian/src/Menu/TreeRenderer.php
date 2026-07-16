<?php
declare(strict_types=1);

namespace Hadrian\Menu;

use Hadrian\Models\Menu;
use Hadrian\Models\MenuItem;
use WHMCS\View\Menu\Item;

/**
 * Walks a Menu tree and populates a WHMCS\View\Menu\Item (the $primaryNavbar
 * passed into the ClientAreaPrimaryNavbar hook). One static entry point —
 * TreeRenderer::populate($primaryNavbar, $menu).
 *
 * The renderer respects three layers of filtering on every node:
 *   1. MenuItem::active                      (toggled per-item by the admin)
 *   2. config.audience ('client'|'guest'|'all')   (per-item audience override)
 *   3. config.theme_layouts (array)          (only show on top|side|rail)
 *
 * Layout filter notes: theme_layouts is checked against the body's
 * data-layout attribute. That attribute isn't known at hook time (it's set
 * later by header.tpl), so we expose it via session/cookie. If the array is
 * empty or missing, the item shows on all layouts.
 */
final class TreeRenderer
{
    /**
     * Monotonically increasing counter for setOrder(). The previous version
     * used $node->position, which is per-parent (every level resets to 0,1,2…)
     * — that confused WHMCS's getChildren() sort and put all-position-0 items
     * (headers, first sibling at each level) ahead of higher-position items.
     * Using a single global counter that grows in the natural rendering order
     * keeps insertion order intact across the whole tree.
     */
    private static int $orderCounter = 0;

    /**
     * Flat ordered list of top-level items collected during populate(). The
     * sidebar/topnav templates iterate THIS instead of
     * $primaryNavbar->getChildren() because WHMCS\View\Menu\Item's getChildren()
     * reorders items in ways we can't predict (headers grouped, dropdowns
     * bucketed, etc.) — even with consistent setOrder() values across every
     * item. Building our own flat list bypasses that entirely.
     *
     * Each entry is the WHMCS Item we created via addChild, in the exact
     * order TreeRenderer added them. Children of dropdowns stay attached to
     * their parent Item (still accessible via getChildren on the dropdown).
     */
    private static array $orderedTopLevel = [];

    public static function populate(Item $parent, Menu $menu): void
    {
        $audience = $menu->audience === Audience::ALL ? Audience::current() : $menu->audience;
        $layout   = self::currentLayout();

        // Reset per-render so two menus on the same page (primary + secondary)
        // each start from zero.
        self::$orderCounter   = 0;
        self::$orderedTopLevel = [];

        foreach ($menu->topLevelItems() as $node) {
            try {
                $itemBefore = count($parent->getChildren());
                self::renderNode($parent, $node, $audience, $layout);
                // Capture whatever child WHMCS minted for this top-level
                // node, by diffing the children-set before and after. This
                // is more robust than grabbing $parent->getChild(keyFor())
                // because the child may have been filtered out (inactive,
                // wrong audience, etc.) — in which case we want to skip it
                // in the flat list too.
                $childrenNow = $parent->getChildren();
                if (count($childrenNow) > $itemBefore) {
                    $key  = self::keyFor($node);
                    $made = $childrenNow[$key] ?? null;
                    if ($made !== null) {
                        self::$orderedTopLevel[] = $made;
                    }
                }
            } catch (\Throwable $e) {
                // One broken item must never kill the rest of the menu.
                error_log(sprintf(
                    'Hadrian TreeRenderer: skipped item id=%d type=%s — %s',
                    $node->id,
                    $node->item_type,
                    $e->getMessage()
                ));
            }
        }
    }

    /**
     * Returns the flat ordered list of top-level Items rendered by the most
     * recent populate() call. The sidebar/topnav templates use this to
     * iterate in the correct order — bypassing the WHMCS Menu Item children
     * map that reorders by criteria we can't control.
     */
    public static function orderedTopLevel(): array
    {
        return self::$orderedTopLevel;
    }

    /**
     * Build a flat ordered list of menu items as plain PHP arrays — NO
     * dependency on WHMCS\View\Menu\Item. Each entry has every field the
     * sidebar/topnav template needs:
     *
     *   [
     *     'type'           => 'header'|'custom_link'|'dropdown_parent'|...,
     *     'name'           => 'mt-<id>',
     *     'label'          => 'Home',
     *     'uri'            => '/clientarea.php',
     *     'icon'           => 'home',
     *     'color'          => 'blue',
     *     'side'           => 'right'|'',
     *     'css_class'      => '',
     *     'badge_source'   => '',
     *     'dropdown_style' => 'default'|'mega'|'',
     *     'children'       => [ ... same shape, for dropdowns ],
     *   ]
     *
     * Called from the ClientAreaPage hook (not the navbar hook) so the data
     * is ready BEFORE template render, regardless of hook order.
     */
    public static function buildFlatList(Menu $menu): array
    {
        $audience = $menu->audience === Audience::ALL ? Audience::current() : $menu->audience;
        $layout   = self::currentLayout();
        $out = [];
        foreach ($menu->topLevelItems() as $node) {
            try {
                $entry = self::nodeToArray($node, $audience, $layout);
                if ($entry !== null) {
                    $out[] = $entry;
                }
            } catch (\Throwable $e) {
                error_log(sprintf(
                    'Hadrian buildFlatList: skipped item id=%d type=%s — %s',
                    $node->id, $node->item_type, $e->getMessage()
                ));
            }
        }
        return $out;
    }

    /**
     * Convert a single MenuItem (with descendants) into the plain-array
     * shape buildFlatList returns. Returns null if the item should be
     * filtered out (inactive, wrong audience, wrong layout, ...).
     */
    private static function nodeToArray(MenuItem $node, string $audience, string $layout): ?array
    {
        if (!$node->active) return null;
        $config = $node->config();

        $nodeAudience = (string)($config['audience'] ?? Audience::ALL);
        if (!self::audienceAllows($nodeAudience, $audience)) return null;

        $layouts = (array)($config['theme_layouts'] ?? []);
        if (!empty($layouts) && !in_array($layout, $layouts, true)) return null;

        $meta = ItemTypes::meta($node->item_type);
        if (!empty($meta['guest_only']) && $audience !== Audience::GUEST) return null;
        if (!empty($meta['client_only']) && $audience !== Audience::CLIENT) return null;

        // Skip whmcs_default — that's a passthrough item type that only
        // makes sense in the WHMCS Item tree, not in our flat list.
        if ($node->item_type === ItemTypes::WHMCS_DEFAULT) return null;

        $uri = '#';
        if ($node->item_type === ItemTypes::WHMCS_PAGE) {
            $uri = self::resolvePageUrl((string)($config['page'] ?? ''));
            if ($uri === '') return null;
        } elseif ($node->item_type === ItemTypes::CUSTOM_LINK) {
            $uri = (string)($config['url'] ?? '#');
        } elseif ($node->item_type === ItemTypes::LOGIN_BUTTON) {
            $uri = self::loginUrl();
        }

        // Auto-cycle palette colour by item id (override-able via config.color)
        $palette = ['blue','purple','teal','green','orange','red','pink','indigo','gray'];
        $color   = (string)($config['color'] ?? '');
        if ($color === '') {
            $color = $palette[((int)$node->id) % count($palette)];
        }

        $children = [];
        if ($node->item_type === ItemTypes::DROPDOWN_PARENT
            || $node->item_type === ItemTypes::ACCOUNT_DROPDOWN) {
            foreach ($node->children as $childNode) {
                try {
                    $childEntry = self::nodeToArray($childNode, $audience, $layout);
                    if ($childEntry !== null) {
                        $children[] = $childEntry;
                    }
                } catch (\Throwable $e) {
                    error_log(sprintf(
                        'Hadrian buildFlatList: skipped child id=%d — %s',
                        $childNode->id, $e->getMessage()
                    ));
                }
            }
        }

        return [
            'type'           => $node->item_type,
            'name'           => 'mt-' . $node->id,
            'label'          => $node->resolvedLabel(),
            'uri'            => $uri,
            'icon'           => (string)($config['icon'] ?? ''),
            'color'          => $color,
            'side'           => ($config['position_side'] ?? '') === 'right' ? 'right' : '',
            'css_class'      => (string)($config['css_class'] ?? ''),
            'badge_source'   => (string)($config['badge_source'] ?? ''),
            'dropdown_style' => (string)($config['dropdown_style'] ?? ''),
            'target'         => ($config['target'] ?? '') === '_blank' ? '_blank' : '',
            'children'       => $children,
        ];
    }

    private static function renderNode(Item $parent, MenuItem $node, string $audience, string $layout): void
    {
        if (!$node->active) {
            return;
        }
        $config = $node->config();

        // Per-item audience override
        $nodeAudience = (string)($config['audience'] ?? Audience::ALL);
        if (!self::audienceAllows($nodeAudience, $audience)) {
            return;
        }

        // Layout filter
        $layouts = (array)($config['theme_layouts'] ?? []);
        if (!empty($layouts) && !in_array($layout, $layouts, true)) {
            return;
        }

        // Hard guest/client lock from the type registry (e.g. login_button is guest-only)
        $meta = ItemTypes::meta($node->item_type);
        if (!empty($meta['guest_only']) && $audience !== Audience::GUEST) {
            return;
        }
        if (!empty($meta['client_only']) && $audience !== Audience::CLIENT) {
            return;
        }

        switch ($node->item_type) {
            case ItemTypes::WHMCS_PAGE:        self::renderWhmcsPage($parent, $node, $audience, $layout);       break;
            case ItemTypes::CUSTOM_LINK:       self::renderCustomLink($parent, $node, $audience, $layout);      break;
            case ItemTypes::DROPDOWN_PARENT:   self::renderDropdown($parent, $node, $audience, $layout);        break;
            case ItemTypes::HEADER:            self::renderHeader($parent, $node);                              break;
            case ItemTypes::DIVIDER:           self::renderDivider($parent, $node);                             break;
            case ItemTypes::LANGUAGE:          self::renderSwitcher($parent, $node, 'language');                break;
            case ItemTypes::CURRENCY:          self::renderSwitcher($parent, $node, 'currency');                break;
            case ItemTypes::LOGIN_BUTTON:      self::renderLoginButton($parent, $node);                         break;
            case ItemTypes::ACCOUNT_DROPDOWN:  self::renderAccountDropdown($parent, $node, $audience, $layout); break;
            case ItemTypes::WHMCS_DEFAULT:     self::renderWhmcsDefault($parent, $node);                        break;
            // Unknown types are silently skipped — admins can rename/remove via the builder
        }
    }

    private static function audienceAllows(string $itemAudience, string $audience): bool
    {
        if ($itemAudience === Audience::ALL || $itemAudience === '') {
            return true;
        }
        return $itemAudience === $audience;
    }

    private static function currentLayout(): string
    {
        // header.tpl sets a cookie when the chip changes; URL ?layout=top|side|rail also wins
        $url = $_GET['layout'] ?? null;
        if (in_array($url, ['top', 'side', 'rail'], true)) {
            return $url;
        }
        $cookie = $_COOKIE['mt_layout'] ?? null;
        if (in_array($cookie, ['top', 'side', 'rail'], true)) {
            return $cookie;
        }
        return 'side';
    }

    // ─────────────────────────────────────────────────────────────────────
    // Per-type renderers
    // ─────────────────────────────────────────────────────────────────────

    private static function renderWhmcsPage(Item $parent, MenuItem $node, string $audience, string $layout): void
    {
        $config = $node->config();
        $page   = (string)($config['page'] ?? '');
        $url    = self::resolvePageUrl($page);
        if ($url === '') {
            return;
        }
        $child = self::addChildSafe($parent, self::keyFor($node), $node->resolvedLabel(), $url);
        if ($child === null) {
            return;
        }
        self::applyVisuals($child, $node);
        self::renderChildren($child, $node, $audience, $layout);
    }

    private static function renderCustomLink(Item $parent, MenuItem $node, string $audience, string $layout): void
    {
        $config = $node->config();
        $url    = (string)($config['url'] ?? '#');
        $child  = self::addChildSafe($parent, self::keyFor($node), $node->resolvedLabel(), $url);
        if ($child === null) {
            return;
        }
        $target = (string)($config['target'] ?? '');
        if ($target === '_blank') {
            $child->setAttribute('target', '_blank');
            $child->setAttribute('rel', 'noopener');
        }
        self::applyVisuals($child, $node);
        self::renderChildren($child, $node, $audience, $layout);
    }

    private static function renderDropdown(Item $parent, MenuItem $node, string $audience, string $layout): void
    {
        $child = self::addChildSafe($parent, self::keyFor($node), $node->resolvedLabel(), '#');
        if ($child === null) {
            return;
        }
        $config = $node->config();
        if (!empty($config['dropdown_style'])) {
            $child->setAttribute('data-dropdown-style', (string)$config['dropdown_style']);
        }
        self::applyVisuals($child, $node);
        self::renderChildren($child, $node, $audience, $layout);
    }

    private static function renderHeader(Item $parent, MenuItem $node): void
    {
        // addChildSafe assigns order via the addChild array AND setOrder()
        // (Lagom-style). Don't call setOrder again here — that would
        // double-bump the counter and shift subsequent siblings.
        $child = self::addChildSafe($parent, self::keyFor($node), $node->resolvedLabel(), '#');
        if ($child !== null) {
            // Set data-mt-type FIRST so the sidebar template's getAttribute()
            // lookup never returns null no matter what side-effects later
            // mutations have.
            $child->setAttribute('data-mt-type', ItemTypes::HEADER);
            $child->addClass('mt-menu-header');
        }
    }

    private static function renderDivider(Item $parent, MenuItem $node): void
    {
        $child = self::addChildSafe($parent, self::keyFor($node), '', '#');
        if ($child !== null) {
            $child->setAttribute('data-mt-type', ItemTypes::DIVIDER);
            $child->addClass('mt-menu-divider');
        }
    }

    private static function renderSwitcher(Item $parent, MenuItem $node, string $flavor): void
    {
        // addChildSafe handles order assignment.
        $child = self::addChildSafe($parent, self::keyFor($node), $node->resolvedLabel(), '#');
        if ($child !== null) {
            $child->setAttribute('data-mt-type', $node->item_type);
            $child->addClass('mt-menu-switcher mt-menu-switcher-' . $flavor);
            $child->setAttribute('data-switcher', $flavor);
        }
    }

    private static function renderLoginButton(Item $parent, MenuItem $node): void
    {
        $child = self::addChildSafe($parent, self::keyFor($node), $node->resolvedLabel(), self::loginUrl());
        if ($child !== null) {
            $config = $node->config();
            $style  = (string)($config['style'] ?? 'primary');
            $child->setAttribute('data-mt-type', ItemTypes::LOGIN_BUTTON);
            $child->addClass('mt-menu-login mt-menu-login-' . $style);
            if (($config['position_side'] ?? '') === 'right') {
                $child->addClass('mt-menu-side-right');
                $child->setAttribute('data-mt-side', 'right');
            }
        }
    }

    private static function renderAccountDropdown(Item $parent, MenuItem $node, string $audience, string $layout): void
    {
        // Renders as a dropdown that contains the account-related links; the
        // children come from the saved tree, so admins can decide which links
        // appear here from the builder.
        $child = self::addChildSafe($parent, self::keyFor($node), $node->resolvedLabel(), '#');
        if ($child === null) {
            return;
        }
        $child->addClass('mt-menu-account');
        self::applyVisuals($child, $node);
        self::renderChildren($child, $node, $audience, $layout);
    }

    private static function renderWhmcsDefault(Item $parent, MenuItem $node): void
    {
        // The native $primaryNavbar's existing children — capture them BEFORE
        // we cleared them in the hook (the hook stashes them in a global). If
        // they're not cached, fall back to fetching freshly.
        $native = $GLOBALS['__hadrian_native_navbar_children'] ?? [];
        if (empty($native)) {
            return;
        }
        foreach ($native as $name => $nativeChild) {
            if (!$nativeChild instanceof Item) {
                continue;
            }
            $clone = self::addChildSafe(
                $parent,
                (string)$name,
                (string)$nativeChild->getLabel(),
                (string)$nativeChild->getUri()
            );
            if ($clone === null) {
                continue;
            }
            // Copy attributes/order from the native item
            $clone->setOrder((int)$nativeChild->getOrder());
            foreach ($nativeChild->getChildren() as $grandName => $grandChild) {
                if (!$grandChild instanceof Item) {
                    continue;
                }
                $clone->addChild((string)$grandName, [
                    'label' => (string)$grandChild->getLabel(),
                    'uri'   => (string)$grandChild->getUri(),
                    'order' => (int)$grandChild->getOrder(),
                ]);
            }
        }
    }

    // ─────────────────────────────────────────────────────────────────────
    // Helpers
    // ─────────────────────────────────────────────────────────────────────

    private static function renderChildren(Item $parentChild, MenuItem $node, string $audience, string $layout): void
    {
        foreach ($node->children as $childNode) {
            self::renderNode($parentChild, $childNode, $audience, $layout);
        }
    }

    private static function applyVisuals(Item $item, MenuItem $node): void
    {
        $config = $node->config();
        // Expose the menu-manager item-type to Smarty partials FIRST so the
        // template's getAttribute('data-mt-type') branch never falls through
        // to the default-whmcs_page case. (Other setters can throw or have
        // side effects — if any of them clears attributes, set this one up
        // front so subsequent calls overwrite less critical fields.)
        try { $item->setAttribute('data-mt-type', $node->item_type); } catch (\Throwable $e) {}

        // Each setter is wrapped in its own try/catch because WHMCS\View\Menu\Item
        // is strict about expected formats and can throw on certain inputs. A
        // bad visual hint must not abort the whole item, let alone the menu.
        if (!empty($config['icon'])) {
            // setIcon() strips non-FontAwesome inputs in some WHMCS builds,
            // so we ALSO stash the raw name on a data attribute the partials
            // can read via getAttribute('data-mt-icon').
            try { $item->setIcon((string)$config['icon']); } catch (\Throwable $e) { /* tolerate */ }
            try { $item->setAttribute('data-mt-icon', (string)$config['icon']); } catch (\Throwable $e) {}
        }
        if (!empty($config['css_class'])) {
            try { $item->addClass((string)$config['css_class']); } catch (\Throwable $e) {}
        }
        if (($config['position_side'] ?? '') === 'right') {
            try { $item->addClass('mt-menu-side-right'); } catch (\Throwable $e) {}
            try { $item->setAttribute('data-mt-side', 'right'); } catch (\Throwable $e) {}
        } elseif (($config['position_side'] ?? '') === 'left') {
            try { $item->setAttribute('data-mt-side', 'left'); } catch (\Throwable $e) {}
        }
        // Order is already set in addChildSafe (Lagom-style: passed in
        // addChild array AND via setOrder fluent chain). Don't increment
        // again here — that would double-bump and break sibling order.

        // Auto-cycle a palette colour from a fixed list, override-able via
        // config.color. Partials use this as a CSS class suffix.
        $palette = ['blue','purple','teal','green','orange','red','pink','indigo','gray'];
        $color = (string)($config['color'] ?? '');
        if ($color === '') {
            $color = $palette[((int)$node->id) % count($palette)];
        }
        try { $item->setAttribute('data-mt-color', $color); } catch (\Throwable $e) {}

        // Optional badge source — partials can read this and look up the
        // count from $clientsstats (set globally on every client-area page).
        if (!empty($config['badge_source'])) {
            try { $item->setAttribute('data-mt-badge-source', (string)$config['badge_source']); } catch (\Throwable $e) {}
        }
    }

    /**
     * Add a child to a WHMCS Menu Item, guarding against duplicate names
     * (which throws a fatal in WHMCS v8/v9 native menu code).
     *
     * Pass `order` inside the addChild() array AND via setOrder() on the
     * returned child — Lagom (commercial WHMCS theme) does it this way, and
     * empirically it sticks better than setOrder() alone on some WHMCS
     * builds. We use the global $orderCounter so order grows monotonically
     * in render sequence regardless of per-parent positions.
     */
    private static function addChildSafe(Item $parent, string $name, string $label, string $uri): ?Item
    {
        try {
            $order = self::$orderCounter++;
            $parent->addChild($name, [
                'label' => $label,
                'uri'   => $uri,
                'order' => $order,
            ]);
            $child = $parent->getChild($name);
            if ($child !== null) {
                try { $child->setOrder($order); } catch (\Throwable $e) {}
            }
            return $child;
        } catch (\Throwable $e) {
            return null;
        }
    }

    /**
     * Returns a stable, unique-per-item child name. We prefix with mt- so we
     * never collide with WHMCS's own child names.
     */
    private static function keyFor(MenuItem $node): string
    {
        return 'mt-' . $node->id;
    }

    /**
     * URL for a login_button item.
     *
     * NOT routePath('login') — 'login' is not a registered WHMCS route name, so
     * routePath() hands back the literal "/index.php/route-not-defined" sentinel,
     * which ships straight into the href and 404s. resolvePageUrl() goes through
     * the WhmcsDefaults table, which maps 'login' → login.php. The fallback keeps
     * the button present (pointing somewhere real) even if that entry ever goes.
     */
    private static function loginUrl(): string
    {
        $url = self::resolvePageUrl('login');
        return $url !== '' ? $url : 'login.php';
    }

    private static function resolvePageUrl(string $page): string
    {
        if ($page === '') {
            return '';
        }

        // If the admin entered a raw URL ("clientarea.php?action=...", "/foo",
        // "https://example.com"), use it verbatim.
        if (str_starts_with($page, '/')
            || str_starts_with($page, 'http://')
            || str_starts_with($page, 'https://')
            || str_contains($page, '.php')
            || str_contains($page, '?')) {
            return $page;
        }

        // First: the WhmcsDefaults table — single source of truth for the
        // standard templatefile → URL mapping. This wins over routePath()
        // because WHMCS's routePath() expects *route* names, not templatefile
        // names. Calling routePath('clientareahome') returns the literal
        // "/index.php/route-not-defined" which renders as a broken link.
        $defaults = WhmcsDefaults::lookup($page);
        if ($defaults !== null && !empty($defaults['url'])) {
            return $defaults['url'];
        }

        // Last resort: try routePath() for templatefiles outside WhmcsDefaults
        // that happen to be registered as named routes (e.g. 'account-users',
        // 'user-profile'). If it returns the route-not-defined sentinel, drop
        // through to the empty-string return so the renderer skips the item.
        if (function_exists('routePath')) {
            try {
                $resolved = (string)routePath($page);
                if ($resolved !== '' && !str_contains($resolved, 'route-not-defined')) {
                    return $resolved;
                }
            } catch (\Throwable $e) {
                // fall through
            }
        }

        // Unknown — don't return a broken link; let the renderer drop it.
        return '';
    }
}
