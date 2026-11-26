---
title: Page Manager
group: Configuration
icon: doc
lead: Every WHMCS page, in one list. Pick the template that renders it, set who can reach it, write its search-engine and social copy in as many languages as you run, and override the site-wide layout for that page alone.
---

## Introduction

Style Manager decides how the client area looks and Layout Manager decides what
frame it sits in. Both apply everywhere. Page Manager is where you say *this page
is different* - a different template, a different title in Google, a sidebar the
rest of the site does not have.

Open **Hadrian -> Pages**. Hadrian discovers your pages from the theme itself, so
the list is not a fixed set someone typed in: it is every page the installed
theme can render, over a hundred of them, grouped and searchable.

Nothing here needs a template file opened. Everything on this page is stored per
page, per theme, and survives theme updates.

:::info Where the settings live
Page settings are saved in Hadrian's own `hadrian_pages` table - one row per
page. They are not written into your template files, so updating the theme never
overwrites them.
:::

## The page list

The list opens on **All pages**: every page, one line each, grouped by the
part of the site it belongs to. The rail on the left narrows it.

:::shot img/pm-list-filters.png The rail, the search and the start of the list.

| In the rail | Shows |
| --- | --- |
| **Area** | All pages, or only the Website, the Client area or the Order process. Inside one area the list is grouped by the page's own group: Billing, Support, Built pages and so on. These are the same areas [Layout Manager](/client-theme/layout-manager/#by-visitor-or-by-area) and [Menu Manager](/client-theme/menu-manager/#menus-by-area) use. |
| **Changed by you** | Only the pages where you set something of your own: a template, SEO, visibility, indexing, an area or a layout. A good place to see what you have done to the theme. |
| **With templates** | Only the pages that offer more than one template. Each row names the template it uses and how many there are; hover that to see their names. |
| **Built with Page Builder** | Only the pages you made with the Page Builder, when it is installed. Export and import for them sit above the list. |
| **System pages** | Reveals pages you never navigate to: wizard sub-steps, parts another page includes, and the error states WHMCS shows instead of what you asked for. |

The search above the list matches a page's name, description and address as you
type, inside the view you are on. Go back to **All pages** to search everything.

System pages are hidden rather than dropped. A 2FA challenge or an upgrade
summary is a page a visitor really sees, so you can still give it a layout
override or a `noindex`: switch them on and they join the list. Searching for one
by name finds it whether the switch is on or not.

### What a row tells you

:::shot img/pm-list-rows.png Rows of the list. Click anywhere on a row to open that page's settings.

| Column | Shows |
| --- | --- |
| Page | The page's name. Hover the small *i* for one line on what it is. Pages made with the Page Builder carry a **Built** tag. |
| Address | Where the page lives on your site. Click it to open the live page in a new tab. *No direct address* means the page is only reached as a step, or needs a record such as an invoice. |
| Changed | A badge for each thing you changed: **Template: ...**, **SEO**, **Signed-in only**, **Disabled**, **Hidden from search**, **Own layout** or **Moved to ...**. Empty means the page is as the theme ships it. |
| **Manage** | Opens the page's settings, as clicking the row does. |

Order Process pages - Products, Configure Product, View Cart, Checkout and the
rest of the order form - take SEO, visibility, sub-nav and layout overrides like
any other page. They simply have no alternative templates to choose from,
because the order form renders from its own template.

### Pages made with the Page Builder

With the Page Builder module installed, the pages you build live here too. The builder has no list of its own: this is where a built page is made, found, configured and deleted.

| Control | What it does |
| --- | --- |
| **Add page** | In the header. Name the page and it opens in the builder's editor, as a draft. |
| **Website served by** | In the header: Theme or Page Builder. On Page Builder, a theme page that has a built replacement shows the replacement. It changes the live site at once, so it asks first and lists the pages that will change. |
| A row | Opens that page's settings, the same editor every page has. |
| **Edit content** | Opens the page in the builder, to work on its sections and its address. |

