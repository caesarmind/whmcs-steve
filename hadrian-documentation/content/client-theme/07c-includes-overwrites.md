---
title: Includes and Overwrites
group: Customization
slug: includes-overwrites
icon: plug
lead: Where your own code and your own files go - the hooks that inject markup into a page, the handful of paths the theme reads if you create them, and an honest list of the things Hadrian has no file-drop for.
---

## Introduction

Every theme needs an answer to "I want something the settings screens do not
offer." Hadrian's answer is in three layers, and it is worth knowing which one
you are reaching for before you open an FTP client:

:::props
| Layer | Use it for | Survives an update |
| --- | --- | --- |
| The admin | Colours, fonts, custom CSS, menus, layouts, SEO, page templates | Yes - it is in the database, files cannot touch it |
| Output hooks | Injecting markup into a page from a WHMCS hook file | Yes - your hook lives outside the theme |
| Theme files | A short, exact list of paths the theme checks for and reads if present | Yes - all of them are paths the theme never ships |
:::

The rule that matters: **never edit a file the theme shipped.** The next update
replaces it and your change is gone with no warning. Everything below is a way
to add something *beside* the shipped files instead.

## Where each customization lives

Most of what other WHMCS themes ask you to do over FTP, Hadrian does in the
admin. This is the map.

