---
title: Customizing Pages
group: Customization
slug: customize-pages
icon: doc
lead: Give any page a template of your own - a new design from scratch, or a safe copy of a shipped one - without editing a single theme file, so everything you build survives updates.
---

## Introduction

Every page body in Hadrian lives under `core/pages/`, and the
[Page Manager](/client-theme/page-manager/) renders whichever template you
activate. That structure is the whole customization story: to change what a page
renders, you add files beside the shipped ones and pick yours - you never edit
theirs.

This page is written for whoever edits the files - a developer comfortable with
Smarty. If that is not you, the takeaway is that a customized page installs by
upload, activates from the Pages screen like anything else, and can be switched
away from at any time.

:::warn One rule carries this whole page
Never edit a file the theme shipped. A theme update replaces every shipped file
wholesale, so an edit made in place lasts exactly until the next update. Files
you *add* - new template folders, `overwrites` files - live at paths the theme
never ships, so updates cannot touch them.
:::

## Before you touch a file

Most customization needs no files at all. Cheaper routes, in the order worth
trying:

| You want to | Use |
| --- | --- |
| Recolour or restyle anything | [Style Manager](/client-theme/styles/) - tokens, presets, and a Custom CSS tab that survives everything |
| Rearrange a dashboard | The [block builder](/client-theme/page-templates/#the-block-builder) - drag, hide, resize, colour |
| A different shell around every page | [Layouts](/client-theme/layout-manager/), or a whole [custom layout](/client-theme/custom-layouts/) from one folder |
| A page the theme does not have | [Creating Pages](/client-theme/creating-pages/) |

Files come in when the *markup of one page* has to change.

## Add a template to a page

Any page can offer more than one template - not just the three that ship with
alternatives. A template is one folder:

```
templates/hadrian/core/pages/<page>/<name>/
    <name>.tpl     the markup (required)
    <name>.php     name + description for the admin card (recommended)
```

:::steps
1. Pick the page's folder under `templates/hadrian/core/pages/` - for the Affiliates page, `core/pages/affiliates/`.
2. Create a folder for your template inside it. Lowercase letters, digits and hyphens only - `affiliates/wide/`.
3. Copy the body of the shipped template as your starting point: `default/default.tpl` in the same page folder. Save your copy as `wide/wide.tpl`.
4. Add `wide/wide.php` so the admin card has a name and a description.
5. Make your changes to `wide/wide.tpl`.
6. Open **Hadrian -> Pages**, click the page - your template is already a card. Activate it and save.
:::

The metadata file is three lines:

```php
<?php
return [
    'name'        => 'Wide',
    'description' => 'The affiliates page with the stats row across the full content width.',
    'fullPage'    => false,
];
```

There is no cache to clear and no registration step - templates are discovered
live from the filesystem, so the card appears on the next load of the editor.

:::warn The three names must match
The folder, the `.tpl` and the `.php` share one name: `wide/wide.tpl` and
`wide/wide.php`. A template whose `.tpl` does not match its folder name is
skipped silently - no card, no error. And the metadata file is `<name>.php`:
a `pageoption.php`, if you find one in an older folder, is read by nothing.
:::

## Modify an existing template

To change a shipped template's markup, do not edit it - duplicate it and edit
the copy. The original stays untouched for updates to replace, and you can
switch between the two from the admin at any time.

:::steps
1. Duplicate the template's folder - `core/pages/clientareahome/bento/` to `core/pages/clientareahome/bento-mine/`.
2. Rename the files inside to match the new folder: `bento-mine.tpl`, `bento-mine.php`.
3. Change the `name` in `bento-mine.php` so the two cards are distinguishable.
4. Edit `bento-mine.tpl`.
5. Activate your copy in **Hadrian -> Pages**.
:::

Template settings are stored per template, so your copy starts at its own
defaults and the shipped template keeps its configuration - switching back is
always safe.

:::info Templates go live on save
Activating a template changes the page for every visitor at once - there is no
per-browser preview for page templates. The switch is instant and so is the
switch back, and neither loses any settings, so the practical approach on a busy
install is to flip, check, and flip back - or to try the change on a staging
copy first.
:::

## What a template can read

Your `.tpl` runs with everything the shipped one had: every WHMCS variable for
that page, the theme's language file as `$hadrianLang.*`, and the per-page
state Hadrian resolves for you:

| Variable | Holds |
| --- | --- |
| `$hadrian.pages.<page>.options.<key>` | The page's saved template settings, by bare key |
| `$hadrian.pages.<page>.variant` | The active template's folder name |
| `$hadrian.pages.<page>.fullPage` | Whether the page renders without nav, sidebar and footer |

Two conventions from the shipped templates worth copying: link your page's
stylesheet from inside the template with the version cache-buster
(`assets/css/pages/<page>.css?v={$hadrian.version}`), and declare a
`supportedOptions` block in your template's `.php` if you want settings of your
own to appear in the editor - the shipped Dashboard templates are working
examples of every option type.

## Replace a page outright

When you want a page's body entirely yours - no card, no choice - drop one
file:

```
templates/hadrian/core/pages/<page>/overwrites/overwrites.tpl
```

While that file exists it renders instead of *every* template for the page,
including whichever card is active in the admin. Deleting it hands the page
back. The full mechanics, and the one warning that matters - the admin keeps
showing a card as Active while your file is what renders - are in
[Page Manager](/client-theme/page-manager/#replacing-a-page-you-did-not-write).

## Two smaller override points

Beyond page bodies, the theme checks two specific paths before rendering its
own partials:

| Create | To replace |
| --- | --- |
| `templates/hadrian/overwrites/footer.tpl` | The entire footer - including the closing markup and script tags the shipped footer emits, so start from a copy of `footer.tpl`, not from empty |
| `templates/hadrian/includes/common/overwrites/logo.tpl` | The logo block, everywhere it renders |

These are the only two. In particular there is no override point for
`header.tpl` - the head, SEO tags and layout dispatch are managed by the theme,
and the supported ways to change what they output are the admin screens.

## What survives an update

| Path | On update |
| --- | --- |
| Any file the theme shipped | Replaced - never edit in place |
| `core/pages/<page>/<your-template>/` | Untouched |
| `core/pages/<page>/overwrites/` | Untouched |
| `overwrites/footer.tpl`, `includes/common/overwrites/logo.tpl` | Untouched |
| `core/layouts/<kind>/<your-layout>/` | Untouched - see [Custom Layouts](/client-theme/custom-layouts/) |
| Everything saved in the admin - template choice, settings, SEO, menus, styles | In the database; files cannot touch it |

:::tip After an update, re-read your copies
A template you duplicated does not receive the fixes its shipped original gets.
After a theme update, diff your copy against the current original and carry
across what you want - the update note in the changelog says which pages
changed.
:::
