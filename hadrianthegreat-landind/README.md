# Hadrian — Landing page (Imperial)

Marketing site for the Hadrian WHMCS client theme by Caesarthemes.

## Open

Serve the **repository root**, not this folder — the hero embeds the real client
area from `../apple-client-area`, so both directories have to sit under one origin:

```bash
npx serve -l 3011 .
```

Then open `/hadrianthegreat-landind/Hadrian Landing Imperial.html`.

To browse the client-area mockups on their own — including the design
explorations the hero does not offer — serve that folder as its own root:

```bash
npx serve -l 3066 apple-client-area
```

Pages are then `/clientareahome-v17` and so on, and because the path carries no
`.html` there is no clean-URL redirect to strip the query string, so the state
params work directly: `?layout=side&palette=violet&sidebar=gradient&preview=off`.

Opening the files off disk (`file://`) does not work: the JSX is loaded through
Babel by XHR, which CORS blocks, and the client-area pages fetch their layout
partials the same way. The hero falls back to the captures in `screens/` when it
detects it cannot embed, but the page itself still needs a server.

- Hadrian Landing Imperial.html — the landing page
- Hadrian About.html — the about page

## Files

    apple-theme.css          design tokens — colour, type, spacing, light/dark
    hadrian-lp5.css          landing page styles
    hadrian-imperial.css     Cinzel treatment for the hero and wordmark
    hadrian-about.css        about page styles
    hadrian-lp5-frames.jsx   live theme embeds — ThemeFrame
    hadrian-lp5-app.jsx      header, hero stage, features, layouts, pricing,
                             extensions, FAQ, footer, founding popup, style panel
    hadrian-lp5-viz.jsx      feature tile visuals
    hadrian-lp5-demos.jsx    Live Demos popup
    hadrian-lp5-spotlight.jsx menu manager, block manager, SEO mocks
    hadrian-about.jsx        about page
    screens/*.png            client-area captures, kept as poster/fallback art
    caesar-silhouette.png    brand mark

`hadrian-lp5-screens.jsx` was removed: its six `Screen*` components were never
rendered anywhere, and the pages they drew by hand now exist for real.

## The hero runs the real client area

The window in the hero is an `<iframe>` of `../apple-client-area`, not a picture
of it. `ThemeFrame` (hadrian-lp5-frames.jsx) handles it:

- **Steering.** `apple-layout.js` reads `?layout=`, `?palette=` and friends once,
  at boot, so driving the frame by URL would mean a reload per click — and a
  static host that rewrites `/x.html` to `/x` drops the query string on the
  redirect anyway. The frame is same-origin, so `ThemeFrame` writes the same
  `body` / `documentElement` attributes the theme's own state chip writes.
  Switching layout, style, sidebar tone or colour mode is instant, needs no
  reload, and puts nothing in the theme's `localStorage`.
- **Scale.** The client area is laid out at 1440px and CSS-scaled to fit its box,
  so it never reflows into its own tablet breakpoints. Below ~1100px it would.
- **Page changes** load behind the current page and are only revealed once their
  partials have landed and their state has been written, so a swap never flashes
  the theme's defaults.
- **Navigation is sealed.** Links and forms inside the frame are cancelled in the
  capture phase; buttons, dropdowns, rail flyouts and scrolling all still work.
- **Fallback.** `data-loaded="error"` on any partial, or a non-http origin, drops
  the frame and shows the matching capture from `screens/`.

### Dashboard designs

The dashboard is the one page with more than one design, so it gets a second
control: a segmented strip of the four the module ships, with that design's own
description underneath. Picking one swaps the frame src, which the A/B slot
absorbs without a flash, and the layout, palette, tone and colour mode carry
across the swap.

Each maps to the mockup file it was drawn as:

| strip | module variant | mockup file |
|---|---|---|
| Atrium  | Atrium  | `clientareahome-v18.html` |
| Bento   | Bento   | `clientareahome-v17.html` |
| Minimal | Minimal | `clientareahome-v15.html` |
| Classic | Default | `clientareahome-v9.html` |

Atrium leads and opens the hero; Classic sits last. The strip calls the module
variant Default "Classic", because it reads as the older shape rather than a
fallback -- the only label here that is not the module word.

Atrium runs with its Summary figures block switched off: the module ships that
row as a toggle, so the mockup hides it with one rule in
`clientareahome-v18.html` rather than deleting the markup.

Names and descriptions are otherwise lifted verbatim from
`core/pages/clientareahome/<v>/<v>.php`, so the strip says exactly what the
Pages editor says. The list is one array, `HF_DESIGNS` in hadrian-lp5-app.jsx.

The mockup holds nineteen further explorations (v2-v19, v15-heavy, -boxed).
They are deliberately not offered: a buyer cannot choose them. Browse those
directly on the client-area server instead — see Open.

### Sidebar tones

Light, Tinted, Solid and **Gradient**. The gradient is new: `--sidebar-bg` feeds a
`background` shorthand rather than background-color, so it took a value and no
engine change. Its stops are set per palette, because one figure cannot serve all
six — white labels on the raw accent measure 2.52 on Amber and 2.76 on Emerald,
against the 4.5 they need, while Default already passes at 4.70. Each palette gets
the lightest top stop it can carry and still clear 4.5; measured on the rendered
frame that lands at 4.52–5.26 across the six. A single figure would have meant 72%,
which reads muddy on the blues.

Live in `apple-client-area` (CSS, state chip and layout JS) and in the hero.
**Not yet in the shipped admin module** — see Before launch.

The Live Demos drawer opens the same pages full-size. It writes the picked
layout, style and colour mode into the theme's own boot keys before navigating,
because of the query-string-dropping redirect described above.

The three thumbnails in the announcement banner are deliberately still captures:
they render at about 7% scale behind a mask, where a live frame would cost three
more page renders above the fold to draw something illegible.

## Claims

Everything the page states about the product was checked against
`../hadrian` on 2026-08-13. Corrected in that pass:

- styles are **six palettes** (Default, Emerald, Violet, Rose, Amber, Slate), not
  three presets named Standard / Clean / Minimal, and not the invented Ink and
  Porphyry. The accent values now match `core/config/colors.php` exactly
- the accent swatches were wrong for all five non-default styles
- the Icon Rail is **80px** with permanent labels and hover *flyout panels*, not
  54px with hover labels
- page templates: the dashboard ships Default / Atrium / Bento / Minimal, the
  homepage Default / Portal / Simple, login Default / Split — there is no
  "Cards" or "Compact", and 99 of the 102 pages ship a single design
- the homepage composer offers **up to eleven** blocks (Atrium 11, Bento 9,
  Minimal 7), not twelve, and there is no Knowledge base block
- SEO has character counters at 64/160, not a Google-style snippet preview
- typography has one `--font-family`; headings and body cannot take different
  families. 130 tokens in total, and the editor has no search
- Custom CSS is site-wide, not per style; there is no fork/duplicate path
- alignment is a Sidebar and Icon Rail option (along with menu side and the
  account block). Top Nav declares none
- "six levers" throughout — the feature grid has six cards

## Before launch

- The **Gradient** sidebar tone exists in the mockup and the landing hero but not
  in `core/config/colors.php`, so a buyer cannot pick it yet. Wiring it needs one
  decision: Brand resolves its ink with `autoInk`, which reads a single resolved
  colour, and a gradient has none — so the preset needs either a declared white ink
  or an `inkFrom` probe naming the lightest stop for autoInk to measure.

- `Hadrian Documentation.html` does not exist. Referenced from the closing CTA
  (`hadrian-lp5-app.jsx`) and the About page nav (`hadrian-about.jsx`).
- The founding counts are hardcoded and presented as live inventory: **34 of 50**
  and a 32% progress bar in the Founding popup, plus the **31 October 2026**
  deadline. Nothing updates them.
- 50 `href="#"` placeholders, including both **Buy** buttons on the pricing cards
  and three of the four Extensions CTAs.
- The FAQ says the theme keeps working after a licence lapses. That is true only
  while `mtLicenseGateEnabled` is `false` in the theme's `header.tpl`/`footer.tpl`;
  the comment there says to flip it to `true` for commercial release.
- "License valid for a lifetime" on the pricing cards is not something the module
  encodes — `License.php` tracks an expiry and an invalid state.
- Contact addresses on the About page are still `caesarthemes.com` placeholders.
- No favicon on either page.
- React and Babel load from unpkg in **development** builds and compile the JSX in
  the browser on every view. Fine for review, slow for a public page.

## Notes

- React 18 + Babel standalone load from unpkg, so first load needs internet.
- The floating Colours button sets the landing's own accent from the same six
  palettes the theme ships. The choice persists in localStorage.
- The hero showreel steps through the three layouts, advancing the palette each
  time it wraps. Hovering the stage pauses it; any manual pick takes over until
  the Auto pill hands control back.

Updated 2026-08-13
