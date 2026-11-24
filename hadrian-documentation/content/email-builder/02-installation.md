---
title: Installation
group: Getting started
icon: rocket
lead: Upload one folder, activate the addon, and turn the layout on when you are ready. Turning it off again puts WHMCS back exactly as it was.
---

## Requirements

- WHMCS 9.
- The Hadrian addon, installed and activated. The module reads your colours, font, logo and social links from it and will not run without it.

## Install

:::steps
1. Upload the `modules/addons/HadrianEmail` folder from the package into your WHMCS `modules/addons/` directory.
2. In WHMCS go to **System Settings -> Addon Modules**, find **Hadrian Email Templates** and click **Activate**.
3. Click **Configure**, tick the admin roles that may use it, and save.
4. Open **Hadrian -> Email**. The module also appears under **Addons -> Hadrian Email Templates**.
:::

Activating creates two database tables of its own, `hadrian_email_settings` and `hadrian_email_designs`. It does not touch your mail settings or your email templates.

:::info If Hadrian is missing
With Hadrian not installed or not activated, the page says so and offers nothing else. Your mail is left alone.
:::

## Turning it on

Open **Hadrian -> Email** and click **Turn on**.

This replaces three WHMCS settings under **General Settings -> Mail**: Global Email Header Content, Global Email Footer Content and Global Email CSS Styling. The values you had are saved first.

From that moment every client email is wrapped in your layout. Emails keep their own text until you design them.

:::warn Edit the layout here, not in the Mail tab
While the layout is on, those three WHMCS settings belong to this module. If someone edits them in WHMCS, the Email page notices and asks what you want: put the Hadrian layout back, or keep that edit and turn Hadrian email off.
:::

## If the module cannot answer

For each email the module supplies the header and footer in the recipient's language. If it cannot, for example because the addon was deactivated or its files are being replaced during an update, WHMCS falls back to a complete copy of your layout in the default language. Clients never receive a bare, unstyled email.

## Turning it off

Click **Turn off** on the Email page. WHMCS gets its previous global header, footer and CSS back, byte for byte.

Published designs are not removed by this. They live in their WHMCS email templates and keep sending, inside whatever global header WHMCS now uses. Remove a design to put that email's original text back.

## Deactivating and removing

Deactivating the addon under **Addon Modules** always turns the layout off first, so WHMCS has its own header and footer back.

What happens to your designs depends on the **Remove data on deactivation** option under **Configure**:

- **Off (default).** Designs are kept, and published ones keep sending. Activate the addon again and everything is where you left it.
- **On.** Every published email is put back to its WHMCS original, then the designs and the module's two tables are deleted.
