# Hadrian accessibility conformance report

Laid out like a VPAT 2.5 EU edition, against EN 301 549 and WCAG 2.2 levels A and AA. This is a self-assessment by the developer, not an independent audit.

| | |
|-|-|
| Product | Hadrian client theme and order form for WHMCS 9, with the Page Builder and Email Templates modules |
| Version | Theme asset version 1.1.247 |
| Report date | 26 November 2026 |
| Standard | EN 301 549 v3.2.1 (WCAG 2.1 AA, cited) and WCAG 2.2 AA (EN 301 549 v4.1.1, published, not yet cited) |
| Scope | Every client-area page, order-form step and store page the theme renders, in its four main-menu layouts, light and dark mode, with default settings and no third-party modules |
| Out of scope | The Hadrian admin addon screens (a back-office tool), WHMCS core output the templates cannot change, third-party modules and gateways, content the site owner adds |

## How it was evaluated

- Automated: axe-core 4.14.0 with the WCAG 2.2 A and AA rules and axe's best practices, 276 scans of 115 pages (every route the test suite knows, the order steps with a cart, the other layouts, ten pages at 320px), in light and dark mode. `tests/e2e/a11y.spec.mjs`.
- Static: five markup checks over 416 client templates. `tests/static/check-a11y-markup.mjs`.
- Scripted keyboard walks of the dashboard, homepage, sign-in, checkout, dialogs, menus, tabs and the mobile drawer.
- Colour: every text and status token measured against every surface it sits on, translucent fills composited, in both modes and all seven style presets.
- Not yet done: a screen reader pass (NVDA, VoiceOver, TalkBack), a text-spacing test, and an independent audit.

Terms: **Supports** means the theme meets the criterion on the pages in scope. **Partially supports** means some parts do not, listed in the remarks. **Not applicable** means the theme has no content of that kind.

## WCAG 2.2, levels A and AA (EN 301 549 clause 9)

### Perceivable

| Criterion | Level | Conformance | Remarks |
|-|-|-|-|
| 1.1.1 Non-text Content | A | Supports | Decorative icons are hidden from assistive technology; icon-only controls are named; logos and product images carry alt text. Images the site owner adds need their own alt text. |
| 1.2.1 Audio-only and Video-only (Prerecorded) | A | Not applicable | The theme ships no audio or video. |
| 1.2.2 Captions (Prerecorded) | A | Not applicable | As above. |
| 1.2.3 Audio Description or Media Alternative | A | Not applicable | As above. |
| 1.2.4 Captions (Live) | AA | Not applicable | As above. |
| 1.2.5 Audio Description (Prerecorded) | AA | Not applicable | As above. |
| 1.3.1 Info and Relationships | A | Supports | Landmarks, headings in order, labelled fields, table headers, real radio and tab semantics. |
| 1.3.2 Meaningful Sequence | A | Supports | |
| 1.3.3 Sensory Characteristics | A | Supports | |
| 1.3.4 Orientation | AA | Supports | |
| 1.3.5 Identify Input Purpose | AA | Supports | Sign-up, sign-in, contact and checkout fields carry `autocomplete` tokens. |
| 1.4.1 Use of Color | A | Supports | Links in running text are underlined; status labels carry words; the unread-notification dot is named. |
| 1.4.2 Audio Control | A | Not applicable | |
| 1.4.3 Contrast (Minimum) | AA | Partially supports | Text tokens, status text and links pass in both modes and all presets. Remaining failures from the last scan are listed under "Known exceptions". |
| 1.4.4 Resize Text | AA | Supports | |
| 1.4.5 Images of Text | AA | Supports | |
| 1.4.10 Reflow | AA | Supports | No page tested scrolls sideways at 320px; wide data tables scroll inside their own container. |
| 1.4.11 Non-text Contrast | AA | Partially supports | The focus ring and the theme's form controls are 3:1. Some page-specific and cart inputs still draw a 1.2:1 hairline border. |
| 1.4.12 Text Spacing | AA | Not yet tested | No `!important` rule blocks a user override; not yet checked with the text-spacing bookmarklet. |
| 1.4.13 Content on Hover or Focus | AA | Supports | Hover menus and tooltips stay while hovered and close with Escape. |

### Operable

| Criterion | Level | Conformance | Remarks |
|-|-|-|-|
| 2.1.1 Keyboard | A | Supports | Menus, dialogs, tabs, the mobile drawer and choice cards all work from the keyboard. |
| 2.1.2 No Keyboard Trap | A | Supports | Dialogs hold focus while open and release it on close. |
| 2.1.4 Character Key Shortcuts | A | Not applicable | No single-key shortcuts. |
| 2.2.1 Timing Adjustable | A | Partially supports | WHMCS ends idle sessions through PHP's session lifetime and gives templates no warning hook. Site owners should keep the lifetime generous. |
| 2.2.2 Pause, Stop, Hide | A | Supports | The carousel, ticker and marquee have a Pause button and do not move under reduced motion. |
| 2.3.1 Three Flashes or Below Threshold | A | Supports | |
| 2.4.1 Bypass Blocks | A | Supports | Skip link and landmarks. |
| 2.4.2 Page Titled | A | Supports | |
| 2.4.3 Focus Order | A | Supports | The closed mobile drawer is out of the tab order; focus moves into dialogs and back. |
| 2.4.4 Link Purpose (In Context) | A | Partially supports | Row actions in some lists read "Manage" or "View" without naming the row. |
| 2.4.5 Multiple Ways | AA | Partially supports | Navigation menus and knowledgebase search; no site-wide search or HTML sitemap page yet. |
| 2.4.6 Headings and Labels | AA | Supports | |
| 2.4.7 Focus Visible | AA | Supports | A 2px ring in the accent colour on every control. |
| 2.4.11 Focus Not Obscured (Minimum) | AA | Supports | Scroll padding keeps focused content clear of the sticky bar. |
| 2.5.1 Pointer Gestures | A | Supports | |
| 2.5.2 Pointer Cancellation | A | Supports | |
| 2.5.3 Label in Name | A | Supports | |
| 2.5.4 Motion Actuation | A | Not applicable | |
| 2.5.7 Dragging Movements | AA | Supports | Drag-to-scroll strips also have arrow buttons. |
| 2.5.8 Target Size (Minimum) | AA | Supports | |

