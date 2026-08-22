---
title: Style Manager
group: Configuration
icon: palette
lead: Recolour and restyle the whole client area from one screen. Pick a preset, generate a palette from a single brand colour, or edit any of the design variables by hand - no template files, no CSS knowledge required.
---

## Introduction

Hadrian is built entirely on CSS variables. Every colour, font size, radius and border in the client area resolves to a named variable, and the Style Manager is the editor for those variables.

Two things follow from that, and both are worth knowing before you change anything:

- **Only variables you actually change are stored.** Editing one value does not freeze the rest. Anything you leave alone keeps tracking the preset, so a theme update that improves a default still reaches you.
- **Changes apply site-wide, immediately.** There is no publish step; the variables are written into the page head on the next request.

:::info Where the values live
Hadrian stores changed variables in the WHMCS database against the active template, not in files on disk. No theme directory needs to be writable, and your customisations survive re-uploading the theme.
:::

## The style editor

Open **Hadrian -> Styles**, then **Customize** on the style you want to work on. **Style Variables** holds every variable, grouped into the sub-sections below: Colors is stored **per style preset**, while Typography, General, Navigation, Buttons, Forms and Elements are stored **once and shared by every preset** - changing a button radius, or the site's font, changes it whichever style is active. **Custom CSS** is a plain editor for rules the variables do not reach.

### The save bar

Pinned to the bottom of the window and always visible. It always carries **Cancel** and a save button named for the section you are in - Save changes, Save typography, Save buttons, and so on. Most sections also add a reset button on the far left that clears just that section back to its shipped values - **Restore defaults** on Colors, **Reset all to default** on General, Navigation, Buttons, Forms and Elements. Typography has no reset button.

:::warn Each section saves on its own
The save bar saves only the section you are looking at. Edit Colors, switch to Typography, press Save typography, and your colour edits are gone. Save before moving between sub-sections.
:::

## Colors

### Light / Dark scope

:::shot img/colors-scope.png The scope toggle, top right of the Color scheme section.

Colors edits **one scope at a time**. This toggle chooses which - it does not preview your site in dark mode. Every control below writes into the scope selected here.

Whether visitors ever see the dark palette is a separate setting under **Settings -> Appearance**.

### Quick presets

:::shot img/colors-presets.png The six presets that ship with the theme.

**Default**, **Emerald**, **Violet**, **Rose**, **Amber** and **Slate**. Clicking one updates the brand fields - accent, accent hover, accent tint and link - and leaves every other variable alone. They are a starting point, not a lock: tweak any value afterwards.

### Generate from one colour

:::shot img/colors-generate.png The palette generator.

If no preset matches your brand, build a whole palette from one hex value.

:::steps
1. Enter your brand colour in **BRAND COLOUR**, or pick it with the swatch.
2. Under **WHAT TO REBUILD**, choose which families to touch - **Brand**, **Neutrals**, **Status**, **Icons & blocks**. Anything you deselect keeps its current values.
3. Adjust **NEUTRAL TINT** to control how much of your brand hue bleeds into the greys - it starts at 30%. Drag it to 0 for pure, hue-free neutrals, or higher for a stronger wash.
4. Press **Generate**, then **Save changes**.
:::

Two behaviours are deliberate and surprise people:

- **Lightness is preserved wherever contrast depends on it.** The generator will not hand you a palette that fails to read.
- **Status colours keep their own hue.** A warning stays amber whatever brand colour you pick, because a red warning and a green warning mean different things to a customer.

:::warn Generate writes one scope only
It rebuilds the scope named in the toggle above it. To rebuild dark as well, switch **EDITING** to Dark and generate again. **Undo** reverts the last generate, before you save.
:::

### Brand

:::shot img/group-brand.png

The accent and everything derived from it. `Accent` is the single colour that marks the one primary action per view; `Accent tint` is its translucent wash, used behind active rows and info callouts. `On accent` is the text colour that sits *on* a filled accent button - change the accent to a pale colour and this needs to go dark.

### Surfaces

:::shot img/group-surfaces.png

