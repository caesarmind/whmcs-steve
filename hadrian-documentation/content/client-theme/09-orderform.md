---
title: Order form
group: Order form
icon: cart
lead: A cleaner, faster WHMCS order process - from product selection to checkout - that matches the rest of Hadrian.
---

## Enable the template

The order form is the `hadrian_cart` folder in `/templates/orderforms/`. Once it is uploaded, set it as your default under **System Settings -> General Settings -> Ordering**.

```setting
Default Order Form Template:  Hadrian Cart
```

:::info It is listed as "Hadrian Cart"
WHMCS labels an order form from its folder name, so the dropdown entry reads **Hadrian Cart** rather than **Hadrian**. That is the right one.
:::

## Product layout

The product listing ships as a single layout: a pricing-column grid with one plan highlighted, which reflows to a stacked list on narrow screens. It inherits your Hadrian colors and typography, so it needs no separate styling.

Alternate layouts exist in the template source as design variants, but they are development-only - they are selected by a preview tool that is not part of a production install, and a live cart always renders the shipped layout.

## Admin preview

In the order-form picker, Hadrian Cart shows a branded 165x90 preview so it is easy to spot among the built-in templates.

:::shot Order form - checkout
