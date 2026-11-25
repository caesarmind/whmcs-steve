---
title: Media
group: Configuration
slug: media
icon: palette
lead: One library for every image you upload in Hadrian. Pick from it in any image field, see where each image is used, keep files small, and clear out what is left over.
---

## Introduction

Hadrian keeps the images you upload in one library. A page's social image, a picture in a built page and a logo in an email all come from the same place, so an image is uploaded once and used as often as you like.

You meet the library in two places:

- **The picker.** Any image field in Pages, Email Templates or the Page Builder opens it, so you can choose an image without leaving what you are doing.
- **The Media screen.** Open **Hadrian -> Media** to look after the library itself.

:::shot img/media-library.png The Media screen, with one image selected.

Your logo and favicon are not in the library. They have fixed slots of their own under [Branding](../branding/).

## Choosing an image

Click **Choose image** on any image field. The picker opens on the **Library** tab.

:::steps
1. **Pick** - click an image, then **Use image**. Double-clicking does both.
2. **Upload** - switch to the **Upload** tab and click, or drop files on it. A new upload is selected for you.
3. **Search** - type in the filter box to narrow the list by name.
:::

The field underneath stays a normal text box, so you can also paste the address of an image hosted somewhere else.

**Manage library** in the picker's footer opens the Media screen in a new tab. What you were editing stays open.

## The Media screen

The screen shows every image as a tile, newest first. Above the grid:

- **Search** narrows the grid by name.
- **All / In use / Unused** filters by whether anything shows the image.
- **Sort** orders by date, name or file size.
- **Upload images** adds files. You can also drop them anywhere on the panel.

The line under the toolbar is the state of the library: how many images there are, how much space they take, how many are unused and how much optimising has saved.

Click a tile to open its details on the right: a preview, its name, size, type, the date it was added, its address and where it is used.

## Where an image is used

Each image's details list the places that show it, with a link to each one. Hadrian looks in:

- the social image of every page
- Hadrian's own settings and menu items
- built pages, when the Page Builder is installed (drafts count as well as published pages)
- email designs and email appearance settings, when Email Templates is installed

An image nothing points at carries an **Unused** label on its tile.

:::info What "unused" cannot see
Hadrian only knows about its own screens. If you pasted an image's address somewhere else, into a WHMCS product description or a template you edited by hand, that use is not counted and the image still shows as unused. Check before deleting an image you remember using outside Hadrian.
:::

## Renaming and copying the address

A new image takes the name of the file you uploaded. To change it, edit **Name** in the details and press Enter. The name is what the library shows and searches. The file on the server keeps its own random name, so renaming never breaks a page that uses the image.

**Copy** next to **Address** puts the image's full address on your clipboard, for the few places that take an address and have no picker.

## Optimising images

Large images are the most common reason a page loads slowly. With **Optimise new uploads** switched on, which it is by default, Hadrian makes each image smaller as it arrives:

- An image wider or taller than 2560 pixels is scaled down to that. Nothing on a client page is drawn larger.
- JPEG and WebP files are saved again at a quality that looks the same at normal sizes. PNG files are compressed without any loss.

The image keeps its address, so nothing that uses it has to change. The result replaces the file only when it is clearly smaller. Otherwise the upload is stored exactly as you sent it.

The upload you sent is kept. An optimised image shows **Optimised** and how much it saved in its details, with **Restore original** beside it. Restoring puts your file back, byte for byte.

To run the same pass over images that were uploaded earlier, use **Optimise all** at the bottom of the screen, or tick a few tiles and choose **Optimise**. An image you restored on purpose is skipped by **Optimise all**.

Some images are always left as they are:

| Image | Why |
| --- | --- |
| GIF, animated PNG, animated WebP | Only the first frame would survive |
| Lossless WebP | Saving it again would lose quality nobody asked to lose |
| JPEG with a colour profile other than sRGB | The profile would be dropped and the colours would shift |

:::info Optimising needs GD
Optimising uses PHP's GD image library, which WHMCS itself requires. If your server has no GD, the switch is greyed out and the screen says so. Uploads work as usual; they are stored as sent.
:::

## Deleting images

Open an image and click **Delete image**. To delete several, tick the box on each tile, or tick one and choose **Select all shown**, then **Delete**.

If any of the images is in use, the confirmation lists where, and the button reads **Delete anyway**. Deleting an image that a page still shows leaves an empty space there, so remove it from the page first when you can.

The picker can delete too, with one difference: it refuses an image that is in use and tells you where it is used. Open the Media screen to delete it anyway.

:::warn Deleting cannot be undone
The file and its kept original are removed from the server. Filter by **Unused** first to see what is safe to clear.
:::

## Limits and file types

| | |
| --- | --- |
| Formats | PNG, JPG, GIF, WebP |
| Largest file | 5 MB |
| Largest image | 50 megapixels |
| Library size | 500 images |

SVG is not accepted in the library. An SVG is a document that can carry scripts, and library images are shown on your own site. Use PNG or WebP here. Your logo and favicon can be SVG, under [Branding](../branding/#logo-versions).

Uploaded files are renamed to a random string, so two files called `banner.png` never collide and the original filename is not exposed.

## Where the files are

Images are stored in `templates/hadrian/assets/img/media/` inside your WHMCS folder. Kept originals are in the `.originals` folder beside them. Include the folder in your backups, and keep it when you update the theme: your update should replace the theme's files, not delete the folder.

A file you copy into that folder by FTP appears in the library under its file name. It can be renamed, optimised and deleted like any other.
