# Hadrian accessibility plan

Written 2026-11-25. The legal and technical background is in [accessibility-eaa-requirements.md](accessibility-eaa-requirements.md). This file covers what Lagom really shipped, where Hadrian stands today, and the work to get Hadrian to a claim it can defend.

Nothing here has been built. The Hadrian findings come from reading the source, not from a browser or a screen reader, so phase 0 exists to confirm them.

Paths: THEME is `hadrian/templates/hadrian/`, CART is `hadrian_cart/`, ADDON is `hadrian/modules/addons/Hadrian/`.

## Target

WCAG 2.2 level AA on every client-area, cart and store page the theme renders, in all layouts and in light and dark mode, with default settings. That covers the 50 criteria of WCAG 2.1 AA that the law points at today, plus the six that EN 301 549 v4.1.1 adds.

The public wording should be "conforms to WCAG 2.2 AA, see the conformance report", with the report listing exceptions. It should not be "EAA compliant", because the theme cannot make that true for a site by itself.

Out of scope: the Hadrian admin addon screens. They are a back-office tool for the site owner, not a consumer service. The exception is the authoring tools inside it (Page Builder, email designer), whose output is in scope and is covered in phase 8.

## What Lagom actually did

Lagom 2.3.7 (July 2025) announced the work. I compared the 2.3.0-b1 templates in `lagom2.3/` with the 2.4.5 package and the decoded addon PHP. There is no changelog in the package, so I cannot date individual changes.

It was a retrofit. There is no accessibility setting, no skip link, no accessibility statement, and the strings "accessibility", "wcag" and "a11y" do not appear anywhere in their templates, lang files or decoded PHP.

| Attribute (theme .tpl files) | 2.3.0-b1 | 2.4.5 |
|-|-|-|
| `aria-label` | 29 | 87 |
| `aria-hidden` | 24 | 534 (430 in the svg-icon partials) |
| `role="button"` | 0 | 207 |
| `tabindex=` | 17 | 974 (932 are `tabindex="0"`) |
| `sr-only` | 8 | 35 |
| `:focus-visible` in theme.css | 2 | 560 |
| `keydown` handlers in lagom-app.js | 0 | 31 |
| `aria-live`, `role="status"`, `aria-invalid`, `aria-current`, `aria-modal` | 0 | 0 |

### Lagom's techniques, and whether Hadrian should take them

| What Lagom did | Where | Take it? | Hadrian's version |
|-|-|-|-|
| Removed `maximum-scale=1.0, user-scalable=0` from the viewport | `header.tpl:9` | Already done | Hadrian's viewport allows zoom |
| Replaced `div.app-main` with `<main>`, added `<header>` | `core/layouts/main-menu/default/default.tpl:10,51,53` | Yes, and go further | Add `<main id>`, a skip link, labelled `<nav>` elements. Lagom's menu, footer and breadcrumb are still plain divs |
| Darkened the text and status colour variables | `core/styles/*/assets/css/vars/defaults/colors/default.css:19-50` | Yes, same method | Fix the tokens, not the components. Lagom moved body text from 6.0 to 8.2, muted text from 2.8 to 6.5, faded text from 2.2 to 4.7, status colours to 5.2 or better |
| Button hover goes darker instead of lighter | `buttons.css` | Yes | Settles Hadrian's open hover-direction question: darken, so label contrast holds on hover |
| `aria-hidden="true"` on decorative icons | svg-icon and gateway partials | Yes | Lagom's icons are partial files, so it was one edit each. Hadrian has about 980 inline SVGs, so this needs a codemod and a checker |
| `aria-label` on icon-only buttons | hamburger, cart edit and remove, row menus | Yes, translated | Lagom hardcoded English ("Close" x18, "More actions", "Remove"). Hadrian puts every name in `core/lang/english.php` |
| `sr-only` labels on inputs with no visible label | register, DNS, cart quantity | Partly | Fine for search boxes and table inputs. Checkout fields get visible labels |
| `role="alert"` on the shared alert include | `includes/alert.tpl:4` | Already done | Hadrian's `alert.tpl` and `flashmessage.tpl` pick alert or status by severity. Lagom's flash message has no role |
| Modal focus trap and focus restore | `lagom-app.js` @62898 | Yes | One shared helper. Lagom's only runs after a key press; ours always runs |
| Arrow keys and Escape in dropdown menus | `lagom-app.js` @69885 | Yes | Same behaviour in `core-layout.js` |
| Off-canvas menu: Enter opens and focuses, Escape closes and restores | `lagom-app.js` @65337 | Yes, plus a trap | Lagom does not trap focus in the open drawer |
| Slider autoplay pauses on focus | `lagom-app.js` @24618 | Yes, plus a button | WCAG 2.2.2 needs a pause control, which Lagom lacks |
| Focus returns to the button after add-to-cart and domain add | `lagom-app.js` @66187 | Yes | And announce the result in a live region, which Lagom does not |
| "Override Alternative Text" for menu icon images, per language | addon `menu/includes/components/icon.tpl:198-280`, `core/hooks/menu.php:580-591` | Only if needed | Relevant only where Hadrian's menu renders uploaded images. Lagom's fallback alt is the file name, which is wrong; ours should be empty |
| Password strength meter as a `progressbar` with a text value | `includes/login/register-form.tpl:268` | Check | Confirm Hadrian's meter exposes its result as text |
| `tabindex="0"` on 932 elements, `role="button"` on 207 divs and spans | everywhere | No | Use real `<button>` and `<a href>`. Lagom's role=button elements answer Enter but not Space |
| `:focus-visible` mapped to hover colours, with a global `outline:none!important` | `theme.css` @47354 | No | A visible ring on everything. Lagom's approach is the weakest part of their work |
| JS patches styled radios with `role` and a generic "radio button" label, native input set to `aria-hidden` | `lagom-app.js` @64394, `configureproduct.tpl:1133` | No | Keep native inputs focusable and style their wrapper |
| Enter in any form input is intercepted and focus moved to the submit button | `lagom-app.js` @66619 | No | Breaks normal form submission |
| Order summary made focusable with an `aria-label` | `ordersummary.tpl:14` | No | A live region announces total changes instead |

