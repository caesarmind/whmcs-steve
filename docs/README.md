# WHMCS 9 Theme Development

> Complete reference for building WHMCS 9 themes based on the Nexus theme architecture.

## What is this?

This documentation is a comprehensive, developer-focused reference for creating custom WHMCS 9 themes. It was derived from analysis of **all 279 Nexus theme files** and the official WHMCS developer documentation, filling in the gaps that the official docs leave out.

## Quick Navigation

### For Beginners

| Topic | Description |
|-------|-------------|
| [Overview & Architecture](/guide/overview.md) | Theme types, asset loading, theme.yaml config |
| [Quick Start](/guide/getting-started.md) | Create your first child theme in 5 minutes |
| [Best Practices](/advanced/best-practices.md) | DOs, DON'Ts, debugging tips |

### Core Reference

| Topic | Description |
|-------|-------------|
| [Directory & File Reference](/guide/directory-reference.md) | Complete file tree with every template documented |
| [Template Hierarchy](/guide/template-hierarchy.md) | How header/footer/content/sidebar fit together |
| [Smarty Patterns](/smarty/patterns.md) | Variables, loops, conditionals, modifiers, captures |
| [WHMCS Functions](/smarty/functions.md) | `{assetPath}`, `{routePath}`, `{lang}`, `{include}` |
| [Template Variables](/smarty/variables.md) | Every variable on every page |

### Components & Styling

| Topic | Description |
|-------|-------------|
| [Navigation](/components/navigation.md) | Navbar rendering, MenuItem API, hook customization |
| [Sidebars](/components/sidebars.md) | Sidebar cards, mobile select, customization |
| [Include Components](/components/includes.md) | All 21 reusable includes with parameters |
| [Form Patterns](/components/forms.md) | Form structure, fields, CSRF, all form actions |
| [CSS & SASS](/styling/css-sass.md) | 30 SCSS partials, CSS variables, custom.css |
| [JavaScript](/styling/javascript.md) | whmcs.js API, jQuery plugins, DataTables |

### Template Types

| Topic | Description |
|-------|-------------|
| [Store & Marketplace](/templates/store.md) | Dynamic store system, config fields, providers |
| [Payment Templates](/templates/payment.md) | Card/bank payment flow, validation, billing address |
| [Cart Theme](/templates/cart.md) | Nexus cart SPA, CSS variables, Vue.js architecture |
| [OAuth](/templates/oauth.md) | OAuth flow templates and layout |
| [Error Pages](/templates/error.md) | Error templates (Smarty and non-Smarty) |
| [PDF Templates](/templates/pdf.md) | Invoice/quote PDF generation (PHP, not Smarty) |

### External Theme Analysis

| Topic | Description |
|-------|-------------|
| [Lagom Analysis](/lagom/README.md) | Lagom 2.3.0-b1 structure, systems, strengths/weaknesses, and WHMCS 9-native alternatives |

### API Reference

| Topic | Description |
|-------|-------------|
| [Object API](/reference/object-api.md) | Complete WHMCS object methods (Client, Product, Pricing, MenuItem, SSL, etc.) |
| [Complete Hook Reference](/reference/hooks.md) | All 382+ WHMCS 9 hooks grouped by category |
| [Language Keys](/reference/language-keys.md) | 2,470+ language keys used in Nexus grouped by feature |
| [System Output Variables](/reference/system-output.md) | What `$headoutput`/`$footeroutput` actually contain |

### Starter Templates

| Topic | Description |
|-------|-------------|
| [Minimum Theme](/starter/minimum-theme.md) | Create a working theme with just 2 files |
| [Skeleton Files](/starter/skeleton-files.md) | Full directory structure reference |
| [Header Template](/starter/header-template.md) | Complete `header.tpl` walkthrough + code |
| [Footer Template](/starter/footer-template.md) | Complete `footer.tpl` walkthrough + code |
| [Template Fallback](/starter/template-fallback.md) | How WHMCS resolves templates child→parent |

### Advanced

| Topic | Description |
|-------|-------------|
| [Hooks Reference](/advanced/hooks.md) | Navigation, sidebar, and page variable hooks (quick intro) |
| [Best Practices](/advanced/best-practices.md) | Common pitfalls, debugging, performance |

## Tech Stack

The Nexus theme is built on:

- **Bootstrap 4.5.3** - CSS framework
- **jQuery 1.12.4** - JavaScript library
- **Font Awesome 5.10.1** - Icon library
- **Smarty 3** - Template engine
- **SCSS/SASS** - CSS preprocessor
- **DataTables** - Table sorting/filtering

## Hosting This Documentation

```bash
# Local preview (requires Node.js)
npx docsify-cli serve docs

# Or any static file server
python -m http.server 3000 --directory docs
php -S localhost:3000 -t docs
```

Deploy to GitHub Pages, Netlify, Vercel, or any static host by pointing to the `docs/` folder.
