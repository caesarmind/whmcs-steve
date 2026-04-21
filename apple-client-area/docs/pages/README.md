# Page Specs — WHMCS Source Reference

Each file here pairs with an HTML file in `apple-client-area/` and describes what the **real WHMCS page** does: its template name, routes, content slots, dynamic variables, and variations. This is the brief passed to an AI when batch-converting the Apple HTML mockups into Smarty (`.tpl`) templates for WHMCS.

## Doc format

Every spec follows the same structure:

1. **WHMCS source** — template filename(s), route, layout context, auth state
2. **Purpose** — one-sentence job of the page
3. **Breadcrumb** — what the breadcrumb shows
4. **Content sections** — each visible section in order, with:
   - **Default content** — what WHMCS renders out of the box
   - **Possible / dynamic content** — admin-configurable, conditional, or looped content
   - **Smarty variables** — the `$variables` the original template reads
   - **Actions / forms** — endpoints and form payloads, if any
5. **Conversion notes** — gotchas for the Apple-theme conversion (what must stay functional, what is pure mockup decoration)

## Naming convention

`<page-name>.md` matches `apple-client-area/<page-name>.html` exactly (minus extension). Store pages live in `store/`.

## Index

See [pages.md](../../pages.md) for the full Apple HTML page list. Specs will be added incrementally.
