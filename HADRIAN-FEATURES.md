# Hadrian features

Hadrian is a WHMCS 9 theme package: a client-area theme, an order form and an admin addon that configures both. Two optional modules, Page Builder and Email Templates, are separate addons that need Hadrian installed.

This list describes the working tree of `builder/editor-redesign` on 2026-11-25. It was taken from [tests/FEATURES.md](tests/FEATURES.md), the test inventory, which has one row per feature with an ID, the files involved and how well it's tested. Features that have an open bug say so at the end, under [Open bugs](#open-bugs).

Requirements: WHMCS 9.0 or later, PHP 8.1 or later, one licence per installation.

| Part | Folder | What it is |
|---|---|---|
| Client-area theme | `hadrian/templates/hadrian/` | Every WHMCS client page, plus the public site pages |
| Admin addon | `hadrian/modules/addons/Hadrian/` | Setup, settings, styles, layouts, pages, menus, branding, media, sitemap |
| Order form | `hadrian_cart/` | Store, configure, domains, cart and checkout |
| Page Builder | `hadrian_builder/` | Optional addon: visual page editor with 75 sections |
| Email Templates | `hadrian_email/` | Optional addon: branded client emails built in a visual editor |

## Client area

### Page designs

Several pages ship in more than one design. The admin picks one per page on the Pages screen, and each design has its own options.

- Dashboard: Default, Atrium, Bento and Minimal. The last three have a welcome band, a block builder, section titles inside or outside the cards, row and search settings, and colour choices.
- Homepage: Modern and Classic. Modern has a hero with domain search and a TLD strip, live product groups, the latest announcements (left out when there are none) and a call to action. The hero title and subtitle can be set in Pages, and five switches hide the domain search, products, features, news and call-to-action sections. Classic honours the domain-search switch.
- Login: Default, Beacon and Split. Beacon has its own field style, colour and news panel; Split has a panel style, colour and info panel. Both run full page.
- Any page can run full page, with no navigation, sidebar, breadcrumb or footer.
- Pages switch between a "full" and an "empty" layout from the client's real counts, so a client with no services sees a helpful empty state.
- About 25 pages show demo rows under `?preview=1` when there is no real data, for screenshots and setup.

### Layouts

- Three main-menu layouts: a sidebar, a top navigation bar and a slim icon rail.
- Custom layouts: drop a folder with `layout.php`, `default.tpl` and `layout.css` into the layouts folder and it shows up on the Layouts screen. `topbar-minimal` ships as an example.
- Pick one layout for guests and one for signed-in clients, or one per area (public website, client area, order form). A page can choose its own area.
- Any page can override the main-menu and footer layout on its own.
- Sidebar options: content alignment, left or right side, show or hide the account block. Rail options: side and account block.
- Three footers: Default (secondary links and the locale button), Extended (columns from the Footer menu) and Extended Info (adds the logo, a company description and social links).
- Boxed or full-width content, with an adjustable maximum width (1120px by default) and side padding (48px).
- Header options: a bar that slides away on scroll and comes back on scroll up, an unpinned sidebar that scrolls with the page, a hide-breadcrumb switch and icons in the top navigation.
- A preview mode (`?preview=1`) adds a control chip that switches layouts, alignment, sidebar side and card controls on the fly. Without it, those URL parameters do nothing.

### Navigation

- Sidebar: logo with fallbacks (full logo, square logo, company name), a knowledgebase search box, collapsible groups, and the account block or Login and Create Account buttons.
- Top navigation: dropdowns, mega menus, right-aligned items, a guest login button, language and currency switchers.
- Icon rail with flyout panels that open on hover, click or keyboard focus.
- Mobile drawer below 900px, closed by the backdrop, Esc, a link or resizing back.
- Profile dropdown with account links, the dark-mode switch and Sign Out. It works from the keyboard (Enter, Space, Esc).
- Notifications: a dot when there's something new, alerts by severity, and up to five announcements.
- Cart badge with the number of items in the cart, on every page.
- Breadcrumb: "Back to Home" on the top layout, crumbs in the top bar on the sidebar and rail layouts.
- Sidebar count badges for services, unpaid invoices, open tickets and domains.
- The current page is highlighted in the navigation.

### Menus

