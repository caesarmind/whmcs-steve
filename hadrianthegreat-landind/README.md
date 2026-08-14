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

### Saying it is only a corner

Under the stage sits one line and a disclosure: what the hero holds against what
ships — six of 102 pages, none of the 133 tokens — with a short list behind
"What would not fit". Figures rather than an apology: a demo that admits its own
edges is more convincing than one that implies it is the whole product.

Every number in `HF_MISSING` and that line was counted in `../hadrian`, not
estimated: 102 page directories, 133 `'var'` rows across `core/config`, four
menu locations, eleven blocks on Atrium. Recount before editing them.

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

### The Menu spotlight runs the admin panel

The "Menu manager" block embeds the real panel from
`../Hadrian by Caesarthemes/hadrian-admin-panel`, cropped to the item tree
alone — the rows with their grips, type badges, nesting, visibility toggles,
arrows and "+ Add item". No brand bar, no nav, no page head, no settings aside:
the block sells drag-and-drop menu editing, so that is all it shows.

Two additions to the panel make that possible, and both are contracts rather
than the landing page reaching into another app's DOM to hide things:

- **`#menu/<id>`** — the route takes an optional second segment. `#menu` still
  opens the menus list; `#menu/1` opens that menu's items.
- **`?embed=1`** — renders the section on its own, without the shell. `MenuPage`
  also drops its page head and settings column under it.

Neither changes the panel's own behaviour: `''`, `#info`, `#menu`, `#pages` and
`#styles` are unaffected, and `#menu/1` without the flag is still the full page.

`AdminSpot` in hadrian-lp5-app.jsx takes the route as a prop, so `#pages` or
`#styles` could be framed the same way. It renders at 760px and scales, nearer
life size than the whole panel would be.

Two things this needed from `ThemeFrame`:

- **A React root is not ready at load.** The client-area pages announce
  themselves through `data-loaded` on their includes; this one has none and
  mounts through Babel, so `frameStatus` now also waits for `#root` to have a
  child. Without it the frame is revealed blank.
- **`state.admin`** stops `paintFrame` after the colour mode. The panel keys off
  the same `data-theme` and has no use for `data-layout` or the rest.

The URL is the **directory, with its trailing slash** — not `index.html`. A host
that rewrites `/x.html` to `/x` normalises `/dir/index.html` down to `/dir`, and
without the trailing slash the browser treats the last segment as a file, so the
panel's relative `apple-admin.jsx` resolves one directory too high and 404s into
an empty root. Leave the slash alone.

Dragging works inside the scaled frame — verified by dispatching
dragstart/dragover/drop through the frame's own `DataTransfer`, with a tick
between them so React commits each one, and the arrow buttons move rows too,
which is the path that survives a touch screen.

`MenuSpot` stays as the fallback — off a `file://` URL, or with no network for
the React and Babel the panel loads, the block shows the drawn mock instead.
The panel is a second Babel app on the page (~1.8s to mount here) and loads
eagerly, because the give-up timer starts at mount: `loading="lazy"` would
expire it before a visitor ever scrolled down, pinning the block to the mock.

## Putting it on a server

The site is static — no Node, no PHP, nothing to install on the host. But do not
upload the source folder: it runs on Babel-in-the-browser, which costs a visitor
**4.2 MB of JavaScript** (React dev 107 KB + ReactDOM dev 1,055 KB + Babel
3,064 KB) and a compile of 131 KB of JSX on every single view, before anything
paints. That is a prototyping setup.

Build first:

```bash
node scripts/build-landing.mjs
```

That writes **`hadrianthegreat-landind/dist/`**, beside the source it was built
from. Its **contents** are what you upload — they go in `public_html`, not the
folder itself:

    hadrianthegreat-landind/dist/
      index.html            the landing (was "Hadrian Landing Imperial.html")
      about.html            (was "Hadrian About.html")
      assets/               css, the compiled app, React, images
      screens/              the poster captures
      apple-client-area/    the hero embeds this
      hadrian-admin-panel/  the Menu spotlight embeds this

The build compiles the JSX once, self-hosts React's production builds, and
compiles the admin panel too — a visitor scrolling to the Menu block would
otherwise pull Babel from unpkg for one card. Nothing in `dist/` requests
unpkg; the only third-party call left is Google Fonts, for Cinzel.

