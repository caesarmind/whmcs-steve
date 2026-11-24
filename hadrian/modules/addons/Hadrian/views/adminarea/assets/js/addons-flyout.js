/* Hadrian: a flyout under WHMCS's Addons > Hadrian menu entry that lists
   Hadrian's admin sections and the extension modules built on it.

   hooks.php prints this file inline in the <head> of every admin page, next
   to a JSON block (#hn-addons-flyout-data) that holds the links. The markup
   is the one WHMCS uses for its own nested menus (li.has-dropdown.expand
   holding an <a> and a <ul>), so the admin template's own CSS opens it on
   hover and its mobile menu treats it like any other submenu.

   Does nothing when the Hadrian entry is missing from the Addons menu: the
   admin's role has no access to the addon, or a custom admin template draws
   the menu some other way. */
(function () {
    'use strict';

    function linkTo(base, url, label, isHead) {
        var li = document.createElement('li');
        var a = document.createElement('a');
        a.href = base + url;
        a.textContent = label;
        if (isHead) {
            li.className = 'hn-flyout-head';
            var arrow = document.createElement('i');
            arrow.className = 'fas fa-arrow-right always';
            arrow.setAttribute('aria-hidden', 'true');
            a.appendChild(arrow);
        }
        li.appendChild(a);
        return li;
    }

    function build() {
        var dataEl = document.getElementById('hn-addons-flyout-data');
        var menuBtn = document.getElementById('Menu-Addons');
        if (!dataEl || !menuBtn || !menuBtn.parentNode) {
            return;
        }
        var addons = menuBtn.parentNode.querySelector('ul');
        if (!addons) {
            return;
        }

        var data;
        try {
            data = JSON.parse(dataEl.textContent);
        } catch (e) {
            return;
        }

        // The entry WHMCS printed for this module. Matched on the href, not
        // the id, because the id is built from the display name.
        var entry = addons.querySelector('a[href$="addonmodules.php?module=' + data.module + '"]');
        if (!entry || !entry.parentNode || entry.parentNode.querySelector('ul')) {
            return;
        }

        // Every link is a "?module=..." query string. Resolve it against the
        // href WHMCS's own entry resolves to, so it reaches addonmodules.php
        // from any admin page and under any custom admin folder name.
        var base = entry.href.split('?')[0];

        var list = document.createElement('ul');
        list.className = 'hn-addons-flyout';
        list.appendChild(linkTo(base, data.open.url, data.open.label, true));
        data.sections.forEach(function (s) {
            list.appendChild(linkTo(base, s.url, s.label, false));
        });
        list.appendChild(linkTo(base, data.extensions.url, data.extensions.label, true));
        // Every registered extension module, as Hadrian's own top nav lists
        // them. Not filtered against the Addons menu: WHMCS draws that from
        // a cached list (AddonModulesPerms) that can lag behind the access
        // setting addonmodules.php actually checks.
        data.extensions.items.forEach(function (x) {
            list.appendChild(linkTo(base, x.url, x.label, false));
        });

        var host = entry.parentNode;
        host.className = (host.className ? host.className + ' ' : '') + 'has-dropdown expand';
        host.appendChild(list);

        // Narrow screens, where the menu is a slide-out list: a tap on
        // Hadrian opens the list under it, as WHMCS's own nested entries do,
        // and "Open Hadrian" is the way in. The admin template wires that
        // up for its own entries before this runs, and gave this one a
        // handler that just follows the link, so catch the tap first.
        host.addEventListener('click', function (e) {
            var toggle = document.getElementById('btnNavbarToggle');
            // Same test as the template's own: the menu toggle is showing.
            if (!toggle || !toggle.getClientRects().length || !entry.contains(e.target)) {
                return;
            }
            e.preventDefault();
            e.stopPropagation();
            host.classList.toggle('expanded');
        }, true);
    }

    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', build);
    } else {
        build();
    }
})();
