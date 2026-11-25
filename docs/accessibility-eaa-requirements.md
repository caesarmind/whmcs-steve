# European Accessibility Act and WCAG 2.1 AA: what compliance takes

Researched 2026-11-25. This file covers the law, the technical standard behind it, and what each rule means on a WHMCS storefront. The plan for Hadrian is in [accessibility-hadrian-plan.md](accessibility-hadrian-plan.md).

I am not a lawyer and this is not legal advice. The directive is transposed separately by each EU member state, so penalties and enforcement bodies differ by country. Quotes below come from the directive as adopted.

## The short version

- The law is Directive (EU) 2019/882. It applies to services provided to consumers after 28 June 2025, and "e-commerce services" are on the list.
- The party the law binds is the business selling to consumers, which here means the hosting company running WHMCS. A theme vendor is not a "service provider" under the directive. So a theme cannot be EAA compliant by itself. It can conform to the technical standard, which is what the site owner needs from it.
- The technical standard is EN 301 549. Version 3.2.1 is the one currently cited in the EU Official Journal, and its web chapter is WCAG 2.1 levels A and AA: 50 success criteria.
- Version 4.1.1 of EN 301 549 was published on 2 September 2026 and moves to WCAG 2.2 AA. It is not yet cited in the Official Journal. Building to WCAG 2.2 AA now costs six extra criteria and avoids a second pass.
- Code is only part of it. The site owner also has to publish accessibility information, keep the site conformant as it changes, and offer accessible support.

## Who is bound, and who is exempt

Scope. Article 2(2)(f) lists e-commerce services. Article 3(30) defines them as services provided at a distance through websites and mobile services, by electronic means, at the individual request of a consumer, "with a view to concluding a consumer contract". A WHMCS client area and order form that sells hosting or domains to individuals fits that definition. Purely business-to-business sales fall outside it, though most hosting companies cannot prove every buyer is a business.

The rule applies to anyone selling to consumers in the EU, wherever the seller is based.

Microenterprises. Article 4(5) exempts microenterprises that provide services. Article 3(23) defines a microenterprise as a business with fewer than 10 staff and either turnover or balance sheet at or below EUR 2 million. Many small hosts qualify. They are still exposed commercially, because their customers and resellers may not be exempt and will ask.

Disproportionate burden. Article 14 lets a provider skip a requirement that would fundamentally alter the service or impose a disproportionate burden. The provider must assess this against Annex VI, document it, keep the results for five years after the service was last provided, and redo the assessment at least every five years. It is a narrow exit and has to be argued requirement by requirement.

Exempt content (Article 2(4)): pre-recorded video and audio published before 28 June 2025, office documents published before that date, third-party content the operator neither funds, develops nor controls, and archives not updated since that date. Online maps are exempt only if the essential information is also given in an accessible form.

Transition (Article 32). Service contracts agreed before 28 June 2025 can run unchanged until they expire, for at most five years. Providers may also keep using products they lawfully used before that date until 28 June 2030. This does not give websites five more years: a site that takes new orders today is providing a service today.

## What the directive asks of a service

Annex I Section III applies to every service. The parts that matter for a website:

- Information about how the service works must be available through more than one sense, be understandable, be available as text that assistive technology can convert, and use adequate font size, contrast and spacing.
- Websites and related online applications must be accessible "by making them perceivable, operable, understandable and robust". Those four words are the four WCAG principles.
- Support services (help desks, call centres, technical support) must give information on the accessibility of the service and its compatibility with assistive technology, in accessible ways of communicating.

Annex I Section IV adds three points for e-commerce:

1. Give the accessibility information for products and services being sold, when the responsible operator supplies it.
2. Make identification, security and payment functions perceivable, operable, understandable and robust. On WHMCS that is login, registration, password reset, two-factor authentication, captcha and the payment gateway step.
3. Provide identification methods, electronic signatures and payment services that meet the same four principles.