:::props
| You want to | Where it lives |
| --- | --- |
| Add your own CSS rules | [Styles -> Custom CSS](/client-theme/styles/#custom-css) - not a file on disk |
| Use a font you host yourself | [Styles -> Typography](/client-theme/styles/#self-hosted-font) - upload the file, type the name |
| Change a colour, a radius, a shadow | [Style Manager](/client-theme/styles/) |
| Change wording, or add a language | [Languages](/client-theme/languages/#rewording-any-string-overrides) |
| Give one page a design of your own | [Customizing Pages](/client-theme/customize-pages/#add-a-template-to-a-page) |
| Replace a page's body entirely | [Customizing Pages](/client-theme/customize-pages/#replace-a-page-outright) |
| Build a new navigation or footer layout | [Custom Layouts](/client-theme/custom-layouts/) |
| Replace the footer or the logo block | [Customizing Pages](/client-theme/customize-pages/#two-smaller-override-points) |
| Inject markup into the head, the top of the page, the footer or the cart | **Output hooks**, below |
| Run your own PHP every page render | **Theme extensions**, below |
| Restyle the payment badges or the locale button | **Styling what the editor does not reach**, below |
:::

## Output hooks

WHMCS's own output hooks are the supported way to put your markup on a page,
and they are the safest customization in this article: your code lives in
`/includes/hooks/`, which no theme update touches.

Hadrian renders five of them, and it is worth knowing exactly where each one
lands, because "it did not appear" is nearly always "it appeared somewhere you
were not looking."

:::props
| Hook | Renders | Where exactly |
| --- | --- | --- |
| `ClientAreaHeadOutput` | Last thing in `<head>` | After the theme's own stylesheets, so your CSS wins on equal specificity |
| `ClientAreaHeaderOutput` | Immediately after `<body>` | Above all navigation chrome - this is the top-of-page banner slot |
| `ClientAreaFooterOutput` | In the footer | Below the footer layout, above the closing scripts |
| `ShoppingCartViewCartOutput` | On the cart page | Inside a card in the cart column |
| `ShoppingCartCheckoutOutput` | On the checkout page | Inside a card, and inside the checkout `<form>` |
:::

Your HTML is passed through unchanged - Hadrian does not rewrite or filter it.

:::tip The checkout hook is inside the form
`ShoppingCartCheckoutOutput` renders within the checkout form element, so an
`<input>` you return there is submitted with the order. That makes it the
nearest thing Hadrian has to a custom order-form field. Note that it renders
inside the styled offers card, and that nothing validates it for you - if the
field has to be filled in before the order can proceed, that is your own
JavaScript.
:::

:::warn Replacing the footer switches the footer hook off
`ClientAreaFooterOutput` is rendered by the shipped `footer.tpl`. If you create
`templates/hadrian/overwrites/footer.tpl`, your file renders instead and the
hook stops appearing unless you carry it across. See
[the warning in Customizing Pages](/client-theme/customize-pages/#two-smaller-override-points).
:::

WHMCS documents the full list of output hooks, and the template variables each
one receives, in its own developer documentation.

## Theme extensions

An extension is a small PHP file inside the theme that returns markup for the
head or the footer on every page. Use it when a hook file is the wrong home for
the code - when it is genuinely part of the theme and should travel with it,
rather than being an install-wide WHMCS hook.

Create the file:

```
templates/hadrian/core/extensions/<name>/<name>.php
```

It returns an array of slot names to callables. There are exactly two slots,
and any other key in the array is ignored:

```php
<?php

return [
    'headOutput' => function (array $vars): string {
        return '<meta name="fediverse:creator" content="@you@example.social">';
    },
    'footerOutput' => function (array $vars): string {
        return '<script>/* ... */</script>';
    },
];
```

The callable receives the template variables for the page being rendered and
returns a string, which is emitted as-is. Return an empty string to render
nothing.

:::warn An extension does not load until it is listed in theme.json
Unlike a custom layout or a page template, extensions are **not** discovered by
scanning the folder. Open `templates/hadrian/theme.json` and add the folder name
to `provides.extensions`, which ships empty:

```json
"extensions": ["my-extension"],
```

Without that line the file is never read. The **Extensions** screen in the admin
lists what is registered - it is a read-only view, not a place to register one.
:::

Because `theme.json` is a file the theme ships, an update will replace it and
drop your entry. Note it with your other post-update steps.

## Styling what the editor does not reach

Some things are rendered by the theme with no setting behind them. They are
still addressable from [Custom CSS](/client-theme/styles/#custom-css) - you just
need to know what to select.

### Payment gateway badges

Hadrian does not use gateway logo images, so there is no image folder to drop a
file into. Each payment option on checkout renders a small text badge, and the
row carries hooks you can target:

:::props
| Selector | What it is |
| --- | --- |
| `.co-pay-gateway[data-gateway="stripe"]` | One gateway's whole row. The value is the WHMCS system name, lowercased, spaces turned into hyphens |
| `.co-pay-logo` | The badge itself - this is what you would replace with a real logo |
| `.co-pay-name` | The gateway's display name |
:::

The badge also carries one of five style classes: `stripe`, `card` for any
credit-card gateway, `pp` for PayPal, `bank` for bank transfer and ACH, and
`gateway` for everything else. Anything unrecognised shows the first four
letters of the gateway name in capitals.

To show a real logo, hide the text and put your own image in with CSS:

```css
.co-pay-gateway[data-gateway="authorize-net"] .co-pay-logo {
  font-size: 0;                       /* hide the four-letter fallback */
  background: url(/assets/img/authorize.svg) center / contain no-repeat;
}
```

A customer's saved cards are separate: they render as `.pm-card-visual` with a
brand class of `visa`, `mc`, `amex`, `disc`, `cc` or `bank`.

### The locale button

The flag beside the language name is an **emoji**, chosen from the active
language - there is no flag image and no flags folder, so there is nothing to
replace on disk. The button is `.locale-btn` and the flag is `.locale-btn
.flag`, so hiding it is one rule. The chooser panel that opens lists native
language names with no flags at all.

[Languages](/client-theme/languages/#the-locale-chooser) covers the chooser
itself, including what to do about Windows, which renders flag emoji as a pair
of letters.

### Icons

Every icon in Hadrian is inline SVG written directly into the template that
draws it. There is no icon folder and no icon registry, so an icon cannot be
swapped by adding a file. Your options are the colour tokens under
[Styles -> Icons & avatars](/client-theme/styles/#icons-avatars), a Custom CSS
rule, or copying the page's template and editing the markup there.

## What Hadrian does not have

If you are arriving from another WHMCS theme, these are the file-drop
conventions you may be looking for that Hadrian does not implement. Each has a
supported route instead.

:::props
| Not in Hadrian | Do this instead |
| --- | --- |
| A `theme-custom.css` picked up from the active style folder | [Styles -> Custom CSS](/client-theme/styles/#custom-css). The style folders hold settings, not stylesheets |
| A payment gateway image folder | Custom CSS against `[data-gateway]`, above |
| A language flag image folder | Nothing to do - flags are emoji |
| An SVG icon or illustration override folder | Colour tokens, Custom CSS, or a page template |
| A custom terms-and-conditions checkbox file for the cart | `ShoppingCartCheckoutOutput`, which renders inside the checkout form |
| A general rule where a same-named file in an `overwrites/` folder replaces any template | Only three paths work, all listed in [Customizing Pages](/client-theme/customize-pages/#two-smaller-override-points) |
:::

:::warn Do not edit the cart's `custom.css`
`hadrian_cart/css/custom.css` looks like an invitation and is not one - it is a
file the order form ships and loads unconditionally, so an update overwrites it.
Cart styling goes in Custom CSS with everything else.
:::
