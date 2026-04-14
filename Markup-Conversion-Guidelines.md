# Hostnodes Theme — Markup Conversion Standards

Convert AI-generated HTML/CSS into production-ready, standalone markup files.

**This document covers Phase 1 only:** standalone HTML/CSS/JS that works in any browser without WHMCS. Phase 2 (WHMCS 9 `.tpl` integration) is a separate process that builds on these files.

**Architecture constraint:** All naming, structure, and tooling choices are made so Phase 2 conversion is mechanical — no redesign required.

---

## Table of Contents

1. [Conversion Workflow](#1-conversion-workflow)
2. [Project Structure](#2-project-structure)
3. [Build Tooling](#3-build-tooling)
4. [HTML Standards](#4-html-standards)
5. [CSS Standards](#5-css-standards)
6. [Layout System](#6-layout-system)
7. [Component API](#7-component-api)
8. [Icon Strategy](#8-icon-strategy)
9. [Responsive Design](#9-responsive-design)
10. [Dark Mode](#10-dark-mode)
11. [JavaScript](#11-javascript)
12. [Performance](#12-performance)
13. [Design Polish](#13-design-polish)
14. [Content & Sample Data](#14-content--sample-data)
15. [RTL Readiness](#15-rtl-readiness)
16. [Cross-Browser Testing](#16-cross-browser-testing)
17. [Page Inventory](#17-page-inventory)
18. [Pre-Launch QA Checklist](#18-pre-launch-qa-checklist)
19. [Versioning & Changelog](#19-versioning--changelog)
20. [Phase 2 Readiness Checklist](#20-phase-2-readiness-checklist)

---

## 1. Conversion Workflow

### Input

AI-generated single-file HTML with inline `<style>` blocks, Tailwind CDN classes, or embedded CSS. May include inline `<script>` tags.

### Output

A multi-file project with:
- Separated HTML pages (one per screen/page)
- External CSS files (partials compiled to a single stylesheet)
- External JS file(s)
- All assets organized in named directories
- Every page loads in a browser and is fully functional with no server

### Steps

```
1.  Audit the AI output — inventory every page/section/component
2.  Create the project directory structure
3.  Extract all CSS into partials organized by component
4.  Convert Tailwind utilities to semantic BEM classes (if Tailwind was used)
5.  Extract all JS into external files
6.  Define the layout system (container, grid, sidebar + content)
7.  Define the component API (variants, sizes, states for each component)
8.  Build each HTML page using shared partials (header, footer, nav)
9.  Replace all hardcoded values with CSS custom properties
10. Add responsive behavior (mobile-first, inside each component file)
11. Add accessibility markup
12. Add interaction states and transitions
13. Add dark mode variable overrides
14. Populate pages with realistic sample data
15. Cross-browser test
16. Build dist/ (concatenate, minify)
17. Version tag and changelog entry
```

---

## 2. Project Structure

```
hostnodes-theme/
├── index.html                          # Homepage
├── login.html                          # Login page
├── register.html                       # Registration
├── password-reset.html                 # Password reset request
├── client-dashboard.html               # Client area dashboard
├── client-services.html                # Services list
├── client-service-detail.html          # Single service management
├── client-domains.html                 # Domains list
├── client-domain-pricing.html          # Domain pricing table
├── client-invoices.html                # Invoices list
├── client-invoice-view.html            # Single invoice
├── client-quotes.html                  # Quotes list
├── client-quote-view.html              # Single quote
├── client-tickets.html                 # Support tickets list
├── client-ticket-view.html             # Single ticket thread
├── client-ticket-open.html             # Open new ticket
├── client-account.html                 # Account/profile settings
├── client-security.html                # Security settings (2FA, password)
├── client-contacts.html                # Sub-accounts / contacts
├── client-emails.html                  # Email history
├── client-payment-methods.html         # Saved payment methods
├── client-affiliates.html              # Affiliate dashboard
├── client-downloads.html               # Downloads / file manager
├── client-upgrade.html                 # Service upgrade/downgrade
├── knowledgebase.html                  # KB categories
├── knowledgebase-article.html          # Single KB article
├── announcements.html                  # Announcements list
├── announcement-view.html              # Single announcement
├── cart.html                           # Shopping cart
├── checkout.html                       # Checkout flow
├── order-confirmation.html             # Order complete / thank you
├── domain-search.html                  # Domain search + results
├── contact.html                        # Contact / open ticket (public)
├── 404.html                            # Not found
├── 500.html                            # Server error
├── maintenance.html                    # Maintenance mode
├── email-verification.html             # Email verification prompt
│
├── _partials/                          # Shared HTML fragments (build tool consumes these)
│   ├── head.html                       # <head> contents
│   ├── header.html                     # Site header + nav
│   ├── footer.html                     # Site footer
│   ├── sidebar.html                    # Client area sidebar
│   └── scripts.html                    # Pre-</body> script tags
│
├── assets/
│   ├── css/
│   │   ├── variables.css               # All CSS custom properties
│   │   ├── reset.css                   # Modern CSS reset
│   │   ├── base.css                    # Typography, body defaults, @font-face
│   │   ├── layout.css                  # Container, grid, page structure, header, footer
│   │   ├── components/
│   │   │   ├── buttons.css             # Includes own responsive rules
│   │   │   ├── cards.css
│   │   │   ├── forms.css
│   │   │   ├── tables.css
│   │   │   ├── alerts.css
│   │   │   ├── modals.css
│   │   │   ├── badges.css
│   │   │   ├── tabs.css
│   │   │   ├── pagination.css
│   │   │   ├── breadcrumb.css
│   │   │   ├── sidebar.css
│   │   │   ├── navbar.css
│   │   │   ├── dropdown.css
│   │   │   ├── tooltips.css
│   │   │   ├── status-indicators.css
│   │   │   ├── empty-states.css
│   │   │   ├── loading.css
│   │   │   └── icons.css               # Icon sizing, alignment
│   │   ├── pages/
│   │   │   ├── homepage.css
│   │   │   ├── login.css
│   │   │   ├── dashboard.css
│   │   │   ├── invoices.css
│   │   │   ├── tickets.css
│   │   │   ├── knowledgebase.css
│   │   │   ├── cart.css
│   │   │   ├── domain-search.css
│   │   │   ├── domain-pricing.css
│   │   │   ├── affiliates.css
│   │   │   └── upgrade.css
│   │   ├── utilities.css               # Spacing, text, display helpers
│   │   ├── dark-mode.css               # Dark theme variable overrides
│   │   ├── print.css                   # Print styles (invoices, quotes)
│   │   └── main.css                    # Single import file (dev only — see Build Tooling)
│   │
│   ├── js/
│   │   └── main.js                     # All theme JS
│   │
│   ├── icons/                          # SVG icon sprites
│   │   ├── icons.svg                   # Combined SVG sprite sheet
│   │   └── individual/                 # Source SVGs (for reference)
│   │       ├── arrow-right.svg
│   │       ├── check.svg
│   │       ├── chevron-down.svg
│   │       ├── close.svg
│   │       ├── ...
│   │       └── [all individual icons]
│   │
│   ├── images/
│   │   ├── logo.svg
│   │   ├── logo-dark.svg               # Logo for dark mode
│   │   ├── og-image.jpg                # Open Graph image (1200x630)
│   │   ├── favicon/
│   │   │   ├── favicon.ico
│   │   │   ├── favicon-16.png
│   │   │   ├── favicon-32.png
│   │   │   ├── apple-touch-icon.png    # 180x180
│   │   │   ├── icon-192.png
│   │   │   ├── icon-512.png
│   │   │   └── site.webmanifest
│   │   ├── empty-states/               # Illustrations for empty state pages
│   │   │   ├── no-services.svg
│   │   │   ├── no-invoices.svg
│   │   │   ├── no-tickets.svg
│   │   │   └── no-results.svg
│   │   └── [page-specific images]
│   │
│   └── fonts/
│       ├── inter-regular.woff2
│       ├── inter-medium.woff2
│       ├── inter-semibold.woff2
│       └── inter-bold.woff2
│
├── dist/                               # Built distribution files (gitignored, generated by build)
│   ├── css/
│   │   └── main.min.css               # All CSS concatenated + minified
│   ├── js/
│   │   └── main.min.js                # Minified JS
│   ├── icons/
│   ├── images/
│   └── fonts/
│
├── package.json                        # Build scripts
├── README.md
├── CHANGELOG.md
└── LICENSE.md
```

### main.css — Import Order (Development Only)

This file is used during development with native CSS `@import`. The build tool concatenates these into `dist/css/main.min.css` for production. Never ship `main.css` with `@import` chains — browsers load them as waterfalls.

```css
/* === Foundation === */
@import 'variables.css';
@import 'reset.css';
@import 'base.css';

/* === Layout === */
@import 'layout.css';

/* === Components (each file includes its own responsive rules) === */
@import 'components/buttons.css';
@import 'components/cards.css';
@import 'components/forms.css';
@import 'components/tables.css';
@import 'components/alerts.css';
@import 'components/modals.css';
@import 'components/badges.css';
@import 'components/tabs.css';
@import 'components/pagination.css';
@import 'components/breadcrumb.css';
@import 'components/sidebar.css';
@import 'components/navbar.css';
@import 'components/dropdown.css';
@import 'components/tooltips.css';
@import 'components/status-indicators.css';
@import 'components/empty-states.css';
@import 'components/loading.css';
@import 'components/icons.css';

/* === Page-Specific === */
@import 'pages/homepage.css';
@import 'pages/login.css';
@import 'pages/dashboard.css';
@import 'pages/invoices.css';
@import 'pages/tickets.css';
@import 'pages/knowledgebase.css';
@import 'pages/cart.css';
@import 'pages/domain-search.css';
@import 'pages/domain-pricing.css';
@import 'pages/affiliates.css';
@import 'pages/upgrade.css';

/* === Utilities (high specificity — load last) === */
@import 'utilities.css';

/* === Dark Mode === */
@import 'dark-mode.css';

/* === Print === */
@import 'print.css';
```

---

## 3. Build Tooling

### Why

CSS `@import` in the browser creates waterfall requests — each file loads sequentially. A 25-file import chain means 25 HTTP requests. This is unacceptable for production. The build tool concatenates all CSS into one file and minifies it.

### Recommended: PostCSS + postcss-import + cssnano

Minimal setup — no Webpack, no Vite, no bundler. Just CSS processing.

```json
// package.json
{
    "name": "hostnodes-theme",
    "version": "1.0.0",
    "private": true,
    "scripts": {
        "css:build": "postcss assets/css/main.css -o dist/css/main.min.css",
        "js:build": "terser assets/js/main.js -o dist/js/main.min.js -c -m",
        "build": "npm run css:build && npm run js:build && npm run copy:assets",
        "copy:assets": "cp -r assets/images dist/images && cp -r assets/fonts dist/fonts && cp -r assets/icons dist/icons",
        "watch": "postcss assets/css/main.css -o dist/css/main.min.css --watch",
        "dev": "npm run watch"
    },
    "devDependencies": {
        "postcss": "^8.4.0",
        "postcss-cli": "^11.0.0",
        "postcss-import": "^16.0.0",
        "cssnano": "^7.0.0",
        "autoprefixer": "^10.4.0",
        "terser": "^5.30.0"
    }
}
```

```js
// postcss.config.js
module.exports = {
    plugins: [
        require('postcss-import'),       // Inlines @import into single file
        require('autoprefixer'),          // Adds vendor prefixes
        require('cssnano')({             // Minifies
            preset: ['default', {
                discardComments: { removeAll: true }
            }]
        })
    ]
};
```

### Build Commands

```bash
# Install dependencies (one time)
npm install

# Development: watch for changes, rebuild CSS automatically
npm run dev

# Production: build everything into dist/
npm run build
```

### Shared HTML Partials

Use a simple Node script or Nunjucks for compiling `_partials/` into each HTML page:

```json
// Add to package.json scripts
"html:build": "node build-html.js"
```

```js
// build-html.js — minimal partial compiler
const fs = require('fs');
const path = require('path');

const partialsDir = '_partials';
const partials = {};

// Load all partials
fs.readdirSync(partialsDir).forEach(file => {
    const name = path.basename(file, '.html');
    partials[name] = fs.readFileSync(path.join(partialsDir, file), 'utf8');
});

// Process each HTML file in root
fs.readdirSync('.').filter(f => f.endsWith('.html')).forEach(file => {
    let content = fs.readFileSync(file, 'utf8');
    // Replace <!--@include partial-name --> with partial content
    content = content.replace(/<!--@include\s+([\w-]+)\s*-->/g, (match, name) => {
        return partials[name] || match;
    });
    fs.writeFileSync(path.join('dist', file), content);
});
```

Usage in HTML files:

```html
<!DOCTYPE html>
<html lang="en" data-theme="light">
<!--@include head -->
<body>
    <a href="#main-content" class="hn-skip-link">Skip to content</a>
    <!--@include header -->

    <main id="main-content" class="hn-main">
        <!-- Page-specific content here -->
    </main>

    <!--@include footer -->
    <!--@include scripts -->
</body>
</html>
```

### What Ships

The `dist/` folder is what buyers receive:
- All HTML pages (with partials inlined)
- `dist/css/main.min.css` (single file, minified)
- `dist/js/main.min.js` (single file, minified)
- `dist/images/`, `dist/fonts/`, `dist/icons/`
- README.md, CHANGELOG.md, LICENSE.md

Also include `assets/css/` source files so buyers can customize variables and rebuild.

---

## 4. HTML Standards

### Document Setup

Every HTML page must have:

```html
<!DOCTYPE html>
<html lang="en" dir="ltr" data-theme="light">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="Page description here">
    <meta name="author" content="Hostnodes">
    <meta name="theme-color" content="#3b82f6" media="(prefers-color-scheme: light)">
    <meta name="theme-color" content="#0f172a" media="(prefers-color-scheme: dark)">

    <!-- Open Graph -->
    <meta property="og:title" content="Page Title — Hostnodes">
    <meta property="og:description" content="Page description">
    <meta property="og:type" content="website">
    <meta property="og:image" content="assets/images/og-image.jpg">

    <!-- Twitter Card -->
    <meta name="twitter:card" content="summary_large_image">

    <!-- Favicon -->
    <link rel="icon" href="assets/images/favicon/favicon.ico" sizes="any">
    <link rel="icon" type="image/png" sizes="32x32" href="assets/images/favicon/favicon-32.png">
    <link rel="icon" type="image/png" sizes="16x16" href="assets/images/favicon/favicon-16.png">
    <link rel="apple-touch-icon" href="assets/images/favicon/apple-touch-icon.png">
    <link rel="manifest" href="assets/images/favicon/site.webmanifest">

    <title>Page Title — Hostnodes</title>

    <!-- Fonts (preload critical weights only) -->
    <link rel="preload" href="assets/fonts/inter-regular.woff2" as="font" type="font/woff2" crossorigin>
    <link rel="preload" href="assets/fonts/inter-semibold.woff2" as="font" type="font/woff2" crossorigin>

    <!-- Styles -->
    <link rel="stylesheet" href="assets/css/main.css">
</head>
<body>
    <a href="#main-content" class="hn-skip-link">Skip to content</a>

    <!-- Header / Nav -->
    <header class="hn-header" role="banner">...</header>

    <!-- Main Content -->
    <main id="main-content" class="hn-main" role="main">...</main>

    <!-- Footer -->
    <footer class="hn-footer" role="contentinfo">...</footer>

    <!-- Scripts -->
    <script src="assets/js/main.js" defer></script>
</body>
</html>
```

Note: `dir="ltr"` is set on `<html>` for RTL readiness (see Section 15).

### Semantic Markup

```html
<!-- GOOD -->
<header class="hn-header">
    <nav class="hn-nav" aria-label="Main navigation">
        <ul class="hn-nav__list" role="list">
            <li class="hn-nav__item">
                <a href="/" class="hn-nav__link" aria-current="page">Home</a>
            </li>
        </ul>
    </nav>
</header>

<main id="main-content" class="hn-main">
    <section class="hn-section" aria-labelledby="services-heading">
        <h2 id="services-heading">Our Services</h2>
        <article class="hn-card">...</article>
    </section>
</main>

<aside class="hn-sidebar" role="complementary" aria-label="Account menu">
    ...
</aside>

<footer class="hn-footer" role="contentinfo">
    ...
</footer>

<!-- BAD -->
<div class="header">
    <div class="nav">
        <div class="nav-item"><a href="/">Home</a></div>
    </div>
</div>
```

**Rules:**
- One `<h1>` per page, no skipped heading levels
- Use `<section>` with `aria-labelledby` pointing to its heading
- Use `<article>` for self-contained content blocks (cards, tickets, KB articles)
- Use `<aside>` for sidebar, complementary content
- Use `<figure>` + `<figcaption>` for images with captions
- Use `<time datetime="2026-04-13">` for all dates
- Use `<address>` for contact information
- Use `<dl>` for key-value data (service details, invoice metadata)

### Accessibility (WCAG 2.1 AA)

**Required on every page:**
- Skip-to-content link (first focusable element)
- All images: meaningful `alt` or `alt=""` if decorative
- `aria-label` on icon-only buttons: `<button aria-label="Close">...</button>`
- `aria-current="page"` on active nav link
- `aria-expanded="true|false"` on dropdown/accordion toggles
- `aria-controls="panel-id"` linking toggles to their content
- Visible `:focus-visible` states on every interactive element
- Color contrast: 4.5:1 body text, 3:1 large text (18px+ or 14px+ bold)
- Form inputs have associated `<label>` (not placeholder-only)
- Keyboard navigation works with Tab key alone
- Error messages linked to inputs with `aria-describedby`
- `role="alert"` on dynamic error/success messages
- Tables have `<caption>` and `scope="col"` / `scope="row"` on header cells
- All SVG icons inside interactive elements have `aria-hidden="true"` (the parent carries the label)
- `role="list"` on `<ul>`/`<ol>` when list-style is removed (Safari VoiceOver quirk)

**Test with:**
- Tab key only (full page navigation)
- axe DevTools browser extension
- WAVE browser extension
- VoiceOver (macOS) or NVDA (Windows) on: login, dashboard, ticket view, invoice

### Forms

```html
<form class="hn-form" novalidate>
    <div class="hn-form__group">
        <label for="email" class="hn-form__label">
            Email Address
            <span class="hn-form__required" aria-hidden="true">*</span>
        </label>
        <input
            type="email"
            id="email"
            name="email"
            class="hn-form__input"
            autocomplete="email"
            required
            aria-describedby="email-hint email-error"
            placeholder="you@example.com"
        >
        <p id="email-hint" class="hn-form__hint">We'll never share your email.</p>
        <p id="email-error" class="hn-form__error" role="alert" hidden>
            Please enter a valid email address.
        </p>
    </div>

    <div class="hn-form__group">
        <label for="password" class="hn-form__label">Password</label>
        <div class="hn-form__input-group">
            <input
                type="password"
                id="password"
                name="password"
                class="hn-form__input"
                autocomplete="current-password"
                required
                minlength="8"
                aria-describedby="password-error"
            >
            <button type="button" class="hn-form__toggle" data-hn-toggle="password-visibility" aria-label="Show password">
                <svg class="hn-icon" aria-hidden="true">
                    <use href="assets/icons/icons.svg#eye"></use>
                </svg>
            </button>
        </div>
        <p id="password-error" class="hn-form__error" role="alert" hidden>
            Password must be at least 8 characters.
        </p>
    </div>

    <button type="submit" class="hn-btn hn-btn--primary hn-btn--full">Sign In</button>
</form>
```

**Rules:**
- Always use `novalidate` + JS validation (styled consistently with the theme)
- `autocomplete` on every login, register, and billing field
- Proper `type`: `email`, `tel`, `url`, `password`, `number`, `search`
- `required`, `minlength`, `maxlength`, `pattern` where applicable
- Error messages: visible, associated via `aria-describedby`, use `role="alert"`
- Hint text for complex fields (password requirements, format expectations)
- Required fields marked visually (`*`) with `aria-hidden="true"` on the marker + `required` on the input
- Input groups for fields with appended buttons (password toggle, search submit)

---

## 5. CSS Standards

### Naming: BEM with `hn-` Prefix

Every custom class is prefixed with `hn-` to prevent collision when integrated into WHMCS (which has Bootstrap classes everywhere):

```css
/* Block */
.hn-card { }

/* Element */
.hn-card__title { }
.hn-card__body { }
.hn-card__footer { }
.hn-card__image { }

/* Modifier */
.hn-card--featured { }
.hn-card--compact { }

/* State (use aria or data attributes, not classes, where possible) */
.hn-nav__link[aria-current="page"] { }
.hn-accordion__panel[aria-hidden="true"] { }

/* Fallback state classes when attribute isn't available */
.hn-card.is-loading { }
.hn-btn.is-disabled { }
```

**Rules:**
- No unprefixed custom classes
- No ID selectors for styling
- Max 3 levels of nesting
- No `!important` (standalone phase has no need for it)
- Avoid tag selectors in component CSS (use classes)

### Responsive Rules Live Inside Component Files

Every component file contains its own media queries at the bottom. No separate `responsive.css` file. This keeps each component self-contained — when you change a component, everything about it is in one file.

```css
/* components/navbar.css */

/* === Base (mobile) === */
.hn-nav { ... }
.hn-nav__list { ... }
.hn-nav__link { ... }

/* === Responsive === */
@media (min-width: 768px) {
    .hn-nav__list {
        flex-direction: row;
    }
}

@media (min-width: 992px) {
    .hn-nav {
        padding-inline: var(--hn-space-8);
    }
}
```

**Exception:** `layout.css` contains global layout breakpoints (container width changes, grid column shifts, sidebar visibility) since those affect the entire page skeleton.

### CSS Custom Properties (Design Tokens)

`variables.css` — the single source of truth for the entire design system:

```css
:root {
    /* ========================================
       BRAND COLORS
       ======================================== */
    --hn-color-primary: #3b82f6;
    --hn-color-primary-hover: #2563eb;
    --hn-color-primary-active: #1d4ed8;
    --hn-color-primary-light: #eff6ff;
    --hn-color-primary-rgb: 59, 130, 246;           /* For rgba() usage */

    --hn-color-secondary: #6366f1;
    --hn-color-secondary-hover: #4f46e5;
    --hn-color-secondary-active: #4338ca;
    --hn-color-secondary-light: #eef2ff;

    --hn-color-accent: #f59e0b;
    --hn-color-accent-hover: #d97706;
    --hn-color-accent-light: #fffbeb;

    /* ========================================
       NEUTRAL SCALE
       ======================================== */
    --hn-color-gray-50: #f9fafb;
    --hn-color-gray-100: #f3f4f6;
    --hn-color-gray-200: #e5e7eb;
    --hn-color-gray-300: #d1d5db;
    --hn-color-gray-400: #9ca3af;
    --hn-color-gray-500: #6b7280;
    --hn-color-gray-600: #4b5563;
    --hn-color-gray-700: #374151;
    --hn-color-gray-800: #1f2937;
    --hn-color-gray-900: #111827;
    --hn-color-gray-950: #030712;

    /* ========================================
       SEMANTIC COLORS
       ======================================== */
    --hn-color-text: var(--hn-color-gray-800);
    --hn-color-text-muted: var(--hn-color-gray-500);
    --hn-color-text-inverse: #ffffff;
    --hn-color-bg: #ffffff;
    --hn-color-bg-alt: var(--hn-color-gray-50);
    --hn-color-bg-elevated: #ffffff;
    --hn-color-border: var(--hn-color-gray-200);
    --hn-color-border-strong: var(--hn-color-gray-300);

    /* ========================================
       STATUS COLORS
       (Aligned with WHMCS status system for Phase 2)
       ======================================== */
    --hn-color-success: #10b981;
    --hn-color-success-hover: #059669;
    --hn-color-success-light: #ecfdf5;
    --hn-color-warning: #f59e0b;
    --hn-color-warning-hover: #d97706;
    --hn-color-warning-light: #fffbeb;
    --hn-color-danger: #ef4444;
    --hn-color-danger-hover: #dc2626;
    --hn-color-danger-light: #fef2f2;
    --hn-color-info: #3b82f6;
    --hn-color-info-hover: #2563eb;
    --hn-color-info-light: #eff6ff;

    /* ========================================
       TYPOGRAPHY
       ======================================== */
    --hn-font-body: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
    --hn-font-heading: var(--hn-font-body);
    --hn-font-mono: 'JetBrains Mono', 'Fira Code', 'Cascadia Code', monospace;

    --hn-text-xs: 0.75rem;       /* 12px */
    --hn-text-sm: 0.875rem;      /* 14px */
    --hn-text-base: 1rem;        /* 16px */
    --hn-text-lg: 1.125rem;      /* 18px */
    --hn-text-xl: 1.25rem;       /* 20px */
    --hn-text-2xl: 1.5rem;       /* 24px */
    --hn-text-3xl: 1.875rem;     /* 30px */
    --hn-text-4xl: 2.25rem;      /* 36px */

    --hn-leading-tight: 1.2;
    --hn-leading-snug: 1.375;
    --hn-leading-normal: 1.6;
    --hn-leading-relaxed: 1.75;

    --hn-tracking-tight: -0.02em;
    --hn-tracking-normal: 0;
    --hn-tracking-wide: 0.025em;

    /* ========================================
       SPACING SCALE (8px base)
       ======================================== */
    --hn-space-0: 0;
    --hn-space-1: 0.25rem;       /* 4px */
    --hn-space-2: 0.5rem;        /* 8px */
    --hn-space-3: 0.75rem;       /* 12px */
    --hn-space-4: 1rem;          /* 16px */
    --hn-space-5: 1.25rem;       /* 20px */
    --hn-space-6: 1.5rem;        /* 24px */
    --hn-space-8: 2rem;          /* 32px */
    --hn-space-10: 2.5rem;       /* 40px */
    --hn-space-12: 3rem;         /* 48px */
    --hn-space-16: 4rem;         /* 64px */
    --hn-space-20: 5rem;         /* 80px */
    --hn-space-24: 6rem;         /* 96px */

    /* ========================================
       BORDERS & RADIUS
       ======================================== */
    --hn-radius-sm: 0.25rem;     /* 4px */
    --hn-radius-md: 0.5rem;      /* 8px */
    --hn-radius-lg: 0.75rem;     /* 12px */
    --hn-radius-xl: 1rem;        /* 16px */
    --hn-radius-2xl: 1.5rem;     /* 24px */
    --hn-radius-full: 9999px;

    --hn-border-width: 1px;

    /* ========================================
       SHADOWS
       ======================================== */
    --hn-shadow-xs: 0 1px 2px rgba(0, 0, 0, 0.04);
    --hn-shadow-sm: 0 1px 3px rgba(0, 0, 0, 0.06), 0 1px 2px rgba(0, 0, 0, 0.04);
    --hn-shadow-md: 0 4px 6px rgba(0, 0, 0, 0.05), 0 2px 4px rgba(0, 0, 0, 0.04);
    --hn-shadow-lg: 0 10px 15px rgba(0, 0, 0, 0.06), 0 4px 6px rgba(0, 0, 0, 0.04);
    --hn-shadow-xl: 0 20px 25px rgba(0, 0, 0, 0.08), 0 8px 10px rgba(0, 0, 0, 0.04);
    --hn-shadow-inner: inset 0 2px 4px rgba(0, 0, 0, 0.05);
    --hn-shadow-focus: 0 0 0 3px rgba(var(--hn-color-primary-rgb), 0.3);

    /* ========================================
       TRANSITIONS
       ======================================== */
    --hn-duration-fast: 100ms;
    --hn-duration-base: 200ms;
    --hn-duration-slow: 300ms;
    --hn-duration-slower: 500ms;
    --hn-ease-default: cubic-bezier(0.4, 0, 0.2, 1);
    --hn-ease-in: cubic-bezier(0.4, 0, 1, 1);
    --hn-ease-out: cubic-bezier(0, 0, 0.2, 1);

    /* ========================================
       Z-INDEX SCALE
       ======================================== */
    --hn-z-base: 0;
    --hn-z-dropdown: 100;
    --hn-z-sticky: 200;
    --hn-z-fixed: 300;
    --hn-z-overlay: 400;
    --hn-z-modal: 500;
    --hn-z-tooltip: 600;

    /* ========================================
       LAYOUT
       ======================================== */
    --hn-container-max: 1280px;
    --hn-container-narrow: 720px;
    --hn-container-wide: 1440px;
    --hn-container-padding: var(--hn-space-4);
    --hn-sidebar-width: 280px;
    --hn-header-height: 64px;
}
```

**Rule: every visual value in your CSS must reference a variable.** No hardcoded colors, spacing, font sizes, shadows, radii, or transitions outside of `variables.css`.

### Reset

Use Josh Comeau's Modern CSS Reset or Andy Bell's. Place in `reset.css`, loaded after `variables.css`:

```css
*,
*::before,
*::after {
    box-sizing: border-box;
}

* {
    margin: 0;
    padding: 0;
}

html {
    -moz-text-size-adjust: none;
    -webkit-text-size-adjust: none;
    text-size-adjust: none;
    scroll-behavior: smooth;
}

@media (prefers-reduced-motion: reduce) {
    html {
        scroll-behavior: auto;
    }
}

body {
    min-height: 100vh;
    min-height: 100dvh;
    line-height: var(--hn-leading-normal);
    -webkit-font-smoothing: antialiased;
}

img, picture, video, canvas, svg {
    display: block;
    max-width: 100%;
}

input, button, textarea, select {
    font: inherit;
    color: inherit;
}

p, h1, h2, h3, h4, h5, h6 {
    overflow-wrap: break-word;
}

h1, h2, h3, h4, h5, h6 {
    text-wrap: balance;
}

p {
    text-wrap: pretty;
}

a {
    color: inherit;
    text-decoration: inherit;
}

ul[role="list"],
ol[role="list"] {
    list-style: none;
}

/* Remove default button styles */
button {
    background: none;
    border: none;
    cursor: pointer;
}

/* Hide elements with hidden attribute */
[hidden] {
    display: none !important;
}
```

### Units

| Use | For |
|-----|-----|
| `rem` | Typography, spacing, padding, margins |
| `em` | Component-internal spacing tied to own font-size |
| `%` or `fr` | Layout widths, grid columns |
| `vw`/`vh`/`dvh` | Full-viewport elements (hero, modals) |
| `px` | Borders (1-3px), box-shadow offsets |
| `clamp()` | Fluid typography, fluid spacing |
| `ch` | Max content width (e.g., `max-width: 65ch`) |

---

## 6. Layout System

Defined in `layout.css`. This is the structural backbone every page depends on.

### Container

```css
.hn-container {
    width: 100%;
    max-width: var(--hn-container-max);
    margin-inline: auto;
    padding-inline: var(--hn-container-padding);
}

.hn-container--narrow {
    max-width: var(--hn-container-narrow);
}

.hn-container--wide {
    max-width: var(--hn-container-wide);
}

@media (min-width: 768px) {
    :root {
        --hn-container-padding: var(--hn-space-6);
    }
}

@media (min-width: 1200px) {
    :root {
        --hn-container-padding: var(--hn-space-8);
    }
}
```

### Grid System

CSS Grid-based. No fixed column count — use the grid that fits the content:

```css
/* Auto-fill responsive grid (cards, features, pricing) */
.hn-grid {
    display: grid;
    gap: var(--hn-space-6);
}

.hn-grid--2 { grid-template-columns: repeat(1, 1fr); }
.hn-grid--3 { grid-template-columns: repeat(1, 1fr); }
.hn-grid--4 { grid-template-columns: repeat(1, 1fr); }

@media (min-width: 576px) {
    .hn-grid--2 { grid-template-columns: repeat(2, 1fr); }
    .hn-grid--4 { grid-template-columns: repeat(2, 1fr); }
}

@media (min-width: 768px) {
    .hn-grid--3 { grid-template-columns: repeat(2, 1fr); }
}

@media (min-width: 992px) {
    .hn-grid--3 { grid-template-columns: repeat(3, 1fr); }
    .hn-grid--4 { grid-template-columns: repeat(3, 1fr); }
}

@media (min-width: 1200px) {
    .hn-grid--4 { grid-template-columns: repeat(4, 1fr); }
}

/* Auto-fit grid (adapts to available space) */
.hn-grid--auto {
    grid-template-columns: repeat(auto-fill, minmax(min(280px, 100%), 1fr));
}
```

### Page Layouts

```css
/* === Full-width layout (homepage, public pages) === */
.hn-layout {
    display: flex;
    flex-direction: column;
    min-height: 100vh;
    min-height: 100dvh;
}

.hn-layout__content {
    flex: 1;
}

/* === Sidebar + content layout (client area) === */
.hn-layout--sidebar {
    display: flex;
    flex-direction: column;
}

.hn-layout--sidebar .hn-layout__content {
    flex: 1;
    min-width: 0; /* Prevent content from overflowing */
}

@media (min-width: 992px) {
    .hn-layout--sidebar {
        flex-direction: row;
    }
    .hn-layout--sidebar .hn-sidebar {
        width: var(--hn-sidebar-width);
        flex-shrink: 0;
    }
    .hn-layout--sidebar .hn-layout__content {
        padding-inline-start: var(--hn-space-8);
    }
}

/* === Centered narrow layout (login, register, password reset) === */
.hn-layout--centered {
    display: flex;
    align-items: center;
    justify-content: center;
    min-height: 100vh;
    min-height: 100dvh;
    padding: var(--hn-space-4);
}

.hn-layout--centered .hn-layout__content {
    width: 100%;
    max-width: 440px;
}
```

### Section Spacing

```css
/* Vertical spacing between page sections */
.hn-section {
    padding-block: var(--hn-space-12);
}

.hn-section--sm {
    padding-block: var(--hn-space-8);
}

.hn-section--lg {
    padding-block: var(--hn-space-16);
}

/* Page header area (title + breadcrumb) */
.hn-page-header {
    padding-block: var(--hn-space-6);
    border-bottom: 1px solid var(--hn-color-border);
    margin-bottom: var(--hn-space-8);
}
```

---

## 7. Component API

Every component must have defined variants, sizes, and states. This is the contract — pages reference these, they don't invent their own one-off classes.

### Buttons

```
Block:     .hn-btn
Variants:  --primary, --secondary, --outline, --ghost, --danger, --success
Sizes:     --sm, --md (default), --lg
Width:     --full (100% width)
States:    :hover, :focus-visible, :active, :disabled, .is-loading
Icon:      .hn-btn__icon (SVG inside button, before or after text)
```

```css
/* Base */
.hn-btn {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    gap: var(--hn-space-2);
    font-weight: 600;
    font-size: var(--hn-text-sm);
    line-height: 1;
    padding: var(--hn-space-3) var(--hn-space-5);
    border-radius: var(--hn-radius-md);
    border: var(--hn-border-width) solid transparent;
    transition: all var(--hn-duration-base) var(--hn-ease-default);
    cursor: pointer;
    white-space: nowrap;
    text-decoration: none;
}

/* Variants */
.hn-btn--primary {
    background: var(--hn-color-primary);
    color: var(--hn-color-text-inverse);
}
.hn-btn--primary:hover {
    background: var(--hn-color-primary-hover);
    box-shadow: var(--hn-shadow-sm);
}

.hn-btn--outline {
    background: transparent;
    border-color: var(--hn-color-border-strong);
    color: var(--hn-color-text);
}
.hn-btn--outline:hover {
    background: var(--hn-color-bg-alt);
    border-color: var(--hn-color-gray-400);
}

.hn-btn--ghost {
    background: transparent;
    color: var(--hn-color-text);
}
.hn-btn--ghost:hover {
    background: var(--hn-color-bg-alt);
}

.hn-btn--danger {
    background: var(--hn-color-danger);
    color: var(--hn-color-text-inverse);
}
.hn-btn--danger:hover {
    background: var(--hn-color-danger-hover);
}

.hn-btn--success {
    background: var(--hn-color-success);
    color: var(--hn-color-text-inverse);
}

.hn-btn--secondary {
    background: var(--hn-color-secondary);
    color: var(--hn-color-text-inverse);
}

/* Sizes */
.hn-btn--sm { font-size: var(--hn-text-xs); padding: var(--hn-space-2) var(--hn-space-3); }
.hn-btn--lg { font-size: var(--hn-text-base); padding: var(--hn-space-4) var(--hn-space-8); }
.hn-btn--full { width: 100%; }

/* States */
.hn-btn:focus-visible {
    outline: none;
    box-shadow: var(--hn-shadow-focus);
}

.hn-btn:active {
    transform: translateY(1px);
}

.hn-btn:disabled,
.hn-btn.is-disabled {
    opacity: 0.5;
    cursor: not-allowed;
    pointer-events: none;
}

.hn-btn.is-loading {
    position: relative;
    color: transparent;
    pointer-events: none;
}
.hn-btn.is-loading::after {
    content: '';
    position: absolute;
    width: 1em;
    height: 1em;
    border: 2px solid currentColor;
    border-right-color: transparent;
    border-radius: var(--hn-radius-full);
    animation: hn-spin 0.6s linear infinite;
    color: var(--hn-color-text-inverse);
}

/* Icon inside button */
.hn-btn__icon {
    width: 1em;
    height: 1em;
    flex-shrink: 0;
}
```

### Cards

```
Block:     .hn-card
Elements:  __header, __body, __footer, __title, __subtitle, __text, __image, __badge, __actions
Variants:  --bordered (default), --elevated, --flat, --interactive (clickable)
```

### Alerts

```
Block:     .hn-alert
Elements:  __icon, __content, __title, __text, __dismiss
Variants:  --info (default), --success, --warning, --danger
Modifier:  --dismissible (has close button)
```

### Badges

```
Block:     .hn-badge
Variants:  --primary, --secondary, --success, --warning, --danger, --info, --neutral
Modifier:  --pill (fully rounded), --dot (status dot only)
```

### Tables

```
Block:     .hn-table
Elements:  __caption, __head, __body, __row, __cell, __actions
Variants:  --striped, --hoverable, --compact, --bordered
Wrapper:   .hn-table-wrap (scroll container)
Modifier:  --stack (stacks on mobile — see Section 9)
```

### Forms

```
Block:     .hn-form
Elements:  __group, __label, __input, __select, __textarea, __checkbox, __radio,
           __error, __hint, __required, __input-group, __toggle
States:    .hn-form__input.is-invalid, .hn-form__input.is-valid
```

### Modals

```
Block:     .hn-modal
Elements:  __overlay, __dialog, __header, __body, __footer, __close
Sizes:     --sm (400px), --md (560px default), --lg (720px), --full
```

### Tabs

```
Block:     .hn-tabs
Elements:  __list, __tab, __panel
State:     .hn-tabs__tab[aria-selected="true"]
```

### Pagination

```
Block:     .hn-pagination
Elements:  __list, __item, __link, __ellipsis
State:     .hn-pagination__link[aria-current="page"]
```

### Breadcrumb

```
Block:     .hn-breadcrumb
Elements:  __list, __item, __link, __separator
State:     .hn-breadcrumb__item[aria-current="page"]
```

### Status Indicators

```
Block:     .hn-status
Variants:  --active, --pending, --suspended, --terminated, --cancelled,
           --paid, --unpaid, --overdue, --refunded,
           --open, --answered, --closed, --in-progress
Modifier:  --badge (pill background), --dot (colored dot + text)
```

### Empty States

```
Block:     .hn-empty
Elements:  __icon, __image, __title, __text, __action
```

### Loading

```
Block:     .hn-loading
Elements:  __spinner, __text
Variants:  --inline (inline with content), --overlay (covers parent), --page (full page)
```

---

## 8. Icon Strategy

### Approach: SVG Sprite Sheet

Use a single SVG sprite file (`assets/icons/icons.svg`) referenced via `<use>`. This gives:
- Single HTTP request for all icons
- CSS-styleable (fill, stroke, size via `currentColor`)
- Crisp at any size
- No icon font rendering issues

### Sprite File Structure

```xml
<!-- assets/icons/icons.svg -->
<svg xmlns="http://www.w3.org/2000/svg" style="display: none;">
    <symbol id="arrow-right" viewBox="0 0 24 24">
        <path d="M5 12h14M12 5l7 7-7 7" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" fill="none"/>
    </symbol>
    <symbol id="check" viewBox="0 0 24 24">
        <path d="M20 6L9 17l-5-5" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" fill="none"/>
    </symbol>
    <symbol id="chevron-down" viewBox="0 0 24 24">
        <path d="M6 9l6 6 6-6" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" fill="none"/>
    </symbol>
    <symbol id="close" viewBox="0 0 24 24">
        <path d="M18 6L6 18M6 6l12 12" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" fill="none"/>
    </symbol>
    <!-- ... all icons ... -->
</svg>
```

### Usage in HTML

```html
<!-- Decorative icon (inside labeled element) -->
<button class="hn-btn hn-btn--primary" aria-label="Go to next page">
    <svg class="hn-icon" aria-hidden="true">
        <use href="assets/icons/icons.svg#arrow-right"></use>
    </svg>
</button>

<!-- Icon with visible text -->
<a href="/tickets" class="hn-btn hn-btn--outline">
    <svg class="hn-icon hn-btn__icon" aria-hidden="true">
        <use href="assets/icons/icons.svg#ticket"></use>
    </svg>
    Open Ticket
</a>

<!-- Standalone meaningful icon (rare — prefer text labels) -->
<svg class="hn-icon" role="img" aria-label="Warning">
    <use href="assets/icons/icons.svg#alert-triangle"></use>
</svg>
```

### Icon CSS

```css
/* components/icons.css */

.hn-icon {
    width: 1.25em;
    height: 1.25em;
    flex-shrink: 0;
    fill: none;
    stroke: currentColor;
}

/* Size variants */
.hn-icon--xs { width: 0.875em; height: 0.875em; }
.hn-icon--sm { width: 1em; height: 1em; }
.hn-icon--lg { width: 1.5em; height: 1.5em; }
.hn-icon--xl { width: 2em; height: 2em; }
```

### Required Icon Set (Minimum)

```
Navigation:      arrow-left, arrow-right, chevron-down, chevron-right, menu, close, external-link
Actions:         plus, edit, trash, copy, download, upload, refresh, search, filter
Status:          check, check-circle, alert-triangle, alert-circle, info, x-circle, clock
Interface:       eye, eye-off, settings, user, users, bell, mail, lock, unlock
Content:         file, folder, image, link, globe, server, database, code
Social:          github, twitter, facebook, linkedin
Misc:            sun, moon (dark mode toggle), loader (spinning), star, heart
```

### Phase 2 Note

WHMCS 9 ships Font Awesome 5.10.1. In Phase 2, you'll have two choices:
1. Keep your SVG sprite system alongside Font Awesome (no conflict)
2. Replace your SVGs with Font Awesome classes where they overlap

The SVG sprite approach is cleaner, but you'll need Font Awesome for WHMCS module output you don't control. Both can coexist.

---

## 9. Responsive Design

### Mobile-First

All base styles target mobile. Complexity is added upward via `min-width` queries:

```css
/* Base: mobile */
.hn-grid { display: grid; gap: var(--hn-space-4); }

/* Tablet and up */
@media (min-width: 768px) {
    .hn-grid { grid-template-columns: repeat(2, 1fr); }
}

/* Desktop and up */
@media (min-width: 992px) {
    .hn-grid { grid-template-columns: repeat(3, 1fr); }
}
```

### Breakpoints

Aligned with Bootstrap 4 (for Phase 2 compatibility):

```css
/* sm */  @media (min-width: 576px)  { }
/* md */  @media (min-width: 768px)  { }
/* lg */  @media (min-width: 992px)  { }
/* xl */  @media (min-width: 1200px) { }
/* 2xl */ @media (min-width: 1536px) { }
```

### Where Responsive Rules Live

| File | Contains |
|------|----------|
| `layout.css` | Container padding changes, sidebar visibility, page layout shifts |
| `components/navbar.css` | Nav collapse/expand, hamburger menu |
| `components/sidebar.css` | Off-canvas behavior on mobile |
| `components/tables.css` | Table scroll/stack patterns |
| `components/[any].css` | That component's own responsive adjustments |
| `pages/[any].css` | Page-specific layout shifts |

No separate `responsive.css` file. Each file owns its own breakpoints.

### Testing Viewports

| Width | Device | Priority |
|-------|--------|----------|
| 320px | iPhone SE / small Android | High |
| 375px | iPhone 12-15 | High |
| 414px | iPhone Plus / large Android | Medium |
| 768px | iPad portrait | High |
| 1024px | iPad landscape / small laptop | High |
| 1280px | Standard laptop | High |
| 1440px | Large desktop | Medium |
| 1920px | Full HD monitor | Medium |

### Touch Targets

Minimum **44x44px** for every tappable element. Check:
- Navigation links
- Pagination buttons
- Table action buttons
- Dropdown toggles
- Close/dismiss buttons
- Form checkboxes and radio buttons

### Fluid Typography

```css
/* In base.css */
h1 { font-size: clamp(1.75rem, 1.2rem + 1.5vw, 2.5rem); }
h2 { font-size: clamp(1.5rem, 1.1rem + 1.1vw, 2rem); }
h3 { font-size: clamp(1.25rem, 1rem + 0.7vw, 1.5rem); }
h4 { font-size: clamp(1.125rem, 1rem + 0.4vw, 1.25rem); }
```

### Key Responsive Patterns

**Data tables:**

```css
/* Default: horizontal scroll wrapper */
.hn-table-wrap {
    overflow-x: auto;
    -webkit-overflow-scrolling: touch;
    border-radius: var(--hn-radius-md);
    border: 1px solid var(--hn-color-border);
}

/* Alternative: stacked cards on mobile */
@media (max-width: 767.98px) {
    .hn-table--stack thead { display: none; }
    .hn-table--stack tr {
        display: block;
        margin-bottom: var(--hn-space-4);
        border: 1px solid var(--hn-color-border);
        border-radius: var(--hn-radius-md);
        padding: var(--hn-space-3);
    }
    .hn-table--stack td {
        display: flex;
        justify-content: space-between;
        align-items: center;
        padding: var(--hn-space-2) 0;
        border-bottom: 1px solid var(--hn-color-border);
    }
    .hn-table--stack td:last-child {
        border-bottom: none;
    }
    .hn-table--stack td::before {
        content: attr(data-label);
        font-weight: 600;
        font-size: var(--hn-text-sm);
        color: var(--hn-color-text-muted);
        flex-shrink: 0;
        margin-inline-end: var(--hn-space-4);
    }
}
```

**Sidebar → off-canvas on mobile:**

```css
/* In components/sidebar.css */
.hn-sidebar {
    width: var(--hn-sidebar-width);
    background: var(--hn-color-bg);
}

@media (max-width: 991.98px) {
    .hn-sidebar {
        position: fixed;
        top: 0;
        inset-inline-start: 0;
        height: 100dvh;
        transform: translateX(-100%);
        transition: transform var(--hn-duration-slow) var(--hn-ease-out);
        z-index: var(--hn-z-overlay);
        box-shadow: var(--hn-shadow-xl);
        overflow-y: auto;
    }
    [dir="rtl"] .hn-sidebar {
        transform: translateX(100%);
    }
    .hn-sidebar.is-open {
        transform: translateX(0);
    }
    .hn-sidebar-overlay {
        position: fixed;
        inset: 0;
        background: rgba(0, 0, 0, 0.5);
        z-index: calc(var(--hn-z-overlay) - 1);
        opacity: 0;
        visibility: hidden;
        transition: opacity var(--hn-duration-slow) var(--hn-ease-default),
                    visibility var(--hn-duration-slow);
    }
    .hn-sidebar-overlay.is-visible {
        opacity: 1;
        visibility: visible;
    }
}
```

---

## 10. Dark Mode

### Strategy: CSS Variable Override

Dark mode works by reassigning CSS custom properties. Because every visual value references a variable, the entire theme switches with a variable swap — no component rewrites.

### Implementation

```css
/* dark-mode.css */

/* === Automatic (follows system preference) === */
@media (prefers-color-scheme: dark) {
    :root:not([data-theme="light"]) {
        /* --- Semantic colors --- */
        --hn-color-text: #e5e7eb;
        --hn-color-text-muted: #9ca3af;
        --hn-color-text-inverse: #111827;
        --hn-color-bg: #0f172a;
        --hn-color-bg-alt: #1e293b;
        --hn-color-bg-elevated: #1e293b;
        --hn-color-border: #334155;
        --hn-color-border-strong: #475569;

        /* --- Neutral scale (inverted) --- */
        --hn-color-gray-50: #0f172a;
        --hn-color-gray-100: #1e293b;
        --hn-color-gray-200: #334155;
        --hn-color-gray-300: #475569;
        --hn-color-gray-400: #64748b;
        --hn-color-gray-500: #94a3b8;
        --hn-color-gray-600: #cbd5e1;
        --hn-color-gray-700: #e2e8f0;
        --hn-color-gray-800: #e2e8f0;
        --hn-color-gray-900: #f1f5f9;
        --hn-color-gray-950: #f8fafc;

        /* --- Brand colors (adjust lightness for dark backgrounds) --- */
        --hn-color-primary: #60a5fa;
        --hn-color-primary-hover: #93bbfd;
        --hn-color-primary-active: #3b82f6;
        --hn-color-primary-light: rgba(59, 130, 246, 0.15);
        --hn-color-primary-rgb: 96, 165, 250;

        --hn-color-secondary: #818cf8;
        --hn-color-secondary-hover: #a5b4fc;
        --hn-color-secondary-active: #6366f1;
        --hn-color-secondary-light: rgba(99, 102, 241, 0.15);

        --hn-color-accent: #fbbf24;
        --hn-color-accent-hover: #fcd34d;
        --hn-color-accent-light: rgba(245, 158, 11, 0.15);

        /* --- Status colors (lighter for dark bg readability) --- */
        --hn-color-success: #34d399;
        --hn-color-success-hover: #6ee7b7;
        --hn-color-success-light: rgba(16, 185, 129, 0.15);

        --hn-color-warning: #fbbf24;
        --hn-color-warning-hover: #fcd34d;
        --hn-color-warning-light: rgba(245, 158, 11, 0.15);

        --hn-color-danger: #f87171;
        --hn-color-danger-hover: #fca5a5;
        --hn-color-danger-light: rgba(239, 68, 68, 0.15);

        --hn-color-info: #60a5fa;
        --hn-color-info-hover: #93bbfd;
        --hn-color-info-light: rgba(59, 130, 246, 0.15);

        /* --- Shadows (stronger for dark backgrounds) --- */
        --hn-shadow-xs: 0 1px 2px rgba(0, 0, 0, 0.2);
        --hn-shadow-sm: 0 1px 3px rgba(0, 0, 0, 0.3), 0 1px 2px rgba(0, 0, 0, 0.2);
        --hn-shadow-md: 0 4px 6px rgba(0, 0, 0, 0.3), 0 2px 4px rgba(0, 0, 0, 0.2);
        --hn-shadow-lg: 0 10px 15px rgba(0, 0, 0, 0.3), 0 4px 6px rgba(0, 0, 0, 0.2);
        --hn-shadow-xl: 0 20px 25px rgba(0, 0, 0, 0.4), 0 8px 10px rgba(0, 0, 0, 0.2);
        --hn-shadow-inner: inset 0 2px 4px rgba(0, 0, 0, 0.2);
        --hn-shadow-focus: 0 0 0 3px rgba(96, 165, 250, 0.4);
    }
}

/* === Manual toggle (explicit user choice) === */
[data-theme="dark"] {
    /* Identical overrides as above — duplicate the block */
    --hn-color-text: #e5e7eb;
    --hn-color-text-muted: #9ca3af;
    --hn-color-text-inverse: #111827;
    --hn-color-bg: #0f172a;
    --hn-color-bg-alt: #1e293b;
    --hn-color-bg-elevated: #1e293b;
    --hn-color-border: #334155;
    --hn-color-border-strong: #475569;
    --hn-color-gray-50: #0f172a;
    --hn-color-gray-100: #1e293b;
    --hn-color-gray-200: #334155;
    --hn-color-gray-300: #475569;
    --hn-color-gray-400: #64748b;
    --hn-color-gray-500: #94a3b8;
    --hn-color-gray-600: #cbd5e1;
    --hn-color-gray-700: #e2e8f0;
    --hn-color-gray-800: #e2e8f0;
    --hn-color-gray-900: #f1f5f9;
    --hn-color-gray-950: #f8fafc;
    --hn-color-primary: #60a5fa;
    --hn-color-primary-hover: #93bbfd;
    --hn-color-primary-active: #3b82f6;
    --hn-color-primary-light: rgba(59, 130, 246, 0.15);
    --hn-color-primary-rgb: 96, 165, 250;
    --hn-color-secondary: #818cf8;
    --hn-color-secondary-hover: #a5b4fc;
    --hn-color-secondary-active: #6366f1;
    --hn-color-secondary-light: rgba(99, 102, 241, 0.15);
    --hn-color-accent: #fbbf24;
    --hn-color-accent-hover: #fcd34d;
    --hn-color-accent-light: rgba(245, 158, 11, 0.15);
    --hn-color-success: #34d399;
    --hn-color-success-hover: #6ee7b7;
    --hn-color-success-light: rgba(16, 185, 129, 0.15);
    --hn-color-warning: #fbbf24;
    --hn-color-warning-hover: #fcd34d;
    --hn-color-warning-light: rgba(245, 158, 11, 0.15);
    --hn-color-danger: #f87171;
    --hn-color-danger-hover: #fca5a5;
    --hn-color-danger-light: rgba(239, 68, 68, 0.15);
    --hn-color-info: #60a5fa;
    --hn-color-info-hover: #93bbfd;
    --hn-color-info-light: rgba(59, 130, 246, 0.15);
    --hn-shadow-xs: 0 1px 2px rgba(0, 0, 0, 0.2);
    --hn-shadow-sm: 0 1px 3px rgba(0, 0, 0, 0.3), 0 1px 2px rgba(0, 0, 0, 0.2);
    --hn-shadow-md: 0 4px 6px rgba(0, 0, 0, 0.3), 0 2px 4px rgba(0, 0, 0, 0.2);
    --hn-shadow-lg: 0 10px 15px rgba(0, 0, 0, 0.3), 0 4px 6px rgba(0, 0, 0, 0.2);
    --hn-shadow-xl: 0 20px 25px rgba(0, 0, 0, 0.4), 0 8px 10px rgba(0, 0, 0, 0.2);
    --hn-shadow-inner: inset 0 2px 4px rgba(0, 0, 0, 0.2);
    --hn-shadow-focus: 0 0 0 3px rgba(96, 165, 250, 0.4);
}
```

### Dark Mode for Images and Illustrations

```css
/* Swap logos */
.hn-logo--light { display: block; }
.hn-logo--dark  { display: none; }

@media (prefers-color-scheme: dark) {
    :root:not([data-theme="light"]) .hn-logo--light { display: none; }
    :root:not([data-theme="light"]) .hn-logo--dark  { display: block; }
}
[data-theme="dark"] .hn-logo--light { display: none; }
[data-theme="dark"] .hn-logo--dark  { display: block; }

/* Dim illustrations/screenshots that assume white backgrounds */
@media (prefers-color-scheme: dark) {
    :root:not([data-theme="light"]) .hn-img--adaptable {
        opacity: 0.85;
        filter: brightness(0.9);
    }
}
[data-theme="dark"] .hn-img--adaptable {
    opacity: 0.85;
    filter: brightness(0.9);
}
```

### Preventing Flash of Wrong Theme

Add this inline in `<head>` before stylesheet:

```html
<script>
    (function() {
        var theme = localStorage.getItem('hn-theme');
        if (theme) document.documentElement.setAttribute('data-theme', theme);
    })();
</script>
```

---

## 11. JavaScript

### Standalone Phase — Vanilla JS

In Phase 1, use vanilla JavaScript. No jQuery dependency yet (jQuery is added in Phase 2 by WHMCS).

```js
'use strict';

(function() {
    // ========================================
    // INITIALIZATION
    // ========================================

    document.addEventListener('DOMContentLoaded', init);

    function init() {
        initMobileNav();
        initDropdowns();
        initModals();
        initTabs();
        initAccordions();
        initTooltips();
        initFormValidation();
        initDarkModeToggle();
        initSidebarToggle();
        initDismissible();
        initPasswordToggle();
    }

    // ========================================
    // MOBILE NAVIGATION
    // ========================================

    function initMobileNav() {
        var toggle = document.querySelector('[data-hn-nav-toggle]');
        var nav = document.querySelector('[data-hn-nav-menu]');
        if (!toggle || !nav) return;

        toggle.addEventListener('click', function() {
            var expanded = this.getAttribute('aria-expanded') === 'true';
            this.setAttribute('aria-expanded', String(!expanded));
            nav.hidden = expanded;
        });
    }

    // ========================================
    // DARK MODE TOGGLE
    // ========================================

    function initDarkModeToggle() {
        var toggle = document.querySelector('[data-hn-theme-toggle]');
        if (!toggle) return;

        toggle.addEventListener('click', function() {
            var html = document.documentElement;
            var current = html.getAttribute('data-theme');
            var next = current === 'dark' ? 'light' : 'dark';
            html.setAttribute('data-theme', next);
            localStorage.setItem('hn-theme', next);
        });
    }

    // ========================================
    // SIDEBAR TOGGLE (Mobile)
    // ========================================

    function initSidebarToggle() {
        var toggle = document.querySelector('[data-hn-sidebar-toggle]');
        var sidebar = document.querySelector('[data-hn-sidebar]');
        var overlay = document.querySelector('[data-hn-sidebar-overlay]');
        if (!toggle || !sidebar) return;

        function openSidebar() {
            sidebar.classList.add('is-open');
            if (overlay) overlay.classList.add('is-visible');
            toggle.setAttribute('aria-expanded', 'true');
            document.body.style.overflow = 'hidden';
            trapFocus(sidebar);
        }

        function closeSidebar() {
            sidebar.classList.remove('is-open');
            if (overlay) overlay.classList.remove('is-visible');
            toggle.setAttribute('aria-expanded', 'false');
            document.body.style.overflow = '';
            toggle.focus();
        }

        toggle.addEventListener('click', openSidebar);
        if (overlay) overlay.addEventListener('click', closeSidebar);

        sidebar.addEventListener('keydown', function(e) {
            if (e.key === 'Escape') closeSidebar();
        });
    }

    // ========================================
    // MODALS
    // ========================================

    function initModals() {
        document.addEventListener('click', function(e) {
            var trigger = e.target.closest('[data-hn-modal-open]');
            if (trigger) {
                var id = trigger.getAttribute('data-hn-modal-open');
                openModal(document.getElementById(id));
                return;
            }
            var close = e.target.closest('[data-hn-modal-close]');
            if (close) {
                closeModal(close.closest('.hn-modal'));
            }
        });
    }

    var activeModal = null;

    function openModal(modal) {
        if (!modal) return;
        activeModal = modal;
        modal.hidden = false;
        modal.setAttribute('aria-hidden', 'false');
        document.body.style.overflow = 'hidden';
        trapFocus(modal.querySelector('.hn-modal__dialog'));

        modal.querySelector('.hn-modal__overlay').addEventListener('click', function() {
            closeModal(modal);
        });
        document.addEventListener('keydown', handleModalEscape);
    }

    function closeModal(modal) {
        if (!modal) return;
        modal.hidden = true;
        modal.setAttribute('aria-hidden', 'true');
        document.body.style.overflow = '';
        document.removeEventListener('keydown', handleModalEscape);
        activeModal = null;
    }

    function handleModalEscape(e) {
        if (e.key === 'Escape' && activeModal) closeModal(activeModal);
    }

    // ========================================
    // TABS
    // ========================================

    function initTabs() {
        document.querySelectorAll('[data-hn-tabs]').forEach(function(tabGroup) {
            var tabs = tabGroup.querySelectorAll('[data-hn-tab]');
            tabs.forEach(function(tab) {
                tab.addEventListener('click', function() {
                    var target = this.getAttribute('data-hn-tab');
                    tabs.forEach(function(t) {
                        t.setAttribute('aria-selected', 'false');
                    });
                    this.setAttribute('aria-selected', 'true');
                    tabGroup.querySelectorAll('[data-hn-tab-panel]').forEach(function(panel) {
                        panel.hidden = panel.getAttribute('data-hn-tab-panel') !== target;
                    });
                });
            });
        });
    }

    // ========================================
    // DISMISSIBLE ALERTS
    // ========================================

    function initDismissible() {
        document.addEventListener('click', function(e) {
            var btn = e.target.closest('[data-hn-dismiss]');
            if (!btn) return;
            var target = btn.closest('.hn-alert') || btn.closest('[data-hn-dismissible]');
            if (target) {
                target.style.opacity = '0';
                target.style.transition = 'opacity var(--hn-duration-base) var(--hn-ease-default)';
                setTimeout(function() { target.remove(); }, 200);
            }
        });
    }

    // ========================================
    // PASSWORD VISIBILITY TOGGLE
    // ========================================

    function initPasswordToggle() {
        document.addEventListener('click', function(e) {
            var btn = e.target.closest('[data-hn-toggle="password-visibility"]');
            if (!btn) return;
            var input = btn.closest('.hn-form__input-group').querySelector('input');
            if (!input) return;
            var isPassword = input.type === 'password';
            input.type = isPassword ? 'text' : 'password';
            btn.setAttribute('aria-label', isPassword ? 'Hide password' : 'Show password');
        });
    }

    // ========================================
    // UTILITIES
    // ========================================

    function debounce(fn, delay) {
        var timer;
        return function() {
            var context = this;
            var args = arguments;
            clearTimeout(timer);
            timer = setTimeout(function() { fn.apply(context, args); }, delay);
        };
    }

    var prefersReducedMotion = window.matchMedia('(prefers-reduced-motion: reduce)');

    function shouldAnimate() {
        return !prefersReducedMotion.matches;
    }

    function trapFocus(element) {
        if (!element) return;
        var focusable = element.querySelectorAll(
            'a[href], button:not([disabled]), textarea, input:not([disabled]), select:not([disabled]), [tabindex]:not([tabindex="-1"])'
        );
        if (focusable.length === 0) return;
        var first = focusable[0];
        var last = focusable[focusable.length - 1];

        element.addEventListener('keydown', function(e) {
            if (e.key !== 'Tab') return;
            if (e.shiftKey) {
                if (document.activeElement === first) { last.focus(); e.preventDefault(); }
            } else {
                if (document.activeElement === last) { first.focus(); e.preventDefault(); }
            }
        });

        first.focus();
    }

    // Debounced resize handler
    window.addEventListener('resize', debounce(function() {
        // Close mobile sidebar on resize to desktop
        if (window.innerWidth >= 992) {
            var sidebar = document.querySelector('[data-hn-sidebar]');
            if (sidebar && sidebar.classList.contains('is-open')) {
                sidebar.classList.remove('is-open');
                var overlay = document.querySelector('[data-hn-sidebar-overlay]');
                if (overlay) overlay.classList.remove('is-visible');
                document.body.style.overflow = '';
            }
        }
    }, 250));

})();
```

### Rules

- Wrap everything in an IIFE — no global scope pollution
- Use `var` instead of `let`/`const` — ensures compatibility with older tooling and no issues when concatenated (Phase 2: jQuery 1.12.4 environment)
- Use `data-hn-*` attributes for JS hooks (not classes, not IDs):
  - `data-hn-toggle="dropdown"`
  - `data-hn-modal-open="confirm-delete"`
  - `data-hn-tab-target="billing"`
- Debounce all `scroll` and `resize` handlers (250ms minimum)
- Respect `prefers-reduced-motion` — disable animations/transitions when active
- No `console.log` in production
- Use event delegation for repeating elements (table rows, card lists):

```js
document.querySelector('.hn-table').addEventListener('click', function(e) {
    var actionBtn = e.target.closest('[data-hn-action]');
    if (!actionBtn) return;
    // Handle action
});
```

### Phase 2 Consideration

Write JS so that converting to jQuery later is trivial:
- `document.querySelector` → `$()`
- `addEventListener` → `.on()`
- `data-hn-*` attributes work identically in both
- Avoid arrow functions (keep `function()` syntax) — matches jQuery callback style
- Don't use features jQuery 1.12 can't coexist with (IntersectionObserver is fine — it won't need jQuery conversion)

---

## 12. Performance

### Targets

| Metric | Target |
|--------|--------|
| Total CSS (unminified) | < 120KB |
| Total CSS (minified) | < 60KB |
| Total JS (minified) | < 30KB |
| Custom fonts | < 150KB |
| Total page weight (with images) | < 1MB |
| First Contentful Paint | < 1.5s |

### Images

- **WebP** with JPG/PNG fallback:
```html
<picture>
    <source srcset="assets/images/hero.webp" type="image/webp">
    <img src="assets/images/hero.jpg" alt="Description" loading="lazy" width="1200" height="600">
</picture>
```
- Always include `width` and `height` attributes (prevents layout shift)
- `loading="lazy"` on everything below the fold
- `srcset` for responsive images:
```html
<img
    srcset="assets/images/card-400.webp 400w, assets/images/card-800.webp 800w"
    sizes="(max-width: 768px) 100vw, 400px"
    src="assets/images/card-400.jpg"
    alt="Description"
    loading="lazy"
    width="400"
    height="300"
>
```
- SVG for logos, icons, illustrations
- Optimize everything before shipping (squoosh.app, TinyPNG)

### Fonts

- Self-host all fonts (no external CDNs — GDPR matters for hosting companies)
- `woff2` format only (98%+ browser support)
- Maximum 4 weights: regular (400), medium (500), semibold (600), bold (700)
- Subset to Latin + Latin Extended if no other languages needed
- `font-display: swap` on every `@font-face`
- Preload the 1-2 most critical weights

```css
/* In base.css */
@font-face {
    font-family: 'Inter';
    src: url('../fonts/inter-regular.woff2') format('woff2');
    font-weight: 400;
    font-style: normal;
    font-display: swap;
}
@font-face {
    font-family: 'Inter';
    src: url('../fonts/inter-medium.woff2') format('woff2');
    font-weight: 500;
    font-style: normal;
    font-display: swap;
}
@font-face {
    font-family: 'Inter';
    src: url('../fonts/inter-semibold.woff2') format('woff2');
    font-weight: 600;
    font-style: normal;
    font-display: swap;
}
@font-face {
    font-family: 'Inter';
    src: url('../fonts/inter-bold.woff2') format('woff2');
    font-weight: 700;
    font-style: normal;
    font-display: swap;
}
```

### CSS

- No unused CSS — if converting from Tailwind, run PurgeCSS
- Build produces single `dist/css/main.min.css` (see Section 3)
- Ship both source files and minified version

### No External Dependencies

The standalone markup must not load anything from CDNs:
- No Google Fonts CDN
- No Tailwind CDN
- No Bootstrap CDN
- No Font Awesome CDN
- No jQuery CDN

Everything is self-contained. Buyers drop this into their server — it works offline.

---

## 13. Design Polish

### Spacing Consistency

Every margin, padding, and gap uses the spacing scale. No exceptions:

```css
/* GOOD */
padding: var(--hn-space-4) var(--hn-space-6);
gap: var(--hn-space-4);
margin-bottom: var(--hn-space-8);

/* BAD */
padding: 15px 23px;
gap: 18px;
margin-bottom: 35px;
```

### Typography

```css
body {
    font-family: var(--hn-font-body);
    font-size: var(--hn-text-base);
    line-height: var(--hn-leading-normal);
    color: var(--hn-color-text);
}

h1, h2, h3, h4 {
    font-family: var(--hn-font-heading);
    line-height: var(--hn-leading-tight);
    color: var(--hn-color-gray-900);
    letter-spacing: var(--hn-tracking-tight);
}

/* Tabular numbers for data (invoices, pricing, statistics) */
.hn-data-value {
    font-variant-numeric: tabular-nums;
}

/* Content max-width for readability */
.hn-prose {
    max-width: 65ch;
}

/* Small caps for labels */
.hn-label {
    font-size: var(--hn-text-xs);
    font-weight: 600;
    letter-spacing: var(--hn-tracking-wide);
    text-transform: uppercase;
    color: var(--hn-color-text-muted);
}
```

### Interaction States

**Every** interactive element must have these visual states:

| State | Trigger | Visual Change |
|-------|---------|---------------|
| Default | — | Base appearance |
| Hover | Mouse over | Color shift, subtle lift or shadow |
| Focus | Tab key | Visible focus ring (`--hn-shadow-focus`) |
| Active | Mouse down | Slight press-in, darker color |
| Disabled | `disabled` attr | 50% opacity, no pointer events |
| Loading | `.is-loading` class | Spinner replaces content |

### Status Indicators

Aligned with WHMCS status system (for Phase 2):

```css
.hn-status { font-weight: 600; font-size: var(--hn-text-sm); }

/* Service statuses */
.hn-status--active     { color: var(--hn-color-success); }
.hn-status--pending    { color: var(--hn-color-warning); }
.hn-status--suspended  { color: var(--hn-color-danger); }
.hn-status--terminated { color: var(--hn-color-danger); }
.hn-status--cancelled  { color: var(--hn-color-text-muted); }

/* Invoice statuses */
.hn-status--paid       { color: var(--hn-color-success); }
.hn-status--unpaid     { color: var(--hn-color-danger); }
.hn-status--overdue    { color: var(--hn-color-danger); }
.hn-status--refunded   { color: var(--hn-color-info); }

/* Ticket statuses */
.hn-status--open        { color: var(--hn-color-info); }
.hn-status--answered    { color: var(--hn-color-success); }
.hn-status--in-progress { color: var(--hn-color-warning); }
.hn-status--closed      { color: var(--hn-color-text-muted); }

/* Badge variant (with background) */
.hn-status--badge {
    display: inline-flex;
    align-items: center;
    padding: var(--hn-space-1) var(--hn-space-3);
    border-radius: var(--hn-radius-full);
    font-size: var(--hn-text-xs);
}
.hn-status--badge.hn-status--active {
    background: var(--hn-color-success-light);
    color: var(--hn-color-success);
}
/* ... same pattern for each status ... */

/* Dot variant (small dot + text) */
.hn-status--dot::before {
    content: '';
    display: inline-block;
    width: 0.5em;
    height: 0.5em;
    border-radius: var(--hn-radius-full);
    background: currentColor;
    margin-inline-end: var(--hn-space-2);
}
```

### Empty, Loading, and Error States

Style these for every list/table page:

```html
<!-- Empty state -->
<div class="hn-empty">
    <img src="assets/images/empty-states/no-invoices.svg" class="hn-empty__image" alt="" width="200" height="160">
    <h3 class="hn-empty__title">No invoices yet</h3>
    <p class="hn-empty__text">Your invoices will appear here once you place an order.</p>
    <a href="cart.html" class="hn-btn hn-btn--primary">Browse Products</a>
</div>

<!-- Loading state -->
<div class="hn-loading" aria-live="polite" aria-label="Loading">
    <div class="hn-loading__spinner" aria-hidden="true"></div>
    <span class="hn-loading__text">Loading services...</span>
</div>

<!-- Error state -->
<div class="hn-empty hn-empty--error" role="alert">
    <svg class="hn-icon hn-icon--xl hn-empty__icon" aria-hidden="true">
        <use href="assets/icons/icons.svg#alert-circle"></use>
    </svg>
    <h3 class="hn-empty__title">Something went wrong</h3>
    <p class="hn-empty__text">We couldn't load your data. Please try again.</p>
    <button class="hn-btn hn-btn--outline" data-hn-retry>Try Again</button>
</div>
```

### Transitions

- 100-200ms for micro-interactions (hover, focus, toggle)
- 200-300ms for UI state changes (dropdown open, tab switch)
- 300-500ms for larger reveals (modal, sidebar slide)
- Never exceed 500ms

```css
@media (prefers-reduced-motion: reduce) {
    *,
    *::before,
    *::after {
        animation-duration: 0.01ms !important;
        animation-iteration-count: 1 !important;
        transition-duration: 0.01ms !important;
        scroll-behavior: auto !important;
    }
}

@keyframes hn-spin {
    to { transform: rotate(360deg); }
}

@keyframes hn-fade-in {
    from { opacity: 0; }
    to { opacity: 1; }
}
```

---

## 14. Content & Sample Data

### Use Realistic Content

Every page must contain realistic content that a hosting company buyer can relate to. No Lorem Ipsum.

### Content Guidelines by Page

**Homepage:**
- Company name: "Hostnodes" (or "Your Company" in customizable spots)
- Pricing: use realistic hosting prices ($4.99/mo, $12.99/mo, $29.99/mo)
- Features: real hosting features (SSD storage, unlimited bandwidth, 99.9% uptime)
- Domain search: show example TLDs with realistic prices (.com $12.99, .net $11.99)

**Client Dashboard:**
- 3-5 services with realistic names: "Business Hosting - example.com", "VPS Standard - 4GB"
- 2-3 invoices with realistic line items and amounts
- 1-2 open support tickets with realistic subjects
- Dates: use relative-looking dates (not years in the past)

**Services List:**
- 5-8 rows showing mix of Active, Pending, Suspended statuses
- Realistic product names: "Shared Hosting - Starter", "SSL Certificate - Wildcard"
- Pricing: monthly and annual amounts

**Invoices:**
- 8-12 rows with mix of Paid, Unpaid, Overdue
- Realistic invoice numbers: #INV-20260401
- Amounts: $4.99 to $249.99 range
- Include one with multiple line items for the detail view

**Support Tickets:**
- 5-8 tickets with realistic subjects: "Cannot access cPanel", "DNS propagation delay", "SSL not working on subdomain"
- Mix of Open, Answered, Closed, In Progress
- Thread view: 3-5 messages with realistic back-and-forth

**Knowledgebase:**
- Categories: Getting Started, Billing, Email, Domains, Hosting, Security
- Article titles: "How to change your DNS nameservers", "Setting up email forwarding"
- Article body: 2-3 paragraphs with headings, a code block, a screenshot placeholder

### Data Volume Rules

| Element | Minimum Rows | Why |
|---------|-------------|-----|
| Tables | 5-8 rows | Tests pagination, scrolling, and visual rhythm |
| Ticket thread | 3-5 messages | Tests alternating styles and long content |
| KB categories | 4-6 categories | Tests grid layout |
| KB articles per category | 3-5 | Tests list styling |
| Cart items | 2-3 products | Tests totals, multi-row cart |
| Dashboard widgets | 3-5 items each | Tests widget density |

### Edge Cases to Include

On at least one page, include:
- A very long service/product name (60+ characters) to test truncation
- A zero-amount invoice ($0.00) to test display
- An empty table (0 rows) to test empty state
- A ticket with a very long message to test content overflow
- A status badge for every defined status (so all are visually tested)

### Placeholder Images

- Use geometric SVG illustrations for empty states (not stock photos)
- Logo: simple SVG that works at small sizes
- Screenshots: use browser frame mockups with gray content blocks, not real screenshots
- Avatars: use initials-based circles, not face photos

---

## 15. RTL Readiness

Full RTL implementation is not required in Phase 1. However, write CSS so RTL can be added by overriding the `dir` attribute and minimal CSS changes.

### Rules

**Use logical properties instead of physical ones:**

```css
/* GOOD — RTL-ready */
margin-inline-start: var(--hn-space-4);
padding-inline: var(--hn-space-6);
border-inline-end: 1px solid var(--hn-color-border);
inset-inline-start: 0;
text-align: start;

/* BAD — breaks in RTL */
margin-left: var(--hn-space-4);
padding-left: var(--hn-space-6);
padding-right: var(--hn-space-6);
border-right: 1px solid var(--hn-color-border);
left: 0;
text-align: left;
```

**Logical property cheat sheet:**

| Physical | Logical |
|----------|---------|
| `margin-left` | `margin-inline-start` |
| `margin-right` | `margin-inline-end` |
| `padding-left/right` | `padding-inline` or `padding-inline-start/end` |
| `left` | `inset-inline-start` |
| `right` | `inset-inline-end` |
| `top` | `inset-block-start` |
| `bottom` | `inset-block-end` |
| `border-left` | `border-inline-start` |
| `text-align: left` | `text-align: start` |
| `text-align: right` | `text-align: end` |
| `float: left` | Avoid — use flexbox/grid |

**Exceptions where physical properties are OK:**
- `transform: translateX()` — use `[dir="rtl"]` selector to flip
- Box shadows and text shadows — direction is visual, not logical
- Background positions — usually visual

**Flexbox and Grid are naturally RTL-aware.** `justify-content: flex-start` flips automatically when `dir="rtl"` is set.

### Phase 2 Note

WHMCS serves international hosting companies. RTL customers will expect Arabic/Hebrew support. Using logical properties now means Phase 2 RTL support is mostly just adding a `dir="rtl"` attribute and a small CSS file for transform/shadow exceptions.

---

## 16. Cross-Browser Testing

### Required Browsers

| Browser | Version | Priority |
|---------|---------|----------|
| Chrome | Latest 2 | High |
| Firefox | Latest 2 | High |
| Safari | Latest 2 | High |
| Edge | Latest 2 | High |
| iOS Safari | Latest 2 | High |
| Chrome Android | Latest 2 | Medium |

### Common Issues

- **iOS Safari:** `100vh` includes URL bar → use `100dvh` with `100vh` fallback. Font-size < 16px on inputs triggers auto-zoom → keep all inputs at 16px minimum.
- **Safari:** Check `gap` in flexbox (older Safari versions), `backdrop-filter` needs `-webkit-` prefix.
- **Firefox:** Table column width rendering differences. `text-wrap: balance` support.

### CSS Fallbacks

```css
/* dvh fallback */
.hn-modal__overlay {
    height: 100vh;
    height: 100dvh;
}

/* gap fallback for older Safari flex containers */
.hn-flex-list {
    display: flex;
    flex-wrap: wrap;
    margin: calc(var(--hn-space-2) * -1);
}
.hn-flex-list > * {
    margin: var(--hn-space-2);
}
@supports (gap: 1rem) {
    .hn-flex-list {
        gap: var(--hn-space-4);
        margin: 0;
    }
    .hn-flex-list > * {
        margin: 0;
    }
}

/* text-wrap fallback */
h1, h2, h3 {
    text-wrap: balance;
}
@supports not (text-wrap: balance) {
    h1, h2, h3 {
        overflow-wrap: break-word;
    }
}
```

---

## 17. Page Inventory

Every page in this list must exist as a standalone HTML file, fully styled with realistic content:

### Public Pages
- [ ] `index.html` — Homepage (hero, domain search, pricing, features, testimonials)
- [ ] `login.html` — Login form
- [ ] `register.html` — Registration form
- [ ] `password-reset.html` — Password reset request
- [ ] `announcements.html` — Announcements list
- [ ] `announcement-view.html` — Single announcement
- [ ] `knowledgebase.html` — KB categories + search
- [ ] `knowledgebase-article.html` — Single KB article
- [ ] `contact.html` — Contact form / public ticket submission
- [ ] `domain-search.html` — Domain availability search + results
- [ ] `404.html` — Not found
- [ ] `500.html` — Server error
- [ ] `maintenance.html` — Maintenance mode

### Client Area
- [ ] `client-dashboard.html` — Dashboard with service summary, recent invoices, tickets
- [ ] `client-services.html` — Services/products list table
- [ ] `client-service-detail.html` — Single service management
- [ ] `client-domains.html` — Domains list table
- [ ] `client-domain-pricing.html` — Domain pricing table (TLD prices)
- [ ] `client-invoices.html` — Invoices list table
- [ ] `client-invoice-view.html` — Single invoice (viewable + printable)
- [ ] `client-quotes.html` — Quotes list
- [ ] `client-quote-view.html` — Single quote
- [ ] `client-tickets.html` — Support tickets list
- [ ] `client-ticket-view.html` — Ticket thread (messages, replies, status)
- [ ] `client-ticket-open.html` — Open new ticket form
- [ ] `client-account.html` — Profile / account details
- [ ] `client-security.html` — Password change, 2FA setup
- [ ] `client-contacts.html` — Sub-accounts / contacts
- [ ] `client-emails.html` — Email history
- [ ] `client-payment-methods.html` — Saved payment methods
- [ ] `client-affiliates.html` — Affiliate dashboard
- [ ] `client-downloads.html` — Downloads / file manager
- [ ] `client-upgrade.html` — Service upgrade/downgrade

### Cart & Checkout
- [ ] `cart.html` — Cart summary with products
- [ ] `checkout.html` — Checkout form (billing details, payment selection)
- [ ] `order-confirmation.html` — Order complete / thank you

### Utility
- [ ] `email-verification.html` — Email verification prompt

**Total: 38 pages**

---

## 18. Pre-Launch QA Checklist

### Code Quality
- [ ] HTML validates (validator.w3.org) — zero errors on every page
- [ ] CSS validates (jigsaw.w3.org/css-validator)
- [ ] No JavaScript console errors or warnings
- [ ] All links work across pages (no broken hrefs)
- [ ] All images load (no 404s)
- [ ] No inline styles anywhere (everything in external CSS)
- [ ] No `<style>` blocks in any HTML file
- [ ] No `!important` in any CSS file
- [ ] Every CSS value references a custom property (no hardcoded colors/spacing/sizes)
- [ ] BEM naming consistent, all classes prefixed with `hn-`
- [ ] All `data-hn-*` attributes are used for JS hooks (no class-based JS targeting)
- [ ] Build runs successfully (`npm run build` produces `dist/`)

### Accessibility
- [ ] axe DevTools: zero violations on every page
- [ ] WAVE: zero errors on every page
- [ ] Keyboard navigation works (Tab through every page)
- [ ] Skip-to-content link on every page
- [ ] Screen reader tested on: login, dashboard, ticket view, invoice
- [ ] Color contrast passes on all text (4.5:1 body, 3:1 large)
- [ ] Focus states visible on every interactive element
- [ ] All form inputs have `<label>` elements
- [ ] All icon-only buttons have `aria-label`
- [ ] All SVG icons inside buttons have `aria-hidden="true"`
- [ ] All tables have `scope` attributes on header cells

### Performance
- [ ] Lighthouse: Performance 90+, Accessibility 100, Best Practices 100, SEO 100
- [ ] Total CSS < 60KB minified
- [ ] Total JS < 30KB minified
- [ ] All images optimized (WebP + fallback, width/height attributes)
- [ ] Fonts: woff2 only, max 4 weights, font-display: swap, preloaded
- [ ] No external CDN dependencies
- [ ] `dist/css/main.min.css` is a single file (no @import chains)

### Responsive
- [ ] Every page tested at: 320px, 375px, 768px, 1024px, 1440px
- [ ] All tables scroll or stack on mobile
- [ ] Sidebar collapses to off-canvas on mobile
- [ ] Touch targets minimum 44x44px
- [ ] No horizontal overflow at any viewport
- [ ] Input font-size >= 16px (prevents iOS zoom)

### Cross-Browser
- [ ] Chrome, Firefox, Safari, Edge (latest 2)
- [ ] iOS Safari, Chrome Android
- [ ] No layout shifts or broken elements

### Dark Mode
- [ ] All pages readable in dark mode
- [ ] All status colors maintain contrast against dark backgrounds
- [ ] No white flashes on page load (inline theme script works)
- [ ] Logo swaps correctly between light/dark variants
- [ ] Toggle works (manual) + system preference works (automatic)
- [ ] Illustrations/images don't clash with dark backgrounds

### Content
- [ ] Every page has realistic hosting industry content (no Lorem Ipsum)
- [ ] Tables have 5+ rows of realistic data
- [ ] At least one edge case per page type (long name, empty state, zero amount)
- [ ] All empty states are styled (not just blank space)
- [ ] All loading states are styled
- [ ] All error states are styled

### Completeness
- [ ] Every page in the inventory (Section 17) exists and is styled
- [ ] Every interactive element has: hover, focus, active, disabled states
- [ ] Print stylesheet works for invoice and quote pages
- [ ] Works with JavaScript disabled (content visible, forms have action attributes)
- [ ] README.md is complete
- [ ] CHANGELOG.md exists with initial entry
- [ ] LICENSE.md exists

---

## 19. Versioning & Changelog

### Semantic Versioning

Use semver: `MAJOR.MINOR.PATCH`

| Change Type | Bump | Example |
|-------------|------|---------|
| Breaking layout/structure change | MAJOR | 1.0.0 → 2.0.0 |
| New page, component, or feature | MINOR | 1.0.0 → 1.1.0 |
| Bug fix, typo, spacing adjustment | PATCH | 1.0.0 → 1.0.1 |

### CHANGELOG.md Format

```markdown
# Changelog

All notable changes to the Hostnodes Theme are documented in this file.

Format: [Semantic Versioning](https://semver.org/)

## [1.0.0] - 2026-04-13

### Added
- Initial release with 38 standalone HTML pages
- Complete CSS design system with 90+ custom properties
- Dark mode (automatic + manual toggle)
- Responsive design (mobile-first, 5 breakpoints)
- SVG icon sprite system (40+ icons)
- Print stylesheet for invoices and quotes
- Full WCAG 2.1 AA accessibility compliance
- RTL-ready CSS (logical properties throughout)

### Components
- Buttons (6 variants, 3 sizes, loading state)
- Cards (bordered, elevated, flat, interactive)
- Tables (striped, hoverable, compact, mobile-stack)
- Forms (validation, hints, input groups)
- Modals (3 sizes, focus trapping)
- Alerts (4 types, dismissible)
- Badges, Tabs, Pagination, Breadcrumb
- Status indicators (12 statuses, badge + dot variants)
- Empty states, loading spinners, error states
```

### Tagging

When cutting a release:

```bash
git tag -a v1.0.0 -m "v1.0.0 — Initial release"
git push origin v1.0.0
```

---

## 20. Phase 2 Readiness Checklist

Before starting WHMCS `.tpl` conversion, verify:

### Naming & Structure
- [ ] All classes prefixed with `hn-` — zero collision risk with Bootstrap 4.5.3
- [ ] Breakpoints match Bootstrap 4: 576, 768, 992, 1200
- [ ] `data-hn-*` attribute convention used for all JS hooks
- [ ] No ES6+ syntax in JS (uses `var`, `function()` — compatible with jQuery 1.12.4 environment)

### Theming
- [ ] CSS custom properties are the sole source of visual values — buyers can retheme by editing `variables.css` alone
- [ ] Dark mode works via variable override — no component-level dark mode CSS

### Components
- [ ] Status classes match WHMCS states: active, pending, suspended, terminated, cancelled, paid, unpaid, overdue, refunded, open, answered, in-progress, closed
- [ ] Data tables handle 50+ rows (pagination pattern exists)
- [ ] Form markup is compatible with WHMCS's structure (label + input + error)
- [ ] Modal focus trapping works (WHMCS default modals lack this)

### Content
- [ ] All user-facing text is in HTML, not in CSS or JS — makes `{lang key='...'}` extraction trivial
- [ ] No text is embedded in images (except logo)
- [ ] Date formats are consistent and extractable

### Layout
- [ ] Sidebar pattern is extractable into a standalone `sidebar.tpl` partial
- [ ] Header and footer are clearly separated as includable fragments
- [ ] Layout supports WHMCS admin bar (extra ~40px at top when admin is logged in)

### Icons
- [ ] SVG sprite system can coexist with Font Awesome 5.10.1 (no class name conflicts)
- [ ] Decision documented: which icons use SVG sprite vs Font Awesome in Phase 2

### RTL
- [ ] Logical properties used throughout — `dir="rtl"` on `<html>` produces usable (if imperfect) RTL layout
- [ ] Known RTL exceptions documented (transforms, shadows, etc.)

---

## Quick Reference: Do / Don't

| Do | Don't |
|----|-------|
| Prefix all classes with `hn-` | Use generic unprefixed classes |
| Use CSS custom properties for every value | Hardcode colors, sizes, spacing |
| Use BEM naming consistently | Mix naming conventions |
| Use semantic HTML (`section`, `article`, `nav`) | Div soup |
| Use `data-hn-*` for JS hooks | Bind JS to CSS classes or IDs |
| Use `rem` for spacing and typography | Use `px` for spacing |
| Use logical properties (`inline-start`) | Use physical (`left`/`right`) |
| Use `clamp()` for fluid sizing | Write 5+ breakpoint overrides per element |
| Put responsive rules inside component files | Separate responsive.css for everything |
| Use SVG sprite for icons | Inline SVGs in every HTML file |
| Include all interaction states | Style only the default state |
| Self-host all assets | Use CDN links |
| Provide empty/loading/error states | Only style the happy path |
| Use realistic hosting content | Use Lorem Ipsum |
| Match Bootstrap 4 breakpoints | Invent custom breakpoints |
| Keep status names aligned with WHMCS | Use custom status terminology |
| Ship source + minified files | Ship only minified |
| Use `var` and `function()` in JS | Use `const`/`let`/arrow functions |
| Build to dist/ via PostCSS | Ship @import chains to production |
| Version with semver + changelog | No version tracking |