### Understandable

| Criterion | Level | Conformance | Remarks |
|-|-|-|-|
| 3.1.1 Language of Page | A | Supports | Follows the visitor's WHMCS language; right-to-left languages are marked. |
| 3.1.2 Language of Parts | AA | Supports | Language picker entries carry their own language. |
| 3.2.1 On Focus | A | Supports | |
| 3.2.2 On Input | A | Partially supports | Four selects reload the page when changed: the contact pickers on the two contact pages, the currency on the SSL store page and the cart's currency. |
| 3.2.3 Consistent Navigation | AA | Supports | |
| 3.2.4 Consistent Identification | AA | Supports | |
| 3.2.6 Consistent Help | A | Supports | Contact and support links sit in the footer on every page. |
| 3.3.1 Error Identification | A | Supports | Errors are listed in a summary that is announced and takes focus. WHMCS returns errors without field keys, so fields are not individually marked. |
| 3.3.2 Labels or Instructions | A | Supports | |
| 3.3.3 Error Suggestion | AA | Supports | Messages are WHMCS's own. |
| 3.3.4 Error Prevention (Legal, Financial, Data) | AA | Supports | Orders are reviewed in the cart before checkout. |
| 3.3.7 Redundant Entry | A | Supports | The domain registrant can reuse the account's contact details. |
| 3.3.8 Accessible Authentication (Minimum) | AA | Partially supports | Paste and password managers work. WHMCS's built-in image captcha has no alternative; site owners should choose reCAPTCHA. |

### Robust

| Criterion | Level | Conformance | Remarks |
|-|-|-|-|
| 4.1.2 Name, Role, Value | A | Supports | Buttons, switches, tabs, radios, disclosures and dialogs expose their state. |
| 4.1.3 Status Messages | AA | Supports | Order totals, domain lookups, table filters and form errors are announced. |

## Other EN 301 549 clauses

| Clause | Conformance | Remarks |
|-|-|-|
| 10 Non-web documents | Partially supports | WHMCS writes PDF invoices with TCPDF, which produces untagged PDFs. Every invoice is also a web page in the client area. |
| 11.7 User preferences | Supports | Reduced motion, colour mode and browser zoom are respected. |
| 11.8 Authoring tools | Partially supports | The Page Builder keeps one h1 per page and every image field has alt text; it does not yet warn about low-contrast custom colours. |
| 12.1 Product documentation | Supports | The documentation site has a skip link, landmarks and passing contrast; `client-theme/10-accessibility.md` describes the accessibility features. |
| 12.2 Support services | Not applicable | The site owner's support process. |

## Known exceptions

From the final scan on 26 November 2026, with default settings:

axe found 69 failing elements across 276 scans, down from 13,575 when measurement started. 15 of the 18 rules that failed then are at zero. What is left:

| Where | What | Criterion |
|-|-|-|
| Homepage, dark mode | One section keeps a light grey background in dark mode, so its dark-mode text and links fall to 2.4 to 3.3:1 | 1.4.3 |
| Homepage, dark mode | One paragraph uses the light-mode grey on the dark background (3.35:1) | 1.4.3 |
| Account details, ticket form | Helper text dimmed with opacity 0.5 (3.27:1 light, 4.43:1 dark) | 1.4.3 |
| Register | Option hint text #838384 (3.78:1) | 1.4.3 |
| Domain register and search | Sale group label in accent on the accent tint (4.22:1 light, 3.9:1 dark) | 1.4.3 |
| Account users | Row text and tag on the selected-row tint (4.37 to 4.4:1) | 1.4.3 |
| Contacts, nameservers, dark mode | Danger-outline button text on the raised surface (4.47:1) | 1.4.3 |
| Cancel request | Danger button: white on the base red (3.54:1 light, 3.92:1 dark) | 1.4.3 |
| Checkout, signed in | A sub-heading at level 3 directly under the h1 | 1.3.1 |
| Domain EPP page | One h4 under the h1 | 1.3.1 |
| Ticket feedback | A definition list with a non-dt/dd child | 1.3.1 |
| Domain search results | Bootstrap appends its tooltip to the body, outside every landmark (best practice, not a WCAG failure) | - |

Not found by axe and known from review: the four selects that reload on change (3.2.2), row actions without the row's name (2.4.4), page-specific and cart input hairline borders (1.4.11), the session timeout (2.2.1) and the image captcha (3.3.8), each listed above.

## What the site owner provides

The European Accessibility Act binds the business that sells the service. Hadrian cannot cover: images and content the owner adds, colours the owner changes, third-party modules, chat widgets and payment pages, the captcha choice, the session lifetime, support processes, and the accessibility statement itself, which the theme provides as a page for the owner to fill in (`docs`: client-theme/10-accessibility).
