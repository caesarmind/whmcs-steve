---
title: Designing an email
group: Design
icon: palette
lead: Open one of the WHMCS emails, arrange its blocks, preview it and publish. The original WHMCS template is kept and one click puts it back.
---

## Pick an email

The Email page lists every client-facing WHMCS email, grouped the way WHMCS groups them: General, Invoices, Products and services, Domains, Support, Users, Invitations and Affiliates. Admin notifications are not listed, because WHMCS does not send those through the global header.

Each row shows where that email stands.

- **WHMCS text.** Untouched. It goes out with its WHMCS text, inside your layout.
- **Draft.** A design exists but has not been published. Clients still get the WHMCS text.
- **Published.** Clients get your design.
- **Edited in WHMCS.** Published, and then someone changed the template in WHMCS's own editor. See below.

Click **Design** to start, or **Edit** to carry on.

## Starting points

Twelve of the most-seen emails come with a starter design, built from the merge fields the stock WHMCS template for that email uses:

- Client Signup Email, Order Confirmation
- Invoice Created, Invoice Payment Confirmation, Invoice Payment Reminder
- First, Second and Third Invoice Overdue Notice
- Support Ticket Opened, Support Ticket Reply
- Password Reset Validation, Email Address Verification

For every other email the current WHMCS text is carried over, so you start from what clients receive today. Plain text becomes an editable Text block. A body with tables or inline styles is kept exactly as it is in an HTML block.

Opening an email changes nothing. Nothing is saved until you click **Save draft**, and nothing reaches WHMCS until you click **Publish**.

## The builder

:::shot img/email-builder.png A starter design for Invoice Created, with the button selected and its options on the right

Three columns.

- **Left: blocks and outline.** Drag a block onto the email, or click it to add it after the selected block. The outline lists the blocks in order.
- **Middle: the email.** What the recipient gets, with your layout around it. Click a block to select it, drag it to move it.
- **Right: the selected block.** Its text and options. With nothing selected, the settings for the whole email.

Merge fields are filled with sample data in the preview, so you see a name and an amount instead of a row of braces. A condition shows its first branch.

### Moving blocks without a mouse

Click the email, then:

- **Up / Down** selects the previous or next block.
- **Alt + Up / Down** moves the selected block.
- **Delete** removes it.
- **Ctrl + D** duplicates it.

Every block in the outline also has move and delete buttons.

### Preview controls

The bar at the top switches the preview between **Light** and **Dark**, and between **Desktop** and **Mobile**. The language menu previews and edits a translation; see [Languages](../languages/).

## Subject and preview text

With no block selected, the right column holds two settings for the whole email.

- **Subject.** Leave it empty to keep the subject set in WHMCS.
- **Preview text.** The line an inbox shows after the subject. It needs Hadrian email to be on, because it is placed at the top of the layout.

Both accept merge fields.

## Publishing

**Publish** saves the design and writes it into that email's WHMCS template. From the next send, clients receive it.

Before the first publish the module keeps a copy of the template as it was. Every publish after that replaces your own previous version.

After publishing you can keep editing. **Save draft** stores your changes without sending them to WHMCS, and the status reads *Published, with unpublished changes* until you publish again.

:::info A design that would not send is not published
WHMCS does not send an email whose template has a syntax error. The module checks the compiled design first and refuses to publish one with an unclosed `{if}` or `{foreach}`, telling you which.
:::

## Going back

- **Unpublish** (in the builder, with no block selected): the WHMCS template goes back to how it was before the first publish. Your design is kept as a draft.
- **Remove design** (on the Email page): the same, and the design is deleted.

Both restore the original subject and text exactly.

## Edited in WHMCS

If someone opens a published email in **System Settings -> Email Templates** and saves it there, the Email page marks it **Edited in WHMCS**.

That edit is what clients now receive, and the module leaves it alone. It is not overwritten when your Hadrian style changes. Publishing the design again is the one thing that replaces it, and the builder warns you first.

## After a style change

A button's colour is written into the email when it is published. When you change your Hadrian style, open the Email page once: published designs are recompiled with the new colours.