- Main, footer and footer-secondary menus, built in the admin Menu Manager.
- Ten item types: WHMCS page, custom link, header, divider, dropdown (including mega menus), language, currency, login button, account dropdown and WHMCS default.
- Separate menus for guests and clients, plus a per-item "visible to" rule. Menus can also be picked per area.
- Items can be limited to the top, side or rail layout.
- With no menu set up at all, a fallback shows Home, Dashboard and a "Configure menu" link.

### Look and feel

- Six style presets: Default, Emerald, Violet, Rose, Amber and Slate. Each has a light and a dark palette.
- Every colour token is editable, separately for light and dark. Only the values that differ from the preset are stored, so updates keep the rest current.
- Typography: the bundled Inter font, the system font stack, any of 1,942 Google Fonts (up to five weights), or a self-hosted font folder. A separate heading font, plus sizes, weights and line heights.
- Size and shape settings for navigation, buttons, forms, cards and other elements.
- Custom CSS, printed in the page head.
- Dark mode in three modes: off, optional (a switch for each visitor, remembered in a cookie and rendered by the server, so the page never flashes) or forced. Guests get a moon button in the top navigation. Text stays readable in dark mode.
- Small switches: section-title capitals, "Free" instead of 0.00 prices, hide the billing-cycle "Save X%" badges, a back-to-top button, show/hide on password fields, and a dark-mode logo.
- Cookie consent box with a per-language message, a position and a button label.

### Client pages

Every WHMCS client page has a Hadrian version. The ones with the most work in them:

Services
- Services list with status tabs and counts, search and row links.
- Service details: status, a pending-cancellation notice, side menu, billing, configurable options, custom fields, addons and the server module's own output.
- cPanel and Webmail single sign-on, with 11 shortcuts into cPanel.
- Change the service password through the server module.
- Upgrades of the plan and of configurable options.
- Cancellation requests.
- Module overviews for cPanel, Plesk and WP Squared: Sitejet, addons, WP Toolkit and quick email account creation.
- SSL certificate list, with the configure steps where an SSL module is set up.
- Usage billing metrics.

Domains
- Domains list with a bulk-action bar.
- Domain details with tabs: auto-renew, nameservers, registrar lock and addons, with links straight to a tab.
- DNS management, email forwarding, glue records (private nameservers), the EPP code and WHOIS contacts.
- Domain addons (ID protection and the rest), with a confirmation step.
- Domain pricing table.

Billing
- Invoices list with status tabs and search.
- Mass pay: all unpaid invoices on one invoice.
- Invoice view: line items, apply credit, the payment ledger, change the payment method, PDF download.
- Invoice payment by card or bank, including 3-D Secure.
- Add funds, with preset amounts and the minimum enforced.
- Quotes: accept a quote, download the PDF.
- Payment methods: add a card, edit, delete and set a default.
- Email history.

Support
- Open a ticket: department, urgency, related service, custom fields, attachments and captcha.
- Ticket view: the thread, attachments, reply and close.
- Ticket list, ticket feedback and a markdown guide for the editor.

Content
- Knowledgebase: categories, articles, search and "was this helpful" votes.
- Announcements, with a copy-link button and an RSS link.
- Downloads by category.
- Server status with open, scheduled and resolved issue tabs, and port checks.
- Contact form, with captcha for guests.

Account
- Account details, contacts, users with invites and permissions, profile and password.
- Two-factor sign-in with an authenticator app, and backup codes.
- Switch between accounts for a user on several.
- Invite acceptance and email verification.
- Marketing email opt-in and opt-out.
- Affiliates: referral link, balance, withdrawals and sign-up.
- Sign in with "remember me", captcha and linked (social) accounts.
- Register and password reset, including the security-question step.

Error and dead-end pages
- 404, unknown route, rate limit and internal error pages inside the theme.
- Banned, access denied, download denied and store-not-found pages that explain themselves and lead back.
- 11 MarketConnect store landing pages and the store order page (they need MarketConnect).

### Lists and forms

- One list engine on the six main lists (services, domains, invoices, quotes, tickets, emails): search, status tabs, page size, pager, column sort, row click and a row menu. Search and page size are remembered for two hours. An option loads the lists from the server page by page.
- Captcha (image or reCAPTCHA, as WHMCS is set up) on the 12 forms WHMCS protects.
- International phone field with a country dial code, on sign-up and contacts.
- A Generate Password dialog that fills both password fields.
- Dismissible notices.
- Banners for email verification (resend and dismiss), network issues and account validation.

### SEO