Article 13 puts the ongoing duties on the service provider:

- Design and provide the service according to the requirements.
- Prepare the information described in Annex V and make it public in written and oral format, including in a way accessible to people with disabilities. Keep it for as long as the service runs.
- Have procedures so the service stays conformant when the service, the requirements or the standards change.
- If the service is found non-conformant, fix it and tell the national authority.

Annex V says where that information goes: "in the general terms and conditions, or equivalent document". It must hold a general description of the service in accessible formats, the explanations needed to understand how the service works, and a description of how the service meets the Annex I requirements. In practice this is what people call an accessibility statement. It should also name known gaps and give a contact route for reporting barriers, which the directive does not spell out but national authorities expect.

## The technical standard

Article 15 gives a presumption of conformity to services that follow a harmonised standard cited in the Official Journal. That standard is EN 301 549.

| Version | Web baseline | Status on 2026-11-25 |
|-|-|-|
| EN 301 549 v3.2.1 (2021) | WCAG 2.1 A + AA | Cited. This is the legal reference today. |
| EN 301 549 v4.1.1 (published 2 Sep 2026) | WCAG 2.2 A + AA | Published by ETSI, not yet cited. Secondary sources give target dates between 30 Nov and mid Dec 2026. I did not check the Official Journal, so treat the date as unconfirmed. |

Clause 9 of EN 301 549 is WCAG. Other clauses also apply to a website:

| Clause | Subject | Where it shows up on a WHMCS site |
|-|-|-|
| 9 | Web content (WCAG) | Every client-area, cart and store page |
| 10 | Non-web documents | Downloadable PDF invoices, quotes and billing notes |
| 11.7 | User preferences | Respecting OS and browser settings such as reduced motion, text size and forced colours |
| 11.8 | Authoring tools | Any tool that lets the site owner create pages. The Hadrian Page Builder and the email designer are authoring tools. They must be able to produce accessible output and should prompt for things like alt text. |
| 12.1 | Product documentation | Documentation must describe the accessibility features and be accessible itself |
| 12.2 | Support services | Support must be able to answer accessibility questions through accessible channels |
| 6, 7 | Voice and video | Only if the site embeds live chat with voice, or video |

## WCAG 2.1 A and AA, criterion by criterion

"Owner" says who can fix it. Theme means the theme's templates, CSS and JS. Operator means the site owner's content and configuration. Both means the theme has to make it possible and the operator has to use it.

### Perceivable

| SC | Level | What it means on a WHMCS site | Owner |
|-|-|-|-|
| 1.1.1 Non-text Content | A | Every image, icon button and SVG has a text alternative, or is hidden from assistive technology when decorative. Covers logos, payment gateway images, product images, captcha. | Both |
| 1.2.1 to 1.2.3 Audio and video (prerecorded) | A | Captions and transcripts for any video the operator embeds. A stock WHMCS site has none. | Operator |
| 1.2.4 Captions (Live), 1.2.5 Audio Description | AA | Same, for live and prerecorded video. | Operator |
| 1.3.1 Info and Relationships | A | Headings are real headings, lists are lists, data tables have header cells, form fields have programmatic labels, groups of radios sit in a fieldset with a legend. | Theme |
| 1.3.2 Meaningful Sequence | A | DOM order matches reading order. CSS reordering (flex `order`, grid placement) must not scramble it. | Theme |
| 1.3.3 Sensory Characteristics | A | Instructions do not rely on shape, colour or position alone ("click the green button on the right"). | Both |
| 1.3.4 Orientation | AA | Pages work in portrait and landscape. | Theme |
| 1.3.5 Identify Input Purpose | AA | Personal-data fields carry the right `autocomplete` token: name, email, tel, street-address, postal-code, country, current-password, new-password, cc-number and so on. Applies to login, register, checkout and contact details. | Theme |
| 1.4.1 Use of Color | A | Status, errors, required fields and links inside text are distinguishable without colour. A red border alone is not an error message. | Theme |
| 1.4.2 Audio Control | A | No audio that plays automatically for more than 3 seconds. | Operator |
| 1.4.3 Contrast (Minimum) | AA | Text is 4.5:1 against its background, 3:1 for large text (24px, or 18.66px bold). Includes placeholder text, muted text, text on buttons, text on status pills, and both light and dark mode. | Both |
| 1.4.4 Resize Text | AA | Text scales to 200% with browser zoom without loss of content. The viewport meta tag must not block zoom. | Theme |
| 1.4.5 Images of Text | AA | Real text, not pictures of text, except logos. | Both |
| 1.4.10 Reflow | AA | At 320 CSS px wide (equal to 400% zoom on a 1280px screen) content reflows to one column without horizontal scrolling. Data tables may scroll inside their own container. | Theme |
| 1.4.11 Non-text Contrast | AA | Input borders, checkboxes, toggles, focus rings and meaningful icons are 3:1 against what is next to them. | Theme |
| 1.4.12 Text Spacing | AA | Nothing is clipped or overlaps when the user sets line height 1.5, paragraph spacing 2x, letter spacing 0.12em and word spacing 0.16em. Fixed heights on text containers break this. | Theme |
| 1.4.13 Content on Hover or Focus | AA | Tooltips and hover menus can be dismissed with Escape, can be hovered themselves, and stay until dismissed. | Theme |