Page background and three levels of card. `Page` is the body; `Surface` is a card on it. `Surface 2` is an inset on a card - a field, a well, a table header. `Surface 3` sits one step further and is mostly used as a hover background on rows and list items. Which one is lighter also flips between modes: Surface 3 is lighter than Surface 2 in light mode, but darker than it in dark mode.

### Text

:::shot img/group-text.png

Four levels of ink. `Primary` for headings and body, `Secondary` for supporting copy, `Tertiary` for captions and metadata, `Quaternary` for placeholder text in empty fields.

:::warn Keep contrast in mind when you darken surfaces
These are tuned to stay easy to read against the shipped surfaces. If you darken `Page` or `Surface` substantially, check the text levels still read clearly.
:::

### Borders

:::shot img/group-borders.png

`Border` is the default line for inputs and dividers, `Border light` a softer one for subtle separators, and `Card border` the translucent outline around cards.

### Status & badges

:::shot img/group-status.png

Success, Warning and Danger each have three variables: the solid colour, a `text` version tuned to stay readable on a light tint, and a translucent `fill` for the badge background. Info and Neutral have only two - `text` and `fill` - since neither has a separate solid dot colour. These drive invoice states, service status pills and alerts.

:::info Change all three together
The `text` and `fill` versions are separate variables so the pair can stay readable together. Recolouring only the solid one leaves badges in the old colour.
:::

### Navigation & bars

:::shot img/group-navigation.png The navigation group, with its own STYLE row at the top.

The whole navigation shell - sidebar, topbar, flyout panel, item hover and active states, scrollbar.

The **STYLE** row at the top is a shortcut: **Light**, **Tinted**, **Brand**, **Dark** and **Gradient** each set a coordinated group of sidebar variables in one click. The individual rows below stay editable afterwards, so a named style is a starting point too.

### Icons & avatars

:::shot img/group-icons.png

Nine named hues used for service and product icons, plus the two-stop gradient behind client avatars. These are deliberately *not* derived from your accent - a row of icons in nine shades of one colour is harder to scan than nine distinct hues.

### Block accents

:::shot img/group-blocks.png

Three accents you can apply to a whole dashboard block - background, border and text together - so adjacent blocks can be told apart at a glance.

### Reset to the shipped palette

Under the presets there is a **Reset to the [style name] preset** link, named for whichever style you are editing - for example "Reset to the Nova preset". It discards your colour edits for that style and restores the palette it shipped with.

:::warn Reset cannot be undone
It clears the stored colour variables for that style. Note your hex values somewhere first if you might want them back.
:::

## Typography

### Font Family

:::shot img/type-family.png The four font modes.

One typeface is applied across the whole client area - there is no separate heading face. Pick one of four modes. They differ in what gets **loaded** (a network request, or none) and what gets **written** into the `--font-family` variable.

:::props
| Mode | Loads | Where from |
| --- | --- | --- |
| Default | Nothing | Bundled with the theme |
| System fonts | Nothing | The visitor's own device |
| Google Font | One stylesheet, up to five weights | fonts.googleapis.com |
| Self-hosted font | One font file | Your own domain |
:::

#### Default

:::shot img/font-default.png

The shipped stack, and the only mode that writes no variable at all - the value already in the theme's stylesheet stands.

That value asks for San Francisco first, so Apple devices use their system face. Everywhere else it falls through to **Inter**, which ships inside the theme and is already declared, so nothing is fetched over the network.

```css
-apple-system, BlinkMacSystemFont, 'SF Pro Display', 'SF Pro Text',
'Inter', 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, 'Helvetica Neue',
Helvetica, Arial, sans-serif
```

Leave it here unless you have a brand typeface. It is the fastest of the four and looks native on Apple hardware.

#### System fonts

:::shot img/font-system.png

Every visitor sees their own operating system's interface font. Segoe UI on Windows, San Francisco on Mac and iOS, the system default on Linux.

```css
system-ui, -apple-system, 'Segoe UI', Roboto, sans-serif
```

`system-ui` is the modern keyword for "whatever this OS uses for its own interface". `-apple-system` follows it only as a backstop for older Safari.

No `<link>` and no `@font-face` are emitted, so **nothing downloads at all**.