Lagom also left clear failures in place: hardcoded `aria-expanded="true"` on closed toggles, about 20 empty table-expand buttons, an input border at roughly 1.3:1, no `autocomplete` tokens on name or address fields, no error-to-field association, no live regions, and a mismatched CVV label. Hadrian can pass Lagom on substance without matching its attribute counts.

## Where Hadrian stands

Already right: `<html lang>` follows the WHMCS language, the viewport allows zoom, titles are per page, every `<img>` has `alt`, there is no positive `tabindex`, breadcrumbs use `<nav>` with `aria-current`, shared alerts carry roles, list tables use `scope="col"` and real sort buttons, status pills carry text, the register page has full labels and `autocomplete`, and 55 accordions are native `<details>`.

The gaps, worst first:

1. No `<main>` and no skip link on any page except the split login (`THEME/header.tpl:450-474`). The roughly 70 `<header class="page-header">` blocks have no `<main>` ancestor, so they likely expose as banner landmarks.
2. Checkout fields are labelled by an icon only. 34 `<label class="field-icon">` hold just an `<i>`, so the placeholder is the only text (`CART/includes/checkout/account.tpl:139-232`, `domain-registrant.tpl`, `payment.tpl`, `security.tpl`). The same fields have no `autocomplete`. This is the identification and payment step the EAA names.
3. About 83 other controls have no label: ticket reply, domain and knowledgebase search, DNS and forwarder editors, cart quantity and promo inputs.
4. Colour contrast. `--color-text-tertiary` is 3.62:1 in light mode and used about 780 times. Placeholder text is 2.21:1 light and 2.84:1 dark. Orange status text is 3.63:1. Four status pills fail (the known issue from August). White on the primary button is 3.02:1 in dark mode. Input borders are 1.22:1. Hero copy is dimmed with `opacity`.
5. Errors are not tied to fields: zero `aria-describedby`, `aria-invalid` on two pages only, no focus move to the error summary. Login, contact and add-funds errors have no role.
6. No live regions at all. Cart totals, domain search results, the billing-cycle price switch and table filters update silently.
7. The account avatar is a `<div onclick>` on the top and side layouts (`THEME/includes/partials/topnav.tpl:244`, `inner-topbar.tpl:98`), and the dark-mode switch is a `<div onclick>` (`profile-dropdown.tpl:87`). Keyboard users cannot open the avatar menu. The phase 0 Tab walk showed the top layout still has a keyboard route to Logout through the nav's Account dropdown, so this is a duplicate control missing from the keyboard, not a dead end.
8. The off-canvas drawer: `aria-controls="appSidebar"` points at an id that does not exist, the closed drawer is only translated off screen so its links stay in the tab order, and focus is never moved, trapped or restored (`core-layout.js:572-622`).
9. Dropdown state is not exposed. Profile and notification triggers lack `aria-haspopup`, so the existing `setExpanded()` never runs. Sidebar group buttons have no `aria-expanded`. Top-nav dropdowns are `href="#"` links that open on hover and cannot be closed with Escape.
10. No modal traps or restores focus. The locale modal declares `role="radiogroup"` with plain buttons inside.
11. Focus indication. There is no global `:focus-visible` rule. Links and buttons do get the browser's default ring (the phase 0 Tab walk found one visible stop without one, out of 210 at desktop width), so the real failures are the inputs and the cart's custom controls. Inputs swap the outline for a 0.5px border and an 8% alpha ring. `CART/css/custom.css:190-196` removes the outline from every cart button. The visually hidden radio cards in the cart (`.cp-cycle-opt`, `.cp-opt-radio`, apply credit) show no focus at all.
12. Six `role="tablist"` containers have no `role="tab"` children, and no tab set handles arrow keys.
13. Unnamed controls: carousel arrows and dots on three store pages, three remove links in `CART/ordersummary.tpl`, one upsell image link. Thirteen more rely on `title`. About 1% of inline SVGs are `aria-hidden`.
14. Motion. The testimonial carousel advances every 5 seconds and pauses only on mouse hover. The builder's ticker and marquee sections loop with no pause. `prefers-reduced-motion` is honoured in two rules.
15. Links in running text have no underline, and in dark mode the link colour is 2.77:1 against body text.
16. 28 hardcoded English `aria-label`s, English strings inside `dynamic-tables.js`, and no `dir` attribute for right-to-left languages.
17. Smaller: the only `.sr-only` rule is scoped to the pricing compare table (`core-theme.css:2859`) and the cart CSS has none, yet `supporttickets/default/default.tpl:157`, `CART/domainoptions.tpl:111,220` and `CART/sidebar-categories-collapsed.tpl:40` use the class, so that text is probably visible today. Scroll containers are not focusable, there is no `aria-sort`, checkout headings jump from h1 to h4, and the beacon login has no h1.
18. Four selects submit their form on change with no warning: `account-contacts-manage/default/default.tpl:54`, `account-contacts-new/default/default.tpl:51`, `store-ssl/type.tpl:115` and `CART/sidebar-categories-collapsed.tpl:41` (3.2.2).
19. Two standalone documents hardcode `lang="en"`: `core/pages/viewemail/default/default.tpl:15` and `viewbillingnote.tpl:18`.
20. The footer preset ships "Sitemap" and "Accessibility" links that point at `#` (`ADDON/src/Menu/Presets.php:528-530`).