### Operable

| SC | Level | What it means on a WHMCS site | Owner |
|-|-|-|-|
| 2.1.1 Keyboard | A | Everything works with the keyboard: menus, dropdowns, tabs, accordions, modals, custom selects, product cards, billing-cycle pickers, domain search, date pickers. | Theme |
| 2.1.2 No Keyboard Trap | A | Focus can always leave a component. Modals trap focus while open and release it on close. | Theme |
| 2.1.4 Character Key Shortcuts | A | Single-letter shortcuts can be turned off or remapped. Usually not applicable. | Theme |
| 2.2.1 Timing Adjustable | A | Users are warned before a session times out and can extend it. WHMCS sessions expire silently, so a long checkout can lose data. | Both |
| 2.2.2 Pause, Stop, Hide | A | Anything that moves, blinks or auto-updates for more than 5 seconds can be paused. Carousels, marquees, animated hero art. | Theme |
| 2.3.1 Three Flashes | A | Nothing flashes more than three times a second. | Theme |
| 2.4.1 Bypass Blocks | A | A "skip to main content" link as the first focusable element, plus landmarks. | Theme |
| 2.4.2 Page Titled | A | Each page has a title that describes it. Stock WHMCS repeats one title across many pages. | Theme |
| 2.4.3 Focus Order | A | Tab order follows the visual and logical order. No positive `tabindex`. Focus moves into a dialog when it opens and returns to the trigger when it closes. | Theme |
| 2.4.4 Link Purpose (In Context) | A | Link text makes sense with its surrounding sentence or row. "View", "Manage" and icon links in a table need an accessible name that says what they act on. | Theme |
| 2.4.5 Multiple Ways | AA | More than one way to reach a page: navigation plus a search or a sitemap. | Both |
| 2.4.6 Headings and Labels | AA | Headings and labels describe their topic or purpose. | Both |
| 2.4.7 Focus Visible | AA | Keyboard focus is always visible. No `outline: none` without a replacement. | Theme |
| 2.5.1 Pointer Gestures | A | No function needs a multi-point or path gesture (pinch, swipe) without a single-tap alternative. | Theme |
| 2.5.2 Pointer Cancellation | A | Actions fire on pointer up, not pointer down, so they can be aborted. | Theme |
| 2.5.3 Label in Name | A | The accessible name of a control contains its visible text. An `aria-label` must not replace visible wording with different wording. | Theme |
| 2.5.4 Motion Actuation | A | Nothing is triggered only by shaking or tilting the device. Not applicable. | Theme |

