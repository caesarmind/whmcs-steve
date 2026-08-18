---
title: Branding
group: Customization
icon: palette
lead: Put your logo, favicon and company identity into the client area. Five image slots, a footer description and six social links - no template editing, and nothing to regenerate afterwards.
---

## Introduction

Branding is where your marks go. Open **Hadrian -> Branding**.

:::shot img/brand-header.png

The page has two halves, and they save differently:

- **The image slots save the moment you pick a file.** There is no confirmation step.
- **Brand Info needs the Save button.** The description and social URLs are ordinary form fields.

:::info Uploads replace, they do not accumulate
Picking a new file for a slot deletes the old one from the server. The new file lands first and the old one is removed only after, so a failed upload never leaves the slot empty.
:::

## Logo versions

Every logo comes in two variants: one for light backgrounds and one for dark. That is because the client area has a dark mode, and a dark wordmark on a black sidebar is invisible.

:::info One upload is enough to start
If you only upload the light variant, Hadrian uses it in both modes. You are not forced to produce two files before anything works - the second slot is an upgrade, not a requirement.
:::

Once both are uploaded, the swap is automatic: the theme carries the dark URL alongside the light one and switches when the visitor changes mode. Nothing reloads.

### Full logo

:::shot img/brand-full-empty.png The two Full Logo slots on a fresh install.

Your horizontal, wordmark-style logo. This is the one most of the client area uses:

- The **top navigation** bar
- The **sidebar** header
- The **mobile topbar**
- The **login screens**
- The **footer** brand block

:::props
| | |
| --- | --- |
| Formats | PNG, JPG, WebP, SVG |
| Maximum size | 2 MB |
| Suggested | at least 40px tall |
:::

If no full logo is set, the client area falls back to your WHMCS company name as text. Nothing breaks - it just looks unbranded.

:::shot img/brand-full-filled.png The light slot filled. The dark slot is still empty, which is a perfectly good place to stop.

### Square logo

:::shot img/brand-square-empty.png

A compact, square version of your mark, for the places a wide logo would be cut off:

- The **icon rail** layout, which is only 80px wide
- The **sidebar**, when no full logo is set
- The **home-screen icon** when someone saves your client area to a phone

:::props
| | |
| --- | --- |
| Formats | PNG, JPG, WebP, SVG |
| Maximum size | 1 MB |
| Suggested | square, around 64-128px |
:::

:::info The rail never falls back to text
Where the sidebar would print your company name, the icon rail shows a neutral placeholder instead. A wordmark squeezed into a 28px square is unreadable, so it deliberately does not try.
:::

If you use the Icon Rail layout, this slot is the one that matters most.

### Favicon

:::shot img/brand-favicon-empty.png

The small mark that appears in the browser tab, bookmarks and history.

:::props
| | |
| --- | --- |
| Formats | `.ico`, PNG, SVG |
| Maximum size | 256 KB |
| Suggested | square, 16 / 32 / 64px |
:::

Hadrian emits the tab icon from this file. If the slot is empty, no favicon tag is emitted at all - deliberately, so the browser does not fall back to a stale `favicon.ico` left behind by a previous theme.

:::tip One SVG covers every size
A square SVG favicon scales to every context a browser asks for, so you do not need a multi-size `.ico`. If you need to support very old browsers as well, upload a 32x32 `.ico` instead.
:::

## Uploading, replacing and removing

:::shot img/brand-tile-hover.png Hovering a filled slot reveals its two actions.

:::steps
1. **Upload** - click an empty tile and pick a file. It saves immediately.
2. **Replace** - hover a filled tile and click **Replace**. No need to remove first.
3. **Remove** - hover and click **Remove**. You are asked to confirm, then the file is deleted from the server.
:::

Uploaded files are renamed to a random string on the way in, so two customers uploading `logo.png` never collide, and the original filename is not exposed.

:::warn SVGs are scanned before they are accepted
An SVG is a document, not just a picture - it can carry scripts. Hadrian rejects any SVG containing a script tag, an event handler, a `javascript:` link, a foreign object or an inline DTD. If yours is refused, re-export it from your design tool without scripting and it will go through.
:::

## Brand Info

:::shot img/brand-info.png The description and the six social fields.

Two kinds of field, and both need **Save brand info**:

**Footer description** - one or two short sentences under your company name in the footer. Up to 280 characters.

**Social links** - X, LinkedIn, Facebook, GitHub, YouTube and Instagram. Each takes a full `https://` URL. Leave one blank and that icon simply does not appear.

:::shot img/brand-savebar.png

:::warn These do not save on their own
Unlike the image slots, the description and social URLs are only written when you press the button. Navigating away first loses them.
:::

### Where Brand Info appears

:::shot img/brand-footer.png The footer brand block. Only the three networks with URLs set are showing.

The description and the social icons render in **one place**: the brand block of the **Extended Footer + Info** layout.

That means two things have to be true before they show up:

1. That footer layout must be active - set it under **Layouts -> Footer**.
2. **Hide Footer Social Links** must be off, under **Layouts -> Footer options**.

The other two footer layouts render neither.

## What Branding does not cover

Four things people reasonably look for here and will not find:

:::props
| What | Where it actually lives |
| --- | --- |
| Social share image (the preview when a page is posted to a chat) | Per page, under **Pages -> SEO** |
| Your company name | WHMCS itself, under General Settings - the theme reads it from there |
| Custom CSS | **Styles -> Custom CSS** |
| Email logo | Not part of the theme. WHMCS email templates carry their own branding |
:::

## Common problems

### My logo is not showing

Check which slot the active layout uses. The Icon Rail reads the **square** logo, not the full one, so an install with only a full logo shows the rail's placeholder. The sidebar and top navigation read the full logo.

### The logo disappears in dark mode

Only one variant is uploaded and it is dark ink. Upload a light-coloured version into the **dark backgrounds** slot - that slot is for the logo you want shown *on* dark, not a darker logo.

### The rail shows a grey placeholder

That is the square-logo slot being empty. The rail does not fall back to text on purpose.

### My social icons are not in the footer

Three things to check, in order: the **Extended Footer + Info** layout is active, **Hide Footer Social Links** is off, and the URL is a full `https://` address rather than a handle.

### My SVG was rejected

It contains scripting. See [the warning above](/client-theme/branding/#uploading-replacing-and-removing) - re-export without scripts.

### The file is too large

The caps differ per slot: 2 MB for full logos, 1 MB for square logos, 256 KB for the favicon. A favicon over 256 KB is almost always a full-size PNG that should be scaled down first.
