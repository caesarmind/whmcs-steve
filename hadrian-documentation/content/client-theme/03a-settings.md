---
title: Settings
group: Configuration
slug: settings
icon: sliders
lead: Every theme-wide switch in one screen - colour mode, navigation, prices, languages, consent and table loading, plus the order-form controls for the Configure Server step. One setting per block, with what each one actually changes for your customers.
---

## Introduction

Settings is where the site-wide options live - the ones that decide how the
client area *behaves* rather than how it looks. Whether visitors can switch to
dark mode. Whether a `0.00` reads as "Free". Whether a customer configuring a
server sees the hostname field at all.

Everything here starts as one switch for the whole site. Three of them also take
a list of pages that get the opposite treatment, and those are called out where
they apply.

Open **Hadrian -> Settings**. The screen has two tabs.

:::shot img/set-tabs.png The two tabs. General applies everywhere; Order Process applies to the cart.

:::props
| Tab | Applies to | What it covers |
| --- | --- | --- |
| General | Everywhere | Appearance, navigation, pricing, languages and privacy - every page of the client area |
| Order Process | The order form | The cart's own sidebar, and the Configure Server step of product configuration |
:::

Both tabs are one form: whichever tab you press Save on, Hadrian writes the
settings from both.

:::warn Save before you switch tabs
Clicking the other tab reloads the page, and a toggle you flipped but did not
save is lost when it comes back.
:::

## Appearance

Colour mode, label casing, and how a card is put together.

:::shot img/set-appearance.png The Appearance group, with dark mode switched on so its two options show.

### Section Titles Capitalization

**On by default.** Writes the small labels on your public-facing pages in
CAPITALS.

These are the small labels rather than the headings themselves: the short word
or phrase above a section heading, the category tags on store pages, the tier
label beside a plan ("Most popular"), and the eyebrow above a page title in the
client area - the product group shown on a service, for instance. With it on they
read as `MOST POPULAR`; with it off they read as `Most popular`.

Turn it off if your brand voice is quieter, or if you write those labels in a
language where capitals read as shouting.

:::info What it leaves alone
Table headings like "Recent Invoices", sidebar labels and nav dropdown headers
keep their capitals either way. Those are interface decisions rather than section
titles, so they sit deliberately outside this setting's reach.
:::

### Enable Dark Mode

**On by default.** Decides whether dark mode exists on your site at all.

Switch it off and every visitor sees the light site, with no way to change it.
Switch it on and two more options appear underneath, which together decide
whether *visitors* choose the mode or *you* do.

:::props
| Option | Default | What it does |
| --- | --- | --- |
| Choose Display Type | Switcher | **Switcher** gives visitors a light/dark control and remembers their choice for next time. **Forced** removes that control and locks everyone to the default mode |
| Choose Default Mode | Light | The mode the site loads in - for everyone under Forced, or until a visitor changes it under Switcher |
:::

:::info Pinning the site to dark takes both options
Set Display Type to **Forced** *and* Default Mode to **Dark**. Forced on its own
only removes the switch - if Default Mode is still Light, your site is now
permanently light and nobody can change it.
:::

:::warn There is no "follow the operating system" mode
Hadrian does not read `prefers-color-scheme`. Default Mode is the mode the site
loads in for everyone, whatever their laptop is set to. That is deliberate: the
mode is decided on the server, so the page never flashes the wrong colour while
it loads.
:::

The colours dark mode uses are yours to edit - see
[Style Manager](/client-theme/styles/), which keeps a separate value for every
colour in each mode.

### Card Titles Outside the Box

**Off by default.** Lifts a page's title out of the white card and onto the page
background.

Off, a standard page is one white card: the title, any search or pagination
controls, and the content all sit inside it together. On, the title and the
controls beside it float on the page background, and the card underneath goes
flat - a lighter, more spacious look. It applies to standard card pages across
the client area, not only lists.

:::warn Some pages pin their own card layout
Invoices, Quotes, Support Tickets, Add Funds, View Invoice, View Quote, Domains
and the Dashboard decide their own treatment in the template and ignore this
toggle. Those pages are built around bespoke cards that the floating treatment
would pull apart, so they opt out on purpose.
:::

Underneath the toggle is a page picker labelled **Per-page exceptions**. Anything
you add there gets the *opposite* treatment: with the toggle on, a listed page
keeps its title inside the card; with the toggle off, a listed page floats it.
Use it when one page looks better the other way round without changing the rest
of the site.

:::info A page's own setting still wins
If you set Controls placement explicitly on a page in
[Page Manager](/client-theme/page-manager/), that beats both this toggle and the
exception list - on every page except the ones listed above, which ignore all
three.
:::