### Understandable

| SC | Level | What it means on a WHMCS site | Owner |
|-|-|-|-|
| 3.1.1 Language of Page | A | `<html lang>` matches the language being shown, and changes when the client switches language. | Theme |
| 3.1.2 Language of Parts | AA | Passages in another language carry their own `lang`. The language switcher's entries are the common case. | Theme |
| 3.2.1 On Focus | A | Focusing a control does not change context. | Theme |
| 3.2.2 On Input | A | Changing a field does not submit a form or navigate without warning. Currency and language selects that reload on change need care. | Theme |
| 3.2.3 Consistent Navigation | AA | Navigation appears in the same order on every page. | Theme |
| 3.2.4 Consistent Identification | AA | The same function has the same name and icon everywhere. | Theme |
| 3.3.1 Error Identification | A | Errors are described in text and the field in error is identified. | Theme |
| 3.3.2 Labels or Instructions | A | Every field has a visible label. Required fields and format rules are stated before submission. A placeholder is not a label. | Theme |
| 3.3.3 Error Suggestion | AA | When the fix is known, the error says how to fix it. | Both |
| 3.3.4 Error Prevention (Legal, Financial, Data) | AA | Before an order or payment is final the user can review and correct it. Applies to checkout, cancellations and domain transfers. | Theme |

### Robust

| SC | Level | What it means on a WHMCS site | Owner |
|-|-|-|-|
| 4.1.1 Parsing | A | Valid nesting and unique ids. Removed in WCAG 2.2, but duplicate ids still break label and ARIA references. | Theme |
| 4.1.2 Name, Role, Value | A | Every custom control exposes a name, a role and its state. Dropdown toggles expose `aria-expanded`, tabs expose `aria-selected`, toggles expose checked state, and scripts keep these in sync. | Theme |
| 4.1.3 Status Messages | AA | Messages that appear without a page load are announced: "added to cart", domain availability results, promo code applied, form saved, validation errors. Uses `role="status"`, `role="alert"` or `aria-live`. | Theme |

### What WCAG 2.2 AA adds

These become part of the harmonised standard once EN 301 549 v4.1.1 is cited.

| SC | Level | What it means |
|-|-|-|
| 2.4.11 Focus Not Obscured (Minimum) | AA | A sticky header, cookie bar or chat widget must not fully cover the focused element. |
| 2.5.7 Dragging Movements | AA | Anything done by dragging has a click alternative. Sliders for server configuration are the likely case. |
| 2.5.8 Target Size (Minimum) | AA | Click targets are at least 24 by 24 CSS px, or have enough spacing around them. |
| 3.2.6 Consistent Help | A | Help links (contact, support) sit in the same place on every page. |
| 3.3.7 Redundant Entry | A | The user is not asked to retype something already entered in the same process. Billing and registrant contact in checkout. |
| 3.3.8 Accessible Authentication (Minimum) | AA | Login does not depend on a memory or puzzle test with no alternative. Password managers and paste must work, and captcha needs a route that is not a cognitive test. |

## What a theme can cover and what it cannot

A theme controls its own markup, styles and scripts. That is most of clause 9, and it is where a storefront usually fails. It does not control everything a visitor meets.

| Area | Who controls it |
|-|-|
| Templates, CSS, client-side JS, default colours, default copy | Theme |
| Colours the owner picks in a style editor, uploaded logos and images, custom pages, announcements, knowledgebase articles, product descriptions, email content | Operator, with the theme's tools helping or hindering |
| HTML generated by WHMCS core that templates cannot change (some module output, MarketConnect blocks, generated form fields) | WHMCS, with the theme able to patch some of it in JS |
| Third-party modules, server module client areas, live chat widgets, cookie banners | Their vendors |
| Payment gateway pages and embedded card fields | The gateway |
| Captcha | The captcha provider and the operator's choice of provider |
| PDF invoices and quotes | WHMCS PDF templates, which the theme can ship |
| Accessibility statement, support process, staff training | Operator |

