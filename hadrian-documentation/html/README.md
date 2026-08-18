# Hadrian — Documentation site

Product documentation for the Hadrian WHMCS client theme by Caesarthemes.

## Open
index.html — the documentation site (all files must stay in one folder)

## Files
apple-theme.css        design tokens — colour, type, spacing, light/dark
apple-docs-kit.jsx     layout shell: product rail, sidebar, search, TOC, prev/next
apple-docs-content.jsx every article's content
apple-docs-app.jsx     routing and page assembly

## Notes
- React 18 + Babel standalone load from unpkg, so first load needs internet.
- Live search, scroll-spy table of contents, prev/next and dark mode all work offline
  once the CDN scripts are cached.
- To add an article, add an entry in apple-docs-content.jsx — the sidebar,
  search index and prev/next pick it up automatically.

Updated 2026-08-18