A built page takes the same settings as any page: SEO, indexing, visibility, area and a layout of its own. The sitemap lists it while it is published and public. Its row says where it stands: **Draft**, **Published**, **Serving as Homepage** while it stands in for a theme page, or **Standby for Homepage** while it is set to and the site is on the theme.

At the top of a built page's settings is a **Content** list: the page's sections, top to bottom, for when you would rather fill in fields than work on the page itself. It edits the same draft as the builder's visual editor, so a change made in one shows in the other.

| In the Content list | What it does |
| --- | --- |
| A row | Opens that section to edit its text, buttons, images and lists. One section is open at a time. |
| The arrows, or dragging a row | Moves the section up or down the page. |
| The switch | Shows or hides the section from visitors. A hidden section stays in the list, greyed out. |
| The copy and bin buttons | Duplicate the section, or remove it. |
| **Add section** | Picks a new section by category, the same ones the visual editor offers. It goes at the end. |
| **Save draft** | Saves the list. Visitors still see the published page. |
| **Publish** | Saves and puts the draft live. |
| **Preview** | Opens the page as it is now, unsaved changes included, in a new tab. Only you see it. |
| **Open visual editor** | Opens the same page in the builder, to change it on the page itself. |

The list saves on its own: **Save changes** at the foot of the screen saves the page's settings, not its sections.

At the foot of a built page's settings is a **Page Builder** panel with the two things only the builder knows:

- **Replaces** lets the page stand in for one of the theme's website pages: Homepage, Announcements, Knowledgebase or Contact Us. *Follow site* uses it while the website is served by Page Builder, *Always* uses it whatever the site says, and *Never* keeps it on standby.
- **Delete page** removes the page, its sections and its settings.

The theme page says so too, in its Changed column: *Replaced by ...* while the built page is serving, *... on standby* while it waits.

Clicking a row opens that page's editor. Everything from here down is one page's
settings; **Back to Pages** returns to the list, **View page** opens the live
page, and nothing is written until you press **Save changes**.

:::shot img/pm-editor-head.png The top of the page editor.

## Page template

A page can ship more than one template. The **Page template** panel shows every
one Hadrian found for that page, with the active one marked.

:::shot img/pm-templates.png The four templates that ship for the Dashboard.

Click **Activate** on a card and save. Three pages ship alternatives today:

| Page | Templates it ships |
| --- | --- |
| Dashboard | Default, Atrium, Bento, Minimal |
| Sign in | Default, Beacon, Split + Announcements |
| Homepage | Modern, Classic |

What each of those renders, and every setting it offers, is catalogued in
[Page Templates](/client-theme/page-templates/).

Every other page has one template, and its panel simply shows that one card.
Order Process pages have none at all and say so - the order form is rendered by
its own template, not from `core/pages`. Neither is a fault; there is just
nothing to choose.

:::tip A/B by page, not by guess
Because the choice is per page and takes effect immediately, switching the
Dashboard between Bento and Minimal for a fortnight each is a real experiment
you can run without touching a template file.
:::

## Template settings

Underneath the template cards sits **Template settings** - the options belonging
to the template you just picked. Pick a different template and the panel changes
with it, because these options are declared by the template, not by the page.

:::shot img/pm-template-settings.png Settings that belong to the selected template.

Some templates declare a lot - the three alternative dashboards each carry a
drag-to-reorder block builder here - and some declare none. When the selected
template has no options of its own the panel says so.

Every setting, template by template, is documented in
[Page Templates](/client-theme/page-templates/).

:::info Switching templates does not lose your settings
The settings of a template you are *not* using are kept. Configure Bento, switch
to Minimal for a week, switch back - Bento is exactly as you left it.
:::

