---
title: Layout Manager
group: Configuration
icon: layout
lead: Choose the shell your client area sits in - where navigation lives, how the footer is built, and how wide content runs. Guests and signed-in clients can be given different layouts, and any page can override the lot.
---

## Introduction

A layout is the frame around every page: the navigation, the footer, and the geometry between them. Hadrian ships six, in two independent kinds - three for the **main menu** and three for the **footer** - and you pick one of each. A fourth main-menu card, **Topbar Minimal**, ships as a working example of a [custom layout](/client-theme/custom-layouts/) - any folder your developer drops into the theme joins this page the same way.

Open **Hadrian -> Layouts**.

:::shot img/lay-tabs.png The two kinds are separate tabs. Everything on this page belongs to one or the other.

:::info There is no Save button
Every control on this page applies the moment you use it. Activating a layout, flipping a toggle or changing a width takes effect on the next page load - there is nothing to submit and nothing to lose by navigating away.
:::

## Main menu layouts

:::shot img/lay-cards.png The main-menu cards. **Sidebar** is active here, which is what a new install serves; the **Custom**-badged card is the shipped example custom layout.

Each card carries a wireframe, a one-line description, its activation rows, and - once it is active - its options.

### Top Navigation

:::shot img/fe-top.png Top Navigation on a services page.

A horizontal navbar across the top with content full-width beneath it. No left column, so the content area gets the entire viewport width.

Best for accounts with few sections, and for installs where the client area sits alongside a marketing site that already has a top navbar.

:::info Content is always centered
Top Navigation is the one layout with no options at all. Alignment, side and the account block are sidebar concepts, so the card says so rather than offering controls that would do nothing.
:::

### Sidebar

:::shot img/fe-side.png Sidebar on the same page. The nav column is 260px and content shifts right to clear it.

A fixed 260px column on the left holding the full navigation tree, with search, the section groups and the account block. Content shifts right by exactly that width.

The default, and the right choice for dense accounts - every section is one click away and stays visible while the customer works.

### Icon Rail

:::shot img/fe-rail.png Icon Rail. An 80px strip of icons; the labels arrive in a flyout on hover.

A compact 80px strip of icons. Hovering one opens a flyout panel with that section's links, overlaying the content rather than pushing it.

Best when you want the content area as wide as possible but still want persistent navigation. It costs a hover to read a label, so it suits confident, repeat users more than first-time visitors.

:::info All three collapse the same way on mobile
Below 900px the sidebar and rail become off-canvas drawers behind a menu button, and content runs full width. You do not need a separate mobile layout.
:::

## Guests and existing clients

Every layout has **two independent activations**, not one.

:::shot img/lay-audiences.png Top Navigation serving guests, while signed-in clients get something else.

- **Guest client** - anyone not signed in.
- **Existing client** - anyone signed in.

Activating for one audience leaves the other untouched, so a marketing-style top nav for visitors and a dense sidebar for customers is a two-click setup. Hadrian decides which a visitor is from their session, before the page renders, so there is no flash of the wrong layout.

:::warn Only the layout choice is per-audience
Everything else on this page - the per-layout options, Header flags, Containers sizes and Footer options - is a single global value shared by both audiences. Setting the sidebar to the right for clients also sets it for guests.
:::

## Per-layout options

:::shot img/lay-card-sidebar.png The Sidebar card while active. Sidebar position has been set to Right here, so the segmented control shows a non-default pick.

Sidebar and Icon Rail each offer three:

:::props
| Option | Choices | Default |
| --- | --- | --- |
| Content alignment | Center, Left | Center |
| Sidebar position / Rail position | Left, Right | Left |
| Account block | Show, Hide | Show |
:::

They are stored per layout, so the rail's position is independent of the sidebar's.

:::shot img/lay-card-rail.png An inactive card: two Activate rows and a preview link, and no options at all.

:::info Options only appear on an active card
Configuring alignment on a layout nobody is served would be noise, so the block stays hidden until the card is active for at least one audience.
:::

Every option's default emits nothing at all, so an untouched install renders exactly as it shipped.

## Live preview

:::shot img/lay-card-top.png Every main-menu card carries a Live preview link.

**Live preview** opens the client area with that layout applied **for your browser session only**. Customers keep seeing whatever is actually activated. It is the safe way to compare all three before committing.

The link is `?preview=1&layout=…` on your own client area. Footer cards have no preview link - footers have no equivalent standalone mode to preview.

:::warn Preview is not activation
A layout you have only previewed is not live. If it looks right, come back and press **Activate** on the audience you want it for.
:::