## Navigation

Menu icons, and the small card of related links beside your content.

:::shot img/set-navigation.png Two toggles, and the exception picker under the second.

### Top-Nav Icons

**Off by default.** Shows a small icon beside each item in the top navigation.

Icons make a short menu easier to scan and a long one busier, which is why this
is a choice rather than a default. It covers the top-level items and the items
inside dropdowns and mega-menus.

:::warn Two things have to be true for an icon to appear
This toggle only *permits* icons - each menu item also needs an icon chosen for
it in [Menu Manager](/client-theme/menu-manager/). An item with no icon simply
renders as text, so if you switch this on and nothing changes, the icons have not
been picked yet.
:::

:::info Top Navigation layout only
The sidebar and icon-rail layouts draw their own navigation and ignore this
setting. If your site runs on Sidebar, this toggle has nothing to act on - see
[Layout Manager](/client-theme/layout-manager/).
:::

### Website Section Sidebar

**On by default.** Shows the small card of related links beside the page content.

:::shot img/set-subnav.png The section sub-nav on an Account page - its own heading, and links to the rest of that group.

This is the card a customer sees on the client area itself, not in the admin
panel. It appears only on pages that belong to a **group** - Account, Domain,
Billing, Support and a few others - and it always shows the group the current
page is in: an Account page lists Account Details, User Management, Payment
Methods and so on, while a Domain page swaps to the domain list with its own
heading.

Switching it off hides the whole column beside the content, not only the section
card.

:::warn On some pages that column carries more than links
View Invoice keeps the invoice summary and the Download PDF button there, and a
service's own actions - Login to cPanel, Change Password, Upgrade, Cancel - sit
in that column on Product Details. Turning the toggle off takes those with it,
and they are not reachable from the main menu. Use the per-page exceptions to
keep the column on the pages that need it.
:::

Its own **Per-page exceptions** picker works like the one under Card Titles
Outside the Box: a listed page gets the opposite of the toggle, and a page's own
setting in Page Manager beats both.

:::info This is not the main menu
What appears *in* the navigation is [Menu Manager](/client-theme/menu-manager/);
where the navigation sits is [Layout Manager](/client-theme/layout-manager/).
This toggle only decides whether that column is drawn.
:::

## Pricing Display

How prices are written. Nothing in this group changes what a customer is
actually charged - no price, no currency, no tax rule, no invoice. Each one
changes how an already-calculated number appears on the page.

:::shot img/set-pricing.png Two toggles. Neither one changes what a customer is charged.

### "0.00" -> "Free"

**Off by default.** Writes a zero price as the word "Free" instead of `$0.00`.

A zero that reads as a price makes people hesitate - `$0.00/mo` looks like
something went wrong with the calculation. "Free" reads as an offer. Turn this on
if you run free plans, free trials, free add-ons, or bundle a domain at no charge
with a hosting package.

It covers the order form end to end - every step, the cart summary and the
checkout totals - along with the service and upgrade prices in the client area
and the money columns in the data tables.

:::info Where it does not reach
The marketing homepage and the `/store/*` pages print their prices from their own
templates, as do invoice line items and totals, so a zero on those stays `$0.00`.
:::

:::info It follows your language
The word comes from your WHMCS language files, so a German visitor sees the
German word rather than the English one.
:::

### Hide Billing Cycle Discounts

**Off by default.** Removes the "Save X%" pills next to the billing-cycle
choices when someone configures a product.

By default, choosing between Monthly, Annually and Biennially shows a small
badge on the longer cycles telling the customer how much they would save. It is
a nudge towards longer commitments and it works - which is exactly why some
shops do not want it.

Turn it on if you would rather present each cycle as a flat price and let people
choose on their own terms, or if your pricing is structured so the percentages
read oddly. The cycles and their prices stay exactly as they were; only the
badges go.

## Language and SEO

The locale chooser your visitors use, and the link tags that tell search engines
about your translations.

:::shot img/set-locale.png Alternate links, and the language picker revealed under Custom Language List.

### Enable Alternate Links

**On by default.** Adds `hreflang` tags to every page, one per language you
offer.

These tags tell Google that your English page and your German page are the same
page in two languages, rather than two pages competing with each other. Without
them, search engines can treat translations as duplicate content and show the
wrong one to the wrong audience.

Leave it on if you run more than one language. On a single-language install it
emits next to nothing, so there is no reason to turn it off either.

