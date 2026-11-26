---
title: Installation
group: Getting started
icon: rocket
lead: Upload the files, activate the Hadrian addon, and finish on its Setup page. The whole process takes a few minutes.
---

## Upload the files

Hadrian ships three folders and a license check, and all four are needed - the theme, the admin addon, the order form, and the files that verify your license.

The release zip is laid out like a WHMCS installation. Unzip it and upload what is inside into your WHMCS folder: `templates`, `modules` and `includes` merge with the folders already there, and nothing of yours is replaced.

:::steps
1. Download the latest release from your account area and unzip it.
2. Upload `templates`, `modules` and `includes` into the folder WHMCS is installed in.
3. Check that the four parts landed where the list below shows.
:::

- the `hadrian` folder in `/templates/`
- the `hadrian_cart` folder in `/templates/orderforms/`
- the `Hadrian` folder in `/modules/addons/`
- two license files in `/includes/hooks/`

```directory
templates/
  ├── hadrian/
  └── orderforms/
      └── hadrian_cart/
modules/
  └── addons/
      └── Hadrian/
includes/
  └── hooks/
      ├── hostnodes_theme_license.php
      └── hostnodes_license_config.php
```

:::warn Do not skip the order form
`hadrian_cart` is a separate folder from the theme. If you leave it out, the client area still works, but orders stay on your current order form.
:::

## Activate the addon

:::steps
1. In WHMCS admin, go to **System Settings -> Addon Modules**.
2. Find **Hadrian** and click **Activate**.
3. Grant access to the relevant admin roles, then **Save Changes**.
:::

Activating creates Hadrian's database tables and its default menus. It does not change what your clients see yet.

## Finish on the Setup page

Open **Addons -> Hadrian**. Until the theme is live, the addon opens on its **Setup** page, a checklist of everything that has to be in place. Each row is read from your installation every time the page loads, so it shows what is true now, not what was true when you installed.

| Step | What it checks |
|-|-|
| **Files** | The theme, the order form and the license check are uploaded, and nothing is missing from them |
| **Requirements** | PHP and WHMCS versions, PHP extensions, and that the upload folder can be written to |
| **Database** | Hadrian's tables and default menus exist and match the uploaded files |
| **License** | Your license key is entered and valid for this domain |
| **Go live** | Hadrian is the client area theme and the order form |

A row marked **Ready** needs nothing. **Check** means it works but is worth a look. **To do** is a step you have not done yet, and **Problem** is something to fix first; the row says what and where.

:::tip
If an upload was cut off, Files names what did not arrive. Upload that folder again and reload the page.
:::

You can come back to this page at any time from **Info -> Setup checklist**.

## Apply your license

On the Setup page, paste the key from your account into the **License** step and press **Save & check**.

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

When every step above **Go live** is done, press **Make Hadrian live**. It sets the client area theme, and the order form if you uploaded it, for the whole site. Clients see Hadrian on their next page load.

To look before you switch, press **Preview first**. It opens the site in Hadrian for your browser only, with the Hadrian order form too if you uploaded it. That is the same as adding `?systpl=hadrian&carttpl=hadrian_cart` to a client area address.

Hadrian remembers the theme it replaced. **Switch back** on the same page restores it, and the order form with it.

:::tip
The button writes the same setting as **System Settings -> General Settings -> General**, so you can also pick the Client Area Template there, and the Default Order Form Template under the **Ordering** tab.
:::

## After an update

Upload the new files over the old ones, then open **Addons -> Hadrian**. WHMCS sees the new version number and applies any database changes the update brings, so in most cases there is nothing else to do. Your clients keep seeing the site normally while the files upload.

To confirm, open **Info -> Setup checklist**. **Release** shows the new version and **Database** shows **Ready**.

If WHMCS did not finish the update, for example because the files were uploaded twice under the same version, the addon opens on Setup with **Tables** marked **To do** and a note that an update has not been applied. Press **Run now**. It only adds what is missing, so it is safe to press more than once.