:::tip The fastest option, and the most consistent with the device
Text paints on the first frame because there is no font to wait for, and the client area matches the surrounding OS. Pick this when speed matters more than exact brand typography.
:::

The difference from **Default** is narrow but real: Default prefers Inter on Windows and Linux, giving you the same face across non-Apple platforms; System fonts gives each platform its own.

#### Google Font

:::shot img/font-google.png

The **whole Google Fonts library** is available here - every family Google publishes, close to 1,900 of them.

Clicking the field opens a searchable picker. Type to narrow by name, or filter by category with the row of chips: Sans, Serif, Display, Handwriting, Mono. Each row previews itself **in its own typeface**, with its category and how many weights it ships beside the name, so you can read a face before choosing it.

Twelve UI-grade families sit pinned at the top under **Popular** - Inter, Roboto, Open Sans, Lato, Poppins, Montserrat, Nunito Sans, Work Sans, Manrope, DM Sans, Source Sans 3 and Plus Jakarta Sans. These are the safe picks for a client area if you would rather not go browsing.

:::tip Previews come from Google, the choice does not
The picker reads its list from a catalogue shipped inside the theme, so the list works with no internet connection. Only the little previews are fetched live from `fonts.googleapis.com` - if that is blocked, names simply render in the admin font and everything else behaves the same.
:::

Selecting one emits three tags into every client-area page - two preconnects and the stylesheet:

```html
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap">
```

Three details are worth knowing:

- **Up to five weights are fetched** - 300, 400, 500, 600 and 700. That is five of Hadrian's six weight variables; the sixth, `--fw-black` (900), is never requested from Google, so text set to that weight is faked-bold by the browser whenever a Google font is active. Hadrian asks only for the five weights your chosen family actually ships: pick a display face that comes in a single weight and the URL asks for that one weight, not five.
- **`display=swap`** means text is painted immediately in the fallback face and swapped when the font arrives. Nothing is ever invisible while loading.
- The variable becomes `'Poppins', system-ui, sans-serif` - your font, then the visitor's own OS font if it fails to load.

:::warn This adds a third-party request
Every client-area page will contact `fonts.googleapis.com` and `fonts.gstatic.com`. If your privacy policy or a GDPR assessment rules out third-party requests, use **Self-hosted font** instead - the same typeface, served from your own domain.
:::

#### Self-hosted font

:::shot img/font-selfhosted.png

Your own typeface, served from your own server. No third-party request.

:::steps
1. Upload the font file to `/templates/hadrian/assets/fonts/custom/` on your server.
2. Type the face name into the field. **It must match the filename exactly** - `BrandSans.woff2` means typing `BrandSans`.
3. Save typography.
:::

Hadrian looks for `woff2`, `woff`, `ttf` and `otf`, in that order, and uses the first one it finds. Then it writes the `@font-face` for you:

```css
@font-face {
  font-family: "BrandSans";
  font-style: normal;
  font-weight: 100 900;
  font-display: swap;
  src: url("/templates/hadrian/assets/fonts/custom/BrandSans.woff2") format("woff2");
}
```

:::warn One file, one weight range
The rule declares `font-weight: 100 900`, which is correct for a **variable** font and wrong for a static one. Upload a variable file if you have it. With a static single-weight file the browser will synthesise the other weights, and bold text will look smeared.
:::

**Keep the device's system font on Apple** is offered on this mode only. Ticking it puts `-apple-system, BlinkMacSystemFont` at the front of the stack, so Apple devices keep San Francisco and your face is used everywhere else - useful when your brand font exists mainly to replace the plain Windows default.

#### How it's written into the system

Three of the four modes show this field beneath them - System fonts, Google Font and Self-hosted font. Default has none, because (as above) it writes no variable at all. Where it appears, it is **editable, not a preview**: whatever it contains is exactly what gets written to `--font-family`.

The two halves are independent. The radio button decides what gets **loaded** - the Google stylesheet, the `@font-face`, or nothing. This field decides what gets **applied**. That is what lets the Apple-first trick work: the font still downloads, but the stack asks for San Francisco first, so only non-Apple devices ever use it.