- A title, description and social image for each page and language, printed as the page title, meta description, Open Graph and Twitter tags.
- Noindex per page. Password-reset and legacy pages are noindex by default.
- Canonical URL and `og:url`, without the currency and language parameters.
- `og:type` set to article on announcements and knowledgebase articles.
- hreflang alternate links for each language, following the custom language list.
- `html lang` set from the visitor's language.
- Favicon, and an Apple touch icon when a square logo is uploaded too.
- sitemap.xml and robots.txt, generated from the admin (see [Sitemap](#sitemap)).

### Languages

- All theme text is in language files, with a per-language override file that survives updates. A broken override file is skipped rather than breaking the site.
- Locale button and dialog: flag, native language names, a custom language list, and a currency grid when there's more than one currency. Language and currency can be hidden separately.
- Right-to-left languages are declared in theme.json. Client pages are tested in Arabic.

### Page settings

Set per page on the Pages screen:

- Design (variant) and that design's options.
- Visibility: public, signed-in clients only (guests go to the login page), or disabled (a 404 for everyone except a signed-in admin). Sign-in, order and dead-end pages ignore it, so nobody gets locked out.
- The side column of related links, and whether a list's search and pager sit inside or outside its card. Both also have a global default and an exception list.
- Area, main-menu layout and footer layout.
- SEO title, description and image per language, indexing and the public address.

### For developers

- Add a page by creating a folder under `core/pages/`. It is picked up with no version bump.
- `overwrites.tpl` in a page folder replaces that page whichever design is picked. `overwrites/footer.tpl` replaces the footer.
- Custom main-menu layouts as folders.
- Theme extensions in `core/extensions/`, switched on in theme.json, can add head and footer output.
- WHMCS hook output lands where WHMCS expects it: in the head, after the body opens, and before the scripts.
- Body attributes such as `data-tpl`, `data-auth`, `data-layout` and `data-area` give CSS something to target.
- A recipe for a custom PHP page.

## Admin panel

The Hadrian addon has its own section in the WHMCS admin, with a light and a dark mode. Every "Learn more" link goes to a heading in the customer docs, and every change needs the WHMCS security token.

### Setup and Info

- A Setup checklist in five groups: files, requirements, database, licence and go-live, with a status on every row.
- Run Now: database migrations, the preset menus, the page and layout caches and the branding folder, in one step.
- Save the licence key from Setup.
- Go Live switches WHMCS to the Hadrian theme, and to the Hadrian order form if it's installed, and remembers what was there before. Switch Back restores it.
- A preview link to the client area with Hadrian, before going live.
- The Info page shows the version and the licence status.

### Settings

- General and Order Process tabs, with a search box that also knows synonyms ("gdpr" finds the cookie box).
- Dark mode, the side column of related links, card controls, the custom language list, the cookie box, dynamic table loading and the order-process options described under [Order form](#order-form).

### Styles

- Activate any of the six presets.
- A colour editor for light and dark together. It can generate a palette from one colour, apply a quick preset, undo, and reset to the preset.
- Typography, with the Google Fonts list built in.
- General, button, form, element and navigation settings.
- Custom CSS.
- A Customizer that previews the real client area with unsaved changes. It has device widths, a light/dark switch and layout picks, and saves or discards everything at once.

### Layouts

- Choose layouts by visitor or by area. Switching between the two loses nothing.
- Per-layout options, header and footer switches, content width, maximum width and side padding.
- Custom layout folders are found automatically. A folder that's rejected says why.
- Live preview links for each main-menu layout.

### Pages

- The page list: group tabs, search, a system-page toggle, and badges for SEO, indexing and visibility.
- All the per-page settings listed under [Page settings](#page-settings), plus the social image from the media library.
- Pages made by other modules, such as Page Builder, are listed and set up the same way.

### Sitemap

- Choose what goes into sitemap.xml, and how often it says pages change.
- Generate Now writes sitemap.xml and a marked block in robots.txt, keeping any lines written by hand.
- Refreshes itself when a page is saved, a builder page is published, an announcement is added or edited, and on the daily cron.
- A preview of the XML, the time it was last written, and a warning when the web root isn't writable.

### Menu Manager

- Menus in four locations, each a table of the menus in it, with area badges.
- Preset menus, with Re-seed presets, Force re-sync and Reset WHMCS defaults.
- The editor: ten item types, a WHMCS page picker, translations per item, 34 icons, per-item audience and layouts, and drag to reorder.
- Menus by area.
- A diagnose view that dumps a menu as JSON.

### Branding

- Five image slots for the logos and the favicon. Files are checked (type, size, SVG content) and stored under a random name.
- A company description (up to 280 characters) and social links, used by the Extended Info footer and the Email Templates module.

### Media

- A media library for images up to 5 MB. Uploads can be optimised automatically, at a quality and largest size the admin picks.
- Optimise and restore: the original is kept, and the optimised copy is used only when it's noticeably smaller.
- "Used in" shows where an image appears (pages, settings, menus, other modules). An image in use is not deleted without a second confirmation.
- Rename, filters, sort and bulk actions.

### Other screens

- Extensions: theme extensions and the modules that plug into Hadrian.
- Tools: clear the template cache, rebuild page and layout discovery, refresh the licence.
- Templates list and the Licence page.
- Deactivating with Database Clear removes Hadrian's data.

## Order form

The order form shares the theme's style, fonts and dark mode, and has its own layout pick in area mode.

### Store

- Plan grid with one card per product, its tag line and an Order Now button.
- Billing-cycle pills (Monthly, Annual, Biennial) with the per-month price, a "billed annually" line, the setup fee and a "Save N%" badge.
- "Most popular" on products the admin flags as Featured.
- Setup fees, "starting from" prices and stock left. Out of stock goes to a clear error page.
- A category sidebar and a compact category select for small screens. The sidebar can be switched off.

### Configure

- A summary of the chosen plan and domain, with links back to change either.
- Billing-cycle cards with prices and savings.
- Configurable options (dropdowns, radios, yes/no, quantities with a slider), custom fields and product addons. Each change updates the live order summary, tax included.
- A promo code box on this step, which re-prices when options change.
- Review Cart, which shows WHMCS's validation errors inline.

### Order Process settings

- Hide the hostname and root password fields for all or chosen product groups. The cart fills in a generated hostname and a strong password.
- Hide the nameserver fields, in the same way.
- A custom hostname pattern: random block length, prefix, domain suffix and character set.
- A strength meter on the root password, enforced on the server (weak passwords are refused).
- Hide the hostname line under products on the cart page.

### Domains

- The product's domain step: register a new domain, transfer one, use your own, a subdomain, or a domain already in the cart. Each choice is checked with WHMCS first, as the stock cart does, and WHMCS's message shows inline when a name won't do.
- Domain search with AI (smart) and Classic tabs, filters for TLDs, name length and safe search, prices in the results, and add to cart. Spotlight TLDs and suggestions come from WHMCS's smart lookup.
- TLD pricing table with register, transfer and renew prices.
- Transfer page with the EPP code and inline errors.
- Several domains can be added one after another.
- Domain configuration: registration period, hosting status, the EPP code for transfers, DNS management, ID protection and email forwarding priced per period, registry fields for TLDs that need them (such as .co.uk), and nameservers when there's no hosting.

### Cart and checkout

- Line cards for products (with their options and addons), addons, domains, renewals and upgrades, each with Edit and Remove.
- Empty Cart, a domain-period select, promo codes and a tax estimate for guests.
- Totals: subtotal, discount, two tax lines, recurring amounts and the total due today.
- Checkout for new and existing customers, with inline sign-in. A signed-in user on several accounts picks one; closed accounts can't be picked.
- Customer fields including tax ID and custom fields, a phone field with dial code, a password generator and strength meter, and the domain registrant contact.
- Notes, marketing opt-in, terms and captcha, as WHMCS is set up.
- Pay with account credit (all of it or part), choose a gateway, or use a new or saved card. Saved cards show the brand, and expired ones can't be chosen.
- A live total that adds VAT as the country changes.
- After checkout: the order number, a link to the unpaid invoice, recommendations, the fraud-check step and the error page.

### Renewals and addons

- Domain renewals, with grace and redemption periods, a period select and fees.
- Service and addon renewals.
- An addons page for adding an addon to an existing service.

### Other

- "Free" instead of 0.00 throughout the cart, when the setting is on.
- Template sources (`.tpl`, `.md`, `.yaml`, `.json`) can't be opened over the web.

## Page Builder (separate module)

- 75 ready-made sections in categories, with search.
- A visual editor with a live preview: drag and drop, typing straight onto the page, layers, move, duplicate, hide, remove, and undo and redo (80 steps).
- Desktop, tablet and phone preview, and a preview of the page with another style, menu, footer or dark mode.
- Save drafts, publish, and take a page offline. A draft is never served.
- Content, title and description per language.
- Images from Hadrian's media library, which shows where each image is used.
- Live sections: products and prices in the visitor's currency, and the latest announcements.
- Built pages are served at their own address. They can also replace the theme's homepage, announcements, knowledgebase or contact page, as always, never, or following the website setting. An admin can still open the theme's original page.
- Built pages appear in Hadrian's Pages screen for SEO, visibility and the sitemap.
- The page's sections can also be edited as a list on the Pages screen.
- The theme can override or add sections in its own folder.
- Content is cleaned on save: unsafe links and markup are dropped.

## Email Templates (separate module)

- Turns on and off. When on, it replaces WHMCS's email header, footer and CSS; when off, it puts WHMCS's own values back exactly as they were.
- Six designs: Card, Banner and Letter, plus Page, Panel and Notice in the style of the client area.
- Appearance: automatic, light or dark mode, logos, width, corner radius and custom CSS.
- A visual builder for the layout and for each email: 13 block types, an inspector, merge-field help, and a preview in light and dark, desktop and phone, with the email's size.
- Saving keeps a draft; customers only get what was published.
- Published separately for each language. Each email goes out in the recipient's language, right to left where needed.
- Notices when someone edits a template or the email settings in WHMCS directly.
- Takes the brand from Hadrian: colours, fonts, logos and social links.
- Removing a design restores WHMCS's template.

## Not built yet, or limited

- The licence gate in the client area is switched off, and the "revert to the old theme" enforcement isn't in this repo.
- The Invoice Builder has docs pages that say "coming soon". There's no module for it.
- Menu items save a description, badge, text style, hide-label switch and CSS class, but the theme doesn't show them yet.
- The icon rail's buttons are fixed: the Menu Manager doesn't change them.
- The login page's "Show Logo" setting isn't read by any design.
- MarketConnect store pages need active MarketConnect services.
- The cart's alternative plan-card designs exist for preview only.

## Open bugs

These features exist but have an open bug. Each one has a test that fails today, marked as a known bug, and the bug number points to the table in [tests/FEATURES.md](tests/FEATURES.md).

| Feature | What's wrong | Bug |
|---|---|---|
| Canonical URL | Keeps extra parameters, and encodes `rp=/` routes | 9, 10 |
| Knowledgebase search | Finds nothing, from the sidebar or the knowledgebase pages | 11 |
| Sidebar groups | Which groups are open isn't remembered | 12 |
| Top-bar crumb | Says "Client Area" instead of the page name | 13 |
| Sidebar highlight | The current page isn't highlighted in the sidebar | 14 |
| Preview parameters | Work on the live site without `?preview=1` | 15 |
| Error pages in RTL languages | Link a stylesheet that doesn't exist | 16 |
| Dashboard domain box | The typed name doesn't reach the order form | 17 |
| Services and invoices lists | Can't be sorted | 18, 19 |
| Invoice, quote and ticket status tabs | Always show an empty list | 20 |
| Email history | Stops at 10 emails, and opens a message without the navigation | 21, 25 |
| Glue records | The forms go to the dashboard | 22 |
| Mass pay by bank transfer | Stays on "Please wait" | 23 |
| Invoice "Amount due" | Shows the total, not what's still owed | 24 |
| Ticket form | No knowledgebase suggestions | 26 |
| Ticket feedback | Posts to a page that doesn't exist | 27 |
| Announcements RSS | Goes to the web page, not the feed | 28 |
| Account details | No save message; email preferences aren't saved | 29, 30 |
| Contacts | Adding one creates nothing; re-saving one changes its phone number | 31, 32 |
| Change Password | Doesn't change the password | 33 |
| Marketing emails | No way to opt back in from Account Details | 34 |
| Bento dashboard | The identity-card option does nothing | 35 |
| Configure step | The "Included" domain badge never shows; the quantity slider is 0px wide | 40, 41 |
| Store category select | Doesn't navigate, and shows twice at desktop width on some pages | 42, 43 |
| TLD pricing filters | Do nothing | 44 |
| Card number check at checkout | No error for a mistyped number | 45 |
| Checkout summary panel | Doesn't update with the country, and leaves out renewals | 46, 47 |
