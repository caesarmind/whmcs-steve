---
title: Installation
group: Getting started
icon: rocket
lead: Upload the theme, activate the Hadrian addon, and apply your license. The whole process takes a few minutes.
---

## Upload the files

Hadrian ships three folders, and all three are needed - the theme, the admin addon, and the order form.

:::steps
1. Download the latest release from your account area.
2. Unzip and upload the `hadrian` folder to `/templates/`.
3. Upload the `Hadrian` folder to `/modules/addons/`.
4. Upload the `hadrian_cart` folder to `/templates/orderforms/`.
:::

```directory
templates/
  ├── hadrian/
  └── orderforms/
      └── hadrian_cart/
modules/
  └── addons/
      └── Hadrian/
```

:::warn Do not skip the order form
`hadrian_cart` is a separate folder from the theme. If you leave it out, Hadrian Cart will not appear in the order-form dropdown later.
:::

## Activate the addon

:::steps
1. In WHMCS admin, go to **System Settings -> Addon Modules**.
2. Find **Hadrian** and click **Activate**.
3. Grant access to the relevant admin roles, then **Save Changes**.
:::

## Apply your license

Open the Hadrian addon, go to **Info -> Manage license key**, paste the key from your account, and press **Save & check**.

```config
License Key:  hadrian-XXXXX-XXXXX-XXXXX
Status:       Active
```

:::warn Keep the key private
Treat your license key like a password - it ties the installation to your account.
:::

:::tip
[Licensing](/client-theme/licensing/) covers the rest: what each status means, what happens if a check fails, and how to reissue after a move.
:::

## Select the theme

Go to **System Settings -> General Settings -> General** and set the Client Area Template to **Hadrian**. Save, then reload the client area.

:::tip
You can preview Hadrian for your own session first via `?systpl=hadrian` before switching it on for everyone.
:::