Edit it if you need a fallback the defaults do not give you - a specific CJK face, say, or a monospace stack. Only letters, digits, spaces, commas, quotes and hyphens ever reach the live page; anything else is silently dropped whenever the front-end page head is built, not when you save the form.

### Font Size and Font Weight

Below Font Family, Font Size exposes the full type scale, grouped under three headings you will see in the panel: **Body** (`--text-xs` through `--text-3xl`), **Headings** (`--text-h6` through `--text-h1`) and **Display** (`--text-display-sm` through `--text-display-xl`). Each step is its own variable, so you can change one size without shifting the rest.

Font Weight lists six weight variables - `--fw-light` through `--fw-black` - each a dropdown offering the standard weight values from 100 to 900, so any element's boldness can be tuned independently of the others.

## Navigation

The measurements of the main menu, in pixels. Colours for the same bars are in **Colors** (the *Navigation & bars* group) and their type is in **Typography** - this section is only the geometry.

Hover (or tab to) the (i) next to each field to see which layouts it affects - that line is worked out from the layouts themselves rather than written by hand, so it stays right if you add or remove one.

:::props
| Field | Default | Applies to |
| --- | --- | --- |
| Logo height | 28px | Every main menu layout |
| Menu icon tile | 26px | Top Navigation, Sidebar, Icon Rail |
| Menu icon glyph | 15px | Top Navigation, Sidebar, Icon Rail |
| Sidebar width | 260px | Sidebar |
| Topbar height | 44px | Sidebar, Icon Rail |
| Rail width | 80px | Icon Rail |
| Rail flyout width | 240px | Icon Rail |
| Top nav height | 44px | Top Navigation |
| Top nav icon | 14px | Top Navigation |
| Minimal bar height | 52px | Topbar Minimal |
:::

:::info Topbar height applies to Sidebar and Icon Rail, not Top Navigation
The inner topbar is rendered for every layout *except* Top Navigation, which has its own navbar - sized by **Top nav height** - instead. The admin derives that line from the layouts themselves, so it is right even though it reads backwards.
:::

Only one main menu layout is active at a time, so a field for a layout you do not run changes nothing until you switch to it. The values are kept either way, so switching back restores what you set.

:::info These moved here from the Layout Manager
They used to sit in the Layout Manager's **Containers** section. Any values you had already saved came across with them - nothing to redo.
:::

## General, Buttons, Forms and Elements

The remaining sub-sections cover component variables. They share one habit: only the values you change are saved. Buttons and Forms also let you recolour from the palette you already set, so those colours track your accent and dark mode; General and Elements are shape and timing only - General has no colour fields at all, and Elements keeps its colours in the Colors panel.

| Section | What it controls |
| --- | --- |
| General | Shared UI variables - corner radius, shadow depth, control padding, and animation (transition) speed, used across components |
| Buttons | A size tier per button scale (font size, weight, line height, radius) plus per-variant colours. Height follows the font size automatically |
| Forms | Field, label and checkbox/radio sizing (font size, weight, radius, border width), plus their colours - field background, border, text, placeholder and focus, label text colour, and the checkbox/radio accent colour |
| Elements | Card shape (radius, shadow, padding) and the pagination button radius - no colours here, those stay in the Colors panel |

:::info These are shared across styles
Unlike Colors, the component sections - and Typography - are not stored per preset. Changing a button radius, or the site's font, changes it whichever style is active.
:::

## Custom CSS

The **Custom CSS** tab takes hand-written CSS, saved with the theme and loaded on every client-area page. Use it for anything the variables above do not reach.

Write against the variables rather than fixed values, and your rules keep working when the palette changes or a visitor switches to dark:

```css
/* Follows the accent and the active palette */
.my-promo-banner {
  background: var(--color-accent-light);
  border: 1px solid var(--color-border);
  color: var(--color-text-primary);
  border-radius: var(--radius-lg);
}
```

:::warn Do not paste a hex code where a variable exists
`background: #ffffff` stays white in dark mode and renders white-on-white. `var(--color-surface)` flips with the mode.
:::

To find the variable behind any element, open your browser's developer tools, inspect it, and look for it in the Styles panel.
