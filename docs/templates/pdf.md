# PDF Templates

### `invoicepdf.tpl` - Invoice PDF Generation

This file uses **PHP with HTML**, not Smarty templates. It generates PDFs via the TCPDF library.

**Key PHP variables:**
```php
$status              // Invoice status (Paid/Unpaid/etc.)
$companyaddress      // Company address text
$taxCode             // Company tax code
$taxIdLabel          // Tax ID label
$pagetitle           // Invoice title
$datecreated         // Creation date
$duedate             // Due date
$clientsdetails[]    // Client info array
$customfields[]      // Custom field values
$invoiceitems[]      // Line items
$subtotal            // Subtotal
$taxname / $taxrate  // Tax level 1
$tax / $tax2         // Tax amounts
$credit              // Applied credit
$total               // Total amount
$transactions[]      // Payment transactions
$balance             // Outstanding balance
$notes               // Invoice notes
$invoiceQrHtml       // QR code HTML
$pdfFont             // PDF font name
$_LANG[]             // Language strings array
```

### `quotepdf.tpl` - Quote PDF Generation

Similar PHP/HTML structure:

```php
$quotenumber         // Quote number
$subject             // Quote subject
$datecreated         // Creation date
$validuntil          // Validity date
$proposal            // Proposal text
$lineitems[]         // Quote line items
$subtotal            // Subtotal
$taxlevel1 / $tax1   // Tax level 1
$taxlevel2 / $tax2   // Tax level 2
$total               // Total amount
$notes               // Quote notes
```

**Important:** These templates use `$_LANG['key']` for language strings instead of `{lang key='key'}`.

### `viewbillingnote.tpl` - Standalone Invoice View

This is a **standalone full HTML page** (not wrapped by header/footer). It has its own asset loading:

```smarty
<link href="{assetPath file='all.min.css'}?v={$versionHash}" rel="stylesheet">
<link href="{assetPath file='theme.min.css'}?v={$versionHash}" rel="stylesheet">
<link href="{assetPath file='invoice.min.css'}?v={$versionHash}" rel="stylesheet">
```

**Key variables:**
- `{$billingNote->lineItems}` - Line items collection
- `{$billingNote->taxes}` - Tax collection
- `{$billingNote->subTotal}` - Subtotal
- `{$billingNote->total}` - Total
- `{$billingNote->balance}` - Balance
- `{$transactions}` - Transaction history
- `{$issuedBy}` - Issuing entity name

### `viewemail.tpl` - Standalone Email View

Another standalone HTML page rendered in a popup:

```smarty
<iframe class="email-body" srcdoc="{$message}"></iframe>
```

Uses `window.close()` for the close button.
