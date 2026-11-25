---
title: Accessibility
group: Configuration
slug: accessibility
icon: book
lead: What Hadrian does for WCAG 2.2 AA and the European Accessibility Act, what stays your job as the site owner, and how to publish your accessibility statement.
---

## What the law asks

The European Accessibility Act (Directive 2019/882) applies to services sold to consumers in the EU from 28 June 2025, and online shops are on its list. A hosting company that sells to consumers through WHMCS is in scope. Businesses with fewer than 10 staff and under EUR 2 million turnover are exempt, but their resellers and larger customers may still ask.

The law binds you, the business, not the theme. The technical standard behind it is EN 301 549, whose web chapter is WCAG. Hadrian is built and tested to WCAG 2.2 level AA, which covers the 2.1 level the standard cites today and the 2.2 level its next version moves to.

:::info A theme cannot make a site compliant on its own
Hadrian handles the parts a theme controls: its own templates, styles and scripts. Your content, your colour choices, your modules and your payment gateways are yours. The checklist at the end of this article covers them.
:::

## What Hadrian does

Every client-area page, order step and store page the theme draws:

- **Keyboard.** Everything works without a mouse. The first Tab stop is a "Skip to main content" link, every control shows a 2px focus ring in your accent colour, menus open and close from the keyboard, dialogs keep focus inside until they close, and Escape dismisses menus, dialogs and tooltips.
- **Screen readers.** Pages are built from landmarks (header, navigation, main, footer) and headings, every form field has a label, every button has a name, decorative icons are hidden, and changes that happen without a page load, such as order totals, domain search results and table filters, are announced.
- **Colour.** Text, links, status labels and form borders meet the WCAG AA contrast ratios in light and dark mode, in every shipped style. The colour of text on your accent buttons is worked out from your accent, black or white, so a light brand colour stays readable.
- **Zoom and small screens.** Pages reflow to a single column at 320 pixels wide and stay usable at 400% zoom.
- **Motion.** Carousels and scrolling sections have a Pause button, and nothing animates when a visitor's device asks for reduced motion.
- **Forms.** Checkout and sign-up fields have visible labels and the `autocomplete` values browsers and password managers use. When a form comes back with errors, focus moves to the error list.
- **Language.** The page language follows the visitor's WHMCS language, right-to-left languages are marked as such, and each entry in the language picker is announced in its own language.

The Page Builder keeps one top-level heading per page, and every image field in it has an alternative text box. The email designs use the same contrast rules and work out the text colour on accent buttons the same way.

## What stays your job

Hadrian cannot see or fix these. Each one can break conformance on its own.

- **Your colours.** If you change colours under Styles > Colors, keep text at 4.5:1 against its background and form borders at 3:1. The defaults and the shipped styles already pass.
- **Images you add.** Your logo, product images, announcement and knowledgebase images, and Page Builder images need alternative text that says what the image shows. Leave it empty only when an image is decoration.
- **Content you write.** Use headings in order in announcements and knowledgebase articles, write link text that makes sense on its own ("Read the migration guide", not "click here"), and caption any video.
- **Modules and gateways.** Server modules, third-party addons, live chat widgets, cookie banners and payment pages draw their own markup. Ask their vendors for their accessibility conformance report.
- **Captcha.** The built-in image captcha has no alternative for people who cannot see it. In WHMCS's General Settings, on the Security tab, choose a reCAPTCHA type instead (it offers an audio challenge), or turn the captcha off on forms where you can.
- **Session length.** WHMCS ends idle sessions without warning, which can lose a half-finished order. Keep the session lifetime generous on your server.
- **PDF invoices.** WHMCS generates PDFs that screen readers cannot read well. Every invoice is also a web page in the client area, and your statement should say so.
- **Support.** Your support team should be able to answer accessibility questions and take requests in more than one way, such as tickets and email.

## Publishing your accessibility statement

The Act asks you to publish how your service meets the requirements, in your terms or an equivalent page. Hadrian ships a statement page with the wording written for you; you fill in the parts only you know.

1. In WHMCS, open **Addons > Hadrian > Pages** and find **Accessibility statement**.
2. Fill in its options: conformance status, known limitations, how you checked, a contact email, the enforcement body for your country, and the dates.
3. Make the page reachable. In your WHMCS root, copy `custom-page.php` to `accessibility.php` and change `setTemplate('custom-page')` to `setTemplate('accessibility')`. The page is then at `https://your-domain/accessibility.php`.
4. Link to it from your footer. The footer menu presets include an **Accessibility** link; point it at `accessibility.php` in **Menu Manager**.

:::warning Hadrian does not ship accessibility.php
The statement goes live only when you create the entry file in step 3. That way a statement still holding its default answers never appears on your site by accident.
:::

Review the statement at least once a year, and whenever you change your theme settings, add modules or switch payment gateways.

## Before you go live

- Every image you added has alternative text, or an empty one if it is decoration.
- Your colours still pass, if you changed any.
- Tab through a sign-up, an order and a ticket: you can reach and use everything, and you can always see where you are.
- Third-party modules, chat widgets and gateways you use are accessible, or listed as limitations in your statement.
- Your accessibility statement is filled in, published and linked from every page.
