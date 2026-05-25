# Custom fonts

Drop a web-font file in **this folder** and it becomes selectable in the admin
under **Styles → (edit a style) → Typography → Font Family → Your fonts** — no
upload UI, no rebuild. The Typography panel scans this folder on load.

- **Supported:** `.woff2` (recommended), `.woff`, `.ttf`, `.otf`
- **Best:** a single **variable** `.woff2` — covers all weights (100–900) from one file
- **Family name** is derived from the filename, e.g. `AcmeSans.woff2` → "AcmeSans"
  (use letters/numbers/`-`/`_` only; avoid spaces)

Example: copy `AcmeSans.woff2` here, open the Typography panel, choose **Your
fonts → AcmeSans**, Save. The theme emits an `@font-face` for it and sets it as
the active font (with the system stack as fallback).

The bundled default font (Inter) lives one level up at `../InterVariable.woff2`
and is not affected by what you put here.
