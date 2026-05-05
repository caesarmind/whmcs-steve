# WHMCS Apple Theme — Design Style Guide

> A comprehensive design system replicating Apple.com standards for hosting/SaaS products.
> Use this as the source of truth when creating new components or pages.

---

## Table of Contents

1. [Design Philosophy](#1-design-philosophy)
2. [Color System](#2-color-system)
3. [Typography](#3-typography)
4. [Spacing & Layout](#4-spacing--layout)
5. [Border Radius](#5-border-radius)
6. [Shadows & Elevation](#6-shadows--elevation)
7. [Buttons & CTAs](#7-buttons--ctas)
8. [Cards](#8-cards)
9. [Forms & Inputs](#9-forms--inputs)
10. [Iconography](#10-iconography)
11. [Animation & Motion](#11-animation--motion)
12. [Responsive Breakpoints](#12-responsive-breakpoints)
13. [Dark Mode](#13-dark-mode)
14. [Section Patterns](#14-section-patterns)
15. [Component Library](#15-component-library)
16. [Apple-Specific Patterns](#16-apple-specific-patterns)
17. [Do's and Don'ts](#17-dos-and-donts)

---

## 1. Design Philosophy

Apple's design language rests on three core principles. Apply these to every new component:

### Clarity
- **Content is paramount.** UI helps users focus on the task; it should never compete for attention.
- Use generous whitespace — let elements breathe.
- One primary action per view. Secondary actions are subordinate (text links, outline buttons).
- Strong typographic hierarchy makes scanning effortless.

### Deference
- **The interface defers to the content.** No decorative elements that don't serve a function.
- Avoid drop shadows, gradients, and textures unless they convey meaning (depth, state).
- Translucency and blur create context without obscuring.

### Depth
- Use layers to convey hierarchy: floating cards, modals, dropdowns.
- Subtle motion reinforces relationships between actions and outcomes.
- Z-axis matters — closer = more important, farther = supporting.

### Brand Voice
- **Confident, not loud.** Big typography, restrained color, large whitespace.
- **Human, not corporate.** "Get started" not "Initiate provisioning."
- **Specific, not vague.** "$10.17/mo" not "Affordable pricing."
- One claim, one supporting line. Never paragraphs of marketing copy.

---

## 2. Color System

### Palette (Light Mode)

| Token | Value | Usage |
|-------|-------|-------|
| `--color-bg` | `#fbfbfd` | Page background (just off-white, not pure) |
| `--color-surface` | `#ffffff` | Cards, panels, modals |
| `--color-surface-secondary` | `#f5f5f7` | Subtle backgrounds (sections, inputs, hover states) |
| `--color-surface-tertiary` | `#fafafa` | Innermost surfaces (nested cards) |
| `--color-border` | `#e8e8ed` | Default borders |
| `--color-border-light` | `#f0f0f5` | Subtle dividers |

### Text Colors

| Token | Value | Usage |
|-------|-------|-------|
| `--color-text-primary` | `#1d1d1f` | Headings, body, important text |
| `--color-text-secondary` | `#6e6e73` | Subtitles, descriptions |
| `--color-text-tertiary` | `#86868b` | Captions, metadata |
| `--color-text-quaternary` | `#aeaeb2` | Disabled, placeholder |

### Accent & System

| Token | Value | Usage |
|-------|-------|-------|
| `--color-accent` | `#0071e3` | Primary brand blue (Apple's signature) |
| `--color-accent-hover` | `#0077ED` | Hover state for blue elements |
| `--color-accent-light` | `rgba(0, 113, 227, 0.08)` | Tinted backgrounds for accent |
| `--color-link` | `#0066cc` | Inline links (slightly darker than accent) |

### Semantic Status

| Status | Color | Background | Text |
|--------|-------|-----------|------|
| Success / Active | `#30d158` (green) | `rgba(48, 209, 88, 0.10)` | `#248a3d` |
| Warning / Pending | `#ff9f0a` (orange) | `rgba(255, 159, 10, 0.10)` | `#c27400` |
| Error / Danger | `#ff3b30` (red) | `rgba(255, 59, 48, 0.10)` | `#d70015` |
| Info | `#0071e3` (blue) | `rgba(0, 113, 227, 0.08)` | `#0071e3` |
| Neutral | `#8e8e93` (gray) | `rgba(142, 142, 147, 0.12)` | `#6e6e73` |

### Decorative Tile Colors

For product showcases, use these full-color backgrounds (from `.hp-tile-*`):

| Tile | Background | Foreground |
|------|-----------|-----------|
| Light | `#fbfbfd` | `#1d1d1f` |
| Dark | `#1d1d1f` | `#f5f5f7` |
| Cream | `#faf7f2` | `#1d1d1f` |
| Sky | `linear-gradient(180deg, #e8f2fb 0%, #d4e8f7 100%)` | `#1d1d1f` |
| Plum | `#1a1735` | `#f5f5f7` |
| Graphite | `#2a2a2c` | `#f5f5f7` |

### Color Rules

✅ **Do**
- Use `--color-bg` (off-white) instead of `#fff` for the page background — it gives subtle warmth.
- Use semantic colors only for their meaning (green = success, red = error). Don't tint a button red just for emphasis.
- Use the accent blue sparingly. One blue CTA per section, not three.

❌ **Don't**
- Don't introduce new colors. Stick to the palette. If you need something new, add it as a CSS variable first.
- Don't use pure black `#000` for text — use `#1d1d1f`.
- Don't use rainbow gradients. Apple's gradients are monochromatic (light variant of one hue).

---

## 3. Typography

### Font Stack

```css
--font-family: -apple-system, BlinkMacSystemFont, 'SF Pro Display', 'SF Pro Text', 'Helvetica Neue', Helvetica, Arial, sans-serif;
--font-mono: 'SF Mono', SFMono-Regular, ui-monospace, Menlo, monospace;
```

Always use the system font stack. SF Pro on Apple devices, fallback gracefully on others.

### Type Scale

Apple uses bold, confident typography. Headlines should be larger than you think.

| Use Case | Size | Weight | Letter-Spacing | Line-Height |
|----------|------|--------|---------------|-------------|
| **Hero Display** (h1) | 64-80px | 600 | -0.03em | 1.05 |
| **Section Title** (h2) | 48-56px | 600 | -0.025em | 1.08 |
| **Subsection** (h3) | 28-40px | 600 | -0.02em | 1.1 |
| **Card Title** (h4) | 17-24px | 600 | -0.01em | 1.2 |
| **Eyebrow / Tag** | 12-14px | 600 | 0.02em (uppercase) | 1.2 |
| **Lead Paragraph** | 21-28px | 400 | -0.015em | 1.35 |
| **Body** | 15-17px | 400 | normal | 1.5 |
| **Small / Caption** | 12-13px | 400 | normal | 1.4 |
| **Button Label** | 14-15px | 500 | normal | 1 |

### Typography Rules

✅ **Do**
- Use **negative letter-spacing** on large text (anything ≥ 24px). Apple's headlines feel tight, not loose.
- Use weight **600** for headings, **500** for medium emphasis (buttons, labels), **400** for body.
- Use eyebrows (small uppercase labels) above headings to establish category/section.

❌ **Don't**
- Don't use weight 700 (too heavy for the system font's display variant).
- Don't use italic for emphasis — use weight or color instead.
- Don't underline anything except inline links on hover.
- Don't use ALL CAPS for body text — only eyebrows and tags.

### Heading Hierarchy Example

```html
<div class="hp-eyebrow">CLOUD HOSTING</div>          <!-- 14px / 600 / uppercase / accent -->
<h1>Engineered for speed.</h1>                       <!-- 56px / 600 / -0.03em -->
<p class="hp-subhead">NVMe storage, global CDN, ...  <!-- 21px / 400 / muted -->
```

---

## 4. Spacing & Layout

### Container Widths

| Context | Max Width |
|---------|-----------|
| Hero sections (centered text) | 1024px |
| Body content (most sections) | 1024px |
| Wide layouts (rare) | 1200px |
| Reading content (auth, articles) | 560px |
| FAQ accordion | 720px |

### Section Padding (Vertical)

| Density | Padding |
|---------|---------|
| Tight section | 48-60px |
| Standard section | 80px |
| Spacious / Hero | 100-120px |
| Final CTA | 110-120px |

### Horizontal Padding

Always **22px** on the outer container (ensures comfortable reading on tablet, breathing room on desktop).

### Spacing Scale

Use these values for gaps, margins, padding inside components:

```
4px   - Micro (icon-text gap)
8px   - Tight (between related items)
12px  - Small (compact lists)
16px  - Default (between elements)
20px  - Comfortable
24px  - Loose (between groups)
32px  - Section spacing within block
40px  - Between major elements
48px  - Between distinct blocks
56px  - Generous breathing room
80px  - Section vertical padding
```

### Grid Patterns

```css
/* Standard 3-column grid */
display: grid; grid-template-columns: repeat(3, 1fr); gap: 20px;

/* 2-column with gap */
display: grid; grid-template-columns: 1fr 1fr; gap: 60px;

/* Bento (mixed sizes) */
display: grid; grid-template-columns: repeat(3, 1fr); gap: 16px;
.span-2 { grid-column: span 2; }

/* Auto-fit responsive */
display: grid; grid-template-columns: repeat(auto-fill, minmax(260px, 1fr));
```

---

## 5. Border Radius

Apple uses consistent rounding scales. Match shape to size:

| Token | Value | Use |
|-------|-------|-----|
| `--radius-sm` | `8px` | Small buttons, badges, tiny cards |
| `--radius-md` | `12px` | Default cards, inputs |
| `--radius-lg` | `12px` | Large cards (alias of md by default) |
| (custom) | `14-18px` | Feature cards, large content blocks |
| (custom) | `20-24px` | Hero cards, section wrappers |
| `--radius-pill` | `980px` | Buttons, pills, tags (becomes pill-shaped) |
| (custom) | `50%` | Avatars, dots, circular icons |

### Rules

- **Smaller elements get smaller radii.** A 32px button uses 980px (pill), a 200px card uses 18px.
- **Pills (980px)** are the signature Apple button shape. Use for primary CTAs and tags.
- **Never use 0 radius** unless intentionally creating a sharp/industrial feel.
- **Match radii within a section.** Don't mix 12px cards with 18px cards in the same view.

---

## 6. Shadows & Elevation

Apple uses **very subtle** shadows. Avoid harsh drop shadows.

```css
--shadow-card: none;                                   /* default cards have NO shadow */
--shadow-card-hover: 0 2px 12px rgba(0,0,0,0.06);     /* gentle lift on hover */
--shadow-dropdown: 0 4px 32px rgba(0,0,0,0.12),       /* dropdowns/modals only */
                   0 0 1px rgba(0,0,0,0.08);
```

### Custom shadows for hero visuals

```css
/* Browser frame mockup */
box-shadow: 0 20px 60px rgba(0,0,0,0.08);

/* Floating gradient cards */
box-shadow: 0 8px 32px rgba(0,0,0,0.08);

/* Shield/icon glow */
box-shadow: 0 20px 60px rgba(48,209,88,0.3);  /* tinted by element color */
```

### Rules

- **No shadow on default cards.** Use a 1px border instead (`#e8e8ed`).
- **Shadows for floating elements only:** dropdowns, modals, hover-lift cards, hero mockups.
- **Tinted shadows for accent elements:** colored glow matching the element (e.g. green shadow on a green shield).
- **Blur radius > offset.** Apple shadows are diffuse, never sharp. Use `0 8px 32px` not `4px 4px 0`.

---

## 7. Buttons & CTAs

### Primary Button (Pill)

The signature Apple button — fully rounded, blue, prominent.

```css
.btn-primary, .hp-buy-btn {
    background: #0071e3;
    color: #fff;
    padding: 10px 24px;
    border-radius: 980px;
    font-size: 14px;
    font-weight: 500;
    border: none;
    cursor: pointer;
    transition: background 0.2s ease;
}
.btn-primary:hover { background: #0077ed; }
```

### Secondary Button (Outline Pill)

For "Talk to Sales" or low-emphasis actions:

```css
.btn-outline-pill {
    border: 1.5px solid rgba(0,0,0,0.2);
    color: #1d1d1f;
    padding: 11px 28px;
    border-radius: 980px;
    background: none;
}
```

### Tertiary (Text Link)

For "Learn more" type links — Apple's trademark blue arrow pattern:

```html
<a href="#" class="link-arrow">Learn more ›</a>
```

```css
color: #0066cc;
font-size: 17px;
text-decoration: none;
/* ":hover" adds underline */
```

### Button Sizes

| Size | Padding | Font | Use |
|------|---------|------|-----|
| Small | `6px 14px` | `13px / 500` | Compact UI, table actions |
| Default | `10px 24px` | `14px / 500` | Most CTAs |
| Large (`btn-lg`) | `12px 28px` | `15px / 500` | Hero CTAs |
| Full (`btn-full`) | `14px 24px` width:100% | `15px / 500` | Form submits |

### CTA Combinations

The signature pattern: **primary pill + secondary text link**

```html
<div class="hp-cta-row">
    <a href="#" class="hp-buy-btn">Get started</a>
    <a href="#">Learn more ›</a>
</div>
```

Always blue button + blue text link with arrow. Never two prominent buttons side by side.

---

## 8. Cards

### Default Card

```css
.card {
    background: #fff;
    border: 1px solid rgba(0,0,0,0.04);
    border-radius: 18px;
    padding: 36px 28px;
}
```

### Card Anatomy

```html
<div class="card">
    <div class="card-header">
        <div class="card-title">Card Title</div>
        <div class="card-action"><a href="#">View all ›</a></div>
    </div>
    <div class="card-body">
        <!-- content -->
    </div>
</div>
```

### Card Variants

| Class | Treatment |
|-------|-----------|
| Default | White background, subtle border, no shadow |
| `.dim` | Gray background `#f5f5f7`, no border |
| `.highlight` | 2px blue border (for "Most popular" plan) |
| `.accent` | Blue background, white text |
| `.dark` | Dark gray `#1d1d1f`, light text |

### Card Rules

✅ **Do**
- Use border, not shadow, for default cards.
- Padding should be generous: 28-40px for content cards, 14-20px for compact list items.
- Use 18px border radius for content cards, 12px for compact cards.

❌ **Don't**
- Don't use box-shadow on flat content cards.
- Don't combine border + shadow + background tint — pick one method to indicate the card.

---

## 9. Forms & Inputs

### Input

```css
.form-input {
    background: #fff;
    border: 1px solid #d2d2d7;
    border-radius: 12px;
    padding: 12px 16px;
    font-size: 15px;
    color: #1d1d1f;
    transition: border-color 0.15s ease;
}
.form-input:focus {
    outline: none;
    border-color: #0071e3;
    box-shadow: 0 0 0 4px rgba(0, 113, 227, 0.15);
}
```

### Label

```css
.form-label {
    font-size: 13px;
    font-weight: 500;
    color: #1d1d1f;
    margin-bottom: 6px;
    display: block;
}
```

### Hint Text

```css
.form-hint {
    font-size: 12px;
    color: #6e6e73;
    margin-top: 6px;
}
```

### Form Rules

- **Label above input**, never beside (better for accessibility and mobile).
- **12px border-radius** for inputs (matches default card radius).
- **Focus ring**: 4px tinted glow + colored border. Never a thick outline.
- **Validation**: red text + red border on error, with hint below explaining what to fix.

---

## 10. Iconography

### Icon Sources

Use **inline SVG** with `stroke="currentColor"` so icons inherit color.

```html
<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6"
     stroke-linecap="round" stroke-linejoin="round">
    <!-- path -->
</svg>
```

### Icon Sizes

| Context | Size | Stroke |
|---------|------|--------|
| Inline (text) | 14-16px | 1.6 |
| Sidebar nav | 18px | 2 |
| Section icons | 24-28px | 1.5-2 |
| Hero/feature icons | 40-48px | 1.5 |
| Decorative (Apple values) | 48-64px | 1.5 |

### Icon Container Patterns

```html
<!-- Colored chip background -->
<div class="icon-circle blue">
    <svg>...</svg>
</div>
```

```css
.icon-circle.blue { background: rgba(0,113,227,0.1); color: #0071e3; }
.icon-circle.green { background: rgba(48,209,88,0.1); color: #30d158; }
.icon-circle.purple { background: rgba(175,130,255,0.1); color: #af82ff; }
.icon-circle.orange { background: rgba(255,159,10,0.1); color: #ff9f0a; }
.icon-circle.red { background: rgba(255,59,48,0.1); color: #ff3b30; }
.icon-circle.teal { background: rgba(90,200,250,0.1); color: #5ac8fa; }
```

### Icon Rules

- Use **stroke icons** (not filled) for UI affordances (nav, buttons, lists).
- Use **filled icons** sparingly — only when the symbol is recognizable as filled (heart, star).
- **Stroke width 1.5-2** depending on size. Heavier strokes for smaller icons.
- Never mix stroke and fill in the same icon set.

---

## 11. Animation & Motion

### Easing & Duration

```css
--transition-fast: 150ms cubic-bezier(0.25, 0.1, 0.25, 1);
--transition-medium: 250ms cubic-bezier(0.25, 0.1, 0.25, 1);
```

| Action | Duration | Easing |
|--------|----------|--------|
| Hover state change | 150ms | ease-out |
| Dropdown open/close | 250ms | ease-out |
| Modal/panel slide | 300-400ms | ease-out |
| Carousel auto-advance | 5000ms interval | ease-in-out |
| Page transitions | None (avoid) | — |

### Motion Rules

✅ **Do**
- **Pulse/breathe** for live indicators (server status dots): `2s infinite`.
- **Subtle slide-in** when revealing a dropdown (8px translateY + opacity).
- **Smooth scroll** for in-page anchors (`scroll-behavior: smooth`).
- **Pause on hover** for auto-advancing carousels.

❌ **Don't**
- Don't use bouncy easings (`cubic-bezier` overshoots). Apple's motion is straight.
- Don't animate longer than 400ms for UI feedback.
- Don't animate page-to-page transitions (browsers handle this; custom feels janky).
- Don't animate everything — most state changes should be instant.

### Standard Hover Pattern

```css
.element {
    opacity: 0.85;
    transition: opacity 0.15s ease;
}
.element:hover {
    opacity: 1;
}
```

### Pulse/Glow (Live Status)

```html
<svg>
    <circle cx="200" cy="150" r="5" fill="#30d158">
        <animate attributeName="r" values="5;8;5" dur="2s" repeatCount="indefinite"/>
    </circle>
</svg>
```

---

## 12. Responsive Breakpoints

```css
/* Mobile-first; one breakpoint */
@media (max-width: 820px) { /* tablet/mobile adjustments */ }
@media (max-width: 480px) { /* mobile only — rare overrides */ }
```

### Responsive Patterns

| Component | Mobile Adjustment |
|-----------|-------------------|
| Hero h1 | 80px → 52px |
| Hero subhead | 28px → 22px |
| 3-col grid | → 1-col |
| 2-col grid | → 1-col |
| Pricing grid | → 1-col stacked |
| Footer cols | 5-col → 2-col |
| Alternating sections | grid `1fr 1fr` → `1fr` (text always above visual) |
| Bento grid | mixed sizes → all 1-col |

### Container Strategy

- Single max-width container (`1024px`) with `padding: 0 22px` works for 99% of layouts.
- For wide marketing content (gallery, dashboards), allow up to `1200px`.
- Never let body content stretch to full viewport width on desktop.

---

## 13. Dark Mode

Apple uses **deep gray** (`#1c1c1e`), not pure black, for dark mode backgrounds.

### Color Mapping

| Light | Dark |
|-------|------|
| `#fbfbfd` (bg) | `#000000` or `#1c1c1e` |
| `#ffffff` (surface) | `#2c2c2e` |
| `#f5f5f7` (surface 2) | `#3a3a3c` |
| `#1d1d1f` (text) | `#f5f5f7` |
| `#6e6e73` (secondary) | `#a1a1a6` |
| `#e8e8ed` (border) | `#3a3a3c` |

### Implementation

Use CSS custom properties + `[data-theme="dark"]` selector:

```css
:root {
    --color-bg: #fbfbfd;
    --color-text-primary: #1d1d1f;
}
[data-theme="dark"] {
    --color-bg: #1c1c1e;
    --color-text-primary: #f5f5f7;
}
```

Toggle:
```js
document.documentElement.setAttribute('data-theme', 'dark');
```

### Dark Mode Rules

- **Cards lighten in dark mode** (`#2c2c2e`), they don't disappear into the bg.
- **Borders become lighter** in dark mode (`rgba(255,255,255,0.06)`).
- **Accent blue stays the same** — it's the brand. Maybe slightly brighter (`#2997ff`) for contrast.
- **Test every block in both modes.** Always.

---

## 14. Section Patterns

### Vertical Rhythm

Stack sections with consistent vertical padding. Each section is self-contained:

```html
<section class="hp-hero">...</section>          <!-- 100px padding -->
<section class="hp-stats-strip">...</section>   <!-- 56px padding -->
<section class="hp-features-section">...</section> <!-- 80px padding -->
<section class="hp-final-cta">...</section>     <!-- 110px padding -->
```

### Section Background Alternation

To create rhythm, alternate between:
- **White / off-white** (`#fbfbfd`) — default content
- **Light gray** (`#f5f5f7`) — secondary sections (stats, trust bar)
- **Dark** (`#1d1d1f`) — hero or final CTA only
- **Tinted gradient** (sky, green, purple) — feature heroes

Don't alternate every section — too noisy. Use 2-3 different backgrounds across a page.

### Eyebrow Pattern

Almost every section starts with a small label above the heading:

```html
<div class="hp-eyebrow">CLOUD HOSTING</div>
<h2>Engineered for speed.</h2>
<p>Description...</p>
```

This is Apple's signature pattern. Establishes context before the headline.

**Exception for hero variants:** The two bold-statement hero variants — `hp-hero-dark` (dark with stats) and `hp-hero-gradient` (gradient with floating cards) — typically skip the eyebrow. The h1 itself is a confident product statement (e.g. "VPS.", "SSL Certificates.") and the eyebrow would compete with it. Use eyebrows on:

| Hero variant | Eyebrow | Rationale |
|--------------|---------|-----------|
| `hp-hero` (centered) | Required | Context label pairs naturally with centered text |
| `hp-hero-split` (text + visual) | Required | Text column benefits from the small category label |
| `hp-hero-dark` (dark stats) | Skip | Large h1 + stats row IS the context |
| `hp-hero-gradient` (floating cards) | Skip | Product name + gradient + cards establishes identity |

Eyebrows are required on all **subsequent** sections (below the hero) regardless of hero variant.

### Dashboard Page Pattern

All logged-in dashboard pages share the same header anatomy for unified flow. Use `.page-eyebrow` (dashboard variant) + `.page-title` + `.page-subtitle`:

```html
<!-- Simple (most pages) -->
<div class="page-header">
    <div class="page-eyebrow">BILLING</div>
    <h1 class="page-title">Invoices</h1>
    <p class="page-subtitle">View and manage your billing history.</p>
</div>

<!-- With action button (list pages) -->
<div class="page-header">
    <div class="page-header-row">
        <div>
            <div class="page-eyebrow">DOMAINS</div>
            <h1 class="page-title">My Domains</h1>
            <p class="page-subtitle">Manage your domain registrations.</p>
        </div>
        <a href="#" class="btn-primary">Register New Domain</a>
    </div>
</div>
```

#### Category Eyebrow Labels

Use these consistent category labels so users always know where they are:

| Eyebrow | Pages |
|---------|-------|
| `DASHBOARD` | clientareahome (optional — the "Good afternoon" greeting serves a similar purpose) |
| `SERVICES` | clientareaproducts, clientareaproductdetails, upgrade, managessl |
| `DOMAINS` | clientareadomains, clientareadomaindetails, bulkdomainmanagement, whois, domain-pricing |
| `BILLING` | clientareainvoices, viewinvoice, clientareaaddfunds, clientareacreditcard, masspay, account-paymentmethods, subscription-manage |
| `SUPPORT` | supportticketslist, supportticketsubmit, viewticket, ticketfeedback |
| `ACCOUNT` | clientareadetails, clientareasecurity, user-profile, account-user-management |

#### Dashboard Page Rules

✅ **Do**
- Always use `.page-title` class on the `h1` (explicit is cleaner).
- Always include `.page-subtitle` — even a one-line description orients the user.
- Put eyebrow **above** h1, subtitle **below**.
- Callouts/alerts go **after** the page header, **before** filter tabs or content cards.
- Cards contain items — either via direct list items with their own padding (`.service-item`, `.ticket-item`) or wrapped in `.card-body` for tables.

❌ **Don't**
- Don't place callouts above the page header — breaks visual hierarchy.
- Don't omit the subtitle unless the page title is truly self-explanatory (rare).
- Don't introduce new eyebrow labels beyond the 6 categories above — consistency matters.
- Don't apply `.page-eyebrow` on auth pages or public-facing pages (use `.hp-eyebrow` there).

### List Page Pattern

Pages that show a table/list of items (`clientareadomains`, `clientareaproducts`, `clientareainvoices`, etc.) share a common anatomy. Reuse it so list pages across the portal feel like one system.

> **List-page headers are the exception to the Dashboard Page Pattern.** They skip the uppercase category eyebrow and swap the filled-pill CTA for a subtle accent-blue **text link** with a chevron. The title is one word (noun) at 40px / -0.028em, not "My …". Everywhere else in the portal keeps the eyebrow + filled-pill pattern from §14 Dashboard Page Pattern.

```html
<div class="content-area">
    <!-- Page header — no uppercase eyebrow; text-link CTA instead of filled pill -->
    <header class="page-header">
        <div class="page-header-row">
            <div>
                <h1>Domains</h1>
                <p class="page-subtitle">Manage your registrations, renewals, and DNS.</p>
            </div>
            <a href="cart-domain-register.html" class="page-header-action">
                Register a domain
                <svg class="chev" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><polyline points="9 18 15 12 9 6"/></svg>
            </a>
        </div>
    </header>

    <!-- 2-col split: main column + content sub-nav -->
    <div class="dom-split"><!-- or .svc-split, .inv-split — prefix per page -->
        <div class="dom-main">
            <!-- 1. Status / renewal banner (only when-full) -->
            <div class="dom-banner when-full">…</div>

            <!-- 2. Filter tabs — pill-group, OUTSIDE the card -->
            <div class="filter-tabs when-full">
                <button class="filter-tab active">All</button>
                <button class="filter-tab">Active</button>
                …
            </div>

            <!-- 3. Card wraps table + pagination footer -->
            <div class="card">
                <div class="when-full">
                    <!-- Optional toolbar: search + secondary controls -->
                    <!-- Table or .domain-list grid -->
                    <!-- Pagination footer (see below) -->
                </div>
                <div class="when-empty dom-empty">…</div>
            </div>
        </div>

        <!-- Content sub-nav (right by default; chip can move it) -->
        <aside>
            <div class="card subnav-card">
                <div class="subnav-heading">Domains</div>
                <a href="…" class="subnav-item active">
                    <svg>…</svg>
                    My Domains
                    <span class="subnav-count when-full">5</span>
                    <span class="subnav-count when-empty">0</span>
                </a>
                <a href="…" class="subnav-item">…</a>
            </div>
        </aside>
    </div>
</div>
```

#### Required primitives

| Primitive | Purpose |
|---|---|
| `.page-header` with `.page-header-row` | Single-word title (40px / -0.028em) + subtitle + text-link CTA. **No uppercase eyebrow** on list pages. |
| `.page-header-action` | Secondary CTA: 14px accent-blue text + `svg.chev`. Nudges right on hover. Replaces `.btn-primary` as the header action on list pages. |
| `<div class="…-split">` | 2-col grid — defaults to `1fr 240px` (main left, sub-nav right) |
| `.subnav-card` | Content sub-nav: `.subnav-heading` + `.subnav-item` list, with `.subnav-count` counts that swap via `.when-full` / `.when-empty` |
| `<div class="…-banner when-full">` | Informational banner (expiring soon, overdue invoices, renewals due) — muted surface, tinted icon well, subtle text, pill secondary CTA. Never loud/colored alert blocks. |
| `.filter-tabs` (pill-group) | Status filters sit **outside** the card as pills, not as radio lists in a side panel. |
| `.card > .when-full / .when-empty` | The content card wraps both states. Empty state uses the 52px tinted icon-well + 15px title + 13px sub + pill CTAs recipe from §14. |
| `.…-menu-wrap` (kebab) | Per-row `⋯` button with a floating Apple-style dropdown of row actions. See pattern below. |
| Apple-faithful pagination footer | See pattern below. |

#### Pagination footer (Apple-faithful)

Transparent, borderless, typographic — not a tertiary-surface DataTables bar.

```html
<div class="dom-footer when-full">
    <div class="dom-page-size">
        Show
        <select><option>10</option><option>25</option><option>50</option></select>
        entries
    </div>
    <div class="spacer"></div>
    <span>Showing 1–5 of 5</span>
    <div class="dom-pages">
        <button disabled>‹</button>
        <button class="active">1</button>
        <button disabled>›</button>
    </div>
</div>
```

Key properties:
- `background: transparent`, no `border-top`.
- `<select>`: `border: 0; background: transparent;` — hover reveals a subtle `--color-surface-secondary` fill. No box around it in the resting state.
- Page buttons: `border: 0; background: transparent;` — active + hover use `color: var(--color-accent)`, not a filled accent pill. Disabled = `opacity: 0.25`.
- Tabular-nums on counts.

#### Divider lines and column-header surface

Drop the hairline between rows, the hairline under the column header, and the tinted `surface-secondary` strip behind the column header. The card is the container; whitespace and hover do the rest:

```css
/* Rows + column header: no separating lines */
.dom-main .domain-row,
.dom-main .domain-list-header { border-bottom: none; }

/* Column headers sit on the card surface, not on a tinted strip */
.svc-table thead th { background: transparent; border-bottom: none; }
```

#### Per-row kebab (⋯) action menu

Use a three-dot button in the last cell of each row for row-level actions — not a chevron link, and not a row of inline icons. One button, one dropdown.

```html
<div class="dom-menu-wrap" onclick="event.stopPropagation();">
    <button type="button" class="dom-menu-btn" aria-haspopup="true" aria-expanded="false"
            onclick="toggleDomMenu(this, event)">
        <svg viewBox="0 0 24 24" fill="currentColor">
            <circle cx="5" cy="12" r="2"/>
            <circle cx="12" cy="12" r="2"/>
            <circle cx="19" cy="12" r="2"/>
        </svg>
    </button>
    <div class="dom-menu" role="menu">
        <a href="…" class="dom-menu-item" role="menuitem">
            <svg>…</svg> Manage Domain
        </a>
        <!-- etc -->
    </div>
</div>
```

Key properties:
- **Button**: 28×28 circle, transparent by default, `surface-secondary` on hover + when open. Three dots at 14px, tertiary color.
- **Dropdown**: absolute under the button, 220px min-width, `surface` background, `0.5px` border, `8px 32px` shadow, `var(--radius-md)` corners, `z-index: 20`.
- **Items**: 13px, 14px icons (tertiary → accent on hover), `surface-secondary` hover row.
- **Row container must allow overflow**. The card has `overflow: hidden` by default — override it on the list's card so the menu isn't clipped:
  ```css
  .dom-main .card,
  .svc-main .card { overflow: visible; }
  ```
- **Whole-row click still works**. Because `<a>` can't nest `<a>`, list rows use `<div class="domain-row" data-href="…">` (or existing `<tr data-href>`) with a JS click handler that bails out if the click target is inside `.…-menu-wrap`, a `<button>`, or an `<a>`.
- **Menu behavior**: only one menu open at a time; closes on outside click and on `Escape`.

#### Chip-driven layout (dev preview only)

The `partials/state-chip.html` preview chip + `apple-layout.js` drive several body attributes that this pattern responds to:

| Attribute | Values | Effect |
|---|---|---|
| `data-align` | (unset) / `content` / `left` | `unset` = center combined (main + aside); `content` = center main only, aside floats in remaining gutter; `left` = flush left |
| `data-subnav` | (unset) / `off` | `off` hides the aside and collapses `.…-split` to 1 column |
| `data-subnav-side` | `right` (default) / `left` / `outside` / `outside-left` | `right`/`left` = inside grid column; `outside`/`outside-left` = aside floats in the outer gutter (falls back to inside column below 1100px viewport) |

These chips are dev-only. CSS rules live on each list page under `body[data-subnav-side="…"] .…-split { … }` — copy the block from `clientareadomains.html` or `clientareaproducts.html` when adding a new list page and swap the prefix.

#### List Page Rules

✅ **Do**
- Use the refined header: no uppercase eyebrow, single-word title, `.page-header-action` text link instead of a filled pill.
- Wrap the full state in `.when-full` and ship an Apple-style empty card in `.when-empty` — state-chip toggles between them.
- Put filter tabs as a pill-group above the card, not as a radio list in a side panel.
- Keep the sub-nav counts in sync with the data state (`.subnav-count.when-full` shows the real count; `.subnav-count.when-empty` shows `0`).
- Use the transparent pagination footer — no surface-tertiary strip, no filled accent page-button.
- Let column headers sit on the card surface — no `surface-secondary` tinted strip, no underline.
- Use one per-row `⋯` kebab dropdown for row actions, not a row of inline icons or a chevron link.
- Override `.…-main .card { overflow: visible }` on list pages so the kebab dropdown isn't clipped by the card's rounded corners.
- Center action/toggle columns (`text-align: center; justify-self: center;` on `:nth-child(N)`).

❌ **Don't**
- Don't reuse the Dashboard Page Pattern's `.page-eyebrow` + `.btn-primary` on list pages — they feel SaaS-y. List pages are typographic.
- Don't put the filter controls in a left side-panel card with radio buttons — that was the older pattern; we've replaced it with pill-group tabs for visual consistency across list pages.
- Don't use the legacy `svc-paging` / `inv-pages`-with-fill styling from older v2 pages — the current standard is borderless and transparent.
- Don't ship divider hairlines between rows — the card is the container, hover + spacing do the work.
- Don't use a tinted `surface-secondary` background behind `<thead>` — the header is part of the same visual plane as the rows.
- Don't nest `<a>` inside `<a>`. If a row is clickable and needs a kebab menu, the row must be a `<div>` (or `<tr>`) with `data-href` + a JS click handler.
- Don't wire the chip options into server-rendered templates. They're preview-only.

---

## 15. Component Library

### Inline Styles: When They're Allowed

**Production UI components must use CSS classes and design tokens** — buttons, cards, forms, nav items, lists, tables. Never apply color or spacing via `style=""` on these.

**Inline styles are allowed for decorative mockups** — browser-frame product screenshots, world-map illustrations, server-rack visuals, floating gradient cards, illustrative charts. These are effectively images rendered as markup. Extracting each one-off decoration into a class bloats the CSS for zero reuse.

Rule of thumb:
- If you'd ship it as an SVG/image in a different codebase → inline styles OK
- If it's a real UI element a user interacts with → must use classes

### Quick Reference Table

| Component | Class | When to Use |
|-----------|-------|-------------|
| **Hero — Centered** | `.hp-hero` | Default hero, search-focused pages |
| **Hero — Split** | `.hp-hero-split` | When you have a strong product visual |
| **Hero — Dark Stats** | `.hp-hero-dark` | Technical products (VPS, security) |
| **Hero — Gradient** | `.hp-hero-gradient` | Premium/aspirational products |
| **Pricing — 3-col** | `.hp-pricing-section` | Standard pricing comparison |
| **Pricing — Toggle** | `.hp-pricing-toggle-section` | Monthly/annual pricing |
| **Pricing — Starting at** | `.hp-pricing-hero` | Single-tier or "starting from" pricing |
| **Features — Icon Cards** | `.hp-features-section` | 6-feature overviews |
| **Features — Numbered** | `.hp-features-numbered` | Step-by-step processes |
| **Features — Bento** | `.hp-bento-section` | Marketing-heavy feature mix |
| **Features — Checklist** | `.hp-features-checklist` | "What's included" lists |
| **Features — Strip Scroll** | `.hp-strip-scroll` | Variety of features (gold, dark, green cards) |
| **Locations — Cards** | `.hp-locations-section` | Show 4-8 data centers |
| **Locations — Pills** | `.hp-locations-compact` | 8+ items, compact tag display |
| **Locations — Map** | `.hp-locations-map-section` | Hero-level global presence |
| **Testimonials — Hero** | `.hp-testimonial-hero` | Single, powerful quote |
| **Testimonials — Cards** | `.hp-testimonials-grid` | 3 testimonials with carousel |
| **Testimonials — Strip** | `.hp-testimonials-scroll` | 5+ testimonials, dark backdrop |
| **FAQ — Accordion** | `.hp-faq-section` | Long FAQ list |
| **FAQ — Card Grid** | `.hp-faq-grid` | Quick 4-6 question overview |
| **Stats Strip** | `.hp-stats-strip` | 4 large numbers (uptime, customers) |
| **Trust Bar** | `.hp-trust-bar` | Compact stats below a section |
| **Logo Bar** | `.hp-logo-bar` | Partner/integration logos |
| **Final CTA** | `.hp-final-cta` | Bottom-of-page call to action |
| **Split CTA** | `.hp-split-cta` | Two paths (Get started / Talk to sales) |
| **Values** | `.hp-values-section` | Mission/principles (Apple iPad style) |
| **Upgrade Compare** | `.hp-upgrade-section` | "Worth the upgrade?" metric grid |

See `components.html` for live examples of every block.

---

## 16. Apple-Specific Patterns

### The "Worth the Upgrade?" Block

Adapted from apple.com/iphone-air. Use to compare a current product against an upgraded version.

**Anatomy:**
- Centered h2 (~56px)
- Subtitle (~21px, muted)
- 2-column grid of comparison items
- Each item: large blue metric (`48px / accent color`) + h4 title + description

**When to use:** Upgrade prompts, plan comparisons, "before/after" feature gains.

### The "Our Values Lead the Way" Block

Adapted from apple.com/ipad-11. Mission/values section.

**Anatomy:**
- Left-aligned h2 (~64px, NOT centered)
- 3-column grid of value cards on light gray background (`#f5f5f7`, `border-radius: 20px`)
- Each card: large icon top-left → h3 title → paragraph → "Learn more ›" link
- Cards have generous padding (`36px 32px`)

**When to use:** About sections, mission statements, brand principles.

### The Hero Browser Mockup

Apple's signature: a browser-frame containing a product preview.

```html
<div class="hp-browser-frame">
    <div class="hp-browser-bar">
        <span class="dot" style="background: #ff5f57;"></span>
        <span class="dot" style="background: #febc2e;"></span>
        <span class="dot" style="background: #28c840;"></span>
    </div>
    <!-- Your product UI mockup here -->
</div>
```

Frame uses gradient background (`#f5f5f7 → #e8e8ed`), 22px radius, soft drop shadow.

### Centered + Search Bar Hero

Apple uses for "search" pages (apple.com/shop):

```html
<section class="hp-hero">
    <div class="hp-eyebrow">DOMAINS</div>
    <h1>Find your perfect domain.</h1>
    <p class="hp-subhead">Search over 400 TLDs.</p>
    <!-- Decorative search bar mockup -->
</section>
```

### Floating Cards Pattern (Gradient Hero)

Tinted gradient background + 3-4 floating cards using `backdrop-filter: blur(12px)`:

```css
background: linear-gradient(160deg, #e8f5e9 0%, #c8e6c9 30%, #a5d6a7 100%);
.hp-floating-card {
    background: rgba(255,255,255,0.85);
    backdrop-filter: blur(12px);
    border-radius: 16px;
}
```

Use `green` for security/trust products, `purple` for creative/premium, custom colors for brand fit.

### Sticky Nav with Frosted Glass

Apple's nav is always sticky with translucent blur:

```css
.homepage-nav {
    position: sticky;
    top: 0;
    background: rgba(251,251,253,0.72);
    backdrop-filter: saturate(180%) blur(20px);
    border-bottom: 1px solid rgba(0,0,0,0.06);
}
```

### Mega Menu (Hover Dropdown)

Full-width panel with 3-column grid. Each item has bold name + muted tagline:

```html
<div class="nav-item-dropdown">
    <a href="#" class="nav-dropdown-trigger">Hosting <svg class="chevron">...</svg></a>
    <div class="nav-mega-menu">
        <div class="nav-mega-inner">
            <div class="nav-mega-col">
                <h4>Web Hosting</h4>
                <a href="..." class="nav-mega-item">
                    <div class="name">Cloud Hosting</div>
                    <div class="tag">Fast NVMe storage, global CDN</div>
                </a>
            </div>
        </div>
    </div>
</div>
```

Critical: dropdown wrapper must use `align-self: stretch` and the trigger `height: 100%` so there's no hover gap when moving cursor to menu.

---

## 17. Do's and Don'ts

### Voice & Copy

✅ **Do**
- "Get started" / "Buy now" / "Sign in" — short verbs
- Specific numbers: "99.99% uptime", "$10.17/mo", "55-second deploy"
- Lead with the benefit, not the feature: "Sleep easy" not "AES-256 encryption" (encryption is a supporting detail)
- Use sentence case for headings: "Engineered for speed." not "Engineered For Speed."
- End headlines with periods. Apple-trademark.

❌ **Don't**
- Never use "Solutions", "Synergize", "Empower", "Unleash"
- No exclamation points in headlines
- No "World-class", "Best-in-class", "Industry-leading" — vague claims sound corporate
- No question marks in headlines (except specific patterns: "Worth the upgrade?", "How can we help?")

### Layout

✅ **Do**
- Generous whitespace — sections breathe at 80-120px vertical padding
- Single column of focus per section. One headline + one supporting visual. Not three competing things.
- Strong vertical rhythm — alternate dense (stats) and spacious (hero) sections
- Use the eyebrow → headline → description → CTA pattern consistently

❌ **Don't**
- Don't pack 6 things into one section — split across multiple sections
- Don't use full-bleed background images with text on top (low contrast risk)
- Don't right-align body text — Apple is left-aligned (or centered for hero)
- Don't use thin lines as section dividers — use whitespace and background change instead

### Color Use

✅ **Do**
- Restrained palette — 90% neutrals (off-white, gray, black), 10% accent (blue)
- One bright color per section maximum (e.g. blue button OR green checkmarks, not both prominently)
- Use color semantically (green = success, red = error)

❌ **Don't**
- Don't use brand color for decoration (no random blue boxes)
- Don't use rainbow status pills (red/yellow/green) — visually noisy
- Don't tint everything — let neutral surfaces be neutral

### Typography

✅ **Do**
- Use the system font stack always
- Negative letter-spacing on headings (-0.02 to -0.03em)
- Generous line-height on body (1.5-1.6)
- Big, confident headlines (don't be timid — 56-80px on hero)

❌ **Don't**
- Don't use display fonts, decorative fonts, or anything with personality
- Don't use weight 700 (too heavy for SF Pro Display)
- Don't justify text — Apple uses left-align (or center for short hero text)
- Don't add `text-transform: uppercase` to body — only eyebrows

### Components

✅ **Do**
- Reuse blocks from the component library (`components.html`) instead of creating new variants
- Match border radius across sibling elements (a section of 18px cards stays 18px)
- Use the existing color tokens — don't introduce new shades

❌ **Don't**
- Don't combine more than 3 different card styles in one page
- Don't use `<table>` for layout — use grid
- Don't nest cards inside cards more than once (hard to read)

---

## Quick Start: Building a New Section

When adding a new section to a page, follow this checklist:

1. **Pick a pattern** from the component library (`components.html`). Don't invent.
2. **Use the eyebrow → h2 → p → CTA** structure.
3. **Wrap in a `<section>`** with appropriate padding (80px default, 60-100px range).
4. **Constrain content** to `max-width: 1024px` with `padding: 0 22px`.
5. **Test in dark mode** — verify all colors adapt.
6. **Test at 820px** — verify the responsive collapse works.
7. **Check the rhythm** — does this section feel right between the section above and below?

---

## Resources

- **Live component library:** [components.html](apple-client-area/components.html)
- **All pages sitemap:** [sitemap.html](apple-client-area/sitemap.html)
- **Design tokens:** [css/apple-theme.css](apple-client-area/css/apple-theme.css) (top of file)
- **Apple HIG (reference):** [developer.apple.com/design](https://developer.apple.com/design/human-interface-guidelines/)
- **Apple.com (inspiration):** [apple.com/mac](https://www.apple.com/mac/), [apple.com/iphone](https://www.apple.com/iphone/)

---

*Last updated: 2026-04-14. When adding new components, update this guide and `components.html` together.*
