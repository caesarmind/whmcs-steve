# Hadrian Admin Panel — Apple Style

WHMCS theme admin panel UI for the Hadrian client theme.

## Files
- index.html — entry point (open in a browser)
- apple-admin.jsx — all screens and components
- apple-admin.css — admin panel styles
- apple-theme.css — design tokens (colors, type, spacing, light/dark)
- caesar-silhouette.png — brand mark asset

## Screens
Info · Settings (General / Order Process) · Styles (presets + style editor:
Colors, Typography, General, Navigation, Buttons, Forms, Elements) ·
Layouts (Main menu / Footer tabs, per-audience activation, live preview) ·
Pages (list, search, page detail with Page Template, Page Settings, SEO with
multi-language editor, Custom layout) · Menu (menus list → menu editor with
drag-and-drop items, per-item settings) · Branding · Extensions · Tools

## Notes
- React 18 + Babel standalone are loaded from unpkg (needs internet on first load).
- Floating save bar (Restore defaults / Cancel / Save changes) is docked at the
  bottom on every page that saves.
- Dark mode toggle is in the top-right of the header.
- All state is local/prototype only — no backend calls.

Updated 2026-08-10