## Footer layouts

:::shot img/lay-footer-cards.png The three footer layouts. Extended Footer is the default.

:::props
| Layout | What it renders | Driven by |
| --- | --- | --- |
| Default Footer | A single row: copyright, a few links, the locale button | Footer Secondary Menu |
| Extended Footer | A multi-column site map above that row | Footer Menu - each top-level item becomes a column |
| Extended Footer + Info | The columns, plus a brand block with logo, description and social icons | Footer Menu, Branding, Footer Secondary Menu |
:::

Footer layouts have no options of their own - what they show comes from the menus and from Branding.

:::info Columns come from your menu, not from a setting
An Extended Footer with one column means the Footer Menu has one top-level item. Add columns under **Menu -> Footer**.
:::

### Footer options

Two toggles sit below the footer cards, on the same tab.

:::shot img/lay-footer-options.png

:::props
| Setting | What it does | Default |
| --- | --- | --- |
| Hide Footer Social Links | Hides the social icons in the footer | Off |
| Back to Top Button | Shows a floating button in the bottom-right once the visitor scrolls down | Off |
:::

:::info Social links need two things before they appear
Only **Extended Footer + Info** renders them, and only when social URLs are set under **Branding**. If they are missing, check both before reaching for this toggle.
:::

## Header

:::shot img/lay-header.png Five toggles, each applying instantly.

:::props
| Setting | What it does | Default |
| --- | --- | --- |
| Affixed Navigation | Pins the navbar while scrolling. It slides away as you scroll down and returns the moment you scroll up | Off |
| Unpin Sidebar | Lets the sidebar scroll away with the page instead of staying put. Sidebar layout above 900px only | Off |
| Hide Breadcrumb | Removes the breadcrumb above the page title on every layout | Off |
| Hide Language Switcher | Removes the language chooser from the header | Off |
| Hide Currency Selector | Removes the currency chooser. No visible effect on single-currency installs | Off |
:::

:::warn Unpin Sidebar puts the menu out of reach
While it is on, the sidebar scrolls away with the page, so the main menu is only reachable at the top. Fine for short pages, awkward for long ones.
:::

## Containers

:::shot img/lay-containers.png Content width, then four exact measurements in pixels.

**Content width** is the mode: **Boxed** centres the content column at a fixed maximum, **Full width** uses the whole viewport. Boxed keeps long-form pages readable; full width suits data-dense dashboards.

:::props
| Setting | Default | Range |
| --- | --- | --- |
| Maximum width | 1120px | 640-2400 |
| Side padding | 48px | 0-160 |
| Sidebar width | 260px | 0-4000 |
| Topbar height | 44px | 0-4000 |
:::

:::warn Maximum width does nothing unless Boxed is selected
Switch Content width to Full width and the field is ignored - the page says **Currently overridden** next to it rather than letting you wonder.
:::

:::info Topbar height applies to Sidebar and Icon Rail, not Top Navigation
The inner topbar is rendered for every layout *except* Top Navigation, which has its own navbar instead. The admin derives that line from the layouts themselves, so it is right even though it reads backwards.
:::

Side padding applies per side, in both modes.

## Overriding a layout for one page

Layouts are site-wide, but a single page can opt out. In **Pages**, open a page and find **Custom layout**:

:::steps
1. Open **Hadrian -> Pages** and pick the page.
2. Under **Custom layout**, set **Main menu** or **Footer** to the layout you want.
3. Leave either on **- Inherit -** to keep following the global setting.
:::

A per-page override beats the global choice for that page, including the per-audience one. Useful for a checkout that should lose the sidebar, or a landing page that wants the extended footer when nothing else does.

## Common problems

### A layout's options are missing

Options only render on a card that is active for at least one audience. Activate it first, then the controls appear.

### The layout changed for me but not for customers

You used **Live preview**, which is scoped to your browser session. Press **Activate** on the audience you want.

### Maximum width does nothing

Content width is set to Full width, which ignores it. Switch to **Boxed**.

### Guests and clients both changed when I only meant one

Only the *layout choice* is per-audience. Options, Header flags, Containers and Footer options are global - see [the warning above](/client-theme/layout-manager/#guests-and-existing-clients).

### One page ignores the layout entirely

It has a per-page override. Check **Pages -> that page -> Custom layout** and set both selects back to **- Inherit -**.

### The footer has only one column

Extended Footer builds its columns from the Footer Menu's top-level items. Add more under **Menu -> Footer**.