:::info Languages need a recognisable name
The tag values have to be standard codes, so Hadrian maps your WHMCS language
names ("french" becomes `fr`) using a table that covers every language WHMCS
ships. A language file with a name the table does not recognise is left out of
the tags - the page still works, it just is not advertised in that language.
:::

### Custom Language List

**Off by default.** Lets you decide which languages the locale chooser offers.

By default the chooser lists every language installed in WHMCS - which, on a
fresh install, is a long list of languages you have not translated anything into.
Turn this on and a picker appears, **Languages shown to clients**, listing what
is installed with a count of what you have chosen. Tick the ones you actually
support.

Only languages that really exist under `/lang/` can be picked, so a stale
selection can never leave a customer staring at a language you removed.

:::info Where the chooser itself lives
This decides what is *in* the chooser. Whether the chooser is shown at all is
**Hide Language Switcher**, over on
[Layout Manager -> Header](/client-theme/layout-manager/#header).
:::

## Privacy and Performance

The consent banner, and how big data tables load.

:::shot img/set-privacy.png The consent banner and the data-table loader.

### Cookie Box

**Off by default.** Shows a consent banner to first-time visitors.

Switching it on reveals the banner's own three fields, so you can write it,
place it and label its button without touching a template.

:::shot img/set-cookiebox.png Message, position and button label, revealed under the toggle.

:::props
| Field | Default | What it is |
| --- | --- | --- |
| Message | empty | The banner copy. Basic HTML is allowed, so you can link your privacy policy |
| Position | Bottom left | Where the banner sits: Bottom left, Bottom right, or Bottom (full width) |
| Button label | Continue | The text on the button that dismisses it |
:::

The message is stored **per language**. Pick a language from the selector above
the box and write that language's copy; a dot beside a language in the list means
copy already exists for it. A visitor whose language has no message falls back to
your system default language's message, and then to the theme's built-in
sentence - so the banner is never blank, even if you save no copy at all.

:::warn Clearing a box deletes that translation
Emptying the message for a language removes it rather than saving an empty
string, and only languages installed under `/lang/` are stored at all.
:::

### Enable Dynamic AJAX Loading

**Off by default.** Fetches the client area's data tables from the server a page
at a time, instead of building every row into the HTML.

Either way your customer pages through ten rows at a time - what changes is how
much work the page does before it can appear. Off, the whole table is rendered
into the page first; on an account with two thousand domains, that is two
thousand rows of HTML. On, the table arrives empty and each page of ten is
fetched as it is needed, with sorting, filtering and searching answered by the
server instead of re-worked in the browser.

It covers the client area's data tables: services, domains, invoices, tickets,
quotes and emails.

:::tip Worth turning on for large accounts, not for small ones
On an account with a dozen services you will not notice a difference. On one with
thousands, you will notice several seconds of it.
:::

## Order Process

The second tab. Everything on it affects the order form and nothing else.

## Cart Layout

The order form's own sidebar.

:::shot img/set-cart.png The order form's own sidebar, and its exception picker.

### Order Category Sidebar

**On by default.** Shows the Categories / Actions sidebar on the storefront and
domain steps of the order form.

This is the column beside the store listing that lets a customer jump between
product categories and reach cart actions without going back. Switching it off
gives the products the full width - worth considering if you sell from a single
category, where a category list of one is just furniture.

It reaches four pages: Products, Register a Domain, Transfer a Domain and
Product Domain. The remaining steps either have no Categories sidebar at all or
keep theirs regardless.

Its **Per-page exceptions** picker behaves like the ones on the General tab: a
listed page gets the opposite of the toggle, and a page's own setting in
[Page Manager](/client-theme/page-manager/) beats both. The picker lists every
order page, but only those four respond to it.

## Configure Server

The settings below all target the **Configure Server** step of product
configuration - the panel that asks for nameservers, a hostname and a root
password.

:::warn Mostly, but not entirely, Server products
WHMCS only renders the Configure Server panel for products whose type is
**Server**, so the settings that hide fields there do nothing on a shared-hosting
or "Other" product. **Hide on Checkout page** is the exception: it acts on the
cart rather than that panel, whatever the product type.
:::

### Hide Product Nameservers

**Off by default.** Hides the **NS1 Prefix** and **NS2 Prefix** fields during
product configuration.

Most customers ordering a server have no idea what to put in a nameserver prefix
field, and a field nobody understands is a field that loses orders. Hiding it
removes the question.

Turning the switch on reveals **Apply to**, with two choices:

- **All Products** - every server product on the install.
- **Selected Product Groups** - only the groups you tick, in a searchable picker that appears underneath.

:::shot img/set-nameservers.png Switched on and narrowed to one product group.

"All Products" is stored as *all*, not as a snapshot of today's group IDs - a
product group you create next month is covered without coming back here.

### Hide Product Hostname

**Off by default.** Hides the **Hostname** and **Root Password** fields during
product configuration.

Same reasoning as the nameservers, and the same **Apply to** choice. The
difference is what happens to the values: WHMCS still requires both, so Hadrian
supplies them behind the scenes. The root password is generated, and the hostname
comes from the builder below.

:::shot img/set-hostname.png Hostname hidden for all products, with the hostname builder open underneath.

### Use Custom Hostname

**Off by default.** Shapes the hostname the cart generates.

Leave the fields empty and each order gets a random block followed by your
company name as the domain. Fill them in and you decide the shape, with a worked
example that updates as you type.

:::props
| Field | Default | What it is |
| --- | --- | --- |
| Subdomain zone | empty | A label sitting between the random block and the domain. The dot in front of it is added for you |
| Random length | 20 | How many random characters lead the hostname. Anything from 8 to 50 |
| Domain | empty | Closes the hostname. A leading dot is added for you if you leave it off |
| Random character set | all three | Which characters the random block is drawn from: Uppercase, Lowercase, Numbers - tick any combination |
:::

The hostname is assembled as `<random>.<zone><domain>`, so a zone of `srv` and a
domain of `.hostnodes.com` at a random length of 20 produces something like
`k3n8x2vq7mtd94rblz06.srv.hostnodes.com`.

**Example hostname**, under the three fields, re-rolls as you type. It uses the
length you set and the characters you ticked, and it applies the same tidying-up
that saving does - so what you see is what your orders will get, and you see it
before saving rather than after the first order.

:::info The random block always leads
Nothing puts a readable label at the *front* of the hostname - `srv-k3n8...` is
not reachable. The zone is a middle label, which is what makes each generated
name a per-order host sitting under one fixed zone.
:::

Leave the zone and the domain both empty and the hostname falls back to your
company name as the domain. Tick none of the character types, or all three, and
all three are used.

:::warn Switching the toggle back off does not undo the fields
A zone and domain you saved keep applying to new orders even with the switch off
- the switch itself only controls the random character set. To get the plain
fallback back, clear those two fields and save.
:::

### Hide on Checkout page

**Off by default.** Also hides the hostname line under each product when the
customer reviews their cart.

Hiding the hostname field stops customers *entering* a hostname, but the
generated value still shows under each item on the Review & Checkout page. Switch
this on and that line goes.

:::warn It does not hide every copy of it
The Order summary panel on the same page still prints the hostname beside the
item, so this reduces how visible the string is rather than removing it. It also
ignores the product type: with Hide Product Hostname set to All Products, the
domain line disappears under every product in the cart, hosting included.
:::

### Enable Password Strength For Root Password Field

**Off by default.** Adds a strength meter to the **Root Password** field during
product configuration.

The meter shows customers how strong their password is as they type, and the
same score is checked again on the server when the form submits - so a weak
password is turned away even if the customer has JavaScript switched off.

It affects that one field. Registration and the client area's own password
screens are untouched.

:::info The bar is deliberately low
Anything scoring 50 out of 100 is accepted, which a short all-digit password such
as `1234` still reaches. Treat this as a nudge towards better passwords rather
than a password policy.
:::

:::shot img/set-rootpw.png One switch, on the Order Process tab.

:::info It has nothing to do with Hide Product Hostname
Hiding the hostname also hides the root password field and generates a password
for it, so the meter would have nothing to attach to. This setting is for
installs that leave the field visible.
:::

## What is configured somewhere else

Several things that feel like settings are not on this screen, because they
belong to the thing they change:

- Make the navbar slide away as you scroll down and return as you scroll up, unpin the sidebar, or hide the breadcrumb - [Layout Manager -> Header](/client-theme/layout-manager/#header)
- Hide the language switcher or the currency selector - [Layout Manager -> Header](/client-theme/layout-manager/#header)
- Hide the footer social icons, or add a back-to-top button - [Layout Manager -> Footer](/client-theme/layout-manager/#footer-options)
- Change the footer company description or the social URLs - [Branding -> Brand Info](/client-theme/branding/#brand-info)
- Show or hide the account block in the sidebar - [Layout Manager](/client-theme/layout-manager/#per-layout-options), per layout
- Change colours, fonts, radii, or add custom CSS - [Style Manager](/client-theme/styles/)
- Hide one page, or give it its own layout and SEO copy - [Page Manager](/client-theme/page-manager/)
- Change what appears in the navigation - [Menu Manager](/client-theme/menu-manager/)