### Four things about the host

1. **Keep the `.html` extensions and do not turn on clean URLs.** `npx serve`
   rewrites `/x.html` to `/x`, and that cost two real bugs: the redirect drops
   the query string, breaking the Live Demos deep links, and it normalises
   `/dir/index.html` down to `/dir`, which moves the base path and 404s the
   admin panel's relative scripts into an empty frame. Plain Apache does
   neither — just do not add `MultiViews` or a "pretty URLs" option.
2. **The three folders must stay siblings under one document root.** The hero
   reads into `apple-client-area/` and `hadrian-admin-panel/` as same-origin
   iframes. Neither can move to a subdomain or a CDN.
3. **It works in a subdirectory.** Every path is relative, and the two the app
   resolves at runtime come from `window.HADRIAN_PATHS`, which the build writes
   into each page's `<head>`.
4. **Set `SITE` at the top of the build script** before you upload. The
   canonical, `og:url` and `og:image` are absolute and cannot be derived from a
   relative build, so they come from that one constant — and the build prints a
   NOTE on every run until it stops being the placeholder.

The build also writes the description, Open Graph and Twitter tags, a canonical,
a favicon and an apple-touch-icon, and generates `assets/og.png` at 1200x630
from the top of the dashboard capture. Page descriptions live in `META` in the
build script, one entry per page.

And it puts the hero into `#root` as real markup rather than leaving it empty
until React mounts — same classes as the JSX, built from the same
`window.HERO_COPY` the page already declares, so there is one source of truth
and `createRoot()` simply replaces it. A crawler that runs no JavaScript now
gets the h1 and every epithet instead of a blank div; a visitor gets the hero a
few hundred milliseconds sooner. It is not a full prerender — that would want a
headless browser in the build — but it is the part worth indexing.

The build re-encodes `screens/` on the way out: 2,894 KB of 2880px PNG becomes
328 KB of 1600px WebP, and the compiled JS is rewritten to match. The captures
are the poster behind the hero frame and the `file://` fallback, shown at about
890px, so nothing visible is lost. If the encoder cannot be reached the PNGs are
copied through unchanged, on the grounds that a heavy page beats a broken one.
A whole page load is now about 210 KB.

### Deploying it from CI

`.github/workflows/main.yml` has a second job, `deploy-landing`. It cannot copy
`dist/` out of the repo the way the theme job copies its files, because `dist/`
is gitignored — there is nothing committed to diff. So it runs the same build
you run locally and ships what comes out.

Two values in that job need setting before the first run, both marked
`CHANGE-ME`, and the upload step fails loudly rather than deploying to a
placeholder:

    REMOTE_LANDING_BASE   the landing docroot on the server
    LANDING_SITE_URL      canonical and og:url — the build reads this env var
                          in place of the SITE constant

`REMOTE_LANDING_BASE` is deliberately not `REMOTE_BASE`. That one is the WHMCS
billing root, and an `index.html` landing on top of it would sit in front of the
client area's own entry point.

The upload is the whole tree each time, not a diff — `dist/` is regenerated from
scratch, so a changed-file list would be every file anyway. The extract is
additive: nothing on the server is removed, which means renaming or deleting a
source file leaves the old copy behind. If that starts to matter, swap the tar
for `rsync -az --delete`, but point it at a docroot you are certain of first: an
additive upload that gets the path wrong makes a mess, and a `--delete` one that
gets it wrong empties a directory.

The job also fails if `screens/` still holds PNGs after the build, which is how
it catches the encoder having been unreachable. Locally that falls back to
copying them; in CI it would quietly ship 2.9 MB of images instead of 328 KB.

### Editing after a build

Keep editing the source in `hadrianthegreat-landind/` and re-run the build. The
source still runs unbuilt for development — see Open, above — so nothing about
the way you work changes. `dist/` is gitignored wherever it sits; it is output, not source.

Stop anything serving `dist/` before rebuilding. Windows holds a handle on every
file a server has touched, and the build says so rather than failing obscurely.

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
  families. 133 tokens in total, and the editor has no search
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