There is no accessibility tooling in the repo. `tests/package.json` has Playwright only. The browser tier does measure contrast, but only on the first heading and first paragraph of each page, and it fails only below 3:1 (`tests/e2e/page-checks.mjs:26-82`).

## Decisions needed before building

These change the look or the scope, so they should be made by a person, not assumed.

Decided on 2026-11-25: items 1 to 4, each as recommended. The focus ring is a 2px accent ring on `:focus-visible`, the muted-text tokens get darker, checkout gets visible labels above the fields, and inputs get a 3:1 `--input-border` token. Items 5 to 7 are still my recommendations and have not been confirmed.

1. Focus ring. `STYLEGUIDE.md:465` says "4px tinted glow + colored border. Never a thick outline." The glow at 8% alpha is invisible to many users. Recommendation: a 2px solid ring in the accent colour with a 2px offset, shown only on `:focus-visible`, so mouse users never see it. The style guide line changes.
2. Muted text. Raising `--color-text-tertiary` from #86868b to about #6e6e73 (and secondary a step darker) flattens the three-step grey hierarchy that the Apple look relies on. The alternative is to keep the token and stop using it for anything that is real text, which means auditing 780 uses. Recommendation: darken the tokens.
3. Input borders. A 3:1 border on every input is visibly heavier than today's hairline. Recommendation: a dedicated `--input-border` token at 3:1, leaving card and divider borders alone, since those are not controls.
4. Checkout labels. Visible labels above the fields (as on the register page), or floating labels that keep the current look. Hidden labels would satisfy screen readers but leave the placeholder as the only visible label. It disappears once the user types, and auditors routinely fail that under 3.3.2. Recommendation: visible labels above, matching register.
5. Admin settings. Lagom has none. Recommendation: no on/off switch for accessibility itself, and only the few operator-facing options in phase 9.
6. WCAG 2.2 rather than 2.1. Recommendation: 2.2, for the reason given in the requirements file.
7. `core/lang/english.php:131` says landmark names were left out of the lang file on purpose. This plan adds them. If there was a reason beyond scope at the time, it should be raised now.

## Phases

Each phase can ship on its own. Sizes are rough: S is a day or two, M is several days, L is a week or more.

### Phase 0: Measure first (S)

Done on 2026-11-25 except the screen reader pass, which needs a person. Results are under "Phase 0 results" at the end of this file.

- Add `@axe-core/playwright` to `tests/` and run it on every route in `tests/e2e/routes.mjs`, each persona, three layouts, light and dark, at 375px and 320px. Tag the run WCAG 2.2 AA.
- The scan must not use `?preview=1&layout=`, which is how `browser.spec.mjs` switches layouts today. Preview mode renders the chrome of all three layouts at once (`THEME/header.tpl:421-457`), so axe would report duplicate landmarks and ids that real visitors never get. Switch layouts through the settings tier's layout pointers instead, one worker, restoring after each.
- Record current violations in a baseline file, the same way `tests/e2e/known-issues.mjs` works, so new violations fail the gate and old ones burn down. Without this the gate would block every push from day one. The static checkers below need the same baseline.
- Add static checkers under `tests/static/`: an icon-only `<button>` or `<a>` without a name, a literal English `aria-label` in a .tpl, an inline `<svg>` without `aria-hidden` or a title, an `<input>` with no label.
- Do one manual keyboard pass and one NVDA pass of register, login, order with a domain, pay an invoice and open a ticket. Note what the source audit got wrong.

### Phase 1: Page shell (M)

Covers 2.4.1, 1.3.1, 2.4.7, 3.1.1, 4.1.2.

Done on 2026-11-26. What changed, against this list:

