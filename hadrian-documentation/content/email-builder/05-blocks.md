---
title: Blocks and merge fields
group: Reference
icon: puzzle
lead: The building blocks of an email, the options each one has, and how WHMCS merge fields work inside them.
---

## Blocks

Every block takes its colours and font from your Hadrian style. The options below are the ones you set per block.

### Heading

A title line. Three sizes: Large, Medium and Small. Alignment: Start, Centre or End.

### Text

Paragraphs with bold, italic, links and bulleted lists. Three sizes, an alignment, and a **Secondary colour** switch for small print.

Pasting drops the formatting from wherever the text came from and keeps the words. Format it with the toolbar afterwards.

### Button

One action. Set its label and where it goes. **Filled** uses your accent colour; **Tinted** is the quieter version for a second action. **Full width** stretches it across the email.

The link can be a merge field, such as `{$invoice_url}`.

### Details

Rows of a label on one side and a value on the other, up to twenty: amount due, due date, ticket number. **Tinted box** puts them on a tinted panel.

The value is where the merge field goes, for example a label of `Amount due` and a value of `{$invoice_total}`.

### Callout

A highlighted note with a coloured edge. Four tones: Info, Success, Warning and Danger.

### Image

A PNG or JPG from the Hadrian media library, with alt text, a width, an optional link and rounded corners. Mail apps do not show SVG or WebP.

### Divider and Spacer

A thin rule with small, medium or large spacing around it, or empty space from 4 to 96 pixels.

### HTML

Raw HTML and Smarty, sent as written. It is for what the other blocks cannot do: a `{foreach}` loop, or a merge field that returns HTML of its own such as `{$invoice_html_contents}`.

:::warn HTML blocks are not checked for you
Whatever you put here goes into the email unchanged, in every mail app. Keep it to simple tags, and send yourself a test.
:::

### Layout blocks

**Header**, **Email content** and **Footer** exist only in the layout. See [Layout and appearance](../layout/).

## Merge fields

A merge field is a placeholder WHMCS fills in when it sends: `{$client_first_name}` becomes the client's first name.

Click the **{ }** button beside a text field to pick one, or type it. With no block selected, the right column lists the fields for the kind of email you are editing, and clicking one copies it.

```merge
{$client_first_name}
{$invoice_num}
{$invoice_total}
{$invoice_url}
{$ticket_subject}
```

The list is a convenience. Any merge field WHMCS offers for that email can be typed by hand; WHMCS decides at send time whether it exists, and an unknown one comes out empty.

### Fields every email has

`{$client_first_name}`, `{$client_last_name}`, `{$client_name}`, `{$client_company_name}`, `{$client_email}`, `{$companyname}`, `{$whmcs_url}`, `{$whmcs_link}`, `{$signature}` and `{$date}`.

### Links and URLs

WHMCS often offers a field in two forms. `{$invoice_url}` is the address on its own; `{$invoice_link}` is a ready-made link. Use the `_url` form for a Button's link, and the `_link` form inside text or a Details value.

### Conditions

`{if}`, `{else}` and `{foreach}` work in an email's design, because WHMCS evaluates the published design itself:

```merge
{if $invoice_balance}Balance due: {$invoice_balance}{/if}
```

They do not work in the layout, which is the same for every email.

### Curly brackets in your text

Outside a merge field or a condition, a curly bracket is just a character. Type `use {curly} brackets` and that is what the client reads.

This matters because WHMCS treats an email template as code, and one unexpected bracket stops that email from being sent. The module escapes them for you when it publishes.