A few options belong to the page rather than to one template, and stay put
whichever card is active. [Full Page](/client-theme/page-templates/#full-page-mode)
on the Sign in page is the one worth knowing: it hides the navigation and footer
so the page fills the window.

## Page settings

These apply whichever template is selected.

:::shot img/pm-page-settings.png Visibility, sub-nav and controls placement.

### Visibility

Who can reach the page. Unlike Indexing - which politely asks crawlers - this
one is enforced when the page is requested.

:::props
| Option | Stored as | What happens |
| --- | --- | --- |
| Public | `public` | Renders for everyone, is eligible for `sitemap.xml`, and Page Manager offers an **Open** link. The default. |
| Authenticated only | `auth` | Signed-out visitors are redirected to the login page. Kept out of the sitemap. |
| Disabled (404) | `disabled` | Every visitor is sent to WHMCS' page-not-found page. Kept out of the sitemap, and the Open link goes too. |
:::

A signed-in admin still sees a Disabled page from the same browser, so you can
check what you disabled before anyone asks why it is gone.

:::info Three kinds of page ignore this setting, deliberately
The sign-in and password-reset pages - a login gate on the login page is a
redirect loop, and locking password reset locks out exactly the people who
need it. The order form, because a dropdown must not be able to break a
checkout in progress. And the dead ends WHMCS sends rejected visitors to -
Banned, Access Denied, store Not Found - which must render for precisely the
visitors a gate would turn away. Whatever these pages' rows say, they render.
:::

Client-area pages already sit behind WHMCS' own login. **Authenticated only**
puts that same gate on pages WHMCS ships public, and **Disabled** takes a page
off the site without deleting anything - flip it back and it returns intact.

To take a page out of your navigation, edit the menu in
[Menu Manager](/client-theme/menu-manager/) - that is a separate control and the
one that changes what visitors see.

### Section sub-nav

Show or hide this page's sidebar sub-navigation. **Inherit (global default)**
follows the site-wide toggle in **Settings -> Order / Website Section Sidebar**;
**On (always show)** and **Off (always hide)** override it for this page.

### Area

The part of the site this page belongs to: **Website**, **Client area** or **Order process**. It decides which layout the page gets when layouts are chosen by area (see [Layout Manager](/client-theme/layout-manager/#by-visitor-or-by-area)); with layouts chosen by visitor it has no effect.

**Automatic** goes by what the page is, and shows the result in brackets. Pick an area to move the page.

### Controls placement

Where a list page's search and pagination controls sit: **Inside the card** keeps
them in the white panel with the table, **Outside the card** floats them on the
page background, and **Inherit (global default)** follows the site-wide **Card
Titles Outside the Box** setting.

This row only appears on the pages that have such controls - Services, Invoices,
Quotes, View Invoice, View Quote, Add Funds, Support Tickets, Dashboard and
Affiliates. On every other page it is absent rather than inert.

## SEO

The SEO panel runs down the right of the editor and is always available - there
is no switch to turn on first.

:::shot img/pm-seo.png The SEO panel, on a page that has been filled in.

### Indexing

:::props
| Option | Robots meta | What it does |
| --- | --- | --- |
| Inherit from site default | none | WHMCS' own behaviour applies and the page can be indexed. The default. |
| Allow indexing | none | Same page head, but the page becomes eligible for the sitemap. |
| Disallow indexing | `noindex, nofollow` | Keeps the page out of search results and out of the sitemap. |
:::

:::warn Pages are indexable until you say otherwise
A fresh install adds no `robots` meta tag anywhere, which means search engines
may index client-area pages. If there are pages you do not want in search
results, set them to **Disallow indexing** deliberately - nothing does it for
you.
:::

### Public URL

The path to this page relative to your site root - `contact.php`, `login`,
`store/ssl-certificates`. It does two things: it powers the **Open** link in the
list, and it is the URL written into `sitemap.xml`.

Leave it blank to keep the page out of the sitemap entirely. A page needs a
public URL, **Public** visibility and indexing other than Disallow before it is
listed.

### Title, description and social image

**SEO title** replaces the whole `<title>` tag. Leave it blank and Hadrian falls
back to the WHMCS page title followed by your company name.

**SEO description** becomes the meta description. Blank falls back to your WHMCS
tagline.

**Social image** is the picture used when the page's link is shared. Pick one
from your media library with **Choose image**, or paste a URL underneath.
1200 x 630 is the size to aim for.

The counters beside the title and description fields - `0/64` and `0/160` - are
the lengths search engines display before truncating. They are guidance, not a
limit; longer text saves fine.

:::warn One page, many records
A handful of pages render a different record every time they load - View
Announcement, Knowledgebase Article, Knowledgebase Category, Download Category.
SEO here is stored against the *page*, so a title you write on Knowledgebase
Article is the title every article gets. Leave those blank and each one keeps
its own heading, which is almost always what you want.
:::

From those three fields Hadrian generates the whole social set, so there is
nothing else to fill in:

| You set | Hadrian emits |
| --- | --- |
| SEO title | `<title>`, `og:title`, `twitter:title` |
| SEO description | `<meta name="description">`, `og:description`, `twitter:description` |
| Social image | `og:image`, `twitter:image`, and switches `twitter:card` to `summary_large_image` |
| nothing at all | `canonical`, `og:url`, `og:type`, `og:site_name`, and `hreflang` alternates when alternate links are on |

### Writing SEO copy in every language

Title and description are stored per language, not as one string. The
**Language** picker switches which language you are editing, and the counter
beside it - `1/4 translated` - tells you how far through you are.

**Edit all languages** opens every language at once:

:::shot img/pm-seo-languages.png The per-language editor, opened from the SEO panel.

:::steps
1. Click **Edit all languages**.
2. Type into the language you want, or narrow the list with **Filter languages** and **Only missing**.
3. **Copy default -> empty** fills every untranslated language with your default-language text, as a starting point.
4. Click **Done**, then **Save changes**.
:::

A language you leave empty is not a gap - the page falls back to your default
language for that visitor.

## Custom layout

The two dropdowns at the bottom of the right rail override
[Layout Manager](/client-theme/layout-manager/) for this page and no other.

:::shot img/pm-custom-layout.png Per-page main-menu and footer overrides.

Both start on **Use global layout**. Choose a specific main-menu or footer layout
and that page renders with it, whatever the site-wide setting is. The override is
resolved on the server before the page is sent, so there is no flash of the wrong
layout.

The usual reason to reach for it: a full-width marketing homepage on top
navigation while the client area runs on the sidebar, or a checkout page with the
footer stripped back.

## Adding your own page

Pages the theme does not ship - a landing page, a policy page, anything you build
yourself - can be registered so they appear in Page Manager with the same
template, SEO and layout controls as everything else. Hadrian ships a working
example: `custom-page.php` in your WHMCS root, already registered in the Public
group of this list.

It is four small files, and the full walkthrough - the entry file, the
dispatcher, the `page.php` reference, full-width pages and login gating - is
its own article: [Creating Pages](/client-theme/creating-pages/).

:::tip No cache to clear
Hadrian fingerprints the `core/pages` directory, so a page you just added appears
on your next visit to the Pages tab. There is no version to bump and no rebuild
to run.
:::

## Replacing a page you did not write

If you want to rewrite a stock page's body outright, do not edit the theme's
file - the next update will replace it. Drop your version at:

```
templates/hadrian/core/pages/<page>/overwrites/overwrites.tpl
```

When that file exists it renders instead of every template for that page,
including whichever one is selected in the admin. Deleting it hands the page back
to the theme.

:::warn An overwrite outranks the admin
While `overwrites.tpl` is in place, the Page template panel still shows a card as
Active, but the page renders your file. If a template change appears to do
nothing, check that directory first.
:::