- `<main id="main-content" class="content-area" tabindex="-1">` in `header.tpl`, closed in `footer.tpl`. Full-bleed pages get a `<main class="mt-fullpage-main">` that is `display: contents`, so their layout is untouched; the split login's own `<main>` became a `<div>` to avoid nesting. The email viewer and billing note got a `<main>` and the active locale's `lang`.
- Skip link first in `<body>`. Its href carries `REQUEST_URI`, because `header.tpl` sets `<base href>` and a bare `#main-content` would load the homepage.
- The side/rail top bar is a `<header>` (banner). The rail is a `<nav>` instead of an `<aside>`. Every chrome landmark has a name from `core/lang/english.php` (`nav.mainMenu`, `nav.sidebar`, `nav.breadcrumb`, `nav.skipToContent`). The top bar was not wrapped in a `<header>`: it is `position: sticky`, and a wrapper would change what it sticks to.
- Global `:focus-visible` ring with `--focus-ring-*` tokens, `!important` so the ~80 `outline: none` rules (many in the cart's inline styles) cannot remove it. The old rules were left in place: they no longer win, and deleting them is churn across 60 files. `[tabindex="-1"]` targets get no ring.
- Global `.sr-only`. `html { scroll-padding-top: 80px }`.
- `dir="rtl"` for the same language list the email module uses, kept in `header.tpl` rather than shared through the addon: one list in two places is cheaper than a cross-module call for eleven strings.
- The closed drawer is `inert` at 900px and below. Opening it moves focus to its first link, Escape returns focus to the button that opened it, and the rail layout's toggles point `aria-controls` at the rail. This was planned for phase 3; it came forward because an inert drawer that opens behind the button would have been harder to reach than before.
- Theme asset version 1.1.242 -> 1.1.243 for the CSS and JS cache-bust.

Measured: `region` 3,493 -> 2, `landmark-one-main` 276 -> 0, `landmark-unique` 200 -> 6, no rule got worse. What is left: unnamed `<form role="form">` blocks in the cart sidebar (6 scans) and a Bootstrap tooltip appended to `<body>` on the domain search results (2). A scripted walk confirmed the skip link is the first Tab stop on non-login pages, Enter keeps the URL and moves focus into `<main>`, and the drawer behaves as above in all three layouts.

- Turn `div.content-area` into `<main id="main-content" class="content-area" tabindex="-1">`. It opens at `THEME/header.tpl:474` and closes at `footer.tpl:24`. Keep the class, since CSS and the test suite select on it. This covers the cart and the invoice and quote pages, which all go through `header.tpl`.
- Both ends sit inside `{if !$mt_fullPage}`, so full-page templates get no `<main>` from the shell and need their own. `login/split` and `error/license-required.tpl` already have one. Every other page flagged `fullPage` needs checking.
- `core/pages/viewemail/default/default.tpl:15` and `viewbillingnote.tpl:18` are standalone documents with `lang="en"` hardcoded. Use the active locale.
- Skip link as the first focusable element in `<body>`, visible on focus, text from `{$hadrianLang.a11y.skipToContent}`.
- Wrap the site chrome in `<header>`. Give each `<nav>` and chrome `<aside>` a translated `aria-label` (primary, account, footer, breadcrumb). When the top layout renders both the top nav and the drawer, mark the inactive one `hidden` or `inert`.
- Add a global `.sr-only` utility to `core-theme.css` and to the cart CSS.
- One global focus rule and a `--focus-ring` token in `core-theme.css`. Delete or rewrite the `outline: none` rules that leave nothing behind (10 in core-theme, 49 in `pages/*.css`, 12 in the cart, plus `CART/css/custom.css:190-196`).
- `dir="rtl"` on `<html>` for RTL languages. The email module already detects this (`hadrian_email/.../src/Theme.php:192`), but it is a separate addon and the theme must not depend on it. Put the check in the Hadrian addon and let the email module call it through its bridge. This sets the attribute only. Full RTL styling is a separate project.
- `html { scroll-padding-top }` equal to the sticky header height, so focused elements are not hidden under it (2.4.11).
- Bump the module version for the CSS cache-bust, and the `|default` number in `CART/common.tpl`.

### Phase 2: Colour (M)

Covers 1.4.1, 1.4.3, 1.4.11.

- Fix at the token level in `core-theme.css:22-79` (light) and `:521-590` (dark), and in `core/config/colors.php` for the derived status tokens: text-tertiary, text-quaternary and placeholder, green, orange, red and blue `-text` tokens, on-accent text in dark mode, the new `--input-border`.
- Replace `opacity` on text with a real colour token (six known rules in `core-theme.css`, for example `:2012`, `:2102`, `:3050`).
- Underline links inside paragraphs and table cells. Navigation, buttons and cards stay as they are.
- The notification unread dot and severity dots get a text equivalent.
- Check all seven presets and the palette generator, since the August note showed the pill failures are independent of the seed colour.
- Tighten the contrast check that already exists in `tests/e2e/page-checks.mjs`. Today it samples the first heading and first paragraph and fails below 3:1. Raise it to 4.5:1 for body-size text and add a fixed selector list for muted text, placeholders, status pills, buttons and links, composited arithmetically.
- The admin colour panel already shows a contrast readout. Make it warn when a chosen colour drops a text pair below 4.5:1.

### Phase 2 notes (done 2026-11-26)

- Text greys: light secondary #636368, tertiary #6e6e73, quaternary #737378; dark #b8b8bd, #a6a6ab, #9a9a9f. Each passes 4.5:1 on bg, surface, surface-secondary and the accent tint. Light secondary was already at the limit on surface-secondary, so tertiary could not stay lighter; secondary went darker to keep three steps.
- Status text: light green #207b37, orange #9c5d00, red #d20015, info #0067d0, neutral #636368; dark #45d669, #ffab28, #ff7a72, #64b4ff, #b2b2b7. Each passes on its own tinted fill over surface and bg.
- Dark links derive from the accent at lightness +8 (was the accent itself, 3.76:1 on surface-secondary).
- Ink on the accent is derived, black or white (decided 2026-11-26). Default dark mode and the amber, emerald, rose and violet presets get dark labels on their buttons. 84 rules that painted white text on an accent fill now use `--color-on-accent`.
- Inputs: 1px border in a new `--color-input-border` (#8a8a8f light, #87878b dark), mirrored in the admin forms schema. Page-local and cart inputs that draw their own `var(--color-border)` hairline are not changed yet.
- Style presets: amber, emerald, rose, slate and violet link and info colours darkened (light) or lightened (dark) to 4.5:1.
- Links in running text are underlined. Two `opacity`-dimmed texts use a real colour. The notification bell's name says when there are new notifications.
- The cart's `style.min.css` keeps its own copy of the text tokens and loads after the theme: it is updated to match. The email module's fallback palette too.
- The browser tier's contrast sample now fails body text under 4.5:1 (was 3:1). It found the cart copy above.
- Not done: the admin colour panel does not warn about contrast yet (its files carry other uncommitted work).

### Phase 3: Keyboard and widget behaviour (L)

Covers 2.1.1, 2.1.2, 2.4.3, 1.4.13, 4.1.2.

Done 2026-11-26. One block of helpers at the end of `core-layout.js` follows the classes the existing scripts toggle, so no page script changed: modal dialogs move focus in, trap Tab and restore focus on close; Escape returns focus to the account and notification menu buttons; sidebar groups and rail items report `aria-expanded`; the six tab lists get `role="tab"`, `aria-selected` and arrow keys; the locale radiogroup gets real radios; the FAQ answers report their state and open with Enter or Space; Escape hides compare-table tooltips. Template changes: the avatars, both dark-mode moon links and the top-nav dropdown triggers are `<button>`s; the dark-mode switch is a `role="switch"` button; menu triggers declare `aria-haspopup`; top-nav menus open on click and Escape dismisses them; the upgrade plan radios are focusable and the card shows the ring. Checked with a scripted probe (19 checks, all pass) and the browser tier.

Build four small helpers in `core-layout.js` and use them everywhere, instead of fixing each widget by hand:

- Disclosure: a `<button>` with `aria-expanded` and `aria-controls`, Escape closes and returns focus. Used by the profile menu, notifications, sidebar groups, top-nav dropdowns, rail flyouts and row menus.
- Dialog: moves focus in on open, traps Tab, closes on Escape, restores focus to the trigger, sets `inert` on the page behind. Used by the locale modal, the three page modals, the cart's Bootstrap modals and the mobile drawer.
- Tabs: `role="tab"` children, `aria-selected`, `aria-controls`, arrow keys, Home and End. Fixes the six invalid tablists.
- Menu: arrow keys inside `role="menu"` row menus.

Then the specific fixes:

- `topnav.tpl:244` and `inner-topbar.tpl:98`: the avatar becomes a `<button>` with a name.
- `profile-dropdown.tpl:87` and `store-order` toggles: `<button role="switch" aria-checked>`.
- Drawer: add the missing `id="appSidebar"`, and make the closed drawer `inert` or `visibility: hidden`.
- Top-nav dropdown triggers become buttons that open on click and on Enter, and close on Escape.
- Locale modal: real radio inputs, or `role="radio"` with `aria-checked` and arrow keys.
- `store/dynamic/partial/faq.tpl`: replace the checkbox hack with `<details>`.
- `upgrade-configure` radio cards: the inputs must not be `hidden`.
- Tooltips (`.cmp-tip`): dismiss on Escape, stay open while hovered.
- Remaining `<a href="#">` and `<a>` without href that act as buttons become buttons.
- The four selects that submit on change (gap 18) get a submit button next to them, or a visible note that choosing an option reloads the page (3.2.2).

### Phase 4: Forms (L)

Covers 1.3.1, 1.3.5, 3.3.1 to 3.3.4, 4.1.2, plus 3.3.7 and 3.3.8 from WCAG 2.2.

- Checkout first, because the law names it. Real text labels for the 34 icon-labelled fields, `autocomplete` tokens copied from the register page, a required or optional cue on every field, and the two `for` mismatches fixed (`account.tpl:210-213`).
- Label the other 83 controls. Search boxes and table inputs can use `.sr-only` labels or `aria-label`.
- One error pattern for every form: a summary at the top with `role="alert"` that receives focus after a failed submit, each entry linking to its field, and `aria-invalid` plus `aria-describedby` on the field. WHMCS returns errors as a flat list, so mapping an error to its field needs a lookup by message key. Where that cannot be done reliably, the summary alone still passes 3.3.1.
- Focus styles for the visually hidden radio and checkbox cards, with `:has(input:focus-visible)`.
- Captcha: translated alt text, a label on the `domaintransfer` input, and a documentation note that the built-in image captcha has no non-visual alternative, so operators who need AA should pick reCAPTCHA or hCaptcha.
- The CVV popover image needs alt text (`CART/includes/checkout/payment.tpl:127,170`).
- Confirm password fields accept paste and work with password managers.
- Confirm checkout does not ask for the same contact details twice without offering to reuse them.
- Session timeout (2.2.1). WHMCS ends an idle session without warning, which can lose a half-filled checkout or ticket. Find out what the session lifetime is on a stock install and whether the theme can warn before it ends. If it cannot, this is a listed exception in the conformance report and a line in the operator guide. I have not investigated this yet.

Phase 4 notes (done 2026-11-26):

- Checkout: 33 fields that were labelled by an icon now have a visible text label above them (the string that was their placeholder; WHMCS's own strings for country and the card dates). The icon stays as decoration in a positioned wrapper, so it still sits in the input. Names, email, phone and address carry `autocomplete` tokens; the domain registrant's use a `section-registrant` prefix; the new passwords use `new-password`. Inputs draw a 1px 3:1 border.
- WHMCS `StatesDropdown.js` swaps the state field for a select at runtime; a helper re-points any label whose field was swapped or hidden at the one visible field in its group.
- 45 other unlabelled fields got names: 27 from their translated placeholder, the rest from WHMCS strings (DNS host and address, forwarder prefix and target, quantity, registration period, security question, captcha, IDN language). Labels that existed but were not associated (`<label class="form-label">` with no `for`) now are. Static check: unlabelled fields 70 -> 13, icon-only labels 34 -> 0. The 13 left are false positives (labels in an including template, a CSS comment, preview-only demo data, hidden selects WHMCS reads).
- Errors: login notices, contact, add funds, mass pay, register and checkout error blocks carry `role="alert"` and `data-error-summary`; a helper moves focus to the summary once on load. Success notices are `role="status"`.
- Choice cards whose input is invisible (cart billing cycle, option radios, apply credit, upgrade plans) draw the focus ring on the card.
- Captcha image alt and code input use WHMCS's own "Spam Bot Verification" string. The CVV help button is named and its popover image has alt text.
- Not done: `aria-invalid` and per-field `aria-describedby`. WHMCS returns errors as one list with no field keys, so the summary is the honest place for them. Session timeout (2.2.1): WHMCS ends idle sessions through PHP's own session lifetime and gives templates no hook or remaining-time value, so the theme cannot warn reliably. It goes in the conformance report as a WHMCS limitation, with a note in the operator guide to keep the session lifetime generous.

### Phase 5: Announcements and motion (M)

Covers 4.1.3, 2.2.2, plus user motion preferences.

- One polite live region in the shell and a `hadrianAnnounce(text)` function. Call it for cart total changes, domain search results, billing-cycle switches, promo codes, add-to-cart and table filter counts.
- `dynamic-tables.js`: set `aria-sort` on the sorted column, announce the result count after search or filter, and check DataTables does not add a second tab stop on each header.
- Testimonial carousel (`core-theme.js:224-268`): a visible pause button, pause on focus, and no autoplay under `prefers-reduced-motion`.
- Builder ticker and marquee sections: pause button, static under reduced motion.
- A global `@media (prefers-reduced-motion: reduce)` block that removes non-essential animation and transitions, and gates `scroll-behavior: smooth`.

Phase 5 notes (done 2026-11-26): one polite live region and `window.hadrianAnnounce(text)` for any script. It speaks the order summary's "total due today" when WHMCS rebuilds it, the domain lookup result, and the result count after a table search or status filter. The sorted column carries `aria-sort`. The testimonial carousel, hero ticker and feature marquee get a Pause/Play button, also stop while hovered or focused, and do not start under `prefers-reduced-motion`; a global reduced-motion rule stops every other animation and smooth scrolling. The ticker's faded words went from 30% to 55% opacity (3:1 for large text). Strings come from a new `a11y` group in the lang file, passed to the scripts by `footer.tpl`.

### Phase 6: Names, icons, language, structure (M)

Covers 1.1.1, 2.4.4, 2.4.6, 2.5.3, 3.1.2, 1.3.1.

- Codemod: add `aria-hidden="true" focusable="false"` to every decorative inline SVG and `<i>` icon (about 980 SVGs, 104 font icons). The phase 0 checker keeps it that way.
- Name the unnamed controls, and move the 13 `title`-only controls to `aria-label`.
- Move the 28 literal labels and the page labels in `header.tpl:233-258` into `core/lang/english.php`. Pass the `dynamic-tables.js` strings in from the template.
- Row actions get names that include the row ("Manage example.com"), so a list of identical "Manage" links is distinguishable.
- `lang` attributes on the native language names in the locale modal.
- Table names (`aria-label` or `<caption>`), and `tabindex="0"` with `role="region"` and a label on horizontal scroll wrappers.
- Headings: real `<h2>` for checkout sections and dashboard block titles, an h1 on the beacon login, footer column titles demoted from h4 to a level that fits.
- Remove the `!important` line-height and letter-spacing at `core-layout.css:1926-2037`, then run the text-spacing test.
- Multiple ways to find a page (2.4.5). The client area has navigation and a knowledgebase search but no site search and no HTML sitemap, and the footer preset's "Sitemap" link points at `#`. The sitemap generator already knows every public page, so an HTML sitemap page is the cheap answer.

Phase 6 notes (done 2026-11-26):

- A codemod hid 1,046 decorative icons in 137 templates (`aria-hidden="true" focusable="false"` on inline SVGs, `aria-hidden` on Font Awesome `<i>`), skipping `<script>` blocks. Static check: unhidden SVGs 965 -> 23, all inside scripts.
- Named the icon-only controls (store carousel arrows and dots, the cart summary's remove links). Moved translatable English names into the lang file (`a11y` group) and the crumb's page labels onto WHMCS's own strings. What is left in the static `literal-name` count (18) is brand names, preview-only chips and two dead templates.
- Heading levels: footer and mega-menu column titles are announced at level 2, homepage feature items and the checkout's sub-headings at level 3; the beacon login and the missing-ticket state got an `<h1>`.
- Language picker entries carry their own `lang`, from the BCP-47 map the hreflang code already had.
- An unnamed `<form role="form">` and a `<footer>` nested inside `<main>` on the cart pages stopped being landmarks.
- Not changed: the `!important` line-height and letter-spacing rules in `core-layout.css`. They do not block WCAG 1.4.12: a user style sheet's `!important` outranks an author's, and the test bookmarklets use inline `!important`, which also wins. Scroll containers: current Chrome and Firefox make scrollable regions keyboard-focusable themselves, and axe's scrollable-region rule found nothing. Row actions still read "Manage" without the row's name.

### Phase 7: WCAG 2.2 additions (S)

- Target size: carousel dots (8px), promo dots (6px), tooltip triggers (15px) and the 14px contact-preference checkboxes reach 24px, by padding where the visual should stay small.
- Dragging: confirm every drag-to-scroll strip has arrow buttons.
- Consistent help: the support or contact link sits in the same place on every page.

Phase 7 notes (done 2026-11-26): every one of the 3,966 target-size failures was a footer link, rows of 13px links 18px apart. Footer links are now at least 24px tall (the text does not move), and carousel dots keep their 8px look inside a 24px button. Dragging strips already had arrow buttons (2.5.7), and the contact link sits in the footer on every page (3.2.6). Target size and label-in-name both reached zero on the scan.

### Phase 8: Outside the theme pages (M)

- Page Builder (`hadrian_builder/`). It is an authoring tool under EN 301 549 clause 11.8. Eleven sections emit an `<h1>`, so two heroes on one page give two h1s: add a heading-level control or demote automatically. Image fields need an alt text input and a "decorative" choice. The editor should warn on low contrast for custom colours.
- Email (`hadrian_email/`). `lang` and `dir` are handled. Check layout tables carry `role="presentation"`, images have alt text, and the six designs meet contrast.
- PDF invoices and quotes fall under clause 10. WHMCS generates them with TCPDF, which does not write tagged PDF. The practical answer is that the HTML invoice page is the accessible version and the conformance report says so.
- The documentation site should meet the same standard, since clause 12.1 covers documentation.

### Phase 9: What the operator gets (M)

- An accessibility statement page template in the Page Manager, with fields for the Annex V content: service description, how the requirements are met, known limitations, contact route, date. The footer preset already has an "Accessibility" link (`ADDON/src/Menu/Presets.php:530`), but it points at `#` and its label is plain English. Point it at the new page and move the label into the lang file.
- A small Accessibility group in Settings, added through `SettingsController::FLAGS` and `FLAG_GROUPS`. Candidates: underline all links, and a site-wide reduced-motion override. Each new flag needs documentation or `check-settings-doc-coverage.php` fails.
- A documentation chapter in `hadrian-documentation/content/client-theme/` with what the theme covers, what stays the operator's job (logo and image alt text, colour choices, third-party modules, gateways, captcha choice, the statement) and a pre-launch checklist.
- A published conformance report in VPAT 2.5 EU format, updated per release.

Phase 8 and 9 notes (done 2026-11-26):

- Page Builder: a page keeps one `<h1>`; any later hero heading is announced at level 2 (`aria-level`, so its styling stays). Covered by a new check in `test-builder-engine.php`. Every builder image field already had an alt text box; empty means decorative.
- Email: the palette works out the ink on accent buttons (black or white) the way the theme does, since email clients cannot run the CSS derivation, and dark-mode links get the same lift. Layout tables already carried `role="presentation"` and images their alt text.
- Documentation site: it already had a skip link, landmarks and focus rings; its copy of the theme tokens carried the old greys, so `docs.css` overrides them.
- PDF invoices: WHMCS renders them with TCPDF, which writes no tags. The statement page and the docs say the HTML invoice is the accessible version.
- Accessibility statement: a new `accessibility` page (Page Manager group Public) with the Annex V content written in the lang file and seven options for what only the site owner knows (status, limitations, method, contact email, enforcement body, dates). Hadrian does not ship the root `accessibility.php` entry file, so a statement still holding default answers never goes live by itself; the docs say how to create it.
- Docs: a new chapter, `client-theme/10-accessibility.md`, covering what the theme does, what stays the owner's job, publishing the statement and a pre-launch checklist.
- Not built: an Accessibility settings group. Links in running text are already underlined and reduced motion follows the visitor's own device setting, so neither toggle the plan proposed earns its place. The admin colour panel's contrast warning is still not built (its files carry other uncommitted work).

Phase 10 notes (2026-11-26): the final scan's leftovers were fixed where they were clear. Text painted in the accent colour now uses the link colour (334 declarations; the accent is a fill colour and was 4.31:1 as text on the grey surface). The dark-mode "Resend" button on the email verification banner gets dark ink (white on the lifted orange was 1.89:1). Nine inline styles that put white on an accent fill use the derived ink. The checkout's password meter is named, an empty table header got a label, and section titles that jumped from h1 to h3 or h4 on the domain, upgrade, payment method, announcement and knowledgebase pages announce the right level. The results and the exceptions left are in [accessibility-conformance-report.md](accessibility-conformance-report.md).

### Phase 10: Sign-off (M)

- Screen reader passes of the five journeys on NVDA with Chrome or Firefox, VoiceOver with Safari, and TalkBack.
- 200% and 400% zoom, a 320px viewport and the text-spacing overrides on every page type.
- The axe baseline is empty, or every remaining entry is listed in the conformance report as a known exception with a reason.
- For the "EAA" marketing line, an independent audit is the only thing that makes the claim more than self-declared. Lagom does not appear to have one.

## Order and risk

Phases 0, 1 and 2 touch every page and should go first, one at a time, each through the pre-push gate. Phase 4's checkout work is the highest legal priority and can run right after phase 1. Phases 3 and 5 share `core-layout.js` and should not run in parallel. Phase 6's codemod touches hundreds of templates, so it needs a clean tree and its own commit.

Things that can go wrong:

- The colour and focus changes alter the look on every page. Run the visual tier before and after and review the diffs by eye.
- The cart carries large inline `<style>` blocks that beat global rules on specificity. Focus and label styles for the cart may have to be re-asserted at matching specificity.
- A bad Smarty edit in a mass codemod can poison the compiled template cache on the live site. Run the compile tier on every template before any deploy.
- CSS files must stay ASCII-only.
- Shared layout assets are mirrored between the mockup tree and the theme. Shell changes land in both, or the mockup is declared out of date.
- WHMCS core output that templates cannot reach (some module pages, MarketConnect blocks) will show up in the axe run. These go in the conformance report as third-party content, with JS patches only where cheap.

## Review notes

I reviewed this plan against the code on 2026-11-25, after writing it.

Checked directly and confirmed: no `<main>` or skip link in the shell, the 34 icon-only checkout labels, both `<div onclick>` avatars and the dark-mode switch, the missing `appSidebar` id, the single scoped `.sr-only` rule, the lone `:focus-visible` rule, the `Presets.php` link, and that `viewinvoice.tpl` goes through `header.tpl`.

Corrected by the review:

- Phase 0 would have scanned preview mode, which renders three layouts at once. It now uses real layout pointers.
- The RTL item reused a function from the email module, which would have made the theme depend on a separate addon.
- The contrast test was described as new. A weaker one exists and is now extended instead.
- Added gaps 18 to 20, the session-timeout item, the multiple-ways item and the scope line for the admin addon.
- The `<main>` item now says where the element opens and closes and that full-page templates fall outside it.

Still unverified, because nobody has run it:

- Every count from the source audit (unlabelled controls, SVGs, `outline: none` rules) came from regex scans and will be off by some margin.
- The contrast ratios were calculated from token values, not measured on rendered pages. The August pill measurements are the exception.
- Anything marked "probably" or "likely" above, including the banner-landmark point and the visible `.sr-only` text.
- Lagom's behaviour was read from minified JS and templates, not exercised in a browser.

## Phase 0 results

Measured on 2026-11-25 against the local stack (WHMCS 9.0.8), axe-core 4.14.0, WCAG 2.2 A + AA plus axe's best-practice rules.

What was built:

- An `a11y` tier: `tests/e2e/a11y.spec.mjs`, run with `node tests/run.mjs --tier a11y` (about 18 minutes, one worker, settings snapshot and restore). It scans every route in `tests/e2e/routes.mjs` in the sidebar layout, the four order steps with a two-item cart as guest and signed in, six pages in each of the top, rail and topbar-minimal layouts, and ten pages at 320px. Light and dark throughout. 276 scans of 115 pages. It is not in `--gate`.
- `tests/e2e/a11y-baseline.json`: page, rule, number of failing elements. The run fails on a new rule, more elements, a page missing from the baseline, or a rule that has gone (so the baseline shrinks with each fix). A second full run against it passed, so the counts are stable from run to run.
- `tests/static/check-a11y-markup.mjs` with `tests/static/a11y-markup-baseline.json`, in the static tier and so in the pre-push gate. Five source heuristics over 416 client templates.
- `tests/lib/a11y-summary.mjs` turns a run's detail into `tests/reports/a11y-summary.md`.

### What axe found

| Rule | Pages (of 115) | Elements, all scans | Notes |
|-|-|-|-|
| `color-contrast` | 115 | 2,844 | See the colour pairs below |
| `landmark-one-main` | 115 | 276 | No page has a `<main>` (gap 1) |
| `region` | 115 | 3,493 | Content outside any landmark, a side effect of the missing `<main>` |
| `target-size` | 114 | 3,966 | WCAG 2.2 2.5.8. Mostly inline links in menus and footers under 24px tall |
| `label-content-name-mismatch` | 114 | 302 | `aria-label` replaces visible text: the locale button ("Choose language & currency" over "EN / USD"), the cart button |
| `heading-order` | 108 | 285 | Footer column titles and homepage cards are `<h4>` under an `<h1>` |
| `landmark-unique` | 90 | 200 | Two unnamed `<aside>` and `<nav>` landmarks per page |
| `aria-required-children` | 11 | 29 | The `role="tablist"` containers with no `role="tab"` (gap 12) |
| `link-in-text-block` | 4 | 23 | Links told apart from text by colour only (gap 15) |
| `label-title-only` | 4 | 14 | Domain register and transfer search fields |
| `label` | 2 | 28 | 13 unlabelled permission checkboxes on account-user-permissions, the marketing opt-in on checkout |
| `select-name` | 1 | 4 | Country and state on the guest checkout |
| `page-has-heading-one`, `empty-table-header`, `definition-list`, `landmark-no-duplicate-contentinfo`, `aria-progressbar-name` | 1 each | 2 each | Missing-ticket page, managessl, ticket feedback, addons, checkout password meter |

No page scrolled sideways at 320px, so 1.4.10 reflow holds on the pages tested. The email viewer ignores dark mode, which is expected for a standalone document.

The contrast failures come from a handful of tokens, which supports fixing at the token level (phase 2). From the sample run, by element count:

| Mode | Text on background | Ratio | Where |
|-|-|-|-|
| light | #86868b on #ffffff | 3.62 | `--color-text-tertiary`: descriptions, prices, breadcrumbs |
| dark | #8e8e93 on #2c2c2e | 4.27 | the same token in dark mode |
| light | #86868b on #fbfbfd and #f5f5f7 | 3.50, 3.32 | the same token on page and surface backgrounds |
| dark | #ffffff on #2997ff | 3.01 | primary buttons in dark mode |
| dark | #a1a1a6 on #3a3a3c | 4.41 | secondary text on raised surfaces |
| light | #c27400 on #fbf2e5, #ffffff on #c27400 | 3.26, 3.62 | email verification banner |
| dark | #ffffff on #ff9f0a | 2.05 | email verification banner button, the worst pair found |
| light | #248a3d on #eafaee | 4.06 | billing-cycle saving pill |

### What the static check found

416 templates: 965 inline SVGs not hidden, 70 unlabelled fields, 35 English names written into templates, 34 icon-only labels (all in the checkout includes), 9 icon-only buttons or links (store carousel arrows, the cart's remove links).

### What axe missed

- The 34 checkout fields labelled only by an icon pass axe, because axe accepts the placeholder as a name. The static check is what catches them.
- The icon-only carousel arrows are on store landing pages that are not in `routes.mjs`, so the browser scan never loads them. Adding the store landing pages to the routes would close that.
- axe has no rule for skip links when a page has headings, so the missing skip link does not show up as `bypass`. `landmark-one-main` and `region` stand in for it.

### Keyboard walk

A scripted Tab walk (70 presses) on the homepage and dashboard in the top and sidebar layouts, at 1280px and 375px:

- At 375px, in both layouts, the first 12 Tab presses land in the closed off-canvas drawer, which is off screen. Gap 8 is confirmed.
- At 1280px nothing hidden takes focus. Top-nav dropdowns open on focus.
- The avatar never takes focus. The top layout still reaches Logout through the nav's Account dropdown, and the sidebar layout reaches the account menu through `.sidebar-user`. Gap 7 is narrower than written.
- Links and buttons show the browser's default focus ring. Gap 11 is about inputs and custom controls.

The probe is `tests/.local/a11y-keyboard-probe.mjs` (local, not tracked).

### Still to do for phase 0

- A screen reader pass (NVDA with Chrome or Firefox) of register, login, order with a domain, pay an invoice and open a ticket. That needs a person.
- A decision on when the `a11y` tier joins `--gate`. It takes about 18 minutes against a gate of about 5, so the likely answer is a smaller set of pages in the gate and the full scan before each release.