So the claim a theme vendor can stand behind is narrow: with default settings and no third-party output, the theme's pages conform to WCAG 2.1 (or 2.2) AA, with the exceptions listed in a conformance report. Lagom's public wording goes further ("compliance with the European Accessibility Act"), and I found no audit report or conformance report from RS Studio to back it.

## How conformance is shown

Automated scanners find roughly a third of WCAG failures. They catch missing names, missing labels, most contrast failures and invalid ARIA. They cannot judge focus order, whether a name is meaningful, keyboard operability of custom widgets, or whether a status message is announced. A credible claim needs all of these:

1. Automated scan of every page template in every state (empty and full, logged in and out, light and dark, each layout), with a tool such as axe-core.
2. Keyboard pass of each user journey: register, log in, order a product with a domain, pay an invoice, open a ticket, manage a service.
3. Screen reader pass of the same journeys. The usual set is NVDA with Firefox or Chrome on Windows, VoiceOver with Safari on macOS and iOS, and TalkBack on Android.
4. Zoom and reflow: 200% and 400% browser zoom, a 320px viewport, and the WCAG text-spacing overrides.
5. Contrast measured for every text and control token in each colour mode, not judged by eye.
6. A written conformance report. The usual format is the VPAT 2.5 EU edition, which is laid out against EN 301 549. It lists each criterion as supports, partially supports or does not support, with remarks.

## What Lagom says it did

Lagom shipped this in client theme 2.3.7 on 20 July 2025, with matching updates to Website Builder 1.1.4, Support Hours 1.2.1 and Sensitive Data 1.0.1. Their blog post and docs describe four areas of work:

- Keyboard navigation: logical tab order, visible focus indicators, no keyboard traps, support for Tab, Shift+Tab, Enter, Space and Escape in modals and dropdown menus.
- Screen readers: semantic elements, ARIA landmarks, descriptive labels on navigation, forms and buttons, and `aria-hidden` on decorative icons and illustrations.
- Scalability: menus, sections, buttons and typography that hold their layout under browser zoom and larger display settings.
- Contrast: higher contrast on text, icons and interactive components, done without changing the look much.

The docs file this under "SEO Features" as a built-in feature with no settings. What the decoded code actually contains is in the plan file.

## Sources

- [Directive (EU) 2019/882, as adopted](https://www.legislation.gov.uk/eudr/2019/882/adopted/data.htm) and on [EUR-Lex](https://eur-lex.europa.eu/eli/dir/2019/882/oj)
- [W3C: EU accessibility policies](https://www.w3.org/WAI/policies/european-union)
- [WCAG 2.1](https://www.w3.org/TR/WCAG21/) and [WCAG 2.2](https://www.w3.org/TR/WCAG22/)
- [CCPC Ireland: EAA guidelines for microenterprises](https://www.ccpc.ie/business/enforcement/accessibility/european-accessibility-act-guidelines-for-microenterprises/)
- [NDA Ireland: What is the European Accessibility Act?](https://nda.ie/accessibility/european-accessibility-act)
- [Level Access: EN 301 549 v4.1.1](https://www.levelaccess.com/compliance-overview/en-301-549-compliance/), [Vispero: EN 301 549](https://vispero.com/digital-accessibility-compliance/en-301-549/), [Deque: EN 301 549](https://www.deque.com/accessibility-compliance/en-301-549/) (vendor sources, used for the v4.1.1 timeline only)
- [Lagom blog: EAA Compliance, client theme 2.3.7](https://lagom.rsstudio.net/blog/eaa-compliance-lagom-whmcs-client-theme-2-3-7-website-builder-1-1-4/)
- [Lagom docs: SEO Features, Integration with European Accessibility Act](https://lagom.rsstudio.net/docs/seo-features/#integration-with-european-accessibility-act)
