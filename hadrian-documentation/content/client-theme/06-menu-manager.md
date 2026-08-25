---
title: Menu Manager
group: Configuration
icon: puzzle
lead: Build the navigation itself - what appears in it, in what order, and who sees it. Menus are separate from layouts: the layout decides where navigation sits, the menu decides what goes in it.
---

## Introduction

A layout gives you a sidebar, a rail or a navbar. The Menu Manager fills it - without hooks, template edits or any code.

Open **Hadrian -> Menu**. Menus are grouped into **locations**, one tab each, and a location is simply the place in the page its menus render.

:::shot img/menu-list.png The menu list. Each row is one menu, with the audience it serves and how many items it holds.

:::props
| Location | Where it appears | Default |
| --- | --- | --- |
| Main | The primary navigation - the sidebar column, the rail's flyouts, or the top navbar | Two menus: one for clients, one for guests |
| Footer | The columns of links in the Extended footers. A Dropdown becomes a column heading and its children become that column's links | One menu |
| Footer Secondary | The small row of legal links beside the copyright - Privacy, Terms and the like | One menu |
| Secondary | A tab you can build menus in, but nothing in the shipped theme renders them | Empty |
:::

:::warn The Secondary location has nowhere to render
It is a working builder with no output. Nothing in the shipped theme reads a Secondary menu, so a menu you build there will not appear anywhere on your site. Use **Main** for header navigation. It is left in place for installs that add their own template for it.
:::

:::info Footer columns come from the Footer menu
Each top-level item in the Footer menu becomes one column in the Extended footers. Adding a column means adding a top-level item here, not changing a setting on the Layouts page.
:::

### Getting back to the shipped menus

Hadrian ships four ready-made menus - a Main menu for clients, a Main menu for guests, a Footer menu and a Footer Secondary menu. Three buttons above the table put them back if an experiment goes wrong:

:::props
| Button | What it does |
| --- | --- |
| Re-seed presets | Adds back any preset item that has gone missing. Never overwrites what is already there, so it is the safe one to try first |
| Reset WHMCS Defaults | Rebuilds the factory WHMCS Defaults menus and the Footer Secondary menu. Menus you built yourself are left alone |
| Force re-sync to presets | Rebuilds **every** preset menu to match the shipped originals, overwriting their current items |
:::

:::warn Force re-sync overwrites your edits
It replaces the items in every preset menu with the shipped defaults. Both it and Reset ask you to confirm first. If you have customised a preset menu heavily, build your version as a new menu instead - custom menus are never touched by any of these three.
:::

## Building a menu

:::steps
1. Open **Menu** and choose the location tab you want.
2. Press **+ New menu**, or **Manage** on a menu that already exists.
3. Set the **Display Rule** - who this menu is for - and turn **Status** on.
4. Add items with **+ Add item**, choosing what kind each one is from **Add As**.
5. Drag the grip to reorder, or use the up/down arrows.
6. Press **Save changes**.
:::

:::shot img/menu-tree.png The builder. Every row shows its kind as a tag, and sub-items sit indented under their dropdown.

Each row carries the same set of controls:

:::props
| Control | What it does |
| --- | --- |
| Drag grip | Hold and drag to reorder. The up/down arrows do the same thing and are easier on a touchscreen |
| Arrow / the item name | Opens that item's settings underneath the row. Only one item is open at a time |
| Type tag | The kind of item this is - PAGE, LINK, DROPDOWN, HEADER and so on |
| **+** | Adds a sub-item. Only Dropdown rows have it, because only a Dropdown can hold children |
| Trash | Removes the item. If it has sub-items you are asked to confirm, because they go too |
| Switch | Hides the item from your site without deleting it. A hidden row's name dims so you can spot it |
:::

:::shot img/menu-add.png The button at the foot adds a top-level item; **Add As** decides what kind it will be.

:::info Two levels, by design
A Dropdown can hold items, but those items cannot hold more. Two levels covers a navigation menu and keeps the builder readable - deeper trees are a website menu, not a client area one.
:::

## Menu settings

:::shot img/menu-settings.png Who the menu is for, and whether it is switched on.

:::props
| Setting | Options | What it does |
| --- | --- | --- |
| Menu name | Free text | Only ever seen by you, in the admin list. Rename it freely |
| Display Rule | Existing Client, Guest Client, All visitors | Who this menu is built for |
| Status | On / Off | Whether this menu is live |
:::

:::info Turning one on turns the others off
Only one menu can serve a given location and audience at a time. Switching a menu on automatically switches off any other menu competing for the same slot, so you can never end up with two menus fighting over the same navigation.
:::

## Audiences

Menus target an audience, exactly as layouts do:

- **Guest Client** - shown only to visitors who are not signed in.
- **Existing Client** - shown only to signed-in customers.
- **All visitors** - shown to everyone.

That is what lets a guest see *Home, Store, Contact* where a client sees *Dashboard, Services, Billing, Support*, in the same navigation slot.

:::info This is a different mechanism from layout audiences
A layout audience picks the *shell*; a menu audience picks the *contents*. They are set in different places and do not have to agree - one layout can hold different menus for guests and clients.
:::

