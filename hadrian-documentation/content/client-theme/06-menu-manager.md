---
title: Menu Manager
group: Customization
icon: puzzle
lead: Build the navigation itself - what appears in it, in what order, and who sees it. Menus are separate from layouts: the layout decides where navigation sits, the menu decides what is in it.
---

## Introduction

A layout gives you a sidebar, a rail or a navbar. The Menu Manager fills it.

Menus live in four **locations**, each rendered by a different part of the shell:

:::props
| Location | Where it appears |
| --- | --- |
| Main | The primary navigation - the sidebar tree, the rail's flyouts, or the top navbar |
| Secondary | The compact links in the header, beside the account controls |
| Footer | The columns in the Extended and Extended + Info footers |
| Footer Secondary | The single row of links beside the copyright |
:::

Open **Hadrian -> Menu** and pick a location tab.

:::info Footer columns come from the Footer menu
Each top-level item in the Footer menu becomes one column in the Extended Footer. Adding a column means adding a top-level item here, not changing a setting on the Layouts page.
:::

## Building a menu

:::steps
1. Open **Menu** and choose the location tab you want.
2. Create a menu and assign it to **Client**, **Guest** or **All**.
3. Add items - pages, custom links, dropdowns and dividers.
4. Drag to reorder. Drag onto an item to nest it beneath that item.
5. Expand any item to edit its label and target.
:::

:::shot Menu builder

## Audiences

Like layouts, menus target an audience:

- **Guest** - shown only to visitors who are not signed in.
- **Client** - shown only to signed-in customers.
- **All** - shown to everyone.

That is what lets a guest see *Home, Store, Contact* where a client sees *Dashboard, Services, Billing, Support*, in the same navigation slot.

:::info This is a different mechanism from layout audiences
A layout audience picks the *shell*; a menu audience picks the *contents*. They are set in different places and do not have to agree - a single layout can hold different menus for guests and clients.
:::

## Item types

:::props
| Type | Use it for |
| --- | --- |
| Page | A WHMCS page. The link follows the page if its URL changes |
| Link | Any URL, internal or external |
| Dropdown | A parent that holds other items rather than navigating itself |
| Divider | A visual rule between groups |
:::

## Common problems

### An item is missing from the client area

Check its audience. An item on a **Guest** menu never appears for signed-in customers, and vice versa.

### The footer has fewer columns than I expected

Extended Footer draws one column per **top-level** Footer-menu item. Items nested under a parent become links inside that column, not columns of their own.

### Reordering did nothing

Order is saved per location. Confirm you were on the tab for the location you meant - Main and Secondary are easy to mix up.
