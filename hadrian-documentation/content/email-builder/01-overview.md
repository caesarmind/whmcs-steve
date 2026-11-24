---
title: Overview
group: Getting started
icon: mail
lead: Give every email WHMCS sends your logo, colours and footer, then redesign the ones your clients see most with blocks. A separate addon that takes its look from Hadrian.
---

## About

Hadrian Email Templates is its own WHMCS addon module. It is not part of the Hadrian theme and installs separately, but it needs Hadrian to be active: your email colours, font, logo and social links are the ones you already set in Hadrian.

It does two things.

- **A layout around every email.** A header and a footer that wrap each client email WHMCS sends, in your colours. Emails you have not touched keep their WHMCS text and sit inside it.
- **A block builder for individual emails.** Open an email such as Invoice Created, arrange headings, text, buttons and detail rows, and publish. WHMCS sends your design from then on.

:::shot img/email-overview.png The Email page: a preview of the layout around every email, and the settings only email needs

## How it fits into WHMCS

WHMCS already has a global email header, footer and stylesheet under **General Settings -> Mail**, and an email template for each message under **System Settings -> Email Templates**. This module works through those two places and nothing else.

- Turning it on replaces the global header, footer and CSS with your layout. The ones you had are kept and come back when you turn it off.
- Publishing a design writes it into that email's WHMCS template. The original template is kept and comes back when you remove the design.

Admin notifications are not affected. WHMCS does not wrap those in the global header, so they look the way they always did.

:::info Nothing changes until you say so
Activating the addon changes nothing about outgoing mail. Your emails only change when you turn the layout on, and an individual email only changes when you publish a design for it.
:::

## Workflow

:::steps
1. Install and activate the addon, then open **Hadrian -> Email**.
2. Pick one of the three designs under **Layout**. Adjust the header and footer if you want to, and set an email logo.
3. **Turn on.** Every client email now goes out inside your layout.
4. Pick an email, click **Design**, and arrange its blocks. Preview it in light, dark and on a phone.
5. **Publish.** Repeat for the emails that matter most to you.
:::

## What clients receive

- One of three designs: Card, Banner or Letter. See [Layout and appearance](../layout/).
- One column, 600 pixels wide by default, built from tables so it holds together in Outlook.
- Light by default, switching to your dark colours where the recipient's mail app is in dark mode. You can lock it to either.
- Mirrored automatically for right-to-left languages.
- No web fonts and no tracking images. The wrapper adds about 9 KB to an email.