Individual items can narrow this further - see [Display settings](#display-settings) below.

## Item types

**Add As** offers ten kinds of item. Only **Dropdown** can hold sub-items.

:::props
| Type | Use it for | Holds sub-items |
| --- | --- | --- |
| WHMCS Page | A built-in WHMCS page - Dashboard, My Services, Invoices, Tickets. Picked from a list, so the link stays right | No |
| Custom Link | Any address you type - a cart deep link, your blog, an external site | No |
| Dropdown | A heading that holds other items beneath it | **Yes** |
| Section Header | A small grey label grouping the items under it, such as "Billing". Not clickable | No |
| Divider | A thin separating line between groups | No |
| Language Switcher | Opens the language and currency chooser | No |
| Currency Switcher | The same chooser, labelled for currency | No |
| Login Button | A call-to-action button pointing at the sign-in page, for guest menus | No |
| Account Dropdown | The "My Account" menu for signed-in clients | No |
| WHMCS Default | Passes WHMCS's own built-in navigation through | No |
:::

:::warn WHMCS Default does not render in Hadrian's own navigation
Hadrian's sidebar, rail and top bar build their links from your menu and deliberately skip this type. It exists for modules and hooks that read WHMCS's navigation object directly. Build the links you want with the other types instead.
:::

## Item settings

Open any row to edit it.

:::shot img/menu-item-drawer.png A Custom Link open, showing its address, its name and its icon.

:::props
| Field | Shown for | What it does |
| --- | --- | --- |
| Type | Every item | What this item is. Changing it hides the fields that no longer apply and keeps anything you already typed, in case you switch back |
| WHMCS Page | WHMCS Page | The built-in page it opens, from a searchable list grouped as Public, Client Area, Account, Billing, Support and Shop |
| URL | Custom Link | The address to open - an internal path, or a full external link |
| Open in new tab | Custom Link | Opens the link in a new browser tab |
| Dropdown Style | Dropdown | **Default** is a narrow floating list. **Mega menu** is a wide panel where Section Headers become column headings |
| Name | Most types | The wording customers see - see below |
| Icon | Page, Link, Dropdown, Login Button, Account Dropdown | A small line icon beside the label, from a built-in set of 34 |
:::

:::info The icon set is deliberately small
Hadrian draws its 34 icons straight into the page, so there is no icon font to download and nothing extra to load. That is why there is one curated set rather than a choice of libraries.
:::

### Naming an item

Two ways, chosen with the radio buttons:

- **Custom String** - type the wording yourself. Press **Translate** to add a version for each language you have installed; anything you leave blank falls back to the English one.
- **Language Variable** - point the item at one of WHMCS's own wording keys, such as `navhome`, so the label appears in each visitor's own language automatically.

Picking a page with **WHMCS Page** fills this in for you using that page's own WHMCS wording, which is usually what you want.

:::info Icons in the top bar need one more setting
The sidebar and rail always show icons. The top navbar shows them only when **Top-Nav Icons** is switched on under [Settings -> Navigation](/client-theme/settings/#navigation). If you set an icon and nothing appears, check there first.
:::

### Display settings

Inside each item, under **Display Settings**:

:::props
| Setting | Options | What it does |
| --- | --- | --- |
| Visible To | All, Clients only, Guests only | Narrows this one item, on top of the whole menu's audience |
| Position | Auto, Left, Right | Pushes the item to the right-hand end of the top bar - useful for a Login button. Only the top-bar layout uses it |
| Layouts | Top nav, Sidebar, Icon rail | Limits the item to certain layouts. Leave all three unticked - which is the default - to show it everywhere |
| Show In Menu | On / Off | The same switch as the one on the row itself |
:::

## Saving

**Save changes** in the bar at the foot of the page writes the name, the display rule, the status and the whole tree in one go. Nothing is written until you press it - including deletions, so an item removed by mistake comes back if you leave without saving.

:::warn There is no delete button for a whole menu
You can delete individual items, but the interface has no way to delete an entire menu. Switch its **Status** off instead: it stops rendering and stays available if you want it back.
:::

:::info Two safety nets
If your hosting account's PHP form limit is too small for a menu this size, the save is refused outright with a message rather than saving half of it. And if the browser sends no items at all, your existing menu is kept rather than wiped.
:::

## Settings that save but do not show yet

A few fields in the item drawer store their value and are not yet read by the theme. They are listed here so you do not spend time wondering why nothing changed:

:::props
| Field | Where | Status |
| --- | --- | --- |
| Description | Under Name | Saves. Intended for mega-menu and rail tooltips; nothing prints it yet |
| Badge | Menu Item Label | Saves. No badge is drawn beside the label yet |
| Text Transform | Menu Item Label | Saves. Label capitalisation is not changed yet |
| Hide Label Text | Menu Item Label | Saves. The label is still shown |
| Custom CSS Class | Display Settings | Saves, and reaches WHMCS's own navigation object, but Hadrian's sidebar, rail and top bar do not apply it |
:::

:::info What Hadrian's Menu Manager does not do
There is no export or import to a file, no image inside a mega-menu panel, no per-item choice between text and icon-only styles, and no coloured label tags. If you have used another theme's menu builder, those are the pieces to expect not to find. In place of export and import, Hadrian keeps its shipped menus as presets you can restore at any time - see [Getting back to the shipped menus](#getting-back-to-the-shipped-menus).
:::
