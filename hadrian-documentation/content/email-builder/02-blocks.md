---
title: Blocks & merge fields
group: Reference
icon: puzzle
lead: The building blocks of an email and the WHMCS merge fields you can drop into them.
---

## Blocks

- **Header** - logo and optional nav.
- **Text** - rich paragraphs with merge fields.
- **Button** - a single primary action.
- **Divider** & **Spacer** - rhythm and separation.
- **Footer** - company details and unsubscribe.

## Merge fields

Drop any WHMCS smarty merge field into a text or button block; it renders live in WHMCS as usual.

```merge
{$client_name}
{$invoice_num}
{$invoice_total}
{$invoice_payment_link}
```
