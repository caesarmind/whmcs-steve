# Hadrian documentation

The customer-facing product documentation for Hadrian, Caesarthemes.

```
content/          the docs themselves -- one Markdown file per article
assets/           docs.css + docs.js, the shell the build wraps content in
html/             the original React prototype: DESIGN REFERENCE ONLY
dist/             build output; upload its CONTENTS, nothing else
```

## Build

```bash
node scripts/build-docs.mjs
```

Writes `dist/` as static HTML -- one directory per article, each with a real
URL, a `<title>`, a canonical link and an OG card. Plus `search-index.json`,
`sitemap.xml` and `robots.txt`.

```bash
node scripts/check-docs.mjs
```

Validates the output: dead links, un-parsed Markdown, missing metadata, TOC
anchors pointing at headings that do not exist, index/sitemap coverage. Run it
before every upload.

```bash
node scripts/test-docs-parser.mjs
```

Regression tests for the markdown parser. Every case is a bug that shipped
once -- three of them used to hang the build outright -- so each runs in its
own process with a timeout. Run it after any edit to `render()` or `inline()`.

### Where it will be served

**Production is `docs.hadrianthegreat.com`, deployed by
`.github/workflows/docs.yml` on every push to main** that touches the content,
the assets or the builder. The workflow builds with the right flags itself and
gates on check-docs + the parser tests, so nothing needs building locally to
release -- push and it ships.

Links are absolute, so the base path is baked in at build time. The flag-less
default (`hadrianthegreat.com/docs`) is legacy -- production builds are:

```bash
node scripts/build-docs.mjs --origin=https://docs.hadrianthegreat.com --base=
```

**Previewing locally needs `--base=`** too, because the preview server roots at
`dist/`:

```bash
node scripts/build-docs.mjs --base=
```

then start the `hadrian-docs-built` preview (port 3100). Since the subdomain
serves from a root as well, a preview build differs from a production one only
in the origin baked into canonicals and the sitemap -- never hand-upload a
preview build; let the Action do it.

> On Windows the preview server holds handles on files it has served. The build
> retries through that, but if it reports a locked file, stop the preview first.

## Writing an article

> Article copy is fact-checked against the addon source, not against the
> marketing prototype it was ported from. If you document a setting, open the
> controller and confirm the name, the default and where it lives first.

Add a `.md` file to a product folder. The numeric prefix orders it in the
sidebar and is stripped from the URL, so renumbering a section does not break
saved links. Sidebar, search index, prev/next and sitemap all pick it up with
no other edit.

```markdown
---
title: Installation
group: Getting started      # the sidebar heading it sits under
icon: rocket                # book cart doc layout mail palette puzzle plug rocket
lead: One sentence under the title.
---

## A section
```

`##` headings become the "On this page" rail automatically -- there is no TOC to
maintain by hand. `###` is available for sub-sections and is indexed for search
but stays out of the rail.

### Components

Standard Markdown works: paragraphs, `- ` bullets, `**bold**`, `` `code` ``,
[links](#), fenced code blocks, and tables. On top of that:

````markdown
:::info An optional title
Blue. Context the reader needs to understand what follows.
:::

:::tip
Green. Something that makes their life easier but is not required.
:::

:::warn Keep the key private
Amber. A way to lose data, money, or an afternoon.
:::

:::steps
1. Numbered instructions, rendered with the circled step markers.
2. **Bold** and `code` work inside.
:::

:::props
| Setting | Default | Description |
| --- | --- | --- |
| `--color-accent` | `#0071e3` | Three columns, monospace on the first two. |
:::

:::shot img/style-editor.png A real screenshot, with its caption

:::shot Caption for a screenshot not taken yet
````

A `:::shot` with an image path renders the image: click-to-open-full, lazy
loaded, with width/height read off the file so the article does not reflow as
it arrives. Put the file in `content/<product>/img/`. Filenames must be unique
across products -- `dist/img/` is flat, and the build fails on a collision or a
missing file rather than shipping a broken image.

Without a path it renders a grey placeholder frame, which is how an outstanding
screenshot stays visible on the page. `grep -rn ':::shot' content/ | grep -v img/`
lists what is still owed.

Crop to ONE block per shot -- one token group, one control panel. A whole-page
screenshot squeezed into the article column renders every label at about a fifth
of its real size and documents nothing. Captures are 2x and the builder halves
the dimensions (`IMG_SCALE` in `build-docs.mjs`), so a crop lands at life size
and is capped, never stretched, by the column width.

### Anchors

Every `##` and `###` gets an id and a hover-revealed `#` permalink, so a support
reply can point at one block instead of the top of a long page. Give each
feature its own `###` for that reason. `check-docs.mjs` fails on a link to an
anchor that does not exist, including across pages, so renaming a heading
surfaces every link that pointed at its old slug.

### Capturing admin screenshots

```bash
node .dashbuild/capture-docs-screenshots.mjs
```

Shoots the real admin screens out of the `.dashbuild` Smarty harnesses, and the
real client-area shell out of `apple-client-area`, so a screenshot cannot show a
control the product does not have. Needs the repo served on :3011 (the `static`
launch config serves both).

Build the admin pages first:

```bash
php .dashbuild/build-settings-admin-harness.php
php .dashbuild/build-layouts-admin-harness.php
php .dashbuild/build-branding-admin-harness.php
```

Every front-end shot asserts its own geometry before firing -- the right shell
visible, the right `margin-left`, and no dev-only overlay on screen -- so a
partial that failed to load cannot produce a plausible-looking blank frame.
Only panels the harness feeds real data are captured; see the note in the
capture script before adding more.

## Adding a product

Create a folder under `content/` with a `product.json`. It appears in the left
rail automatically.

```json
{ "name": "Email Templates", "icon": "mail", "order": 2, "coming": true }
```

`coming: true` adds the amber dot in the rail and the "Soon" badge in the
sidebar. Nothing else in the build needs to know about it.

## Why this is not the React prototype

`html/` still runs, and it is the reference for any visual change -- but it is
not what ships. It loads React and Babel from unpkg (4.2 MB before first paint),
keeps every article inside a JSX function, and holds the current article in
`useState`, so no article has a URL and a crawler sees an empty `<div>`. For
docs that is disqualifying on all three counts.

None of the content components hold state, so the builder emits their markup
directly and the site ships as static HTML plus ~10 KB of vanilla JS. Two
deliberate fixes went in along the way: the prototype hardcodes the light-mode
`#0071e3` in about forty places, which broke every accent in dark mode, and it
has no layout at all below 1404px.

## Relationship to the other docs in this repo

| Where | Audience | Engine |
| --- | --- | --- |
| `hadrian-documentation/` | **customers** | this builder |
| `hadrian/docs/` | us, building the theme | docsify |
| `docs/` | us, WHMCS 9 / Nexus platform reference | docsify |
| `apple-client-area/docs/` | us, mockup notes | docsify |

Only this one is public. Nothing from the other three should be copied here
without being rewritten for someone who has never seen the codebase.
