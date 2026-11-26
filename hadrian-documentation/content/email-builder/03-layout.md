---
title: Layout and appearance
group: Design
icon: layout
lead: The header and footer around every email, and the handful of settings only email needs. Colours and font come from your Hadrian style.
---

## Designs

Six designs set the overall look of every email. Pick one on the Email page under **Layout**, or in the layout builder with no block selected. They come in two groups.

:::shot img/email-designs.png The designs, rendered with your own colours and logo

**Classic**

- **Card.** Your logo above the message, which sits on a white card on a soft grey page. The default.
- **Banner.** A band in your accent colour carries your logo and the email's subject as a large title, joined to the card below it.
- **Letter.** No card: a centred logo, the message on a plain page and fine rules between the parts, like a receipt.

**Client area**

These three are drawn from screens of your Hadrian client area, so an email looks like the account it came from. Each heads the message the way the client area heads a page: the section in small capitals, the title, and a status pill.

- **Page.** Like a client area page. Your logo and links sit on a bar with a fine rule under it, then the section, title and status, then the message on a card.
- **Panel.** Like the client area's summary panels. The logo, the heading and the message share one card, with a fine rule under the logo.
- **Notice.** Like the client area's notice bar. The title and status sit on a tinted bar with an info mark, and the message is on a card below it.

All six take their colours, font and logo from your Hadrian style, switch to your dark colours in dark mode, and mirror for right-to-left languages. If you change your Hadrian style, the emails follow it.

### Section and status

The client-area designs add two things next to the title. Both come from WHMCS, and both are in the recipient's language.

- **Section.** The kind of email, from its WHMCS template type: Billing, Services, Domains, Support, Account or Affiliates.
- **Status.** Only for the stock WHMCS emails that are always sent in one state. For example, an invoice is Unpaid when **Invoice Created** goes out and Paid when **Invoice Payment Confirmation** does. Welcome emails show Active, a suspension notice shows Suspended, and a ticket reply shows Answered.

Every other email, including any template you created yourself, shows its section and title with no status. The words are WHMCS's own client area strings, so your language overrides apply to them.

### What switching changes

Switching design changes the page colour, how the header is drawn, and whether the message sits on a card. It also resets a few options to suit the design: header and footer alignment, the content card, and whether the header shows the email's subject.

Everything you wrote stays: the tagline, header and footer links, footer text, social links and the unsubscribe setting. You can change any option again afterwards in the layout builder.

### The subject in the header

**Show the email subject** in the header block puts each email's subject under your logo as a title. Banner and the three client-area designs turn it on; Card and Letter leave it off, but you can turn it on in any design. In the client-area designs the section and status go with the title, so turning the subject off removes all three.

The subject is the one WHMCS sends, in the recipient's language, with its merge fields filled in. If the module is ever not available when an email is sent, that email goes out without the title, section and status rather than with placeholders.

:::info The banner needs a light logo
Your normal logo is usually dark, which disappears on a coloured band. The Banner design uses your **Logo for dark mode** on the band. Without one, it sets your company name in white instead.
:::

## The layout

The layout is what every email shares: a header above the message and a footer below it. Open **Hadrian -> Email** and click **Edit layout**.

It is built from the same blocks as an email, with one fixed block in the middle.

- **Header.** Your logo, an optional tagline and up to four links.
- **Email content.** Where each email's own message goes. It cannot be removed. Choose whether it sits on a card, and how much padding it has.
- **Footer.** A line of text, up to eight links, your social profiles and the unsubscribe link.

You can add other blocks above or below the content, such as a text line under the header that appears on every email.

:::info A saved layout is live
There is no draft for the layout. With Hadrian email on, saving changes the emails that go out from then on.
:::

### Footer links

A new layout starts with the links from your site's legal footer menu in Hadrian, so Privacy and Terms are usually there already. They are copied once: edit them in the footer block afterwards.

### Social links

The footer lists the profiles set under **Hadrian -> Branding**, as text links. Turn **Show social links** off in the footer block to hide them.

### Unsubscribe

WHMCS supplies an unsubscribe address on the emails where it applies. The footer shows the link on those emails and leaves it out of the rest.

### Merge fields in the layout

Merge fields such as `{$companyname}` and `{$whmcs_url}` work in the header and footer. Conditions such as `{if}` do not: the layout is the same for every email. Use `{$hx_year}` for the current year in a copyright line.

## Colours and font

There is nothing to set. Emails use the colours of your active Hadrian style, including a changed accent, and its font stack.

No web font is loaded. Most mail apps ignore the request, and the ones that honour it contact the font host every time the email is opened. Your font is named first in the stack, so it is used wherever the recipient has it installed, with system fonts after it.

When you change your Hadrian style, open the Email page once. Published designs are recompiled with the new colours.

## Appearance settings

These are on the Email page, under **Appearance**.

:::props
| Setting | Default | Description |
| --- | --- | --- |
| Light and dark | Follows Hadrian | `Match the recipient's device` sends a light email that switches to your dark colours in dark mode. `Always light` and `Always dark` lock it. Until you choose, a site locked to one mode in Hadrian sends that mode. |
| Email logo | Your site logo | A PNG, JPG or GIF. Leave empty to use the logo from Branding when it is one of those types. |
| Logo for dark mode | None | Shown instead of the email logo where the email is dark. Use a light-coloured version. |
| Width | `600` | The width of the email in pixels, from 480 to 720. |
| Corner radius | `16` | Rounding of the content card, from 0 to 28. |
| Custom CSS | Empty | Added to the style block of every email. |
:::

### Why the logo must be a PNG

Gmail and Outlook do not display SVG or WebP images. If your Hadrian logo is one of those, the Email page tells you and emails show your company name as text until you set an email logo.

Use a PNG at twice the size it will be shown, so it stays sharp on phones.

### Dark mode support

Not every mail app applies an email's dark styles, and some apply a dark treatment of their own instead. Where an app does not use yours, the recipient gets the light version, which is why light is always the base.

### Custom CSS

Many mail apps strip style blocks, so the email is built with inline styles and does not depend on this field. Use it for refinements only.
